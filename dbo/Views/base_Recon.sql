







CREATE view [dbo].[base_Recon]
 as 
	SELECT 
		[dbo].[Recon_zw1].[Identifier] as Identifier, 
		Max([dbo].[Recon_zw1].[InternalLegalEntity]) AS InternalLegalEntity,  
		[dbo].[Recon_zw1].[ReconGroup] as	ReconGroup, 
		Max([dbo].[00_map_order].[Desk]) AS Desk, 
		Max([dbo].[00_map_order].[SubDesk]) AS SubDesk,
		Max([dbo].[00_map_order].[RevRecSubDesk]) AS RevRecSubDesk,
		[dbo].[Recon_zw1].[OrderNo] AS OrderNo,
		[dbo].[Recon_zw1].[DeliveryMonth] as DeliveryMonth, 
		[dbo].[Recon_zw1].[DealID_Recon] as DealID_Recon, 
		Max([dbo].[Recon_zw1].[DealID]) AS DealID,
		Max([dbo].[Recon_zw1].[Portfolio]) AS Portfolio,
		Max([dbo].[Recon_zw1].[CounterpartyGroup]) AS CounterpartyGroup, 
		Max([dbo].[Recon_zw1].[InstrumentType]) AS InstrumentType,
		Max([dbo].[Recon_zw1].[ProjIndexGroup]) AS ProjIndexGroup,
		Max([dbo].[Recon_zw1].[CurveName]) AS CurveName, 
		Max([dbo].[Recon_zw1].[ExternalLegal]) AS ExternalLegal, 
		--Max(case when [dbo].[Recon_zw1].[ExternalPortfolio] In ('RGM_CZ_DUMMY_POS','RGM_D_DUMMY_POS') then 'OffeneMenge' else [dbo].[Recon_zw1].[ExternalBusinessUnit] end ) AS ExternalBusinessUnit, 
		max(ExternalBusinessUnit) as ExternalBusinessUnit, 
		Max([dbo].[Recon_zw1].[ExternalPortfolio]) AS	ExternalPortfolio, 
		Max([dbo].[Recon_zw1].[TradeDate]) AS TradeDate, 
		Max([dbo].[Recon_zw1].[EventDate]) AS EventDate, 
		Max([dbo].[Recon_zw1].[DocumentNumber_SAP]) AS SAP_DocumentNumber,
		round(Sum(Recon_zw1.[Volume_Endur]),3) AS Volume_Endur, 
		round(Sum(Recon_zw1.[Volume_SAP]),3) AS Volume_SAP, 
		round(Sum(Recon_zw1.[Volume_Adj]),3) AS Volume_Adj, 
		Max(Recon_zw1.[UOM_Endur]) AS UOM_Endur, 
		Max(Recon_zw1.[UOM_SAP]) AS UOM_SAP, 
		round(Sum(Recon_zw1.[realised_ccy_Endur]),2) AS realised_ccy_Endur, 
		round(Sum(Recon_zw1.[realised_ccy_SAP]),2) AS realised_ccy_SAP, 
		round(Sum(Recon_zw1.[realised_ccy_adj]),2) AS realised_ccy_adj, 
		[dbo].[Recon_zw1].[ccy] as CCY, 
		round(Sum(Recon_zw1.[realised_Deskccy_Endur]),2) AS realised_Deskccy_Endur,
		round(Sum(Recon_zw1.[realised_Deskccy_SAP]),2) AS realised_Deskccy_SAP, 
		round(Sum(Recon_zw1.[realised_Deskccy_adj]),2) AS realised_Deskccy_adj, 
		[dbo].[Recon_zw1].[DeskCcy] as Deskccy,  
		round(Sum([dbo].[Recon_zw1].[realised_EUR_Endur]),2) AS realised_EUR_Endur, 
		round(Sum([dbo].[Recon_zw1].[realised_EUR_SAP]),2) AS realised_EUR_SAP, 
		round(Sum([dbo].[Recon_zw1].[realised_EUR_SAP_conv]),2) AS realised_EUR_SAP_conv, 
		round(Sum([dbo].[Recon_zw1].[realised_EUR_adj]),2) AS realised_EUR_adj, 
		Max([dbo].[Recon_zw1].[Account_Endur]) AS Account_Endur, 
		Max([dbo].[Recon_zw1].[Account_SAP]) AS Account_SAP, 
		round(Sum([dbo].[Recon_zw1].[volume_Endur]+[dbo].[Recon_zw1].[volume_SAP]-[dbo].[Recon_zw1].[Volume_Adj]),3) AS diff_Volume, 
		round(Sum([dbo].[Recon_zw1].[realised_eur_endur]-[dbo].[Recon_zw1].[realised_eur_sap_conv]-[dbo].[Recon_zw1].[realised_eur_adj]),2) AS Diff_Realised_EUR, 
		round(Sum([dbo].[Recon_zw1].[realised_Deskccy_endur]-[dbo].[Recon_zw1].[realised_Deskccy_SAP]-[dbo].[Recon_zw1].[realised_Deskccy_adj]),2) AS Diff_Realised_DeskCCY, 
		round(Sum([dbo].[Recon_zw1].[realised_ccy_endur]-[dbo].[Recon_zw1].[realised_ccy_SAP]-[dbo].[Recon_zw1].[realised_ccy_adj]),2) AS Diff_Realised_CCY, 
		Max([dbo].[Recon_zw1].[InternalBusinessUnit]) AS InternalBusinessUnit, 
		Max([dbo].[Recon_zw1].[DocumentNumber]) AS DocumentNumber, 
		Max([dbo].[Recon_zw1].[Reference]) AS Reference, 
		Max([dbo].[Recon_zw1].[TranStatus]) AS TranStatus, 
		Max([dbo].[Recon_zw1].[Action]) AS [Action],
		Max([dbo].[Recon_zw1].[CashflowType]) AS CashflowType,
		case when [dbo].[Recon_zw1].[Account_Endur] is NULL then '' else [dbo].[Recon_zw1].[Account_Endur] end 
			+ case when [dbo].[Recon_zw1].[Account_SAP] is NULL then '' else [dbo].[Recon_zw1].[Account_SAP] end AS Account, 
		Max([dbo].[Recon_zw1].[Adj_Category]) AS Adj_Category,
		Max([dbo].[Recon_zw1].[Adj_Comment]) AS Adj_Comment, 
		Max([dbo].[Recon_zw1].[Partner]) AS [Partner], 
		Max([dbo].[Recon_zw1].[VAT_Script]) AS VAT_Script,
		Max([dbo].[Recon_zw1].[VAT_SAP]) AS VAT_SAP, 
		Max([dbo].[Recon_zw1].[VAT_CountryCode]) AS VAT_CountryCode, 
		MAX([dbo].[Recon_zw1].[Material]) as Material,		
		Max([dbo].[Recon_zw1].[Ticker]) as Ticker,
		Max([dbo].[Recon_zw1].[Portfolio_ID]) as [Portfolio_ID]
