
/* 
=====================================================================================================================================
 Author:      mkb			
 Created:     2024-03
 Description:	importing data from BocarX (common) views into finrecon, this includes:
							> TRADES &  OPTION_PREMIUM
							> SETTLEMENTS 
							> MANUAL ADJUSTTMENTS
							> CURRENCY SUMMARY
							> BOM_DEALS (team not implemented in the beginning, planned for a later stage, got ok from exchange team)
 
As of 2024-03 not all clearer data is imported via this way as it's not completely available in BocarX. 
It will start with BNP-RWETA, followed by BNP-JP and BNP-AP
=====================================================================================================================================
Changes:
when, who, where, what (why):
2024-05-02, mkb, steps 20-28, deactivated separate import for option premium, as it looks like the data for option_premium comes already with the trade_data
2024-05-12, PMG, steps 210-240, added steps to pcopy data directly into tables for bim_creation as well to support automated BIM generation
2024-06-18, mkb, steps 220+230, modified filter conditions so that data gets correctly transferred into BIM-realted table (not keeping any old data)
2024-07-04. PG, step 20-28, activated OptionPremium and commented some code out (marked in the code); step 18: commented "External_BU" and "End_Date" out
2024-07-24, PG, step 260, Update TotalFee (has to be negative) (from positive to negative)
2024-08-15, PG, step 250, copy Options from DealData to AccountingData
=====================================================================================================================================*/


CREATE PROCEDURE [dbo].[Import_BocarX_Data_into_Finrecon] 
		 @Clearer_To_Import nvarchar(50) 					/* value needs to be a valid "ClearerName" from table dbo.clearer */		
