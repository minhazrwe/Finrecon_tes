
create view [dbo].[delete_dublicates] as SELECT [dbo].[02_Realised_all_details].LegalEntity, 
[dbo].[02_Realised_all_details].IntDesk, 
[dbo].[02_Realised_all_details].[group] as [group], 
[dbo].[02_Realised_all_details].InternalPortfolio, 
[dbo].[02_Realised_all_details].Deal, 
[dbo].[02_Realised_all_details].InstrumentType, 
[dbo].[02_Realised_all_details].ExternalLegalEntity, 
[dbo].[02_Realised_all_details].CashflowType, 
[dbo].[02_Realised_all_details].ProjectionIndex, 
[dbo].[02_Realised_all_details].TradeDate, 
[dbo].[02_Realised_all_details].EventDate, 
[dbo].[02_Realised_all_details].DeliveryMonth, 
[dbo].[02_Realised_all_details].Realised, 
Min([dbo].[02_Realised_all_details].DocumentNumber) AS MinvonDocumentNumber, 
Max([dbo].[02_Realised_all_details].DocumentNumber) AS MaxvonDocumentNumber, 
Min([dbo].[02_Realised_all_details].ID) AS MinvonID, 
Max([dbo].[02_Realised_all_details].ID) AS MaxvonID, 
Count([dbo].[02_Realised_all_details].Deal) AS AnzahlvonDeal
FROM [dbo].[02_Realised_all_details]
GROUP BY 
[dbo].[02_Realised_all_details].LegalEntity, 
[dbo].[02_Realised_all_details].IntDesk, 
[dbo].[02_Realised_all_details].[group], 
[dbo].[02_Realised_all_details].InternalPortfolio, 
[dbo].[02_Realised_all_details].Deal, 
[dbo].[02_Realised_all_details].InstrumentType, 
[dbo].[02_Realised_all_details].ExternalLegalEntity, 
[dbo].[02_Realised_all_details].CashflowType, 
[dbo].[02_Realised_all_details].ProjectionIndex, 
[dbo].[02_Realised_all_details].TradeDate, 
[dbo].[02_Realised_all_details].EventDate, 
[dbo].[02_Realised_all_details].DeliveryMonth, 
[dbo].[02_Realised_all_details].Realised
HAVING ((([dbo].[02_Realised_all_details].IntDesk) In ('CAO Power','Sales & Origination','CAO UK', 'RWE AG')) AND ((Count([dbo].[02_Realised_all_details].Deal))>1))

GO

