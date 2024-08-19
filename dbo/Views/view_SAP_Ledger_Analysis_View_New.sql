

CREATE view [dbo].[view_SAP_Ledger_Analysis_View_New] as
	Select Distinct
		bb.[Periode],
		bb.[Company],
		MAX(ff.[LegalEntity]) as LegalEntity,
		Min(ff.[Desk]) as Desk,
		MAX(ff.[SubDesk]) as Subdesk,
		bb.[Product],
		bb.[Sachkonto],
		bb.[Kontentext],
		bb.[Partner],
		bb.[Status],
		bb.[Land],
		bb.[ProfitCenter],
		bb.[Debitor],
		bb.[Kreditor],
		Max(dd.[Produktname]) as Produktname,
		Max(dd.[Controling Structure]) as ControllingStructure,
		bb.[ME],
		bb.[Menge],
		bb.[WertInHW]
FROM 
	[FinRecon].[dbo].[SAP_LedgerData] as bb  
	Left join [FinRecon].[dbo].[SAP Ledger Mapping] as dd 
	on bb.[Sachkonto] = dd.[Sachkonto]
	Left join [FinRecon].[dbo].[map_order] as ff
	on bb.[ProfitCenter] = ff.[ProfitCenter]
GROUP BY 
	bb.[Periode],
	bb.[Company],
	ff.[LegalEntity],
	bb.[Product],
	bb.[Sachkonto],
	bb.[Kontentext],
	bb.[Partner],
	bb.[Status],
	bb.[Land],
	bb.[ProfitCenter],
	bb.[Debitor],
	bb.[Kreditor],
	dd.[Produktname],
	dd.[Controling Structure],
	bb.[ME],
	bb.[Menge],
	bb.[WertInHW]

GO

