














/* =============================================
 Author:		MKB/MBE
 Created: October 2022
 Description:	risk recon procedure for data 
 -----
 updates:
 2022-12-03, step 3+4: changed join between tables "gloririsk" and "map_order" from "inner" to "left outer" join. (mkb)
 2022-12-08, step 3+5: removed not needed joins to dbo.map_order /map_instrument. (mkb)
 2023-02-21, step 4: reactivated (MU/MKB)
 2023-05-03, step3+4: excluded data from FileID 3133 ("Fin_Risk_PnL_GPM_AP_0.csv") as it just contains data for liiquid period from gpm desk , mkb+YK 
 2023-06-02, step5: excluded contra-adjustments for 'GPM DESK' to reflect illiquid correctly in revrec (JS, YK, mkb)
 2024-01-30, step5: Changed Risk ID assignment from "table_RISK_ADJUSTMENTS.ID" to "table_RISK_ADJUSTMENTS.ADJUSTMENT_ID" (MK/MKB)
 2024-04-05, step2: DELETION MEASURMENT BECAUSE ENTRIES CAME AS ADJUSTMENT AND DEAL. DELETING THE DEAL ENTRY SO IT WON'T COME TWICE (MK/MKB)
 2024-04-09, step2: Removed deletion mentioned in line above.

 =============================================*/
CREATE PROCEDURE [dbo].[RiskReconProc]
AS
BEGIN TRY

		DECLARE @LogInfo Integer
		DECLARE @proc nvarchar(40)
		DECLARE @step Integer
		DECLARE @AsOfDate_EOLY date /*End of last year*/
		DECLARE @AsOfDate_BOLY date /*Beginning of last  year*/
		DECLARE @AsOfDate_LastDayOfMonth date /*Last calendar day of the reporting month*/
		DECLARE @AsOfDate_FirstDayOfMonth date /*First calendar day of the reporting month*/
	
		select 
			 @AsOfDate_EOLY = EOMonth(asofdate_eoy) /*End of Last year*/
			,@AsOfDate_BOLY =  DATEADD(yy, DATEDIFF(yy, 0, asofdate_eoy), 0) /*Beginning of Last Year*/
			,@AsOfDate_LastDayOfMonth = EOMonth(AsOfDate_EOM)
			,@AsOfDate_FirstDayOfMonth = DATEADD(DAY,1,EOMONTH(AsOfDate_EOM,-1))
		from 	
			dbo.AsOfDate
		
		select @step = 1
		SELECT @proc = Object_Name(@@PROCID)

		

		BEGIN insert into [dbo].[Logfile] select @proc + ' - START', GETDATE () END

		--exec [dbo].[create_Map_order]

		BEGIN insert into [dbo].[Logfile] select @proc + ' - clear data tables', GETDATE () END
		
		select @step = 2
		truncate table dbo.[riskrecon_zw1]
		truncate table dbo.[riskrecon]

/*=============================================================================================================================================================*/
/*==== INSERT Risk PNL INTO RiskRecon_zw1 =====================================================================================================================*/
/*=============================================================================================================================================================*/


		BEGIN insert into [dbo].[Logfile] select @proc + ' - insert Risk PNL into table RiskRecon_zw1', GETDATE () END
				
		select @step = 3
		INSERT INTO dbo.[riskrecon_zw1] 
		(
			 [Portfolio]
			,[InstrumentType]
			,[DealID]
			,Ticker
			,ExtBunitName
			,[ccy]
			,[risk_mtm_EOM_EUR] /*1*/
			,[risk_mtm_EOM_RepCCY] /*2*/
			,[risk_mtm_EOM_RepEUR] /*3*/
			,[risk_mtm_EOY_EUR] /*4*/
			,[risk_mtm_EOY_RepCCY] /*5*/
			,[risk_mtm_EOY_RepEUR] /*6*/
			,[risk_realised_disc_EUR] /*7*/
			,[risk_realised_disc_RepCCY] /*8*/
			,[risk_realised_disc_RepEUR] /*9*/
			,[risk_realised_undisc_CCY] /*10*/
			,TOTAL_VALUE_PH_IM1_CCY_YTD /*11*/
			,TOTAL_VALUE_PH_BL_CCY_YTD /*12*/
			,REAL_DISC_PH_BL_CCY_YTD/*13*/
			,REAL_DISC_PH_IM1_CCY_YTD/*14*/			
/*added 2022-12-08, mkb*/
			,UNREAL_DISC_PH_IM1_CCY  /*15*/
			,UNREAL_DISC_PH_IM1_CCY_LGBY /*16*/
			,UNREAL_DISC_PH_BL_CCY /*17*/
			,UNREAL_DISC_PH_BL_CCY_LGBY /*18*/
			,UNREAL_DISC_BL_CCY /*19*/
			,UNREAL_DISC_BL_CCY_LGBY/*20*/
			,[source]
		)
		SELECT 
			 [Internal Portfolio Name]
			,[Instrument Type Name]
			,CASE 
				WHEN [Cashflow Settlement Type] IN ('Broker Fee','Broker Commission') 
					THEN [Cashflow Settlement Type] + ' // ' + [Internal Portfolio Name]
				WHEN [Instrument Type Name] in ('LNG-TRANS-P', 'LNG-STOR-P') and [Cashflow Settlement Type] = 'Physical Settlement'  
					and abs(UNREAL_DISC_BL_CCY) + abs(UNREAL_DISC_BL_CCY_LGBY) > 0.01 	and 
					(	DEAL_PDC_END_DATE >= @AsOfDate_FirstDayOfMonth and
						[Trade Deal Number] in (
						select [Trade Deal Number] from GloriRisk
						where [Instrument Type Name] in ('LNG-TRANS-P', 'LNG-STOR-P') and [Cashflow Settlement Type] = 'Physical Settlement' and abs([Realised Discounted (EUR)]) > 0.01 
						)
					or
						DEAL_PDC_END_DATE <= @AsOfDate_EOLY and CASHFLOW_PAYMENT_DATE <= @AsOfDate_LastDayOfMonth
					) /* 2023-03-27 (MU): Logik for Isk and April to have the unrealised part of phys separated in the deallevel tab of LNG RevRec */
					THEN [Trade Deal Number] + '_phys'
				ELSE [Trade Deal Number] 
			 END as DealID
			,CASE WHEN [Trade Instrument Reference Text] = 'not assigned' THEN '' ELSE [Trade Instrument Reference Text] END AS Ticker
			,[Ext Business Unit Name]
			,[Trade Currency]
