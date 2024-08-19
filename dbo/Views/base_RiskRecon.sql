




CREATE view [dbo].[base_RiskRecon] as
	SELECT
		Desk, 
		Subdesk, 
		RevRecSubDesk,
		Portfolio,
		Portfolio_ID,
		InstrumentType,
		Ticker,
		case when InstrumentType like '%-INV-%' then InstrumentType else DealID end as DealID,
		ExtBunitName,
		Ccy,
		EndDate,
		TradeDate,
		[finance_mtm_EOM],
		[finance_mtm_EOY],
		[finance_mtm_EOM_DeskCCY],
		[finance_mtm_EOY_DeskCCY],
		[risk_mtm_EOM_EUR],
		[risk_mtm_EOY_EUR],
		[risk_mtm_EOM_repccy],
		[risk_mtm_EOY_RepCCY],
		[finance_realised_CCY],
		[finance_realised_DeskCCY],
		[finance_realised_EUR],
		[risk_realised_undisc_CCY],
		[risk_realised_disc_RepCCY],
		[risk_realised_disc_repEUR],
		([finance_mtm_EOM] -[risk_mtm_EOM_EUR] ) as Diff_mtm_EOM_EUR,
		([finance_mtm_EOY] -[risk_mtm_EOY_EUR] ) as Diff_mtm_EOY_EUR,
		([finance_mtm_EOM] -[risk_mtm_EOM_EUR]) - ([finance_mtm_EOY] -[risk_mtm_EOY_EUR] ) as Diff_mtm_EUR,
		([finance_mtm_EOM_DeskCCY] -[risk_mtm_EOM_RepCCY]) - ([finance_mtm_EOY_DeskCCY] -[risk_mtm_EOY_RepCCY] ) as Diff_mtm_DeskCCY,
		([finance_mtm_EOM_DeskCCY] -[risk_mtm_EOM_RepCCY] ) as Diff_mtm_EOM_DeskCCY,
		([finance_mtm_EOY_DeskCCY] -[risk_mtm_EOY_RepCCY] ) as Diff_mtm_EOY_DeskCCY,
		([finance_realised_CCY] -[risk_realised_undisc_CCY])  as Diff_realised_CCY,
		([finance_realised_DeskCCY] -[risk_realised_disc_RepCCY])  as Diff_realised_DeskCCY,
		([finance_realised_EUR]  - [risk_realised_disc_repEUR]) as Diff_realised_EUR,
		([finance_mtm_EOM] -[risk_mtm_EOM_EUR] +[finance_realised_EUR]  - [risk_realised_disc_repEUR]-[finance_mtm_EOY] +[risk_mtm_EOY_EUR]) as Total_Diff_EUR
	FROM 
		dbo.RiskRecon

GO

