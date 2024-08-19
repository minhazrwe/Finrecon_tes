
CREATE view [dbo].[view_ROCK_GPM_FT_export] as 
SELECT 
	 cast(COB as datetime) as cob
	,map_SBM.Subsidiary 
	,FT.Strategy
	,dbo.map_SBM.Book
	,FT.Internal_Portfolio
	,FT.Counterparty_Group
	,Sum(FT.Volume) AS Volume
	,Header_Buy_Sell AS BuySell
	,Curve_Name
	,FT.Projection_Index_Group
	,FT.Instrument_Type
	,FT.UOM
	,FT.Int_Legal_Entity
	,FT.Int_Bunit
	,FT.Ext_Legal_Entity
	,FT.Ext_Portfolio
	,Sum(Discounted_PNL / 1000000) AS DiscPnL_mEUR
	,FT.[Accounting_Treatment]
	,Year([Term_End]) AS [TermEndYear]
	,IIf(FT.Accounting_Treatment = 'Hedging Instrument (Der)', IIf([unrealizedearnings] LIKE 'I2339%', 'OCI', IIf([unrealizedearnings] LIKE 'I5999900%', 'NE', 'PNL')), IIf(FT.Accounting_Treatment = 'Hedged Items', 'Hedged Item', 'Own Use')) AS PNL_OCI
	,IIf(FT.counterparty_group LIKE 'RWE%' OR FT.counterparty_group LIKE 'ESS%' OR FT.counterparty_group IN ('POWERHOUSE'), 'Group Internal', IIf(FT.counterparty_group LIKE 'Interdesk%' OR FT.counterparty_group LIKE 'Intradesk%', 'Interdesk', FT.counterparty_group)) AS CtpyGroup2
	,IIf(FT.Instrument_Type IN (
			'CASH'
			,'COMM-EXCH'
			,'COMM-FEE'
			,'COMM-STOR'
			,'COMM-CAP-ENTRY'
			,'COMM-CAP-EXIT'
			,'COMM-TRANS'
			,'EO-C-Basket-Spd'
			), 'non-derivative', 'derivative') AS [Non-derivative]
	,Sum(FT.[volume] * isnull(conv, 1)) AS Volume_MWh
	,Sum(UnDiscounted_PNL / 1000000) AS UndiscPnL_mEUR
	,case when Term_End > End_Of_Active_Period then 0 else 1 End as Active_Period
FROM 
	(dbo.table_ROCK_GPM_FT_Data FT LEFT JOIN map_UOM_conversion 
	ON FT.UOM = map_UOM_conversion.UNIT_FROM)	LEFT JOIN dbo.map_SBM 
	ON FT.Projection_Index_Group = dbo.map_SBM.ProjectionIndexGroup 
		AND FT.Instrument_Type = dbo.map_SBM.InstrumentType
		AND FT.Counterparty_Group = dbo.map_SBM.counterpartygroup 
		AND FT.Internal_Portfolio = dbo.map_SBM.InternalPortfolio
	,(select MAX(DEAL_PDC_END_DATE) as End_Of_Active_Period from dbo.GloriRisk where Desk_Name like '%GPM%' and FileId<>3133) as subSQL
	
WHERE
	FT.Internal_Portfolio NOT IN ('RGM_D_DUMMY_SENSI','RGM_CZ_DUMMY_POS','RGM_D_DUMMY_POS')	
GROUP BY 
	FT.cob
	,dbo.map_SBM.Subsidiary
	,FT.Strategy
	,dbo.map_SBM.Book
	,FT.Internal_Portfolio
	,FT.Counterparty_Group
	,FT.Header_Buy_Sell
	,FT.Curve_Name
	,FT.Projection_Index_Group
	,FT.Instrument_Type
	,FT.UOM
	,FT.Int_Legal_Entity
	,FT.Int_Bunit
	,FT.[Ext_Legal_Entity]
	,FT.Ext_Portfolio
	,FT.Accounting_Treatment
	,case when Term_End > End_Of_Active_Period then 0 else 1 End 
	,Year(Term_End) 	
	,IIf(FT.Accounting_Treatment = 'Hedging Instrument (Der)', IIf([unrealizedearnings] LIKE 'I2339%', 'OCI', IIf([unrealizedearnings] LIKE 'I5999900%', 'NE', 'PNL')), IIf(FT.Accounting_Treatment = 'Hedged Items', 'Hedged Item', 'Own Use'))
	,IIf(FT.counterparty_group LIKE 'RWE%' OR [FT].[counterparty_group] LIKE 'ESS%' OR FT.counterparty_group IN ('POWERHOUSE'), 'Group Internal', IIf(FT.counterparty_group LIKE 'Interdesk%' OR FT.counterparty_group LIKE 'Intradesk%', 'Interdesk', FT.counterparty_group))
	,IIf(FT.Instrument_Type IN (
			'CASH'
			,'COMM-EXCH'
			,'COMM-FEE'
			,'COMM-STOR'
			,'COMM-CAP-ENTRY'
			,'COMM-CAP-EXIT'
			,'COMM-TRANS'
			,'EO-C-Basket-Spd'
			), 'non-derivative', 'derivative')

GO