/*now the metrics*/
			,UNREAL_DISC_BL_CCY as [risk_mtm_EOM_EUR] /*1*/			
			,UNREAL_DISC_PH_IM1_CCY as [risk_mtm_EOM_RepCCY] /*2*/			
			,UNREAL_DISC_PH_BL_CCY as [risk_mtm_EOM_RepEUR] /*3*/			
			,UNREAL_DISC_BL_CCY_LGBY as [risk_mtm_EOY_EUR] /*4*/			
			,UNREAL_DISC_PH_IM1_CCY_LGBY as [risk_mtm_EOY_RepCCY] /*5*/			
			,UNREAL_DISC_PH_BL_CCY_LGBY as [risk_mtm_EOY_RepEUR] /*6*/			

			,CASE WHEN (InstrumentGroup = 'phys' AND [Cashflow Settlement Type] = 'Physical Settlement') 	THEN 0 ELSE REAL_DISC_PH_BL_CCY_YTD END AS [risk_realised_disc_EUR]	/*7*/ 
		    --,REAL_DISC_PH_BL_CCY_YTD	AS [risk_realised_disc_EUR]	/*7*/ 

			,CASE WHEN (InstrumentGroup = 'phys' AND [Cashflow Settlement Type] = 'Physical Settlement') THEN 0 ELSE REAL_DISC_PH_IM1_CCY_YTD END as [risk_realised_disc_RepCCY] /*8*/
			--,REAL_DISC_PH_IM1_CCY_YTD as [risk_realised_disc_RepCCY] /*8*/

			,CASE WHEN (InstrumentGroup = 'phys' AND [Cashflow Settlement Type] = 'Physical Settlement') THEN 0 ELSE REAL_DISC_PH_BL_CCY_YTD END as [risk_realised_disc_repEUR] /*9*/
			--,REAL_DISC_PH_BL_CCY_YTD as [risk_realised_disc_repEUR] /*9*/
			
			,CASE WHEN  (InstrumentGroup = 'phys' AND [Cashflow Settlement Type] = 'Physical Settlement') THEN 0 ELSE REAL_UNDISC_CASHFLOW_CCY_YTD END AS [risk_realised_undisc_CCY] /*10*/  /*--> der definition nach eigentlich eine YTD metrik!!!*/	
			--,REAL_UNDISC_CASHFLOW_CCY_YTD AS [risk_realised_undisc_CCY] /*10*/  
			
			,CASE WHEN (InstrumentGroup = 'phys' AND [Cashflow Settlement Type] = 'Physical Settlement' AND REAL_DISC_PH_IM1_CCY_YTD <> 0) 	THEN 0 ELSE TOTAL_VALUE_PH_IM1_CCY_YTD END AS [TOTAL_VALUE_PH_IM1_CCY_YTD] /*11*/

			,CASE WHEN (InstrumentGroup = 'phys' AND [Cashflow Settlement Type] = 'Physical Settlement' AND REAL_DISC_PH_IM1_CCY_YTD <> 0) 	THEN 0 ELSE TOTAL_VALUE_PH_BL_CCY_YTD END AS [TOTAL_VALUE_PH_BL_CCY_YTD] /*12*/

			,CASE WHEN (InstrumentGroup = 'phys' AND [Cashflow Settlement Type] = 'Physical Settlement') 	THEN 0 ELSE REAL_DISC_PH_BL_CCY_YTD END AS [REAL_DISC_PH_BL_CCY_YTD]/*13*/

			,CASE WHEN (InstrumentGroup = 'phys' AND [Cashflow Settlement Type] = 'Physical Settlement') THEN 0 ELSE REAL_DISC_PH_IM1_CCY_YTD END as [REAL_DISC_PH_IM1_CCY_YTD]/*14*/

