


/* ==========================================================================================================
author:				unknown
created:			unknown 
Description:	Imports strolf data from CAO CE snowflake DB
-------------------------------------------------------------------------------------------------------------
changes: when, who, step, what, (why)
2024-07-05, mkb, all, hard coded step numbers
2024-07-05, mkb, 8, prepared use of new mapping_table for cashflow_type (not yet activated)

=============================================================================================================*/

	CREATE PROCEDURE [dbo].[ImportStrolfData_Realized] 
	AS
	BEGIN TRY

		DECLARE @proc nvarchar(40)
		DECLARE @step Integer
		DECLARE @LogInfo Integer
		DECLARE @COB_DATE as Date

		select @step = 1
		-- we need the LogInfo for Logging
		select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

		select @proc = Object_Name(@@PROCID)

		select @step = 2
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import Strolf Data Realized - Start Import Strolf Data', GETDATE () END
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import Strolf Data Realized- fill [dbo].[Strolf_REALIZED]', GETDATE () END
	
		truncate table [dbo].[Strolf_REALIZED]


		select @step = 3		
		select @COB_DATE = MAX([COB]) from[ROCKCAO_CE].[CAO_CE].[XPORT].[FIN_REALIZED]


		select @step = 4
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import Strolf Data Realized- fill [dbo].[Strolf_REALIZED]', GETDATE () END
		
		insert into [dbo].[Strolf_realized] 
			(COB, TRADE_DEAL_NUMBER, TRAN_STATUS, INS_TYPE_NAME, LENTITY_NAME, BUNIT_NAME, PORTFOLIO_ID, PORTFOLIO_NAME, EXT_PORTFOLIO_NAME, EXT_BUNIT_NAME, EXT_LENTITY_NAME,
			INDEX_NAME, TRADE_CURRENCY, TRANSACTION_INFO_BUY_SELL, CASHFLOW_TYPE, TRADE_PRICE, TRADE_DATE, TICKER, UNIT_NAME, CASHFLOW_PAYMENT_DATE, INDEX_GROUP, VOLUME,
			REALISED_ORIGCCY_UNDISC, REALISED_EUR_UNDISC, DELIVERY_MONTH,TRADE_REFERENCE_TEXT)
		select 
			COB, TRADE_DEAL_NUMBER, TRAN_STATUS, INS_TYPE_NAME, LENTITY_NAME, BUNIT_NAME, PORTFOLIO_ID, PORTFOLIO_NAME, EXT_PORTFOLIO_NAME, EXT_BUNIT_NAME, EXT_LENTITY_NAME, 
			INDEX_NAME, TRADE_CURRENCY, TRANSACTION_INFO_BUY_SELL, CASHFLOW_TYPE, TRADE_PRICE, TRADE_DATE, TICKER, UNIT_NAME, CASHFLOW_PAYMENT_DATE, INDEX_GROUP, VOLUME, REALISED_ORIGCCY_UNDISC,
			REALISED_EUR_UNDISC, DELIVERY_MONTH, left(TRADE_REFERENCE_TEXT,100)
		from [ROCKCAO_CE].[CAO_CE].[XPORT].[FIN_REALIZED]
		where [COB] = @COB_DATE


		select @step = 5
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import Strolf Data Realized- fill [dbo].[Strolf_REALIZED_ADJ]', GETDATE () END

		insert into [dbo].[Strolf_realized] 
			(COB, TRADE_DEAL_NUMBER, TRAN_STATUS, INS_TYPE_NAME, LENTITY_NAME, BUNIT_NAME, PORTFOLIO_ID, PORTFOLIO_NAME, EXT_PORTFOLIO_NAME, EXT_BUNIT_NAME, EXT_LENTITY_NAME,
			INDEX_NAME, TRADE_CURRENCY, TRANSACTION_INFO_BUY_SELL, CASHFLOW_TYPE, TRADE_PRICE, TRADE_DATE, TICKER, UNIT_NAME, CASHFLOW_PAYMENT_DATE, INDEX_GROUP, VOLUME,
			REALISED_ORIGCCY_UNDISC, REALISED_EUR_UNDISC, DELIVERY_MONTH,TRADE_REFERENCE_TEXT)
		select 
			COB, TRADE_DEAL_NUMBER, TRAN_STATUS, INS_TYPE_NAME, LENTITY_NAME, BUNIT_NAME, PORTFOLIO_ID, PORTFOLIO_NAME, EXT_PORTFOLIO_NAME, EXT_BUNIT_NAME, EXT_LENTITY_NAME, INDEX_NAME,
			TRADE_CURRENCY, TRANSACTION_INFO_BUY_SELL, CASHFLOW_TYPE, TRADE_PRICE, TRADE_DATE, TICKER, UNIT_NAME, CASHFLOW_PAYMENT_DATE, INDEX_GROUP, VOLUME, REALISED_ORIGCCY_UNDISC,
			REALISED_EUR_UNDISC, DELIVERY_MONTH, left(TRADE_REFERENCE_TEXT,100)
		from [ROCKCAO_CE].[CAO_CE].[XPORT].[FIN_REALIZED_ADJ]
		where [COB] = @COB_DATE
		/*--where [COB] in (select max([COB]) from[GLOR4P]..[STROLF_FINANCE].[FIN_REALIZED])*/


		select @step = 6
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import Strolf Data Realized - update [dbo].[FilesToImport]', GETDATE () END

		update [dbo].[FilestoImport] 
		set LastImport = getdate()
		where id = 2210
	

		select @step = 7	
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import Strolf Data Realized - delete from [dbo].[01_realised_all]', GETDATE () END

		delete from [dbo].[01_realised_all] where fileid = 2210


		select @step = 8
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import Strolf Data Realized - insert into [dbo].[01_realised_all]', GETDATE () END
			 
		insert into [01_realised_all] ( [Trade Deal Number], [Trade Reference Text] ,[Transaction Info Status] ,[Instrument Type Name] ,[Int Legal Entity Name] ,[Int Business Unit Name]		
			,[Internal Portfolio Business Key] ,[Internal Portfolio Name] ,[External Portfolio Name] ,[Ext Business Unit Name] ,[Ext Legal Entity Name]		
			,[Index Name] ,[Trade Currency] ,[Transaction Info Buy Sell] ,[Cashflow Type] ,[Trade Price] ,[Trade Date] ,[Trade Instrument Reference Text]		
			,[Unit Name (Trade Std)] ,[Cashflow Payment Date] ,[Leg End Date] ,[Index Group] ,[volume] ,[Realised_OrigCCY_Undisc] ,[Realised_EUR_Undisc] ,[FileID])		
		select [TRADE_DEAL_NUMBER] , [TRADE_REFERENCE_TEXT], [TRAN_STATUS] ,[INS_TYPE_NAME] ,[LENTITY_NAME] ,[BUNIT_NAME] ,[PORTFOLIO_ID] ,[PORTFOLIO_NAME] ,[EXT_PORTFOLIO_NAME]		
			,[EXT_BUNIT_NAME] ,[EXT_LENTITY_NAME] ,[INDEX_NAME] ,[TRADE_CURRENCY] ,[TRANSACTION_INFO_BUY_SELL]		
			,case when c.name is null then r.[CASHFLOW_TYPE] else c.name end	
			/*isnull(cashflow_type_name,CASHFLOW_TYPE)*/ /*basing on new table_map_cashflow_type, mkb*/
			,[TRADE_PRICE] ,[TRADE_DATE] ,[TICKER] 
			,case when INS_TYPE_NAME = 'PWR-FWD-P' and [UNIT_NAME] in ('Currency','MT') then 'MWH' else [UNIT_NAME] end
			,[CASHFLOW_PAYMENT_DATE],	[DELIVERY_MONTH] ,[INDEX_GROUP] ,[VOLUME] ,[REALISED_ORIGCCY_UNDISC] ,[REALISED_EUR_UNDISC] ,2210
		FROM [Strolf_REALIZED] r 
			left join map_cflowtype c on r.CASHFLOW_TYPE = c.id_number
			/*left join table_map_cashflow_type on CASHFLOW_TYPE = cashflow_type_id, mkb */


