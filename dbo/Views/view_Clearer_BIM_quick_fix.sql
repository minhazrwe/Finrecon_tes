


CREATE view [dbo].[view_Clearer_BIM_quick_fix] as

(SELECT tCB.[ID]
,tCB.[KopfIdent]
,tCB.[Buchungskreis]
,tCB.[Belegdatum]
,tCB.[Belegart]
,tCB.[Buchungsdatum]
,tCB.[Waehrung]
,tCB.[Belegkopftext]
,tCB.[Referenz]
,tCB.[loeschen01]
,tCB.[loeschen02]
,tCB.[loeschen03]
,tCB.[loeschen04]
,tCB.[loeschen05]
,tCB.[loeschen06]
,tCB.[loeschen07]
,mO.[PortfolioID] AS [PORTFOLIO_ID]
,tCB.[loeschen08]
,tCB.[loeschen09]
,tCB.[loeschen10]
,tCB.[loeschen11]
,tCB.[loeschen12]
,tCB.[loeschen13]
,tCB.[loeschen14]
,tCB.[Desk]
,tCB.[PayReceive]
,tCB.[DocumentPartition]
,tCB.[clearerID]
,tCB.[COB]
,tCB.[RealisedPNL]
,tCB.[QuerySource]
FROM [FinRecon].[dbo].[table_Clearer_BIM] AS tCB
LEFT JOIN [FinRecon].[dbo].[map_order] AS mO
ON tCB.[loeschen07] = mO.[Portfolio])

GO

