
/* 
====================================================================================================================================================
	Context:			PART OF THE NEW UNREALISED APPROACH AFTER FT EXIT
	Author:				mkb
	Created:			2024/05
	Description:	A) apply all required rules, filters, mappings, etc. to imported unrealised data 
								B) afterwards transfer data into table_unrealised_02 
								C) create and fill table_unrealised_eom (replacement for former "_eom")
------------------------------------------------------------------------------------------
change history: when, who, step, what, (why)
	2024-05-00, mkb,	all, initial setup of procedure 
	2024-06-20, mkb,	all, spedified most of the required mappings/enrichments
	2024-06-26, su,		101, added Strolf part for deletion flag
	2024-07-03, mkb,	204, added mapping for counterparty_group
	2024-07-04, mkb,	206-210, added mapping for accounting_treatment
	2024-07-12, mkb,	204, removed trade_date separation from counterparty_group check on intradesk and corrected entry in LE mapping
	2024-07-16, mkb,	122, implemented mapping: Commodity_Type
	2024-07-17, mkb,	124, implemented mapping: Cashflow_Type
										240, modified mapping to consider selected accounting_treatments and changed returned values 
										242, implemented mapping: Balance_Sheet_Account and PNL_OCI_Account
										301, considered new fields Commodity_Type, Balance_Sheet_Account and PNL_OCI_Account in transfer from 02_intermediate > 02
  2024-07-17, su		216, changed logic for ST/ LT Parameter and added DataSource field to Intermediate_02
	2024-07-22, su,		216, changed logic for Accounting_Delivery_Month and ST/LT. Split UPDATE from one into two
	2024-07-31, mkb,	114, added new fields 
										200, adapted metric names
										202, added "RevRec_SubDesk" to be mapped
										250+252, added steps								
	2024-08-01, mkb,	3, introduced "AsOfDate_FT_Replacement" as additional COB option
	2024-08-04, mkb,	204, added filter do set interdesk_old only for hedging affected desks (email april, 25/07/2024)
	2024-08-07, mkb,	142, added exception for defining ADM for instype "GAS-FUT-AVG-EXCH-P"
	2024-08-08, mkb,	all, updated step numbers to have a proper order
	2024-08-08, mkb,	added additional metrics for BU and CF CCY
	2024-08-13, mkb, 80-86, implemented refill of table_unrealised_eom
====================================================================================================================================================
*/

