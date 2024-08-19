
CREATE VIEW [dbo].[FASTracker_EOY]
AS
SELECT o.Desk
	,o.Subdesk
	,o.SubDeskCCY
	,[dbo].[FASTracker_Archive].AsofDate
	,[dbo].[FASTracker_Archive].[Sub ID]
	,[dbo].[map_SBM_Archive].Subsidiary
	,[dbo].[map_SBM_Archive].Strategy
	,[dbo].[map_SBM_Archive].Book
	-- Exception added for fiscal year 2024. Delete after that! MK 2024-03-12 on request of April Xin
	,CASE 
		WHEN [dbo].[map_SBM_Archive].[CounterpartyGroup] = 'Intradesk'
			AND [dbo].[map_SBM_Archive].[InstrumentType] = 'GAS-FWD-P'
			AND [dbo].[map_SBM_Archive].[ProjectionIndexGroup] = 'Natural Gas'
			AND [dbo].[map_SBM_Archive].[InternalPortfolio] = 'RGM_D_PM_PSA_TAQA_2'
			THEN 'Own Use'
		ELSE [dbo].[map_SBM_Archive].AccountingTreatment
		END AS AccountingTreatment
	,[dbo].[FASTracker_Archive].[InternalPortfolio]
	,[dbo].[FASTracker_Archive].[Counterparty_ExtBunit] AS ExternalBusinessUnit
	,[dbo].[FASTracker_Archive].ExtLegalEntity
	,[dbo].[FASTracker_Archive].ExtPortfolio
	,[dbo].[FASTracker_Archive].CounterpartyGroup
	,[dbo].[FASTracker_Archive].InstrumentType
	,[dbo].[FASTracker_Archive].ProjIndexGroup
	,[dbo].[FASTracker_Archive].CurveName
	,[dbo].[FASTracker_Archive].Product
	,[dbo].[FASTracker_Archive].ReferenceID
	,[dbo].[FASTracker_Archive].[Trade Date] AS TradeDate
	,[dbo].[FASTracker_Archive].TermEnd
	,[dbo].[FASTracker_archive].[Discounted_MTM] AS Total_MTM
	,CASE 
		WHEN [dbo].[map_SBM_Archive].AccountingTreatment = 'Hedging Instrument (Der)'
			THEN CASE 
					WHEN [dbo].[map_SBM_Archive].UnrealizedEarnings LIKE 'I2339%'
						OR Left([dbo].[map_SBM_Archive].[UnrealizedEarnings], 8) IN (
							'I5999900'
							,'I6019990'
							)
						THEN 0
					ELSE [dbo].[FASTracker_Archive].[Discounted_PNL]
					END
		ELSE 0
		END AS PNL
	,CASE 
		WHEN [dbo].[map_SBM_Archive].AccountingTreatment = 'Hedging Instrument (Der)'
			THEN CASE 
					WHEN [dbo].[map_SBM_Archive].UnrealizedEarnings LIKE 'I2339%'
						THEN [dbo].[FASTracker_Archive].[Discounted_MTM]
					ELSE [dbo].[FASTracker_Archive].[Discounted_AOCI]
					END
		ELSE 0
		END AS OCI
	,CASE 
		WHEN [dbo].[map_SBM_Archive].AccountingTreatment <> 'Hedging Instrument (Der)'
			THEN [dbo].[FASTracker_Archive].[Discounted_MTM]
		ELSE 0
		END AS OU
	,CASE 
		WHEN [dbo].[map_SBM_Archive].AccountingTreatment = 'Hedging Instrument (Der)'
			AND Left([dbo].[map_SBM_Archive].[UnrealizedEarnings], 8) IN (
				'I5999900'
				,'I6019990'
				)
			THEN [dbo].[FASTracker_archive].[Discounted_PNL]
		ELSE CASE 
				WHEN left([dbo].[map_SBM_archive].UnhedgedLTAsset, 8) IN (
						'I5999900'
						,'I6019990'
						)
					THEN - [dbo].[FASTracker_archive].[Discounted_PNL]
				ELSE 0
				END
		END AS NOR
	,[dbo].[FASTracker_Archive].UOM
	,[dbo].[FASTracker_Archive].Volume
	,CASE 
		WHEN ([dbo].[map_SBM_Archive].AccountingTreatment = 'Hedging Instrument (Der)')
			AND ([dbo].[map_SBM_Archive].UnrealizedEarnings LIKE 'I2339%')
			THEN 0
		ELSE [dbo].[FASTracker_Archive].[Volume Available]
		END AS VolumeAvailable
	,CASE 
		WHEN ([dbo].[map_SBM_Archive].AccountingTreatment = 'Hedging Instrument (Der)')
			AND ([dbo].[map_SBM_Archive].UnrealizedEarnings LIKE 'I2339%')
			THEN [dbo].[FASTracker_Archive].[Volume]
		ELSE [dbo].[FASTracker_Archive].[Volume Used]
		END AS VolumeUsed
	,o.SubDeskCCY AS DeskCCY
	,[dbo].[FASTracker_Archive].[Discounted_MTM] * CASE 
		WHEN o.LegalEntity = 'RWESTP'
			THEN fx.rate
		ELSE fx.RateRisk
		END AS Total_MTM_DeskCCY
	,(
		CASE 
			WHEN [dbo].[map_SBM_Archive].AccountingTreatment = 'Hedging Instrument (Der)'
				THEN CASE 
						WHEN [dbo].[map_SBM_Archive].UnrealizedEarnings LIKE 'I2339%'
							OR Left([dbo].[map_SBM_Archive].[UnrealizedEarnings], 8) IN (
								'I5999900'
								,'I6019990'
								)
							THEN 0
						ELSE [dbo].[FASTracker_Archive].[Discounted_PNL]
						END
			ELSE 0
			END
		) * CASE 
		WHEN o.LegalEntity = 'RWESTP'
			THEN fx.rate
		ELSE fx.RateRisk
		END AS PNL_DeskCCY
	,(
		CASE 
			WHEN [dbo].[map_SBM_Archive].AccountingTreatment = 'Hedging Instrument (Der)'
				THEN CASE 
						WHEN [dbo].[map_SBM_Archive].UnrealizedEarnings LIKE 'I2339%'
							THEN [dbo].[FASTracker_Archive].[Discounted_MTM]
						ELSE [dbo].[FASTracker_Archive].[Discounted_AOCI]
						END
			ELSE 0
			END
		) * CASE 
		WHEN o.LegalEntity = 'RWESTP'
			THEN fx.rate
		ELSE fx.RateRisk
		END AS OCI_DeskCCY
	,(
		CASE 
			WHEN [dbo].[map_SBM_Archive].AccountingTreatment <> 'Hedging Instrument (Der)'
				THEN [dbo].[FASTracker_Archive].[Discounted_MTM]
			ELSE 0
			END
		) * CASE 
		WHEN o.LegalEntity = 'RWESTP'
			THEN fx.rate
		ELSE fx.RateRisk
		END AS OU_DeskCCY
	,(
		CASE 
			WHEN [dbo].[map_SBM_Archive].AccountingTreatment = 'Hedging Instrument (Der)'
				AND Left([dbo].[map_SBM_Archive].[UnrealizedEarnings], 8) IN (
					'I5999900'
					,'I6019990'
					)
				THEN [dbo].[FASTracker_Archive].[Discounted_PNL]
			ELSE 0
			END
		) * CASE 
		WHEN o.LegalEntity = 'RWESTP'
			THEN fx.rate
		ELSE fx.RateRisk
		END AS NOR_DeskCCY