AS
BEGIN TRY
	
		DECLARE @step Integer		
		DECLARE @Current_Procedure nvarchar(50)

		DECLARE @sql nvarchar (max)
		
		DECLARE @Clearer_ID Integer	
		DECLARE @Clearer_Long_Name as varchar(100)
	
		DECLARE @COB as date
		DECLARE @COB_MONTH_START as date
		DECLARE @COB_MONTH_END as date
		DECLARE @COB_PREV_MONTH as date
		DECLARE @COB_LAST_MONTH_END as date

		DECLARE @Record_Counter as int
		DECLARE @Warning_Counter as int 
		DECLARE @Calling_App as varchar(100)	 					
		DECLARE @Status_Text as varchar(100)	 					


		SELECT @Step = 1		
		SELECT @Current_Procedure = Object_Name(@@PROCID)
		
		SET @Calling_App = 'ClearerDB'			/*might get automized one far day*/
		EXEC dbo.Write_Log 'Info', 'START', @Current_Procedure, NULL, @Calling_App, @step, 1
					
		/*initialise variables*/
		SET @step = 2
		SET @Record_Counter = 0
		SET @Warning_Counter = 0 

		SELECT 
			 @COB = asofdate_eom									/* current AsofDate */
			,@COB_PREV_MONTH = AsOfDate_prevEOM		/* AsofDate previous EOM */
		FROM 
			dbo.AsOfDate		

		SELECT @COB_MONTH_START= DATEADD(month, DATEDIFF(month, 0, @COB), 0)	/* related begin of month */
		SELECT @COB_MONTH_END = eomonth(@cob);																/* related end of month */
		SELECT @COB_LAST_MONTH_END = eomonth(@COB_PREV_MONTH)										/* related end of last month */
		
		SET @step = 3
		/*clearer_name is given as import parameter, identify the related entries to know which records to import from BocarX*/
		SELECT 
			@Clearer_ID = ClearerID, 
			@Clearer_Long_Name=ClearerLongName
		FROM 
			dbo.table_Clearer 
		WHERE 
			ClearerLongName = @Clearer_To_Import

		SET @Status_Text = 'Importing data directly from BocarX for Clearer ' + @Clearer_Long_Name
		EXEC dbo.Write_Log 'Info',@Status_Text, @Current_Procedure, NULL, @Calling_App, @step, 1


		/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
		/*start with data for trades*/
		SET @step = 10
		EXEC dbo.Write_Log 'Info', 'Load raw data for trades', @Current_Procedure, NULL, @Calling_App, @step, 1
		DROP TABLE IF EXISTS dbo.table_bocarx_trade_check_endur_deals_raw

		/*transfer postgres data into local raw data table*/				
		SET @step = 12
		SELECT 
			 CAST(report_day as date) as Report_Date
			,CAST(account_name as varchar) as Account_Name
			,CAST(ccy as varchar) as CCY	
			,CAST(trade_date as date) as Trade_Date			
			,CAST(deal_no as varchar(500)) as Deal_Number
			,CAST([contract] as varchar) as [Contract_Name]
			,CAST([start_date] as date) as [Start_Date]
			,CAST(end_date as date) as End_Date
			,CAST(projection_index_1 as varchar) as Projection_Index_1
			,CAST(external_business_unit as varchar) as External_BU
			,CAST(internal_portfolio as varchar) as Internal_Portfolio
			,CAST(toolset as varchar) as Toolset
			,CAST(contract_size as float) as Contract_Size
			,CAST(position as float) as Position
			,CAST(trade_price as float) as Trade_Price
			,CAST(callput as varchar) as Call_Put
			,CAST(strike_price as float) as Strike_Price
			,CAST(premium as float) as Premium /*always "0" in Trades!?*/
			,CAST([broker] as varchar) as Broker_Name
			,CAST(fee_rate as float) as Fee_Rate
			,CAST(total_fee as float) as Total_Fee
			,CAST(report_name as varchar) as Report_Name			
		INTO 
			finrecon.dbo.table_Bocarx_Trade_Check_Endur_Deals_Raw
		FROM
			[BOCAR_1P].[BOCAR1P].[bocarx].[accounting_report_trade_check_endur_deals_view]
			---BOCAR1T.BOCAR1T.[bocarx].[accounting_report_trade_check_endur_deals_view]
		WHERE
			cast(report_name as varchar) in (@Clearer_Long_Name)	
			AND cast(report_day as date) between  @COB_MONTH_START and  @COB_MONTH_END
			
			

		/* check if any data has been loaded at all, if not skip next step but inform user by logentry.*/
		SET @step = 14
		SET @Record_Counter = 0
		SELECT @Record_Counter = COUNT(*) FROM finrecon.dbo.table_Bocarx_Trade_Check_Endur_Deals_Raw 

		IF @Record_Counter=0 
		BEGIN
			SET @Warning_Counter = @Warning_Counter + 1
			SET @Status_Text = 'No data for trades found. Warning Counter raised to ' + CAST(@Warning_Counter as varchar) 
			EXEC dbo.Write_Log 'WARNING', @Status_Text, @Current_Procedure, NULL, @Calling_App, @step, 1
			GOTO NextImportStep_OptionPremium
		END 

		SET @step = 15
		SET @Status_Text = 'Sucessfully loaded ' + CAST(@Record_Counter as varchar) + ' records.'
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, NULL, @Calling_App, @step, 1


		SET @step = 16
		EXEC dbo.Write_Log 'Info', 'Transfer final data for trades', @Current_Procedure, NULL, @Calling_App, @step, 1
		
		/*kill old data for trades and option_premium from final table*/
		DELETE FROM 
			dbo.table_BocarX_Trade_Check_Endur_Deals 
		WHERE 
			report_name = @Clearer_Long_Name
			AND report_date between  @COB_MONTH_START and  @COB_MONTH_END /*just delete the current data, but keep history */ 
			--AND report_date > @COB_PREV_MONTH												/*delete all data since prev_EOM*/			

		/*fill new data for trades and option_premium in final table*/
		SET @step = 18		
		INSERT INTO dbo.table_BocarX_Trade_Check_Endur_Deals									  
		(
       [Report_Date]
      ,[Account_Name]
      ,[CCY]
      ,[Trade_Date]
      ,[Deal_Number]
      ,[Contract_Name]
      ,[Start_Date]
     -- ,[End_Date]
      ,[Projection_Index_1]
      --,[External_BU]
      ,[Internal_Portfolio]
      ,[Toolset]
      ,[Contract_Size]
      ,[Position]
      ,[Trade_Price]
      ,[Call_Put]
      ,[Strike_Price]
	  ,[Premium]
	  ,[Broker_Name]     
      ,[Fee_Rate]
      ,[Total_Fee]
      ,[Report_Name]
      ,[Clearer_ID]
		)
		SELECT 			
      [Report_Date]
      ,[Account_Name]
      ,[CCY]
      ,[Trade_Date]
      ,[Deal_Number]
      ,[Contract_Name]
      ,[Start_Date]
      --,[End_Date]
      ,[Projection_Index_1]
     -- ,[External_BU]
      ,[Internal_Portfolio]
      ,[Toolset]
      ,[Contract_Size]
      ,[Position]
      ,[Trade_Price]
      ,[Call_Put]
      ,[Strike_Price]
      ,[Premium]
	  ,[Broker_Name]     
      ,[Fee_Rate]
      ,[Total_Fee]
      ,[Report_Name]
	  ,@Clearer_ID
		FROM 
			dbo.table_Bocarx_Trade_Check_Endur_Deals_Raw 

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/		
NextImportStep_OptionPremium:
/*mkb, 2024-05-02 deactivated as it looks like the data comes already with the trade_data*/
		--/*continue with data for option_premium*/
	/*	SET @step = 20
		EXEC dbo.Write_Log 'Info', 'Load raw data for option_premium', @Current_Procedure, NULL, @Calling_App, @step, 1
		DROP TABLE IF EXISTS dbo.table_bocarx_trade_check_endur_deals_raw

		/*transfer postgres data into local raw data table*/				
		SET @step = 22
		SELECT
			cast(report_name as varchar) as report_name
			,cast(report_day as date) as Report_Date
			,cast(trade_date as date) as Trade_Date
			,cast(account_name as varchar) as Account_Name
			,cast(deal_no as varchar(500)) as Deal_Number
			,cast([contract] as varchar)  as [Contract_Name]
			,cast([start_date] as date) as [Start_Date]									/* ACHTUNG CONTRACT_DATE NOT YET FILLED CORRECTLY !!! */
			,cast(projection_index_1 as varchar)  as Projection_Index_1
			,cast(internal_portfolio as varchar)  as Internal_Portfolio
			,cast(toolset as varchar)  as Toolset
			,cast(position as float) as Position
			,cast(trade_price as float) as Trade_Price
			,cast(strike_price as float) as Strike_Price
			,cast(premium as float) as Premium
			,cast(callput as varchar)  as Call_Put
			,cast(ccy as varchar) as CCY	
			,cast(contract_size  as float) as contract_size
			,cast([broker] as varchar) as Broker_Name
			,cast(fee_rate as float)as fee_rate
			,cast(total_fee as float) as Total_Fee
			--,CAST(report_name as varchar) as Report_Name												/* ACHTUNG Delivery_Type  NOT YET FILLED CORRECTLY !!! */
		INTO 
			finrecon.dbo.table_Bocarx_Trade_Check_Endur_Deals_Raw
		FROM
			[BOCAR_1P].[BOCAR1P].[bocarx].[accounting_report_trade_check_endur_deals_view]
		WHERE
			cast(report_name as varchar) in (@Clearer_Long_Name)	

			AND cast(report_day as date) between  @COB_MONTH_START and  @COB_MONTH_END
		/* check if any data has been loaded at all, if not skip next step but inform user by logentry.*/
		SET @step = 24
		SET @Record_Counter = 0
		SELECT @Record_Counter = COUNT(*) FROM finrecon.dbo.table_Bocarx_Trade_Check_Endur_Deals_Raw 

		IF @Record_Counter=0 
		BEGIN
			SET @Warning_Counter = @Warning_Counter + 1
			SET @Status_Text = 'No data for option_premium found. Warning Counter raised to ' + CAST(@Warning_Counter as varchar) 
			EXEC dbo.Write_Log 'WARNING', @Status_Text, @Current_Procedure, NULL, @Calling_App, @step, 1
			GOTO NextImportStep_Settlements
		END 

		SET @step = 26
		EXEC dbo.Write_Log 'Info', 'Transfer final data for option_premium', @Current_Procedure, NULL, @Calling_App, @step, 1
		
		/*kill old data for trades and option_premium from final table*/
		DELETE FROM 
			dbo.table_Bocarx_Trade_Check_Endur_Deals 
		WHERE 
			report_name = @Clearer_Long_Name
			AND report_date between  @COB_MONTH_START and  @COB_MONTH_END /*just delete the current data, but keep history */ 
			--AND report_date < @COB_LAST_MONTH_END												/*delete ALL old data*/			

		/*fill new data for trades and option_premium in final table*/
		SET @step = 28		
		INSERT INTO [dbo].table_Bocarx_Trade_Check_Endur_Deals
		(
			 [Report_Name]
			,[Report_Date]
			,[Trade_Date]
			,[Account_Name]
			,[Deal_Number]
			,[Contract_Name]
			,[Start_Date]	    ---edited from [Contract_Date] PG 04.07.2024
			,[Projection_Index_1]
			,[Internal_Portfolio]
			,[Toolset]
			,[Position]
			,[Trade_Price]
			,[Strike_Price]
			,[Premium]
			,[Call_Put]
			,[CCY]
			,[Contract_Size]
			,[Broker_Name]
			,[fee_rate]
			,[Total_Fee]
			,[Clearer_ID]
		)
		SELECT 			
			 [Report_Name]
			,[Report_Date]
      ,[Trade_Date]
      ,[Account_Name]
      ,[Deal_Number]
      ,[Contract_Name]
      ,[Start_Date]				---edited from [Contract_Date] PG 04.07.2024
      ,[Projection_Index_1]
      ,[Internal_Portfolio]
      ,[Toolset]
      ,[Position]
      ,[Trade_Price]
      ,[Strike_Price]
      ,[Premium]
      ,[Call_Put]
      ,[CCY]
      ,[Contract_Size]
      ,[Broker_Name]
      ,[fee_rate]
      ,[Total_Fee]
			,@Clearer_ID
		FROM 
			dbo.table_Bocarx_Trade_Check_Endur_Deals_Raw 
			*/

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/		
NextImportStep_Settlements:

		/*continue with data for settlements*/
		SET @step = 30
		EXEC dbo.Write_Log 'Info', 'Load raw data for settlements', @Current_Procedure, NULL, @Calling_App, @step, 1
		
		DROP TABLE IF EXISTS dbo.table_Bocarx_Trade_Settlement_Raw

		/*transfer postgres data into local raw data table*/				
		SET @step = 32
		SELECT
			 CAST(report_day as date) as Report_Date
			,CAST(Settlement_Date as date) as Settlement_Date				
			,CAST(account_name as varchar) as Account_name
			,CAST(deal_number as int) as Deal_number
			,CAST([contract] as varchar) as Contract_Name
			,CAST(contract_date as date) as Contract_Date
			,CAST(projection_index as varchar) as Projection_Index_1
			,CAST(Settlement_Date as date) as Trade_Date /* "settlement_date and trade_date are the same", (C.Zuckermann 2024-05-02)*/
			,CAST(toolset as varchar) as Toolset
			,CAST(position as float) as Position
			,CAST(trade_price as float) as Trade_Price
			,CAST(statement_price	as float) as Settlement_Price
			,CAST(endur_pnl as float) as Realised_PnL
			,CAST(internal_portfolio as varchar) as Internal_Portfolio
			,CAST(ccy as varchar) as CCY
			,CAST(NULL as varchar) as Buy_Sell						/* "nice to have column" (AA, 2024-05-02), currently not being implemented, just there in case once needed*/
			,CAST(report_name as varchar) as Report_Name
		INTO 
			finrecon.dbo.table_Bocarx_Trade_Settlement_Raw
		FROM
			[BOCAR_1P].[BOCAR1P].[bocarx].[accounting_report_trade_settlement_view]		
		WHERE 
			cast(report_name as varchar) in (@Clearer_Long_Name)
			AND cast(report_day as date) between  @COB_MONTH_START and  @COB_MONTH_END 
			
	/* check if any data has been loaded at all, if not skip next step but inform user by logentry.*/
		SET @step = 34
		SET @Record_Counter = 0
		SELECT @Record_Counter = COUNT(*) FROM finrecon.dbo.table_Bocarx_Trade_Settlement_Raw 

		IF @Record_Counter=0 
		BEGIN
			SET @Warning_Counter = @Warning_Counter + 1
			set @Status_Text = 'No data for settlements found. Warning Counter raised to ' + CAST(@Warning_Counter as varchar) 
			EXEC dbo.Write_Log 'WARNING', @Status_Text, @Current_Procedure, NULL, @Calling_App, @step, 1

			GOTO NextImportStep_ManualAdjustments
		END 

		SET @step = 36
		EXEC dbo.Write_Log 'Info', 'Transfer final data for trades and option_premium', @Current_Procedure, NULL, @Calling_App, @step, 1
		
		/*kill old data for settlements from final table*/
		DELETE FROM 
			dbo.table_Bocarx_Trade_Settlement 
		WHERE 
			report_name = @Clearer_Long_Name
			--AND report_date between  @COB_MONTH_START and  @COB_MONTH_END /*just delete the current data, but keep history */ 

		/*fill new data for trades and option_premium in final table*/
		SET @step = 38
		INSERT INTO dbo.table_Bocarx_Trade_Settlement
    (
			 Report_Name
			,Report_Date
			,Settlement_Date
			,Account_name
			,Deal_Number
			,[Contract_Name]
			,Contract_Date
			,Projection_Index_1
			,Toolset
			,Position
			,Trade_Price
			,Settlement_Price
			,Realised_PnL
			,Internal_Portfolio
			,CCY
			,Buy_Sell
			,Clearer_ID
		)
		SELECT 
			 Report_Name
			,Report_Date
			,Settlement_Date
			,Account_name
			,Deal_Number
			,[Contract_Name]
			,Contract_Date
			,Projection_Index_1
			,Toolset
			,Position
			,Trade_Price
			,Settlement_Price
			,Realised_PNL
			,Internal_Portfolio
			,CCY
			,Buy_Sell
			,@Clearer_ID
		FROM 
			dbo.table_Bocarx_Trade_Settlement_Raw
			
