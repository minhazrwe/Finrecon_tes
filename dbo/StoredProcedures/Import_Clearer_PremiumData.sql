





/* 
=============================================
	Author:      MKB			
	Created:     DEC 2021 
	Description:	importing the settlement data FROM clearer accounting-reports
	Changes:		
	2022-07-19:
	As "ContractDate" does not always contain proper dates in the original data, but as well product names like "CAL-2022" oder "Q4-2023", 
	the so far unused filed "productname" is used as well with the content of contract_date. "ContractDate" itself gets only filled if a proper date is available

-- =============================================
*/

CREATE PROCEDURE [dbo].[Import_Clearer_PremiumData] 
		@ClearerToImport nvarchar(20) 		/*--welche kann es geben ? --> die aus der table_clearer*/
		,@COBString nvarchar(20) = ''  /*Optional Parameter - Format 'YYYY-MM-DD' : It sets the COB date to a custom one*/
AS
BEGIN TRY

  DECLARE @step Integer		
	DECLARE @proc nvarchar(50)
	DECLARE @LogInfo Integer
		
	DECLARE @PathID integer
	DECLARE @PathName nvarchar (300)
	DECLARE @FileName nvarchar(200)
	DECLARE @SourcePath nvarchar(300)
	DECLARE @FileSource nvarchar(300)
			
	DECLARE @sql nvarchar (max)
	DECLARE @counter Integer

	DECLARE @ClearerID Integer	
	DECLARE @ClearerType nvarchar(20)  
	
	DECLARE @COB as DATE
	DECLARE @logheader nvarchar(100)
		
	SELECT @proc = Object_Name(@@PROCID)
	SELECT @ClearerType ='Premium'
	SELECT @SourcePath = 'ClearerCSV'+@ClearerToImport
	SELECT @FileSource = 'Clearer'+@ClearerType+@ClearerToImport	
	
	SELECT @logheader = 'Clearer - Import Premium Data for ' + @ClearerToImport

	--/*identify ClearerID*/
	SELECT @step=@step+1  
	SELECT @ClearerID = ClearerID FROM dbo.table_Clearer WHERE ClearerName=@ClearerToImport
	
	SELECT  @Step = 1
	/* Get the COB date if not set manually by a parameter */
		IF @COBString = ''
			SELECT @COB = cast(asofdate_eom as date) FROM dbo.asofdate as cob
		ELSE
			SELECT @COB = cast(@COBString as date)

  --/* get Info if Logging is enabled */
	SELECT @LogInfo = [dbo].[LogInfo].[LogInfo] FROM [dbo].[LogInfo]

	/*nasdaq data gets imported already directly via database link!*/
	IF @ClearerToImport ='Nasdaq' 
	BEGIN 
		IF @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] SELECT @logheader + ' must only be done by databaselink', GETDATE () END
		GOTO NoFurtherAction 
	END


  IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @logheader + ' and COB ' + convert(varchar, @COB, 23) + ' - START', GETDATE () END
	IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @logheader + ' - delete old data', GETDATE () END
		
	--/*delete old import data FROM temp_table*/
	--/*drop and recreate temp table*/
	SELECT @step=2
	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'table_Clearer_PremiumData_temp'))
	BEGIN DROP TABLE dbo.table_Clearer_PremiumData_temp END
	
	CREATE TABLE dbo.table_Clearer_PremiumData_temp(
		TradeDate nvarchar(100) NULL
		,AccountName nvarchar(100) NULL
		,DealNumber nvarchar(100) NULL
		,ContractName nvarchar(100) NULL
		,ContractDate nvarchar(100) NULL
		,ProjectionIndex1 nvarchar(100) NULL
		,ProjectionIndex2 nvarchar(100) NULL
		,InternalPortfolio nvarchar(100) NULL
		,Toolset nvarchar(100) NULL
		,Position float NULL
		,TradePrice float NULL
		,StrikePrice float NULL
		,Premium nvarchar(20) NULL
		,CallPut nvarchar(100) NULL
		,CCY nvarchar(100) NULL
		,DeliveryType nvarchar(100) NULL
		---,ExcerciseDate nvarchar(100) NULL
) ON [PRIMARY]
		
	SELECT @step=3
	--/*delete potential previously loaded data for this clearer + type FROM final table*/
	DELETE FROM dbo.table_Clearer_AccountingData WHERE ClearerType = @ClearerType AND clearerID = @ClearerID 
	
  IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @logheader + ' - identify and load import files', GETDATE () END
	
	SELECT @step =4
	--/*identify importpath (same for all files of same type for one clearer )*/
	SELECT @PathName = [dbo].[udf_get_path_custom_asofdate](@SourcePath, @COBString)      

	--/*use a counter as there might be files of same type for one clearer!*/
	SELECT @step =5
	SELECT @counter = count(1) FROM [dbo].[FilestoImport] WHERE  [dbo].[FilestoImport].[Source] like @FileSource and ToBeImported=1

	SELECT @counter 

	--/*in case here is no importfile, create a reladed log entry and jump out*/
	IF @counter=0 
	BEGIN 
		INSERT INTO [dbo].[Logfile] SELECT @logheader + ' - no data found to get imported.', GETDATE () 
		GOTO NoFurtherAction 
	END		
	 
