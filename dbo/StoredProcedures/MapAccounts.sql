










CREATE PROCEDURE [dbo].[MapAccounts]
AS
BEGIN TRY

		/*define some variables */
		DECLARE @FILEPath varchar (300)
		DECLARE @LogInfo Integer
		DECLARE @proc nvarchar(40)
		DECLARE @step Integer
		DECLARE @counter Integer

		select @step = 1
		SELECT @proc = Object_Name(@@PROCID)

		select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

		

		select @step = 2
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - START', GETDATE () END

		--exec [dbo].[create_Map_order]


		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - update ticker for Swaps', GETDATE () END

		select @step = 3
		UPDATE [dbo].[02_Realised_all_details]
			SET [Ticker] = [dbo].[map_dealid_Ticker].[Ticker]
			from
				[dbo].[02_Realised_all_details] inner join [dbo].[map_dealid_Ticker]
				on [dbo].[02_Realised_all_details].[deal] =  [dbo].[map_dealid_Ticker].[dealid]

			/*2022-09-23, MKB+MU: frage: fehlt hier eine where bedingung wie zb "where InstrumentType like '%SWAP% " ???	*/

		select @step = 4
		UPDATE [dbo].[02_Realised_all_details]
			SET [Ticker] = [dbo].[map_dealidupdate].[dealid_new]
			from
				[dbo].[02_Realised_all_details] inner join [dbo].[map_dealidupdate]
				on [dbo].[02_Realised_all_details].[ticker] =  [dbo].[map_dealidupdate].[dealid_old]


		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - set sap_account and stkz_zw1 to null', GETDATE () END
		select @step = 5
		update [dbo].[02_Realised_all_details]
		SET	[SAP_Account] = NULL,
				[StKZ_zw1] = NULL
		where
			[SAP_Account] is not NULL
			or [StKZ_zw1] is not  NULL

		select @step = 6
		EXEC [dbo].[EnrichAccounts]

		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - set empty loss_accounts and VAT_groups', GETDATE () END
		select @step = 7
		UPDATE	[dbo].[02_Realised_all_details]
			SET	[SAP_Account] = [dbo].map_accounts.[Account_Loss],
					[StKZ_zw1] = [dbo].[map_accounts].[VAT_Group]
			from
				[dbo].[02_Realised_all_details] inner join [dbo].[map_accounts]
				on [dbo].[02_Realised_all_details].[UpdateKonten] = [dbo].[map_accounts].[updateKonten]
			where
				[dbo].[map_accounts].Account_Loss = 'n/a'

		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - update accounts for certain cashflow types', GETDATE () END
		select @step = 815
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - update profit/loss-accounts and VAT-group', GETDATE () END
		UPDATE dbo.[02_Realised_all_details]
			SET
				SAP_Account = CASE
								WHEN round([02_Realised_all_details].Realised, 10) > 0 THEN map_accounts.Account_Profit
								WHEN round([02_Realised_all_details].Realised, 10) < 0 THEN map_accounts.Account_Loss
								WHEN round([volume_new], 10) < 0 THEN [dbo].map_accounts.[Account_Loss]
								ELSE [dbo].map_accounts.[Account_Profit]
							END
				,StKZ_zw1 = map_accounts.VAT_Group
			FROM
				dbo.[02_Realised_all_details] INNER JOIN dbo.map_accounts
				ON [02_Realised_all_details].UpdateKonten = map_accounts.updateKonten

		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - update close out: COAL-FWD', GETDATE () END
		select @step = 17
		UPDATE [dbo].[02_Realised_all_details]
			SET SAP_Account = case when left(SAP_Account,1) ='4' then '4006165' else '6010165' end
			WHERE
				[Delivery Vessel Name] in ('Circle Out','Close Out')
				and InstrumentType in ('COAL-FWD')

		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - update close out: BIOFUEL-FWD', GETDATE () END
		select @step = 18
		UPDATE [dbo].[02_Realised_all_details]
			SET SAP_Account = case when left(SAP_Account,1) ='4' then '4006035' else '6010077' end
			WHERE
				[Delivery Vessel Name] in ('Circle Out','Close Out')
				and InstrumentType in ('BIOFUEL-FWD')

		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - update from map_ExtLegal_Account', GETDATE () END
		select @step = 19
		UPDATE [dbo].[02_Realised_all_details]
			SET [SAP_Account] = dbo.map_ExtLegal_Account.Account_new
			from
				[dbo].[02_Realised_all_details] inner JOIN [dbo].[map_ExtLegal_Account]
				ON
				(
					[dbo].[02_Realised_all_details].[SAP_Account] = [dbo].[map_ExtLegal_Account].[Account_old]
					AND [dbo].[02_Realised_all_details].[InstrumentType] = [dbo].[map_ExtLegal_Account].[InstrumentType]
					AND [dbo].[02_Realised_all_details].[ExternalBusinessUnit] = [dbo].[map_ExtLegal_Account].[ExtBunit]
				)

		/* this is to alter the VAT group from physical power to other for deals with negative prices. These need to be treated as "disposal" rather than physical delivery*/
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - update Steuer 1', GETDATE () END
		select @step = 20
		UPDATE [dbo].[02_Realised_all_details]
			SET [StKZ_zw1] = 'Physisch_Strom_Fee'
			where
				stkz_zw1 = 'physisch_strom'
				and
				(
					(
						round(Realised,10) < 0
						And [action] = 'sell'
					)
					or
					(
						round([Realised],10) > 0
						And [action] = 'buy'
					)
				)

		select @step = 21
		IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME like '%02g_Steuer_zw1_tbl%'))
		BEGIN
			drop table dbo.[02g_Steuer_zw1_tbl]
		END

		select @step = 22
		select * into dbo.[02g_Steuer_zw1_tbl]	from [dbo].[02g_Steuer_zw1]

		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - update Steuer2', GETDATE () END
		select @step = 23
		UPDATE [dbo].[02_Realised_all_details]
			SET [StKZ] =	case when round(realised,10) > 0  then [dbo].[02g_Steuer_zw1_tbl].[Sells] else
											case when round(realised,10) < 0  then [dbo].[02g_Steuer_zw1_tbl].[Buys] else
												case when round(volume_new,10) > 0 then [dbo].[02g_Steuer_zw1_tbl].[Sells] else [dbo].[02g_Steuer_zw1_tbl].[Buys] end
											end
										end
			from
				[dbo].[02_Realised_all_details] LEFT JOIN [dbo].[02g_Steuer_zw1_tbl]
				ON			[dbo].[02_Realised_all_details].[StKZ_zw1] = [dbo].[02g_Steuer_zw1_tbl].[VAT_Group]
						AND [dbo].[02_Realised_all_details].VAT_CountryCode = [dbo].[02g_Steuer_zw1_tbl].countrycode
						AND [dbo].[02_Realised_all_details].[group] = [dbo].[02g_Steuer_zw1_tbl].ctpygroup
			where
				[dbo].[02_Realised_all_details].InternalLegalEntity = 'RWEST DE - PE'

		select @step = 24
		IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME like '%02g_Steuer_zw1_tbl%'))
		BEGIN
			drop table dbo.[02g_Steuer_zw1_tbl]
		END

		select @step = 25
		select * into dbo.[02g_Steuer_zw1_tbl]	from [dbo].[02g_Steuer_zw1]

		UPDATE [dbo].[02_Realised_all_details]
			SET [StKZ] =	case when round([dbo].[02_Realised_all_details].[realised],10) > 0  then [dbo].[02g_Steuer_zw1_tbl].[Sells] else
											case when round([dbo].[02_Realised_all_details].[realised],10) < 0  then [dbo].[02g_Steuer_zw1_tbl].[Buys] else
												case when round([dbo].[02_Realised_all_details].[volume_new],10) > 0 then [dbo].[02g_Steuer_zw1_tbl].[Sells] else [dbo].[02g_Steuer_zw1_tbl].[Buys] end
											end
										end
			from
				[dbo].[02_Realised_all_details] LEFT JOIN [dbo].[02g_Steuer_zw1_tbl]
				ON		[dbo].[02_Realised_all_details].[StKZ_zw1] = [dbo].[02g_Steuer_zw1_tbl].[VAT_Group]
					AND [dbo].[02_Realised_all_details].VAT_CountryCode = [dbo].[02g_Steuer_zw1_tbl].countrycode
					AND [dbo].[02_Realised_all_details].[group] = [dbo].[02g_Steuer_zw1_tbl].ctpygroup
			where
				[dbo].[02_Realised_all_details].InternalLegalEntity <> 'RWEST DE - PE'


		--- change requestes by Vincenzo Profeta: Update the D6 entries of the following External BUs to A9 --- 08.07.2024 PG
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - update StKZ D6', GETDATE () END
		select @step = 251

		UPDATE [dbo].[02_Realised_all_details]
			SET [StKZ] = 'A9'
			from [dbo].[02_Realised_all_details]
			where ExternalBusinessUnit IN ('BROSE FAHRZEUGTEILE BU','FREUDENBERG PERFORMANCE BU', 'NITTO ADVANCED FILM%', 'ROCHLING BU', 'TELEFONICA GERMANY BU', 'THYSSENKRUPP BU','ZOTT BU','KS NL28 BU','SASOL GERMANY BU')
			AND StKZ = 'D6'

		select @step = 26
		IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME like '%02g_Steuer_zw1_tbl%'))
		BEGIN
			drop table dbo.[02g_Steuer_zw1_tbl]
		END

		-- DELETE WHOLE BLOCK AFTER 2025-04-23, IF NOT REACTIVED UNTILL THEN.
		-- 2024-04-23 MK: Commented because of account assignment requirement by Anna-Lena Maas.
		--if @LogInfo >= 1 BEGIN insert into [dbo].[Logfile] select @proc + ' - update exchanged traded', GETDATE () END
		--select @step = 27
		--IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME like '%temp_update_account%'))
		--BEGIN
		--	drop table dbo.[temp_update_account]
		--END

		--CREATE TABLE [dbo].[temp_update_account]
		--(
		--	[recon_group] [varchar](100) NULL
		--	,[ctpygroup] [varchar](100) NULL
		--	,[OrderNo] [varchar](100) NULL
		--	,[InstrumentType] [varchar](100) NULL
		--	,[ExternalBusinessUnit] [varchar](100) NULL
		--	,[Ticker] [varchar](100) NULL
		--	,[DeliveryMonth] [varchar](100) NULL
		--	,[RealisedBase] [numeric](20, 2) NULL
		--	,[MinSAPAccount] [varchar](100) NULL
		--	,[MaxSAPAccount] [varchar](100) NULL
		--	,[SAPAccountNEW] [varchar](100) NULL
		--	,[MinVAT] [varchar](100) NULL
		--	,[MaxVAT] [varchar](100) NULL
		--	,[VATNEW] [varchar](100) NULL
		--	,[posneg] [varchar](100) NULL,
		--) ON [PRIMARY]

		--SET ANSI_PADDING OFF /*???*/
		--select @step = 28
		--insert into [dbo].[temp_update_account]
		--(
		--		[recon_group]
		--	,[ctpygroup]
		--	,[OrderNo]
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
		--	,posneg
		--)
		--select
		--	a.recon_group
		--	,r.ctpygroup
		--	,r.OrderNo
		--	,r.InstrumentType
		--	,r.externalbusinessunit
		--	,r.ticker
		--	,r.DeliveryMonth
		--	,sum(r.Realisedbase) as realised_eur
		--	,min(r.SAP_Account) as minAccount
		--	,max(r.sap_account) as maxAccount
		--	,case when sum(r.realised) < 0 then max(r.SAP_Account) else min(r.SAP_Account) end as AccountNEW
		--	,min(r.stkz) as minVAT
		--	,max(r.stkz) as maxVAT
		--	,case when sum(r.realised) < 0 then max(r.stkz) else min(r.stkz) end as VATNEW
		--	,iif(r.realised < 0,'neg','pos') as posneg
		--from
		--	dbo.[02_Realised_all_details] r
		--	inner join dbo.map_ReconGroupAccount a on r.SAP_Account=a.Account
		--where
		--	a.recon_group in ('exchanges')
		--group by
		--	a.recon_group
		--	,r.ctpygroup
		--	,r.orderno
		--	,r.InstrumentType
		--	,r.externalbusinessunit
		--	,r.ticker
		--	,r.DeliveryMonth
		--	,r.currency
		--	,iif(r.realised < 0,'neg','pos')

		--select @step = 29
		--update dbo.[02_Realised_all_details]
		--	set SAP_Account = temp.sapAccountNew,
		--			stkz = temp.vatnew
		--	from
		--		dbo.[02_Realised_all_details] inner join dbo.[temp_update_account] temp
		--		on		dbo.[02_Realised_all_details].orderno = temp.OrderNo
		--			AND dbo.[02_Realised_all_details].InstrumentType = temp.InstrumentType
		--			AND dbo.[02_Realised_all_details].ExternalBusinessUnit = temp.ExternalBusinessUnit
		--			AND dbo.[02_Realised_all_details].ticker = temp.ticker
		--			AND dbo.[02_Realised_all_details].deliverymonth = temp.DeliveryMonth
		--			AND dbo.[02_Realised_all_details].ctpygroup = temp.ctpygroup
		--			AND iif(dbo.[02_Realised_all_details].realised<0,'neg','pos')=temp.posneg

		--select @step = 30
		--IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME like 'temp_update_account'))
		--BEGIN
		--	drop table dbo.[temp_update_account]
		--END

		select @step = 31
		select @counter = count(1) from  [dbo].[02_Realised_all_details] where [SAP_Account] is NULL
		if @LogInfo >= 1 BEGIN insert into [dbo].[Logfile] select @proc + ' - records where SAP_ACCOUNT is NULL: ' + convert(varchar(12),@counter), GETDATE () END


		select @step = 32
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - Run GASUpdateVAT procedure to set gas delivery VAT to 7%', GETDATE () END
		EXEC [dbo].[GASUpdateVAT]

		if @LogInfo >= 1 BEGIN insert into [dbo].[Logfile] select @proc + ' - FINISHED', GETDATE () END

END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
		BEGIN insert into [dbo].[Logfile] select @proc + ' - FAILED', GETDATE () END
	END CATCH

GO

