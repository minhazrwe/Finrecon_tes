



/*==========================================================================================
 Author:      MKB/MU			
 Created:     May 2021 
 Description:	importing all the required NASDAQ related data from BocarX
---------------------
changelog:
2022-09-05,	step 10,				MU:			inserted vairables for begin and end of month of asofdate
2022-09-05,	step 120,				MU:			Replaced Delete by Truncate due to Complain by Yvonne that old data remains in the AccountSummary table.
2023-06-14,	step 160 + 170,	mkb:		inserted
2023-06-14,	overall,				mkb:		refurbished log entries and step counting
==========================================================================================*/

CREATE PROCEDURE [dbo].[Import_Clearer_BocarX_Nasdaq_Data] 		
AS
	BEGIN TRY

		DECLARE @step Integer		
		
		DECLARE @proc nvarchar(50)
		DECLARE @LogInfo Integer
		
		DECLARE @sql nvarchar (max)
		DECLARE @LogHeader varchar(100)

		DECLARE @ClearerToImport nvarchar(30) 		
		DECLARE @ClearerID Integer	
		DECLARE @ClearerType as nvarchar(30)
	
		DECLARE @COB as DATE
		DECLARE @BeginOfMonth as DATE
		DECLARE @EndOfMonth as DATE
		
		/*initialisation tasks*/
		SELECT @Step = 0
		SELECT @proc = Object_Name(@@PROCID)
					
		SELECT @Step = 10
		SELECT @COB = cast(asofdate_eom as date) FROM dbo.asofdate as COB									/* current AsofDAte */
		SELECT @BeginOfMonth = cast(DATEFROMPARTS(YEAR(@cob), MONTH(@cob), 1) as date);		/*	related begin of month */
		SELECT @EndOfMonth = eomonth(@cob);																								/*	related end of month */
		
		/* check, if logging is globally enabled */
		SELECT @LogInfo = [dbo].[LogInfo].[LogInfo] FROM [dbo].[LogInfo]
  
	 	/*as the clearer is given , so we identify the related id (just in case it might have changed) */
		SELECT @Step = 20
		SELECT @ClearerToImport ='Nasdaq'
		SELECT @ClearerID = ClearerID FROM dbo.table_Clearer WHERE ClearerName=@ClearerToImport
		
		SELECT @ClearerType = 'Trades'		/*needed in table "table_Clearer_DealData", as it might be, that we store data from other reports there as well. */
		
		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - START', GETDATE () END
								
		/* nasdaq settled deals */ 
		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + '- load settled deals from BocarX', GETDATE () END
		
		SELECT @Step = 30
		TRUNCATE TABLE dbo.table_clearer_bocarx_nasdaq_settled_deals

		SELECT @Step = 40				
		INSERT INTO dbo.table_clearer_bocarx_nasdaq_settled_deals
			SELECT
				cast(report_day as date) as Settlement_Date
				,cast(deal_number as varchar) as deal_number
				,cast(product_name as varchar) as [Contract]
				,cast(Contract_Date as date) as Contract_Date
				,cast(Projection_Index as varchar) as "Projection Index 1"
				,cast(internal_portfolio as varchar) as Portfolio
				,cast(Toolset as varchar) as Toolset 
				,cast(Position as float) as position
				,cast(trade_price as float) as trade_price 
				,cast(statement_price as float) as Settlement_Price
				,cast(endur_pnl as float) as Realized_PnL
				,cast("CCY" as varchar) as CCY
			FROM
					BOCAR_1P.BOCAR1P.bocarx.trade_settlement_view
			WHERE
					report_name like 'Nasdaq'
					and report_day between @BeginOfMonth and @COB /* alternative: @EndOfMonth, could not test yet what happens when monthend is not on a normal workday*/
					and product_name not like 'ENOM' /*ENOM sind die letzten noch verbliebenen forwards, alles andere sind futures*/
			ORDER BY 
				report_day

		/* nasdaq realised EUR (Settlements)*/ 		
		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + '- load realised data from BocarX', GETDATE () END
		
		SELECT @Step=50
		TRUNCATE TABLE dbo.table_clearer_bocarx_nasdaq_realised_data
		
		/* query might return nothing, in case there are no settlements*/
		SELECT @Step=60		
		INSERT INTO dbo.table_clearer_bocarx_nasdaq_realised_data		
		SELECT
			 cast(trade_date as date) as report_date
			,cast([contract] as Varchar) as ProductName
			,cast(quantity as float) as Position
			,cast(total_settlement_positions as float) as realised_pnl
			,cast(delivery_date as date) as DeliveryDate 
		FROM 
			BOCAR_1P.BOCAR1P.bocar.bocar_stm_nasdaq_settle_position
		WHERE 
			trade_date between @BeginOfMonth and @COB
			and filesource = 'Contracts In Delivery' 
		ORDER BY 
			trade_date, 
			delivery_date

		/* nasdaq settled deals (options)*/ 			 
		--SELECT @Step=80
		--IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + '- load settled deals (options)', GETDATE () END

		/*can be ignored, as we haven't got some since years. in cas there are any again, an according query needs to be defined.
				required fields would be 
				report_day (date)
				DealNumber (varchar)
				ProductName (varchar)
				ExerciseDate (date)
				PremiumSettlement (float)
		*/

		/* nasdaq manual adjustments*/ 		
		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + '-  load manual adjustments from BocarX', GETDATE () END
		
		SELECT @Step=100 
		TRUNCATE TABLE dbo.table_clearer_bocarx_nasdaq_manual_adjustments
		
		/*
		ACHTUNG!!!
		filtering on "adjaccount.name like 'NC RWE HOUSE'" in the next query will NOT return the expected values.
		we would have to additionally filter on "and adjreport.name like 'Nasdaq'" to get what we aim for.
		As since 06/2022 back office added two additional accounts for Nasdaq, it makes more sense to just filter for the report name, to not miss any adjustments.		
		*/
		SELECT @Step=110 
		INSERT INTO dbo.table_Clearer_BocarX_Nasdaq_Manual_Adjustments
        (Trade_Date
          ,Adjustment_Value
          ,Adjustment_Type
          ,Adjustment_Category
          ,Account_Name
          ,Adjustment_Comment
				)
				SELECT
					cast(adj.report_date as date) as Trade_Date   
					,cast(adj.Value as float) as Adjustment_Value   
					,null as Adjustment_Type /* gibt es in Zukunft so detailliert nicht mehr*/       
					,cast(adjcat.name as varchar) as Adjustment_Category   
					,cast(adjaccount.name as varchar) as Account_Name
					,cast(adj.Commentary  as varchar) as Adjustment_Comment     
				FROM
					BOCAR_1P.BOCAR1P.bocarx.manual_adjustments as adj
					inner join BOCAR_1P.BOCAR1P.bocarx.manual_adjustment_categories as adjcat on adj.manual_adjustment_category_id = adjcat.id
					inner join BOCAR_1P.BOCAR1P.bocarx.accounts as adjaccount on adj.account_id = adjaccount.id
					inner join BOCAR_1P.BOCAR1P.bocarx.report_definitions as adjreport on adj.report_definition_id = adjreport.id
					inner join BOCAR_1P.BOCAR1P.bocarx.currencies as adjccy on adj.currency_id = adjccy.id   
				WHERE
					cast(report_date as date) between @BeginOfMonth and @COB
					--and adjaccount.name like 'NC RWE HOUSE'
					and adjreport.name like 'Nasdaq'
				ORDER BY 
					report_date   

		/* nasdaq account_summary*/ 			 		
		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + '- load account summary data from BocarX', GETDATE () END
		
		
		SELECT @Step=120 
		TRUNCATE TABLE dbo.table_Clearer_BocarX_Nasdaq_Accountsummary
		
		SELECT @Step=130 
		INSERT INTO dbo.table_Clearer_BocarX_Nasdaq_Accountsummary
           (Trade_Date
           ,Total_Sum_Of_Day
           ,Settlement
           ,Variation_Margin
           ,Premium_Settlement
           ,Trade_Fees
           ,Bank_Balance
           ,Unrealised_FWD_Pnl
           ,Unrealised_FUT_Pnl
           ,Realised_Pnl
           ,Total_Margin_Requirement
           ,Custody_Bank_Balance
           ,Surplus_Deficit
	   )
		SELECT 
				cast(report_day as date) as Trade_Date	
				,CAST(total_cash_settlement as float) as Total_Sum_Of_Day
				,CAST(settlement as float) as Settlement
				,CAST(variation_margin as float) as Variation_Margin							
				,CAST(premium_settlement as float) as Premium_Settlement 
				,CAST(fees as float) as Trade_Fees 
				,CAST(bank_balance as float) as Bank_Balance											
				,CAST(unrealised_forward_Pnl as float) as Unrealised_FWD_Pnl
				,CAST(unrealised_future_Pnl as float) as Unrealised_FUT_Pnl
				,CAST(realised_pnl as float) as Realised_Pnl														
				,cast(Total_Margin_Requirement as float) as Total_Margin_Requirement
				,CAST(Custody_Bank_Balance as float) as Custody_Bank_Balance
				,CAST(Surplus_Deficit as float) as Surplus_Deficit
			FROM 
				BOCAR_1P.BOCAR1P.bocarx.accounting_report_nasdaq_account_summary_view
			WHERE 
				report_day between @BeginOfMonth and @COB
			ORDER BY
				report_day   


		/*nasdaq dealreport data*/		
		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + '- load deal report data from BocarX', GETDATE () END
		
		/* delete old data*/
		SELECT @STEP =140
		DELETE FROM [dbo].[table_Clearer_DealData] where clearerID = @ClearerID and ClearerType = @ClearerType

		/* load new data (global table)*/		
		SELECT @STEP =150
		INSERT INTO [dbo].[table_Clearer_DealData]
    (
			 [ReportDate]
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
      --,[ProjectionIndex2] /* here not used/needed */
      ,[Toolset]
      ,[Position]
      ,[CCY]
      ,[TradePrice]
      ,[StrikePrice]
      ,[Premium]
      ,[CallPut]
      ---,[FeeType] /* here not used / needed */
      ,[FeeRate]
      ,[TotalFee]
      --,[AdjustedTotalFee] /* here not used / needed */
      ,[ClearerID]
      ,[ClearerType]
		)
    SELECT 
			 cast(report_day as date ) as report_date
			,cast(cast(deal_number as int) as varchar) as deal_number
			,cast(account_name as varchar) as account_name
			,cast(internal_portfolio as varchar) as internal_portfolio
			,cast(external_business_unit as varchar) as  external_business_unit
			,cast(product_name as varchar) as ContractName 
			,cast(contract_size as float) as ContractSize
			,cast(broker as varchar) as brokerName 
			,cast(trade_date as date) as TradeDate 
			,cast(contract_start_date as date) as StartDate  
			,cast(contract_end_date as date) as EndDate  			
			,cast(projection_index1 as varchar) as projection_index1 
			,cast(toolset as varchar) as toolset 
			,cast("position" as float) as position
			,cast("CCY" as varchar) as CCY 
			,cast(trade_price as float) as TradePrice
			,cast(strike_price as float) as StrikePrice
			,cast(premium as float) as premium
			,cast(callput as varchar) as callput  
			,cast(total_fee_rate as float) as FeeRate
			,cast(total_fee as float) as TotalFee
			,@clearerID AS clearerID
			,@ClearerType as clearertype
	FROM 
		BOCAR_1P.BOCAR1P.bocarx.trade_check_endur_deals
	WHERE 
		report_name like 'Nasdaq'
		and report_day between @BeginOfMonth and @cob

		
		SELECT @STEP =160
		truncate table [dbo].[table_Clearer_DealData_Nasdaq]
		
		SELECT @STEP =170
		INSERT INTO [dbo].[table_Clearer_DealData_Nasdaq]
    (
			 [Report_Date]
      ,[Deal_Number]
      ,[account_name]
      ,[internal_portfolio]
      ,[External_Business_Unit]
      ,[ContractName]
      ,[ContractSize]
      ,[BrokerName]
      ,[TradeDate]
      ,[StartDate]
      ,[EndDate]
      ,[Projection_Index1]
      ,[Toolset]
      ,[Position]
      ,[CCY]
      ,[TradePrice]
      ,[StrikePrice]
      ,[Premium]
      ,[CallPut]
      ,[FeeRate]
      ,[TotalFee]
      ,[ClearerID]
      ,[ClearerType]
		)
    SELECT 
			 cast(report_day as date ) as report_date
			,cast(cast(deal_number as int) as varchar) as deal_number
			,cast(account_name as varchar) as account_name
			,cast(internal_portfolio as varchar) as internal_portfolio
			,cast(external_business_unit as varchar) as  external_business_unit
			,cast(product_name as varchar) as ContractName 
			,cast(contract_size as float) as ContractSize
			,cast(broker as varchar) as brokerName 
			,cast(trade_date as date) as TradeDate 
			,cast(contract_start_date as date) as StartDate  
			,cast(contract_end_date as date) as EndDate  			
			,cast(projection_index1 as varchar) as projection_index1 
			,cast(toolset as varchar) as toolset 
			,cast("position" as float) as position
			,cast("CCY" as varchar) as CCY 
			,cast(trade_price as float) as TradePrice
			,cast(strike_price as float) as StrikePrice
			,cast(premium as float) as premium
			,cast(callput as varchar) as callput  
			,cast(total_fee_rate as float) as FeeRate
			,cast(total_fee as float) as TotalFee
			,@clearerID AS clearerID
			,@ClearerType as clearertype
	FROM 
		BOCAR_1P.BOCAR1P.bocarx.trade_check_endur_deals
	WHERE 
		report_name like 'Nasdaq'
		and report_day between @BeginOfMonth and @cob


		/*NoFurtherAction, so tell the world we're done.*/
		SELECT @STEP =200
		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + '- FINISHED', GETDATE () END
	END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
		BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + '- FAILED', GETDATE () END
	END CATCH

GO

