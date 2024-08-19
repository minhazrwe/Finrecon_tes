






CREATE view [dbo].[view_strolf_mtm_check_recon_diff] as
SELECT table_strolf_mtm_check_02_recon_raw.SubDesk
	,table_strolf_mtm_check_02_recon_raw.Book
	,DealID
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
	,'NO' AS Agreed_Difference
FROM dbo.table_strolf_mtm_check_02_recon_raw
LEFT JOIN map_order ON map_order.Portfolio = table_strolf_mtm_check_02_recon_raw.InternalPortfolio
WHERE Desk = 'CAO CE'
	AND table_strolf_mtm_check_02_recon_raw.Book NOT LIKE '%BMT%'
	AND table_strolf_mtm_check_02_recon_raw.Book NOT LIKE '%RHP%'
	AND table_strolf_mtm_check_02_recon_raw.Book <> 'CAO CE DUMMY BU'
	AND InstrumentType NOT LIKE '%INV%'
	AND InstrumentType NOT LIKE '%IRS%'
	AND InstrumentType NOT LIKE '%FX%'
	AND isnumeric(DealID) = 1
GROUP BY table_strolf_mtm_check_02_recon_raw.SubDesk
	,table_strolf_mtm_check_02_recon_raw.Book
	,DealID
	,InternalPortfolio
	,InstrumentType
HAVING ABS(Sum(DiffMTM)) > 1
	--AND
	--(
	--	InstrumentType NOT IN ('PWR-FUT-EXCH-F', 'PWR-FUT-EXCH-P')		
	--	OR 
	--	(
	--     InstrumentType IN ('PWR-FUT-EXCH-F', 'PWR-FUT-EXCH-P')
	--		AND	Max(Product) IS NULL
	--	)
	--)

UNION ALL
SELECT table_strolf_mtm_check_02_recon_raw.SubDesk
	,table_strolf_mtm_check_02_recon_raw.Book
	,DealID
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
	,'YES' AS Agreed_Difference
FROM dbo.table_strolf_mtm_check_02_recon_raw
LEFT JOIN map_order ON map_order.Portfolio = table_strolf_mtm_check_02_recon_raw.InternalPortfolio
WHERE Desk = 'CAO CE'
	AND ((table_strolf_mtm_check_02_recon_raw.Book NOT LIKE '%BMT%' AND table_strolf_mtm_check_02_recon_raw.Book NOT LIKE '%RHP%' AND table_strolf_mtm_check_02_recon_raw.Book <> 'CAO CE DUMMY BU') OR table_strolf_mtm_check_02_recon_raw.Book is null)
	AND 
	((InstrumentType LIKE '%INV%'
	OR InstrumentType LIKE '%IRS%'
	OR InstrumentType LIKE '%FX%'
	)
	OR isnumeric(DealID) = 0)
GROUP BY table_strolf_mtm_check_02_recon_raw.SubDesk
	,table_strolf_mtm_check_02_recon_raw.Book
	,DealID
	,InternalPortfolio
	,InstrumentType
HAVING ABS(Sum(DiffMTM)) > 1
	--AND
	--(
	--	InstrumentType NOT IN ('PWR-FUT-EXCH-F', 'PWR-FUT-EXCH-P')		
	--	OR 
	--	(
	--     InstrumentType IN ('PWR-FUT-EXCH-F', 'PWR-FUT-EXCH-P')
	--		AND	Max(Product) IS NULL
	--	)
	--)

GO