/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/		
NextImportStep_ManualAdjustments:

	/*continue with data for manual adjustments*/
		SET @step = 40
		EXEC dbo.Write_Log 'Info', 'Load manual adjustments', @Current_Procedure, NULL, @Calling_App, @step, 1
		
		DROP TABLE IF EXISTS dbo.table_Bocarx_Manual_Adjustments_Raw

		/*transfer postgres data into local raw data table*/				
		SET @step = 42
		SELECT
			 CAST(report_date as date) as Report_Date
			,CAST(NULL as date) as Trade_Date
			,CAST([value] as float) as Adjustment_Value
			,CAST(manual_adjustment_category as varchar) as Adjustment_Type
			,CAST(account_name as varchar) as Account_Name
			,CAST(commentary as varchar) as Adjustment_Comment
			,CAST(ccy as varchar) as CCY
			,CAST(report_name as varchar) as Report_Name
		INTO  				
			finrecon.dbo.table_BocarX_Manual_Adjustments_Raw
		FROM
			[BOCAR_1P].[BOCAR1P].[bocarx].[accounting_manual_adjustments_view]		
		WHERE 
			cast(report_name as varchar) in (@Clearer_Long_Name)
			AND cast(report_date as date) between  @COB_MONTH_START and  @COB_MONTH_END 



		/* check if any data has been loaded at all, if not skip next step but inform user by logentry.*/
		SET @step = 44
		SET @Record_Counter = 0
		SELECT @Record_Counter = COUNT(*) FROM finrecon.dbo.table_Bocarx_Manual_Adjustments_Raw 

		IF @Record_Counter=0 
		BEGIN
			SET @Warning_Counter = @Warning_Counter + 1
			set @Status_Text = 'No manual adjustments found. Warning Counter raised to ' + CAST(@Warning_Counter as varchar) 
			EXEC dbo.Write_Log 'WARNING', @Status_Text, @Current_Procedure, NULL, @Calling_App, @step, 1			
			GOTO NextImportStep_CurrencySummary
		END

		SET @step = 46
		EXEC dbo.Write_Log 'Info', 'Transfer manual adjustments to final table ', @Current_Procedure, NULL, @Calling_App, @step, 1
		
		/*kill old manual adjustments from final table*/
		DELETE FROM 
			dbo.table_Bocarx_Manual_Adjustments 
		WHERE 
			report_name = @Clearer_Long_Name
			--AND report_date between  @COB_MONTH_START and  @COB_MONTH_END /*just delete the current data, but keep history */ 
			

		/*fill new manual adjustments in final table*/
		SET @step = 48	
		INSERT INTO dbo.table_Bocarx_Manual_Adjustments
		(
      Report_Date
      ,Trade_Date
      ,Adjustment_Value
      ,Adjustment_Type
      ,Account_Name
      ,Adjustment_Comment
      ,CCY
      ,Report_Name
      ,Clearer_ID
 		)	
		SELECT
      Report_Date
      ,Trade_Date
      ,Adjustment_Value
      ,Adjustment_Type
      ,Account_Name
      ,Adjustment_Comment
      ,CCY
      ,Report_Name
			,@Clearer_ID
		FROM 
			finrecon.dbo.table_Bocarx_Manual_Adjustments_Raw
	
