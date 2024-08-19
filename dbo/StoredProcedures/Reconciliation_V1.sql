















/*=================================================================================================================
	author:		mbe
	created:	ancient times
	purpose:	procedure steps depending on the given @details parameter different 
-----------------------------------------------------------------------------------------------------------------
	Changes:
	2024-01-09, PG/mkb, step 0, restricted the allowance to run the procedure for all
	2024-01-11, ?,			step 0, restricted the allowance to run the procedure for YK 
	2024-01-12, mkb,		step 0, restricted the allowance to run the procedure for VP
=================================================================================================================*/


CREATE PROCEDURE [dbo].[Reconciliation_V1]
	@details varchar(10) AS

BEGIN TRY

		DECLARE @LogInfo Integer
		DECLARE @proc nvarchar(40)
		DECLARE @step Integer
		DECLARE @COB date 
		
		DECLARE @Log_Entry_Text as nvarchar (200)
		DECLARE @ExceptionalUserRunAllowance as integer
		DECLARE @weekday integer
		

		
		/*restriction start*/			 
		select @step = 0
		/*A Group of special users may run the procedure just after 18:00 UK time on weekdays and througout the whole weekend without timely constraint. (request SH, 2024-01-09*/
		SELECT @weekday  = DATEPART(dw, GETDATE())
		SELECT @ExceptionalUserRunAllowance = CASE WHEN (format(GETDATE(),'HH:mm:ss')>'17:00') OR (@Weekday in (1,7))	THEN 1 ELSE 0 END
		
		IF NOT ( 
		(
			-- Data team users with right to run recon anytime
			user_name () = 'ENERGY\R884862'  /*MBE*/
			OR user_name () = 'ENERGY\R880382'  /*MKB*/			
			OR user_name () = 'ENERGY\UI856115' /*SH*/
			OR user_name () = 'ENERGY\UI788089' /*MU*/
			OR user_name () = 'ENERGY\UI555471' /*PG*/						
			OR user_name () = 'ENERGY\UI626985' /*MK*/
			OR user_name () = 'ENERGY\UI919293' /*SU*/
			OR user_name () = 'dbo' /*R2D2*/
		) OR (
			(
				-- Exceptional user group, who can run, when @ExceptionalUserRunAllowance = 1
				user_name () ='ENERGY\R920983'			/*April Xin */
				OR user_name () ='ENERGY\UI567004'	/*Yasemin Koser */
				OR user_name () = 'ENERGY\R884018'  /*VP*/
			) AND @ExceptionalUserRunAllowance = 1
		)
		)
		BEGIN
			SET @Log_Entry_Text ='Skipped reconciliation run by ' + user_name ()
			EXEC dbo.Write_Log 'Warning', @Log_Entry_Text, @proc, NULL, NULL, @step, 1 , NULL
			GOTO NoFurtherAction 
		END
		/*restriction end*/			 

		select @COB = [AsOfDate_EOM] from dbo.AsOfDate

		select @step = 1
		select @proc =  Object_Name(@@PROCID)

		select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

		

		select @step=2
		if @LogInfo >= 1  
		BEGIN insert into [dbo].[Logfile] select @proc + ' - START', GETDATE () 		END

		--exec [dbo].[create_Map_order]

		BEGIN insert into [dbo].[Logfile] select @proc + ' - realised recon processed details: ' + @details , GETDATE () 		END
		BEGIN insert into [dbo].[Logfile] select @proc + ' - delete from Recon & Recon_zw1', GETDATE () 		END

		select @step=3
		truncate table [dbo].[Recon]

		select @step=4
		if @details = 'ALL'	BEGIN truncate table [dbo].[Recon_zw1] END
		if @details = 'SAP'	BEGIN delete FROM [dbo].[Recon_zw1] where [Source] in ('sap_blank','adj') END
		if @details = 'ADJ'	BEGIN delete from [dbo].[Recon_zw1] where [dbo].[Recon_zw1].[Source] = 'adj' END

		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - fill table Recon_zw1', GETDATE () END
	
		select @step=5
		if @details = 'ALL' 
			BEGIN
				EXEC [dbo].[InsertEndurintoRecon_zw1]
			END

		Select @step=6
		if @details in ('ALL','SAP')
		BEGIN			
			EXEC [dbo].[InsertSAPintoRecon_zw1]
		END

		Select @step=7
		EXEC [dbo].[InsertAdjustmentsintoRecon_zw1]

		Select @step=8
		EXEC [dbo].[UpdateDealID]

		Select @step=9
		if @details = 'ALL'
		BEGIN
			select @step = 10
			EXEC [dbo].[InsertIntoRecon] 

			select @step = 11
			EXEC [dbo].[UpdateVAT]
			
			select @step = 12
			EXEC [dbo].[UpdateEndurAccounts]
		END

	/*START: temporäres update der Steuerkennz. für den Zeitraum 01.07.2020 bis 31.12.2020 gemäß mail Peter Weber vom 27.07.2020*/
	/*UPDATE 01/2021: bleibt aktiv bis auf Widerruf von PW/HGS */
		select @step =15
		EXEC [dbo].[COVIDUpdateVAT]
	/*ENDE: temporäres update der Steuerkennz. */

		Select @step=16
		EXEC [dbo].[UpdateIdentifier]

		Select @step=17
		update  recon_zw1 
			set ReconGroup = 'TC' 
			where 
				InstrumentType in ('TC-OPT-CALL-P','TC-OPT-PUT-P') 
				and ExternalBusinessUnit in ('SHANDONG SHIPPING HK HOLDINGS BU', 'CAPE AMBER BU','CAPE EMERALD BU')

		Select @step=18		
		if @details = 'ALL'
		BEGIN
			Select @step=19
			if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - delete from Recon', GETDATE () END
			select @step = 16
			truncate table [dbo].[Recon]
		END
	
		Select @step=20
		EXEC [dbo].[InsertIntoRecon]

		Select @step=21		
		update dbo.recon
			set recon.Portfolio = [00_map_order].MaxvonPortfolio
			from
				dbo.recon
				inner join dbo.[00_map_order] on recon.[Portfolio_ID] = [00_map_order].[MaxvonPortfolioID]
			where
				recon.Portfolio is null OR recon.Portfolio = ''

		Select @step=22
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - fill tables for export: RiskRecon_RealisedOverview_tbl', GETDATE () END


		Select @step=23
		truncate table  [dbo].[RiskRecon_RealisedOverview_tbl] 

		Select @step=24
		INSERT INTO [dbo].[RiskRecon_RealisedOverview_tbl]
		(
			 [internalLegalEntity]
			,[Desk]
			,[Subdesk]
			,[RevRecSubdesk]
			,[ReconGroup]
			,[EUR_Endur]
			,[EUR_SAP]
			,[EUR_Adj]
			,[diff_EUR]
			,[DeskCCY_Endur]
			,[DeskCCY_SAPint]
			,[DeskCCY_Adj]
			,[diff_DeskCCY]
			,[EUR_SAP_conv]
		)
		SELECT 
			internalLegalEntity
			,Desk	
			,Subdesk	
			,RevRecSubdesk
			,ReconGroup	
			,sum(realised_EUR_Endur) 
			,sum(realised_EUR_SAP)
			,sum(realised_EUR_adj)
			,sum(diff_realised_EUR) 
			,sum(realised_DeskCCY_Endur) 
			,sum(realised_DeskCCY_SAP)
			,sum(realised_DeskCCY_adj) 
			,sum(diff_realised_DeskCCY) 
			,sum(realised_eur_sap_conv) 
		from  
			dbo.recon
		where 
			recongroup not in ('prüfen','MtM') 
		group by 
			internalLegalEntity
			,Desk	 
			,Subdesk
			,RevRecSubdesk
			,ReconGroup	 	

		
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - fill tables for export: RiskRecon_RealisedOverview_Adj_tbl', GETDATE () END
		Select @step=25
		truncate table  dbo.[RiskRecon_RealisedOverview_Adj_tbl]

		Select @step=26		
		INSERT INTO [dbo].[RiskRecon_RealisedOverview_Adj_tbl]
		(
	   [LegalEntity]
	  ,[Desk]
      ,[Subdesk]
	  ,[RevRecSubdesk]
      ,[ReconGroup]
      ,[Category]
	  ,[Internal_Portfolio_ID] --added to be able to correctly map RevRec-Subdesk later / SH 19/02/2024
      ,[Comment]
      ,[Currency]
      ,[Quantity]
      ,[Realised_CCY]
      ,[Realised_DeskCCY]
      ,[Realised_EUR]
		)
		SELECT 
			 LegalEntity
			,Desk
			,Subdesk
			,RevRecSubDesk
			,ReconGroup
			,Internal_Portfolio_ID
			,Category
			,Comment
			,Adjustments.Currency
			,sum(Quantity)
			,round(sum(Realised_CCY),2) 
			,round(sum(Realised_CCY/r.RateRisk*r2.RateRisk),2) 
			,round(sum(Realised_CCY/r.RateRisk),2) 
		from 
			dbo.adjustments 
			Left Join dbo.[00_map_order] as d ON dbo.adjustments.orderno = d.orderno
			left join dbo.FXRates as r on dbo.Adjustments.Currency = r.Currency
			left join dbo.fxrates as r2 on d.SubDeskCCY = r2.Currency 
		where 
			Valid_From <= @COB
			AND valid_to >=@COB
		group by 
			LegalEntity
			,Desk
			,Subdesk
			,RevRecSubDesk
			,ReconGroup
			,Internal_Portfolio_ID
			,Category
			,Adjustments.Currency
			,Comment
		having 
			abs(sum(Realised_CCY))>1 

		--Update function to catch all RevRec-Desk infos which might not have been correctly allocated via orderno via the above table fill
		
		UPDATE [dbo].[RiskRecon_RealisedOverview_Adj_tbl]
			SET [dbo].[RiskRecon_RealisedOverview_Adj_tbl].[RevRecSubdesk] = dbo.[00_map_order_PortfolioID].RevRecSubDesk
			from [dbo].[RiskRecon_RealisedOverview_Adj_tbl] 
			left join dbo.[00_map_order_PortfolioID] on
			dbo.RiskRecon_RealisedOverview_Adj_tbl.Internal_Portfolio_ID = dbo.[00_map_order_PortfolioID].PortfolioID
			where [dbo].[RiskRecon_RealisedOverview_Adj_tbl].[Internal_Portfolio_ID] is not null
	
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select  @proc + ' - fill tables for export: Recon_diff_tbl', GETDATE () END
		Select @step=30
		truncate table dbo.recon_diff_tbl
	
		Select @step=31
		INSERT INTO [dbo].[Recon_Diff_tbl]
    (
			 [InternalLegalEntity]
			,[Desk]
			,[Subdesk]
			,[RevRecSubdesk]
			,[ReconGroup]
			,[OrderNo]
			,[DeliveryMonth]
			,[DealID_Recon]
			,[Account]
			,[ccy]
			,[Portfolio]
			,[Portfolio_ID]
			,[CounterpartyGroup]
			,[InstrumentType]
			,[CashflowType]
			,[ProjIndexGroup]
			,[CurveName]
			,[ExternalLegal]
			,[ExternalBusinessUnit]
			,[ExternalPortfolio]
			,[DocumentNumber]
			,[Reference]
			,[partner]
			,[RefFeld3]
			,[TradeDate]
			,[EventDate]
			,[SAP_DocumentNumber]
			,[Volume_Endur]
			,[Volume_SAP]
			,[Volume_Adj]
			,[UOM_Endur]
			,[UOM_SAP]
			,[realised_ccy_Endur]
			,[realised_ccy_SAP]
			,[realised_ccy_adj]
			,[realised_EUR_Endur]
			,[realised_EUR_SAP]
			,[realised_EUR_adj]
			,[Account_Endur]
			,[Account_SAP]
			,[Diff_Volume]
			,[Diff_CCY]
			,[Diff_DeskCCY]
			,[Diff_EUR]
			,[abs_diff_EUR]
			,[PaymentDateInfo]
			,[AccrualPostingText]
			,[CountryCode]
			,[StKZ]
			,[BS_GUV]
			,[Konto_GUV]
			,[BS_Bilanz]
			,[Konto_Bilanz]
			,[UstID]
			,[VAT_CountryCode]
			,[Identifier]
		)
		select 
			dbo.recon_diff.* 
		from 
			dbo.recon_diff 
		where 
			InternalLegalEntity in ('RWEST DE', 'TS DE', 'RWEST AP' ,'RWEST CZ') or desk = 'COMMODITY SOLUTIONS'

	 	/*change VAT for ReDispatch to D6 MBE / DS (27.04.2021), adding buy to X6 (30.04.2021, DS)*/
		Select @step=32
		update dbo.recon_diff_tbl set StKZ = 'D6' where Portfolio like '%REDIS%' and StKZ in ('A1','A9')

		Select @step=33
		update dbo.recon_diff_tbl set StKZ = 'X6' where Portfolio like '%REDIS%' and StKZ in ('VN')

		-- ===============================================================================================================
		-- ===============================================================================================================

		BEGIN insert into [dbo].[Logfile] select @proc + ' - Create Recon UK / DE Tables ( All -- Diff -- Adjustments )', GETDATE () END

		-- ===============================================================================================================
		-- ===============================================================================================================
		-- Recon UK ALL
		-- ===============================================================================================================
		-- ===============================================================================================================


		IF (
				EXISTS (
					SELECT *
					FROM INFORMATION_SCHEMA.TABLES
					WHERE [TABLE_SCHEMA] = 'dbo'
						AND [TABLE_NAME] = 'Recon_UK_ALL'
					)
				)
		BEGIN
			DROP TABLE dbo.Recon_UK_ALL
		END

		SELECT [InternalLegalEntity]
			,r.[Desk]
			,iif(r.RevRecSubDesk = '', r.SubDesk,r.RevRecSubDesk) as SubDesk
			,o.book
			,r.[ReconGroup] + CASE 
				WHEN account IN (
						'6010149'
						,'4006149'
						)
					THEN ' - Comm Fee'
				ELSE ''
				END AS ReconGroup
			,r.[OrderNo]
			,[DeliveryMonth]
			,[DealID_Recon]
			,[Account]
			,[ccy]
			,[Portfolio]
			,[CounterpartyGroup]
			,[InstrumentType]
			,[CashflowType]
			,[ProjIndexGroup]
			,[CurveName]
			,[ExternalLegal]
			,[ExternalBusinessUnit]
			,[ExternalPortfolio]
			,[DocumentNumber]
			,[Reference]
			,[partner]
			,[TradeDate]
			,[EventDate]
			,[SAP_DocumentNumber]
			,[Volume_Endur]
			,[Volume_SAP]
			,[Volume_Adj]
			,[UOM_Endur]
			,[UOM_SAP]
			,[realised_ccy_Endur]
			,[realised_ccy_SAP]
			,[realised_ccy_adj]
			,[Deskccy]
			,[realised_Deskccy_Endur]
			,[realised_Deskccy_SAP]
			,[realised_Deskccy_adj]
			,[realised_EUR_Endur]
			,[realised_EUR_SAP]
			,[realised_EUR_adj]
			,[Account_Endur]
			,[Account_SAP]
			,Diff_Volume
			,Diff_Realised_CCY
			,Diff_Realised_DeskCCY
			,Diff_Realised_EUR
			,[Identifier]
		INTO dbo.Recon_UK_ALL
		FROM recon r
		INNER JOIN dbo.[00_map_order] o ON r.orderno = o.orderno
		WHERE r.internallegalentity IN (
				'RWEST UK'
				,'TS UK'
				,'RWESTP'
				,'RWEST AP'
				,'RWEST INDIA'
				,'RWEST SH'
				,'RWEST Indonesia'
				,'RWEST Japan'
				,'RWEST ZA'
				)
		-- ===============================================================================================================
		-- ===============================================================================================================
		-- Recon UK Adjustments
		-- ===============================================================================================================
		-- ===============================================================================================================

		IF (
				EXISTS (
					SELECT *
					FROM INFORMATION_SCHEMA.TABLES
					WHERE [TABLE_SCHEMA] = 'dbo'
						AND [TABLE_NAME] = 'Recon_UK_Adjustments'
					)
				)
		BEGIN
			DROP TABLE dbo.Recon_UK_Adjustments
		END

		SELECT [dbo].[00_map_order].LegalEntity
			,[dbo].[00_map_order].Desk
			,iif([dbo].[00_map_order].RevRecSubDesk = '', [dbo].[00_map_order].SubDesk,[dbo].[00_map_order].RevRecSubDesk) as SubDesk 
			,[dbo].[00_map_order].Book
			,[Adjustments].ReconGroup
			,[Adjustments].OrderNo
			,[Adjustments].DeliveryMonth
			,[Adjustments].DealID
			,[Adjustments].Account
			,[Adjustments].Currency
			,[Adjustments].Quantity
			,[Adjustments].Realised_CCY
			,[Adjustments].Realised_CCY AS 'Realised_CCY_2'
			,
			/*[Adjustments].Realised_EUR,*/
			[Adjustments].Category
			,[Adjustments].Comment
			,[Adjustments].Valid_From
			,[Adjustments].Valid_To
			,[Adjustments].[User]
			,[Adjustments].[timestamp]
		INTO dbo.Recon_UK_Adjustments
		FROM [Adjustments]
		INNER JOIN [dbo].[00_map_order] ON [Adjustments].OrderNo = [dbo].[00_map_order].OrderNo
		WHERE (
				[dbo].[00_map_order].LegalEntity LIKE '%UK%'
				OR [dbo].[00_map_order].LegalEntity LIKE '%ZA%'
				)
			AND [Adjustments].Valid_From <= (
				SELECT asofdate_eom
				FROM asofdate
				)
			AND [Adjustments].Valid_To >= (
				SELECT asofdate_eom
				FROM asofdate
				)
		-- ===============================================================================================================
		-- ===============================================================================================================
		-- Recon UK DIFF
		-- ===============================================================================================================
		-- ===============================================================================================================
		IF (
				EXISTS (
					SELECT *
					FROM INFORMATION_SCHEMA.TABLES
					WHERE [TABLE_SCHEMA] = 'dbo'
						AND [TABLE_NAME] = 'Recon_UK_Diff'
					)
				)
		BEGIN
			DROP TABLE dbo.Recon_UK_Diff
		END

		SELECT CASE 
				WHEN deliverymonth IN (
						'2017/01'
						,'2017/02'
						,'2017/03'
						,'2017/04'
						,'2017/05'
						,'2017/06'
						,'2017/07'
						,'2017/08'
						,'2017/09'
						,'2017/10'
						,'2017/11'
						,'2017/12'
						)
					THEN 'PriorYear'
				ELSE CASE 
						WHEN deliverymonth IN (
								'2018/01'
								,'2018/02'
								,'2018/03'
								,'2018/04'
								,'2018/05'
								,'2018/06'
								,'2018/07'
								,'2018/08'
								,'2018/09'
								,'2018/10'
								,'2018/11'
								,'2018/12'
								)
							THEN deliverymonth
						ELSE 'other'
						END
				END AS DelMonth
			,[InternalLegalEntity]
			,r.[Desk]
			,iif(r.RevRecSubDesk = '', r.SubDesk,r.RevRecSubDesk) as SubDesk 
			,o.book
			,ReconGroup
			,r.[OrderNo]
			,[DeliveryMonth]
			,[DealID_Recon]
			,[Account]
			,[ccy]
			,[Portfolio]
			,[CounterpartyGroup]
			,[InstrumentType]
			,[CashflowType]
			,[ProjIndexGroup]
			,[CurveName]
			,[ExternalLegal]
			,[ExternalBusinessUnit]
			,[ExternalPortfolio]
			,[DocumentNumber]
			,[Reference]
			,[partner]
			,[TradeDate]
			,[EventDate]
			,[SAP_DocumentNumber]
			,[Volume_Endur]
			,[Volume_SAP]
			,[Volume_Adj]
			,[UOM_Endur]
			,[UOM_SAP]
			,[realised_ccy_Endur]
			,[realised_ccy_SAP]
			,[realised_ccy_adj]
			,[Deskccy]
			,[realised_Deskccy_Endur]
			,[realised_Deskccy_SAP]
			,[realised_Deskccy_adj]
			,[realised_EUR_Endur]
			,[realised_EUR_SAP]
			,[realised_EUR_adj]
			,[Account_Endur]
			,[Account_SAP]
			,Diff_Volume
			,Diff_Realised_CCY
			,Diff_Realised_DeskCCY
			,Diff_Realised_EUR
			,abs(Diff_Realised_CCY) AS AbsDiff_CCY
			,[Identifier]
		INTO dbo.Recon_UK_Diff
		FROM recon r
		INNER JOIN dbo.[00_map_order] o ON r.orderno = o.orderno
		WHERE (
				abs(diff_realised_ccy) > 1
				OR abs(diff_volume) > 1
				)
			AND r.internallegalentity IN (
				'RWEST UK'
				,'TS UK'
				,'RWESTP'
				,'RWEST AP'
				,'RWEST SH'
				,'RWEST Indonesia'
				,'RWEST Japan'
				,'RWEST INDIA'
				,'RWEST ZA'
				)
		ORDER BY InternalLegalEntity
			,Desk
			,Subdesk
			,OrderNo
			,dealid_recon
	


		-- ===============================================================================================================
		-- ===============================================================================================================
		-- Recon DE ALL
		-- ===============================================================================================================
		-- ===============================================================================================================

		IF (
				EXISTS (
					SELECT *
					FROM INFORMATION_SCHEMA.TABLES
					WHERE [TABLE_SCHEMA] = 'dbo'
						AND [TABLE_NAME] = 'Recon_DE_ALL'
					)
				)
		BEGIN
			DROP TABLE dbo.Recon_DE_ALL
		END

		-- Recon DE ALL
		SELECT [InternalLegalEntity]
			,r.[Desk]
			,iif(r.RevRecSubDesk = '', r.SubDesk,r.RevRecSubDesk) as SubDesk 
			,o.book
			,r.[ReconGroup] + CASE 
				WHEN account IN (
						'6010149'
						,'4006149'
						)
					THEN ' - Comm Fee'
				ELSE ''
				END AS ReconGroup
			,r.[OrderNo]
			,[DeliveryMonth]
			,[DealID_Recon]
			,[Account]
			,[ccy]
			,[Portfolio]
			,[CounterpartyGroup]
			,[InstrumentType]
			,[CashflowType]
			,[ProjIndexGroup]
			,[CurveName]
			,[ExternalLegal]
			,[ExternalBusinessUnit]
			,[ExternalPortfolio]
			,[DocumentNumber]
			,[Reference]
			,[partner]
			,[TradeDate]
			,[EventDate]
			,[SAP_DocumentNumber]
			,[Volume_Endur]
			,[Volume_SAP]
			,[Volume_Adj]
			,[UOM_Endur]
			,[UOM_SAP]
			,[realised_ccy_Endur]
			,[realised_ccy_SAP]
			,[realised_ccy_adj]
			,[Deskccy]
			,[realised_Deskccy_Endur]
			,[realised_Deskccy_SAP]
			,[realised_Deskccy_adj]
			,[realised_EUR_Endur]
			,[realised_EUR_SAP]
			,[realised_EUR_adj]
			,[Account_Endur]
			,[Account_SAP]
			,Diff_Volume
			,Diff_Realised_CCY
			,Diff_Realised_DeskCCY
			,Diff_Realised_EUR
			,[Identifier]
		INTO dbo.Recon_DE_ALL
		FROM recon r
		INNER JOIN dbo.[00_map_order] o ON r.orderno = o.orderno
		WHERE r.internallegalentity IN (
				'RWEST CZ'
				,'RWEST DE'
				)
			OR Portfolio IN (
				'RGM_D_PM_STORAGE_UK'
				,'RGM_D_PM_STORAGE_UK_EPM'
				)

		-- ===============================================================================================================
		-- ===============================================================================================================
		-- Recon DE Adjustments
		-- ===============================================================================================================
		-- ===============================================================================================================

		IF (
				EXISTS (
					SELECT *
					FROM INFORMATION_SCHEMA.TABLES
					WHERE [TABLE_SCHEMA] = 'dbo'
						AND [TABLE_NAME] = 'Recon_DE_Adjustments'
					)
				)
		BEGIN
			DROP TABLE dbo.Recon_DE_Adjustments
		END

		-- Recon DE Adjustments
		SELECT [dbo].[00_map_order].LegalEntity
			,[dbo].[00_map_order].Desk
			,iif([dbo].[00_map_order].RevRecSubDesk = '', [dbo].[00_map_order].SubDesk,[dbo].[00_map_order].RevRecSubDesk) as SubDesk
			,[dbo].[00_map_order].Book
			,[Adjustments].ReconGroup
			,[Adjustments].OrderNo
			,[Adjustments].DeliveryMonth
			,[Adjustments].DealID
			,[Adjustments].Account
			,[Adjustments].Currency
			,[Adjustments].Quantity
			,[Adjustments].Realised_CCY
			,[Adjustments].Realised_CCY AS 'Realised_CCY_2'
			,/*[Adjustments].Realised_EUR,*/
			[Adjustments].Category
			,[Adjustments].Comment
			,[Adjustments].Valid_From
			,[Adjustments].Valid_To
			,[Adjustments].[User]
			,[Adjustments].[timestamp]
		INTO dbo.Recon_DE_Adjustments
		FROM [Adjustments]
		INNER JOIN [dbo].[00_map_order] ON [Adjustments].OrderNo = [dbo].[00_map_order].OrderNo
		WHERE (
				[dbo].[00_map_order].LegalEntity LIKE '%DE%'
				OR [dbo].[00_map_order].LegalEntity LIKE '%CZ%'
				OR [dbo].[00_map_order].LegalEntity LIKE '%UK%' /*Added for april since CAO Gas has 2 UK portfolios*/
				)
			AND [Adjustments].Valid_From <= (
				SELECT asofdate_eom
				FROM asofdate
				)
			AND [Adjustments].Valid_To >= (
				SELECT asofdate_eom
				FROM asofdate
				)

		
		-- ===============================================================================================================
		-- ===============================================================================================================
		-- Recon DE DIFF
		-- ===============================================================================================================
		-- ===============================================================================================================

		IF (
				EXISTS (
					SELECT *
					FROM INFORMATION_SCHEMA.TABLES
					WHERE [TABLE_SCHEMA] = 'dbo'
						AND [TABLE_NAME] = 'Recon_DE_Diff'
					)
				)
		BEGIN
			DROP TABLE dbo.Recon_DE_Diff
		END

		SELECT CASE 
				WHEN deliverymonth IN (
						'2017/01'
						,'2017/02'
						,'2017/03'
						,'2017/04'
						,'2017/05'
						,'2017/06'
						,'2017/07'
						,'2017/08'
						,'2017/09'
						,'2017/10'
						,'2017/11'
						,'2017/12'
						)
					THEN 'PriorYear'
				ELSE CASE 
						WHEN deliverymonth IN (
								'2018/01'
								,'2018/02'
								,'2018/03'
								,'2018/04'
								,'2018/05'
								,'2018/06'
								,'2018/07'
								,'2018/08'
								,'2018/09'
								,'2018/10'
								,'2018/11'
								,'2018/12'
								)
							THEN deliverymonth
						ELSE 'other'
						END
				END AS DelMonth
			,[InternalLegalEntity]
			,r.[Desk]
			,iif(r.RevRecSubDesk = '', r.SubDesk,r.RevRecSubDesk) as SubDesk 
			,o.book
			,ReconGroup
			,r.[OrderNo]
			,[DeliveryMonth]
			,[DealID_Recon]
			,[Account]
			,[ccy]
			,[Portfolio]
			,[CounterpartyGroup]
			,[InstrumentType]
			,[CashflowType]
			,[ProjIndexGroup]
			,[CurveName]
			,[ExternalLegal]
			,[ExternalBusinessUnit]
			,[ExternalPortfolio]
			,[DocumentNumber]
			,[Reference]
			,[partner]
			,[TradeDate]
			,[EventDate]
			,[SAP_DocumentNumber]
			,[Volume_Endur]
			,[Volume_SAP]
			,[Volume_Adj]
			,[UOM_Endur]
			,[UOM_SAP]
			,[realised_ccy_Endur]
			,[realised_ccy_SAP]
			,[realised_ccy_adj]
			,[Deskccy]
			,[realised_Deskccy_Endur]
			,[realised_Deskccy_SAP]
			,[realised_Deskccy_adj]
			,[realised_EUR_Endur]
			,[realised_EUR_SAP]
			,[realised_EUR_adj]
			,[Account_Endur]
			,[Account_SAP]
			,Diff_Volume
			,Diff_Realised_CCY
			,Diff_Realised_DeskCCY
			,Diff_Realised_EUR
			,abs(Diff_Realised_CCY) AS AbsDiff_CCY
			,[Identifier]
		INTO dbo.Recon_DE_Diff
		FROM recon r
		INNER JOIN dbo.[00_map_order] o ON r.orderno = o.orderno
		WHERE (
				abs(diff_realised_ccy) > 1
				OR abs(diff_volume) > 1
				)
			AND (
				r.internallegalentity IN (
					'RWEST DE'
					,'RWEST CZ'
					)
				OR Portfolio IN (
					'RGM_D_PM_STORAGE_UK'
					,'RGM_D_PM_STORAGE_UK_EPM'
					) /*Added for april since CAO Gas has 2 UK portfolios*/
				)
		ORDER BY InternalLegalEntity
			,Desk
			,Subdesk
			,OrderNo
			,[dealid_recon]

		Select @step=34
		if @LogInfo >= 1 BEGIN insert into [dbo].[Logfile] select @proc + ' - FINISHED', GETDATE () END

NoFurtherAction:
/* hier passiert NIX mehr*/

END TRY

	BEGIN CATCH		
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
		BEGIN insert into [dbo].[Logfile] select @proc + ' - FAILED', GETDATE () END
	END CATCH

GO

