



/* 
-- =============================================
-- Author:			MKB
-- Create date: DEC 2021
-- Description:	importing the tade data FROM clearer dealreports 
-- Changes:
--		20-07-2022 // nasdaq data gets meanwhile imported via database link and gets therefore excluded from any further import // mkb, 07/2022

-- =============================================
*/

CREATE PROCEDURE [dbo].[Import_Clearer_TradeData]
   @ClearerToImport nvarchar(20)
   ,@COBString nvarchar(20) = ''  /*Optional Parameter - Format 'YYYY-MM-DD' : It sets the COB date to a custom one*/
AS
BEGIN TRY

	DECLARE @LogInfo Integer
	DECLARE @proc nvarchar(40)
	DECLARE @Step Integer

	DECLARE @PathName nvarchar (300)
	DECLARE @FileName nvarchar(100)	
	
	DECLARE @sql nvarchar (max)
	DECLARE @counter Integer
	
	DECLARE @ClearerID Integer
	DECLARE @ClearerType nvarchar (20)
	
	DECLARE @SourcePath nvarchar(300)
	DECLARE @SourceFile nvarchar(300)
	
	DECLARE @COB as DATE
	DECLARE @logheader nvarchar(100)

	SELECT @proc = Object_Name(@@PROCID)
	SELECT @ClearerType ='Trades'
	SELECT @SourcePath = 'ClearerCSV'+@ClearerToImport							
	SELECT @SourceFile = 'Clearer'+@ClearerType+@ClearerToImport	

	SELECT @logheader = 'Clearer - Trade Data import for ' + @ClearerToImport 

	SELECT  @Step = 1
	/* Get the COB date if not set manually by a parameter */
		IF @COBString = ''
			SELECT @COB = cast(asofdate_eom as date) FROM dbo.asofdate as cob
		ELSE
			SELECT @COB = cast(@COBString as date)
	
  --/* get Info if Logging is enabled */  
	SELECT @Step=2
	SELECT @LogInfo = [dbo].[LogInfo].[LogInfo] FROM [dbo].[LogInfo]
	
	/*nasdaq data gets imported already directly via database link!*/
	IF @ClearerToImport ='Nasdaq' 
	BEGIN 
		IF @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] SELECT @logheader + ' must only be done by databaselink', GETDATE () END
		GOTO NoFurtherAction 
	END
	
  IF @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] SELECT @logheader + ' and COB ' + convert(varchar, @COB, 23) + ' - START', GETDATE () END
		
	--/*identify ClearerID*/
	SELECT @Step=3
	SELECT @ClearerID = ClearerID FROM dbo.table_Clearer WHERE ClearerName=@ClearerToImport

	--/*delete potential previously loaded data for this clearer and type FROM final table*/
	SELECT @Step=4
  if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] SELECT @logheader + ' - delete old data', GETDATE () END
	DELETE FROM dbo.table_Clearer_DealData WHERE ClearerType = @ClearerType AND clearerID = @ClearerID 

	--/*identify importpath (same for all files of same type for one clearer )*/
	SELECT @Step = 5
	IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @logheader + ' - identify and load import files', GETDATE () END
  SELECT @PathName = [dbo].[udf_get_path_custom_asofdate](@SourcePath, @COBString)  

	SELECT @Step = 6
	--/*use a counter as there might be files of same type for one clearer!*/
  SELECT @counter = count(1) FROM [dbo].[FilestoImport] WHERE  [dbo].[FilestoImport].[Source] like @SourceFile and ToBeImported=1
		 
		--/*in case here is no importfile, create a reladed log entry and jump out*/
	SELECT @Step = 7
	IF @counter=0 
	BEGIN 
		INSERT INTO [dbo].[Logfile] SELECT @logheader + ' - no data found to get imported.', GETDATE () 
		GOTO NoFurtherAction 
	END		

