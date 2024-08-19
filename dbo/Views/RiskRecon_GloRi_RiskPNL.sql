

create view [dbo].[RiskRecon_GloRi_RiskPNL] as
select 
Desk, 
Subdesk, 
Subdeskccy,
sum([risk_mtm_EOM_RepCCY]-[risk_mtm_EOY_RepCCY]+[risk_realised_disc_RepCCY]) as risk_PnL_YtD_RepCCY,
sum([risk_realised_disc_RepCCY]) as risk_realised_disc_RepCCY,
sum([risk_mtm_EOM_RepCCY]) as risk_mtm_EOM_RepCCY,
sum([risk_mtm_EOY_RepCCY]) as risk_mtm_EOY_RepCCY,
sum([risk_mtm_EOM_RepEUR]-[risk_mtm_EOY_RepEUR]+[risk_realised_disc_RepEUR]) as risk_PnL_YtD_EUR,
sum([risk_realised_disc_repEUR]) as risk_realised_disc_repEUR,
sum([risk_mtm_EOM_RepEUR]) as risk_mtm_EOM_RepEUR,
sum([risk_mtm_EOY_RepEUR]) as risk_mtm_EOY_RepEUR,
sum([risk_mtm_EOM_EUR]) as risk_mtm_EOM_EUR,
sum([risk_mtm_EOY_EUR]) as risk_mtm_EOY_EUR



from dbo.riskrecon

group by 

Desk, 
Subdesk, 
Subdeskccy

GO