/*added 2022-12-08, mkb*/
			,UNREAL_DISC_PH_IM1_CCY  /*15*/
			,UNREAL_DISC_PH_IM1_CCY_LGBY /*16*/
			,UNREAL_DISC_PH_BL_CCY /*17*/
			,UNREAL_DISC_PH_BL_CCY_LGBY /*18*/
			,UNREAL_DISC_BL_CCY /*19*/
			,UNREAL_DISC_BL_CCY_LGBY/*20*/
			,'Glori' AS [source]
		FROM 	
		/*mkb 2022-12-08: joins werden hier nicht benötigt, ALLE werte kommen komplett aus der [dbo].[GloriRisk]*/
			[dbo].[GloriRisk]  
			--left outer JOIN [dbo].[map_order] ON [GloriRisk].[Internal Portfolio Name] = [map_order].[portfolio]
			INNER JOIN dbo.map_instrument ON [GloriRisk].[Instrument Type Name] = map_instrument.InstrumentType	
			left outer JOIN [dbo].map_order ON GloriRisk.[Internal Portfolio Name] = map_order.portfolio
		WHERE 
			(
				--(fileid = 2909 AND [Instrument Type Name] NOT IN ('COMM-FWD-FM-P','PWR-FWD-FM-EFA-D-P','EM-INV-P'))
				(fileid in ( '2909', '3153', '3154' ) AND [Instrument Type Name] NOT IN ('COMM-FWD-FM-P','PWR-FWD-FM-EFA-D-P','EM-INV-P')) -- MBE: After splitting the data files
				OR 
				( fileid not in ('2909','3153','3154')) /*FileID 2909 = "Fin_Risk_PnL_CAOUK.csv" */	  
			)
			and FileId <> 3133 /*FileID 3133 = "Fin_Risk_PnL_GPM_AP_0.csv" => data for liiquid period from gpm desk , mkb+YK 2023-05-03*/




/*=============================================================================================================================================================*/
/*==== INSERT Risk PNL (realised for physical trades) INTO RiskRecon_zw1 ======================================================================================*/
--/*=============================================================================================================================================================*/
/*reactivated 2023-02-21 MU/MKB to eliminate found differences found in globals_options (mail april, 2023-02-19*/
/*deactivated 2023-02-22 MU - As led to problems for all desks except Global Options UK where it solved most of the differences*/
/*Activated 2023-02-27 MU - Test activation just for Conti and S&O*/
	BEGIN insert into [dbo].[Logfile] select @proc + ' - insert RiskData - physical', GETDATE () END
	select @step = 4
	INSERT INTO dbo.riskrecon_zw1 
		(
		portfolio
		,InstrumentType
		,DealID
		,ExtBunitName
		,ccy
		,risk_realised_disc_EUR /*7*/
		,risk_realised_disc_RepCCY /*8*/
		,risk_realised_disc_RepEUR /*9*/
		,risk_realised_undisc_CCY /*10*/
		,TOTAL_VALUE_PH_IM1_CCY_YTD /*11*/
		,TOTAL_VALUE_PH_BL_CCY_YTD /*12*/
		,REAL_DISC_PH_BL_CCY_YTD /*13*/
		,REAL_DISC_PH_IM1_CCY_YTD /*14*/
/*added 2022-12-08, mkb*/
		--,UNREAL_DISC_PH_IM1_CCY  /*15*/
		--,UNREAL_DISC_PH_IM1_CCY_LGBY /*16*/
		--,UNREAL_DISC_PH_BL_CCY /*17*/
		--,UNREAL_DISC_PH_BL_CCY_LGBY /*18*/
		--,UNREAL_DISC_BL_CCY /*19*/
		--,UNREAL_DISC_BL_CCY_LGBY/*20*/
		,[source]
		)
		SELECT 
			[Internal Portfolio Name] AS InternalPortfolio
			,[Instrument Type Name] AS InsTypeName
			,'physical realised' + '/' + [Internal Portfolio Name] + '/' + [Ext Business Unit Name] + '/' + [Instrument Type Name] + '/' + [Trade Currency] AS [Deal]
			,[Ext Business Unit Name]
			,[Trade Currency] AS ccy
			,sum(REAL_DISC_PH_BL_CCY_YTD) AS risk_realised_disc_eur /*7*/			
			,sum(REAL_DISC_PH_IM1_CCY_YTD) AS risk_realised_disc_rep_ccy	/*8*/					
			,sum(REAL_DISC_PH_BL_CCY_YTD) AS risk_realised_disc_rep_eur /*9*/					
			--,sum([Realised Undiscounted Original Currency] - [Realised Undiscounted Original Currency GPG EOLY]) AS realised_orig_ccy /*10*/
			,sum(REAL_UNDISC_CASHFLOW_CCY_YTD) AS risk_realised_undisc_CCY /*10*/
