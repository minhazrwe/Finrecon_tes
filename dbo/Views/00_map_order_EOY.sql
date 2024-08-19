





CREATE view [dbo].[00_map_order_EOY] 
as 
	SELECT 
		Max([LegalEntity]) AS LegalEntity, 
		--Max([Desk_Risk]) AS Desk_Risk, 
		--Max([SubDesk_Risk]) AS SubDesk_Risk, 
		Max([Desk]) AS Desk, 
		Max([SubDesk]) AS SubDesk, 
				Max([Book]) AS Book, 
		Max([Portfolio]) AS MaxvonPortfolio, 
		Max([PortfolioID]) AS MaxvonPortfolioID,
		[OrderNo], 
		Max([Ref3]) AS Ref3, 
		Max([ProfitCenter]) AS ProfitCenter,
		Max([SubDeskCCY]) AS SubDeskCCY,
		Max([RepCCY]) AS RepCCY,
		Max([CommodityForFX]) as Commodity
FROM 
	[dbo].[map_order_2023]
where 
	[Desk] not in ('n/a')
GROUP BY 
	[OrderNo]

GO

