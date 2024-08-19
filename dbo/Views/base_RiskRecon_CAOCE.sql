



CREATE view [dbo].[base_RiskRecon_CAOCE] as
Select 
Desk, 
Subdesk, 
Portfolio,
InstrumentType,
Ticker,
case when InstrumentType like '%-INV-%' then InstrumentType else DealID end as DealID,
ExtBunitName,
Ccy,
EndDate,
TradeDate,
[finance_mtm_EOM],
[finance_mtm_EOY],
[risk_mtm_EOM_EUR],
[risk_mtm_EOY_EUR],
[finance_realised_CCY],
[finance_realised_EUR],
[risk_realised_undisc_CCY],
[risk_realised_disc_EUR],
([finance_mtm_EOM] -[risk_mtm_EOM_EUR] ) as Diff_mtm_EOM_EUR,
([finance_mtm_EOY] -[risk_mtm_EOY_EUR] ) as Diff_mtm_EOY_EUR,
([finance_mtm_EOM] -[risk_mtm_EOM_EUR]) - ([finance_mtm_EOY] -[risk_mtm_EOY_EUR] ) as Diff_mtm_EUR,
([finance_realised_CCY] -[risk_realised_undisc_CCY])  as Diff_realised_CCY,
([finance_realised_EUR]  - [risk_realised_disc_EUR]) as Diff_realised_EUR,
([finance_mtm_EOM] -[risk_mtm_EOM_EUR] +[finance_realised_EUR]  - [risk_realised_disc_EUR]-[finance_mtm_EOY] +[risk_mtm_EOY_EUR]) as Total_Diff_EUR

from dbo.RiskRecon_CAOCE

GO

