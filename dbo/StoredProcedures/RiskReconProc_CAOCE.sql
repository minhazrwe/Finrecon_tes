-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[RiskReconProc_CAOCE]
AS
BEGIN TRY

	DECLARE @LogInfo Integer
	DECLARE @proc nvarchar(40)
	DECLARE @step Integer

	select @step = 1
	select @proc = '[dbo].[RiskReconProc_CAOCE]'


	BEGIN insert into [dbo].[Logfile] select 'RiskRecon_CAOCE - START', GETDATE () END

	BEGIN insert into [dbo].[Logfile] select 'RiskRecon_CAOCE - delete tables', GETDATE () END

	select @step = @step + 1
	truncate table dbo.[RiskRecon_CAOCE_zw1]
	truncate table dbo.[RiskRecon_CAOCE]



	-- ######## insert RealisedScript into RiskRecon_CAOCE_zw1 ######## 

	BEGIN insert into [dbo].[Logfile] select 'RiskRecon_CAOCE - insert RealisedScript', GETDATE () END

	select @step = @step + 1
	Insert into dbo.[RiskRecon_CAOCE_zw1] (Portfolio, InstrumentType, DealID, Ticker, ExtBunitName,TradeDate,EndDate, ccy, finance_realised_EUR, finance_realised_CCY,source)
			select r.portfolio ,InstrumentType, 
			case when cashflowtype = 'Broker Commission' then 'Broker Commission // ' + Portfolio 
				--else case when r.portfolio like 'IDT%' then r.portfolio + ' // ' + InstrumentType + ' // '  + ccy 
				else DealID 
				--end 
				end, 
			Ticker, ExternalBusinessUnit,TradeDate, 
			case when deliverymonth like '20%/%' and len(deliverymonth) = 7 and left(right(deliverymonth,3),1)='/' then convert(datetime , '01.' + right(DeliveryMonth,2)+'.'+left(deliverymonth,4),104) else '' end as EndDate,
			ccy, 
			sum(realised_eur_endur), sum(realised_ccy_endur),  'RealScript' as source
			from recon_zw1 r inner join dbo.[00_map_order] o on r.OrderNo = o.orderno
			where source = 'realised_script' and CashflowType not in ('Route Fee', 'DMA Exchange Fee')
				  and o.desk in ('CAO Power','COMMODITY SOLUTIONS','Industrial Sales','CAO CE')
				  and left(PORTFOLIO,3) not in ('TS ','TS_', 'BMT' ,'RHP')
			group by r.portfolio,InstrumentType,case when cashflowtype = 'Broker Commission' then 'Broker Commission // ' + Portfolio 
				--else case when r.portfolio like 'IDT%' then r.portfolio + ' // ' + InstrumentType + ' // ' + ccy 
				else DealID 
				--end 
				end, Ticker, TradeDate,
				case when deliverymonth like '20%/%' and len(deliverymonth) = 7 and left(right(deliverymonth,3),1)='/' then convert(datetime , '01.' + right(DeliveryMonth,2)+'.'+left(deliverymonth,4),104) else '' end,
				ccy,source,ExternalBusinessUnit 

	-- ######## insert FASTracker (MtM EOM) into RiskRecon_CAOCE_zw1 ######## 

	BEGIN insert into [dbo].[Logfile] select 'RiskRecon_CAOCE - insert FASTracker EOM', GETDATE () END

	select @step = @step + 1
	Insert into dbo.[RiskRecon_CAOCE_zw1] (Portfolio, InstrumentType, DealID, ticker, ExtBunitName, TradeDate, EndDate, finance_mtm_EOM, ccy, source)
		select ft.[InternalPortfolio], ft.[InstrumentType], 
		--case when ft.InternalPortfolio like 'IDT%' then InternalPortfolio else  ft.[ReferenceID] end as refid,
		ft.[ReferenceID] as refid,
		ft.product, ft.ExternalBusinessUnit, ft.[TradeDate], max(ft.[Termend]), sum(ft.[Total_MTM]), 'EUR' as ccy, 'FT EOM' as source
	    from [dbo].[FASTracker_EOM] ft 
		where ft.Desk in ('CAO Power','COMMODITY SOLUTIONS','Industrial Sales','CAO CE')
		group by [InternalPortfolio], ft.[InstrumentType],  [TradeDate], product, ExternalBusinessUnit,
		--case when ft.InternalPortfolio like 'IDT%' then InternalPortfolio else  ft.[ReferenceID] end
		ft.ReferenceID

	-- ######## insert FASTracker (MtM EOY) into RiskRecon_CAOCE_zw1 ######## 

	BEGIN insert into [dbo].[Logfile] select 'RiskRecon_CAOCE - insert FASTracker EOY', GETDATE () END

	select @step = @step + 1
	Insert into dbo.[RiskRecon_CAOCE_zw1] (Portfolio, InstrumentType, DealID, ticker, ExtBunitName, TradeDate, EndDate, finance_mtm_EOY, source)
			select ft.[InternalPortfolio], ft.[InstrumentType], 
			--case when ft.InternalPortfolio like 'IDT%' then InternalPortfolio +' // '+[InstrumentType] else  ft.[ReferenceID] end as refid
			ft.[ReferenceID] as refid
			, ft.product, ft.ExternalBusinessUnit, ft.[TradeDate], max(ft.[Termend]), 
					sum(ft.[Total_MTM]), 'FT EOY' as source
			from [dbo].[FASTracker_EOY] ft inner join AsOfDate on ft.AsofDate = AsofDate.AsOfDate_EOY
			where ft.desk in ('CAO Power','COMMODITY SOLUTIONS','Industrial Sales','CAO CE')
			group by [InternalPortfolio],ft.[InstrumentType], 
			--case when ft.InternalPortfolio like 'IDT%' then InternalPortfolio +' // '+[InstrumentType] else  ft.[ReferenceID] end,
			ft.ReferenceID,
			[TradeDate], product, ExternalBusinessUnit


	-- ######## insert Risk PNL into RiskRecon_CAOCE_zw1 ######## 

	BEGIN insert into [dbo].[Logfile] select 'RiskRecon_CAOCE - insert RiskData', GETDATE () END

	select @step = @step + 1
	insert into dbo.[RiskRecon_CAOCE_zw1] ([Portfolio],[InstrumentType],[DealID], tradedate ,enddate, ExtBunitName, [ccy],[risk_mtm_EOM_EUR],
				[risk_mtm_EOY_EUR],[risk_realised_disc_EUR],[risk_realised_undisc_CCY],[source])
	select  [PORTFOLIO_NAME],
			[INS_TYPE_NAME],
			--case when r.[PORTFOLIO_NAME] like 'IDT%' then r.Portfolio_name +' // '+[INS_TYPE_NAME] + case when PNL_TYPE in ('REALIZED','MATURED') then ' // '+leg_currency else '' end
			 --else 
			 case when year(REALISATION_DATE_Original) < year(COB) and REALISATION_DATE > COB then 'shift realised --> unrealised' 
			 else r.[deal_num] end --end 
			 as DealID,
			 Trade_Date,
			 max(REALISATION_DATE_Original),
			[EXT_BUNIT_NAME],	
			[leg_currency],
			sum(case when PNL_TYPE in ('REALIZED','MATURED') then 0 else [pnl] end) as mtm_EOM,
			sum(0) as mtm_EOY,
			sum(case when PNL_TYPE in ('REALIZED','MATURED') then [UNDISC_PNL] else 0 end) as realised_eur,
			sum(case when PNL_TYPE in ('REALIZED','MATURED') then [undisc_pnl_orig_ccy] else 0 end) as realised_ccy,
			'Strolf' as src
	from (select * from [dbo].[Strolf_MOP_PLUS_REAL_CORR_EOM]
			where desk not in (	'RWER_OFFSHORE_ASSET_DE',
								'RWER_OPEA_ASSET_DE',
								'RWER_OPEA_HEDGING_AU')
	      union all
		  select * from [dbo].[Strolf_MOP_PLUS_REAL_CORR_EOM_IS]) r 
			where  left(PORTFOLIO_NAME,3) not in ('TS ','TS_', 'BMT' ,'RHP')-- ,'CFD' ,'SPM')
			and portfolio_name not like 'HEDGING_LEGACY_RHP%'
			and cob = (select asofdate_eom from asofdate)
			--		and  desk not in ('SCHED_DE','SCHED_BENE')
	group by [PORTFOLIO_NAME],
			[INS_TYPE_NAME],
			--case when r.[PORTFOLIO_NAME] like 'IDT%' then r.Portfolio_name  +' // '+[INS_TYPE_NAME] + case when PNL_TYPE in ('REALIZED','MATURED') then ' // '+leg_currency else '' end
			 --else 
			 case when year(REALISATION_DATE_Original) < year(COB) and REALISATION_DATE > COB then 'shift realised --> unrealised' 
			 else r.[deal_num] --end  
			 end,
			 Trade_Date,
			[EXT_BUNIT_NAME],	
			[leg_currency]



	-- ######## insert Risk-Adj into RiskRecon_CAOCE_zw1 ######## 

	BEGIN insert into [dbo].[Logfile] select 'RiskRecon_CAOCE - insert Risk adjustments', GETDATE () END

	select @step = @step + 1
	
	
	insert into dbo.[RiskRecon_CAOCE_zw1] ([Portfolio], [InstrumentType],[DealID], ccy, [risk_mtm_EOM_EUR], 
				[risk_realised_disc_EUR], [risk_realised_undisc_CCY], [source])
	select 
		[PORTFOLIO_NAME], 
		left([cat_name],1500), 
		case when description like 'Late deals%#%'
				then --case when left(portfolio_name,3) = 'IDT' then portfolio_name + ' // ' + r.currency else 
				[dbo].[udf_SplitData](Replace([DESCRIPTION], '#', ','),3 ) --end
		     when description like 'Late deal PnL%#%'
				then 
				--case when left(portfolio_name,3) = 'IDT' then portfolio_name + ' // ' + r.currency else 
				[dbo].[udf_SplitData](Replace([DESCRIPTION], '#', ','),2 ) --end
			else 'adj_'+left([DESCRIPTION],500) end as DealID, 
		r.CURRENCY as ccy,
		sum(case when PNL_TYPE = 'REALIZED' then 0 else [pnl]/fx.raterisk end) as mtm_EOM,
		sum(case when PNL_TYPE = 'REALIZED' then [pnl]/fx.raterisk else 0 end) as realised_eur,
		sum(case when PNL_TYPE = 'REALIZED' then [pnl] else 0 end) as realised_ccy,
		'ValAdj' as src
	from [dbo].[Strolf_VAL_ADJUST_EOM] r 
		inner join dbo.FXRates fx on r.currency = fx.Currency
	where left(PORTFOLIO_NAME,3) not in ('TS ','TS_', 'BMT' ,'RHP')-- ,'CFD' ,'SPM')
			and portfolio_name not like 'HEDGING_LEGACY_RHP%'
	--and left(PORTFOLIO_NAME,6) not in ('SCHED_')
	group by 
		[PORTFOLIO_NAME], left([cat_name],1500), 
		 r.CURRENCY , 
		case when description like 'Late deals%#%'
				then --case when left(portfolio_name,3) = 'IDT' then portfolio_name + ' // ' + r.currency else 
				[dbo].[udf_SplitData](Replace([DESCRIPTION], '#', ','),3 ) --end
		     when description like 'Late deal PnL%#%'
				then --case when left(portfolio_name,3) = 'IDT' then portfolio_name + ' // ' + r.currency else 
				[dbo].[udf_SplitData](Replace([DESCRIPTION], '#', ','),2 ) --end
			else 'adj_'+left([DESCRIPTION],500)  end 


	BEGIN insert into [dbo].[Logfile] select 'RiskRecon_CAOCE - update ExtBunitName Is Null', GETDATE () END
	update dbo.RiskRecon_CAOCE_zw1
	 set ExtBunitName = ''
	 where extbunitname is null


	-- ######## Korrektur für Portfolien, deren pnl nicht in der SubDesk-CCY gerechnet wird ######## 
	
	
	

	-- ######## insert RiskRecon_CAOCE füllen ######## 
	BEGIN insert into [dbo].[Logfile] select 'RiskRecon_CAOCE - fill Recon', GETDATE () END

	select @step = @step + 1
	insert into dbo.RiskRecon_CAOCE ([InternalLegalEntity], Desk, [Subdesk], [SubdeskCCY], [Portfolio], [InstrumentType], [DealID], Ticker, ExtBunitName,[ccy], [TradeDate],
				[EndDate], [finance_mtm_EOM], [finance_mtm_EOY], [finance_realised_CCY], 
				[finance_realised_EUR], [risk_mtm_EOM_EUR], [risk_mtm_EOY_EUR], 
				[risk_realised_disc_EUR], [risk_realised_undisc_CCY])
		select o.LegalEntity, o.desk, o.subdesk + case when (dealid like 'Broker%' or dealid like 'Exchange%') and r.[portfolio] not like '%Brokerage' then '_Brokerage' else '' end, o.subdeskccy, 
				r.Portfolio + case when dealid like 'physical realised%' then ' // ' + r.[ccy] else '' end, [InstrumentType], [DealID], max(Ticker), max(ExtBunitName),  ([ccy]), max([TradeDate]), max([EndDate]), 
				round(sum([finance_mtm_EOM]),2), round(sum([finance_mtm_EOY]),2),round(sum([finance_realised_CCY]),2), 
				round(sum([finance_realised_EUR]),2), round(sum([risk_mtm_EOM_EUR]),2), round(sum([risk_mtm_EOY_EUR]),2), 
				round(sum([risk_realised_disc_EUR]),2), round(sum([risk_realised_undisc_CCY]),2)
		from [dbo].[RiskRecon_CAOCE_zw1] r left join dbo.map_order o on r.portfolio = o.portfolio
			where o.LegalEntity not in ('n/a') or o.LegalEntity is null
				group by o.legalentity, o.LegalEntity, o.desk ,  o.subdesk + case when (dealid like 'Broker%' or dealid like 'Exchange%') and r.[portfolio] not like '%Brokerage' then '_Brokerage' else '' end ,
						o.subdeskccy, InstrumentType, dealid, ccy, r.Portfolio + case when dealid like 'physical realised%' then ' // ' + r.[ccy] else '' end


