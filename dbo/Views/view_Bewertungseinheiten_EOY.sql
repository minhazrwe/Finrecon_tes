





create view [dbo].[view_Bewertungseinheiten_EOY] as 
SELECT 

o.Desk,
o.Subdesk,
o.SubDeskCCY,
case when [dbo].[FASTracker_Archive].[InternalPortfolio] like 'FV%' then 'Adj' else
case when [dbo].[FASTracker_Archive].[InternalPortfolio] like 'creditprov%' then 'Credit' else '' end end as Adj,
[dbo].[FASTracker_Archive].AsofDate,
[dbo].[FASTracker_Archive].[Sub ID],
[dbo].[map_SBM_Archive].Subsidiary,
[dbo].[map_SBM_Archive].Strategy,
[dbo].[map_SBM_Archive].Book,
[dbo].[map_SBM_Archive].AccountingTreatment,
[dbo].[FASTracker_Archive].[InternalPortfolio],
[dbo].[FASTracker_Archive].[Counterparty_ExtBunit] as ExternalBusinessUnit,
[dbo].[FASTracker_Archive].ExtLegalEntity, 
[dbo].[FASTracker_Archive].ExtPortfolio, 
[dbo].[FASTracker_Archive].CounterpartyGroup, 
[dbo].[FASTracker_Archive].InstrumentType, 
[dbo].[FASTracker_Archive].ProjIndexGroup, 
[dbo].[FASTracker_Archive].CurveName,
[dbo].[FASTracker_Archive].Product, 
[dbo].[FASTracker_Archive].ReferenceID, 
[dbo].[FASTracker_Archive].[Trade Date] as TradeDate, 
[dbo].[FASTracker_Archive].TermEnd,
[dbo].[FASTracker_Archive].[Discounted_MTM] as Total_MTM,
p.posneg,
Case when [dbo].[map_SBM_Archive].AccountingTreatment = 'Hedging Instrument (Der)' then 
	Case when [dbo].[map_SBM_Archive].UnrealizedEarnings like  'I2339%' or Left([dbo].[map_SBM_Archive].[UnrealizedEarnings],8) In ('I5999900','I6019990') then 0 else [dbo].[FASTracker_Archive].[Discounted_PNL] end else 0 end as PNL,
Case when [dbo].[map_SBM_Archive].AccountingTreatment = 'Hedging Instrument (Der)' then 
	Case when [dbo].[map_SBM_Archive].UnrealizedEarnings like 'I2339%' then [dbo].[FASTracker_Archive].[Discounted_MTM] else [dbo].[FASTracker_Archive].[Discounted_AOCI] end else 0 end as OCI,
Case when [dbo].[map_SBM_Archive].AccountingTreatment <> 'Hedging Instrument (Der)' then [dbo].[FASTracker_Archive].[Discounted_MTM] else 0 end as OU,
Case when [dbo].[map_SBM_Archive].AccountingTreatment = 'Hedging Instrument (Der)' and Left([dbo].[map_SBM_Archive].[UnrealizedEarnings],8) In ('I5999900','I6019990') then [dbo].[FASTracker_Archive].[Discounted_PNL] else 
 case when left([dbo].[map_SBM_Archive].UnhedgedLTAsset,8) In ('I5999900','I6019990') then -[dbo].[FASTracker_Archive].[Discounted_PNL]  else  0 end end as NOR,
[dbo].[FASTracker_Archive].UOM,
[dbo].[FASTracker_Archive].Volume,
Case when ([dbo].[map_SBM_Archive].AccountingTreatment = 'Hedging Instrument (Der)') AND ([dbo].[map_SBM_Archive].UnrealizedEarnings like  'I2339%')
	then 0 else [dbo].[FASTracker_Archive].[Volume Available] end as VolumeAvailable,
Case when ([dbo].[map_SBM_Archive].AccountingTreatment = 'Hedging Instrument (Der)') AND ([dbo].[map_SBM_Archive].UnrealizedEarnings like  'I2339%')
	then [dbo].[FASTracker_Archive].[Volume] else [dbo].[FASTracker_Archive].[Volume Used]  end as VolumeUsed,
