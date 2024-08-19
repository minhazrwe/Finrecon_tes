






CREATE view [dbo].[base_Recon_2023]
 as 
	SELECT 
		[dbo].[Recon_zw1_2023].[Identifier] as Identifier, 
		Max([dbo].[Recon_zw1_2023].[InternalLegalEntity]) AS InternalLegalEntity,  
		[dbo].[Recon_zw1_2023].[ReconGroup] as	ReconGroup, 
		Max([dbo].[00_map_order_EOY].[Desk]) AS Desk, 
		Max([dbo].[00_map_order_EOY].[SubDesk]) AS SubDesk,
				[dbo].[Recon_zw1_2023].[OrderNo] AS OrderNo,
		[dbo].[Recon_zw1_2023].[DeliveryMonth] as DeliveryMonth, 
		[dbo].[Recon_zw1_2023].[DealID_Recon] as DealID_Recon, 
		Max([dbo].[Recon_zw1_2023].[DealID]) AS DealID,
		Max([dbo].[Recon_zw1_2023].[Portfolio]) AS Portfolio,
		Max([dbo].[Recon_zw1_2023].[CounterpartyGroup]) AS CounterpartyGroup, 
		Max([dbo].[Recon_zw1_2023].[InstrumentType]) AS InstrumentType,
		Max([dbo].[Recon_zw1_2023].[ProjIndexGroup]) AS ProjIndexGroup,
		Max([dbo].[Recon_zw1_2023].[CurveName]) AS CurveName, 
		Max([dbo].[Recon_zw1_2023].[ExternalLegal]) AS ExternalLegal, 
		Max(case when [dbo].[Recon_zw1_2023].[ExternalPortfolio] In ('RGM_CZ_DUMMY_POS','RGM_D_DUMMY_POS') then 'OffeneMenge' else [dbo].[Recon_zw1_2023].[ExternalBusinessUnit] end ) AS ExternalBusinessUnit, 
		--max(ExternalBusinessUnit) as ExternalBusinessUnit, 
		Max([dbo].[Recon_zw1_2023].[ExternalPortfolio]) AS	ExternalPortfolio, 
		Max([dbo].[Recon_zw1_2023].[TradeDate]) AS TradeDate, 
		Max([dbo].[Recon_zw1_2023].[EventDate]) AS EventDate, 
		Max([dbo].[Recon_zw1_2023].[DocumentNumber_SAP]) AS SAP_DocumentNumber,
		round(Sum(Recon_zw1_2023.[Volume_Endur]),3) AS Volume_Endur, 
		round(Sum(Recon_zw1_2023.[Volume_SAP]),3) AS Volume_SAP, 
		round(Sum(Recon_zw1_2023.[Volume_Adj]),3) AS Volume_Adj, 
		Max(Recon_zw1_2023.[UOM_Endur]) AS UOM_Endur, 
		Max(Recon_zw1_2023.[UOM_SAP]) AS UOM_SAP, 
		round(Sum(Recon_zw1_2023.[realised_ccy_Endur]),2) AS realised_ccy_Endur, 
		round(Sum(Recon_zw1_2023.[realised_ccy_SAP]),2) AS realised_ccy_SAP, 
		round(Sum(Recon_zw1_2023.[realised_ccy_adj]),2) AS realised_ccy_adj, 
		[dbo].[Recon_zw1_2023].[ccy] as CCY, 
		round(Sum(Recon_zw1_2023.[realised_Deskccy_Endur]),2) AS realised_Deskccy_Endur,
		round(Sum(Recon_zw1_2023.[realised_Deskccy_SAP]),2) AS realised_Deskccy_SAP, 
		round(Sum(Recon_zw1_2023.[realised_Deskccy_adj]),2) AS realised_Deskccy_adj, 
		[dbo].[Recon_zw1_2023].[DeskCcy] as Deskccy,  
		round(Sum([dbo].[Recon_zw1_2023].[realised_EUR_Endur]),2) AS realised_EUR_Endur, 
		round(Sum([dbo].[Recon_zw1_2023].[realised_EUR_SAP]),2) AS realised_EUR_SAP, 
		round(Sum([dbo].[Recon_zw1_2023].[realised_EUR_SAP_conv]),2) AS realised_EUR_SAP_conv, 
		round(Sum([dbo].[Recon_zw1_2023].[realised_EUR_adj]),2) AS realised_EUR_adj, 
		Max([dbo].[Recon_zw1_2023].[Account_Endur]) AS Account_Endur, 
		Max([dbo].[Recon_zw1_2023].[Account_SAP]) AS Account_SAP, 
		round(Sum([dbo].[Recon_zw1_2023].[volume_Endur]+[dbo].[Recon_zw1_2023].[volume_SAP]-[dbo].[Recon_zw1_2023].[Volume_Adj]),3) AS diff_Volume, 
		round(Sum([dbo].[Recon_zw1_2023].[realised_eur_endur]-[dbo].[Recon_zw1_2023].[realised_eur_sap_conv]-[dbo].[Recon_zw1_2023].[realised_eur_adj]),2) AS Diff_Realised_EUR, 
		round(Sum([dbo].[Recon_zw1_2023].[realised_Deskccy_endur]-[dbo].[Recon_zw1_2023].[realised_Deskccy_SAP]-[dbo].[Recon_zw1_2023].[realised_Deskccy_adj]),2) AS Diff_Realised_DeskCCY, 
		round(Sum([dbo].[Recon_zw1_2023].[realised_ccy_endur]-[dbo].[Recon_zw1_2023].[realised_ccy_SAP]-[dbo].[Recon_zw1_2023].[realised_ccy_adj]),2) AS Diff_Realised_CCY, 
		Max([dbo].[Recon_zw1_2023].[InternalBusinessUnit]) AS InternalBusinessUnit, 
		Max([dbo].[Recon_zw1_2023].[DocumentNumber]) AS DocumentNumber, 
		Max([dbo].[Recon_zw1_2023].[Reference]) AS Reference, 
		Max([dbo].[Recon_zw1_2023].[TranStatus]) AS TranStatus, 
		Max([dbo].[Recon_zw1_2023].[Action]) AS [Action],
		Max([dbo].[Recon_zw1_2023].[CashflowType]) AS CashflowType,
		case when [dbo].[Recon_zw1_2023].[Account_Endur] is NULL then '' else [dbo].[Recon_zw1_2023].[Account_Endur] end 
			+ case when [dbo].[Recon_zw1_2023].[Account_SAP] is NULL then '' else [dbo].[Recon_zw1_2023].[Account_SAP] end AS Account, 
		Max([dbo].[Recon_zw1_2023].[Adj_Category]) AS Adj_Category,
		Max([dbo].[Recon_zw1_2023].[Adj_Comment]) AS Adj_Comment, 
		Max([dbo].[Recon_zw1_2023].[Partner]) AS [Partner], 
		Max([dbo].[Recon_zw1_2023].[VAT_Script]) AS VAT_Script,
		Max([dbo].[Recon_zw1_2023].[VAT_SAP]) AS VAT_SAP, 
		Max([dbo].[Recon_zw1_2023].[VAT_CountryCode]) AS VAT_CountryCode, 
		MAX([dbo].[Recon_zw1_2023].[Material]) as Material,		
		Max([dbo].[Recon_zw1_2023].[Ticker]) as Ticker
		
