





CREATE view [dbo].[FASTracker_EOM] as 
SELECT 

o.Desk,
o.Subdesk,
o.SubDeskCCY,
[dbo].[FASTracker].AsofDate,
[dbo].[FASTracker].[Sub ID],
[dbo].[map_SBM].Subsidiary,
[dbo].[map_SBM].Strategy,
[dbo].[map_SBM].Book,
[dbo].[map_SBM].AccountingTreatment,
[dbo].[FASTracker].[InternalPortfolio],
[dbo].[FASTracker].[Counterparty_ExtBunit] as ExternalBusinessUnit,
[dbo].[FASTracker].ExtLegalEntity, 
[dbo].[FASTracker].ExtPortfolio, 
[dbo].[FASTracker].CounterpartyGroup, 
[dbo].[FASTracker].InstrumentType, 
[dbo].[FASTracker].ProjIndexGroup, 
[dbo].[FASTracker].CurveName,
[dbo].[FASTracker].Product, 
[dbo].[FASTracker].ReferenceID, 
[dbo].[FASTracker].[Trade Date] as TradeDate, 
[dbo].[FASTracker].TermEnd,
[dbo].[FASTracker].[Discounted_MTM] as Total_MTM,
Case when [dbo].[map_SBM].AccountingTreatment = 'Hedging Instrument (Der)' then 
	Case when [dbo].[map_SBM].UnrealizedEarnings like  'I2339%' or Left([dbo].[map_SBM].[UnrealizedEarnings],8) In ('I5999900','I6019990') then 0 else [dbo].[FASTracker].[Discounted_PNL] end else 0 end as PNL,
Case when [dbo].[map_SBM].AccountingTreatment = 'Hedging Instrument (Der)' then 
	Case when [dbo].[map_SBM].UnrealizedEarnings like 'I2339%' then [dbo].[FASTracker].[Discounted_MTM] else [dbo].[FASTracker].[Discounted_AOCI] end else 0 end as OCI,
Case when [dbo].[map_SBM].AccountingTreatment <> 'Hedging Instrument (Der)' then [dbo].[FASTracker].[Discounted_MTM] else 0 end as OU,
Case when [dbo].[map_SBM].AccountingTreatment = 'Hedging Instrument (Der)' and Left([dbo].[map_SBM].[UnrealizedEarnings],8) In ('I5999900','I6019990') then [dbo].[FASTracker].[Discounted_PNL] else 
 case when left([dbo].[map_SBM].UnhedgedLTAsset,8) In ('I5999900','I6019990') then -[dbo].[FASTracker].[Discounted_PNL]  else  0 end end as NOR,
[dbo].[FASTracker].UOM,
[dbo].[FASTracker].Volume,
Case when ([dbo].[map_SBM].AccountingTreatment = 'Hedging Instrument (Der)') AND ([dbo].[map_SBM].UnrealizedEarnings like  'I2339%')
	then 0 else [dbo].[FASTracker].[Volume Available] end as VolumeAvailable,
Case when ([dbo].[map_SBM].AccountingTreatment = 'Hedging Instrument (Der)') AND ([dbo].[map_SBM].UnrealizedEarnings like  'I2339%')
	then [dbo].[FASTracker].[Volume] else [dbo].[FASTracker].[Volume Used]  end as VolumeUsed,
o.SubDeskCCY as DeskCCY,
[dbo].[FASTracker].[Discounted_MTM]* case when o.LegalEntity = 'RWESTP' then fx.rate else fx.RateRisk end as Total_MTM_DeskCCY,
(Case when [dbo].[map_SBM].AccountingTreatment = 'Hedging Instrument (Der)' then 
	Case when [dbo].[map_SBM].UnrealizedEarnings like  'I2339%' or Left([dbo].[map_SBM].[UnrealizedEarnings],8) In ('I5999900','I6019990') then 0 else [dbo].[FASTracker].[Discounted_PNL] end else 0 end)*case when o.LegalEntity = 'RWESTP' then fx.rate else fx.RateRisk end as PNL_DeskCCY,
(Case when [dbo].[map_SBM].AccountingTreatment = 'Hedging Instrument (Der)' then 
	Case when [dbo].[map_SBM].UnrealizedEarnings like 'I2339%' then [dbo].[FASTracker].[Discounted_MTM] else [dbo].[FASTracker].[Discounted_AOCI] end else 0 end) * case when o.LegalEntity = 'RWESTP' then fx.rate else fx.RateRisk end as OCI_DeskCCY,
(Case when [dbo].[map_SBM].AccountingTreatment <> 'Hedging Instrument (Der)' then [dbo].[FASTracker].[Discounted_MTM] else 0 end) * case when o.LegalEntity = 'RWESTP' then fx.rate else fx.RateRisk end  as OU_DeskCCY,
(Case when [dbo].[map_SBM].AccountingTreatment = 'Hedging Instrument (Der)' and Left([dbo].[map_SBM].[UnrealizedEarnings],8) In ('I5999900','I6019990') then [dbo].[FASTracker].[Discounted_PNL] else 0 end) *case when o.LegalEntity = 'RWESTP' then fx.rate else fx.RateRisk end as NOR_DeskCCY



FROM (([dbo].[FASTracker] 
		inner join [dbo].[map_SBM] ON 
			[dbo].[FASTracker].InternalPortfolio = [dbo].[map_SBM].InternalPortfolio AND
			[dbo].[FASTracker].CounterpartyGroup = [dbo].[map_SBM].CounterpartyGroup AND
			[dbo].[FASTracker].InstrumentType = [dbo].[map_SBM].InstrumentType AND
			[dbo].[FASTracker].ProjIndexGroup = [dbo].[map_SBM].ProjectionIndexGroup ) 
		left join dbo.map_order o on 
			dbo.FASTracker.internalportfolio = o.portfolio)
		left join dbo.FXRates fx on		
			case when (o.repccy is null or o.repccy  = '') then o.SubDeskCCY else o.repccy end = fx.currency
			
			
			---o.SubDeskCCY = fx.Currency
			--case when o.repccy is null then o.SubDeskCCY else o.repccy end = fx.Currency

GO

