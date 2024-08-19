
/* 
-- =============================================
-- Author:      MKB			
-- Created:     Feb 2021 
-- Description:	importing the settlement data FROM clearer accounting-reports
-- Last Update: Dec 2021
-- =============================================
*/

CREATE PROCEDURE [dbo].[Import_Clearer_SettlementData] 
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
	
	SELECT @proc =Object_Name(@@PROCID)
	SELECT @ClearerType ='Settlement'
	SELECT @SourcePath = 'ClearerCSV'+@ClearerToImport
	SELECT @FileSource = 'Clearer'+@ClearerType+@ClearerToImport

	SELECT @logheader = 'Clearer - Import Settlement Data for ' + @ClearerToImport

	SELECT  @Step = 10
	/* Get the COB date if not set manually by a parameter */
		IF @COBString = ''
			SELECT @COB = cast(asofdate_eom as date) FROM dbo.asofdate as cob
		ELSE
			SELECT @COB = cast(@COBString as date)
		
	--/*identify ClearerID*/
	SELECT @step=20
	SELECT @ClearerID = ClearerID FROM dbo.table_Clearer WHERE ClearerName=@ClearerToImport
		
  --/* get Info if Logging is enabled */
	SELECT @LogInfo = [dbo].[LogInfo].[LogInfo] FROM [dbo].[LogInfo]
  
	/*nasdaq data gets imported already directly via database link!*/
	IF @ClearerToImport ='Nasdaq' 
	BEGIN 
		IF @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] SELECT @logheader + ' must only be done by databaselink', GETDATE () END
		GOTO NoFurtherAction 
	END

	--/*make related log entries*/
	IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @logheader + ' and COB ' + convert(varchar, @COB, 23) + ' - START', GETDATE () END
  IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @logheader + ' - delete old data', GETDATE () END
	
	
		--/*drop and recreate temp table for data import*/
	SELECT @step=30
	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE  TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'table_Clearer_SettlementData_temp'))
	--BEGIN TRUNCATE TABLE dbo.table_Clearer_SettlementData_temp END

	DROP TABLE dbo.table_Clearer_SettlementData_temp 
	
	SELECT  @Step = 40
	CREATE TABLE dbo.table_Clearer_SettlementData_temp(
	 	 SettlementDate nvarchar(100) NULL
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
		,SettlementPrice float NULL
		,RealizedPNL float NULL
		,CCY nvarchar(100) NULL
	) ON [PRIMARY]
	
	
	--/*delete potential previously loaded data for this clearer + type FROM final table*/
	SELECT @step=50
	DELETE FROM dbo.table_Clearer_AccountingData WHERE ClearerType = @ClearerType AND clearerID = @ClearerID 
	
  IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @logheader + ' - identify and load import files', GETDATE () END

		
	--/*identify importpath (same for all files of same type for one clearer )*/
	SELECT @step=60
	SELECT @PathName = [dbo].[udf_get_path_custom_asofdate](@SourcePath,@COBString)      
	--SELECT @PathName --> display to check status

	--/*use a counter as there might be files of same type for one clearer!*/
	SELECT @step=70
	SELECT @counter = count(1) FROM [dbo].[FilestoImport] WHERE  [dbo].[FilestoImport].[Source] like @FileSource and ToBeImported=1

		--/*in case here is no importfile, create a reladed log entry*/
	IF @counter=0 
	BEGIN 
		INSERT INTO [dbo].[Logfile] SELECT @logheader + ' - no data found to get imported.', GETDATE () 
		GOTO NoFurtherAction 
	END		

	--SELECT @counter --> display to check status

