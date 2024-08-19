






/*changes: 
2022/06/10: added 'RWE RENEWABLES' 
2023/04/06: added Entities 'RWE Kaskasi GmbH', 'WIND FARM ALLE' und 'WINDPARK EMME' 

*/

CREATE view [dbo].[Tableau_Recon] as 
	SELECT 
       	 max([ID]) as [ID]
  ,[Identifier] 
 ,max([InternalLegalEntity]) as [InternalLegalEntity]
 ,max([Desk]) as [Desk]
 ,max([Subdesk]) as [Subdesk]
 ,max([ReconGroup]) as [ReconGroup]
 ,max([OrderNo]) as [OrderNo]
 ,max([DeliveryMonth]) as [DeliveryMonth]
 ,max([DealID_Recon]) as [DealID_Recon]
 ,max([DealID]) as [DealID]
 ,max([Portfolio]) as [Portfolio]
 ,max([InternalBusinessUnit]) as [InternalBusinessUnit]
 ,max([CounterpartyGroup]) as [CounterpartyGroup]
 ,max([InstrumentType]) as [InstrumentType]
 ,max([CashflowType]) as [CashflowType]
 ,max([ProjIndexGroup]) as [ProjIndexGroup]
 ,max([CurveName]) as [CurveName]
 ,max([ExternalLegal]) as [ExternalLegal]
 ,max([ExternalBusinessUnit]) as [ExternalBusinessUnit]
 ,max([ExternalPortfolio]) as [ExternalPortfolio]
 ,max([DocumentNumber]) as [DocumentNumber]
 ,max([Reference]) as [Reference]
 ,max([TranStatus]) as [TranStatus]
 ,max([Action]) as [Action]
 ,max([TradeDate]) as [TradeDate]
 ,max([EventDate]) as [EventDate]
 ,max([SAP_DocumentNumber]) as [SAP_DocumentNumber]
 ,sum([Volume_Endur]) as [Volume_Endur]
 ,sum([Volume_SAP]) as [Volume_SAP]
 ,sum([Volume_Adj]) as [Volume_Adj]
 ,max([UOM_Endur]) as [UOM_Endur]
 ,max([UOM_SAP]) as [UOM_SAP]
 ,max([ccy]) as [ccy]
 ,sum([realised_ccy_Endur]) as [realised_ccy_Endur]
 ,sum([realised_ccy_SAP]) as [realised_ccy_SAP]
 ,sum([realised_ccy_adj]) as [realised_ccy_adj]
 ,max([DeskCcy]) as [DeskCcy]
 ,sum([realised_Deskccy_Endur]) as [realised_Deskccy_Endur]
 ,sum([realised_Deskccy_SAP]) as [realised_Deskccy_SAP]
 ,sum([realised_Deskccy_adj]) as [realised_Deskccy_adj]
 ,sum([realised_EUR_Endur]) as [realised_EUR_Endur]
 ,sum([realised_EUR_SAP]) as [realised_EUR_SAP]
 ,sum([realised_EUR_SAP_conv]) as [realised_EUR_SAP_conv]
 ,sum([realised_EUR_adj]) as [realised_EUR_adj]
 ,max([Account]) as [Account]
 ,max([Account_Endur]) as [Account_Endur]
 ,max([Account_SAP]) as [Account_SAP]
 ,sum([Diff_Volume]) as [Diff_Volume]
 ,sum([Diff_Realised_CCY]) as [Diff_Realised_CCY]
 ,sum([Diff_Realised_DeskCCY]) as [Diff_Realised_DeskCCY]
 ,sum([Diff_Realised_EUR]) as [Diff_Realised_EUR]
 ,max([Adj_Category]) as [Adj_Category]
 ,max([Adj_Comment]) as [Adj_Comment]
 ,max([Partner]) as [Partner]
 ,max([VAT_Script]) as [VAT_Script]
 ,max([VAT_SAP]) as [VAT_SAP]
 ,max([VAT_CountryCode]) as [VAT_CountryCode]
 ,max([Material]) as [Material]
  FROM [dbo].[Recon]
  where [Identifier] is not null
  group by 
  [Identifier]

GO

