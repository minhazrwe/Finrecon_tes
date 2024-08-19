








CREATE VIEW [dbo].[view_strolf_mtm_check_overview_recon] AS 
SELECT DISTINCT 
   cast(COB as datetime) as cob
	,dbo.table_strolf_mtm_check_01_FT_data.Subsidiary
	,dbo.table_strolf_mtm_check_01_FT_data.Strategy
	,table_strolf_mtm_check_01_FT_data.Bereich
	,dbo.map_SBM.Book
	,TermEnd
	--,Format(table_strolf_mtm_check_01_FT_data.TermEnd, 'yyyy/MM') AS EndDate
	,year(TermEnd) as TermEndYear
	,dbo.table_strolf_mtm_check_01_FT_data.InternalPortfolio
	,dbo.table_strolf_mtm_check_01_FT_data.CounterpartyGroup
	,dbo.table_strolf_mtm_check_01_FT_data.ProjectionIndexGroup
	,table_strolf_mtm_check_01_FT_data.CurveName
	,dbo.table_strolf_mtm_check_01_FT_data.InstrumentType
	,table_strolf_mtm_check_01_FT_data.InternalLegalEntity
	,table_strolf_mtm_check_01_FT_data.InternalBusinessUnit
	,table_strolf_mtm_check_01_FT_data.ExternalLegalEntity
	,table_strolf_mtm_check_01_FT_data.ExternalPortfolio
	,Sum(table_strolf_mtm_check_01_FT_data.Volume) AS Volume
	,Sum(table_strolf_mtm_check_01_FT_data.mtm) AS mtm
	,dbo.table_strolf_mtm_check_01_FT_data.AccountingTreatment
	,table_strolf_mtm_check_01_FT_data.Accounting
FROM 
	dbo.table_strolf_mtm_check_01_FT_data
	LEFT JOIN dbo.map_SBM
	ON      dbo.table_strolf_mtm_check_01_FT_data.InternalPortfolio = dbo.map_SBM.InternalPortfolio
		AND dbo.table_strolf_mtm_check_01_FT_data.CounterpartyGroup = dbo.map_SBM.CounterpartyGroup
		AND dbo.table_strolf_mtm_check_01_FT_data.InstrumentType = dbo.map_SBM.Instrumenttype
		AND dbo.table_strolf_mtm_check_01_FT_data.ProjectionIndexGroup = dbo.map_SBM.ProjectionIndexGroup
	LEFT JOIN map_order ON map_order.Portfolio = table_strolf_mtm_check_01_FT_data.InternalPortfolio
WHERE 
	cob=(select AsOfDate.AsOfDate_EOM from AsOfDate)--nötig, weil wir den "most recent monat" abfragen und auch den prev_eom in der gleichen tabelle haben!!!
	--year(cob) = year((select AsOfDate.AsOfDate_EOM from dbo.AsOfDate))
	--and month(cob) = month((select AsOfDate.AsOfDate_EOM from AsOfDate))
	and (desk = 'CAO CE' OR table_strolf_mtm_check_01_FT_data.InternalPortfolio IN ('RWEST_ERCOT_HEDGE_CERT','RWEST_PJM_HEDGE_CERT'))
	and (table_strolf_mtm_check_01_FT_data.DealID NOT LIKE 'MA%' OR table_strolf_mtm_check_01_FT_data.DealID is null)
	and ((map_order.Book NOT LIKE '%RHP%' and map_order.Book NOT LIKE '%BMT%') OR map_order.Book is null)
GROUP BY 
	 cob	 
	,dbo.table_strolf_mtm_check_01_FT_data.Subsidiary
	,dbo.table_strolf_mtm_check_01_FT_data.Strategy
	,Bereich
	,dbo.map_SBM.Book
	,Format(TermEnd, 'yyyy\/MM')
	,TermEnd
	,dbo.table_strolf_mtm_check_01_FT_data.InternalPortfolio
	,dbo.table_strolf_mtm_check_01_FT_data.CounterpartyGroup
	,dbo.table_strolf_mtm_check_01_FT_data.ProjectionIndexGroup
	,CurveName
	,dbo.table_strolf_mtm_check_01_FT_data.InstrumentType
	,dbo.table_strolf_mtm_check_01_FT_data.InternalLegalEntity
	,InternalBusinessUnit
	,ExternalLegalEntity
	,ExternalPortfolio
	,dbo.table_strolf_mtm_check_01_FT_data.AccountingTreatment
	,Accounting

GO

