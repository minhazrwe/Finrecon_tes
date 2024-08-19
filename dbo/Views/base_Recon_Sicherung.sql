


CREATE view [dbo].[base_Recon_Sicherung] ( Identifier, InternalLegalEntity, ReconGroup, Desk, SubDesk, OrderNo, 
DeliveryMonth, DealID_Recon, DealID, Portfolio, CounterpartyGroup, 
InstrumentType, ProjIndexGroup, CurveName, ExternalLegal, ExternalBusinessUnit, 
ExternalPortfolio, TradeDate, EventDate, SAP_DocumentNumber, Volume_Endur, 
Volume_SAP, Volume_Adj, UOM_Endur, UOM_SAP, realised_ccy_Endur, 
realised_ccy_SAP, realised_ccy_adj, ccy, realised_Deskccy_Endur, realised_Deskccy_SAP, realised_Deskccy_adj, Deskccy, realised_EUR_Endur, realised_EUR_SAP, realised_EUR_SAP_conv, 
realised_EUR_adj, Account_Endur, Account_SAP, diff_Volume, Diff_Realised_EUR, Diff_Realised_DeskCCY, Diff_Realised_CCY, 
InternalBusinessUnit, DocumentNumber, Reference, TranStatus, [Action], CashflowType, 
Account, Adj_Category, Adj_Comment, [Partner], VAT_Script, VAT_SAP, VAT_CountryCode, Material)
 as SELECT 
[dbo].[Recon_zw1].[Identifier] , 
Max([dbo].[Recon_zw1].[InternalLegalEntity]) AS MaxvonInternalLegalEntity, 
[dbo].[Recon_zw1].[ReconGroup], 
Max([dbo].[00_map_order].[Desk]) AS MaxvonDesk, 
Max([dbo].[00_map_order].[SubDesk]) AS MaxvonSubDesk, 
[dbo].[Recon_zw1].[OrderNo] AS Ausdr1, 
[dbo].[Recon_zw1].[DeliveryMonth], 
[dbo].[Recon_zw1].[DealID_Recon], 
Max([dbo].[Recon_zw1].[DealID]) AS MaxvonDealID, 
Max([dbo].[Recon_zw1].[Portfolio]) AS MaxvonPortfolio, 
Max([dbo].[Recon_zw1].[CounterpartyGroup]) AS MaxvonCounterpartyGroup, 
Max([dbo].[Recon_zw1].[InstrumentType]) AS MaxvonInstrumentType, 
Max([dbo].[Recon_zw1].[ProjIndexGroup]) AS MaxvonProjIndexGroup, 
Max([dbo].[Recon_zw1].[CurveName]) AS MaxvonCurveName, 
Max([dbo].[Recon_zw1].[ExternalLegal]) AS MaxvonExternalLegal, 
Max(case when [dbo].[Recon_zw1].[ExternalPortfolio] In ('RGM_CZ_DUMMY_POS','RGM_D_DUMMY_POS') then 'OffeneMenge' else [dbo].[Recon_zw1].[ExternalBusinessUnit] end ) AS ExtBunit, 
Max([dbo].[Recon_zw1].[ExternalPortfolio]) AS MaxvonExternalPortfolio, 
Max([dbo].[Recon_zw1].[TradeDate]) AS MaxvonTradeDate, 
Max([dbo].[Recon_zw1].[EventDate]) AS MaxvonEventDate, 
Max([dbo].[Recon_zw1].[DocumentNumber_SAP]) AS MaxvonSAP_Belegnummer, 
round(Sum(Recon_zw1.[Volume_Endur]),3) AS SummevonVolume_Endur, 
round(Sum(Recon_zw1.[Volume_SAP]),3) AS SummevonVolume_SAP, 
round(Sum(Recon_zw1.[Volume_Adj]),3) AS SummevonVolume_Adj, 
Max(Recon_zw1.[UOM_Endur]) AS MaxvonUOM_Endur, 
Max(Recon_zw1.[UOM_SAP]) AS MaxvonUOM_SAP, 
round(Sum(Recon_zw1.[realised_ccy_Endur]),2) AS Summevonrealised_ccy_Endur, 
round(Sum(Recon_zw1.[realised_ccy_SAP]),2) AS Summevonrealised_ccy_SAP, 
round(Sum(Recon_zw1.[realised_ccy_adj]),2) AS Summevonrealised_ccy_adj, 
[dbo].[Recon_zw1].[ccy], 
round(Sum(Recon_zw1.[realised_Deskccy_Endur]),2) AS Summevonrealised_Deskccy_Endur, 
round(Sum(Recon_zw1.[realised_Deskccy_SAP]),2) AS Summevonrealised_Deskccy_SAP, 
round(Sum(Recon_zw1.[realised_Deskccy_adj]),2) AS Summevonrealised_Deskccy_adj, 
[dbo].[Recon_zw1].[DeskCcy], 
round(Sum([dbo].[Recon_zw1].[realised_EUR_Endur]),2) AS Summevonrealised_EUR_Endur, 
round(Sum([dbo].[Recon_zw1].[realised_EUR_SAP]),2) AS Summevonrealised_EUR_SAP, 
round(Sum([dbo].[Recon_zw1].[realised_EUR_SAP_conv]),2) AS Summevonrealised_EUR_SAP_conv, 
round(Sum([dbo].[Recon_zw1].[realised_EUR_adj]),2) AS Summevonrealised_EUR_adj, 
Max([dbo].[Recon_zw1].[Account_Endur]) AS MaxvonKonto_Endur, 
Max([dbo].[Recon_zw1].[Account_SAP]) AS MaxvonSAP_Konto, 
round(Sum([dbo].[Recon_zw1].[volume_Endur]+[dbo].[Recon_zw1].[volume_SAP]-[dbo].[Recon_zw1].[Volume_Adj]),3) AS diff_Volume, 
round(Sum([dbo].[Recon_zw1].[realised_eur_endur]-[dbo].[Recon_zw1].[realised_eur_sap_conv]-[dbo].[Recon_zw1].[realised_eur_adj]),2) AS diff_eur, 
round(Sum([dbo].[Recon_zw1].[realised_Deskccy_endur]-[dbo].[Recon_zw1].[realised_Deskccy_SAP]-[dbo].[Recon_zw1].[realised_Deskccy_adj]),2) AS diff_Deskccy,
round(Sum([dbo].[Recon_zw1].[realised_ccy_endur]-[dbo].[Recon_zw1].[realised_ccy_SAP]-[dbo].[Recon_zw1].[realised_ccy_adj]),2) AS diff_ccy, 
Max([dbo].[Recon_zw1].[InternalBusinessUnit]) AS MaxvonInternalBusinessUnit, 
Max([dbo].[Recon_zw1].[DocumentNumber]) AS MaxvonDocumentNumber, 
Max([dbo].[Recon_zw1].[Reference]) AS MaxvonReference, 
Max([dbo].[Recon_zw1].[TranStatus]) AS MaxvonTranStatus, 
Max([dbo].[Recon_zw1].[Action]) AS MaxvonAction, 
Max([dbo].[Recon_zw1].[CashflowType]) AS MaxvonCashflowType, 
case when [dbo].[Recon_zw1].[Account_Endur] is NULL then '' else [dbo].[Recon_zw1].[Account_Endur] end 
	+ case when [dbo].[Recon_zw1].[Account_SAP] is NULL then '' else [dbo].[Recon_zw1].[Account_SAP] end AS Account, 
