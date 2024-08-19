








CREATE view [dbo].[base_recon_update_VAT] as 
SELECT 
[dbo].[Recon_zw1].[Source], 
[dbo].[Recon_zw1].ReconGroup,
[dbo].[Recon_zw1].[DealID], 
[dbo].[Recon_zw1].[DeliveryMonth], 
[dbo].[Recon_zw1].[CashflowType],
[dbo].[Recon_zw1].[CounterpartyGroup], 
case when Sum([dbo].[Recon_zw1].[realised_ccy_Endur]) < 0 then Max([dbo].[Recon_zw1].[VAT_script]) else Min([dbo].[Recon_zw1].[VAT_script]) end as SOLL_VAT,
case when Sum([dbo].[Recon_zw1].[realised_ccy_Endur]) < 0 then Max([dbo].[Recon_zw1].[Account_Endur]) else Min([dbo].[Recon_zw1].[Account_Endur]) end as SOLL_Account
 
FROM 
[dbo].[Recon_zw1] 
WHERE 

 ([dbo].[Recon_zw1].[EventDate])<(select [AsOfDate_eom] from [dbo].[AsOfDate])
GROUP BY 
[dbo].[Recon_zw1].[Source], 
[dbo].[Recon_zw1].[DealID], 
[dbo].[Recon_zw1].ReconGroup,
[dbo].[Recon_zw1].[DeliveryMonth], 
[dbo].[Recon_zw1].[CashflowType],
[dbo].[Recon_zw1].[CounterpartyGroup]
HAVING 
((([dbo].[Recon_zw1].[Source]) = 'realised_script') 
AND (([dbo].[Recon_zw1].[CounterpartyGroup]) Not In ('InterPE')) 
AND ((Min([VAT_Script]) <> Max([VAT_Script])) OR (ReconGroup = 'FX' AND counterpartygroup = 'RWE AG')))

GO