o.SubDeskCCY as DeskCCY,
[dbo].[FASTracker_Archive].[Discounted_MTM]* case when o.LegalEntity = 'RWESTP' then fx.rate else fx.RateRisk end as Total_MTM_DeskCCY,
(Case when [dbo].[map_SBM_Archive].AccountingTreatment = 'Hedging Instrument (Der)' then 
	Case when [dbo].[map_SBM_Archive].UnrealizedEarnings like  'I2339%' or Left([dbo].[map_SBM_Archive].[UnrealizedEarnings],8) In ('I5999900','I6019990') then 0 else [dbo].[FASTracker_Archive].[Discounted_PNL] end else 0 end)*case when o.LegalEntity = 'RWESTP' then fx.rate else fx.RateRisk end as PNL_DeskCCY,
(Case when [dbo].[map_SBM_Archive].AccountingTreatment = 'Hedging Instrument (Der)' then 
	Case when [dbo].[map_SBM_Archive].UnrealizedEarnings like 'I2339%' then [dbo].[FASTracker_Archive].[Discounted_MTM] else [dbo].[FASTracker_Archive].[Discounted_AOCI] end else 0 end) * case when o.LegalEntity = 'RWESTP' then fx.rate else fx.RateRisk end as OCI_DeskCCY,
(Case when [dbo].[map_SBM_Archive].AccountingTreatment <> 'Hedging Instrument (Der)' then [dbo].[FASTracker_Archive].[Discounted_MTM] else 0 end) * case when o.LegalEntity = 'RWESTP' then fx.rate else fx.RateRisk end  as OU_DeskCCY,
(Case when [dbo].[map_SBM_Archive].AccountingTreatment = 'Hedging Instrument (Der)' and Left([dbo].[map_SBM_Archive].[UnrealizedEarnings],8) In ('I5999900','I6019990') then [dbo].[FASTracker_Archive].[Discounted_PNL] else 0 end) *case when o.LegalEntity = 'RWESTP' then fx.rate else fx.RateRisk end as NOR_DeskCCY




FROM (([dbo].[FASTracker_Archive] 
		inner join [dbo].[map_SBM_Archive] ON 
			[dbo].[FASTracker_Archive].InternalPortfolio = [dbo].[map_SBM_Archive].InternalPortfolio AND
			[dbo].[FASTracker_Archive].CounterpartyGroup = [dbo].[map_SBM_Archive].CounterpartyGroup AND
			[dbo].[FASTracker_Archive].InstrumentType = [dbo].[map_SBM_Archive].InstrumentType AND
			[dbo].[FASTracker_Archive].ProjIndexGroup = [dbo].[map_SBM_Archive].ProjectionIndexGroup and
			[dbo].[FASTracker_Archive].AsOfdate = [dbo].[map_SBM_Archive].AsofDAte ) 
		left join dbo.map_order_2023 o on 
			dbo.[FASTracker_Archive].internalportfolio = o.portfolio)
		left join dbo.FXRates fx on		
			case when (o.repccy is null or o.repccy  = '') then o.SubDeskCCY else o.repccy end = fx.currency
			left join dbo.Bewertungseinheiten_pos_neg p on
			dbo.[FASTracker_Archive].ReferenceID = p.ReferenceID
		inner join dbo.AsOfDate on
		[dbo].[FASTracker_Archive].AsOfDate = dbo.[AsOfDate].[asofdate_eoy]
			where [dbo].[FASTracker_Archive].[Sub ID] in ('4','208')
					and [dbo].[FASTracker_Archive].[InternalPortfolio] not like '%3P%'
			and [dbo].[FASTracker_Archive].CounterpartyGroup not like 'Intradesk'
			and [dbo].[FASTracker_Archive].InstrumentType not in ('EM-INV-P','INVENTORY','REN-INV-P') 
	
				and [dbo].[FASTracker_Archive].[InternalPortfolio] not like '%RHP%'
				and [dbo].[FASTracker_Archive].InternalPortfolio not like '%Dummy%'

GO

