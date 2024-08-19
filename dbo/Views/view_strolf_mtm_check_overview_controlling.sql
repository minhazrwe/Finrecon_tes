






CREATE   VIEW [dbo].[view_strolf_mtm_check_overview_controlling] as
SELECT 
	 cast(COB as datetime) as cob
	,InternalPortfolio
	,Month(TermEnd) AS TermEndMonth
	,Year(TermEnd) AS TermEndYear
	,round(Sum(mtm),2) AS PNL
	,'FASTracker' AS SourceSystem
	,Accounting AS Treatment
FROM 
  dbo.view_strolf_mtm_check_overview_recon
WHERE 
  Accounting in ('PNL','NE')
	AND InternalPortfolio not in ('RES_BE','DE_CAO_DCO_MTM_adj', 'DE_CAO_DCO_NOR_adj', 'IFH_Timespread_I', 'IFH_Timespread_II','RWEST_ERCOT_HEDGE_CERT','RWEST_PJM_HEDGE_CERT') /* excluded 2022-05-03 */
GROUP BY 
	 COB
	,InternalPortfolio
	,Month(TermEnd)
	,Year(TermEnd)
	,Accounting

GO