/*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx*/
---   ACHTUNG
---		Nasdaq hat drei verschiedene input Datentabellen !!
---		da müssen wir einenanderen Ansatz wählen!!!
/* xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx*/

	 
	--/*loop over counter, reduce it at then end*/ 
	SELECT @step=80
	IF @counter>0
	BEGIN		
		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @logheader + ' - import from ' + @pathname, GETDATE () END			
	END

	WHILE @counter > 0		 
		BEGIN		  			
			/*identify importfile*/
		 SELECT @step=@step+1
		  SELECT @FileName = [FileName]
			FROM (SELECT *, ROW_NUMBER() OVER(ORDER BY ID) AS ROW  
            FROM [dbo].[FilestoImport] 
            WHERE [dbo].[FilestoImport].[Source] like @FileSource and ToBeImported=1) as TMP 
		 WHERE ROW = @counter
												
			/*import data into temp table*/						
			SELECT @step=@step+1  					 	  			
			SELECT @filename = [dbo].[udf_Resolve_Date_Placeholder_custom_asofdate](@filename,@COBString) 
			 
			--/*display to check status*/			
			--Select 'check: ' + @PathName as 'ImportPath', @FileName as 'ImportFile'
			
			IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @logheader + ' - import from ' + @filename, GETDATE () END			
			--TRUNCATE TABLE [dbo].[table_Clearer_SettlementData_Temp]
			SELECT @sql = N'BULK INSERT [dbo].[table_Clearer_Settlementdata_Temp] FROM '  + '''' + @pathname + @filename + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR ='','', FIRSTROW = 2, ROWTERMINATOR =''\n'')';
			EXECUTE sp_executesql @sql		

		 	/*reduce counter*/
			SELECT @counter = @counter - 1
		END

	--	/*now that all files have been imported into temp table, move the complete data in one go into final table*/
		SELECT @step=90
		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @logheader + ' - fill destination table', GETDATE () END			
	  INSERT INTO [dbo].[table_Clearer_AccountingData]
    (  [CoB]
			,[DealNumber]
			,[AccountName]
			,[InternalPortfolio]
			,[ContractName]
			,[ContractDate]
			,[ProductName]
			,[SettlementDate]
			,[ExerciseDate]
			,[DeliveryDate]
			,[ProjectionIndex1]
			,[ProjectionIndex2]
			,[Toolset]
			,[Position]
			,[TradePrice]
			,[SettlementPrice]
			,[RealisedPnL]
			,[CCY]
			,[ClearerID]
			,[ClearerType]
		)    
		SELECT 
		    @COB as COB
			,DealNumber
			,AccountName
			,rtrim(ltrim(InternalPortfolio))
			,ContractName			
			,CONVERT(date,ContractDate,103) as ContractDate
			,NULL as ProductName
			,CONVERT(date,SettlementDate, 103) as SettlementDate
			,NULL as ExerciseDate
			,NULL as DeliveryDate
			,ProjectionIndex1
			,ProjectionIndex2
			,Toolset
			,cast(Position as float)as position
			,cast(TradePrice as float) as tradeprice 
			,cast(SettlementPrice as float) as settlementprice
			,cast(RealizedPNL as float) as realisedpnl
			,rtrim(ltrim(replace(CCY,',',''))) as CCY			 
			,@ClearerID as clearerID
			,@ClearerType as clearerType
		FROM [dbo].[table_Clearer_SettlementData_Temp]
	
		--/*now document the last successful import timestamp */
		SELECT @step=99
		update [dbo].[FilestoImport] set LastImport = getdate() WHERE [Source] like @FileSource 

--------------------------------------------------------------------------------------------------------------------------------------------------------
--Settlement_Part Data (only for BNPPAP)
	If @ClearerID = 2 
	BEGIN

		/*drop and recreate temp table for data import*/
		SELECT @step=101
		IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE  TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'table_Clearer_Settlement_Part_Data_temp'))
		DROP TABLE dbo.table_Clearer_Settlement_Part_Data_temp 
	
		SELECT  @Step = 102

		CREATE TABLE [dbo].[table_Clearer_Settlement_Part_Data_Temp](
			[Report Day] [nvarchar](50) NULL,
			[Account] [nvarchar](50) NULL,
			[Original Trade Day] [nvarchar](50) NULL,
			[Contract] [nvarchar](max) NULL,
			[Contract Date] [nvarchar](50) NULL,
			[Internal Trade Id] [nvarchar](50) NULL,
			[Original Deal No] [nvarchar](50) NULL,
			[Projection Index 1] [nvarchar](50) NULL,
			[Projection Index 2] [nvarchar](50) NULL,
			[Toolset] [nvarchar](50) NULL,
			[Closeout Deal No] [nvarchar](50) NULL,
			[Position Closed Today] [decimal](18, 0) NULL,
			[Total Original Position] [numeric](18, 2) NULL,
			[Original Trade Price] [numeric](18, 2) NULL,
			[Closing Trade Price] [numeric](18, 2) NULL,
			[Flat] [nvarchar](50) NULL,
			[PnL] [numeric](18, 2) NULL,
			[Portfolio] [nvarchar](max) NULL,
			[CCY] [nvarchar](50) NULL,
		) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

		Set @FileSource = 'ClearerSettlementPartBNPPAP'
		Set @counter = 1
		SELECT @step=103
			SELECT @FileName = [FileName]
				FROM (SELECT *, ROW_NUMBER() OVER(ORDER BY ID) AS ROW  
				FROM [dbo].[FilestoImport] 
				WHERE [dbo].[FilestoImport].[Source] like @FileSource and ToBeImported=1) as TMP 
			WHERE ROW = @counter
													
				/*import data into temp table*/						
				SELECT @step=104  					 	  			
				SELECT @filename = [dbo].[udf_Resolve_Date_Placeholder_custom_asofdate](@filename,@COBString) 
				
				/*display to check status*/			
				Select 'check: ' + @PathName as 'ImportPath', @FileName as 'ImportFile'
				
				IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @logheader + ' - import from ' + @filename, GETDATE () END			
				TRUNCATE TABLE [dbo].[table_Clearer_SettlementData_Temp]
				SELECT @sql = N'BULK INSERT [dbo].[table_Clearer_Settlement_Part_Data_Temp] FROM '  + '''' + @pathname + @filename + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR ='','', FIRSTROW = 2, ROWTERMINATOR =''\n'')';
				EXECUTE sp_executesql @sql

		SELECT @step=105
			IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @logheader + ' - fill destination table', GETDATE () END			
		INSERT INTO [dbo].[table_Clearer_AccountingData]
		(  [CoB]
				,[DealNumber]
				,[AccountName]
				,[InternalPortfolio]
				,[ContractName]
				,[ContractDate]
				,[ProductName]
				,[SettlementDate]
				,[ExerciseDate]
				,[DeliveryDate]
				,[ProjectionIndex1]
				,[ProjectionIndex2]
				,[Toolset]
				,[Position]
				,[TradePrice]
				,[SettlementPrice]
				,[RealisedPnL]
				,[CCY]
				,[ClearerID]
				,[ClearerType]
			)    
			SELECT 
				@COB as COB
				,[Original Deal No] as DealNumber
				,[Account] as AccountName
				,Portfolio as InternalPortfolio
				,[Contract] as ContractName			
				,CONVERT(date,[Contract Date],103) as ContractDate			--Report Day oder Original Trade Day?
				,NULL as ProductName
				,CONVERT(date,[Report Day], 103) as SettlementDate	--Report Day oder Original Trade Day?
				,NULL as ExerciseDate
				,NULL as DeliveryDate
				,[Projection Index 1] as ProjectionIndex1
				,[Projection Index 2] as ProjectionIndex2
				,[Toolset] as Toolset
				,cast([Total Original Position] as float)as position
				,cast([Original Trade Price] as float) as tradeprice 
				,cast([Closing Trade Price] as float) as settlementprice			-- ist das richtig so?
				,cast(PnL as float) as realisedpnl
				,[CCY] as CCY			 
				,@ClearerID as clearerID
				,@ClearerType as clearerType
			FROM [dbo].[table_Clearer_Settlement_Part_Data_Temp]
		
			/*now document the last successful import timestamp */
			SELECT @step=106
			update [dbo].[FilestoImport] set LastImport = getdate() WHERE [Source] like @FileSource 
	END

NoFurtherAction:  
		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @logheader + ' - FINISHED', GETDATE () END
	END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
		BEGIN INSERT INTO [dbo].[Logfile] SELECT @logheader + ' - FAILED', GETDATE () END
	END CATCH

GO