/*======================================================================================================*/
		select @step = 9
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import Strolf Data Realized - insert into [dbo].[01_realised_all]', GETDATE () END
		
		insert into [01_realised_all] ( [Trade Deal Number], [Trade Reference Text] ,[Instrument Type Name] ,[Int Legal Entity Name],[Internal Portfolio Name] 
                          ,[Ext Business Unit Name]  ,[Ext Legal Entity Name] ,[Trade Currency]  ,[Cashflow Type] ,[Trade Date]
                           ,[Unit Name (Trade Std)] ,[Cashflow Payment Date] ,[Leg End Date], [Index Group] ,[volume] ,[Realised_OrigCCY_Undisc] ,[Realised_EUR_Undisc] ,[FileID])
       select [TRADE_DEAL_NUMBER] , [TRADE_REFERENCE_TEXT], [INS_TYPE_NAME] ,[LENTITY_NAME] ,[PORTFOLIO_NAME] 
                           ,case when c.[ExtBunit] is NULL then left(r.EXT_LENTITY_NAME,100) else c.extbunit end ,left([EXT_LENTITY_NAME],100) ,[TRADE_CURRENCY] ,'eTax 1' as Cflowtype,[TRADE_DATE]
                    ,[UNIT_NAME],[CASHFLOW_PAYMENT_DATE],[DELIVERY_MONTH] ,Index_Group ,[VOLUME] ,
                    -[VOLUME]*case when Ins_type_name = 'PWR-FWD-P' then Stromsteuer else Gassteuer end as realised_eur ,
                    -[VOLUME]*case when Ins_type_name = 'PWR-FWD-P' then Stromsteuer else Gassteuer end as [REALISED_EUR_UNDISC] ,2210
       FROM [Strolf_REALIZED] r
                    JOIN asofdate d  on r.cob = d.asofdate_eom
                    left JOIN [map_CS_counterparty] c on c.[ExtBunit] = r.[EXT_BUNIT_NAME] 
       WHERE [VOLUME]*case when left(Ins_type_name,7) = 'PWR-FWD' then Stromsteuer else Gassteuer end <>0 
             and  left(INS_TYPE_NAME,7) in ('GAS-FWD','PWR-FWD')
	
		select @step = 10
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import Strolf Data Realized - delete data from [dbo].[01_realised_all]', GETDATE () END
	
		delete from dbo.[01_realised_all] 
			where fileid = 2210 
			and dbo.[01_realised_all].[Trade Deal Number] + cast(dbo.[01_realised_all].[Cashflow Payment Date] as varchar) in 
						(
							select 
								r.[Trade Deal Number] + cast(r.[Cashflow Payment Date] as varchar) 
							from 
								dbo.[01_realised_all] r
								inner join dbo.map_instrument i
								on r.[Instrument Type Name] = i.InstrumentType
							where 
								cast(year(r.[Cashflow Payment Date])as  nvarchar) < (select year(asofdate_eom) from dbo.asofdate)
								and cast(year(r.[Trade Date])as  nvarchar) < (select year(asofdate_eom) from dbo.asofdate)
							  and fileid = 2210
								and (
											i.[instrumentgroup] = 'Option' 
											or 
											[Cashflow Type] not in ('FX Forward', 'FX Spot', 'None', 'Commodity', 'Ticket Commodity CFlow', 
																							'OLF Correction', 'Margin', 'Upfront', 'Interest', 'Premium', 'FX Swap', 
																							'Broker Fee',  'Prepayment Principal', 'Prepayment Reversal', 'Provisional Principal', 
																							'Provisional Reversal', 'Broker Commission', 'Bunkers NOT in PnL')
										)
						) 

		select @step = 11
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import Strolf Data Realized - Import Strolf Data Realized has finished', GETDATE () END


END TRY

	BEGIN CATCH
		--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
	END CATCH

GO

