








CREATE view [dbo].[base_Recon-phil]
 as 
	SELECT 
		[dbo].[Recon_zw1_Archive-phil].[Identifier] as Identifier, 
		Max([dbo].[Recon_zw1_Archive-phil].[InternalLegalEntity]) AS InternalLegalEntity,  
		[dbo].[Recon_zw1_Archive-phil].[ReconGroup] as	ReconGroup, 
		Max([dbo].[00_map_order].[Desk]) AS Desk, 
		Max([dbo].[00_map_order].[SubDesk]) AS SubDesk,
		Max([dbo].[00_map_order].[RevRecSubDesk]) AS RevRecSubDesk,
		[dbo].[Recon_zw1_Archive-phil].[OrderNo] AS OrderNo,
		[dbo].[Recon_zw1_Archive-phil].[DeliveryMonth] as DeliveryMonth, 
		[dbo].[Recon_zw1_Archive-phil].[DealID_Recon] as DealID_Recon, 
		Max([dbo].[Recon_zw1_Archive-phil].[DealID]) AS DealID,
		Max([dbo].[Recon_zw1_Archive-phil].[Portfolio]) AS Portfolio,
		Max([dbo].[Recon_zw1_Archive-phil].[CounterpartyGroup]) AS CounterpartyGroup, 
		Max([dbo].[Recon_zw1_Archive-phil].[InstrumentType]) AS InstrumentType,
		Max([dbo].[Recon_zw1_Archive-phil].[ProjIndexGroup]) AS ProjIndexGroup,
		Max([dbo].[Recon_zw1_Archive-phil].[CurveName]) AS CurveName, 
		Max([dbo].[Recon_zw1_Archive-phil].[ExternalLegal]) AS ExternalLegal, 
		--Max(case when [dbo].[Recon_zw1_Archive-phil].[ExternalPortfolio] In ('RGM_CZ_DUMMY_POS','RGM_D_DUMMY_POS') then 'OffeneMenge' else [dbo].[Recon_zw1_Archive-phil].[ExternalBusinessUnit] end ) AS ExternalBusinessUnit, 
		max(ExternalBusinessUnit) as ExternalBusinessUnit, 
		Max([dbo].[Recon_zw1_Archive-phil].[ExternalPortfolio]) AS	ExternalPortfolio, 
		Max([dbo].[Recon_zw1_Archive-phil].[TradeDate]) AS TradeDate, 
		Max([dbo].[Recon_zw1_Archive-phil].[EventDate]) AS EventDate, 
		Max([dbo].[Recon_zw1_Archive-phil].[DocumentNumber_SAP]) AS SAP_DocumentNumber,
		round(Sum([Recon_zw1_Archive-phil].[Volume_Endur]),3) AS Volume_Endur, 
		round(Sum([Recon_zw1_Archive-phil].[Volume_SAP]),3) AS Volume_SAP, 
		round(Sum([Recon_zw1_Archive-phil].[Volume_Adj]),3) AS Volume_Adj, 
		Max([Recon_zw1_Archive-phil].[UOM_Endur]) AS UOM_Endur, 
		Max([Recon_zw1_Archive-phil].[UOM_SAP]) AS UOM_SAP, 
		round(Sum([Recon_zw1_Archive-phil].[realised_ccy_Endur]),2) AS realised_ccy_Endur, 
		round(Sum([Recon_zw1_Archive-phil].[realised_ccy_SAP]),2) AS realised_ccy_SAP, 
		round(Sum([Recon_zw1_Archive-phil].[realised_ccy_adj]),2) AS realised_ccy_adj, 
		[dbo].[Recon_zw1_Archive-phil].[ccy] as CCY, 
		round(Sum([Recon_zw1_Archive-phil].[realised_Deskccy_Endur]),2) AS realised_Deskccy_Endur,
		round(Sum([Recon_zw1_Archive-phil].[realised_Deskccy_SAP]),2) AS realised_Deskccy_SAP, 
		round(Sum([Recon_zw1_Archive-phil].[realised_Deskccy_adj]),2) AS realised_Deskccy_adj, 
		[dbo].[Recon_zw1_Archive-phil].[DeskCcy] as Deskccy,  
		round(Sum([dbo].[Recon_zw1_Archive-phil].[realised_EUR_Endur]),2) AS realised_EUR_Endur, 
		round(Sum([dbo].[Recon_zw1_Archive-phil].[realised_EUR_SAP]),2) AS realised_EUR_SAP, 
		round(Sum([dbo].[Recon_zw1_Archive-phil].[realised_EUR_SAP_conv]),2) AS realised_EUR_SAP_conv, 
		round(Sum([dbo].[Recon_zw1_Archive-phil].[realised_EUR_adj]),2) AS realised_EUR_adj, 
		Max([dbo].[Recon_zw1_Archive-phil].[Account_Endur]) AS Account_Endur, 
		Max([dbo].[Recon_zw1_Archive-phil].[Account_SAP]) AS Account_SAP, 
		round(Sum([dbo].[Recon_zw1_Archive-phil].[volume_Endur]+[dbo].[Recon_zw1_Archive-phil].[volume_SAP]-[dbo].[Recon_zw1_Archive-phil].[Volume_Adj]),3) AS diff_Volume, 
		round(Sum([dbo].[Recon_zw1_Archive-phil].[realised_eur_endur]-[dbo].[Recon_zw1_Archive-phil].[realised_eur_sap_conv]-[dbo].[Recon_zw1_Archive-phil].[realised_eur_adj]),2) AS Diff_Realised_EUR, 
		round(Sum([dbo].[Recon_zw1_Archive-phil].[realised_Deskccy_endur]-[dbo].[Recon_zw1_Archive-phil].[realised_Deskccy_SAP]-[dbo].[Recon_zw1_Archive-phil].[realised_Deskccy_adj]),2) AS Diff_Realised_DeskCCY, 
		round(Sum([dbo].[Recon_zw1_Archive-phil].[realised_ccy_endur]-[dbo].[Recon_zw1_Archive-phil].[realised_ccy_SAP]-[dbo].[Recon_zw1_Archive-phil].[realised_ccy_adj]),2) AS Diff_Realised_CCY, 
		Max([dbo].[Recon_zw1_Archive-phil].[InternalBusinessUnit]) AS InternalBusinessUnit, 
		Max([dbo].[Recon_zw1_Archive-phil].[DocumentNumber]) AS DocumentNumber, 
		Max([dbo].[Recon_zw1_Archive-phil].[Reference]) AS Reference, 
		Max([dbo].[Recon_zw1_Archive-phil].[TranStatus]) AS TranStatus, 
		Max([dbo].[Recon_zw1_Archive-phil].[Action]) AS [Action],
		Max([dbo].[Recon_zw1_Archive-phil].[CashflowType]) AS CashflowType,
		case when [dbo].[Recon_zw1_Archive-phil].[Account_Endur] is NULL then '' else [dbo].[Recon_zw1_Archive-phil].[Account_Endur] end 
			+ case when [dbo].[Recon_zw1_Archive-phil].[Account_SAP] is NULL then '' else [dbo].[Recon_zw1_Archive-phil].[Account_SAP] end AS Account, 
		Max([dbo].[Recon_zw1_Archive-phil].[Adj_Category]) AS Adj_Category,
		Max([dbo].[Recon_zw1_Archive-phil].[Adj_Comment]) AS Adj_Comment, 
		Max([dbo].[Recon_zw1_Archive-phil].[Partner]) AS [Partner], 
		Max([dbo].[Recon_zw1_Archive-phil].[VAT_Script]) AS VAT_Script,
		Max([dbo].[Recon_zw1_Archive-phil].[VAT_SAP]) AS VAT_SAP, 
		Max([dbo].[Recon_zw1_Archive-phil].[VAT_CountryCode]) AS VAT_CountryCode, 
		MAX([dbo].[Recon_zw1_Archive-phil].[Material]) as Material,		
		Max([dbo].[Recon_zw1_Archive-phil].[Ticker]) as Ticker
		--Max([dbo].[Recon_zw1_Archive-phil].[Portfolio_ID]) as [Portfolio_ID]
