

CREATE  view [dbo].[RiskRecon_CAOCE_DealLevel] as
select 
	Desk, 
	Subdesk, 
	Portfolio,
	InstrumentType,
	case     when Portfolio in ('RWEP_B2B','LTT_DE_NONP_NU_FINH_23','LTT_DE_CARBON_BOOK') 
			   or portfolio like 'LTT_DE_CAL_SPREA%'
			   or portfolio like 'LTT_DE_NONP_CARBON%'
			   or portfolio like 'LTT_DE_NONP_STRATEGY%'
			   or instrumenttype = 'CASH' 
			   then portfolio +'//'+ InstrumentType else
		case when portfolio like 'LTT_DE_IRS%' or  portfolio like 'CAD_DE_IRS%' then portfolio +'//'+ InstrumentType + '//' + extBunitName else
		case when InstrumentType in ('FX') then InstrumentType + cast ( year(maxenddate) as nvarchar) +'/'+ cast (month(maxenddate) as nvarchar) else
		case when InstrumentType in ('CASH') then InstrumentType else
		case when maxtradedate> cob then 'LateDeals' else
		case when Ticker is null or Ticker = '' then sql.DealID else Ticker  end end end end end end as DealID,
	MaxCcy,
	Max(sql.MaxEndDate) as MaxEndDate,
	Max(sql.MaxTradeDate) as MaxTradeDate,
	sum([finance_mtm_EOM_EUR]) as 	finance_mtm_EOM_EUR,
	sum([finance_mtm_EOY_EUR]) as 	finance_mtm_EOY_EUR,
	sum([risk_mtm_EOM_EUR]) as 	risk_mtm_EOM_EUR,
	sum([risk_mtm_EOY_EUR]) as 	risk_mtm_EOY_EUR,
	sum([finance_realised_CCY]) as 	finance_realised_CCY,
	sum([finance_realised_EUR]) as 	finance_realised_EUR,
	sum([risk_realised_undisc_CCY]) as 	risk_realised_undisc_CCY,
	sum([risk_realised_disc_EUR]) as risk_realised_disc_EUR,
	sum([Diff_mtm_EOM_EUR]) as Diff_mtm_EOM_EUR,
	sum([Diff_mtm_eoy_EUR]) as Diff_mtm_EOY_EUR,
	sum([Diff_mtm_EUR]) as Diff_mtm_EUR,
	sum([Diff_realised_CCY])  as Diff_realised_CCY,
	sum([Diff_realised_EUR]) as Diff_realised_EUR,
	sum([Total_Diff_EUR]) as Total_Diff_EUR, 
	abs(sum(total_diff_eur)) as AbsTotal_Diff_EUR
from
	(
	select
		AsOfDate_EOM as COB, 
		Desk, 
		Subdesk, 
		Portfolio,
		Max(InstrumentType) as InstrumentType,	
		max(isnull(extbunitname,'')) as extbunitname,
		case when InstrumentType like '%-INV-%' then InstrumentType else replace(DealID, '_sc','') end as DealID,
		Max(Ticker) as Ticker,
		Max(ccy) as MaxCcy,
		Max(EndDate) as MaxEndDate,
		Max(TradeDate) as MaxTradeDate,
		round(sum([finance_mtm_EOM]),0) as 	finance_mtm_EOM_EUR,
		round(sum([finance_mtm_EOY]),0) as 	finance_mtm_EOY_EUR,
		round(sum([risk_mtm_EOM_EUR]),0) as 	risk_mtm_EOM_EUR,
		round(sum([risk_mtm_EOY_EUR]),0) as 	risk_mtm_EOY_EUR,
		round(sum([finance_realised_CCY]),0) as 	finance_realised_CCY,
		round(sum([finance_realised_EUR]),0) as 	finance_realised_EUR,
		round(sum([risk_realised_undisc_CCY]),0) as 	risk_realised_undisc_CCY,
		round(sum([risk_realised_disc_EUR]),0) as [risk_realised_disc_EUR],
		round(sum([Diff_mtm_EOM_EUR] ),0) as Diff_mtm_EOM_EUR,
		round(sum([Diff_mtm_EOY_EUR] ),0) as Diff_mtm_EOY_EUR,
		round(sum(Diff_mtm_EUR),0) as Diff_mtm_EUR,
		round(sum([Diff_realised_CCY]),0)  as Diff_realised_CCY,
		round(sum([Diff_realised_EUR]),0) as Diff_realised_EUR,
		round(sum(Total_Diff_EUR),0) as Total_Diff_EUR, 
		round(abs(sum([Total_Diff_EUR])),0) as AbsTotal_Diff_EUR
	from 
		dbo.base_riskrecon_caoce, 
		dbo.asofdate
	group by 
		AsOfDate_EOM,
		Desk,
		Subdesk,
		Portfolio,
		case when InstrumentType like '%-INV-%' then InstrumentType else replace(DealID, '_sc','') end 
	having
		--abs(sum([finance_mtm_EOM] -[risk_mtm_EOM_EUR] )) >50 or 
		abs(sum([finance_realised_CCY] -[risk_realised_undisc_CCY])) >50
	) as sql
group by
	Desk, 
	Subdesk, 
	Portfolio,
	InstrumentType,
	Maxccy,
	case     when Portfolio in ('RWEP_B2B','LTT_DE_NONP_NU_FINH_23','LTT_DE_CARBON_BOOK') 
						 or portfolio like 'LTT_DE_CAL_SPREA%'
				 		 or portfolio like 'LTT_DE_NONP_CARBON%'
						 or portfolio like 'LTT_DE_NONP_STRATEGY%'
						 or instrumenttype = 'CASH' 
			   then portfolio +'//'+ InstrumentType else
		case when portfolio like 'LTT_DE_IRS%' or portfolio like 'CAD_DE_IRS%' then portfolio +'//'+ InstrumentType + '//' + extBunitName else
		case when InstrumentType in ('FX') then InstrumentType + cast ( year(maxenddate) as nvarchar) +'/'+ cast (month(maxenddate) as nvarchar) else
		case when InstrumentType in ('CASH') then InstrumentType else
		case when maxtradedate> cob then 'LateDeals' else
		case when Ticker is null or Ticker = '' then sql.DealID else Ticker end  end end end end end
having 
	sum([Diff_realised_EUR]) <>0

GO

