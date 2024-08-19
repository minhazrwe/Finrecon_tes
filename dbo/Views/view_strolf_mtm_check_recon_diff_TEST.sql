


--select distinct internalportfolio from dbo.view_strolf_mtm_check_recon_diff

---select * from dbo.view_strolf_mtm_check_recon_diff

CREATE view [dbo].[view_strolf_mtm_check_recon_diff_TEST] as
SELECT 
  SubDesk
	,Book
  ,CASE 
	   WHEN InstrumentType IN ('EM-INV-P', 'REN-INV-P', 'FX')
		 THEN InstrumentType
		 ELSE cast(DealID AS varchar) 
   END as DealID
	,InternalPortfolio
	,InstrumentType
	,Max(CounterpartyExternalBusinessUnit) AS CounterpartyExternalBusinessUnit
	,Max(ExternalPortfolio) AS ExternalPortfolio
	,Max(termend) AS TermEnd
	,Max(Product) AS MaxvonProduct
	,Sum(RiskMtM) AS RiskMtM
	,Sum(RiskRealised) AS RiskRealised
	,Sum(FT) AS FT
	,Sum(Kaskade) AS Kaskade
	,Sum(DiffMTM) AS DiffMTM
	,Sum(Round((DiffMTM + RiskRealised), 2)) AS DiffTotal
FROM 
  dbo.table_strolf_mtm_check_02_recon_raw_test
WHERE
	InternalPortfolio NOT LIKE 'BMT%'
	AND InternalPortfolio NOT LIKE 'RHP%'
	AND InternalPortfolio NOT LIKE 'TS %'
	AND InternalPortfolio NOT LIKE 'SCHED%'
	AND InternalPortfolio NOT LIKE 'RES_BE%'
	AND InternalPortfolio NOT LIKE 'DUMMY_CE%'
	AND InternalPortfolio NOT IN ('STT_DE_FINPHYSxxx', 'STT_NL_FINPHYSxxx','IDT_CE_INDEX_EXCHANGE')
GROUP BY 
   SubDesk
	,Book
  ,CASE 
	   WHEN InstrumentType IN ('EM-INV-P', 'REN-INV-P', 'FX')
		 THEN InstrumentType
		 ELSE cast(DealID AS varchar) 
   END 
	,InternalPortfolio
	,InstrumentType
HAVING 
	ABS(Sum(DiffMTM)) > 1
	AND
	(
		InstrumentType NOT IN ('PWR-FUT-EXCH-F', 'PWR-FUT-EXCH-P')		
		OR 
		(
      InstrumentType IN ('PWR-FUT-EXCH-F', 'PWR-FUT-EXCH-P')
			AND	Max(Product) IS NULL
		)

  )

GO