--	--/*drop and recreate temp table*/
	SELECT @Step=8
	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'table_Clearer_DealData_temp'))
  BEGIN 
		DROP TABLE dbo.table_Clearer_DealData_temp
	END

	CREATE TABLE dbo.table_Clearer_DealData_temp (
		ReportDate nvarchar(100) NULL,
		AccountName nvarchar(100) NULL,
		CCY nvarchar(100) NULL,
		TradeDate nvarchar(100) NULL,
		DealNumber nvarchar(100) NULL,
		ContractName nvarchar(100) NULL,
		StartDate nvarchar(100) NULL,
		EndDate nvarchar(100) NULL,
		ProjectionIndex1 nvarchar(100) NULL,
		ProjectionIndex2 nvarchar(100) NULL,
		ExternalBU nvarchar(100) NULL,
		InternalPortfolio nvarchar(100) NULL,
		Toolset nvarchar(100) NULL,
		ContractSize nvarchar(100) NULL,
		Position nvarchar(100) NULL,
		TradePrice nvarchar(100) NULL,
		CallPut nvarchar(100) NULL,
		StrikePrice nvarchar(100) NULL,
		Premium nvarchar(100) NULL,
		Broker nvarchar(100) NULL,
		FeeRate nvarchar(100) NULL,
		TotalFee nvarchar(100) NULL,
		AdjustedTotalFee nvarchar(100) NULL,
	) ON [PRIMARY]

	--/*loop over counter, reduce it at the end*/      
	SELECT @Step = 9
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] SELECT @logheader + ' - importing from ' + @pathname , GETDATE () END
	WHILE @counter > 0
		BEGIN
		  --/*identify importfile*/
			SELECT  @FileName = [FileName] 
				FROM (SELECT *, ROW_NUMBER() OVER(ORDER BY ID) AS ROW  FROM [dbo].[FilestoImport] WHERE [dbo].[FilestoImport].[Source] like @SourceFile and ToBeImported=1) as TMP  
				WHERE ROW = @counter
		
			--/*reolve date placeholders in filename*/
			SELECT  @FileName = dbo.udf_Resolve_Date_Placeholder_custom_asofdate(@FileName,@COBString )
		
			SELECT @Step = @step + @counter
			if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] SELECT @logheader + ' - now importing ' + @FileName, GETDATE () END
			--/*import data into temp table*/
			--TRUNCATE TABLE [dbo].[table_Clearer_DealData]
			SELECT @sql = N'BULK INSERT [dbo].[table_Clearer_DealData_temp] FROM '  + '''' + @pathname + @FileName + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR ='','', FIRSTROW = 2, ROWTERMINATOR =''\n'')';
			execute sp_executesql @sql
			
			/*now document the last successful import timestamp */
			SELECT @Step = 99
			update dbo.FilestoImport set LastImport = getdate() WHERE [Source] like @SourceFile 
		
			--/*reduce counter*/
			SELECT @counter = @counter - 1
	END 

	--/*transfer data to final table*/
			INSERT INTO [dbo].[table_Clearer_DealData]
           ([ReportDate]
           ,[DealNumber]
           ,[AccountName]
           ,[InternalPortfolio]
           ,[ExternalBusinessUnit]
           ,[ContractName]
           ,[ContractSize]
           ,[BrokerName]
           ,[TradeDate]
           ,[StartDate]
           ,[EndDate]
           ,[ProjectionIndex1]
           ,[ProjectionIndex2]
           ,[Toolset]
           ,[Position]
           ,[CCY]
           ,[TradePrice]
           ,[StrikePrice]
           ,[Premium]
           ,[CallPut]
           ,[FeeType]
           ,[FeeRate]
           ,[TotalFee]
           ,[AdjustedTotalFee]
           ,[ClearerID]
           ,[ClearerType]
		   ,[Source]
					)
   		SELECT 
				 convert(date,ReportDate,103)
				,DealNumber
				,AccountName
				,InternalPortfolio
				,ExternalBU
				,ContractName
				,CAST([ContractSize] as float) as ContractSize
				,[Broker]
				,TRY_CONVERT(Date, TradeDate, 103) as TradeDate
				,TRY_CONVERT(Date, StartDate, 103) as StartDate
				,TRY_CONVERT(DATE, EndDate, 103) as EndDate
				,ProjectionIndex1
				,ProjectionIndex2
				,Toolset
				,CAST(Position as float)
				,CCY  
				,CAST(TradePrice as float)
				,CAST(StrikePrice as float) 
				,CAST(Premium as float) 
				,CallPut
				,Null as FeeType
				,CAST(FeeRate as float)
				,CAST(TotalFee  as float)  
				,CAST(AdjustedTotalFee as float)					
				,@ClearerID as ClearerID
				,@ClearerType as ClearerType 
				,@pathname as [Source]
			FROM 
				dbo.table_Clearer_DealData_temp

NoFurtherAction: 
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] SELECT @logheader + ' - FINISHED', GETDATE () END
END TRY
	
BEGIN CATCH
	EXEC [dbo].[usp_GetErrorInfo] @proc, @Step
	BEGIN INSERT INTO [dbo].[Logfile] SELECT @logheader + ' - FAILED', GETDATE () END
END CATCH

GO