CREATE PROCEDURE [dbo].[AnalyseData_Unrealised] 
AS
BEGIN TRY
	
		DECLARE @step Integer		
		DECLARE @Current_Procedure nvarchar(50)

		DECLARE @sql nvarchar (max)
	
		DECLARE @COB as date
		DECLARE @COB_MONTH_START as date
		DECLARE @COB_MONTH_END as date
		DECLARE @COB_PREV_MONTH as date
		DECLARE @COB_LAST_MONTH_END as date

		DECLARE @Record_Counter as int
		DECLARE @Warning_Counter as int 
		DECLARE @Main_Process as varchar(100)	 					
		DECLARE @Calling_App as varchar(100)	 					
		DECLARE @Status_Text as varchar(500)	
		DECLARE @DataSource_Strolf as varchar(20)
		DECLARE @DataSource_Rock as varchar(20)
		DECLARE @DataSource_Adj as varchar(20)
		
		SET @Step = 1		
		SET @Current_Procedure = Object_Name(@@PROCID)
		SET @DataSource_Strolf = 'STROLF'
		SET @DataSource_Rock = 'ROCK'
		SET @DataSource_Adj = 'ADJUSTMENT'
		SET @Main_Process ='TESTRUN UNREASLISED'
		SET @Calling_App = ''							
		
		EXEC dbo.Write_Log 'Info', 'START', @Current_Procedure, @Main_Process, @Calling_App, @step, 1

		/* DESCRIPTION OF THE WRITELOG-FUNCTIONALITY 
		@Log_Level									--> Mandatory: Info, Warning, Error
		@Description								--> Mandatory: Logentry
		@Current_Procedure = NULL		-->	The actual procedure/function creating the log entry (e.g. VBA Function, Stored Procedure etc.)
		@Calling_App = NULL				  --> The overarching process (e.g. Realised Recon, SAP Update, Overnight etc.)
		@Calling_Application = NULL --> Name of the calling application (e.g. Name of MS Access Application, Sql Server Manager)
		@Step = NULL								--> Step value in which the logentry occurs - new proc => 100 Steps / Insert a new step 10 steps
		@Log_Info = 1								--> 1: Write in Log | 0: Do not write in Log
		@Session_Key = NULL					--> Provided by calling application (e.g. so that it can identifiy errors)
		*/
		
		/*initiate misc. variables*/
		SET @step = 2
		SET @Record_Counter = 0
		SET @Warning_Counter = 0 
				
		/*initiate date variables*/
		SET @step = 3		
		SELECT 
			 --@COB = asofdate_eom								/* current AsofDate */
			 @COB = AsOfDate_FT_Replacement				/* alternative testing COB*/
			,@COB_PREV_MONTH = AsOfDate_prevEOM		/* AsofDate previous month */
		FROM 
			dbo.AsOfDate		
		
		SELECT @COB_MONTH_END = eomonth(@cob)												/* monthend of @COB (=current month's EOM) */
		SELECT @COB_LAST_MONTH_END = eomonth(@COB_PREV_MONTH)				/* monthend of previous month's EOM */
		SELECT @COB_MONTH_START= DATEADD(day,1,@COB_LAST_MONTH_END)	/* month start of @COB (=current month's EOM)*/

		SET @Step =	10
		SET @Status_Text= 'Set deletion flags' 	
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, @Main_Process, @Calling_App, @step, 1 
			
	
		SET @Step = 12
		SET @Status_Text= 'Set deletion flags: STROLF' 	
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, @Main_Process, @Calling_App, @step, 1 
		/* mark STROLF Deals for deletion */
		UPDATE	dbo.table_unrealised_01 SET		
			ToBeDeleted = 1
			,Accounting_Comment ='Desk excluded by default'
		WHERE 
				DataSource = @DataSource_Strolf 
				AND Desk_Name NOT IN ('CS_CFD_MM_CE','CS_CFD_MM_UK','CS_CFD_SF','CS_SPM_DUMMY','CS_SPM_LT'
													,'CS_SPM_ST','CS_SPM_TPB_BENE','CS_SPM_TPB_DE','CS_STRATEGIC'
													,'SCHED_BENE','SCHED_DE')

		
		SET @Step = 14
		SET @Status_Text= 'Set deletion flags: ROCK' 	
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, @Main_Process, @Calling_App, @step, 1 
		/* mark ROCK Deals for deletion */

		/*	at current data for the instypes GAS-FUT-AVG-EXCH-P+F will get deleted after dump-import 
				and is reloaded from a separate report file ("Fin_MtM_GAS-FUT-AVG-EXCH_All_desks.txt", ID 3122).
			 
			 this report considers the following rules: 
			 1) InsTypes in (GAS-FUT-AVG-EXCH-P,InsTypes GAS-FUT-AVG-EXCH-F)
			 2) Intermediate1_Name not like '%non-reporting%'  (ROCK attribute from BUH) 
			 3) cashflow_end_date > COB
			 4) cashflow_type in (None, Settlement, Premium, FX Forward)
			 5) desk_name not in (CAO CE)

			 Action --> check if this is still needed in future. 			 
			 Answer from April Xin --> shes has no clue why this report is setup, 
			 Solution --> We will ignore the approach and check which consequences it might have for deals with the two instypes
		*/
			 
		
		SET @Step = 16		
		SET @Status_Text= 'Set deletion flags: ADJUSTMENTS' 	
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, @Main_Process, @Calling_App, @step, 1 
		/* mark adjustments for deletion */
		UPDATE	dbo.table_unrealised_01 SET		
			ToBeDeleted = 1
			,Accounting_Comment ='Adj. Category excluded by definition of Dave Woodward in 08/2024.'
		WHERE 
		 Adjustment_Category in 
		 (
		 		'Cost of Cash'
				,'Working Capital Utilisation'
				,'Brokerage and Exchange Fees'
				,'Valuation Adjustments Credit'
				,'(Other) Business related Costs'
		 )
		 and Desk_Name in 
		 (
				'COAL AND FREIGHT DESK'
				,'EUROPEAN GAS DESK'
				,'GPM DESK'
				,'LNG DESK'
		 )

		
		SET @Step = 18
		SET @Status_Text= 'Set deletion flags done.' 	
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, @Main_Process, @Calling_App, @step, 1 
		


		SET @Step = 20
		SET @Status_Text= 'Start: data transfer from 01 > 02_intermediate.' 	
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, @Main_Process, @Calling_App, @step, 1 
	

		/* cleanup Table_Unrealised_02_Intermediate from old data */
		SET @Step = 22
		TRUNCATE TABLE DBO.Table_Unrealised_02_Intermediate
	

		/* transfer the data */
		SET @Step = 24
		INSERT INTO dbo.table_Unrealised_02_Intermediate 
		(
			COB
			,Deal_Number
			,Trade_Date
			,Term_Start
			,Term_End
			,Internal_Legal_Entity
			,Desk_Name
			,Desk_ID
			,Desk_CCY
			,SubDesk
			,Book_Name
			,Book_ID
			,Internal_Portfolio
			,Portfolio_ID
			,Instrument_Type
			,Unit_of_Measure
			,External_Legal_Entity
			,External_Business_Unit
			,External_Portfolio
			,Projection_Index_Name
			,Projection_Index_Group
			,Product_Name
			,Adjustment_ID
			,Cashflow_Payment_Date
			,LegEndDate
			,Delivery_Date
			,Delivery_Month
			,Trade_Price
			,Cashflow_Type
			,Cashflow_Type_ID
			,[Contract_Name]
			,Unit_Of_Account
			,ShortTerm_LongTerm
			,Accounting_Delivery_Month
			,Counterparty_Group
			,Order_Number
			,Partner_Code
			,Active_Period			
			,Buy_Sell
			,Orig_Month
			,Target_Month
			,Accounting_Treatment
			,Volume
			,Volume_Avaliable
			,Volume_Used
			,Hedge_ID
			,Hedge_Quote
			,Product_ticker
			,RACE_Position
			,Cashflow_CCY
			,Accounting_Comment	
			,Adjustment_Comment
			,Adjustment_Category
			,Unrealised_Discounted_BU_CCY
			,Realised_Discounted_BU_CCY
			,Unrealised_Discounted_CF_CCY
			,Realised_Discounted_CF_CCY
			,FileID
			,DataSource
		)
		SELECT 
			COB
			,Deal_Number
			,Trade_Date
			,Term_Start
			,Term_End
			,Internal_Legal_Entity
			,Desk_Name
			,Desk_ID
			,Desk_CCY
			,SubDesk
			,Book_Name
			,Book_ID
			,Internal_Portfolio
			,Portfolio_ID
			,Instrument_Type
			,Unit_of_Measure
			,External_Legal_Entity
			,External_Business_Unit
			,External_Portfolio
			,Projection_Index_Name
			,Projection_Index_Group
			,Product_Name
			,Adjustment_ID
			,Cashflow_Payment_Date
			,Leg_End_Date
			,Delivery_Date
			,Delivery_Month
			,Trade_Price
			,Cashflow_Type
			,Cashflow_Type_ID
			,[Contract_Name]
			,Unit_Of_Account
			,ShortTerm_LongTerm
			,Accounting_Delivery_Month
			,Counterparty_Group
			,Order_Number
			,Partner_Code
			,Active_Period
			,Buy_Sell
			,Orig_Month
			,Target_Month
			,Accounting_Treatment
			,Volume
			,Volume_Avaliable
			,Volume_Used
			,Hedge_ID
			,Hedge_Quote
			,Product_ticker
			,RACE_Position
			,Cashflow_CCY
			,Accounting_Comment	
			,Adjustment_Comment
			,Adjustment_Category
			,Unrealised_Discounted_BU_CCY
			,Realised_Discounted_BU_CCY
			,Unrealised_Discounted_Cashflow_CCY
			,Realised_Discounted_Cashflow_CCY
			,FileID
			,DataSource
		FROM 
			dbo.Table_Unrealised_01
		WHERE
			ToBeDeleted=0



		SET @Step = 26
		SELECT @Record_Counter = count(*) from dbo.Table_Unrealised_02_Intermediate
		SET @Status_Text= 'Finished: data tranfser from 01 > intermediate, ' + cast(format(@Record_Counter,'###,###')as varchar) + ' records transferred' 	
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, @Main_Process, @Calling_App, @step, 1 

		SET @Step = 26
		SET @Status_Text= 'Start: mapping and enrichments.'
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, @Main_Process, @Calling_App, @step, 1 
		
		SET @Step = 28
		SET @Status_Text= 'mapping: book_name and book_ID.'
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, @Main_Process, @Calling_App, @step, 1 

		update table_unrealised_02_intermediate SET 
			Book_Name = table_business_unit_hierarchy.BookName	
			,Book_ID = table_business_unit_hierarchy.Book_ID
		from 
			table_unrealised_02_intermediate left outer join table_business_unit_hierarchy 
			on table_unrealised_02_intermediate.Internal_Portfolio = table_business_unit_hierarchy.PortfolioName 
		where 
			book_name is null

			
		SET @Step = 30
		SET @Status_Text= 'mapping: Commodity_Type' 	
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, @Main_Process, @Calling_App, @step, 1 
		/**/
		UPDATE dbo.table_unrealised_02_Intermediate	
		SET 
			Commodity_Type = table_map_Instrument_Commodity.Commodity_Type 
		FROM 
			table_unrealised_02_intermediate left outer join table_map_Instrument_Commodity 
			on table_unrealised_02_intermediate.Instrument_Type=table_map_Instrument_Commodity.instrument_type



		SET @Step = 32
		SET @Status_Text= 'mapping: Cashflow_Type' 	
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, @Main_Process, @Calling_App, @step, 1 
		/*only strolf data is affected, as it does only deliver ID but not name*/
		/* set Cashflow_Type */
		UPDATE dbo.table_unrealised_02_Intermediate	
		SET 
			Cashflow_Type = Cashflow_Type_Name 
		FROM 
			table_unrealised_02_intermediate left outer join dbo.table_map_cashflow_type 
			on table_unrealised_02_intermediate.Cashflow_Type_ID=table_map_cashflow_type.Cashflow_Type_ID
		WHERE 
			Cashflow_Type is null  



		SET @Step = 34
		SET @Status_Text= 'enrichment: Term_End' 	
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, @Main_Process, @Calling_App, @step, 1 
		/* set the correct term_end */		
		UPDATE dbo.table_unrealised_02_Intermediate 
		SET 
			Term_End  = CASE WHEN CDM = 'CDM_FUT' THEN eomonth(Cashflow_Payment_Date) ELSE eomonth(LegEndDate) END 
		FROM 
			dbo.table_unrealised_02_Intermediate
			LEFT JOIN dbo.map_instype	ON dbo.table_unrealised_02_Intermediate.Instrument_Type = dbo.map_instype.InstrumentType
		WHERE 
				(CDM is null AND LegEndDate > COB)
				OR  
				(CDM is not null AND Cashflow_Payment_Date > COB)



		SET @Step = 36
		SET @Status_Text= 'enrichment: Unrealised_Discounted and related metrics' 
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, @Main_Process, @Calling_App, @step, 1 
		/* set the correct term_end and mtm_value for options and futures defined instypes*/		
		UPDATE dbo.table_unrealised_02_Intermediate
		SET 
			 Total_Discounted_BU_CCY = Unrealised_Discounted_BU_CCY + Realised_Discounted_BU_CCY
			,Total_Discounted_CF_CCY = Unrealised_Discounted_CF_CCY + Realised_Discounted_CF_CCY
			,Total_Accounting_Discounted_BU_CCY = isnull(Unrealised_Discounted_BU_CCY,0) + case when (CDM = 'CDM_OPT') OR (Instrument_Type = 'GAS-STOR-P') THEN 0 ELSE isnull(Realised_Discounted_BU_CCY,0) END 
			,Total_Accounting_Discounted_CF_CCY = isnull(Unrealised_Discounted_CF_CCY,0) + case when (CDM = 'CDM_OPT') OR (Instrument_Type = 'GAS-STOR-P') THEN 0 ELSE isnull(Realised_Discounted_CF_CCY,0) END 
		FROM 
			dbo.table_unrealised_02_Intermediate
				LEFT JOIN dbo.map_instype	ON dbo.table_unrealised_02_Intermediate.Instrument_Type = dbo.map_instype.InstrumentType

		SET @Step = 38
		SET @Status_Text= 'enrichment: FX calculation.' 
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, @Main_Process, @Calling_App, @step, 1 
		/* convert the Total_Accounting_Discounted_CF_CCY metric into EUR to get figures comparable to SAP-figures */
		UPDATE dbo.table_unrealised_02_Intermediate
		SET 
			Total_Accounting_Discounted_CF_CCY_SAP_EUR = round(Total_Accounting_Discounted_CF_CCY / FXRate.Rate,2)
			,FX_Rate_CF_CCY_EUR = FXRate.Rate
		FROM 
			dbo.table_unrealised_02_Intermediate inner join dbo.FXRate 
			on table_unrealised_02_Intermediate.Cashflow_CCY = FXRate.[Currency] 
			AND format(table_unrealised_02_Intermediate.Delivery_Month,'yyyy/MM')=format(FXRate.asofdate,'yyyy/MM')
				--table_unrealised_02_Intermediate.Delivery_Month = FXRate.DeliveryMonth
		WHERE 
			table_unrealised_02_Intermediate.Cashflow_CCY Not In ('EUR')

			

		SET @Step = 40 
		/* ACHTUNG ! 	
		although knowing, that we decrease correctness and data quality by this, 
		we do not use the original values we get directly from ROCK/ENDUR but update the data here with the potentially wrong ones from map_Order. 
		Main reason is to consider defined exceptions and values that do not stem from endur !!! */	
		SET @Status_Text= 'mapping: Desk, Desk_ID, SubDesk, OrderNo, int_LE, Desk_CCY, RevRec_SubDesk' 	
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, @Main_Process, @Calling_App, @step, 1 
		/*mappings coming from map_order*/
		UPDATE dbo.table_unrealised_02_Intermediate 
		SET 
			 Desk_Name = map_order.Desk											/*overwriting the received correcter value from ROCK*/
			,Subdesk= map_order.SubDesk
			,Desk_ID = table_Business_Unit_Hierarchy.Desk_ID
			,Order_Number = map_order.OrderNo								/*overwriting the received value from ROCK*/
			,Internal_Legal_Entity = map_order.LegalEntity	/*overwriting the received correcter value from ROCK*/
			,Desk_CCY = map_order.SubDeskCCY 								/*overwriting the received correcter value from ROCK*/
			,RevRec_SubDesk = map_order.RevRecSubDesk
		FROM 
			dbo.table_unrealised_02_Intermediate 
			LEFT JOIN dbo.map_order ON dbo.table_unrealised_02_Intermediate.Internal_Portfolio= map_order.Portfolio
			inner join table_Business_Unit_Hierarchy on map_order.Portfolio = table_Business_Unit_Hierarchy.PortfolioName 
		where table_unrealised_02_Intermediate.Desk_ID is null
		
		
		SET @Step = 42
		SET @Status_Text= 'The the answer to life, the universe and everything: see step.' 	
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, @Main_Process, @Calling_App, @step, 1 


		SET @Step = 44 
		/*Setting the counterparty_groups*/
		SET @Status_Text= 'mapping: counterparty_group' 	
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, @Main_Process, @Calling_App, @step, 1 
		
		UPDATE dbo.table_unrealised_02_Intermediate SET 
		Counterparty_Group = 	
