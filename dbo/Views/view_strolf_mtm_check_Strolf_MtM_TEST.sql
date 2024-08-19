




CREATE view [dbo].[view_strolf_mtm_check_Strolf_MtM_TEST] as
	SELECT 
		map_EndurPortfolioTree.Book
		,PORTFOLIO_NAME
		,PNL_TYPE
		,round(Sum(PNL),2) AS PNL
	FROM 
		--dbo.Strolf_MOP_PLUS_REAL_CORR_EOM
		FIN_MOP_PLUS_REAL_CORR_mit_PNL_TYPE_ORIG_SUMMIERT
		LEFT JOIN dbo.map_EndurPortfolioTree
		ON dbo.FIN_MOP_PLUS_REAL_CORR_mit_PNL_TYPE_ORIG_SUMMIERT.PORTFOLIO_NAME = dbo.map_EndurPortfolioTree.portfolio
		  LEFT JOIN dbo.map_order ON map_order.Portfolio = FIN_MOP_PLUS_REAL_CORR_mit_PNL_TYPE_ORIG_SUMMIERT.PORTFOLIO_NAME
	WHERE 
		map_order.Desk = 'CAO CE'
		AND PORTFOLIO_NAME NOT LIKE '%RHP%'
		AND PORTFOLIO_NAME NOT LIKE '%BMT%'
		AND PNL_TYPE = 'UNREALIZED'
	GROUP BY 
		map_EndurPortfolioTree.Book
		,PORTFOLIO_NAME
		,PNL_TYPE

GO