Max([dbo].[Recon_zw1].[Adj_Category]) AS MaxvonAdj_Kategorie, 
Max([dbo].[Recon_zw1].[Adj_Comment]) AS MaxvonAdj_Anmerkung, 
Max([dbo].[Recon_zw1].[Partner]) AS Maxvonpartner, 
Max([dbo].[Recon_zw1].[VAT_Script]) AS MaxvonStKZ_Script, 
Max([dbo].[Recon_zw1].[VAT_SAP]) AS MaxvonStKZ_SAP, 
Max([dbo].[Recon_zw1].[VAT_CountryCode])  AS Maxvonlkz,
MAX([dbo].[Recon_zw1].[Material]) as Material
FROM [dbo].[Recon_zw1] LEFT JOIN [dbo].[00_map_order] ON [dbo].[Recon_zw1].[OrderNo] = [dbo].[00_map_order].[OrderNo]

--WHERE (InternalLegalEntity not in ('n/a')) OLD and osolet after CS migration
WHERE (InternalLegalEntity not in ('n/a') and desk not in ('Industrial Sales - DUMMY')) or desk is null


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
--,case when Desk in ('Biofuels','Solidfuels') and recongroup in ('Physical Freight', 'Secondary Cost', 'Physical Coal', 'Physical Biomass') then round(abs(Recon_zw1.[realised_ccy_Endur]+Recon_zw1.[realised_ccy_SAP]+recon_zw1.[realised_ccy_adj]),0) else 0 end



having 
(abs(Sum(Recon_zw1.[Volume_Endur]))+abs(Sum(Recon_zw1.[Volume_SAP])) +abs(Sum(Recon_zw1.[Volume_Adj])) +abs(Sum(Recon_zw1.[realised_ccy_Endur]))+abs(Sum(Recon_zw1.[realised_ccy_SAP]))+
abs(Sum(Recon_zw1.[realised_ccy_adj]))+abs(Sum(Recon_zw1.[realised_Deskccy_Endur]))+abs(Sum(Recon_zw1.[realised_Deskccy_SAP]))
+abs(Sum(Recon_zw1.[realised_Deskccy_adj])) +abs(Sum([dbo].[Recon_zw1].[realised_EUR_Endur]))
+abs(Sum([dbo].[Recon_zw1].[realised_EUR_SAP]))+abs(Sum([dbo].[Recon_zw1].[realised_EUR_adj])))<>0
	OR Max([dbo].[Recon_zw1].[DocumentNumber_SAP])='1100208687' ---inserted on request of Enzo, 08/10/20202 mkb 

GO