/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/		
NextImportStep_CurrencySummary:
	
	/*continue with data for currency summary*/

		SET @step = 50
		/*FROM HERE ON WE NEED TO DISTINGUISH THE CLEARER (BNPP, Mizuho, ...) as BO is not able to deliver everything in ONE View.
	So we start with BNPP, any other clearer has to be implemented later, as the data structure is not known yet....)	*/

	/*BNPP and all related accounts*/
		IF @Clearer_To_Import like '%BNP%'
		BEGIN
			/*continue with currency summary*/
			SET @step = 52
			EXEC dbo.Write_Log 'Info', 'Load raw data for BNPP currency summary', @Current_Procedure, NULL, @Calling_App, @step, 1
		
			DROP TABLE IF EXISTS dbo.table_Bocarx_BNPP_Currency_Summary_Raw

			/*transfer postgres data into local raw data table*/				
			SET @step = 54
			SELECT
			 CAST(report_date as date) as Report_Date
			,CAST(opening_balance as float) as Opening_Balance
			,CAST(margin_funds_transfer as float) as Margin_Funds_Transfer
			,CAST(comission_and_fees as float) as Commission_And_Fees
			,CAST(interests as float) as Interests
			,CAST(option_premium as float) as Option_Premium
			,CAST(realized_pnl as float) as Realised_PNL
			,CAST(closing_balance as float) as Closing_Balance
			,CAST(variation_margin as float) as Variation_Margin
			,CAST(net_option_value as float) as Net_Option_Value
			,CAST(initial_margin as float) as Initial_Margin
			,CAST(intercommodity_credit as float) as Intercommodity_Credit
			,CAST(special_delivery_margin as float) as Special_Delivery_Margin
			,CAST(collateral_used as float) as Collateral_Used
			,CAST(letter_of_credit as float) as Letter_Of_Credit
			,CAST(excess_and_deficit as float) as Excess_And_Deficit
			,CAST(commentary as varchar) as Summary_Comment
			,CAST(security_interest_check as float) as Security_Interest_Check
			,CAST(NULL as float) as Net_Invoice																		/*not yet available but needed*/
			,CAST(NULL as float) as Invoiced_VAT																	/*not yet available but needed*/
			,CAST(ccy as varchar) as CCY
			,CAST(account as varchar) as Account_Name
			,CAST(report_name as varchar) as Report_Name
			INTO  
				finrecon.dbo.table_Bocarx_BNPP_Currency_Summary_Raw
			FROM
				[BOCAR_1P].[BOCAR1P].[bocarx].[accounting_report_bnpp_currency_summary_view]		
			WHERE 
				cast(report_name as varchar) in (@Clearer_Long_Name)
				--AND cast(report_date as date) between  @COB_MONTH_START and  @COB_MONTH_END 
				AND cast(report_date as date) between  @COB_PREV_MONTH and  @COB_MONTH_END


			/* check if any data has been loaded at all, if not skip next step but inform user by logentry.*/
			SET @step = 56
			SET @Record_Counter = 0
			SELECT @Record_Counter = COUNT(*) FROM finrecon.dbo.table_Bocarx_BNPP_Currency_Summary_Raw 

			IF @Record_Counter=0 
			BEGIN
				SET @Warning_Counter = @Warning_Counter + 1
				SET @Status_Text = 'No data for data for BNPP currency summary found. Warning Counter = ' + CAST(@Warning_Counter as varchar) 
				EXEC dbo.Write_Log 'WARNING', @Status_Text, @Current_Procedure, NULL, @Calling_App, @step, 1
				GOTO NextImportStep_AccountSummary
			END 

			SET @step = 58
			EXEC dbo.Write_Log 'Info', 'Transfer BNPP currency summary to final table ', @Current_Procedure, NULL, @Calling_App, @step, 1
		
			/*kill old manual adjustments from final table*/
			DELETE FROM 
				dbo.table_Bocarx_BNPP_Currency_Summary 
			WHERE 
				report_name = @Clearer_Long_Name
				
								
			/*fill data for BNPP currency summary into final table*/
			SET @step = 60	
			INSERT INTO [dbo].[table_Bocarx_BNPP_Currency_Summary]
			(
      Report_Date
      ,Opening_Balance
      ,Margin_Funds_Transfer
      ,Commission_And_Fees
      ,Interests
      ,Option_Premium
      ,Realised_PNL
      ,Closing_Balance
      ,Variation_Margin
      ,Net_Option_Value
      ,Initial_Margin
      ,Intercommodity_Credit
      ,Special_Delivery_Margin
      ,Collateral_Used
      ,Letter_Of_Credit
      ,Excess_And_Deficit
      ,Summary_Comment
      ,Security_Interest_Check
      ,Net_Invoice
      ,Invoiced_VAT
      ,CCY
      ,Account_Name
      ,Report_Name
			,Clearer_ID
			)
			SELECT 
				 Report_Date
				,Opening_Balance
				,Margin_Funds_Transfer
				,Commission_And_Fees
				,Interests
				,Option_Premium
				,Realised_PNL
				,Closing_Balance
				,Variation_Margin
				,Net_Option_Value
				,Initial_Margin
				,Intercommodity_Credit
				,Special_Delivery_Margin
				,Collateral_Used
				,Letter_Of_Credit
				,round(Excess_And_Deficit,2)
				,Summary_Comment
				,Security_Interest_Check
				,Net_Invoice
				,Invoiced_VAT
				,CCY
				,Account_Name
				,Report_Name
				,@Clearer_ID
			FROM 
				dbo.table_Bocarx_BNPP_Currency_Summary_Raw

	END /* of --> IF @Clearer_To_Import like '%BNP%'  */
	
	/*next clearer to be implemented here*/

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/		
NextImportStep_AccountSummary:
	/*continue with data for currency summary*/
		SET @step = 100
		EXEC dbo.Write_Log 'Info', 'Load data for account summaries.', @Current_Procedure, NULL, @Calling_App, @step, 1
		
	/*FROM HERE ON WE NEED TO DISTINGUISH THE CLEARER (BNPP, Mizuho, ...) as BO is not able to deliver everything in ONE View.*/
	IF @Clearer_To_Import like '%BNP%'
	BEGIN 
		SET @step = 101
		EXEC dbo.Write_Log 'Info', 'Skipped account summary (BNPP), as not yet required.', @Current_Procedure, NULL, @Calling_App, @step, 1
	END /* of --> IF @Clearer_To_Import like '%BNPP%'  */
	
	