/*1*/	case when table_unrealised_02_Intermediate.Desk_name = map_order_external.Desk	then 'Intradesk' else 
															
/*2*/			case when (( (Internal_Legal_Entity in ('RWEST UK','RWEST UK - PE') AND External_Legal_Entity in('RWEST UK','RWEST UK - PE') AND Desk_Name IN ('STRUCTURED ORIGINATION DESK', 'UK TRADING DESK','CAO UK') )
											OR (Internal_Legal_Entity in ('RWEST DE','RWEST DE - PE') AND External_Legal_Entity in('RWEST DE','RWEST DE - PE') AND Desk_Name IN ('STRUCTURED ORIGINATION DESK', 'CONTINENTAL TRADING DESK','CAO CE', 'COMMODITY SOLUTIONS'))
											OR (Internal_Legal_Entity in ('RWEST AP','RWEST AP - PE') AND External_Legal_Entity in('RWEST AP','RWEST AP - PE'))
										) AND Trade_Date >= cast('2024-01-01' as date)) 
							then 'Interdesk' 
							else 
/*3*/								case when (((Internal_Legal_Entity in ('RWEST UK','RWEST UK - PE') AND External_Legal_Entity in('RWEST UK','RWEST UK - PE') AND Desk_Name IN ('STRUCTURED ORIGINATION DESK', 'UK TRADING DESK','CAO UK'))
															OR (Internal_Legal_Entity in ('RWEST DE','RWEST DE - PE') AND External_Legal_Entity in('RWEST DE','RWEST DE - PE') AND Desk_Name IN ('STRUCTURED ORIGINATION DESK', 'CONTINENTAL TRADING DESK','CAO CE', 'COMMODITY SOLUTIONS'))
															OR (Internal_Legal_Entity in ('RWEST AP','RWEST AP - PE') AND External_Legal_Entity in('RWEST AP','RWEST AP - PE'))
														) 
														AND Trade_Date < cast('2024-01-01' as date)													
														AND desk_name in ('STRUCTURED ORIGINATION DESK','UK TRADING DESK','CAO UK','CONTINENTAL TRADING DESK'
															/*,'CAO CE', 'Commodity Solutions' (Enzo to confirm) */
														)
													) 
								then 'Interdesk_OLD' 
								else		
