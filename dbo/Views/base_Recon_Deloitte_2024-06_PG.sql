


CREATE view [dbo].[base_Recon_Deloitte_2024-06_PG]
 as 
	SELECT 
		[dbo].[Recon_zw1_archive].[Identifier] as Identifier, 
		Max([dbo].[Recon_zw1_archive].[InternalLegalEntity]) AS InternalLegalEntity,  
		[dbo].[Recon_zw1_archive].[ReconGroup] as	ReconGroup, 
		Max([dbo].[00_map_order].[Desk]) AS Desk, 
		Max([dbo].[00_map_order].[SubDesk]) AS SubDesk,
		Max([dbo].[00_map_order].[RevRecSubDesk]) AS RevRecSubDesk,
		[dbo].[Recon_zw1_archive].[OrderNo] AS OrderNo,
		[dbo].[Recon_zw1_archive].[DeliveryMonth] as DeliveryMonth, 
		[dbo].[Recon_zw1_archive].[DealID_Recon] as DealID_Recon, 
		Max([dbo].[Recon_zw1_archive].[DealID]) AS DealID,
		Max([dbo].[Recon_zw1_archive].[Portfolio]) AS Portfolio,
		Max([dbo].[Recon_zw1_archive].[CounterpartyGroup]) AS CounterpartyGroup, 
		Max([dbo].[Recon_zw1_archive].[InstrumentType]) AS InstrumentType,
		Max([dbo].[Recon_zw1_archive].[ProjIndexGroup]) AS ProjIndexGroup,
		Max([dbo].[Recon_zw1_archive].[CurveName]) AS CurveName, 
		Max([dbo].[Recon_zw1_archive].[ExternalLegal]) AS ExternalLegal, 
		--Max(case when [dbo].[Recon_zw1_archive].[ExternalPortfolio] In ('RGM_CZ_DUMMY_POS','RGM_D_DUMMY_POS') then 'OffeneMenge' else [dbo].[Recon_zw1_archive].[ExternalBusinessUnit] end ) AS ExternalBusinessUnit, 
		max(ExternalBusinessUnit) as ExternalBusinessUnit, 
		Max([dbo].[Recon_zw1_archive].[ExternalPortfolio]) AS	ExternalPortfolio, 
		Max([dbo].[Recon_zw1_archive].[TradeDate]) AS TradeDate, 
		Max([dbo].[Recon_zw1_archive].[EventDate]) AS EventDate, 
		Max([dbo].[Recon_zw1_archive].[DocumentNumber_SAP]) AS SAP_DocumentNumber,
		round(Sum(Recon_zw1_archive.[Volume_Endur]),3) AS Volume_Endur, 
		round(Sum(Recon_zw1_archive.[Volume_SAP]),3) AS Volume_SAP, 
		round(Sum(Recon_zw1_archive.[Volume_Adj]),3) AS Volume_Adj, 
		Max(Recon_zw1_archive.[UOM_Endur]) AS UOM_Endur, 
		Max(Recon_zw1_archive.[UOM_SAP]) AS UOM_SAP, 
		round(Sum(Recon_zw1_archive.[realised_ccy_Endur]),2) AS realised_ccy_Endur, 
		round(Sum(Recon_zw1_archive.[realised_ccy_SAP]),2) AS realised_ccy_SAP, 
		round(Sum(Recon_zw1_archive.[realised_ccy_adj]),2) AS realised_ccy_adj, 
		[dbo].[Recon_zw1_archive].[ccy] as CCY, 
		round(Sum(Recon_zw1_archive.[realised_Deskccy_Endur]),2) AS realised_Deskccy_Endur,
		round(Sum(Recon_zw1_archive.[realised_Deskccy_SAP]),2) AS realised_Deskccy_SAP, 
		round(Sum(Recon_zw1_archive.[realised_Deskccy_adj]),2) AS realised_Deskccy_adj, 
		[dbo].[Recon_zw1_archive].[DeskCcy] as Deskccy,  
		round(Sum([dbo].[Recon_zw1_archive].[realised_EUR_Endur]),2) AS realised_EUR_Endur, 
		round(Sum([dbo].[Recon_zw1_archive].[realised_EUR_SAP]),2) AS realised_EUR_SAP, 
		round(Sum([dbo].[Recon_zw1_archive].[realised_EUR_SAP_conv]),2) AS realised_EUR_SAP_conv, 
		round(Sum([dbo].[Recon_zw1_archive].[realised_EUR_adj]),2) AS realised_EUR_adj, 
		Max([dbo].[Recon_zw1_archive].[Account_Endur]) AS Account_Endur, 
		Max([dbo].[Recon_zw1_archive].[Account_SAP]) AS Account_SAP, 
		round(Sum([dbo].[Recon_zw1_archive].[volume_Endur]+[dbo].[Recon_zw1_archive].[volume_SAP]-[dbo].[Recon_zw1_archive].[Volume_Adj]),3) AS diff_Volume, 
		round(Sum([dbo].[Recon_zw1_archive].[realised_eur_endur]-[dbo].[Recon_zw1_archive].[realised_eur_sap_conv]-[dbo].[Recon_zw1_archive].[realised_eur_adj]),2) AS Diff_Realised_EUR, 
		round(Sum([dbo].[Recon_zw1_archive].[realised_Deskccy_endur]-[dbo].[Recon_zw1_archive].[realised_Deskccy_SAP]-[dbo].[Recon_zw1_archive].[realised_Deskccy_adj]),2) AS Diff_Realised_DeskCCY, 
		round(Sum([dbo].[Recon_zw1_archive].[realised_ccy_endur]-[dbo].[Recon_zw1_archive].[realised_ccy_SAP]-[dbo].[Recon_zw1_archive].[realised_ccy_adj]),2) AS Diff_Realised_CCY, 
		Max([dbo].[Recon_zw1_archive].[InternalBusinessUnit]) AS InternalBusinessUnit, 
		Max([dbo].[Recon_zw1_archive].[DocumentNumber]) AS DocumentNumber, 
		Max([dbo].[Recon_zw1_archive].[Reference]) AS Reference, 
		Max([dbo].[Recon_zw1_archive].[TranStatus]) AS TranStatus, 
		Max([dbo].[Recon_zw1_archive].[Action]) AS [Action],
		Max([dbo].[Recon_zw1_archive].[CashflowType]) AS CashflowType,
		case when [dbo].[Recon_zw1_archive].[Account_Endur] is NULL then '' else [dbo].[Recon_zw1_archive].[Account_Endur] end 
			+ case when [dbo].[Recon_zw1_archive].[Account_SAP] is NULL then '' else [dbo].[Recon_zw1_archive].[Account_SAP] end AS Account, 
		Max([dbo].[Recon_zw1_archive].[Adj_Category]) AS Adj_Category,
		Max([dbo].[Recon_zw1_archive].[Adj_Comment]) AS Adj_Comment, 
		Max([dbo].[Recon_zw1_archive].[Partner]) AS [Partner], 
		Max([dbo].[Recon_zw1_archive].[VAT_Script]) AS VAT_Script,
		Max([dbo].[Recon_zw1_archive].[VAT_SAP]) AS VAT_SAP, 
		Max([dbo].[Recon_zw1_archive].[VAT_CountryCode]) AS VAT_CountryCode, 
		MAX([dbo].[Recon_zw1_archive].[Material]) as Material,		
		Max([dbo].[Recon_zw1_archive].[Ticker]) as Ticker
