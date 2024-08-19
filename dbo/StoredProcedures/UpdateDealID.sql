








CREATE PROCEDURE [dbo].[UpdateDealID] 
	AS
	BEGIN TRY
	
		/*define some variables */
		DECLARE @LogInfo Integer
		DECLARE @step Integer
		DECLARE @proc varchar(40)
		DECLARE @COB as date
		
		SELECT @proc = Object_Name(@@PROCID)

		select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ' - START', GETDATE () END
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': map_DealID_Ticker', GETDATE () END

		select @step = 1
		UPDATE Recon_zw1  
			SET [DealID_Recon] = [dbo].[map_DealID_Ticker].[Ticker], 
					[Adj_Comment] = case when [Adj_Comment] is NULL 
																		or [source]  not in ('adj') 
															then '' + '// updated dealID' 
															else [Adj_Comment] + '// updated Ticker' 
													end
			from 
				dbo.Recon_zw1 join [dbo].[map_DealID_Ticker] 
				on [dbo].[Recon_zw1].[DealID] = [dbo].[map_DealID_Ticker].[DealID]

		-- to be deleted after mointh end MBE
		UPDATE Recon_zw1
			SET [dbo].[Recon_zw1].[DealID_Recon] = [dbo].[map_cs_contract].[dealid_recon],
				[dbo].[Recon_zw1].[Adj_Comment] = 
							case when [dbo].[Recon_zw1].[Adj_Comment] is NULL or [dbo].[Recon_zw1].[source]  not in ('adj') then '' + '// updated dealID' 
								else [dbo].[Recon_zw1].[Adj_Comment] + '// updated Deal ID Recon for CS' end
			from [dbo].[Recon_zw1]  
				join [dbo].[map_cs_contract]  on 
							[dbo].[Recon_zw1].orderno = [dbo].[map_cs_contract].orderno and 
							[dbo].[Recon_zw1].ExternalBusinessUnit = [dbo].[map_cs_contract].ExternalBusinessUnit and 
							[dbo].[Recon_zw1].InstrumentType = [dbo].[map_cs_contract].InstrumentType
				
		select @step = 2	
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': map_DealIDUpdate', GETDATE () END
		UPDATE Recon_zw1 
			SET [DealID_Recon] = [dbo].[map_DealIDUpdate].[DealID_New], 
					[Adj_Comment] = case when [Adj_Comment] is NULL 
																 or [source]  not in ('adj') 
															 then '' + '// updated dealID' 
															 else [Adj_Comment] + '// updated dealID' 
													end
			from 
				dbo.Recon_zw1 join [dbo].[map_DealIDUpdate] 
				on [dbo].[Recon_zw1].[DealID_Recon] = [dbo].[map_DealIDUpdate].[DealID_Old]

		/*just to get rid of the "NULL"*/
		select @step = 3	
		UPDATE [dbo].[Recon_zw1] 
			SET [DealID_Recon] = '' 
			where 
				dealid_recon is null

		-- DELETE WHOLE BLOCK AFTER 2025-04-23, IF NOT REACTIVED UNTILL THEN.
		-- 2024-04-23 MK: Commented because of account assignment requirement by Anna-Lena Maas.
		--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': map_Account_ExchangeTraded', GETDATE () END

		--select @step = 4	
		--CREATE TABLE [dbo].[temp_update_account]
		--(
		--	[recon_group] [varchar](100) NULL,	
		--	[ctpygroup] [varchar](100) NULL,	
		--	[OrderNo] [varchar](100) NULL,	
		--	[InstrumentType] [varchar](100) NULL,	
		--	[ExternalBusinessUnit] [varchar](100) NULL,
		--	[Ticker] [varchar](100) NULL,	
		--	[DeliveryMonth] [varchar](100) NULL,	
		--	[RealisedBase] [numeric](20, 2) NULL,	
		--	[MinSAPAccount] [varchar](100) NULL,	
		--	[MaxSAPAccount] [varchar](100) NULL,	
		--	[SAPAccountNEW] [varchar](100) NULL,
		--	[MinVAT] [varchar](100) NULL,	
		--	[MaxVAT] [varchar](100) NULL,	
		--	[VATNEW] [varchar](100) NULL,
		--) ON [PRIMARY]

		--select @step = 5	
		--insert into [dbo].[temp_update_account] 
		--(
		--	[recon_group]
		--	,[ctpygroup]
		--	, [OrderNo]
		--	,[InstrumentType]
		--	,[externalbusinessunit]
		--	,[ticker]
		--	,[DeliveryMonth]
		--	,[realisedbase]
		--	,[minsapAccount]
		--	,[maxsapAccount]
		--	,[sapAccountNEW]
		--	,minVAT
		--	,maxVAT
		--	,VATNEW
		--)	
		--SELECT 
		--	recongroup
		--	,CounterpartyGroup
		--	,OrderNo
		--	,InstrumentType
		--	,externalbusinessunit
		--	,dealid_recon
		--	,DeliveryMonth
		--	,sum(realised_ccy_endur) as realised_eur
		--	,min(Account_endur) as minAccount
		--	,max(Account_Endur) as maxAccount
		--	,case when sum(realised_ccy_endur) < 0 then max(Account_Endur) else min(Account_Endur) end as AccountNEW
		--	,min(vat_script) as minVAT
		--	,max(vat_script) as maxVAT
		--	,case when sum(realised_ccy_endur) < 0 then max(vat_script) else min(vat_script) end as VATNEW
		--from 
		--	dbo.[recon_zw1] 
		--where 
		--	[source] = 'realised_script'
		--group by 
		--	 recongroup
		--	,CounterpartyGroup
		--	,orderno
		--	,InstrumentType
		--	,externalbusinessunit
		--	,dealid_recon
		--	,DeliveryMonth
		--	,ccy
		--having 
		--	recongroup = 'Exchanges' 
		--	and min(Account_endur) <> max(Account_endur)
	
		--select @step = 4	
		--update dbo.[recon_zw1]
		--	set [Account_endur] = temp.sapAccountNew,
		--			[vat_script] = temp.vatnew
		--	from 
		--		dbo.[recon_zw1] inner join dbo.[temp_update_account] temp
		--		on	dbo.[recon_zw1].orderno = temp.OrderNo 
		--		AND dbo.[recon_zw1].InstrumentType = temp.InstrumentType
		--		AND dbo.[recon_zw1].ExternalBusinessUnit = temp.ExternalBusinessUnit
		--		AND dbo.[recon_zw1].dealid_recon = temp.ticker
		--		AND dbo.[recon_zw1].deliverymonth = temp.DeliveryMonth
		--		AND dbo.[recon_zw1].CounterpartyGroup = temp.ctpygroup 

		--select @step = 5	
		--IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'temp_update_account'))
		----BEGIN DROP TABLE dbo.temp_update_account END 
			
		--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - '+ @proc + ' - FINISHED' , GETDATE () END

END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step		
		BEGIN INSERT INTO [dbo].[Logfile] SELECT 'Reconciliation - ' + @proc + ' - FAILED', GETDATE () END
	END CATCH

GO

