












CREATE VIEW [dbo].[view_strolf_mtm_check_CS_FASTracker] AS 
SELECT CONVERT(date, FASTracker.AsOfDate) AS AsOfDate
	,map_SBM.strategy AS Desk
	,map_order.subdesk AS Subdesk
	,FASTracker.termend AS EndDate
	,Replace(FASTracker.[internalportfolio], 'v8_', '') AS Portfolio
	,FASTracker.Counterparty_ExtBunit AS ExternalBusinessUnit
	,FASTracker.CounterpartyGroup
	,FASTracker.CurveName
	,FASTracker.ProjIndexGroup
	,FASTracker.InstrumentType
	,FASTracker.ExtLegalEntity AS ExternalLegal
	,map_SBM.AccountingTreatment
	--,FASTracker.ReferenceID
	,Sum(FASTracker.Discounted_MTM) AS Total_Mtm
	,Sum(IIf([AccountingTreatment] = 'Hedging Instrument (Der)', IIf(Left([unrealizedEarnings], 4) = 'I233', 0, [Discounted_PNL]), 0)) AS PNL
	,Sum(IIf([AccountingTreatment] = 'Hedging Instrument (Der)', IIf(Left([unrealizedEarnings], 4) = 'I233', [Discounted_mtm], [Discounted_AOCI]), 0)) AS OCI
	,IIf((
			(
				[UnrealizedEarnings] LIKE '%HS1000%'
				OR [UnrealizedEarnings] LIKE '%HBS1000%'
				OR [UnrealizedEarnings] LIKE '%10078188%'
				)
			AND FASTracker.[projindexgroup] IN (
				'Electricity'
				,'Other'
				)
			)
		OR (
			FASTracker.[InternalPortfolio] = 'SPM_LT_PWR_ML_OU'
			AND FASTracker.[instrumenttype] LIKE 'PWR-OPT%'
			AND FASTracker.[ExtLegalEntity] LIKE 'KOEHLER KEHL'
			)
		OR (
			FASTracker.[InternalPortfolio] = 'SPM_LT_PWR_NL_CERT'
			AND FASTracker.[instrumenttype] = 'REN-FWD-P'
			), 'NE', IIf([accountingtreatment] = 'Hedging Instrument (Der)'
			AND FASTracker.[InternalPortfolio] = 'RES_BE', 'NE NWII', IIf([accountingtreatment] = 'Hedging Instrument (Der)'
			AND FASTracker.[InternalPortfolio] LIKE 'RES_%', 'NE EM-FWD-P', IIf([accountingtreatment] = 'Hedging Instrument (Der)'
				AND FASTracker.[InstrumentType] = 'EM-FWD-P', 'NE EM-FWD-P', IIf([accountingtreatment] = 'Hedging Instrument (Der)'
					AND FASTracker.[InstrumentType] = 'REN-FWD-P'
					AND FASTracker.[InternalPortfolio] <> 'SPM_LT_PWR_NL_CERT', 'NE EM-FWD-P', IIf([accountingtreatment] = 'Hedging Instrument (Der)'
						AND FASTracker.[InstrumentType] = 'EM-FUT-EXCH-P'
						AND FASTracker.[InternalPortfolio] = 'CFD_SF_CAB_OU', 'NE EM-FWD-P', IIF([accountingtreatment] = 'Hedging INstrument (Der)'
							AND FASTracker.[InternalPortfolio] LIKE 'SPM_TPB%', 'NE_TBP', ''))))))) AS NE
	,Sum(FASTracker.Volume) AS Volume
	,FASTracker.UOM
	,map_order.OrderNo
	,year(FASTracker.termend) AS Jahr
	,month(FASTracker.termend) AS Monat
FROM FASTracker INNER JOIN map_SBM ON (FASTracker.InternalPortfolio = map_SBM.[InternalPortfolio])
			AND (FASTracker.CounterpartyGroup = map_SBM.[CounterpartyGroup])
			AND (FASTracker.InstrumentType = map_SBM.[InstrumentType])
			AND (FASTracker.ProjIndexGroup = map_SBM.[ProjectionIndexGroup])
LEFT JOIN map_order ON FASTracker.[InternalPortfolio] = map_order.[Portfolio]
WHERE map_SBM.strategy = 'Commodity Solutions'
	AND map_SBM.Subsidiary = 'RWEST DE'
	AND FASTracker.[InternalPortfolio] NOT LIKE 'CreditProv%'
GROUP BY CONVERT(date, FASTracker.AsOfDate)
	,map_SBM.strategy
	,map_order.subdesk
	,FASTracker.termend
	,Replace(FASTracker.[internalportfolio], 'v8_', '')
	,FASTracker.Counterparty_ExtBunit
	,FASTracker.CounterpartyGroup
	,FASTracker.CurveName
	,FASTracker.ProjIndexGroup
	,FASTracker.InstrumentType
	,FASTracker.ExtLegalEntity
	,map_SBM.AccountingTreatment
	--,FASTracker.ReferenceID
	,IIf((
			(
				[UnrealizedEarnings] LIKE '%HS1000%'
				OR [UnrealizedEarnings] LIKE '%HBS1000%'
				OR [UnrealizedEarnings] LIKE '%10078188%'
				)
			AND FASTracker.[projindexgroup] IN (
				'Electricity'
				,'Other'
				)
			)
		OR (
			FASTracker.[InternalPortfolio] = 'SPM_LT_PWR_ML_OU'
			AND FASTracker.[instrumenttype] LIKE 'PWR-OPT%'
			AND FASTracker.[ExtLegalEntity] LIKE 'KOEHLER KEHL'
			)
		OR (
			FASTracker.[InternalPortfolio] = 'SPM_LT_PWR_NL_CERT'
			AND FASTracker.[instrumenttype] = 'REN-FWD-P'
			), 'NE', IIf([accountingtreatment] = 'Hedging Instrument (Der)'
			AND FASTracker.[InternalPortfolio] = 'RES_BE', 'NE NWII', IIf([accountingtreatment] = 'Hedging Instrument (Der)'
			AND FASTracker.[InternalPortfolio] LIKE 'RES_%', 'NE EM-FWD-P', IIf([accountingtreatment] = 'Hedging Instrument (Der)'
				AND FASTracker.[InstrumentType] = 'EM-FWD-P', 'NE EM-FWD-P', IIf([accountingtreatment] = 'Hedging Instrument (Der)'
					AND FASTracker.[InstrumentType] = 'REN-FWD-P'
					AND FASTracker.[InternalPortfolio] <> 'SPM_LT_PWR_NL_CERT', 'NE EM-FWD-P', IIf([accountingtreatment] = 'Hedging Instrument (Der)'
						AND FASTracker.[InstrumentType] = 'EM-FUT-EXCH-P'
						AND FASTracker.[InternalPortfolio] = 'CFD_SF_CAB_OU', 'NE EM-FWD-P', IIF([accountingtreatment] = 'Hedging INstrument (Der)'
							AND FASTracker.[InternalPortfolio] LIKE 'SPM_TPB%', 'NE_TBP', '')))))))
	,FASTracker.UOM
	,map_order.OrderNo
	,year(FASTracker.termend) 
	,month(FASTracker.termend)

GO