/*						
	BEGIN insert into [dbo].[Logfile] select 'RiskRecon_CAOCE - fill tables for export', GETDATE () END

	select @step = @step + 1

	truncate table dbo.RiskRecon_CAOCE_DealLevel_tbl 
	truncate table dbo.RiskRecon_CAOCE_RiskPNL_tbl 
	truncate table dbo.RiskRecon_CAOCE_Discounting_tbl 	
	truncate table dbo.RiskRecon_CAOCE_MtM_Overview_tbl

	select @step = @step + 1
	
	insert into dbo.RiskRecon_CAOCE_DealLevel_tbl select * from dbo.RiskRecon_CAOCE_DealLevel
	insert into dbo.RiskRecon_CAOCE_RiskPNL_tbl select * from dbo.RiskRecon_CAOCE_Riskpnl
	insert into dbo.RiskRecon_CAOCE_Discounting_tbl select * from dbo.RiskRecon_CAOCE_Discounting
	insert into dbo.RiskRecon_CAOCE_MtM_Overview_tbl select * from dbo.RiskRecon_CAOCE_MtM_Overview 
*/
	BEGIN insert into [dbo].[Logfile] select 'RiskRecon_CAOCE - COMPLETED', GETDATE () END

END TRY


	BEGIN CATCH
		--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
	END CATCH

GO

