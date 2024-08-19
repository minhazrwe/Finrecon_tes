







CREATE view [dbo].[RiskRecon_GloRi_Discounting] as
select  Desk, 
Subdesk, 
	+ case when b.ExtBunit is not null then 
		 case when Instrumenttype = 'OIL-BUNKER-ROLL-P' then 'BUNKER ROLL - ' else 
		 case when Instrumenttype = 'OIL-FWD' then 'BUNKER OIL - ' else 
	     case when Instrumenttype = 'TC-FWD' then 'TC - ' else 		
	     case when Instrumenttype = 'FREIGHT-FWD' then 'VC - ' else 		
	     case when Instrumenttype = 'COMM-FEE' then 'FEE - ' else '' end end end end end
	+    b.ReconGroup else 
		 case when Instrumenttype = 'OIL-BUNKER-ROLL-P' then 'BUNKER ROLL - external_' else '' end  end
	+   case when b.ExtBunit is not null then '_' else '' end 
	+   case when dealID like 'physical realised%' then 'phys' else 'fin' end as PhysFin,
InstrumentType, 
ccy, 
sum(finance_realised_EUR) as finance_realised_EUR, 
sum(risk_realised_disc_repEUR) as risk_realised_disc_repEUR,
sum(finance_realised_EUR- risk_realised_disc_repEUR) as Diff_EUR,
sum(finance_realised_DeskCCY) as finance_realised_DeskCCY, 
sum(risk_realised_disc_RepCCY) as risk_realised_disc_DeskCCY,
sum([finance_realised_DeskCCY]- [risk_realised_disc_RepCCY]) as Diff_DeskCCY



from
dbo.base_riskrecon r
left join dbo.map_ExtBunitExclude b on r.extbunitname = b.ExtBunit

where 
(dealID like 'physical realised%'
or  abs([finance_realised_CCY] -[risk_realised_undisc_CCY]) <=50)

group by 
Desk,
Subdesk,
Ccy,
	+ case when b.ExtBunit is not null then 
		 case when Instrumenttype = 'OIL-BUNKER-ROLL-P' then 'BUNKER ROLL - ' else 
		 case when Instrumenttype = 'OIL-FWD' then 'BUNKER OIL - ' else 
	     case when Instrumenttype = 'TC-FWD' then 'TC - ' else 		
	     case when Instrumenttype = 'FREIGHT-FWD' then 'VC - ' else 		
	     case when Instrumenttype = 'COMM-FEE' then 'FEE - ' else '' end end end end end
	+    b.ReconGroup else 
		 case when Instrumenttype = 'OIL-BUNKER-ROLL-P' then 'BUNKER ROLL - external_' else '' end  end
	+   case when b.ExtBunit is not null then '_' else '' end 
	+   case when dealID like 'physical realised%' then 'phys' else 'fin' end,
InstrumentType

having
(abs(sum(finance_realised_EUR- risk_realised_disc_repEUR)) >1 or abs(sum([finance_realised_DeskCCY]- [risk_realised_disc_RepCCY])) >1)

GO

