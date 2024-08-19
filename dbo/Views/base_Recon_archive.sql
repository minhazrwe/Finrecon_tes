











CREATE view [dbo].[base_Recon_archive] ( Identifier, InternalLegalEntity, ReconGroup, Desk, SubDesk, OrderNo, 
DeliveryMonth, DealID_Recon, DealID, Portfolio, CounterpartyGroup, 
InstrumentType, ProjIndexGroup, CurveName, ExternalLegal, ExternalBusinessUnit, 
ExternalPortfolio, TradeDate, EventDate, SAP_DocumentNumber, Volume_Endur, 
Volume_SAP, Volume_Adj, UOM_Endur, UOM_SAP, realised_ccy_Endur, 
realised_ccy_SAP, realised_ccy_adj, ccy, realised_Deskccy_Endur, realised_Deskccy_SAP, realised_Deskccy_adj, Deskccy, realised_EUR_Endur, realised_EUR_SAP, realised_EUR_SAP_conv, 
realised_EUR_adj, Account_Endur, Account_SAP, diff_Volume, Diff_Realised_EUR, Diff_Realised_DeskCCY, Diff_Realised_CCY, 
InternalBusinessUnit, DocumentNumber, Reference, TranStatus, [Action], CashflowType, 
Account, Adj_Category, Adj_Comment, [Partner], VAT_Script, VAT_SAP, VAT_CountryCode, Material)
 as SELECT 
[dbo].[recon_zw1_archive].[Identifier], 
Max([dbo].[recon_zw1_archive].[InternalLegalEntity]) AS MaxvonInternalLegalEntity, 
[dbo].[recon_zw1_archive].[ReconGroup], 
Max([dbo].[00_map_order].[Desk]) AS MaxvonDesk, 
Max([dbo].[00_map_order].[SubDesk]) AS MaxvonSubDesk, 
[dbo].[recon_zw1_archive].[OrderNo] AS Ausdr1, 
[dbo].[recon_zw1_archive].[DeliveryMonth], 
[dbo].[recon_zw1_archive].[DealID_Recon], 
Max([dbo].[recon_zw1_archive].[DealID]) AS MaxvonDealID, 
Max([dbo].[recon_zw1_archive].[Portfolio]) AS MaxvonPortfolio, 
Max([dbo].[recon_zw1_archive].[CounterpartyGroup]) AS MaxvonCounterpartyGroup, 
Max([dbo].[recon_zw1_archive].[InstrumentType]) AS MaxvonInstrumentType, 
Max([dbo].[recon_zw1_archive].[ProjIndexGroup]) AS MaxvonProjIndexGroup, 
Max([dbo].[recon_zw1_archive].[CurveName]) AS MaxvonCurveName, 
Max([dbo].[recon_zw1_archive].[ExternalLegal]) AS MaxvonExternalLegal, 
Max(case when [dbo].[recon_zw1_archive].[ExternalPortfolio] In ('RGM_CZ_DUMMY_POS','RGM_D_DUMMY_POS') then 'OffeneMenge' else [dbo].[recon_zw1_archive].[ExternalBusinessUnit] end ) AS ExtBunit, 
Max([dbo].[recon_zw1_archive].[ExternalPortfolio]) AS MaxvonExternalPortfolio, 
Max([dbo].[recon_zw1_archive].[TradeDate]) AS MaxvonTradeDate, 
Max([dbo].[recon_zw1_archive].[EventDate]) AS MaxvonEventDate, 
Max([dbo].[recon_zw1_archive].[DocumentNumber_SAP]) AS MaxvonSAP_Belegnummer, 
round(Sum(recon_zw1_archive.[Volume_Endur]),3) AS SummevonVolume_Endur, 
round(Sum(recon_zw1_archive.[Volume_SAP]),3) AS SummevonVolume_SAP, 
round(Sum(recon_zw1_archive.[Volume_Adj]),3) AS SummevonVolume_Adj, 
Max(recon_zw1_archive.[UOM_Endur]) AS MaxvonUOM_Endur, 
Max(recon_zw1_archive.[UOM_SAP]) AS MaxvonUOM_SAP, 
round(Sum(recon_zw1_archive.[realised_ccy_Endur]),2) AS Summevonrealised_ccy_Endur, 
round(Sum(recon_zw1_archive.[realised_ccy_SAP]),2) AS Summevonrealised_ccy_SAP, 
round(Sum(recon_zw1_archive.[realised_ccy_adj]),2) AS Summevonrealised_ccy_adj, 
[dbo].[recon_zw1_archive].[ccy], 
round(Sum(recon_zw1_archive.[realised_Deskccy_Endur]),2) AS Summevonrealised_Deskccy_Endur, 
round(Sum(recon_zw1_archive.[realised_Deskccy_SAP]),2) AS Summevonrealised_Deskccy_SAP, 
round(Sum(recon_zw1_archive.[realised_Deskccy_adj]),2) AS Summevonrealised_Deskccy_adj, 
[dbo].[recon_zw1_archive].[DeskCcy], 
round(Sum([dbo].[recon_zw1_archive].[realised_EUR_Endur]),2) AS Summevonrealised_EUR_Endur, 
round(Sum([dbo].[recon_zw1_archive].[realised_EUR_SAP]),2) AS Summevonrealised_EUR_SAP, 
round(Sum([dbo].[Recon_zw1_Archive].[realised_EUR_SAP_conv]),2) AS Summevonrealised_EUR_SAP_conv, 
round(Sum([dbo].[recon_zw1_archive].[realised_EUR_adj]),2) AS Summevonrealised_EUR_adj, 
Max([dbo].[recon_zw1_archive].[Account_Endur]) AS MaxvonKonto_Endur, 
Max([dbo].[recon_zw1_archive].[Account_SAP]) AS MaxvonSAP_Konto, 
round(Sum([dbo].[recon_zw1_archive].[volume_Endur]+[dbo].[recon_zw1_archive].[volume_SAP]-[dbo].[recon_zw1_archive].[Volume_Adj]),3) AS diff_Volume, 
round(Sum([dbo].[recon_zw1_archive].[realised_eur_endur]-[dbo].[recon_zw1_archive].[realised_eur_sap]-[dbo].[recon_zw1_archive].[realised_eur_adj]),2) AS diff_eur, 
round(Sum([dbo].[recon_zw1_archive].[realised_Deskccy_endur]-[dbo].[recon_zw1_archive].[realised_Deskccy_SAP]-[dbo].[recon_zw1_archive].[realised_Deskccy_adj]),2) AS diff_Deskccy,
round(Sum([dbo].[recon_zw1_archive].[realised_ccy_endur]-[dbo].[recon_zw1_archive].[realised_ccy_SAP]-[dbo].[recon_zw1_archive].[realised_ccy_adj]),2) AS diff_ccy, 
Max([dbo].[recon_zw1_archive].[InternalBusinessUnit]) AS MaxvonInternalBusinessUnit, 
Max([dbo].[recon_zw1_archive].[DocumentNumber]) AS MaxvonDocumentNumber, 
Max([dbo].[recon_zw1_archive].[Reference]) AS MaxvonReference, 
Max([dbo].[recon_zw1_archive].[TranStatus]) AS MaxvonTranStatus, 
Max([dbo].[recon_zw1_archive].[Action]) AS MaxvonAction, 
Max([dbo].[recon_zw1_archive].[CashflowType]) AS MaxvonCashflowType, 
case when [dbo].[recon_zw1_archive].[Account_Endur] is NULL then '' else [dbo].[recon_zw1_archive].[Account_Endur] end 
	+ case when [dbo].[recon_zw1_archive].[Account_SAP] is NULL then '' else [dbo].[recon_zw1_archive].[Account_SAP] end AS Account, 