FROM 
	[dbo].[Recon_zw1_Archive-phil] 
	LEFT JOIN [dbo].[00_map_order] ON [dbo].[Recon_zw1_Archive-phil].[OrderNo] = [dbo].[00_map_order].[OrderNo]
WHERE 
	(
		InternalLegalEntity not in ('n/a') 
		and desk not in ('Industrial Sales - DUMMY')
	) 
	or desk is null
GROUP BY 
	[dbo].[Recon_zw1_Archive-phil].[Identifier], 
	[dbo].[Recon_zw1_Archive-phil].[ReconGroup], 
	[dbo].[Recon_zw1_Archive-phil].[OrderNo], 
	[dbo].[Recon_zw1_Archive-phil].[DeliveryMonth], 
	[dbo].[Recon_zw1_Archive-phil].[DealID_Recon], 
	[dbo].[Recon_zw1_Archive-phil].[ccy], 
	[dbo].[Recon_zw1_Archive-phil].[Deskccy], 
	case when [dbo].[Recon_zw1_Archive-phil].[Account_Endur] is NULL then '' else [dbo].[Recon_zw1_Archive-phil].[Account_Endur] end 
		+ case when [dbo].[Recon_zw1_Archive-phil].[Account_SAP] is NULL then '' else [dbo].[Recon_zw1_Archive-phil].[Account_SAP] end
HAVING
	(
		isnull(abs(Sum([Recon_zw1_Archive-phil].[Volume_Endur])),0)
		+isnull(abs(Sum([Recon_zw1_Archive-phil].[Volume_SAP])) ,0)
		+isnull(abs(Sum([Recon_zw1_Archive-phil].[Volume_Adj])) ,0)
		+isnull(abs(Sum([Recon_zw1_Archive-phil].[realised_ccy_Endur])),0)
		+isnull(abs(Sum([Recon_zw1_Archive-phil].[realised_ccy_SAP])),0)
		+isnull(abs(Sum([Recon_zw1_Archive-phil].[realised_ccy_adj])),0)
		+isnull(abs(Sum([Recon_zw1_Archive-phil].[realised_Deskccy_Endur])),0)
		+isnull(abs(Sum([Recon_zw1_Archive-phil].[realised_Deskccy_SAP])),0)
		+isnull(abs(Sum([Recon_zw1_Archive-phil].[realised_Deskccy_adj])) ,0)
		+isnull(abs(Sum([dbo].[Recon_zw1_Archive-phil].[realised_EUR_Endur])),0)
		+isnull(abs(Sum([dbo].[Recon_zw1_Archive-phil].[realised_EUR_SAP])),0)
		+isnull(abs(Sum([dbo].[Recon_zw1_Archive-phil].[realised_EUR_adj])),0)
	)<>0

GO