/*MU 2023-02-28 Commented*/			
			,sum(TOTAL_VALUE_PH_IM1_CCY_YTD) as TOTAL_VALUE_PH_IM1_CCY_YTD /*11*/
			,sum(TOTAL_VALUE_PH_BL_CCY_YTD) as TOTAL_VALUE_PH_BL_CCY_YTD /*12*/	
			,sum(REAL_DISC_PH_BL_CCY_YTD) as REAL_DISC_PH_BL_CCY_YTD/*13*/
			,sum(REAL_DISC_PH_IM1_CCY_YTD) as REAL_DISC_PH_IM1_CCY_YTD/*14*/
/*added 2022-12-08, mkb*/
/*MU 2023-02-28 Commented*/
		--	,sum(UNREAL_DISC_PH_IM1_CCY) as UNREAL_DISC_PH_IM1_CCY /*15*/
		--	,sum(UNREAL_DISC_PH_IM1_CCY_LGBY) as UNREAL_DISC_PH_IM1_CCY_LGBY /*16*/
		--	,sum(UNREAL_DISC_PH_BL_CCY) as UNREAL_DISC_PH_BL_CCY  /*17*/
		--	,sum(UNREAL_DISC_PH_BL_CCY_LGBY) as UNREAL_DISC_PH_BL_CCY_LGBY /*18*/
		--	,sum(UNREAL_DISC_BL_CCY) as UNREAL_DISC_BL_CCY  /*19*/
		--	,sum(UNREAL_DISC_BL_CCY_LGBY) as UNREAL_DISC_BL_CCY_LGBY/*20*/
			,'Glori_phys' AS src
		FROM 						
			[dbo].[GloriRisk] 
			--inner JOIN [dbo].map_order ON GloriRisk.[Internal Portfolio Name] = map_order.portfolio
			left outer JOIN [dbo].map_order ON GloriRisk.[Internal Portfolio Name] = map_order.portfolio
			INNER JOIN dbo.map_instrument ON GloriRisk.[Instrument Type Name] = dbo.map_instrument.InstrumentType			
		WHERE 				
			InstrumentGroup = 'phys'
			AND GloriRisk.[Cashflow Settlement Type] = 'Physical Settlement'			
			and REAL_DISC_PH_IM1_CCY_YTD <> 0
			and FileId <> 3133 /*FileID 3133 = "Fin_Risk_PnL_GPM_AP_0.csv" => data for liiquid period from gpm desk , mkb+YK 2023-05-03*/
		GROUP BY 
			[Internal Portfolio Name]
			,[Instrument Type Name]
			,'physical realised' + '/' + [Internal Portfolio Name] + '/' + [Ext Business Unit Name] + '/' + [Instrument Type Name] + '/' + [Trade Currency] 
			,[Ext Business Unit Name]
			,[Trade Currency] 
		
			
			