/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/		
NextImportStep_BOMDeals:
	/*continue with data for BOM_Deals*/
		SET @step = 200
		EXEC dbo.Write_Log 'Info', 'Load data for BOM_deals.', @Current_Procedure, NULL, @Calling_App, @step, 1
		
	/*FROM HERE ON WE NEED TO DISTINGUISH THE CLEARER (BNPP, Mizuho, ...) as BO is not able to deliver everything in ONE View.*/
	
	IF @Clearer_To_Import like '%BNP%'	
	BEGIN 
		SET @step = 201
		EXEC dbo.Write_Log 'Info', 'Skipped BOM_deals (BNP), as not yet required.', @Current_Procedure, NULL, @Calling_App, @step, 1
	END /* of --> IF @Clearer_To_Import like '%BNP%'  */
		

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/	
NextImportantStep_ImportIntoClearerTable:
-- This step copies the data into the table_Clearer_AccountingData and table_Clearer_DealData

	
	SET @step = 210
	SET @Status_Text ='Prepare BIM - deal data'
	EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, NULL, @Calling_App, @step, 1
		
	/*kill old data from final table*/
	DELETE FROM 
		dbo.table_Clearer_DealData
	WHERE 
		ClearerID = @Clearer_ID
						
	SET @step = 220
	/*fill data for BNPP currency summary into final table*/
	INSERT INTO dbo.table_Clearer_DealData (
    ReportDate,
    DealNumber,
    AccountName,
    InternalPortfolio,
    ExternalBusinessUnit,
    ContractName,
    ContractSize,
    BrokerName,
    TradeDate,
    StartDate,
    EndDate,
    ProjectionIndex1,
	  Toolset,
    Position,
    CCY,
    TradePrice,
    StrikePrice,
    Premium,
    CallPut,
    FeeRate,
    TotalFee,
    ClearerID,
		ClearerType,
    [Source]
	)
	SELECT
		Report_Date AS ReportDate,
		Deal_Number,
		Account_Name AS AccountName,
		Internal_Portfolio AS InternalPortfolio,
		External_BU AS ExternalBusinessUnit,
		[Contract_Name] AS ContractName,
		Contract_Size AS ContractSize,
		Broker_Name AS BrokerName,
		Trade_Date AS TradeDate,
		[Start_Date] AS StartDate,
		End_Date AS EndDate,
		Projection_Index_1 as ProjectionIndex1,
		Toolset,
		Position,
		CCY,
		Trade_Price AS TradePrice,
		Strike_Price AS StrikePrice,
		Premium,
		Call_Put AS CallPut, 
		Fee_Rate AS FeeRate,
		Total_Fee AS TotalFee,
		@Clearer_ID AS ClearerID, 
		'Trades' AS	ClearerType,
		'BocarX' AS [Source] 
	FROM 
		dbo.table_BocarX_Trade_Check_Endur_Deals
	WHERE Clearer_ID = @Clearer_ID 
			
	SET @step = 230
	SET @Status_Text ='Prepare BIM - accounting data'
	EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, NULL, @Calling_App, @step, 1

	DELETE FROM 
		table_Clearer_AccountingData
	WHERE 
		ClearerID = @Clearer_ID	
			
	SET @step = 240
	INSERT INTO table_Clearer_AccountingData 
	(
		 CoB
    ,DealNumber
    ,AccountName
    ,InternalPortfolio
    ,ContractName
    ,ContractDate
    ,SettlementDate
    ,ProjectionIndex1
    ,Toolset
    ,Position
    ,TradePrice
    ,SettlementPrice
    ,RealisedPnL
    ,CCY
    ,ClearerID
    ,ClearerType
	)
	SELECT 
		 @COB AS CoB
	   ,Deal_number AS DealNumber
	   ,Account_name AS AccountName
	   ,Internal_Portfolio AS InternalPortfolio
	   ,[Contract_Name] AS ContractName
	   ,Contract_Date AS ContractDate
	   ,Settlement_Date AS SettlementDate
	   ,Projection_Index_1 AS ProjectionIndex1
	   ,Toolset
	   ,Position
	   ,Trade_Price AS TradePrice
	   ,Settlement_Price AS SettlementPrice
	   ,Realised_PnL AS RealisedPnL
	   ,CCY
	   ,Clearer_ID AS ClearerID
	   ,'Settlement' AS ClearerType
	FROM 
		FinRecon.dbo.table_Bocarx_Trade_Settlement
	WHERE 
		Clearer_ID = @Clearer_ID 