Max([dbo].[recon_zw1_archive].[Adj_Category]) AS MaxvonAdj_Kategorie, 
Max([dbo].[recon_zw1_archive].[Adj_Comment]) AS MaxvonAdj_Anmerkung, 
Max([dbo].[recon_zw1_archive].[Partner]) AS Maxvonpartner, 
Max([dbo].[recon_zw1_archive].[VAT_Script]) AS MaxvonStKZ_Script, 
Max([dbo].[recon_zw1_archive].[VAT_SAP]) AS MaxvonStKZ_SAP, 
Max([dbo].[recon_zw1_archive].[VAT_CountryCode]) AS Maxvonlkz,
MAX([dbo].[Recon_zw1_archive].[Material]) as Material
FROM [dbo].[recon_zw1_archive] LEFT JOIN [dbo].[00_map_order] ON [dbo].[recon_zw1_archive].[OrderNo] = [dbo].[00_map_order].[OrderNo]

WHERE (InternalLegalEntity not in ('n/a') AND asofdate = convert(datetime,'30.12.2022',104))

GROUP BY 
[dbo].[recon_zw1_archive].[Identifier], 
[dbo].[recon_zw1_archive].[ReconGroup], 
[dbo].[recon_zw1_archive].[OrderNo], 
[dbo].[recon_zw1_archive].[DeliveryMonth], 
[dbo].[recon_zw1_archive].[DealID_Recon], 
[dbo].[recon_zw1_archive].[ccy], 
[dbo].[recon_zw1_archive].[Deskccy], 
case when [dbo].[recon_zw1_archive].[Account_Endur] is NULL then '' else [dbo].[recon_zw1_archive].[Account_Endur] end 
	+ case when [dbo].[recon_zw1_archive].[Account_SAP] is NULL then '' else [dbo].[recon_zw1_archive].[Account_SAP] end


having 
(abs(Sum(recon_zw1_archive.[Volume_Endur]))+abs(Sum(recon_zw1_archive.[Volume_SAP])) +abs(Sum(recon_zw1_archive.[Volume_Adj])) +abs(Sum(recon_zw1_archive.[realised_ccy_Endur]))+abs(Sum(recon_zw1_archive.[realised_ccy_SAP]))+
abs(Sum(recon_zw1_archive.[realised_ccy_adj]))+abs(Sum(recon_zw1_archive.[realised_Deskccy_Endur]))+abs(Sum(recon_zw1_archive.[realised_Deskccy_SAP]))
+abs(Sum(recon_zw1_archive.[realised_Deskccy_adj])) +abs(Sum([dbo].[recon_zw1_archive].[realised_EUR_Endur]))
+abs(Sum([dbo].[recon_zw1_archive].[realised_EUR_SAP]))+abs(Sum([dbo].[recon_zw1_archive].[realised_EUR_adj])))<>0

GO

