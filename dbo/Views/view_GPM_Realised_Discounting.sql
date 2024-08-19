CREATE view [dbo].[view_GPM_Realised_Discounting] as

SELECT  d.Desk, 
		d.Subdesk, 
		Portfolio,
		d.InstrumentType,
		Ticker,
		DealID,
		ExtBunitName,
		d.Ccy,
		EndDate,
		TradeDate,
		d.PhysFin,
		[finance_realised_DeskCCY],
		[finance_realised_EUR],
		[risk_realised_disc_RepCCY],
		[risk_realised_disc_repEUR],
		Diff_EUR,
		Diff_DeskCCY
FROM 
(
	SELECT
		Desk, 
		Subdesk, 
		Portfolio,
		InstrumentType,
		Ticker,
		DealID,
		ExtBunitName,
		Ccy,
		EndDate,
		TradeDate,
	  + case when map_ExtBunitExclude.ExtBunit is not null then 
		case when Instrumenttype = 'OIL-BUNKER-ROLL-P' then 'BUNKER ROLL - ' else 
		case when Instrumenttype = 'OIL-FWD' then 'BUNKER OIL - ' else 
	    case when Instrumenttype = 'TC-FWD' then 'TC - ' else 		
	    case when Instrumenttype = 'FREIGHT-FWD' then 'VC - ' else 		
	    case when Instrumenttype = 'COMM-FEE' then 'FEE - ' else '' end end end end end
	  + map_ExtBunitExclude.ReconGroup else 
		case when Instrumenttype = 'OIL-BUNKER-ROLL-P' then 'BUNKER ROLL - external_' else '' end  end
	  + case when map_ExtBunitExclude.ExtBunit is not null then '_' else '' end 
	  + case when dealID like 'physical realised%' then 'phys' else 'fin' end as PhysFin,
		sum([finance_realised_DeskCCY]) AS [finance_realised_DeskCCY],
		sum([finance_realised_EUR]) AS [finance_realised_EUR],
		sum([risk_realised_disc_RepCCY]) AS [risk_realised_disc_RepCCY],
		sum([risk_realised_disc_repEUR]) AS [risk_realised_disc_repEUR],
		(sum(finance_realised_EUR)- sum(risk_realised_disc_repEUR)) as Diff_EUR,
		(sum([finance_realised_DeskCCY])- sum([risk_realised_disc_RepCCY])) as Diff_DeskCCY
	FROM 
		dbo.RiskRecon
		left join dbo.map_ExtBunitExclude on RiskRecon.extbunitname = map_ExtBunitExclude.ExtBunit
	WHERE 
		(dealID like 'physical realised%' or  abs([finance_realised_CCY] -[risk_realised_undisc_CCY]) <=50)
		AND Desk like 'CAO G%'
	GROUP BY 
		Desk, 
		Subdesk, 
		Portfolio,
		InstrumentType,
		Ticker,
		DealID,
		ExtBunitName,
		Ccy,
		EndDate,
		TradeDate,
	  + case when map_ExtBunitExclude.ExtBunit is not null then 
		case when Instrumenttype = 'OIL-BUNKER-ROLL-P' then 'BUNKER ROLL - ' else 
		case when Instrumenttype = 'OIL-FWD' then 'BUNKER OIL - ' else 
	    case when Instrumenttype = 'TC-FWD' then 'TC - ' else 		
	    case when Instrumenttype = 'FREIGHT-FWD' then 'VC - ' else 		
	    case when Instrumenttype = 'COMM-FEE' then 'FEE - ' else '' end end end end end
	  + map_ExtBunitExclude.ReconGroup else 
		case when Instrumenttype = 'OIL-BUNKER-ROLL-P' then 'BUNKER ROLL - external_' else '' end  end
	  + case when map_ExtBunitExclude.ExtBunit is not null then '_' else '' end 
	  + case when dealID like 'physical realised%' then 'phys' else 'fin' end		
) d left join (    SELECT	Desk, 
							Subdesk, 
						  + case when b.ExtBunit is not null then 
							case when Instrumenttype = 'OIL-BUNKER-ROLL-P' then 'BUNKER ROLL - ' else 
							case when Instrumenttype = 'OIL-FWD' then 'BUNKER OIL - ' else 
							case when Instrumenttype = 'TC-FWD' then 'TC - ' else 		
							case when Instrumenttype = 'FREIGHT-FWD' then 'VC - ' else 		
							case when Instrumenttype = 'COMM-FEE' then 'FEE - ' else '' end end end end end
						  + b.ReconGroup else 
							case when Instrumenttype = 'OIL-BUNKER-ROLL-P' then 'BUNKER ROLL - external_' else '' end  end
						  + case when b.ExtBunit is not null then '_' else '' end 
						  + case when dealID like 'physical realised%' then 'phys' else 'fin' end as PhysFin,
							InstrumentType, 
							ccy 
				   from dbo.base_riskrecon r left join dbo.map_ExtBunitExclude b on r.extbunitname = b.ExtBunit
				   where (dealID like 'physical realised%' or  abs([finance_realised_CCY] -[risk_realised_undisc_CCY]) <=50) AND Desk like 'CAO G%'
				   group by	Desk,
							Subdesk,
							Ccy,
						  + case when b.ExtBunit is not null then 
							case when Instrumenttype = 'OIL-BUNKER-ROLL-P' then 'BUNKER ROLL - ' else 
							case when Instrumenttype = 'OIL-FWD' then 'BUNKER OIL - ' else 
							case when Instrumenttype = 'TC-FWD' then 'TC - ' else 		
							case when Instrumenttype = 'FREIGHT-FWD' then 'VC - ' else 		
							case when Instrumenttype = 'COMM-FEE' then 'FEE - ' else '' end end end end end
						  + b.ReconGroup else 
							case when Instrumenttype = 'OIL-BUNKER-ROLL-P' then 'BUNKER ROLL - external_' else '' end  end
						  + case when b.ExtBunit is not null then '_' else '' end 
						  + case when dealID like 'physical realised%' then 'phys' else 'fin' end,
							InstrumentType
				   having	(abs(sum(finance_realised_EUR- risk_realised_disc_repEUR)) >1 or abs(sum([finance_realised_DeskCCY]- [risk_realised_disc_RepCCY])) >1)
				  )r ON (d.Desk = r.Desk AND d.Subdesk = r.Subdesk AND d.PhysFin = r.PhysFin AND d.InstrumentType = r.InstrumentType AND d.ccy = r.ccy) 
WHERE (d.Desk = r.Desk AND d.Subdesk = r.Subdesk AND d.PhysFin = r.PhysFin AND d.InstrumentType = r.InstrumentType AND d.ccy = r.ccy)

GO