--- Options from DealData to AccountingData		Added by PG 15/08/2024
	SET @step = 250
	SET @Status_Text ='Prepare BIM - accounting data - options'
	EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, NULL, @Calling_App, @step, 1
	INSERT INTO table_Clearer_AccountingData 
	(
		 CoB											
    ,DealNumber											
    ,AccountName										
    ,InternalPortfolio									
    ,ContractName										
    ,ContractDate										
    ,SettlementDate										
    ,ProjectionIndex1									
    ,Toolset											
    ,Position											
    ,TradePrice											
    ,SettlementPrice									
    ,RealisedPnL										
    ,CCY												
    ,ClearerID											
    ,ClearerType										
	)
		SELECT
		 @COB AS CoB,									
		Deal_Number as DealNumber,						
		Account_Name AS AccountName,					
		Internal_Portfolio AS InternalPortfolio,		
		[Contract_Name] AS ContractName,				
		[Start_Date] AS ContractDate,					
		Trade_Date AS SettlementDate,					
		Projection_Index_1 as ProjectionIndex1,			
		Toolset,										
		Position,										
		Trade_Price AS TradePrice,						
		NULL AS SettlementPrice,				
		Premium as RealisedPnL,							
		CCY,											
		@Clearer_ID AS ClearerID, 
		'Options from DealData' AS	ClearerType
	FROM 
		dbo.table_BocarX_Trade_Check_Endur_Deals
	WHERE 
		Clearer_ID = @Clearer_ID  
	AND	Toolset LIKE '%OPT%'
