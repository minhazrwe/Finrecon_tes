







CREATE view [dbo].[RiskRecon_DealLevel] as
	SELECT
		Desk, 
		Subdesk, 
		RevRecSubdesk, 
		Portfolio,
		Portfolio_ID,
		InstrumentType,
		case when Ticker is null or Ticker = '' then sql.DealID else Ticker end as DealID,
		MaxCcy,
		Max(sql.MaxEndDate) as MaxEndDate,
		Max(sql.MaxTradeDate) as MaxTradeDate,
		sum([finance_mtm_EOM_EUR]) as 	finance_mtm_EOM_EUR,
		sum([finance_mtm_EOY_EUR]) as 	finance_mtm_EOY_EUR,
		sum([risk_mtm_EOM_EUR]) as 	risk_mtm_EOM_EUR,
		sum([risk_mtm_EOY_EUR]) as 	risk_mtm_EOY_EUR,
		sum([finance_mtm_EOM_DeskCCY]) as 	finance_mtm_EOM_DeskCCY,
		sum([finance_mtm_EOY_DeskCCY]) as 	finance_mtm_EOY_DeskCCY,
		sum([risk_mtm_EOM_DeskCCY]) as 	risk_mtm_EOM_DeskCCY,
		sum([risk_mtm_EOY_DeskCCY]) as 	risk_mtm_EOY_DeskCCY,

		sum([finance_realised_CCY]) as 	finance_realised_CCY,
		sum([finance_realised_DeskCCY]) as 	finance_realised_DeskCCY,
		sum([finance_realised_EUR]) as 	finance_realised_EUR,

		sum([risk_realised_undisc_CCY]) as 	risk_realised_undisc_CCY,
		sum([risk_realised_disc_DeskCCY]) as 	risk_realised_disc_DeskCCY,
		sum([risk_realised_disc_repEUR]) as 	risk_realised_disc_repEUR,

		sum([Diff_mtm_EOM_EUR]) as Diff_mtm_EOM_EUR,
		sum([Diff_mtm_eoy_EUR]) as Diff_mtm_EOY_EUR,
		sum([Diff_mtm_EUR]) as Diff_mtm_EUR,
		sum([Diff_mtm_DeskCCY]) as Diff_mtm_DeskCCY,

		sum([Diff_realised_CCY])  as Diff_realised_CCY,
		sum([Diff_realised_DeskCCY])  as Diff_realised_DeskCCY,
		sum([Diff_realised_EUR]) as Diff_realised_EUR,
		sum([Total_Diff_EUR]) as Total_Diff_EUR, 
		abs(sum(total_diff_eur)) as AbsTotal_Diff_EUR

	FROM
		(
			SELECT 
				Desk, 
				Subdesk, 
				RevRecSubDesk,
				Max(Portfolio) as Portfolio,
				Max(Portfolio_ID) as Portfolio_ID,
				Max(InstrumentType) as InstrumentType,
				case when InstrumentType like '%-INV-%' then InstrumentType else replace(DealID, '_sc','') end as DealID,
				Max(Ticker) as Ticker,
				Max(ccy) as MaxCcy,
				Max(EndDate) as MaxEndDate,
				Max(TradeDate) as MaxTradeDate,
				round(sum([finance_mtm_EOM]),0) as 	finance_mtm_EOM_EUR,
				round(sum([finance_mtm_EOY]),0) as 	finance_mtm_EOY_EUR,
				round(sum([risk_mtm_EOM_EUR]),0) as 	risk_mtm_EOM_EUR,
				round(sum([risk_mtm_EOY_EUR]),0) as 	risk_mtm_EOY_EUR,
				round(sum([finance_mtm_EOM_DeskCCY]),0) as 	finance_mtm_EOM_DeskCCY,
				round(sum([finance_mtm_EOY_DeskCCY]),0) as 	finance_mtm_EOY_DeskCCY,
				round(sum([risk_mtm_EOM_repCCY]),0) as 	risk_mtm_EOM_DeskCCY,
				round(sum([risk_mtm_EOY_repCCY]),0) as 	risk_mtm_EOY_DeskCCY,

				round(sum([finance_realised_CCY]),0) as 	finance_realised_CCY,
				round(sum([finance_realised_DeskCCY]),0) as 	finance_realised_DeskCCY,
				round(sum([finance_realised_EUR]),0) as 	finance_realised_EUR,

				round(sum([risk_realised_undisc_CCY]),0) as 	risk_realised_undisc_CCY,
				round(sum([risk_realised_disc_RepCCY]),0) as 	risk_realised_disc_DeskCCY,
				round(sum([risk_realised_disc_repEUR]),0) as 	risk_realised_disc_repEUR,

				round(sum([Diff_mtm_EOM_EUR] ),0) as Diff_mtm_EOM_EUR,
				round(sum([Diff_mtm_EOY_EUR] ),0) as Diff_mtm_EOY_EUR,
				round(sum(Diff_mtm_EUR),0) as Diff_mtm_EUR,
				round(sum(Diff_mtm_DeskCCY),0) as Diff_mtm_DeskCCY,

				round(sum([Diff_realised_CCY]),0)  as Diff_realised_CCY,
				round(sum([Diff_realised_DeskCCY]),0)  as Diff_realised_DeskCCY,
				round(sum([Diff_realised_EUR]),0) as Diff_realised_EUR,
				round(sum(Total_Diff_EUR),0) as Total_Diff_EUR, 
				round(abs(sum([Total_Diff_EUR])),0) as AbsTotal_Diff_EUR
			FROM
				dbo.base_riskrecon
			WHERE
				dealId not like 'physical realised%' 
			GROUP BY 
				Desk, 
				Subdesk,
				RevRecSubDesk,
				case when InstrumentType like '%-INV-%' then InstrumentType else replace(DealID, '_sc','') end 
			HAVING
					 abs(sum([finance_mtm_EOM] -[risk_mtm_EOM_EUR] )) >50
				or abs(sum([finance_mtm_EOY] -[risk_mtm_EOY_EUR] )) >50
				or abs(sum([finance_realised_CCY] -[risk_realised_undisc_CCY])) >50
		) as sql
	GROUP BY 
		Desk, 
		Subdesk, 
		RevRecSubDesk,
		Portfolio,
		Portfolio_ID,
		InstrumentType,
		Maxccy,
		case when Ticker is null or Ticker = '' then sql.DealID else Ticker end

GO