FROM 
	[dbo].[Recon_zw1_archive] 
	LEFT JOIN [dbo].[00_map_order] ON [dbo].[Recon_zw1_archive].[OrderNo] = [dbo].[00_map_order].[OrderNo]
WHERE 
	(
		InternalLegalEntity not in ('n/a') 
		and desk not in ('Industrial Sales - DUMMY')
	) 
	or desk is null
	and asofdate ='2024-06-28'
GROUP BY 
	[dbo].[Recon_zw1_archive].[Identifier], 
	[dbo].[Recon_zw1_archive].[ReconGroup], 
	[dbo].[Recon_zw1_archive].[OrderNo], 
	[dbo].[Recon_zw1_archive].[DeliveryMonth], 
	[dbo].[Recon_zw1_archive].[DealID_Recon], 
	[dbo].[Recon_zw1_archive].[ccy], 
	[dbo].[Recon_zw1_archive].[Deskccy], 
	case when [dbo].[Recon_zw1_archive].[Account_Endur] is NULL then '' else [dbo].[Recon_zw1_archive].[Account_Endur] end 
		+ case when [dbo].[Recon_zw1_archive].[Account_SAP] is NULL then '' else [dbo].[Recon_zw1_archive].[Account_SAP] end
HAVING
	(
		isnull(abs(Sum(Recon_zw1_archive.[Volume_Endur])),0)
		+isnull(abs(Sum(Recon_zw1_archive.[Volume_SAP])) ,0)
		+isnull(abs(Sum(Recon_zw1_archive.[Volume_Adj])) ,0)
		+isnull(abs(Sum(Recon_zw1_archive.[realised_ccy_Endur])),0)
		+isnull(abs(Sum(Recon_zw1_archive.[realised_ccy_SAP])),0)
		+isnull(abs(Sum(Recon_zw1_archive.[realised_ccy_adj])),0)
		+isnull(abs(Sum(Recon_zw1_archive.[realised_Deskccy_Endur])),0)
		+isnull(abs(Sum(Recon_zw1_archive.[realised_Deskccy_SAP])),0)
		+isnull(abs(Sum(Recon_zw1_archive.[realised_Deskccy_adj])) ,0)
		+isnull(abs(Sum([dbo].[Recon_zw1_archive].[realised_EUR_Endur])),0)
		+isnull(abs(Sum([dbo].[Recon_zw1_archive].[realised_EUR_SAP])),0)
		+isnull(abs(Sum([dbo].[Recon_zw1_archive].[realised_EUR_adj])),0)
	)<>0

GO

