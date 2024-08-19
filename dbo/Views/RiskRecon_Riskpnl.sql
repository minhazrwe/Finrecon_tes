



CREATE view [dbo].[RiskRecon_Riskpnl] as
	select 
		 Desk 
		,Subdesk
		,RevRecSubdesk
		,Subdeskccy
		,sum(isnull(TOTAL_VALUE_PH_IM1_CCY_YTD,0)) as risk_PnL_YtD_RepCCY			/* calc --> new 11 */
		,sum(isnull(REAL_DISC_PH_IM1_CCY_YTD,0)) as risk_realised_disc_RepCCY		/* 8	--> new 14 */
		,sum(isnull(risk_mtm_EOM_RepCCY,0)) as risk_mtm_EOM_RepCCY					/* 2	--> new 15: UNREAL_DISC_PH_IM1_CCY */
		,sum(isnull(risk_mtm_EOY_RepCCY,0)) as risk_mtm_EOY_RepCCY					/* 5	--> new 16: UNREAL_DISC_PH_IM1_CCY_LGBY */
		,sum(isnull(TOTAL_VALUE_PH_BL_CCY_YTD,0)) as risk_PnL_YtD_EUR				/* calc --> new 12 */
		,sum(isnull(REAL_DISC_PH_BL_CCY_YTD,0)) as risk_realised_disc_repEUR		/* 9	--> new 13*/
		,sum(isnull(risk_mtm_EOM_RepEUR,0)) as risk_mtm_EOM_RepEUR					/* 3	--> new 17: UNREAL_DISC_PH_BL_CCY*/
		,sum(isnull(risk_mtm_EOY_RepEUR,0)) as risk_mtm_EOY_RepEUR					/* 6	--> new 18: UNREAL_DISC_PH_BL_CCY_LGBY */
		,sum(isnull(risk_mtm_EOM_EUR,0)) as risk_mtm_EOM_EUR						/* 1	--> new 19: UNREAL_DISC_BL_CCY */
		,sum(isnull(risk_mtm_EOY_EUR,0)) as risk_mtm_EOY_EUR						/* 4	--> new 20: UNREAL_DISC_BL_CCY_LGBY */
from 
		dbo.riskrecon
--where desk like ('%dry%')  
group by 
		Desk, 
		Subdesk, 
		RevRecSubdesk,
		Subdeskccy

GO

