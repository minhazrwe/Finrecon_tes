
create view dbo.view_RiskRecon_ccy as

SELECT 
      [DealID]
      
      ,[ccy]
     
  FROM [FinRecon].[dbo].[RiskRecon_CAOCE] where ccy is not null

GO

