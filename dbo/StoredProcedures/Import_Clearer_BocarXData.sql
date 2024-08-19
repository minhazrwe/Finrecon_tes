

/* 
-- ==========================================================================================
-- Author:      MKB			
-- Created:     FEB 2021 
-- Description:	importing the settlement data FROM clearer accounting-reports
--==========================================================================================
-- Updates: 
todo (may21) (all per clearer, special view on nasdaq as partially different setup)
import 
-  account summary data 
- daily options --> by info from BO: can be ignored for nasdaq, as we do not have some since years
- manual adjustments
- settled deals 
- settlements
- trades
-- ==========================================================================================
--Changes, 
--when, who, where, what (why):

-- ==========================================================================================
*/


CREATE PROCEDURE [dbo].[Import_Clearer_BocarXData] 
		@ClearerToImport nvarchar(20) 		/*--welche kann es geben ? --> die aus der table_clearer*/

AS
	BEGIN TRY

		DECLARE @step Integer		
		
		DECLARE @proc nvarchar(50)
		DECLARE @LogInfo Integer
		
		DECLARE @sql nvarchar (max)
		DECLARE @LogHeader varchar(100)

		DECLARE @ClearerID Integer	
	
		DECLARE @COB as DATE
		DECLARE @BOM as DATE
		DECLARE @EOM as DATE
		DECLARE @INCOMPLETEBOCAR AS INTEGER
		
		SELECT @proc = Object_Name(@@PROCID)
		SELECT @LogHeader = 'Clearer - Import BocarX Data for ' + @ClearerToImport + ' - '

		SELECT  @Step = 1
	
		/*get the current ASOfDate formatted as pure date (without time) as we need it later several times*/
		SELECT @COB = cast(asofdate_eom as date) FROM dbo.asofdate as COB  /* current AsofDAte */
		SELECT @BOM = cast(DATEFROMPARTS(YEAR(@cob), MONTH(@cob), 1) as date);					 /*	related begin of month */
		SELECT @EOM = eomonth(@cob);					 /*	related begin of month */
		

		/* check, if logging is globally enabled */
		SELECT @LogInfo = [dbo].[LogInfo].[LogInfo] FROM [dbo].[LogInfo]
  
		/*the clearer is given as import parameter, so we will identify the related accounts to know wjich records to import from BOCARx*/
		SELECT @step=@step+1  
		SELECT @ClearerID = ClearerID FROM dbo.table_Clearer WHERE ClearerName=@ClearerToImport
	
		/* make related log entries*/
		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @LogHeader + 'START', GETDATE () END

	
		/*truncate temp table in postgresformat for data import*/
		SELECT @step=@step+1  
		TRUNCATE TABLE dbo.table_Clearer_BocarX_Data_temp

		/*delete potential previously loaded data for this clearer from final BocarX table*/
		DELETE FROM dbo.table_Clearer_BocarX_Fees WHERE clearerID = @ClearerID 
										
		
		SELECT @step=@step+1  	
		/*import original bocar data into "postgres-like"-temp-table*/						
		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @LogHeader + 'query BocarX data', GETDATE () END

		INSERT INTO dbo.table_Clearer_BocarX_Data_temp
		SELECT 
			report_name
			,report_day
			,account_name
			,CCY
			,trade_date
			,deal_number
			,product_name
			,contract_start_date
			,contract_end_date
			,projection_index1
			,external_business_unit
			,internal_portfolio
			,toolset
			,contract_size
			,position
			,trade_price
			,callput
			,strike_price
			,premium
			,broker
			,total_fee_rate
			,total_fee
			,@clearerID
		FROM 
			[BOCAR_1P].[BOCAR1P].[bocarx].[trade_check_endur_deals]
		WHERE 
			report_day between @BOM and @COB
			AND cast(account_name as varchar) in (Select distinct AccountName from dbo.table_Clearer_map_ExternalBusinessUnit where ClearerID=@ClearerID)

		/*identify incomplete records in bocar and store them in extra table*/
		SELECT @step=@step+1  					 	  							
		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @LogHeader + 'Identify incomplete Bocar raw data', GETDATE () END

		IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' and TABLE_NAME = 'table_Clearer_IncompleteBocarData'))
		BEGIN		
			drop table dbo.table_Clearer_IncompleteBocarData
		END

		SELECT 
			bocarx.*			
		INTO 
			dbo.table_Clearer_IncompleteBocarData
		FROM 
			[BOCAR_1P].[BOCAR1P].[bocarx].[trade_check_endur_deals] as bocarx		
		WHERE 
			report_day between @BOM and @COB			
			and len(cast(account_name as varchar))<1

		select @INCOMPLETEBOCAR = count(*) FROM dbo.table_Clearer_IncompleteBocarData
			
		if @INCOMPLETEBOCAR>0 
		BEGIN
			IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @LogHeader + 'WARNING!!! - ' + cast(@INCOMPLETEBOCAR as varchar) + ' incomplete records found in BOCAR raw data:', GETDATE () END
		END

		
		SELECT @step=@step+1  	
		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @LogHeader + 'transfer data into FinRecon', GETDATE () END
		--transfer-statement with cast/converts into the finrecon-table (gefiltert).
		INSERT INTO [dbo].[table_Clearer_BocarX_Fees]
      ([ReportDate]
      ,[AccountName]
      ,[CurrencyFees]
      ,[TradeDate]
      ,[DealNumber]
      ,[ContractName]
      ,[StartDate]
      ,[EndDate]
      ,[ProjectionIndex1]
      ,[ProjectionIndex2]
      ,[ExternalBusinessUnit]
      ,[InternalPortfolio]
      ,[Toolset]
      ,[ContractSize]
      ,[Position]
      ,[TradePrice]
      ,[CallPut]
      ,[StrikePrice]
      ,[Premium]
      ,[Broker]
      ,[FeeRate]
      ,[TotalFee]
      ,[ClearerID]
      ,[LastImport])
			SELECT 
				 cast([report_day] as date)
				,cast([account_name] as varchar)
				,cast([CCY] as varchar)
				,cast([trade_date] as date)
				,cast([deal_number] as varchar)
				,cast([product_name] as varchar) as productname
				,cast([contract_start_date] as date) as startdate
				,cast([contract_end_date] as date) as enddate
				,cast([projection_index1] as varchar)
				,NULL as ProjectionIndex2
				,cast([external_business_unit] as varchar)
				,cast([internal_portfolio] as varchar)
				,cast([toolset] as varchar)
				,cast([contract_size] as float)
				,cast([position]  as float)
				,cast([trade_price] as float)
				,cast([callput] as varchar)
				,cast([strike_price] as float)
				,cast([premium] as float)
				,cast([broker] as varchar)
				,cast([total_fee_rate] as float)
				,cast([total_fee] as float)
				,cast([clearer_ID] as int)
				,getdate() as LastImport
			FROM 
				[dbo].[table_Clearer_BocarX_Data_temp]
			WHERE
				clearer_ID = @ClearerID				
				---AND account_name in (Select distinct AccountName from dbo.table_Clearer_map_ExternalBusinessUnit where ClearerID = @ClearerID)
			
		/*NoFurtherAction, so tell the world we're done.*/
		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @LogHeader + 'FINISHED', GETDATE () END
	END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
		BEGIN INSERT INTO [dbo].[Logfile] SELECT @LogHeader + 'FAILED', GETDATE () END
	END CATCH

GO