/*=============================================================================================================================================================*/
/*==== INSERT ADJUSTMENTS FROM GLORI/ROCK INTO RiskRecon_zw1_ ==================================================================================================*/
/*=============================================================================================================================================================*/

	BEGIN insert into [dbo].[Logfile] select @proc + ' - insert GloriADJ ( Adjustments from ROCK ) into table RiskRecon_zw1', GETDATE () END

	select @step =5		
	INSERT INTO dbo.[riskrecon_zw1] 
	(
		 [Portfolio]
		,[InstrumentType]
		,[DealID]
		,ccy
		,[risk_mtm_EOM_EUR]			/* 1 */
		,[risk_mtm_EOM_RepCCY] /* 2 */
		,[risk_mtm_EOM_RepEUR] /* 3 */
		,[risk_mtm_EOY_EUR] /* 4 */
		,[risk_mtm_EOY_RepCCY] /* 5 */
		,[risk_mtm_EOY_RepEUR] /* 6 */
		,[risk_realised_disc_EUR] /* 7 */
		,[risk_realised_disc_RepCCY] /* 8 */
		,[risk_realised_disc_RepEUR] /* 9 */
		,[risk_realised_undisc_CCY] /* 10 */
		,TOTAL_VALUE_PH_IM1_CCY_YTD /*11*/
		,TOTAL_VALUE_PH_BL_CCY_YTD /*12*/
		,REAL_DISC_PH_BL_CCY_YTD /*13*/
		,REAL_DISC_PH_IM1_CCY_YTD /*14*/
--/*added 2022-12-08, mkb*/
		,UNREAL_DISC_PH_IM1_CCY  /*15*/
		,UNREAL_DISC_PH_IM1_CCY_LGBY /*16*/
		,UNREAL_DISC_PH_BL_CCY /*17*/
		,UNREAL_DISC_PH_BL_CCY_LGBY /*18*/
		,UNREAL_DISC_BL_CCY /*19*/
		,UNREAL_DISC_BL_CCY_LGBY/*20*/
		,[source]
	)
	SELECT
		 PORTFOLIO_NAME as portfolio
		,left(USER_COMMENT,1500) as InstrumentType
		--2024-01-25: Prepared Code for using Risk Adjustment_ID instead of 'GloriAdj_' + cast((table_RISK_ADJUSTMENTS.ID), for easier identification (old approach switches IDs every Month)
		,CASE 
			WHEN CATEGORY_NAME IN ('Bid/Offer Valuation Adjustments','Valuation Adjustments Credit') THEN CATEGORY_NAME
			WHEN CATEGORY_NAME = 'Maklergebühren und Börsengebühren' THEN [SUB_CATEGORY_NAME] + '// Adj_' + [table_RISK_ADJUSTMENTS].[ADJUSTMENT_ID]
			ELSE 'Adj_' + [table_RISK_ADJUSTMENTS].[ADJUSTMENT_ID]
		END AS DealID
		--,CATEGORY_NAME  as DealID
		,CASHFLOW_CURRENCY as ccy
		,UNREAL_DISC_BL_CCY as risk_mtm_EOM_EUR  /*1*/
		,UNREAL_DISC_PH_IM1_CCY as [risk_mtm_EOM_RepCCY] /*2*/
		,UNREAL_DISC_PH_BL_CCY as [risk_mtm_EOM_RepEUR] /*3*/
		,UNREAL_DISC_BL_CCY_LGBY as [risk_mtm_EOY_EUR] /*4*/
		,UNREAL_DISC_PH_IM1_CCY_LGBY as [risk_mtm_EOY_RepCCY] /*5*/
		,UNREAL_DISC_PH_BL_CCY_LGBY as [risk_mtm_EOY_RepEUR] /*6*/
		,REAL_DISC_PH_BL_CCY_YTD as [risk_realised_disc_EUR] /*7*/ 
		,REAL_DISC_PH_IM1_CCY_YTD as [risk_realised_disc_RepCCY] /*8*/
		,REAL_DISC_PH_BL_CCY_YTD as [risk_realised_disc_repEUR] /*9*/		
		,REAL_UNDISC_CASHFLOW_CCY_YTD as risk_realised_undisc_ccy /*10*/ /*2023-02-27: Metric added analog to regular Rock Data*/ 
		,TOTAL_VALUE_PH_IM1_CCY_YTD /*11*/
		,TOTAL_VALUE_PH_BL_CCY_YTD /*12*/
		,REAL_DISC_PH_BL_CCY_YTD /*13*/
		,REAL_DISC_PH_IM1_CCY_YTD /*14*/
--/*added 2022-12-08, mkb*/
			,UNREAL_DISC_PH_IM1_CCY  /*15*/
			,UNREAL_DISC_PH_IM1_CCY_LGBY /*16*/
			,UNREAL_DISC_PH_BL_CCY /*17*/
			,UNREAL_DISC_PH_BL_CCY_LGBY /*18*/
			,UNREAL_DISC_BL_CCY /*19*/
			,UNREAL_DISC_BL_CCY_LGBY/*20*/
		,'GloriAdj' as src
	from 
		/*mkb 2022-12-08: joins werden hier nicht benötigt, ALLE werte kommen komplett aus der [dbo].[table_RISK_ADJUSTMENTS] !!! */		
			[dbo].table_RISK_ADJUSTMENTS  
	where 
		not (desk_name ='GPM DESK' and SUB_CATEGORY_NAME like '%contra%') /*inserted 2023-06-01 by JS, YK, mkB to reflect gpm illiquid correct*/
			
/*=============================================================================================================================================================*/
/*==== START INSERT FASTracker (MtM EOM) INTO RiskRecon_zw1 ===================================================================================================*/
/*=============================================================================================================================================================*/

	BEGIN insert into [dbo].[Logfile] select @proc + ' - insert FASTracker EOM into table RiskRecon_zw1', GETDATE () END

	select @step = 6
	INSERT INTO dbo.[riskrecon_zw1] 
	(
		Portfolio
		,InstrumentType
		,DealID
		,ticker
		,ExtBunitName
		,TradeDate
		,EndDate
		,finance_mtm_EOM
		,finance_mtm_EOM_DeskCCY
		,source
	)
	SELECT 
		 ft.[InternalPortfolio]
		,ft.[InstrumentType]
		,ft.[ReferenceID]
		,ft.product
		,ft.ExternalBusinessUnit
		,ft.[TradeDate]
		,max(ft.[Termend])
		,sum(isnull(ft.[Total_MTM],0))
		,sum(isnull(ft.[Total_MTM_DeskCCY],0))
		,'FT EOM' AS source
	FROM 
		[dbo].[FASTracker_EOM] ft
	GROUP BY 
		 [InternalPortfolio]
		,ft.[InstrumentType]
		,[ReferenceID]
		,[TradeDate]
		,product
		,ExternalBusinessUnit


/*=============================================================================================================================================================*/
/*==== START INSERT FASTracker (MtM EOY) INTO RiskRecon_zw1 ===================================================================================================*/
/*=============================================================================================================================================================*/

		BEGIN insert into [dbo].[Logfile] select @proc + ' - insert FASTracker EOY into table RiskRecon_zw1', GETDATE () END

		select @step =7
		INSERT INTO dbo.[riskrecon_zw1] 
		(
			Portfolio
			,InstrumentType
			,DealID
			,ticker
			,ExtBunitName
			,TradeDate
			,EndDate
			,finance_mtm_EOY
			,finance_mtm_EOY_DeskCCY
			,[source]
		)
		SELECT ft.[InternalPortfolio]
			,ft.[InstrumentType]
			,ft.[ReferenceID]
			,ft.product
			,ft.ExternalBusinessUnit
			,ft.[TradeDate]
			,max(ft.[Termend])
			,sum(isnull(ft.[Total_MTM],0))
			,sum(isnull(ft.[Total_MTM_DeskCCY],0))
			,'FT EOY' AS [source]
		FROM 
			[dbo].[FASTracker_EOY] ft
			INNER JOIN AsOfDate ON ft.AsofDate = AsofDate.AsOfDate_EOY
		GROUP BY 
			 [InternalPortfolio]
			,ft.[InstrumentType]
			,[ReferenceID]
			,[TradeDate]
			,product
			,ExternalBusinessUnit
									
/*=============================================================================================================================================================*/
/*==== START INSERT RealisedScript INTO RiskRecon_zw1 ====================================================================================================*/
/*=============================================================================================================================================================*/

	BEGIN insert into [dbo].[Logfile] select @proc + ' - insert FinanceRealised into table RiskRecon_zw1', GETDATE () END

	select @step = 8
	INSERT INTO dbo.[riskrecon_zw1] 
	(
		 Portfolio
		,InstrumentType
		,DealID
		,Ticker
		,ExtBunitName
		,TradeDate
		,ccy
		,finance_realised_EUR
		,finance_realised_CCY
		,finance_realised_DeskCCY
		,[source]
	)
	SELECT portfolio
		,InstrumentType
		,CASE WHEN cashflowtype = 'Broker Commission' THEN 'Broker Commission // ' + Portfolio ELSE DealID END AS DealID
		,Ticker
		,ExternalBusinessUnit as ExtBunitName
		,TradeDate
		,ccy
		,sum(isnull(realised_eur_endur,0)) as finance_realised_EUR
		,sum(isnull(realised_ccy_endur,0)) as finance_realised_CCY
		,sum(isnull(realised_Deskccy_Endur,0)) as finance_realised_DeskCCY
		,'RealScript' AS [source]
	FROM						
		dbo.recon_zw1						
	WHERE 
		[source] = 'realised_script' AND CashflowType NOT IN ('Route Fee','DMA Exchange Fee')
	GROUP BY 
			portfolio
		,InstrumentType
		,CASE WHEN cashflowtype = 'Broker Commission' THEN 'Broker Commission // ' + Portfolio ELSE DealID END
		,Ticker
		,TradeDate
		,ccy
		,[source]
		,ExternalBusinessUnit


	
	select @step =9
	BEGIN insert into [dbo].[Logfile] select @proc + ' - update RiskRecon_zw1 table where ExtBunitName Is Null', GETDATE () END
	update dbo.riskrecon_zw1
		set ExtBunitName = ''
		where extbunitname is null

	select @step =11
	BEGIN insert into [dbo].[Logfile] select @proc + ' - update RiskRecon_zw1 table for CAO UK', GETDATE () END

	update dbo.riskrecon_zw1 
		set [dealID] = o.[portfolio]+'//'+[InstrumentType]
		from 
			dbo.riskrecon_zw1 r 
			inner join dbo.map_order o on r.Portfolio = o.Portfolio
		where 
			Desk = 'CAO UK' 
			and 
			(				
				o.[subdesk] in ('Daily_RiskOnly','pls review')				
				or 
				(
					[InstrumentType] in ('COST-FWD-VAL-F','COST-FWD-FM-F') 
					and 
					subdesk not in ('Non-Performance - Britannia')
				)
			)

	--EXCEPTION build in on 2023-01-20 by MK to rectify delta between risk and realised pnl value
	UPDATE [dbo].[riskrecon_zw1]
	SET [risk_realised_disc_RepCCY] = 0
	WHERE ([DealID] in ('56300338','56301243','56301244','57055245','57055466','57055469','59414904','59415023','59415024') AND [CCY] = 'SGD')
	OR ([DealID] in ('50789181','GloriAdj_8657') AND [CCY] = 'EUR')
	OR ([DealID] in ('50789181','51475185','51475191','51475192','52739610','52739871','52739872','54729358','54729498','54729499','55380558','55380629','55380630','55923378','55923379','55923380','57055244','57055526','57055527','59414905','59415040','59415041','59988418','59989001','59989002','60419505','60435526','60435527','61048596','61048604','61048605','62041016','62041385','62041386','64270593','64270609','64270610') AND [CCY] = 'JPY')
	
/*=============================================================================================================================================================*/
/*==== RiskRecon füllen =================================================================================================================================*/
/*=============================================================================================================================================================*/

	select @step =12
	BEGIN insert into [dbo].[Logfile] select @proc + ' - fill table riskrecon', GETDATE () END

	INSERT INTO dbo.[riskrecon] 
		(
			 [InternalLegalEntity]
			,Desk
			,[Subdesk]
			,[RevRecSubdesk]
			,[SubdeskCCY]
			,[Portfolio]
			,[Portfolio_ID]
			,[InstrumentType]
			,[DealID]
			,Ticker
			,ExtBunitName
			,[ccy]
			,[TradeDate]
			,[EndDate]
			,[finance_mtm_EOM]
			,[finance_mtm_EOY]
			,[finance_mtm_EOM_DeskCCY]
			,[finance_mtm_EOY_DeskCCY]
			,[finance_realised_CCY]
			,[finance_realised_DeskCCY]
			,[finance_realised_EUR]
			,[risk_mtm_EOM_EUR]
			,[risk_mtm_EOM_RepCCY]
			,[risk_mtm_EOM_RepEUR]
			,[risk_mtm_EOY_EUR]
			,[risk_mtm_EOY_RepCCY]
			,[risk_mtm_EOY_RepEUR]
			,[risk_realised_disc_EUR]
			,[risk_realised_disc_RepCCY] /*8*/
			,[risk_realised_disc_RepEUR]
			,[risk_realised_undisc_CCY]
			,TOTAL_VALUE_PH_IM1_CCY_YTD /*11*/
			,TOTAL_VALUE_PH_BL_CCY_YTD /*12*/
			,REAL_DISC_PH_BL_CCY_YTD /*13*/
			,REAL_DISC_PH_IM1_CCY_YTD /*14*/
/*added 2022-12-08, mkb*/
			,UNREAL_DISC_PH_IM1_CCY  /*15*/
			,UNREAL_DISC_PH_IM1_CCY_LGBY /*16*/
			,UNREAL_DISC_PH_BL_CCY /*17*/
			,UNREAL_DISC_PH_BL_CCY_LGBY /*18*/
			,UNREAL_DISC_BL_CCY /*19*/
			,UNREAL_DISC_BL_CCY_LGBY/*20*/
		)
		SELECT 
			 LegalEntity as [InternalLegalEntity]
			,Desk
			,subdesk + CASE WHEN (dealid LIKE 'Broker%' OR dealid LIKE 'Exchange%') AND RiskRecon_zw1.[portfolio] NOT LIKE '%Brokerage' THEN '_Brokerage' ELSE '' END as [Subdesk]
			,[RevRecSubDesk]
			,SubdeskCCY
			,max(RiskRecon_zw1.Portfolio + CASE WHEN dealid LIKE 'physical realised%' THEN ' // ' + RiskRecon_zw1.[ccy] ELSE '' END) as [Portfolio]
			,MAX(PortfolioID)
			,[InstrumentType] 
			,[DealID] 
			,max(Ticker) as Ticker
			,max(ExtBunitName) as ExtBunitName
			,max([ccy]) as [ccy]
			,max([TradeDate]) as [TradeDate]
			,max([EndDate]) as [EndDate]
			,sum([finance_mtm_EOM]) as [finance_mtm_EOM]
			,sum([finance_mtm_EOY]) as [finance_mtm_EOY]
			,sum([finance_mtm_EOM_DeskCCY]) as [finance_mtm_EOM_DeskCCY]
			,sum([finance_mtm_EOY_DeskCCY]) as [finance_mtm_EOY_DeskCCY]
			,sum([finance_realised_CCY]) as [finance_realised_CCY]
			,sum([finance_realised_DeskCCY]) as [finance_realised_DeskCCY]
			,sum([finance_realised_EUR]) as [finance_realised_EUR]
			,sum([risk_mtm_EOM_EUR]) as [risk_mtm_EOM_EUR]
			,sum([risk_mtm_EOM_RepCCY]) as [risk_mtm_EOM_RepCCY]
			,sum([risk_mtm_EOM_RepEUR]) as [risk_mtm_EOM_RepEUR]
			,sum([risk_mtm_EOY_EUR]) as [risk_mtm_EOY_EUR]
			,sum([risk_mtm_EOY_RepCCY]) as [risk_mtm_EOY_RepCCY]
			,sum([risk_mtm_EOY_RepEUR]) as [risk_mtm_EOY_RepEUR]
			,sum([risk_realised_disc_EUR]) as [risk_realised_disc_EUR]
			,sum([risk_realised_disc_RepCCY]) as [risk_realised_disc_RepCCY] /*8*/
			,sum([risk_realised_disc_RepEUR]) as [risk_realised_disc_RepEUR] /*9*/
			,sum([risk_realised_undisc_CCY]) as [risk_realised_undisc_CCY] /*10*/
			,sum(TOTAL_VALUE_PH_IM1_CCY_YTD) as TOTAL_VALUE_PH_IM1_CCY_YTD  /*11*/
			,sum(TOTAL_VALUE_PH_BL_CCY_YTD) as TOTAL_VALUE_PH_BL_CCY_YTD  /*12*/
			,sum(REAL_DISC_PH_BL_CCY_YTD) as REAL_DISC_PH_BL_CCY_YTD /*13*/
			,sum(REAL_DISC_PH_IM1_CCY_YTD) as REAL_DISC_PH_IM1_CCY_YTD /*14*/			
/*added 2022-12-08, mkb*/
			,sum(UNREAL_DISC_PH_IM1_CCY) as UNREAL_DISC_PH_IM1_CCY  /*15*/
			,sum(UNREAL_DISC_PH_IM1_CCY_LGBY) as UNREAL_DISC_PH_IM1_CCY_LGBY/*16*/
			,sum(UNREAL_DISC_PH_BL_CCY) as UNREAL_DISC_PH_BL_CCY/*17*/
			,sum(UNREAL_DISC_PH_BL_CCY_LGBY) as UNREAL_DISC_PH_BL_CCY_LGBY /*18*/
			,sum(UNREAL_DISC_BL_CCY) as UNREAL_DISC_BL_CCY/*19*/
			,sum(UNREAL_DISC_BL_CCY_LGBY) as UNREAL_DISC_BL_CCY_LGBY/*20*/
		
		FROM 
		  [dbo].[RiskRecon_zw1] 
			LEFT JOIN dbo.map_order ON [dbo].[RiskRecon_zw1].Portfolio = dbo.map_order.portfolio
		WHERE 
			(
				desk NOT IN ('CAO Power','Industrial Sales','Commodity Solutions','Sales & Origination','RWE AG') 
				OR 
				desk IS NULL
			) 
			AND LegalEntity NOT IN ('n/a')		
		GROUP BY 
			 LegalEntity
			,desk
			,subdesk + CASE WHEN (dealid LIKE 'Broker%' OR dealid LIKE 'Exchange%') AND RiskRecon_zw1.[portfolio] NOT LIKE '%Brokerage' THEN '_Brokerage' ELSE '' END
			,RevRecSubDesk
			,subdeskccy
			,InstrumentType
			,dealid

/*=============================================================================================================================================================*/
/*==== START special cases ====================================================================================================================================*/
/*=============================================================================================================================================================*/

/*==== MBE for Libby -- 02.07.2021 ==== */
	select @step =13
	BEGIN insert into [dbo].[Logfile] select @proc + ' - remove predefined CAO_UK portfolios from table riskrecon', GETDATE () END
	delete from [riskrecon] 
	where Portfolio in 
		(
 			 'CAO_UK_BH_CDS_RHP_OP_ValADj'
			,'CAO_UK_BH_CDS_ValADj'
			,'CAO_UK_BH_CDSBL_RHP_ST_ValADj'
			,'CAO_UK_BH_CSS_ANALYST_ValADj'
			,'CAO_UK_BH_CSS_BusinessRelCost'
			,'CAO_UK_BH_CSS_RHP_OP_ValADj'
			,'CAO_UK_BH_CSS_ValADj'
			,'CAO_UK_BH_CSSBL_RHP_ST_ValADj'
			,'CAO_UK_BH_CSSPK_RHP_ST_ValADj'
			,'CAO_UK_BH_FH_ValADj'
			,'CAO_UK_OFGEM_MM_ValADj'
			,'CAO_UK_RENEWABLE_RTMA_ValADj'
		)

/*=============================================================================================================================================================*/
/*====== END special cases ====================================================================================================================================*/
/*=============================================================================================================================================================*/
	
	select @step = 14
	BEGIN insert into [dbo].[Logfile] select @proc + ' - prepare tables for export: delete old data', GETDATE () END
	truncate table dbo.RiskRecon_DealLevel_tbl 
	truncate table dbo.RiskRecon_RiskPNL_tbl 
	truncate table dbo.RiskRecon_Discounting_tbl 	
	truncate table dbo.RiskRecon_MtM_Overview_tbl
	truncate table dbo.RiskRecon_Unrealised_FASTracker_SAP_tbl

	select @step = 15	
	BEGIN insert into [dbo].[Logfile] select @proc + ' - fill 1 / 5: table RiskRecon_DealLevel_tbl', GETDATE () END
	insert into dbo.RiskRecon_DealLevel_tbl select * from dbo.RiskRecon_DealLevel
	
	select @step = 16
	BEGIN insert into [dbo].[Logfile] select @proc + ' - fill 2 / 5: table RiskRecon_RiskPNL_tbl', GETDATE () END
	insert into dbo.RiskRecon_RiskPNL_tbl select * from dbo.RiskRecon_Riskpnl

	select @step = 17
	BEGIN insert into [dbo].[Logfile] select @proc + ' - fill 3 / 5: table RiskRecon_Discounting_tbl', GETDATE () END
	insert into dbo.RiskRecon_Discounting_tbl select * from dbo.RiskRecon_Discounting

	select @step = 18
	BEGIN insert into [dbo].[Logfile] select @proc + ' - fill 4 / 5: table RiskRecon_MtM_Overview_tbl', GETDATE () END
	insert into dbo.RiskRecon_MtM_Overview_tbl select * from dbo.RiskRecon_MtM_Overview 
	 
	select @step = 19
	BEGIN insert into [dbo].[Logfile] select @proc + ' - fill 5 / 5: table RiskRecon_Unrealised_FASTracker_SAP_tbl', GETDATE () END
	insert into dbo.RiskRecon_Unrealised_FASTracker_SAP_tbl select * from dbo.RiskRecon_Unrealised_FASTracker_SAP 

	BEGIN insert into [dbo].[Logfile] select @proc + ' - FINISHED', GETDATE () END

END TRY

BEGIN CATCH
	EXEC [dbo].[usp_GetErrorInfo] @proc, @step		
	BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - FAILED', GETDATE () END		
END CATCH

GO