--- END Options from DealData to AccountingData		Added by PG 15/08/2024 


--Update TotalFee (has to be negative) by PG 24/07/2024
	SET @step = 260
	SET @Status_Text ='Prepare BIM - Update TotalFee'
	EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, NULL, @Calling_App, @step, 1
	UPDATE dbo.table_Clearer_DealData
	SET TotalFee = -TotalFee
	WHERE TotalFee > 0 AND ClearerID = @Clearer_ID AND source = 'BocarX'


/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/	
			
		/*NoFurtherAction, so tell the world we're done, but inform about potential warnings.*/
		SELECT @step = 300
		SET @Status_Text = 'FINISHED'
		IF @Warning_Counter = 0
			BEGIN
					EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, NULL, @Calling_App, @step, 1 
			END
		ELSE
			BEGIN
				SET @Status_Text = @Status_Text + ' WITH ' + cast(@Warning_Counter as varchar) +  ' WARNINGS! - check log for details!'
				EXEC dbo.Write_Log 'WARNING', @Status_Text, @Current_Procedure, NULL, @Calling_App, @step, 1 
			END
		Return 0
END TRY

BEGIN CATCH
	/*tell the world procedure failed*/
	EXEC [dbo].[usp_GetErrorInfo] @Current_Procedure, @step, NULL; 
	EXEC dbo.Write_Log 'FAILED', 'FAILED with error, check log for details', @Current_Procedure, NULL, @Calling_App, @step, 1;
	Return @step
END CATCH

GO

