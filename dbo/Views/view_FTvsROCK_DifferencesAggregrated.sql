



/*
created:	2022/08
author:		mkb
purpose:	used during process of MTM check "FT vs ROCK" to prepare aggregated overview of differences between ROCK and FT. 
					prerequisites are 
					1) that all related mtm reports (FT AND ROCK) have been imported in to finrecon 
					2) procedure "FTvsROCK_MTMCheck" has been run afterwards

*/

CREATE view [dbo].[view_FTvsROCK_DifferencesAggregrated] AS
	SELECT 
				COB
				,Max(isnull(LegalEntity, subsidiary)) AS LegalEntity
				,Max(IsNull(dbo.map_order.desk, Strategy)) AS Desk
				,dbo.table_FTvsROCK_DifferencesDetail.TradeDealNumber
				,dbo.table_FTvsROCK_DifferencesDetail.InternalPortfolio
				--,dbo.table_FTvsROCK_DifferencesDetail.ExternalPortfolio
				,dbo.table_FTvsROCK_DifferencesDetail.InstrumentType
				,Max(TermEnd) AS TermEnd
				,Max(Product) AS Product
				,ROUND(Sum(ROCK),2) AS ROCK
				,ROUND(Sum(FASTracker),2) AS FASTracker
				,ROUND(Sum(DiffRounded),2) AS DiffRounded
				,ROUND(Abs(Sum(DiffRounded)),2) AS AbsDiffRounded
				,IIf(Abs(Sum(DiffRounded)) < 1, 'no diff', Max(isnull(dbo.map_pfexclude.comment, dbo.table_FTvsROCK_map_dealID_exclude.comment))) AS Info
			FROM 
				(
					(
						dbo.table_FTvsROCK_DifferencesDetail LEFT JOIN dbo.table_FTvsROCK_map_dealID_exclude
						ON dbo.table_FTvsROCK_DifferencesDetail.TradeDealNumber = dbo.table_FTvsROCK_map_dealID_exclude.TradeDealNumber
					) 
					LEFT JOIN dbo.map_order
					ON dbo.table_FTvsROCK_DifferencesDetail.InternalPortfolio = dbo.map_order.Portfolio
				)
				LEFT JOIN dbo.map_PFExclude
				ON dbo.table_FTvsROCK_DifferencesDetail.InternalPortfolio = dbo.map_PFExclude.InternalPortfolio
			WHERE 
				LegalEntity not like 'N/A'
				AND NOT
				(
					LegalEntity ='RWEST DE'
					and
					Desk = 'CAO US'
					and
					Portfolio in ('RWEST_ERCOT_HEDGE_CERT','RWEST_PJM_HEDGE_CERT')
				)
			GROUP BY 
				COB
				,dbo.table_FTvsROCK_DifferencesDetail.TradeDealNumber
				,dbo.table_FTvsROCK_DifferencesDetail.InternalPortfolio
				--,dbo.table_FTvsROCK_DifferencesDetail.ExternalPortfolio
				,dbo.table_FTvsROCK_DifferencesDetail.InstrumentType
			HAVING 	
				IIf(Abs(Sum(DiffRounded)) < 1, 'no diff', Max(isnull(dbo.map_pfexclude.comment, dbo.table_FTvsROCK_map_dealID_exclude.comment))) is null

GO

