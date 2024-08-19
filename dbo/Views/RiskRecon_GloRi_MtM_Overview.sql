









CREATE view [dbo].[RiskRecon_GloRi_MtM_Overview] as
select 
case when (ft.internalportfolio in ('NG_OPTION_DELTA_EUR', 'NG_OPTION_XCOMM_EUR', 'NG_VANILLA_OPTIONS_EUR', 'NG_OPTION_DELTA_GBP', 'NG_VANILLA_OPTIONS_GBP')) then 'GPG - Global Options' else ft.desk end as desk, 
case when (ft.internalportfolio in ('NG_OPTION_DELTA_EUR', 'NG_OPTION_XCOMM_EUR', 'NG_VANILLA_OPTIONS_EUR', 'NG_OPTION_DELTA_GBP', 'NG_VANILLA_OPTIONS_GBP')) then 'GLOBAL OPTIONS '+ft.SubDeskCCY else ft.subdesk end as subdesk, 
ft.InternalPortfolio,
AccountingTreatment,

case when  b.ExtBunit is not null then 
		case when ft.Instrumenttype = 'OIL-BUNKER-ROLL-P' then 'BUNKER ROLL - ' else 
	 	 case when ft.Instrumenttype = 'OIL-FWD' then 'BUNKER OIL - ' else 
	     case when ft.Instrumenttype = 'TC-FWD' then 'TC - ' else 		
	     case when ft.Instrumenttype = 'FREIGHT-FWD' then 'VC - ' else 		
	     case when ft.Instrumenttype = 'COMM-FEE' then 'FEE - ' else '' end end end end end
	+    b.ReconGroup else 
	case when ft.strategy = 'Power Continental' and (I.nonvalueadded = 1 or ft.internalportfolio like 'Credit%' or  ft.internalportfolio like 'FV_%') then 'x' else
	case when sbma.allocationcomment is null then  '' else sbma.allocationcomment end end end as nonVA,

case when TermEnd <= dbo.asofdate.[asofdate_eom] then 'Unwind' else 
case when Year(TermEnd) = Year(dbo.asofdate.[asofdate_eom]) then 'CurrentYear' else
case when Year(TermEnd) = Year(dbo.asofdate.[asofdate_eom])+1 then 'NextYear' else 'SecondNextYear_ff' end end end as unwind,

sum(mtm_finance_total)	 as 	mtm_finance_total_EUR	,
sum(prevYE_mtm_finance_total)	 as 	prevYE_mtm_finance_total_EUR,
sum(mtm_finance_OCI	)	 as 	mtm_finance_OCI_EUR,
sum(mtm_finance_PNL	)	 as 	mtm_finance_PNL_EUR,
sum(mtm_finance_OU	)	 as 	mtm_finance_OU_EUR,	
sum(mtm_finance_NOR	)	 as 	mtm_finance_NOR_EUR,
sum(ytd_mtm_finance_total) as 	ytd_mtm_finance_total_EUR,
sum([ytd_mtm_finance_OCI])	as ytd_mtm_finance_OCI_EUR,
sum([ytd_mtm_finance_PNL]) as ytd_mtm_finance_PNL_EUR,
sum([ytd_mtm_finance_OU]) as ytd_mtm_finance_OU_EUR	,
sum([ytd_mtm_finance_NOR]) as ytd_mtm_finance_NOR_EUR	,

sum(mtm_finance_total_DeskCCY)	 as 	mtm_finance_total_DeskCCY,
sum(prevYE_mtm_finance_total_DeskCCY)	 as 	prevYE_mtm_finance_total_DeskCCY,
sum(mtm_finance_OCI_DeskCCY)	 as 	mtm_finance_OCI_DeskCCY,
sum(mtm_finance_PNL_DeskCCY)	 as 	mtm_finance_PNL_DeskCCY,
sum(mtm_finance_OU_DeskCCY)	 as 	mtm_finance_OU_DeskCCY,	
sum(mtm_finance_NOR_DeskCCY)	 as 	mtm_finance_NOR_DeskCCY,
sum(ytd_mtm_finance_total_DeskCCY) as 	ytd_mtm_finance_total_DeskCCY,
sum([ytd_mtm_finance_OCI_DeskCCY])	as ytd_mtm_finance_OCI_DeskCCY,
sum([ytd_mtm_finance_PNL_DeskCCY]) as ytd_mtm_finance_PNL_DeskCCY,
sum([ytd_mtm_finance_OU_DeskCCY]) as ytd_mtm_finance_OU_DeskCCY,	
sum([ytd_mtm_finance_NOR_DeskCCY]) as ytd_mtm_finance_NOR_DeskCCY
from dbo.fastracker_ytd ft
 left join dbo.map_instrument i on ft.instrumenttype = i.instrumenttype
 left join dbo.map_sbm_allocation sbma on ft.internalportfolio = sbma.internalportfolio and ft.counterpartygroup=sbma.counterpartygroup and ft.instrumenttype = sbma.instrumenttype and ft.projindexgroup = sbma.projectionindexgroup
 left join dbo.map_ExtBunitExclude b on ft.externalbusinessunit = b.ExtBunit

, dbo.asofdate 




group by
case when (ft.internalportfolio in ('NG_OPTION_DELTA_EUR', 'NG_OPTION_XCOMM_EUR', 'NG_VANILLA_OPTIONS_EUR', 'NG_OPTION_DELTA_GBP', 'NG_VANILLA_OPTIONS_GBP')) then 'GPG - Global Options' else ft.desk end  , 
case when (ft.internalportfolio in ('NG_OPTION_DELTA_EUR', 'NG_OPTION_XCOMM_EUR', 'NG_VANILLA_OPTIONS_EUR', 'NG_OPTION_DELTA_GBP', 'NG_VANILLA_OPTIONS_GBP')) then 'GLOBAL OPTIONS '+ft.SubDeskCCY else ft.subdesk end , 
ft.InternalPortfolio,
sbma.allocationcomment,
AccountingTreatment,
	case when b.ExtBunit is not null then 
		case when ft.Instrumenttype = 'OIL-BUNKER-ROLL-P' then 'BUNKER ROLL - ' else 
	 	 case when ft.Instrumenttype = 'OIL-FWD' then 'BUNKER OIL - ' else 
	     case when ft.Instrumenttype = 'TC-FWD' then 'TC - ' else 		
	     case when ft.Instrumenttype = 'FREIGHT-FWD' then 'VC - ' else 		
	     case when ft.Instrumenttype = 'COMM-FEE' then 'FEE - ' else '' end end end end end
	+    b.ReconGroup else 
		case when ft.strategy = 'Power Continental' and (I.nonvalueadded = 1 or ft.internalportfolio like 'Credit%' or  ft.internalportfolio like 'FV_%') then 'x' else
	case when sbma.allocationcomment is null then  '' else sbma.allocationcomment end end end,
case when TermEnd <= dbo.asofdate.[asofdate_eom] then 'Unwind' else 
case when Year(TermEnd) = Year(dbo.asofdate.[asofdate_eom]) then 'CurrentYear' else
case when Year(TermEnd) = Year(dbo.asofdate.[asofdate_eom])+1 then 'NextYear' else 'SecondNextYear_ff' end end end

GO