FROM (
	(
		(
			[dbo].[FASTracker_Archive] INNER JOIN [dbo].[map_SBM_Archive] ON [dbo].[FASTracker_Archive].InternalPortfolio = [dbo].[map_SBM_Archive].InternalPortfolio
				AND [dbo].[FASTracker_Archive].CounterpartyGroup = [dbo].[map_SBM_Archive].CounterpartyGroup
				AND [dbo].[FASTracker_Archive].InstrumentType = [dbo].[map_SBM_Archive].InstrumentType
				AND [dbo].[FASTracker_Archive].ProjIndexGroup = [dbo].[map_SBM_Archive].ProjectionIndexGroup
				AND [dbo].[FASTracker_Archive].AsOfdate = [dbo].[map_SBM_Archive].AsofDAte
			) INNER JOIN dbo.[AsOfDate] ON [dbo].[FASTracker_Archive].AsOfDate = dbo.[AsOfDate].[asofdate_eoy]
		) LEFT JOIN dbo.map_order o ON dbo.FASTracker_Archive.internalportfolio = o.portfolio
	)
LEFT JOIN dbo.FXRate fx ON [dbo].[FASTracker_Archive].[AsofDate] = fx.AsOfDate
	AND CASE 
		WHEN (
				o.repccy IS NULL
				OR o.repccy = ''
				)
			THEN o.SubDeskCCY
		ELSE o.repccy
		END = fx.currency

GO

