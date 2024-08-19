


CREATE view [dbo].[RiskRecon_ROCK_Riskpnl_Rawdata_extended] as
	select 
		DESK_NAME		
		,desk
		,subdesk
		,[Internal Portfolio Name] as PORTFOLIO_NAME
		,[Instrument Type Name] as Instrument_Type_Name 
		,dbo.map_instrument.InstrumentType	
		,sum(convert(float,isnull(TOTAL_VALUE_PH_IM1_CCY_YTD,0))) as risk_PnL_YtD_RepCCY
		,sum(convert(float,isnull(REAL_DISC_PH_IM1_CCY_YTD,0))) as risk_realised_disc_RepCCY /*8*/
		,sum(convert(float,isnull(UNREAL_DISC_PH_IM1_CCY,0))) as risk_mtm_EOM_RepCCY				/*2*/
		,sum(convert(float,isnull(UNREAL_DISC_PH_IM1_CCY_LGBY,0))) as risk_mtm_EOY_RepCCY		/*5*/
		,sum(convert(float,isnull(TOTAL_VALUE_PH_BL_CCY_YTD,0))) as risk_PnL_YtD_EUR				/*?????*/
		,sum(convert(float,isnull(REAL_DISC_PH_BL_CCY_YTD,0))) as risk_realised_disc_repEUR	/*9*/
		,sum(convert(float,isnull(UNREAL_DISC_PH_BL_CCY,0))) as risk_mtm_EOM_RepEUR					/*3*/
		,sum(convert(float,isnull(UNREAL_DISC_PH_BL_CCY_LGBY,0))) as risk_mtm_EOY_RepEUR		/*6*/
		,sum(convert(float,isnull(UNREAL_DISC_BL_CCY,0))) as risk_mtm_EOM_EUR								/*1*/
		,sum(convert(float,isnull(UNREAL_DISC_BL_CCY_LGBY,0))) as risk_mtm_EOY_EUR					/*4*/
		FROM 
			---dbo.table_ROCK_RISK_PNL_Rawdata
			---left outer  join dbo.map_order on d.PORTFOLIO_NAME = map_order.portfolio
			---left outer JOIN dbo.map_instrument ON d.Instrument_Type_Name = dbo.map_instrument.InstrumentType	
			dbo.GloriRisk_ROCK
			left outer  join dbo.map_order on GloriRisk_ROCK.[Internal Portfolio Name]= map_order.portfolio				
			left outer JOIN dbo.map_instrument ON GloriRisk_ROCK.[Instrument Type Name]  = dbo.map_instrument.InstrumentType	
	where 
		desk_name in ('Dry Bulk Origination Desk')  
	group by 
		DESK_NAME
		--,PORTFOLIO_NAME		
		--Instrument_Type_Name 
		,map_instrument.InstrumentType	
		,desk
		,subdesk
		,[Internal Portfolio Name]
		,[Instrument Type Name]

GO

