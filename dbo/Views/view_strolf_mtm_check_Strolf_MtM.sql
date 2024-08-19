






CREATE view [dbo].[view_strolf_mtm_check_Strolf_MtM] as
SELECT 
     map_EndurPortfolioTree.Book
	,PORTFOLIO_NAME
	,PNL_TYPE
	,round(Sum(PNL),2) AS PNL
FROM 
  dbo.AsOfDate,
  dbo.Strolf_MOP_PLUS_REAL_CORR_EOM
  LEFT JOIN dbo.map_EndurPortfolioTree
	ON dbo.Strolf_MOP_PLUS_REAL_CORR_EOM.PORTFOLIO_NAME = dbo.map_EndurPortfolioTree.portfolio
  LEFT JOIN dbo.map_order ON map_order.Portfolio = Strolf_MOP_PLUS_REAL_CORR_EOM.PORTFOLIO_NAME
WHERE 
  map_order.Desk = 'CAO CE'
  AND PORTFOLIO_NAME NOT LIKE '%RHP%'
  AND PORTFOLIO_NAME NOT LIKE '%BMT%'
  AND PNL_TYPE = 'UNREALIZED'
  AND ([INS_TYPE_NAME] IN ('EM-INV-P','REN-INV-P')
      OR 
	  ([INS_TYPE_NAME] NOT IN ('EM-INV-P','REN-INV-P') AND  REALISATION_DATE_Original > [AsOfDate_EOM]))
GROUP BY 
     map_EndurPortfolioTree.Book
	,PORTFOLIO_NAME
	,PNL_TYPE

GO

