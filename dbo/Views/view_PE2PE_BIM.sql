




/*
 =============================================
 Author:      	MK
 Created:     	2023-04
 Description:	Create BIMs for PE2PE Recon
 ---------------------------------------------
 updates:
 2023-08-03: added CHF and DKK


 ==============================================
*/



CREATE view [dbo].[view_PE2PE_BIM] AS
(
	-- ################################# EUR BIM #################################

	SELECT [KopfIdent], [Buchungskreis], [Belegdatum], [Belegart], [Buchungsdatum], [Currency], [Belegkopftext], [Referenz], [dummy1], [dummy2], [dummy3], [dummy4], [dummy5], [dummy6], [dummy7], [dummy8], [dummy9]
	FROM [dbo].[table_PE2PE_BIM_header]

	UNION ALL

	SELECT 'BKPF'
	,'0600'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'EUR'
	,'PE2PE'
	,'PE2PE ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
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
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';GB;' + [LZB] + ';' + [ExternalPortfolio] + ';UK'
	,IIF(LEFT([SAP_Account], 1) = 4, 'AP', 'VP')
	,'0600'
	,NULL
	,NULL
	,[Ticker]
	,[LZB]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST DE - PE'
	AND [Currency] = 'EUR'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO], [LZB]
	HAVING NOT (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

	SELECT '999'
	,'37'
	,'80002'
	,'/'
	,CONVERT(Varchar, FORMAT(ABS(SUM([Realised])), 'G'))
	,'/'
	,'/'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,'Transfer PE2PE'
	,'/'
	,'0600'
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST DE - PE'
	AND [Currency] = 'EUR'
	--GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
	HAVING NOT (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

	SELECT 'BKPF'
	,'0611'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'EUR'
	,'PE2PE'
	,'PE2PE ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
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
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';GB;;' + [ExternalPortfolio] + ';DE'
	,IIF(LEFT([SAP_Account], 1) = 4, 'AP', 'VP')
	,'0611'
	,NULL
	,NULL
	,NULL
	,[Ticker]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST UK - PE'
	AND [Currency] = 'EUR'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
	HAVING NOT (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

	SELECT '999'
	,'07'
	,'80012'
	,'/'
	,CONVERT(Varchar, FORMAT(ABS(SUM([Realised])), 'G'))
	,'/'
	,'/'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,'Transfer PE2PE'
	,'/'
	,'0611'
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST UK - PE'
	AND [Currency] = 'EUR'
	--GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
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
	,'VOLUME CORRECTION BELOW'

	UNION ALL

	SELECT 'BKPF'
	,'0600'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'EUR'
	,'PE2PE'
	,'PE2PE ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
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
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';GB;' + [LZB] + ';' + [ExternalPortfolio] + ';UK'
	,IIF(LEFT([SAP_Account], 1) = 4, 'AP', 'VP')
	,'0600'
	,NULL
	,NULL
	,[Ticker]
	,[LZB]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST DE - PE'
	AND [Currency] = 'EUR'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO], [LZB]
	HAVING (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

	SELECT 'BKPF'
	,'0611'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'EUR'
	,'PE2PE'
	,'PE2PE ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
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
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';GB;;' + [ExternalPortfolio] + ';DE'
	,IIF(LEFT([SAP_Account], 1) = 4, 'AP', 'VP')
	,'0611'
	,NULL
	,NULL
	,NULL
	,[Ticker]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST UK - PE'
	AND [Currency] = 'EUR'
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
	,'USD BIM BELOW'

	UNION ALL

	SELECT 'KopfIdent','Buchungskreis','Belegdatum','Belegart','Buchungsdatum','Currency','Belegkopftext','Referenz','dummy1','dummy2','dummy3','dummy4','dummy5','dummy6','dummy7','dummy8','dummy9'

	UNION ALL

	SELECT [KopfIdent], [Buchungskreis], [Belegdatum], [Belegart], [Buchungsdatum], [Currency], [Belegkopftext], [Referenz], [dummy1], [dummy2], [dummy3], [dummy4], [dummy5], [dummy6], [dummy7], [dummy8], [dummy9]
	FROM [dbo].[table_PE2PE_BIM_header]

	UNION ALL

	SELECT 'BKPF'
	,'0600'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'USD'
	,'PE2PE'
	,'PE2PE ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
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
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';GB;' + [LZB] + ';' + [ExternalPortfolio] + ';UK'
	,IIF(LEFT([SAP_Account], 1) = 4, 'AP', 'VP')
	,'0600'
	,NULL
	,NULL
	,[Ticker]
	,[LZB]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST DE - PE'
	AND [Currency] = 'USD'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO], [LZB]
	HAVING NOT (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

	SELECT '999'
	,'37'
	,'80002'
	,'/'
	,CONVERT(Varchar, FORMAT(ABS(SUM([Realised])), 'G'))
	,'/'
	,'/'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,'Transfer PE2PE'
	,'/'
	,'0600'
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST DE - PE'
	AND [Currency] = 'USD'
	--GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
	HAVING NOT (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

	SELECT 'BKPF'
	,'0611'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'USD'
	,'PE2PE'
	,'PE2PE ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
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
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';GB;;' + [ExternalPortfolio] + ';DE'
	,IIF(LEFT([SAP_Account], 1) = 4, 'AP', 'VP')
	,'0611'
	,NULL
	,NULL
	,NULL
	,[Ticker]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST UK - PE'
	AND [Currency] = 'USD'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
	HAVING NOT (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

	SELECT '999'
	,'07'
	,'80012'
	,'/'
	,CONVERT(Varchar, FORMAT(ABS(SUM([Realised])), 'G'))
	,'/'
	,'/'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,'Transfer PE2PE'
	,'/'
	,'0611'
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST UK - PE'
	AND [Currency] = 'USD'
	--GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
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
	,'VOLUME CORRECTION BELOW'

	UNION ALL

	SELECT 'BKPF'
	,'0600'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'USD'
	,'PE2PE'
	,'PE2PE ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
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
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';GB;' + [LZB] + ';' + [ExternalPortfolio] + ';UK'
	,IIF(LEFT([SAP_Account], 1) = 4, 'AP', 'VP')
	,'0600'
	,NULL
	,NULL
	,[Ticker]
	,[LZB]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST DE - PE'
	AND [Currency] = 'USD'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO], [LZB]
	HAVING (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

	SELECT 'BKPF'
	,'0611'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'USD'
	,'PE2PE'
	,'PE2PE ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
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
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';GB;;' + [ExternalPortfolio] + ';DE'
	,IIF(LEFT([SAP_Account], 1) = 4, 'AP', 'VP')
	,'0611'
	,NULL
	,NULL
	,NULL
	,[Ticker]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST UK - PE'
	AND [Currency] = 'USD'
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
	,'GBP BIM BELOW'

	UNION ALL

	SELECT 'KopfIdent','Buchungskreis','Belegdatum','Belegart','Buchungsdatum','Currency','Belegkopftext','Referenz','dummy1','dummy2','dummy3','dummy4','dummy5','dummy6','dummy7','dummy8','dummy9'

	UNION ALL

	SELECT [KopfIdent], [Buchungskreis], [Belegdatum], [Belegart], [Buchungsdatum], [Currency], [Belegkopftext], [Referenz], [dummy1], [dummy2], [dummy3], [dummy4], [dummy5], [dummy6], [dummy7], [dummy8], [dummy9]
	FROM [dbo].[table_PE2PE_BIM_header]

	UNION ALL

	SELECT 'BKPF'
	,'0600'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'GBP'
	,'PE2PE'
	,'PE2PE ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
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
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';GB;' + [LZB] + ';' + [ExternalPortfolio] + ';UK'
	,IIF(LEFT([SAP_Account], 1) = 4, 'AP', 'VP')
	,'0600'
	,NULL
	,NULL
	,[Ticker]
	,[LZB]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST DE - PE'
	AND [Currency] = 'GBP'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO], [LZB]
	HAVING NOT (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

	SELECT '999'
	,'37'
	,'80002'
	,'/'
	,CONVERT(Varchar, FORMAT(ABS(SUM([Realised])), 'G'))
	,'/'
	,'/'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,'Transfer PE2PE'
	,'/'
	,'0600'
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST DE - PE'
	AND [Currency] = 'GBP'
	--GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
	HAVING NOT (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

	SELECT 'BKPF'
	,'0611'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'GBP'
	,'PE2PE'
	,'PE2PE ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
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
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';GB;;' + [ExternalPortfolio] + ';DE'
	,IIF(LEFT([SAP_Account], 1) = 4, 'AP', 'VP')
	,'0611'
	,NULL
	,NULL
	,NULL
	,[Ticker]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST UK - PE'
	AND [Currency] = 'GBP'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
	HAVING NOT (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

	SELECT '999'
	,'07'
	,'80012'
	,'/'
	,CONVERT(Varchar, FORMAT(ABS(SUM([Realised])), 'G'))
	,'/'
	,'/'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,'Transfer PE2PE'
	,'/'
	,'0611'
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST UK - PE'
	AND [Currency] = 'GBP'
	--GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
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
	,'VOLUME CORRECTION BELOW'

	UNION ALL

	SELECT 'BKPF'
	,'0600'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'GBP'
	,'PE2PE'
	,'PE2PE ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
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
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';GB;' + [LZB] + ';' + [ExternalPortfolio] + ';UK'
	,IIF(LEFT([SAP_Account], 1) = 4, 'AP', 'VP')
	,'0600'
	,NULL
	,NULL
	,[Ticker]
	,[LZB]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST DE - PE'
	AND [Currency] = 'GBP'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO], [LZB]
	HAVING (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

	SELECT 'BKPF'
	,'0611'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'GBP'
	,'PE2PE'
	,'PE2PE ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
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
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';GB;;' + [ExternalPortfolio] + ';DE'
	,IIF(LEFT([SAP_Account], 1) = 4, 'AP', 'VP')
	,'0611'
	,NULL
	,NULL
	,NULL
	,[Ticker]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST UK - PE'
	AND [Currency] = 'GBP'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
	HAVING (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	-- ################################# CZK BIM #################################

	UNION ALL

	SELECT 'CZK BIM BELOW'
	,'CZK BIM BELOW'
	,'CZK BIM BELOW'
	,'CZK BIM BELOW'
	,'CZK BIM BELOW'
	,'CZK BIM BELOW'
	,'CZK BIM BELOW'
	,'CZK BIM BELOW'
	,'CZK BIM BELOW'
	,'CZK BIM BELOW'
	,'CZK BIM BELOW'
	,'CZK BIM BELOW'
	,'CZK BIM BELOW'
	,'CZK BIM BELOW'
	,'CZK BIM BELOW'
	,'CZK BIM BELOW'
	,'CZK BIM BELOW'

	UNION ALL

	SELECT 'KopfIdent','Buchungskreis','Belegdatum','Belegart','Buchungsdatum','Currency','Belegkopftext','Referenz','dummy1','dummy2','dummy3','dummy4','dummy5','dummy6','dummy7','dummy8','dummy9'

	UNION ALL

	SELECT [KopfIdent], [Buchungskreis], [Belegdatum], [Belegart], [Buchungsdatum], [Currency], [Belegkopftext], [Referenz], [dummy1], [dummy2], [dummy3], [dummy4], [dummy5], [dummy6], [dummy7], [dummy8], [dummy9]
	FROM [dbo].[table_PE2PE_BIM_header]

	UNION ALL

	SELECT 'BKPF'
	,'0600'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'CZK'
	,'PE2PE'
	,'PE2PE ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
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
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';GB;' + [LZB] + ';' + [ExternalPortfolio] + ';UK'
	,IIF(LEFT([SAP_Account], 1) = 4, 'AP', 'VP')
	,'0600'
	,NULL
	,NULL
	,[Ticker]
	,[LZB]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST DE - PE'
	AND [Currency] = 'CZK'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO], [LZB]
	HAVING NOT (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

	SELECT '999'
	,'37'
	,'80002'
	,'/'
	,CONVERT(Varchar, FORMAT(ABS(SUM([Realised])), 'G'))
	,'/'
	,'/'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,'Transfer PE2PE'
	,'/'
	,'0600'
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST DE - PE'
	AND [Currency] = 'CZK'
	--GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
	HAVING NOT (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

	SELECT 'BKPF'
	,'0611'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'CZK'
	,'PE2PE'
	,'PE2PE ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
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
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';GB;;' + [ExternalPortfolio] + ';DE'
	,IIF(LEFT([SAP_Account], 1) = 4, 'AP', 'VP')
	,'0611'
	,NULL
	,NULL
	,NULL
	,[Ticker]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST UK - PE'
	AND [Currency] = 'CZK'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
	HAVING NOT (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

	SELECT '999'
	,'07'
	,'80012'
	,'/'
	,CONVERT(Varchar, FORMAT(ABS(SUM([Realised])), 'G'))
	,'/'
	,'/'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,'Transfer PE2PE'
	,'/'
	,'0611'
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST UK - PE'
	AND [Currency] = 'CZK'
	--GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
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
	,'VOLUME CORRECTION BELOW'

	UNION ALL

	SELECT 'BKPF'
	,'0600'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'CZK'
	,'PE2PE'
	,'PE2PE ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
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
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';GB;' + [LZB] + ';' + [ExternalPortfolio] + ';UK'
	,IIF(LEFT([SAP_Account], 1) = 4, 'AP', 'VP')
	,'0600'
	,NULL
	,NULL
	,[Ticker]
	,[LZB]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST DE - PE'
	AND [Currency] = 'CZK'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO], [LZB]
	HAVING (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

	SELECT 'BKPF'
	,'0611'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'CZK'
	,'PE2PE'
	,'PE2PE ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
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
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';GB;;' + [ExternalPortfolio] + ';DE'
	,IIF(LEFT([SAP_Account], 1) = 4, 'AP', 'VP')
	,'0611'
	,NULL
	,NULL
	,NULL
	,[Ticker]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST UK - PE'
	AND [Currency] = 'CZK'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
	HAVING (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	-- ################################# HUF BIM #################################

	UNION ALL

	SELECT 'HUF BIM BELOW'
	,'HUF BIM BELOW'
	,'HUF BIM BELOW'
	,'HUF BIM BELOW'
	,'HUF BIM BELOW'
	,'HUF BIM BELOW'
	,'HUF BIM BELOW'
	,'HUF BIM BELOW'
	,'HUF BIM BELOW'
	,'HUF BIM BELOW'
	,'HUF BIM BELOW'
	,'HUF BIM BELOW'
	,'HUF BIM BELOW'
	,'HUF BIM BELOW'
	,'HUF BIM BELOW'
	,'HUF BIM BELOW'
	,'HUF BIM BELOW'

	UNION ALL

	SELECT 'KopfIdent','Buchungskreis','Belegdatum','Belegart','Buchungsdatum','Currency','Belegkopftext','Referenz','dummy1','dummy2','dummy3','dummy4','dummy5','dummy6','dummy7','dummy8','dummy9'

	UNION ALL

	SELECT [KopfIdent], [Buchungskreis], [Belegdatum], [Belegart], [Buchungsdatum], [Currency], [Belegkopftext], [Referenz], [dummy1], [dummy2], [dummy3], [dummy4], [dummy5], [dummy6], [dummy7], [dummy8], [dummy9]
	FROM [dbo].[table_PE2PE_BIM_header]

	UNION ALL

	SELECT 'BKPF'
	,'0600'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'HUF'
	,'PE2PE'
	,'PE2PE ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
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
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';GB;' + [LZB] + ';' + [ExternalPortfolio] + ';UK'
	,IIF(LEFT([SAP_Account], 1) = 4, 'AP', 'VP')
	,'0600'
	,NULL
	,NULL
	,[Ticker]
	,[LZB]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST DE - PE'
	AND [Currency] = 'HUF'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO], [LZB]
	HAVING NOT (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

	SELECT '999'
	,'37'
	,'80002'
	,'/'
	,CONVERT(Varchar, FORMAT(ABS(SUM([Realised])), 'G'))
	,'/'
	,'/'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,'Transfer PE2PE'
	,'/'
	,'0600'
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST DE - PE'
	AND [Currency] = 'HUF'
	--GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
	HAVING NOT (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

	SELECT 'BKPF'
	,'0611'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'HUF'
	,'PE2PE'
	,'PE2PE ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
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
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';GB;;' + [ExternalPortfolio] + ';DE'
	,IIF(LEFT([SAP_Account], 1) = 4, 'AP', 'VP')
	,'0611'
	,NULL
	,NULL
	,NULL
	,[Ticker]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST UK - PE'
	AND [Currency] = 'HUF'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
	HAVING NOT (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

	SELECT '999'
	,'07'
	,'80012'
	,'/'
	,CONVERT(Varchar, FORMAT(ABS(SUM([Realised])), 'G'))
	,'/'
	,'/'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,'Transfer PE2PE'
	,'/'
	,'0611'
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST UK - PE'
	AND [Currency] = 'HUF'
	--GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
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
	,'VOLUME CORRECTION BELOW'

	UNION ALL

	SELECT 'BKPF'
	,'0600'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'HUF'
	,'PE2PE'
	,'PE2PE ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
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
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';GB;' + [LZB] + ';' + [ExternalPortfolio] + ';UK'
	,IIF(LEFT([SAP_Account], 1) = 4, 'AP', 'VP')
	,'0600'
	,NULL
	,NULL
	,[Ticker]
	,[LZB]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST DE - PE'
	AND [Currency] = 'HUF'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO], [LZB]
	HAVING (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

	SELECT 'BKPF'
	,'0611'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'HUF'
	,'PE2PE'
	,'PE2PE ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
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
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';GB;;' + [ExternalPortfolio] + ';DE'
	,IIF(LEFT([SAP_Account], 1) = 4, 'AP', 'VP')
	,'0611'
	,NULL
	,NULL
	,NULL
	,[Ticker]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST UK - PE'
	AND [Currency] = 'HUF'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
	HAVING (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	-- ################################# CHF BIM #################################

	UNION ALL

	SELECT 'CHF BIM BELOW'
	,'CHF BIM BELOW'
	,'CHF BIM BELOW'
	,'CHF BIM BELOW'
	,'CHF BIM BELOW'
	,'CHF BIM BELOW'
	,'CHF BIM BELOW'
	,'CHF BIM BELOW'
	,'CHF BIM BELOW'
	,'CHF BIM BELOW'
	,'CHF BIM BELOW'
	,'CHF BIM BELOW'
	,'CHF BIM BELOW'
	,'CHF BIM BELOW'
	,'CHF BIM BELOW'
	,'CHF BIM BELOW'
	,'CHF BIM BELOW'

	UNION ALL

	SELECT 'KopfIdent','Buchungskreis','Belegdatum','Belegart','Buchungsdatum','Currency','Belegkopftext','Referenz','dummy1','dummy2','dummy3','dummy4','dummy5','dummy6','dummy7','dummy8','dummy9'

	UNION ALL

	SELECT [KopfIdent], [Buchungskreis], [Belegdatum], [Belegart], [Buchungsdatum], [Currency], [Belegkopftext], [Referenz], [dummy1], [dummy2], [dummy3], [dummy4], [dummy5], [dummy6], [dummy7], [dummy8], [dummy9]
	FROM [dbo].[table_PE2PE_BIM_header]

	UNION ALL

	SELECT 'BKPF'
	,'0600'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'CHF'
	,'PE2PE'
	,'PE2PE ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
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
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';GB;' + [LZB] + ';' + [ExternalPortfolio] + ';UK'
	,IIF(LEFT([SAP_Account], 1) = 4, 'AP', 'VP')
	,'0600'
	,NULL
	,NULL
	,[Ticker]
	,[LZB]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST DE - PE'
	AND [Currency] = 'CHF'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO], [LZB]
	HAVING NOT (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

	SELECT '999'
	,'37'
	,'80002'
	,'/'
	,CONVERT(Varchar, FORMAT(ABS(SUM([Realised])), 'G'))
	,'/'
	,'/'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,'Transfer PE2PE'
	,'/'
	,'0600'
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST DE - PE'
	AND [Currency] = 'CHF'
	--GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
	HAVING NOT (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

	SELECT 'BKPF'
	,'0611'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'CHF'
	,'PE2PE'
	,'PE2PE ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
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
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';GB;;' + [ExternalPortfolio] + ';DE'
	,IIF(LEFT([SAP_Account], 1) = 4, 'AP', 'VP')
	,'0611'
	,NULL
	,NULL
	,NULL
	,[Ticker]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST UK - PE'
	AND [Currency] = 'CHF'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
	HAVING NOT (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

	SELECT '999'
	,'07'
	,'80012'
	,'/'
	,CONVERT(Varchar, FORMAT(ABS(SUM([Realised])), 'G'))
	,'/'
	,'/'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,'Transfer PE2PE'
	,'/'
	,'0611'
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST UK - PE'
	AND [Currency] = 'CHF'
	--GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
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
	,'VOLUME CORRECTION BELOW'

	UNION ALL

	SELECT 'BKPF'
	,'0600'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'CHF'
	,'PE2PE'
	,'PE2PE ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
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
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';GB;' + [LZB] + ';' + [ExternalPortfolio] + ';UK'
	,IIF(LEFT([SAP_Account], 1) = 4, 'AP', 'VP')
	,'0600'
	,NULL
	,NULL
	,[Ticker]
	,[LZB]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST DE - PE'
	AND [Currency] = 'CHF'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO], [LZB]
	HAVING (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

	SELECT 'BKPF'
	,'0611'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'CHF'
	,'PE2PE'
	,'PE2PE ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
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
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';GB;;' + [ExternalPortfolio] + ';DE'
	,IIF(LEFT([SAP_Account], 1) = 4, 'AP', 'VP')
	,'0611'
	,NULL
	,NULL
	,NULL
	,[Ticker]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST UK - PE'
	AND [Currency] = 'CHF'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
	HAVING (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)
	
	-- ################################# DKK BIM #################################

	UNION ALL

	SELECT 'DKK BIM BELOW'
	,'DKK BIM BELOW'
	,'DKK BIM BELOW'
	,'DKK BIM BELOW'
	,'DKK BIM BELOW'
	,'DKK BIM BELOW'
	,'DKK BIM BELOW'
	,'DKK BIM BELOW'
	,'DKK BIM BELOW'
	,'DKK BIM BELOW'
	,'DKK BIM BELOW'
	,'DKK BIM BELOW'
	,'DKK BIM BELOW'
	,'DKK BIM BELOW'
	,'DKK BIM BELOW'
	,'DKK BIM BELOW'
	,'DKK BIM BELOW'

	UNION ALL

	SELECT 'KopfIdent','Buchungskreis','Belegdatum','Belegart','Buchungsdatum','Currency','Belegkopftext','Referenz','dummy1','dummy2','dummy3','dummy4','dummy5','dummy6','dummy7','dummy8','dummy9'

	UNION ALL

	SELECT [KopfIdent], [Buchungskreis], [Belegdatum], [Belegart], [Buchungsdatum], [Currency], [Belegkopftext], [Referenz], [dummy1], [dummy2], [dummy3], [dummy4], [dummy5], [dummy6], [dummy7], [dummy8], [dummy9]
	FROM [dbo].[table_PE2PE_BIM_header]

	UNION ALL

	SELECT 'BKPF'
	,'0600'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'DKK'
	,'PE2PE'
	,'PE2PE ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
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
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';GB;' + [LZB] + ';' + [ExternalPortfolio] + ';UK'
	,IIF(LEFT([SAP_Account], 1) = 4, 'AP', 'VP')
	,'0600'
	,NULL
	,NULL
	,[Ticker]
	,[LZB]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST DE - PE'
	AND [Currency] = 'DKK'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO], [LZB]
	HAVING NOT (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

	SELECT '999'
	,'37'
	,'80002'
	,'/'
	,CONVERT(Varchar, FORMAT(ABS(SUM([Realised])), 'G'))
	,'/'
	,'/'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,'Transfer PE2PE'
	,'/'
	,'0600'
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST DE - PE'
	AND [Currency] = 'DKK'
	--GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
	HAVING NOT (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

	SELECT 'BKPF'
	,'0611'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'DKK'
	,'PE2PE'
	,'PE2PE ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
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
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';GB;;' + [ExternalPortfolio] + ';DE'
	,IIF(LEFT([SAP_Account], 1) = 4, 'AP', 'VP')
	,'0611'
	,NULL
	,NULL
	,NULL
	,[Ticker]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST UK - PE'
	AND [Currency] = 'DKK'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
	HAVING NOT (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

	SELECT '999'
	,'07'
	,'80012'
	,'/'
	,CONVERT(Varchar, FORMAT(ABS(SUM([Realised])), 'G'))
	,'/'
	,'/'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,'Transfer PE2PE'
	,'/'
	,'0611'
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST UK - PE'
	AND [Currency] = 'DKK'
	--GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
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
	,'VOLUME CORRECTION BELOW'

	UNION ALL

	SELECT 'BKPF'
	,'0600'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'DKK'
	,'PE2PE'
	,'PE2PE ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
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
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';GB;' + [LZB] + ';' + [ExternalPortfolio] + ';UK'
	,IIF(LEFT([SAP_Account], 1) = 4, 'AP', 'VP')
	,'0600'
	,NULL
	,NULL
	,[Ticker]
	,[LZB]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST DE - PE'
	AND [Currency] = 'DKK'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO], [LZB]
	HAVING (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

	SELECT 'BKPF'
	,'0611'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'AB'
	,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))
	,'DKK'
	,'PE2PE'
	,'PE2PE ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
	,NULL
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
	,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';GB;;' + [ExternalPortfolio] + ';DE'
	,IIF(LEFT([SAP_Account], 1) = 4, 'AP', 'VP')
	,'0611'
	,NULL
	,NULL
	,NULL
	,[Ticker]
	,[InstrumentType]
	,[ExternalPortfolio]
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]
	WHERE [InternalLegalEntity] = 'RWEST UK - PE'
	AND [Currency] = 'DKK'
	GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, [ExternalPortfolio], [Ticker], [UNIT_TO]
	HAVING (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)	

)

GO

