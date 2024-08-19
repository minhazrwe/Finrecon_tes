






CREATE view [dbo].[view_strolf_mtm_check_RiskReport] as
SELECT [ID]
	,[REP_DATE]
	,[PREV_DATE]
	,[EOLM_COB_DATE]
	,[EOLY_COB_DATE]
	,[Strolf_CAO_PNL_OV].[Desk]
	,[PFG_NAME]
	,[BUSINESS_TYPE]
	,[MTM_REP]
	,[MTM_PREV]
	,[REAL_REP]
	,[REAL_PREV]
	,[ALL_REP]
	,[ALL_PREV]
	,[DTD_PNL]
	,[MTD_PNL]
	,[YTD_PNL]
FROM [FinRecon].[dbo].[Strolf_CAO_PNL_OV]
LEFT JOIN (
	SELECT MAX([LegalEntity]) AS [LegalEntity]
		,MAX([Desk]) AS [Desk]
		,[Book]
	FROM map_order
	GROUP BY [Book]
	) o ON o.Book = [Strolf_CAO_PNL_OV].[PFG_NAME]
WHERE   o.Desk = 'CAO CE'
		--AND PFG_NAME NOT LIKE '%RHP%'
		--AND PFG_NAME NOT LIKE '%BMT%'
		AND PFG_NAME <> 'RES DISC BU'
		AND PFG_NAME <> 'CAO CE DUMMY BU'

GO

