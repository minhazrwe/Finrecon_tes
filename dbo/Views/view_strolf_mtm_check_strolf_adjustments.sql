







CREATE view [dbo].[view_strolf_mtm_check_strolf_adjustments] as
SELECT distinct
   case when map_EndurPortfolioTree.Book is null then map_order.Book else map_EndurPortfolioTree.Book end as Book
	,dbo.Strolf_VAL_ADJUST_EOM.PORTFOLIO_NAME
	,dbo.Strolf_VAL_ADJUST_EOM.PNL_TYPE
	,dbo.Strolf_VAL_ADJUST_EOM.[DESCRIPTION] 
	,dbo.Strolf_VAL_ADJUST_EOM.PNL
	,dbo.Strolf_VAL_ADJUST_EOM.[START_DATE] AS StartDate
	,dbo.Strolf_VAL_ADJUST_EOM.END_DATE AS EndDate
FROM 
  dbo.Strolf_VAL_ADJUST_EOM
  LEFT outer JOIN dbo.map_EndurPortfolioTree
	ON dbo.Strolf_VAL_ADJUST_EOM.PORTFOLIO_NAME = map_EndurPortfolioTree.portfolio
   LEFT outer JOIN dbo.map_order
	ON dbo.Strolf_VAL_ADJUST_EOM.PORTFOLIO_NAME = map_order.Portfolio
WHERE 
   	map_order.Desk = 'CAO CE'
	AND map_EndurPortfolioTree.Book NOT LIKE '%RHP%'
	AND map_EndurPortfolioTree.Book NOT LIKE '%BMT%'
    AND PNL_TYPE = 'UNREALIZED'
    AND [START_DATE] <= COB
    AND [END_DATE] >= COB
	AND [DESCRIPTION] <> 'INTEREST_CHARGE'
	;

GO

