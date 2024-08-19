
/*
purpose: procedure to identify the profit/loss for any new deal in CAO POwer made on day one 
results will get stored in table "dbo.table_Day1ProfitLoss_RESULTING_DATA"
prerequisites:  all trade files and all mtm files of the current month have been imported beforehand into the related tmp-tables.
author: mkb
date: 2022-07-27
*/

CREATE procedure [dbo].[Day1ProfitLoss_PrepareData]
AS	

	DECLARE @ReturnValue int
	DECLARE @proc nvarchar(50)	
	DECLARE @step Integer	
	DECLARE @LogInfo Integer
	DECLARE @COB as date
	
BEGIN TRY

		SELECT @proc = Object_Name(@@PROCID)

		SELECT @Step = 1		

		SELECT @COB = AsOfDate_EOM from dbo.AsOfDate
		SELECT @COB = DATEFROMPARTS(YEAR(@COB), MONTH(@COB), 1);

		SELECT  @Step = 2	
		--/*check if logging is enabled (0 = disabled, anything >0 = enabled */
		SELECT @LogInfo = [dbo].[LogInfo].[LogInfo] FROM [dbo].[LogInfo]
		
		IF @LogInfo >= 1  
		BEGIN 
			insert into [dbo].[Logfile] SELECT @proc + ' - START', GETDATE () 
			insert into [dbo].[Logfile] SELECT @proc + ' - process imported MTM', GETDATE () 
		END

		SELECT  @Step = 10	
		/*transfer mtm from temp to final table and do the required data type conversions*/
		truncate table [dbo].[table_Day1ProfitLoss_MTM]

		insert into [dbo].[table_Day1ProfitLoss_MTM]
		(
			Reference_ID
			,report_DATE 
			,Term_end 
			,CCY
			,fx_rate 
			,mtm_undisc
			,mtm_disc
		)
		SELECT 
			[column1]
			,convert(date, [column2],103) col1
		 , convert(date, [column3],103) col2
					,[column4]
					,[column5]
					,[column6]
					,[column7]
		FROM [dbo].[table_Day1ProfitLoss_MTM_tmp]	


		IF @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] SELECT @proc + ' - process imported Trades', GETDATE () END
		
		SELECT  @Step = 20	
		/*delete empty rows*/
		delete from dbo.table_Day1ProfitLoss_TRADE_tmp where len(column1)<1
		
		
		IF @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] SELECT @proc + ' - remove any data from final trade table to avoid duplicate entries', GETDATE () END
		delete from [dbo].[table_Day1ProfitLoss_TRADE]

		IF @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] SELECT @proc + ' - transfer trades and do the required data type conversions', GETDATE () END
		INSERT INTO [dbo].[table_Day1ProfitLoss_TRADE]
           ([Deal_Type]
           ,[Reference_ID]
           ,[Tran_Number]
           ,[Offset_Tran_Number]
           ,[Trade_Date]
           ,[Term_Start]
           ,[Term_End]
           ,[Trader_Name]
           ,[Trader_ID]
           ,[Portfolio_Name]
           ,[Portfolio_ID]
           ,[Counterparty]
           ,[Counterparty_ID]
           ,[Counterparty_Group]
           ,[Deal_Volume]
           ,[BuySell_Flag]
           ,[Expiration_Date]
           ,[Deal_Price]
           ,[Trade_Status]
           ,[Settlement_Date]
           ,[Price_Curve_Name]
           ,[Price_Curve_ID]
           ,[Price_Curve_CCY]
           ,[Price_Curve_UOM]
           ,[Commodity_Name]
           ,[Company_Code]
           ,[Contract_Detail]
           ,[Deal_Currency]
           ,[Param_Seq_Num]
           ,[Profile_Seq_Num]
           ,[Instrument_Type]
           ,[Instrument_SubType]
           ,[fix_float]
           ,[pay_receive]
           ,[Volume_Frequency]
           ,[unit_name]
           ,[Price_Currency_ID]
           ,[Broker_Name]
           ,[Legal_Entity]
           ,[Internal_BU]
           ,[External_Legal_entity]
           ,[External_portfolio]
           ,[Option_Type]
           ,[Option_Strike]
           ,[Option_Premium]
           ,[Premium_Settlement_Date]
           ,[Commentary]
           ,[Product]
           ,[unit_of_measure])
			SELECT 
				[column1],
				[column2],
				[column3],
				[column4],
				convert (date,[column5],103),
				convert (date,[column6],103),
				convert (date,[column7],103),
				[column8],
				[column9],
				[column10],
				[column11],
				[column12],
				cast([column13] as  int),
				[column14],
				cast([column15] as  float),
				[column16],
				convert (date,[column17],103),
				cast([column18] as  float),
				[column19],
				convert (date,[column20],103),
				[column21],
				[column22],
				[column23],
				[column24],
				[column25],
				[column26],
				[column27],
				[column28],
				cast([column29] as  int),
				cast([column30] as  int),
				[column31],
				[column32],
				[column33],
				[column34],
				[column35],
				[column36],
				[column37],
				[column38],
				[column39],
				[column40],
				[column41],
				[column42],
				[column43],
				cast([column44] as  float),
				cast([column45] as  float),
				convert (date,[column46],103),
				[column47],
				[column48],
				[column49]
				FROM 
					[dbo].[table_Day1ProfitLoss_TRADE_tmp]

		SELECT  @Step = 30	
		IF @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] SELECT @proc + ' - delete all deals, that do not belong to CAO Power and which are not new', GETDATE () END

		delete FROM dbo.table_Day1ProfitLoss_TRADE
		where Reference_ID not in
			(
			SELECT distinct reference_id  FROM dbo.table_Day1ProfitLoss_TRADE
			inner join dbo.map_order on dbo.map_order.Portfolio =dbo.table_Day1ProfitLoss_TRADE.portfolio_name
			where 
			dbo.map_order.Desk = 'CAO Power'
			AND Counterparty_Group = 'External'
			AND Instrument_Type not like '%EXCH%'
			AND instrument_type not in ('IRS', 'FX')
			AND Counterparty not like '%RWE%'
			AND Trade_Date>=@COB
			--AND Trade_Date>='2022-07-01'
			)

		SELECT  @Step = 35				
		IF @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] SELECT @proc + ' - delete all MtMs, that do not belong to CAO Power and which are not new', GETDATE () END
		
		delete FROM [dbo].[table_Day1ProfitLoss_MTM] 
		where 
			reference_id not in
			(
			SELECT distinct reference_id  FROM dbo.table_Day1ProfitLoss_TRADE
			inner join dbo.map_order on dbo.map_order.Portfolio =dbo.table_Day1ProfitLoss_TRADE.portfolio_name
			where 
			dbo.map_order.Desk = 'CAO Power'
			AND Counterparty_Group = 'External'
			AND Instrument_Type not like '%EXCH%'
			AND instrument_type not in ('IRS', 'FX')
			AND Counterparty not like '%RWE%'
			AND Trade_Date>=@COB
			--AND Trade_Date>='2022-07-01'
			)
									
		SELECT  @Step = 40	
		IF @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] SELECT @proc + ' - generate the list of effective Day1 profit/loss per deal, still separated by termend, to enable deeper analysis', GETDATE () END


		IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' and TABLE_NAME ='table_Day1ProfitLoss_RESULTING_DATA'))
		BEGIN
			drop table dbo.table_Day1ProfitLoss_RESULTING_DATA
		END

		select 
			table_Day1ProfitLoss_MTM.Reference_ID
			,trade_date
			,first_report_date
			,table_Day1ProfitLoss_MTM.CCY
			,portfolio_name
			,instrument_type
			,counterparty
			,counterparty_group
			,table_Day1ProfitLoss_MTM.Term_end
			,table_Day1ProfitLoss_MTM.mtm_disc
			,table_Day1ProfitLoss_MTM.mtm_undisc
		into 
			dbo.table_Day1ProfitLoss_RESULTING_DATA
		from 
			dbo.table_Day1ProfitLoss_MTM inner join (select Min(report_date) first_report_date, reference_ID from table_Day1ProfitLoss_MTM group by Reference_ID) mtm
			on (mtm.reference_ID= table_Day1ProfitLoss_MTM.Reference_ID and mtm.first_report_date = table_Day1ProfitLoss_MTM.report_date)
			left outer join  (select  distinct 	table_Day1ProfitLoss_TRADE.Reference_ID 
							,table_Day1ProfitLoss_TRADE.Tran_Number
							,table_Day1ProfitLoss_TRADE.portfolio_name
							,table_Day1ProfitLoss_TRADE.instrument_type
							,table_Day1ProfitLoss_TRADE.counterparty
							,table_Day1ProfitLoss_TRADE.counterparty_group
							,table_Day1ProfitLoss_TRADE.Term_End
							,cast (table_Day1ProfitLoss_TRADE.Trade_Date as date) trade_date
						from 
							dbo.table_Day1ProfitLoss_TRADE 
						 inner join (select Max(Tran_Number) last_Tran_Number, reference_ID, Term_End from dbo.table_Day1ProfitLoss_TRADE group by Reference_ID,Term_End) trade
						 on dbo.table_Day1ProfitLoss_TRADE.Reference_ID = trade.Reference_ID 
						 and trade.last_Tran_Number = dbo.table_Day1ProfitLoss_TRADE.Tran_Number
						 and trade.Term_End = dbo.table_Day1ProfitLoss_TRADE.Term_End) trade_details
					on (dbo.table_Day1ProfitLoss_MTM.Reference_ID = trade_details.Reference_ID
							and dbo.table_Day1ProfitLoss_MTM .Term_end = trade_details.term_end)
		order by 
			table_Day1ProfitLoss_MTM.Reference_ID
			,table_Day1ProfitLoss_MTM.report_date
			,table_Day1ProfitLoss_MTM.Term_end

		IF @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] SELECT @proc + ' - FINISHED', GETDATE () END
		return 0
	END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
		BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - FAILED', GETDATE () END
		Return 666
	END CATCH

GO

