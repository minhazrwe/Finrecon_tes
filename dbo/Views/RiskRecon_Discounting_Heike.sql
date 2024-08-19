




CREATE view [dbo].[RiskRecon_Discounting_Heike] as
select  Desk, r.Portfolio,r.dealid,
Subdesk, 
case when dealID like 'physical realised%' then 'phys' + case when b.ExtBunit is not null then '_' + b.ReconGroup else '' end else 'fin' end as PhysFin,
InstrumentType, 
ccy, 
sum(finance_realised_EUR) as finance_realised_EUR, 
sum(risk_realised_disc_repEUR) as risk_realised_disc_repEUR,
sum(finance_realised_EUR- risk_realised_disc_repEUR) as Diff_EUR,
sum(finance_realised_DeskCCY) as finance_realised_DeskCCY, 
sum(risk_realised_disc_RepCCY) as risk_realised_disc_DeskCCY,
sum([finance_realised_DeskCCY]- [risk_realised_disc_RepCCY]) as Diff_DeskCCY



from
dbo.[base_RiskRecon-Heike] r
left join dbo.map_ExtBunitExclude b on r.extbunitname = b.ExtBunit

where 
(abs(Diff_realised_ccy) <=100 
and abs([Diff_mtm_EOM_EUR])<=100
and abs([Diff_mtm_EOY_EUR]) <=100)

OR dealID like 'physical realised%'

group by 
Desk,r.Portfolio,r.dealid,
Subdesk,
Ccy,
case when dealID like 'physical realised%' then 'phys' + case when b.ExtBunit is not null then '_' + b.ReconGroup else '' end else 'fin' end,
InstrumentType

having
(abs(sum(finance_realised_EUR- risk_realised_disc_repEUR)) >1 or abs(sum([finance_realised_DeskCCY]- [risk_realised_disc_RepCCY])) >1)

GO

