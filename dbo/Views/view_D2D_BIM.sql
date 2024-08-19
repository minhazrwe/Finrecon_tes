





/*
 =============================================
 Author:      	MK
 Created:     	2023-04
 Description:	Create BIMs for D2D Recon
 ---------------------------------------------
 updates:


 ==============================================
*/



CREATE view [dbo].[view_D2D_BIM] AS
(
	-- ################################# EUR BIM #################################

	SELECT [KopfIdent], [Buchungskreis], [Belegdatum], [Belegart], [Buchungsdatum], [Currency], [Belegkopftext], [Referenz], [dummy1], [dummy2], [dummy3], [dummy4], [dummy5], [dummy6], [dummy7], [dummy8]
	FROM [dbo].[table_PE2PE_BIM_header]

	UNION ALL

	SELECT 'BKPF'
	,'0600'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'EUR'
	,'D2D'
	,'D2D ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL

	UNION ALL

	SELECT NULL
	,IIF(SUM([Realised]) < 0, '40', '50')
	,[SAP_Account]
	,[OrderNo]
	,CONVERT(Varchar, FORMAT(ABS(SUM([Realised])), 'G'))
	,CONVERT(Varchar, FORMAT(ABS(SUM([Volume_new])), 'G'))
	,IIF([InstrumentType] LIKE 'REN-%' OR [InstrumentType] LIKE 'EM-%', 'ST', 'MWh')
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';DE;' + [ExternalPortfolio]
	,IIF(LEFT([SAP_Account], 1) = '4', 'AP', 'VP')
	,'0600'
	,NULL
	,NULL
	,[Ticker]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_D2D_with_matching_deals]
	WHERE [Currency] = 'EUR'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
	HAVING NOT (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

	SELECT 'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'

	UNION ALL

	SELECT 'BKPF'
	,'0600'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'EUR'
	,'D2D'
	,'D2D ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL

	UNION ALL

	SELECT ''
	,IIF(SUM([Volume_new]) < 0, '40', '50')
	,[SAP_Account]
	,[OrderNo]
	,'0.01'
	,CONVERT(Varchar, FORMAT(ABS(SUM([Volume_new])), 'G'))
	,IIF([InstrumentType] LIKE 'REN-%' OR [InstrumentType] LIKE 'EM-%', 'ST', 'MWh')
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';DE;' + [ExternalPortfolio]
	,IIF(LEFT([SAP_Account], 1) = '4', 'AP', 'VP')
	,'0600'
	,NULL
	,NULL
	,[Ticker]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_D2D_with_matching_deals]
	WHERE [Currency] = 'EUR'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
	HAVING (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	-- ################################# USD BIM #################################

	UNION ALL

	SELECT 'USD BIM BELOW'
	,'USD BIM BELOW'
	,'USD BIM BELOW'
	,'USD BIM BELOW'
	,'USD BIM BELOW'
	,'USD BIM BELOW'
	,'USD BIM BELOW'
	,'USD BIM BELOW'
	,'USD BIM BELOW'
	,'USD BIM BELOW'
	,'USD BIM BELOW'
	,'USD BIM BELOW'
	,'USD BIM BELOW'
	,'USD BIM BELOW'
	,'USD BIM BELOW'
	,'USD BIM BELOW'

	UNION ALL

	SELECT 'KopfIdent','Buchungskreis','Belegdatum','Belegart','Buchungsdatum','Currency','Belegkopftext','Referenz','dummy1','dummy2','dummy3','dummy4','dummy5','dummy6','dummy7','dummy8'

	UNION ALL

	SELECT [KopfIdent], [Buchungskreis], [Belegdatum], [Belegart], [Buchungsdatum], [Currency], [Belegkopftext], [Referenz], [dummy1], [dummy2], [dummy3], [dummy4], [dummy5], [dummy6], [dummy7], [dummy8]
	FROM [dbo].[table_PE2PE_BIM_header]

	UNION ALL

	SELECT 'BKPF'
	,'0600'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'USD'
	,'D2D'
	,'D2D ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL

	UNION ALL

	SELECT NULL
	,IIF(SUM([Realised]) < 0, '40', '50')
	,[SAP_Account]
	,[OrderNo]
	,CONVERT(Varchar, FORMAT(ABS(SUM([Realised])), 'G'))
	,CONVERT(Varchar, FORMAT(ABS(SUM([Volume_new])), 'G'))
	,IIF([InstrumentType] LIKE 'REN-%' OR [InstrumentType] LIKE 'EM-%', 'ST', 'MWh')
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';DE;' + [ExternalPortfolio]
	,IIF(LEFT([SAP_Account], 1) = '4', 'AP', 'VP')
	,'0600'
	,NULL
	,NULL
	,[Ticker]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_D2D_with_matching_deals]
	WHERE [Currency] = 'USD'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
	HAVING NOT (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

	SELECT 'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'

	UNION ALL

	SELECT 'BKPF'
	,'0600'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'USD'
	,'D2D'
	,'D2D ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL

	UNION ALL

	SELECT ''
	,IIF(SUM([Volume_new]) < 0, '40', '50')
	,[SAP_Account]
	,[OrderNo]
	,'0.01'
	,CONVERT(Varchar, FORMAT(ABS(SUM([Volume_new])), 'G'))
	,IIF([InstrumentType] LIKE 'REN-%' OR [InstrumentType] LIKE 'EM-%', 'ST', 'MWh')
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';DE;' + [ExternalPortfolio]
	,IIF(LEFT([SAP_Account], 1) = '4', 'AP', 'VP')
	,'0600'
	,NULL
	,NULL
	,[Ticker]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_D2D_with_matching_deals]
	WHERE [Currency] = 'USD'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
	HAVING (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	-- ################################# GBP BIM #################################

	UNION ALL

	SELECT 'GBP BIM BELOW'
	,'GBP BIM BELOW'
	,'GBP BIM BELOW'
	,'GBP BIM BELOW'
	,'GBP BIM BELOW'
	,'GBP BIM BELOW'
	,'GBP BIM BELOW'
	,'GBP BIM BELOW'
	,'GBP BIM BELOW'
	,'GBP BIM BELOW'
	,'GBP BIM BELOW'
	,'GBP BIM BELOW'
	,'GBP BIM BELOW'
	,'GBP BIM BELOW'
	,'GBP BIM BELOW'
	,'GBP BIM BELOW'

	UNION ALL

	SELECT 'KopfIdent','Buchungskreis','Belegdatum','Belegart','Buchungsdatum','Currency','Belegkopftext','Referenz','dummy1','dummy2','dummy3','dummy4','dummy5','dummy6','dummy7','dummy8'

	UNION ALL

	SELECT [KopfIdent], [Buchungskreis], [Belegdatum], [Belegart], [Buchungsdatum], [Currency], [Belegkopftext], [Referenz], [dummy1], [dummy2], [dummy3], [dummy4], [dummy5], [dummy6], [dummy7], [dummy8]
	FROM [dbo].[table_PE2PE_BIM_header]

	UNION ALL

	SELECT 'BKPF'
	,'0600'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'GBP'
	,'D2D'
	,'D2D ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL

	UNION ALL

	SELECT NULL
	,IIF(SUM([Realised]) < 0, '40', '50')
	,[SAP_Account]
	,[OrderNo]
	,CONVERT(Varchar, FORMAT(ABS(SUM([Realised])), 'G'))
	,CONVERT(Varchar, FORMAT(ABS(SUM([Volume_new])), 'G'))
	,IIF([InstrumentType] LIKE 'REN-%' OR [InstrumentType] LIKE 'EM-%', 'ST', 'MWh')
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';DE;' + [ExternalPortfolio]
	,IIF(LEFT([SAP_Account], 1) = '4', 'AP', 'VP')
	,'0600'
	,NULL
	,NULL
	,[Ticker]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_D2D_with_matching_deals]
	WHERE [Currency] = 'GBP'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
	HAVING NOT (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

	SELECT 'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'

	UNION ALL

	SELECT 'BKPF'
	,'0600'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'GBP'
	,'D2D'
	,'D2D ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL

	UNION ALL

	SELECT ''
	,IIF(SUM([Volume_new]) < 0, '40', '50')
	,[SAP_Account]
	,[OrderNo]
	,'0.01'
	,CONVERT(Varchar, FORMAT(ABS(SUM([Volume_new])), 'G'))
	,IIF([InstrumentType] LIKE 'REN-%' OR [InstrumentType] LIKE 'EM-%', 'ST', 'MWh')
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';DE;' + [ExternalPortfolio]
	,IIF(LEFT([SAP_Account], 1) = '4', 'AP', 'VP')
	,'0600'
	,NULL
	,NULL
	,[Ticker]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_D2D_with_matching_deals]
	WHERE [Currency] = 'GBP'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
	HAVING (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	-- ################################# CZK BIM #################################

	UNION ALL

	SELECT 'RON BIM BELOW'
	,'RON BIM BELOW'
	,'RON BIM BELOW'
	,'RON BIM BELOW'
	,'RON BIM BELOW'
	,'RON BIM BELOW'
	,'RON BIM BELOW'
	,'RON BIM BELOW'
	,'RON BIM BELOW'
	,'RON BIM BELOW'
	,'RON BIM BELOW'
	,'RON BIM BELOW'
	,'RON BIM BELOW'
	,'RON BIM BELOW'
	,'RON BIM BELOW'
	,'RON BIM BELOW'

	UNION ALL

	SELECT 'KopfIdent','Buchungskreis','Belegdatum','Belegart','Buchungsdatum','Currency','Belegkopftext','Referenz','dummy1','dummy2','dummy3','dummy4','dummy5','dummy6','dummy7','dummy8'

	UNION ALL

	SELECT [KopfIdent], [Buchungskreis], [Belegdatum], [Belegart], [Buchungsdatum], [Currency], [Belegkopftext], [Referenz], [dummy1], [dummy2], [dummy3], [dummy4], [dummy5], [dummy6], [dummy7], [dummy8]
	FROM [dbo].[table_PE2PE_BIM_header]

	UNION ALL

	SELECT 'BKPF'
	,'0600'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'RON'
	,'D2D'
	,'D2D ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL

	UNION ALL

	SELECT NULL
	,IIF(SUM([Realised]) < 0, '40', '50')
	,[SAP_Account]
	,[OrderNo]
	,CONVERT(Varchar, FORMAT(ABS(SUM([Realised])), 'G'))
	,CONVERT(Varchar, FORMAT(ABS(SUM([Volume_new])), 'G'))
	,IIF([InstrumentType] LIKE 'REN-%' OR [InstrumentType] LIKE 'EM-%', 'ST', 'MWh')
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';DE;' + [ExternalPortfolio]
	,IIF(LEFT([SAP_Account], 1) = '4', 'AP', 'VP')
	,'0600'
	,NULL
	,NULL
	,[Ticker]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_D2D_with_matching_deals]
	WHERE [Currency] = 'RON'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
	HAVING NOT (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

	SELECT 'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'

	UNION ALL

	SELECT 'BKPF'
	,'0600'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'RON'
	,'D2D'
	,'D2D ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL

	UNION ALL

	SELECT ''
	,IIF(SUM([Volume_new]) < 0, '40', '50')
	,[SAP_Account]
	,[OrderNo]
	,'0.01'
	,CONVERT(Varchar, FORMAT(ABS(SUM([Volume_new])), 'G'))
	,IIF([InstrumentType] LIKE 'REN-%' OR [InstrumentType] LIKE 'EM-%', 'ST', 'MWh')
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';DE;' + [ExternalPortfolio]
	,IIF(LEFT([SAP_Account], 1) = '4', 'AP', 'VP')
	,'0600'
	,NULL
	,NULL
	,[Ticker]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_D2D_with_matching_deals]
	WHERE [Currency] = 'RON'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
	HAVING (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	-- ################################# HUF BIM #################################

	UNION ALL

	SELECT 'PLN BIM BELOW'
	,'PLN BIM BELOW'
	,'PLN BIM BELOW'
	,'PLN BIM BELOW'
	,'PLN BIM BELOW'
	,'PLN BIM BELOW'
	,'PLN BIM BELOW'
	,'PLN BIM BELOW'
	,'PLN BIM BELOW'
	,'PLN BIM BELOW'
	,'PLN BIM BELOW'
	,'PLN BIM BELOW'
	,'PLN BIM BELOW'
	,'PLN BIM BELOW'
	,'PLN BIM BELOW'
	,'PLN BIM BELOW'

	UNION ALL

	SELECT 'KopfIdent','Buchungskreis','Belegdatum','Belegart','Buchungsdatum','Currency','Belegkopftext','Referenz','dummy1','dummy2','dummy3','dummy4','dummy5','dummy6','dummy7','dummy8'

	UNION ALL

	SELECT [KopfIdent], [Buchungskreis], [Belegdatum], [Belegart], [Buchungsdatum], [Currency], [Belegkopftext], [Referenz], [dummy1], [dummy2], [dummy3], [dummy4], [dummy5], [dummy6], [dummy7], [dummy8]
	FROM [dbo].[table_PE2PE_BIM_header]

	UNION ALL

	SELECT 'BKPF'
	,'0600'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'PLN'
	,'D2D'
	,'D2D ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL

	UNION ALL

	SELECT NULL
	,IIF(SUM([Realised]) < 0, '40', '50')
	,[SAP_Account]
	,[OrderNo]
	,CONVERT(Varchar, FORMAT(ABS(SUM([Realised])), 'G'))
	,CONVERT(Varchar, FORMAT(ABS(SUM([Volume_new])), 'G'))
	,IIF([InstrumentType] LIKE 'REN-%' OR [InstrumentType] LIKE 'EM-%', 'ST', 'MWh')
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';DE;' + [ExternalPortfolio]
	,IIF(LEFT([SAP_Account], 1) = '4', 'AP', 'VP')
	,'0600'
	,NULL
	,NULL
	,[Ticker]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_D2D_with_matching_deals]
	WHERE [Currency] = 'PLN'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
	HAVING NOT (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

	SELECT 'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'
	,'VOLUME CORRECTION BELOW'

	UNION ALL

	SELECT 'BKPF'
	,'0600'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'PLN'
	,'D2D'
	,'D2D ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL

	UNION ALL

	SELECT ''
	,IIF(SUM([Volume_new]) < 0, '40', '50')
	,[SAP_Account]
	,[OrderNo]
	,'0.01'
	,CONVERT(Varchar, FORMAT(ABS(SUM([Volume_new])), 'G'))
	,IIF([InstrumentType] LIKE 'REN-%' OR [InstrumentType] LIKE 'EM-%', 'ST', 'MWh')
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';DE;' + [ExternalPortfolio]
	,IIF(LEFT([SAP_Account], 1) = '4', 'AP', 'VP')
	,'0600'
	,NULL
	,NULL
	,[Ticker]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_D2D_with_matching_deals]
	WHERE [Currency] = 'PLN'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
	HAVING (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

)

GO

