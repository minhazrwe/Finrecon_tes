

CREATE view [dbo].[RiskRecon_ROCK_Riskpnl_Rawdata] as
	select 
		Desk
		,Subdesk
		,Subdeskccy
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
	from 
		dbo.table_ROCK_RISK_PNL_Rawdata
		left outer join dbo.[00_map_order] on table_ROCK_RISK_PNL_Rawdata.PORTFOLIO_NAME = [00_map_order].MaxvonPortfolio
	group by 
		DESK
		,Subdesk 
		,Subdeskccy



--/*old glori approach */

--/*a*/ sum([risk_mtm_EOM_RepCCY]-[risk_mtm_EOY_RepCCY]+[risk_realised_disc_RepCCY]) as risk_PnL_YtD_RepCCY,
--/*b*/ sum([risk_realised_disc_RepCCY]) as risk_realised_disc_RepCCY,
--/*c*/ sum([risk_mtm_EOM_RepCCY]) as risk_mtm_EOM_RepCCY,
--/*d*/ sum([risk_mtm_EOY_RepCCY]) as risk_mtm_EOY_RepCCY,
--/*e*/ sum([risk_mtm_EOM_RepEUR]-[risk_mtm_EOY_RepEUR]+[risk_realised_disc_RepEUR]) as risk_PnL_YtD_EUR,
--/*f*/ sum([risk_realised_disc_repEUR]) as risk_realised_disc_repEUR,
--/*g*/ sum([risk_mtm_EOM_RepEUR]) as risk_mtm_EOM_RepEUR,
--/*h*/ sum([risk_mtm_EOY_RepEUR]) as risk_mtm_EOY_RepEUR,
--/*i*/ sum([risk_mtm_EOM_EUR]) as risk_mtm_EOM_EUR,
--/*j*/ sum([risk_mtm_EOY_EUR]) as risk_mtm_EOY_EUR

GO