FROM 
	[dbo].[Recon_zw1_2023] 
	LEFT JOIN [dbo].[00_map_order_EOY] ON [dbo].[Recon_zw1_2023].[OrderNo] = [dbo].[00_map_order_EOY].[OrderNo]
WHERE 
	(
		InternalLegalEntity not in ('n/a') 
		and desk not in ('Industrial Sales - DUMMY')
	) 
	or desk is null
GROUP BY 
	[dbo].[Recon_zw1_2023].[Identifier], 
	[dbo].[Recon_zw1_2023].[ReconGroup], 
	[dbo].[Recon_zw1_2023].[OrderNo], 
	[dbo].[Recon_zw1_2023].[DeliveryMonth], 
	[dbo].[Recon_zw1_2023].[DealID_Recon], 
	[dbo].[Recon_zw1_2023].[ccy], 
	[dbo].[Recon_zw1_2023].[Deskccy], 
	case when [dbo].[Recon_zw1_2023].[Account_Endur] is NULL then '' else [dbo].[Recon_zw1_2023].[Account_Endur] end 
		+ case when [dbo].[Recon_zw1_2023].[Account_SAP] is NULL then '' else [dbo].[Recon_zw1_2023].[Account_SAP] end
HAVING
	(
		abs(Sum(Recon_zw1_2023.[Volume_Endur]))
		+abs(Sum(Recon_zw1_2023.[Volume_SAP])) 
		+abs(Sum(Recon_zw1_2023.[Volume_Adj])) 
		+abs(Sum(Recon_zw1_2023.[realised_ccy_Endur]))
		+abs(Sum(Recon_zw1_2023.[realised_ccy_SAP]))
		+abs(Sum(Recon_zw1_2023.[realised_ccy_adj]))
		+abs(Sum(Recon_zw1_2023.[realised_Deskccy_Endur]))
		+abs(Sum(Recon_zw1_2023.[realised_Deskccy_SAP]))
		+abs(Sum(Recon_zw1_2023.[realised_Deskccy_adj])) 
		+abs(Sum([dbo].[Recon_zw1_2023].[realised_EUR_Endur]))
		+abs(Sum([dbo].[Recon_zw1_2023].[realised_EUR_SAP]))
		+abs(Sum([dbo].[Recon_zw1_2023].[realised_EUR_adj]))
	)<>0

GO