/*4*/									case when (((Internal_Legal_Entity in ('RWEST UK','RWEST UK - PE') AND External_Legal_Entity in('RWEST UK','RWEST UK - PE'))
																OR (Internal_Legal_Entity in ('RWEST DE','RWEST DE - PE') AND External_Legal_Entity in('RWEST DE','RWEST DE - PE'))
																OR (Internal_Legal_Entity in ('RWEST AP','RWEST AP - PE') AND External_Legal_Entity in('RWEST AP','RWEST AP - PE'))
															) AND Trade_Date >= cast('2024-01-01' as date)																
														) 
											 then 'Interdesk' 
											 else 
/*5*/													case when ((Internal_Legal_Entity in ('RWEST UK','RWEST UK - PE') AND External_Legal_Entity in ('RWEST DE','RWEST DE - PE')) 
																		OR (Internal_Legal_Entity in ('RWEST DE','RWEST DE - PE') AND External_Legal_Entity in ('RWEST UK','RWEST UK - PE'))) 
															then 'InterPE' 
/*6*//*6*/															else case when ctpygroup = 'Internal' then 'Internal' else 'External' end
/*5*/													END
/*4*/									END 
/*3*/								END
/*2*/				END 				
/*1*/		END  
		FROM 
			dbo.table_unrealised_02_Intermediate
			LEFT JOIN dbo.map_counterparty ON table_unrealised_02_Intermediate.External_Business_Unit = dbo.map_counterparty.ExtBunit
			LEFT JOIN dbo.map_order map_order_external ON table_unrealised_02_Intermediate.External_Portfolio = map_order_external.Portfolio	


		SET @Step = 46		
		SET @Status_Text= 'mapping: accounting_treatment, 3 mandatory + 2 optional.' 	
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, @Main_Process, @Calling_App, @step, 1 
		/*as we got 3 mandatory and 2 optional identifier, we need to do separate updates to consider all three options
		(a) all five identifiers are set, 
		(b1+b2) only four identifiers are set (two options!), 
		(c) just the three mandatory are set. 
		need to start with the biggest key, as otherwise the sort ones might include them already	*/
		
		/*mapping including all 5 key parameter element (3 mandatory, 2 optional) */
		UPDATE dbo.table_unrealised_02_Intermediate
			SET Accounting_Treatment = table_map_accounting_treatment.Accounting_Treatment
			FROM 
				table_unrealised_02_Intermediate
				inner join dbo.table_map_accounting_treatment
				on (
					table_unrealised_02_Intermediate.Internal_Portfolio			= table_map_accounting_treatment.Internal_Portfolio AND
					table_unrealised_02_Intermediate.Counterparty_Group			= table_map_accounting_treatment.Counterparty_Group AND
					table_unrealised_02_Intermediate.Instrument_Type				= table_map_accounting_treatment.Instrument_Type AND
					table_unrealised_02_Intermediate.Cashflow_Type					= table_map_accounting_treatment.Cashflow_Type AND
					table_unrealised_02_Intermediate.External_Business_Unit	= table_map_accounting_treatment.External_Business_Unit 
				)
				where 
						dbo.table_map_accounting_treatment.External_Business_Unit is not null
						AND dbo.table_map_accounting_treatment.Cashflow_Type is not null

		SET @Step = 48
		/*mapping including 4 key parameter element (3 mandatory, 1 optional Cashflow_Type) */
		SET @Status_Text= 'mapping: accounting_treatment, mandatory + optional (Cashflow_Type).' 	
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, @Main_Process, @Calling_App, @step, 1 
				
		UPDATE dbo.table_unrealised_02_Intermediate
			SET Accounting_Treatment =table_map_accounting_treatment.Accounting_Treatment
			FROM 
				table_unrealised_02_Intermediate
				inner join dbo.table_map_accounting_treatment
				ON (
					table_unrealised_02_Intermediate.Internal_Portfolio			= table_map_accounting_treatment.Internal_Portfolio AND
					table_unrealised_02_Intermediate.Counterparty_Group			= table_map_accounting_treatment.Counterparty_Group AND
					table_unrealised_02_Intermediate.Instrument_Type				= table_map_accounting_treatment.Instrument_Type AND
					table_unrealised_02_Intermediate.Cashflow_Type					= table_map_accounting_treatment.Cashflow_Type 
				)
			WHERE 
				dbo.table_map_accounting_treatment.External_Business_Unit is null
				AND dbo.table_map_accounting_treatment.Cashflow_Type is not null

		SET @Step = 50
		/*mapping including 4 key parameter element (3 mandatory, 1 optional External_Business_Unit) */
		SET @Status_Text= 'mapping: accounting_treatment, mandatory + optional (External Business Unit).' 	
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, @Main_Process, @Calling_App, @step, 1 
				
		UPDATE dbo.table_unrealised_02_Intermediate
			SET Accounting_Treatment =table_map_accounting_treatment.Accounting_Treatment
			FROM 
				table_unrealised_02_Intermediate
				inner join dbo.table_map_accounting_treatment
				ON (
					table_unrealised_02_Intermediate.Internal_Portfolio			= table_map_accounting_treatment.Internal_Portfolio AND
					table_unrealised_02_Intermediate.Counterparty_Group			= table_map_accounting_treatment.Counterparty_Group AND
					table_unrealised_02_Intermediate.Instrument_Type				= table_map_accounting_treatment.Instrument_Type AND
					table_unrealised_02_Intermediate.External_Business_Unit	= table_map_accounting_treatment.External_Business_Unit 
				)
			WHERE 
				dbo.table_map_accounting_treatment.External_Business_Unit is not null
				AND dbo.table_map_accounting_treatment.Cashflow_Type is null


		SET @Step = 52
		/*mapping including just mandatory key elements */
		SET @Status_Text= 'mapping: accounting_treatment, mandatory only.' 	
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, @Main_Process, @Calling_App, @step, 1 
				
		UPDATE dbo.table_unrealised_02_Intermediate
			SET Accounting_Treatment =table_map_accounting_treatment.Accounting_Treatment
			FROM 
				table_unrealised_02_Intermediate
				inner join dbo.table_map_accounting_treatment
				ON (
					table_unrealised_02_Intermediate.Internal_Portfolio			= table_map_accounting_treatment.Internal_Portfolio AND
					table_unrealised_02_Intermediate.Counterparty_Group			= table_map_accounting_treatment.Counterparty_Group AND
					table_unrealised_02_Intermediate.Instrument_Type				= table_map_accounting_treatment.Instrument_Type 			
				)
			WHERE 
				dbo.table_map_accounting_treatment.External_Business_Unit is null
				AND dbo.table_map_accounting_treatment.Cashflow_Type is null		
	

		SET @Step = 54		
		/*mappings coming from map_counterparty*/
		SET @Status_Text= 'mapping: partner_code.' 	
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, @Main_Process, @Calling_App, @step, 1 
				
		UPDATE dbo.table_unrealised_02_Intermediate /* tested OK, mkb 20/06*/
		SET 
			 Partner_Code = case when Partner_Code is null then map_counterparty.[Partner] else Partner_Code end
			 ,External_Legal_Entity = case when External_Legal_Entity is null then map_counterparty.ExtLegalEntity else External_Legal_Entity end /* would overwrites values we got from ROCK*/
			 ,Counterparty_Group = case when Counterparty_Group is null then map_counterparty.ctpygroup else Counterparty_Group end								/*would overwrite values set in previous steps above*/
		FROM 
			dbo.table_unrealised_02_Intermediate INNER JOIN dbo.map_counterparty 
			ON table_unrealised_02_Intermediate.External_Business_Unit = map_counterparty.ExtBunit
		

			
		SET @Step = 56 
		SET @Status_Text= 'mapping: ADM.' 	
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, @Main_Process, @Calling_App, @step, 1 
		/* ADM (Accounting_delivery_month): the bigger one of Term_end and Leg_End_Date */
		
		/*Special treatment of LNG-OPT-PUT-P and LNG-SWOPT-PUT-F by mail-request from April Xin (2024/08/) */
		UPDATE dbo.table_unrealised_02_Intermediate SET 
		Accounting_Delivery_Month  = CASE WHEN Instrument_Type IN ('LNG-OPT-PUT-P', 'LNG-SWOPT-PUT-F') AND Cashflow_Type IN ('Premium', 'INT Variation Margin')
																			THEN Cashflow_Payment_Date
																			ELSE CASE WHEN Instrument_Type ='GAS-FUT-AVG-EXCH-P' 
																								THEN eomonth(Delivery_Month) 
																								ELSE isnull(case when Term_End >= LegEndDate then Term_End else LegEndDate END, Term_End)
																					 END
																	END

		SET @Step = 58 
		SET @Status_Text= 'mapping: ST/LT.' 	
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, @Main_Process, @Calling_App, @step, 1 
		/*Update ST/LT based on Accounting_Delivery_Month (ADM)*/		
		UPDATE dbo.table_unrealised_02_Intermediate SET 
			ShortTerm_LongTerm = case when Accounting_Delivery_Month > EOMONTH(dateadd(month,12, COB)) then 'LT' Else 'ST' END
		

		SET @Step = 60
		SET @Status_Text= 'mapping: Hedge_ID/_Quote, Volume_Avaliable/_Used.' 	 /*mappings coming from hedging_relations*/
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, @Main_Process, @Calling_App, @step, 1 

		UPDATE dbo.table_unrealised_02_Intermediate SET 
			 Hedge_ID = table_unrealised_hedging_relations.Hedge_ID	
			,Hedge_Quote = table_unrealised_hedging_relations.Percent_Included
			,Volume_Avaliable= table_unrealised_hedging_relations.Available_Volume
			,Volume_Used = table_unrealised_hedging_relations.Allocated_Volume 
		from 
			dbo.table_unrealised_02_Intermediate
			LEFT JOIN dbo.table_unrealised_hedging_relations ON dbo.table_unrealised_02_Intermediate.deal_number = dbo.table_unrealised_hedging_relations.Deal_Number
	
		SET @Step = 62
		SET @Warning_Counter = @Warning_Counter+1
		SET @Status_Text= 'enrichment: hedging unwind update - coming soon.' 	
		EXEC dbo.Write_Log 'WARNING', @Status_Text, @Current_Procedure, @Main_Process, @Calling_App, @step, 1 
	

	/*00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000*/
		--insert hedge split logic here !!!
	/*00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000*/

		SET @Step = 70 /* tested OK, mkb 17/07*/
		SET @Status_Text= 'mapping: Unit_Of_Account.' 	
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, @Main_Process, @Calling_App, @step, 1 
	
		/* UNIT OF ACCOUNT: take the sum of all term ends (by deal) and enter either "ASSET" or "LIABILITY" into the related field depending on the outcome.*/
		UPDATE dbo.table_unrealised_02_Intermediate SET 
			 Unit_Of_Account = subsql.Unit_of_Account
		FROM 
			dbo.table_Unrealised_02_Intermediate INNER JOIN 
			(
				SELECT 
					Deal_Number
					,CASE WHEN Unrealised_Discounted_BU_CCY >=0 THEN 'ASSET' ELSE 'LIABILITY' END as Unit_of_Account
				FROM 
				(
					SELECT 
					Deal_Number
					,sum(Unrealised_Discounted_BU_CCY) as Unrealised_Discounted_BU_CCY
					FROM 
						dbo.table_Unrealised_02_Intermediate
					WHERE 
						accounting_treatment in ('FV_OCI','FV_PNL')
					GROUP BY 
						Deal_Number
				) as inner_subsql
			) as subsql
			on dbo.table_Unrealised_02_Intermediate.Deal_Number = subsql.Deal_Number
					


		SET @Step = 72 /* tested OK, mkb 17/07*/
		SET @Status_Text= 'mapping: Balance_Sheet_Account and PNL_OCI_Account.' 	
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, @Main_Process, @Calling_App, @step, 1 
		
		UPDATE dbo.table_unrealised_02_Intermediate
		SET 
			PNL_OCI_Account = isnull(PNL_OCI,'not mapped')
			,Balance_Sheet_Account = CASE WHEN Unit_Of_Account = 'ASSET' and ShortTerm_LongTerm = 'ST' THEN  ST_Asset ELSE
				CASE WHEN Unit_Of_Account = 'ASSET' and ShortTerm_LongTerm = 'LT' THEN  LT_Asset ELSE
					CASE WHEN Unit_Of_Account = 'LIABILITY' and ShortTerm_LongTerm = 'ST' THEN  ST_Liability ELSE
						CASE WHEN Unit_Of_Account = 'LIABILITY' and ShortTerm_LongTerm = 'LT' THEN  LT_Liability ELSE 'not mapped' END
					END
				END
			END 
		FROM 
			table_unrealised_02_Intermediate left join dbo.table_map_accounts_unrealised 
			on table_unrealised_02_Intermediate.Accounting_Treatment = table_map_accounts_unrealised.Accounting_Treatment
				and table_unrealised_02_Intermediate.Counterparty_Group = table_map_accounts_unrealised.Counterparty_Group
				and table_unrealised_02_Intermediate.Commodity_Type = table_map_accounts_unrealised.Commodity_Type

	
		SET @Status_Text= 'Finished: mappings and enrichments.' 	
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, @Main_Process, @Calling_App, @step, 1 

		SET @Step = 74
		SET @Status_Text= 'Start data transfer intermediate > 02.' 	
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, @Main_Process, @Calling_App, @step, 1 

		SET @Step = 76
		TRUNCATE TABLE dbo.Table_Unrealised_02
		
		SET @Step = 78
		INSERT INTO dbo.table_Unrealised_02
		(
			COB
			,Deal_Number
			,Trade_Date
			,Term_Start
			,Term_End
			,Internal_Legal_Entity
			,Desk_Name
			,Desk_ID
			,Desk_CCY
			,SubDesk
			,RevRec_SubDesk
			,Book_Name
			,Book_ID
			,Internal_Portfolio
			,Portfolio_ID
			,Instrument_Type
			,Unit_of_Measure
			,External_Legal_Entity
			,External_Business_Unit
			,External_Portfolio
			,Projection_Index_Name
			,Projection_Index_Group
			,Product_Name
			,Adjustment_ID
			,Cashflow_Payment_Date
			,LegEndDate
			,Delivery_Date
			,Delivery_Month
			,Trade_Price
			,Cashflow_Type
			,Cashflow_Type_ID
			,[Contract_Name]
			,Unit_Of_Account
			,ShortTerm_LongTerm
			,Accounting_Delivery_Month
			,Counterparty_Group
			,Order_Number
			,Partner_Code
			,Active_Period
			,Buy_Sell
			,Orig_Month
			,Target_Month
			,Accounting_Treatment
			,Volume
			,Volume_Avaliable
			,Volume_Used
			,Hedge_ID
			,Hedge_Quote
			,Product_ticker
			,RACE_Position
			,Commodity_Type
			,Balance_Sheet_Account
			,PNL_OCI_Account
			,Cashflow_CCY
			,Accounting_Comment	
			,Adjustment_Comment
			,Adjustment_Category
			,Unrealised_Discounted_BU_CCY
			,Realised_Discounted_BU_CCY
			,Unrealised_Discounted_CF_CCY
			,Realised_Discounted_CF_CCY
			,Total_Discounted_BU_CCY 
			,Total_Discounted_CF_CCY 
			,Total_Accounting_Discounted_BU_CCY 
			,Total_Accounting_Discounted_CF_CCY
			,Total_Accounting_Discounted_CF_CCY_SAP_EUR
			,FX_Rate_CF_CCY_EUR
			,DataSource
			,FileID
		)
		SELECT 
			COB
			,Deal_Number
			,Trade_Date
			,Term_Start
			,Term_End
			,Internal_Legal_Entity
			,Desk_Name
			,Desk_ID
			,Desk_CCY
			,SubDesk
			,RevRec_SubDesk
			,Book_Name
			,Book_ID
			,Internal_Portfolio
			,Portfolio_ID
			,Instrument_Type
			,Unit_of_Measure
			,External_Legal_Entity
			,External_Business_Unit
			,External_Portfolio
			,Projection_Index_Name
			,Projection_Index_Group
			,Product_Name
			,Adjustment_ID
			,Cashflow_Payment_Date
			,LegEndDate
			,Delivery_Date
			,Delivery_Month
			,Trade_Price
			,Cashflow_Type
			,Cashflow_Type_ID
			,[Contract_Name]
			,Unit_Of_Account
			,ShortTerm_LongTerm
			,Accounting_Delivery_Month
			,Counterparty_Group
			,Order_Number
			,Partner_Code
			,Active_Period
			,Buy_Sell
			,Orig_Month
			,Target_Month
			,Accounting_Treatment
			,Volume
			,Volume_Avaliable
			,Volume_Used
			,Hedge_ID
			,Hedge_Quote
			,Product_ticker
			,RACE_Position
			,Commodity_Type
			,Balance_Sheet_Account
			,PNL_OCI_Account
			,Cashflow_CCY
			,Accounting_Comment	
			,Adjustment_Comment
			,Adjustment_Category
			,Unrealised_Discounted_BU_CCY
			,Realised_Discounted_BU_CCY
			,Unrealised_Discounted_CF_CCY
			,Realised_Discounted_CF_CCY
			,Total_Discounted_BU_CCY 
			,Total_Discounted_CF_CCY 
			,Total_Accounting_Discounted_BU_CCY 
			,Total_Accounting_Discounted_CF_CCY
			,Total_Accounting_Discounted_CF_CCY_SAP_EUR
			,FX_Rate_CF_CCY_EUR
			,DataSource
			,FileID			
		FROM 
			dbo.table_Unrealised_02_Intermediate 
		
		SET @Step = 80
		SELECT @Record_Counter = count(*) from dbo.Table_Unrealised_02
		SET @Status_Text= 'Finished data transfer intermediate > 02, ' + cast(format(@Record_Counter,'###,###')as varchar) + ' records transferred.' 	


		SET @Step = 82 
		SET @Status_Text= 'Start create new unrealised_eom.' 	
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, @Main_Process, @Calling_App, @step, 1 

		SET @Step = 84 
		TRUNCATE TABLE dbo.table_unrealised_EOM

		SET @Step = 86
		INSERT INTO [dbo].[table_unrealised_EOM]
		(
			 [COB]
			,[Desk_name]
			,[Subdesk]
			,[RevRec_SubDesk]
			,[Deal_Number]
			,[Trade_Date]
			,[Term_End]
			,[Accounting_Treatment]
			,[Internal_Legal_Entity]
			,[Internal_Portfolio]
			,[Counterparty_Group]
			,[Instrument_Type]
			,[Projection_Index_Group]
			,[Projection_Index_Name]
			,[Product_Name]
			,[External_Business_Unit]
			,[External_Legal_Entity]
			,[External_Portfolio]
			,[Unit_of_Measure]
			,[Desk_CCY]
			,[Cashflow_CCY]
			,[Volume]
			,[Volume_Avaliable]
			,[Volume_Used]
			,[Unrealised_Discounted_BU_CCY]
			,[Unrealised_Discounted_CF_CCY]
			,[Realised_Discounted_BU_CCY]
			,[Realised_Discounted_CF_CCY]
			,[Total_Discounted_BU_CCY]
			,[Total_Discounted_CF_CCY]
			,[Total_Accounting_Discounted_BU_CCY]
			,[Total_Accounting_Discounted_CF_CCY]
			,[Total_Accounting_Discounted_CF_CCY_SAP_EUR]
			,[PNL_BU_CCY]
			,[PNL_CF_CCY]
			,[OCI_BU_CCY]
			,[OCI_CF_CCY]
			,[NOR_BU_CCY]
			,[NOR_CF_CCY]
			,[OU_BU_CCY]
			,[OU_CF_CCY]
		)
		SELECT 			
			COB																														
			,Desk_name																												
			,Subdesk
			,RevRec_SubDesk
			,Deal_Number																										
			,Trade_Date 																										
			,Term_End 																											
			,Accounting_Treatment																						
			,Internal_Legal_Entity 																					
			,Internal_Portfolio 																						
			,Counterparty_Group 																						
			,Instrument_Type 																								
			,Projection_Index_Group 																				
			,Projection_Index_Name 																					
			,Product_Name 																									
			,External_Business_Unit 																				
			,External_Legal_Entity 																					
			,External_Portfolio 																						
			,Unit_of_Measure 																								
			,Desk_CCY 																											
			,Cashflow_CCY 		
			,ROUND(SUM(Volume),2) as Volume		
			,ROUND(SUM(Volume_Avaliable),2) as Volume_Avaliable		
			,ROUND(SUM(Volume_Used ),2) as Volume_Used 		
		
			,ROUND(SUM(Unrealised_Discounted_BU_CCY),2) as Unrealised_Discounted_BU_CCY		
			,ROUND(SUM(Unrealised_Discounted_CF_CCY),2) as Unrealised_Discounted_CF_CCY		

			,ROUND(SUM(Realised_Discounted_BU_CCY),2) as Realised_Discounted_BU_CCY		
			,ROUND(SUM(Realised_Discounted_CF_CCY),2) as Realised_Discounted_CF_CCY		
		
			,ROUND(SUM(Total_Discounted_BU_CCY),2) as Total_Discounted_BU_CCY		
			,ROUND(SUM(Total_Discounted_CF_CCY),2) as Total_Discounted_CF_CCY		

			,ROUND(SUM(Total_Accounting_Discounted_BU_CCY),2) as Total_Accounting_Discounted_BU_CCY			
			,ROUND(SUM(Total_Accounting_Discounted_CF_CCY),2) as Total_Accounting_Discounted_CF_CCY	

			,ROUND(SUM(Total_Accounting_Discounted_CF_CCY_SAP_EUR),2) as Total_Accounting_Discounted_CF_CCY_SAP_EUR		
		
			,ROUND(SUM(iif(Accounting_Treatment = 'FV_PNL', Total_Discounted_BU_CCY,0)),2) as PNL_BU_CCY
			,ROUND(SUM(iif(Accounting_Treatment = 'FV_PNL', Total_Discounted_CF_CCY,0)),2) as PNL_CF_CCY

			,ROUND(SUM(iif(Accounting_Treatment = 'FV_OCI', Total_Discounted_BU_CCY,0)),2) as OCI_BU_CCY
			,ROUND(SUM(iif(Accounting_Treatment = 'FV_OCI', Total_Discounted_CF_CCY,0)),2) as OCI_CF_CCY

			,ROUND(SUM(iif(Accounting_Treatment = 'FV_NOR', Total_Discounted_BU_CCY,0)),2) as NOR_BU_CCY
			,ROUND(SUM(iif(Accounting_Treatment = 'FV_NOR', Total_Discounted_CF_CCY,0)),2) as NOR_CF_CCY

			,ROUND(SUM(iif(Accounting_Treatment = 'Own Use', Total_Discounted_BU_CCY,0)),2) as OU_BU_CCY
			,ROUND(SUM(iif(Accounting_Treatment = 'Own Use', Total_Discounted_CF_CCY,0)),2) as OU_CF_CCY
		FROM 
			dbo.table_unrealised_02		
		GROUP BY
			Desk_name
			,Subdesk
			,RevRec_SubDesk
			,COB
			,Internal_Legal_Entity
			,Accounting_Treatment
			,Internal_Portfolio
			,External_Business_Unit
			,External_Legal_Entity
			,External_Portfolio
			,Counterparty_Group
			,Instrument_Type
			,Projection_Index_Group
			,Projection_Index_Name
			,Product_Name
			,Deal_Number
			,Trade_Date
			,Term_End
			,Unit_of_Measure
			,Desk_CCY
			,Cashflow_CCY

		
		SET @Status_Text= 'Finished create new unrealised_eom.' 	
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, @Main_Process, @Calling_App, @step, 1 





/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/	
/*NoFurtherAction, so tell the world we're done, but inform about potential warnings.*/
		SELECT @step = 300
		SET @Status_Text = 'FINISHED'
		IF @Warning_Counter = 0
			BEGIN
					EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, @Main_Process, @Calling_App, @step, 1 
			END
		ELSE
			BEGIN
				SET @Status_Text ='FINISHED WITH ' + cast(@Warning_Counter as varchar) +  ' WARNINGS! - check log for details!'
				EXEC dbo.Write_Log 'WARNING', @Status_Text, @Current_Procedure, @Main_Process, @Calling_App, @step, 1 
			END
		Return 0
END TRY

BEGIN CATCH
	/*tell the world procedure failed*/
	EXEC [dbo].[usp_GetErrorInfo] @Current_Procedure, @step, NULL; 
	EXEC dbo.Write_Log 'FAILED', 'FAILED with error! - check log for details', @Current_Procedure, @Main_Process, @Calling_App, @step, 1;
	Return @step
END CATCH

GO

