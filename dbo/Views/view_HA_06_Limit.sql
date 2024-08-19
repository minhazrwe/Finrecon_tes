

create view dbo.view_HA_06_Limit as
	SELECT 
		AsofDate, 
		Subsidiary, 
		Desk, 
		InternalPortfolio, 
		CounterpartyGroup, 
		InstrumentType, 
		case when InstrumentType like 'PWR%' then 'Electricity' else projindexgroup end as ProjectionIndex, 
		CurveName, 
		ExtPortfolio, 
		AccountingTreatment, 
		Year(termend) AS Termend_Jahr, 
		sum(VolumeAvailable+VolumeUsed) AS Volume, 
		UOM,
		sum(Total_mtm) AS MtM
	FROM 
		dbo.FASTracker_EOM
	Where
		Subsidiary='RWEST DE' 
		AND 
		(
			(
				CounterpartyGroup like 'InterPE%'
				AND projindexgroup = 'Emissions'
				AND AccountingTreatment In ('Hedged Items','Own Use')
			)
			OR 
			(
				projindexgroup = 'Electricity' 
				and desk = 'CAO Power' 
				and CounterpartyGroup not In ('Intradesk','Interdesk_NON_IAS','Interdesk') 
				and Internalportfolio not in ('RWEG_RETAIL_INDIVIDUAL','RWEP_RETAIL_INDIVIDUAL')
				AND AccountingTreatment In ('Own Use')
			)
			OR 
			(
				InstrumentType like 'PWR-FWD%' 
				and Internalportfolio  in ('RWEP_RETAIL_INDIVIDUAL') 
				and ExtPortfolio In ('CS_STRATEGIC_CE_DBAHN', 'CS_STRATEGIC_CE_DOW')
			)
		)
	GROUP BY 
		AsofDate, 
		Subsidiary, 
		Desk,
		InternalPortfolio, 
		CounterpartyGroup, 
		InstrumentType, 
		case when InstrumentType like 'PWR%' then 'Electricity' else [projindexgroup] end,
		CurveName, 
		ExtPortfolio, 
		AccountingTreatment, 
		Year(termend), 
		UOM

GO

