












CREATE view [dbo].[view_strolf_mtm_check_Strolf_eom_corections] as
SELECT 
   COB
	,Book
	,PORTFOLIO_NAME
	,ins_type_name
	,COMMODITY_TYPE
	,PNL_Type
	,Sum(PNL) AS SummevonPNL
	,Month_ORIG
	,Month AS Month_Target
FROM 
  dbo.Strolf_HIST_PNL_PORT_FIN_EOM 
  LEFT JOIN dbo.map_order 
	ON dbo.Strolf_HIST_PNL_PORT_FIN_EOM.PORTFOLIO_NAME = dbo.map_order.Portfolio
WHERE 
	map_order.Desk = 'CAO CE'
	--AND Book NOT LIKE '%RHP%' /*wird für Aufteilung Dummy benötogt Buchung 0100/0110*/
	AND Book NOT LIKE '%BMT%'
	AND Book NOT IN ('CAO CE GEN DE DISC BU', 'CAO CE GEN NL DISC BU')
	AND
	INS_TYPE_NAME NOT IN ('EM-INV-P','REN-INV-P','VALUATION_ADJUSTMENT')
	AND
	PNL_Type = 'unrealized'
	AND
	(
	(
		Month_orig <= (SELECT asofdate_eom FROM asofdate)
		OR Month <= (SELECT asofdate_eom FROM asofdate)		
	)
	OR 
	(
	Portfolio = 'LTT_DE_DUMMY_DH'
	AND ins_type_name = 'COMM-FEE'
	)
	)
GROUP BY 
   COB
	,Book
	,PORTFOLIO_NAME
	,ins_type_name
	,COMMODITY_TYPE
	,PNL_Type
	,Month_ORIG
	,Month

UNION ALL

SELECT a.COB
	,o.Book
	,a.PORTFOLIO_NAME
	,'adj' AS Ins_type_name
	,'Adj' AS COMMODITY_TYPE
	,a.PNL_Type
	,Sum(a.PNL) AS SummevonPNL
	,a.end_date
	,a.end_date
FROM Strolf_VAL_ADJUST_EOM a
LEFT JOIN dbo.map_order o
	ON a.PORTFOLIO_NAME = o.Portfolio
WHERE a.end_date <= a.cob
	AND o.Desk = 'CAO CE'
	AND o.Book NOT LIKE '%RHP%'
	AND o.Book NOT LIKE '%BMT%'
	AND o.Book <> 'CAO CE DUMMY BU'
    AND pnl_type = 'UNREALIZED'
GROUP BY a.COB
	,o.Book
	,a.PORTFOLIO_NAME
	,a.PNL_Type
	,a.end_date
	,a.end_date

GO