FROM 
	[dbo].[Recon_zw1] 
	LEFT JOIN [dbo].[00_map_order] ON [dbo].[Recon_zw1].[OrderNo] = [dbo].[00_map_order].[OrderNo]
WHERE 
	(
		InternalLegalEntity not in ('n/a') 
		and desk not in ('Industrial Sales - DUMMY')
	) 
	or desk is null
GROUP BY 
	[dbo].[Recon_zw1].[Identifier], 
	[dbo].[Recon_zw1].[ReconGroup], 
	[dbo].[Recon_zw1].[OrderNo], 
	[dbo].[Recon_zw1].[DeliveryMonth], 
	[dbo].[Recon_zw1].[DealID_Recon], 
	[dbo].[Recon_zw1].[ccy], 
	[dbo].[Recon_zw1].[Deskccy], 
	case when [dbo].[Recon_zw1].[Account_Endur] is NULL then '' else [dbo].[Recon_zw1].[Account_Endur] end 
		+ case when [dbo].[Recon_zw1].[Account_SAP] is NULL then '' else [dbo].[Recon_zw1].[Account_SAP] end
HAVING
	(
		isnull(abs(Sum(Recon_zw1.[Volume_Endur])),0)
		+isnull(abs(Sum(Recon_zw1.[Volume_SAP])) ,0)
		+isnull(abs(Sum(Recon_zw1.[Volume_Adj])) ,0)
		+isnull(abs(Sum(Recon_zw1.[realised_ccy_Endur])),0)
		+isnull(abs(Sum(Recon_zw1.[realised_ccy_SAP])),0)
		+isnull(abs(Sum(Recon_zw1.[realised_ccy_adj])),0)
		+isnull(abs(Sum(Recon_zw1.[realised_Deskccy_Endur])),0)
		+isnull(abs(Sum(Recon_zw1.[realised_Deskccy_SAP])),0)
		+isnull(abs(Sum(Recon_zw1.[realised_Deskccy_adj])) ,0)
		+isnull(abs(Sum([dbo].[Recon_zw1].[realised_EUR_Endur])),0)
		+isnull(abs(Sum([dbo].[Recon_zw1].[realised_EUR_SAP])),0)
		+isnull(abs(Sum([dbo].[Recon_zw1].[realised_EUR_adj])),0)
	)<>0

GO

