







CREATE view [dbo].[00_map_order_PortfolioID] -- This was created to allow for a new identifier /08/02/2024
as 
	SELECT 
		Max([LegalEntity]) AS LegalEntity, 
		--Max([Desk_Risk]) AS Desk_Risk, 
		--Max([SubDesk_Risk]) AS SubDesk_Risk, 
		Max([Desk]) AS Desk, 
		Max([SubDesk]) AS SubDesk, 
		Max([RevRecSubDesk]) AS RevRecSubDesk, -- added on 01.02.2024
		Max([Book]) AS Book, 
		Max([Portfolio]) AS MaxvonPortfolio, 
		[PortfolioID],
		Max([OrderNo]) AS MaxvonOrderNo, 
		Max([Ref3]) AS Ref3, 
		Max([ProfitCenter]) AS ProfitCenter,
		Max([SubDeskCCY]) AS SubDeskCCY,
		Max([RepCCY]) AS RepCCY,
		Max([CommodityForFX]) as Commodity
FROM 
	[dbo].[map_order]
where 
	[Desk] not in ('n/a')
GROUP BY 
	
	
	[PortfolioID]

GO

