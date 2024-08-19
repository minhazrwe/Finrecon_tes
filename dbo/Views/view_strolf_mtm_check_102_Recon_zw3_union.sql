



CREATE view [dbo].[view_strolf_mtm_check_102_Recon_zw3_union] as
--recon_zw2_finance
SELECT 
   DealID
	,InternalPortfolio
	,InstrumentType
	,CounterpartyExternalBusinessUnit
	,ExternalPortfolio
	,Format([termend],'yyyy/MM') AS Term	
	,Product
	,0 AS Risk_MTM
	,0 AS Risk_Realised
	,dbo.table_strolf_mtm_check_01_FT_data.mtm AS FT
	,0 AS Kaskade
FROM 
	dbo.table_strolf_mtm_check_01_FT_data
WHERE
  dbo.table_strolf_mtm_check_01_FT_data.InternalPortfolio NOT LIKE '%_RHP_%'
  AND dbo.table_strolf_mtm_check_01_FT_data.InternalPortfolio NOT IN ('CAO_CE_LTT_POWER_RWEI')

UNION ALL
--/*Recon_zw1_Risk_IS*/
SELECT 
   DEAL_NUm AS DEAL_NUM
	,PORTFOLIO_NAME
	,INS_TYPE_NAME
	,EXT_BUNIT_NAME AS EXTERNAL_BUNIT_NAME
	,EXTERNAL_PORTFOLIO_NAME
	,Format([realisation_date],'yyyy/MM') AS TermEnd	
	,NULL AS Product
	,CASE 
	  WHEN [pnl_type] = 'UNREALIZED'
		THEN [PNL]
		ELSE 0
	 END AS Risk_MtM
	,CASE 
	  WHEN [pnl_type] <> 'UNREALIZED'
		THEN [PNL]
		ELSE 0
	 END AS Risk_realised
	,0 AS Finance_MtM
	,0 AS Finance_Kaskade
FROM 
   dbo.Strolf_IS_EUR_EOM
WHERE 
  PORTFOLIO_NAME LIKE '%PWR_BNL_OLD'
	AND realisation_date > (SELECT AsOfDate_EOM FROM AsOfDate)

UNION ALL

--103_Recon_zw1_Risk
SELECT 
  DEAL_NUm AS DEAL_NUM
	,PORTFOLIO_NAME
	,INS_TYPE_NAME
	,EXT_BUNIT_NAME AS EXTERNAL_BUNIT_NAME
	,EXTERNAL_PORTFOLIO_NAME
	,Format(REALISATION_DATE_original,'yyyy/MM') AS TermEnd	
	,NULL AS Product
	,CASE 
	  WHEN [pnl_type] = 'UNREALIZED'
		THEN [PNL]
		ELSE 0
	 END AS Risk_MtM
	,CASE 
	  WHEN [pnl_type] <> 'UNREALIZED'
		THEN [PNL]
		ELSE 0
	 END AS Risk_realised
	 ,0 AS Finance_MtM
	,0 AS Finance_Kaskade
FROM dbo.Strolf_MOP_PLUS_REAL_CORR_EOM
WHERE 
  (
	 PORTFOLIO_NAME NOT LIKE 'RHP'
   AND PORTFOLIO_NAME NOT LIKE 'BMT%'
   AND PORTFOLIO_NAME NOT IN ('CAO_CE_LTT_POWER_RWEI', 'STT_DE_ROM', 'STT_NL_ROM')
   AND DATEADD(DAY,-10,(DATEADD(MOnth,1,EOMONTH([REALISATION_DATE_Original]))))> (SELECT AsOfDate_EOM FROM AsOfDate)
  )
  OR INS_TYPE_NAME = 'em-inv-p'
	OR INS_TYPE_NAME = 'ren-inv-p';

GO