--/*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx*/
-----   ACHTUNG! 
-----		Nasdaq hat drei eingehende datentabellen !!
-----		da müssen wir aufpassen !!!
--/* xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx*/

	--/*loop over counter, reduce it at then end*/ 
	WHILE @counter > 0		 
		BEGIN		  			
			--/*identify importfile*/
			SELECT @step=@step+1
		  SELECT @FileName = [FileName]
			FROM (SELECT *, ROW_NUMBER() OVER(ORDER BY ID) AS ROW  
            FROM [dbo].[FilestoImport] 
            WHERE [dbo].[FilestoImport].[Source] like @FileSource and ToBeImported=1) as TMP 
      WHERE ROW = @counter

			SELECT @filename = dbo.udf_Resolve_Date_Placeholder_custom_asofdate(@FileName,@COBString) 

			--/*import data into temp table*/						
			SELECT @step=@step+1  					 	  
			IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @logheader + ' - import from ' + @PathName + @filename, GETDATE () END			
			--TRUNCATE TABLE  [dbo].[table_Clearer_PremiumData_temp]
			SELECT @sql = N'BULK INSERT [dbo].[table_Clearer_PremiumData_temp] FROM '  + '''' + @PathName + @filename + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR ='','', FIRSTROW = 2, ROWTERMINATOR =''\n'')';
			EXECUTE sp_executesql @sql
		 
		 	--/*reduce counter*/
			SELECT @counter = @counter - 1
		END


		--/*Delete imported "empty" rows FROM dbo.table_Clearer_PremiumData_temp*/
		DELETE FROM dbo.table_Clearer_PremiumData_temp where dealnumber is null and TradeDate is null
		
		--/*now that all files have been imported into temp table, move the complete data in ione go to final table*/
		SELECT @step=6
		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @logheader + ' - fill destination table', GETDATE () END			

	  INSERT INTO [dbo].[table_Clearer_AccountingData]
    (  CoB
			,DealNumber
			,AccountName
			,InternalPortfolio
			,ContractName
			,ContractDate
			,ProductName
			,SettlementDate
			,ExerciseDate
			,DeliveryDate
			,ProjectionIndex1
			,ProjectionIndex2
			,Toolset
			,Position
			,TradePrice
			,SettlementPrice	--contains "StrikePrice" when it's an option!
			,RealisedPnL			--contains "Premium" when it's an option!		
			,CCY
			,DeliveryType
			,ClearerID
			,ClearerType
		)    
		SELECT 
			@COB as cob 
			,DealNumber
			,AccountName
			,InternalPortfolio
			,ContractName
			,try_convert(date, ContractDate,103) as ContractDate
			,ContractDate as ProductName
			,convert(date, TradeDate,103) as TD
			,NULL ExcerciseDate 
			,NULL as DeliveryDate
			,ProjectionIndex1
			,ProjectionIndex2
			,Toolset
			,Position
			,TradePrice
			,StrikePrice as SettlementPrice
			,round(Premium,2) as RealisedPnL
			,CCY 
		  ,DeliveryType
		--,[Call_Put]
			,@ClearerID
			,@ClearerType		
		FROM dbo.table_Clearer_PremiumData_temp
		

		SELECT @step=7
		/*now update all contractDates, where we found something else than a date */		
		UPDATE dbo.table_Clearer_AccountingData 
		SET ContractDate = c.ContractExpirationDate
		FROM 
			dbo.table_Clearer_map_ExpirationDate c 
			inner JOIN dbo.table_Clearer_AccountingData ON c.ReferenceID= dbo.table_Clearer_AccountingData.DealNumber 
		WHERE 
			dbo.table_Clearer_AccountingData.DealNumber in 
			(select distinct DealNumber FROM dbo.table_Clearer_AccountingData WHERE ContractDate is null)
			AND ClearerID = @ClearerID
			and ClearerType	=	@ClearerType	


		SELECT @step=8
		--/*now document the last successful import timestamp */
		update [dbo].[FilestoImport] set LastImport = getdate() WHERE [Source] like @FileSource and ToBeImported=1

NoFurtherAction:
		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @logheader + ' - FINISHED', GETDATE () END
	END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
		BEGIN INSERT INTO [dbo].[Logfile] SELECT @logheader + ' - FAILED', GETDATE () END
	END CATCH

GO

