




CREATE view [dbo].[view_strolf_mtm_check_RiskReport_unreported] as
SELECT dbo.Strolf_GEN_PNL.ID
	,dbo.Strolf_GEN_PNL.COB
	,dbo.Strolf_GEN_PNL.Desk
	,e.Book AS PFG_NAME
	,dbo.Strolf_GEN_PNL.PORTFOLIO_ID
	,dbo.Strolf_GEN_PNL.PORTFOLIO_NAME
	,dbo.Strolf_GEN_PNL.DELIVERY_MONTH
	,dbo.Strolf_GEN_PNL.PNL_TYPE
	,dbo.Strolf_GEN_PNL.PNL
FROM dbo.Strolf_GEN_PNL
LEFT JOIN (
	SELECT dbo.map_EndurPortfolioTree.Portfolio
		,dbo.map_EndurPortfolioTree.Book
	FROM dbo.map_EndurPortfolioTree
	GROUP BY dbo.map_EndurPortfolioTree.Portfolio
		,dbo.map_EndurPortfolioTree.Book
	) e ON e.portfolio = dbo.Strolf_GEN_PNL.PORTFOLIO_NAME
LEFT JOIN dbo.map_order ON map_order.Portfolio = dbo.Strolf_GEN_PNL.PORTFOLIO_NAME
WHERE map_order.Desk = 'CAO CE' and PNL_TYPE = 'UNREALIZED'

GO

