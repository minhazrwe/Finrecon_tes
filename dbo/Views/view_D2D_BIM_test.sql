
/*
 =============================================
 Author:      	MK
 Created:     	2023-04
 Description:	Create BIMs for D2D Recon
 ---------------------------------------------
 updates:
 2023-12-20: added additional columns for PNL & Volume at the end of all queries to ease cross check for accountants (request AL Maas) / MKB/SU
 2023-12-20: rounded "volume_new to" 3 digits (request A-L Maas) / MKB/SU
 2023-12-20: improved overall readability ;)

 ==============================================
*/



CREATE view [dbo].[view_D2D_BIM_test] AS
(
	-- ################################# EUR BIM #################################
	--with params as (
	--							select cob = AsOfDate_EOM from dbo.AsOfDate
	--						 )

	/*resulting: column header & rows 2 & 3*/
		
		SELECT 
				KopfIdent
			, Buchungskreis
			, Belegdatum
			, Belegart
			, Buchungsdatum
			, [Currency]
			, Belegkopftext
			, Referenz
			, dummy1
			, dummy2
			, dummy3
			, dummy4
			, dummy5
			, dummy6
			, dummy7
			, dummy8
			, 'pnl' as dummy9		/* pnl */
			, 'volume_new' as dummy10		/* volume */
		FROM 
			dbo.table_PE2PE_BIM_header
	
	UNION ALL

		/*resulting: row 4*/
		SELECT 
			'BKPF'
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
			,NULL /* pnl */
			,NULL /* volume */

	UNION ALL

		SELECT 
			NULL
			,IIF(SUM(Realised) < 0, '40', '50')
			,SAP_Account
			,OrderNo
			,CONVERT(Varchar, FORMAT(ABS(SUM(Realised)), 'G'))
			,CONVERT(Varchar, FORMAT(ABS(round(SUM(Volume_new),3)), 'G'))
			,IIF([InstrumentType] LIKE 'REN-%' OR [InstrumentType] LIKE 'EM-%', 'ST', 'MWh')
			,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))
			,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';DE;' + [ExternalPortfolio]
			,IIF(LEFT([SAP_Account], 1) = '4', 'AP', 'VP')
			,'0600'
			,NULL
			,NULL
			,Ticker
			,InstrumentType
			,ExternalPortfolio
			,convert(varchar,SUM(Realised))							/*pnl*/
			,convert(varchar,ROUND(SUM(Volume_new),3)) /*volume_new*/
		FROM 
			[FinRecon].[dbo].[table_D2D_with_matching_deals]
		WHERE 
			[Currency] = 'EUR'
		GROUP BY 
				OrderNO
			, SAP_Account
			, InstrumentType
			, CashflowType
			, ExternalPortfolio
			, Ticker
			, UNIT_TO
		HAVING 
			NOT (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

		SELECT 
			'VOLUME CORRECTION BELOW'
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
			,'VOLUME CORRECTION BELOW' /*pnl*/
			,'VOLUME CORRECTION BELOW' /*volume_new*/

	UNION ALL

		SELECT 
				'BKPF'
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
			,NULL /* pnl */
			,NULL /* volume_new */

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
			,'artificial'							/*pnl*/
			,convert(varchar,ROUND(SUM(Volume_new),3)) /*volume_new*/
		FROM 
			[FinRecon].[dbo].[table_D2D_with_matching_deals]
		WHERE 
			[Currency] = 'EUR'
		GROUP BY 
			OrderNO
			, SAP_Account
			, InstrumentType
			, CashflowType
			, [ExternalPortfolio]
			, [Ticker]
			, [UNIT_TO]
		HAVING 
			(SUM(Realised) = 0 AND SUM(Volume_new) <> 0)

	-- ################################# USD BIM #################################

	UNION ALL

		SELECT 
			'USD BIM BELOW'
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
			,'USD BIM BELOW' /*pnl*/
			,'USD BIM BELOW' /*volume_new*/

	UNION ALL

		SELECT 
			'KopfIdent'
			,'Buchungskreis'
			,'Belegdatum'
			,'Belegart'
			,'Buchungsdatum'
			,'Currency'
			,'Belegkopftext'
			,'Referenz'
			,'dummy1'
			,'dummy2'
			,'dummy3'
			,'dummy4'
			,'dummy5'
			,'dummy6'
			,'dummy7'
			,'dummy8'
			,'dummy9'		/*pnl*/
			,'dummy10' /*volume_new*/

	UNION ALL

		SELECT 
			[KopfIdent]
			, [Buchungskreis]
			, [Belegdatum]
			, [Belegart]
			, [Buchungsdatum]
			, [Currency]
			, [Belegkopftext]
			, [Referenz]
			, [dummy1]
			, [dummy2]
			, [dummy3]
			, [dummy4]
			, [dummy5]
			, [dummy6]
			, [dummy7]
			, [dummy8]
			,'pnl' as dummy9					/*pnl*/
			,'volume_new' as dummy10	/*volume_new*/
		FROM 
			[dbo].[table_PE2PE_BIM_header]

	UNION ALL

		SELECT 
			 'BKPF'
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
			,NULL /*pnl*/
			,NULL /*volume_new*/
	
	UNION ALL

		SELECT 
			NULL
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
			,convert(varchar,SUM(Realised))						 /*pnl*/
			,convert(varchar,ROUND(SUM(Volume_new),3)) /*volume_new*/
		FROM 
			[FinRecon].[dbo].[table_D2D_with_matching_deals]
		WHERE 
			[Currency] = 'USD'
		GROUP BY 
			OrderNO
			, SAP_Account
			, InstrumentType
			, CashflowType
			, [ExternalPortfolio]
			, [Ticker]
			, [UNIT_TO]
		HAVING 
			NOT (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

		SELECT 
			 'VOLUME CORRECTION BELOW'
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
			,'VOLUME CORRECTION BELOW' /*pnl */
			,'VOLUME CORRECTION BELOW' /*volume_new*/
	UNION ALL

		SELECT 
			 'BKPF'
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
			,NULL		/*pnl */
			,NULL		/*volume_new*/

	UNION ALL

		SELECT 
			''
			,IIF(SUM([Volume_new]) < 0, '40', '50')
			,[SAP_Account]
			,[OrderNo]
			,'0.01'
			,CONVERT(Varchar, FORMAT(ABS(round(SUM([Volume_new]),3)), 'G'))
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
			,'artificial'	/*pnl */
			,convert(varchar,ROUND(SUM(Volume_new),3)) /*volume_new*/
		FROM 
			[FinRecon].[dbo].[table_D2D_with_matching_deals]
		WHERE 
			[Currency] = 'USD'
		GROUP BY 
			  OrderNO
			, SAP_Account
			, InstrumentType
			, CashflowType
			, [ExternalPortfolio]
			, [Ticker]
			, [UNIT_TO]
		HAVING 
			(SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	-- ################################# GBP BIM #################################

	UNION ALL

		SELECT 
			'GBP BIM BELOW'
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
			,'GBP BIM BELOW' /*pnl*/
			,'GBP BIM BELOW' /*volume_new*/

	UNION ALL

		SELECT 
			'KopfIdent'
			,'Buchungskreis'
			,'Belegdatum'
			,'Belegart'
			,'Buchungsdatum'
			,'Currency'
			,'Belegkopftext'
			,'Referenz'
			,'dummy1'
			,'dummy2'
			,'dummy3'
			,'dummy4'
			,'dummy5'
			,'dummy6'
			,'dummy7'
			,'dummy8'
			,'dummy9'		/*pnl*/
			,'dummy10'	/*volume_new*/
			
	UNION ALL

		SELECT 
			[KopfIdent]
			, [Buchungskreis]
			, [Belegdatum]
			, [Belegart]
			, [Buchungsdatum]
			, [Currency]
			, [Belegkopftext]
			, [Referenz]
			, [dummy1]
			, [dummy2]
			, [dummy3]
			, [dummy4]
			, [dummy5]
			, [dummy6]
			, [dummy7]
			, [dummy8]
			,'pnl' as dummy9						/*pnl*/
			,'volume_new' as dummy10		/*volume_new*/
		FROM 
			[dbo].[table_PE2PE_BIM_header]

	UNION ALL

		SELECT 
			'BKPF'
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
			,NULL		/*pnl */
			,NULL		/*volume_new*/
		
	UNION ALL

		SELECT 
			NULL
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
			,convert(varchar,SUM(Realised))						 /*pnl*/
			,convert(varchar,ROUND(SUM(Volume_new),3)) /*volume_new*/
		FROM 
			[FinRecon].[dbo].[table_D2D_with_matching_deals]
		WHERE 
			[Currency] = 'GBP'
		GROUP BY 
			OrderNO
			, SAP_Account
			, InstrumentType
			, CashflowType
			, [ExternalPortfolio]
			, [Ticker]
			, [UNIT_TO]
		HAVING 
			NOT (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

		SELECT 
			'VOLUME CORRECTION BELOW'
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
			,'VOLUME CORRECTION BELOW' /*pnl*/
			,'VOLUME CORRECTION BELOW' /*volume_new*/

	UNION ALL

		SELECT 
			'BKPF'
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
			,NULL		/*pnl */
			,NULL		/*volume_new*/
		
	UNION ALL

		SELECT 
			''
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
			,'artifical'							/*pnl*/
			,convert(varchar,ROUND(SUM(Volume_new),3)) /*volume_new*/
		FROM 
			[FinRecon].[dbo].[table_D2D_with_matching_deals]
		WHERE 
			[Currency] = 'GBP'
		GROUP BY 
			OrderNO
			, SAP_Account
			, InstrumentType
			, CashflowType
			, [ExternalPortfolio]
			, [Ticker]
			, [UNIT_TO]
		HAVING 
			(SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

		-- ################################# CZK BIM #################################

	UNION ALL

		SELECT 
			'RON BIM BELOW'
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
			,'RON BIM BELOW' /* pnl */
			,'RON BIM BELOW' /* volume_new*/

	UNION ALL

		SELECT 
			 'KopfIdent'
			,'Buchungskreis'
			,'Belegdatum'
			,'Belegart'
			,'Buchungsdatum'
			,'Currency'
			,'Belegkopftext'
			,'Referenz'
			,'dummy1'
			,'dummy2'
			,'dummy3'
			,'dummy4'
			,'dummy5'
			,'dummy6'
			,'dummy7'
			,'dummy8'
			,'dummy9'		/*pnl*/
			,'dummy10'	/*volume_new*/

	UNION ALL

		SELECT 
				[KopfIdent]
			, [Buchungskreis]
			, [Belegdatum]
			, [Belegart]
			, [Buchungsdatum]
			, [Currency]
			, [Belegkopftext]
			, [Referenz]
			, [dummy1]
			, [dummy2]
			, [dummy3]
			, [dummy4]
			, [dummy5]
			, [dummy6]
			, [dummy7]
			, [dummy8]
			,'pnl' as dummy9					/*pnl*/
			,'volume_new' as dummy10	/*volume_new*/
		FROM 
			[dbo].[table_PE2PE_BIM_header]

	UNION ALL

		SELECT 
			 'BKPF'
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
			,NULL		/*pnl */
			,NULL		/*volume_new*/

	UNION ALL

		SELECT 
			 NULL
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
			,convert(varchar,SUM(Realised))						 /*pnl*/
			,convert(varchar,ROUND(SUM(Volume_new),3)) /*volume_new*/
		FROM 
			[FinRecon].[dbo].[table_D2D_with_matching_deals]
		WHERE 
			[Currency] = 'RON'
		GROUP BY 
			  OrderNO
			, SAP_Account
			, InstrumentType
			, CashflowType
			, [ExternalPortfolio]
			, [Ticker]
			, [UNIT_TO]
		HAVING 
			NOT (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

		SELECT 
			'VOLUME CORRECTION BELOW'
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
			,'VOLUME CORRECTION BELOW' /*pnl*/
			,'VOLUME CORRECTION BELOW' /*volume_new*/

	UNION ALL

		SELECT 
			'BKPF'
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
			,NULL /*pnl*/
			,NULL /*volume_new*/
		
	UNION ALL

		SELECT 
			''
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
			,'artificial'									/*pnl*/
			,convert(varchar,ROUND(SUM(Volume_new),3)) /*volume_new*/
		FROM 
			[FinRecon].[dbo].[table_D2D_with_matching_deals]
		WHERE 
			[Currency] = 'RON'
		GROUP BY 
			OrderNO
			, SAP_Account
			, InstrumentType
			, CashflowType
			, [ExternalPortfolio]
			, [Ticker]
			, [UNIT_TO]
		HAVING 
			(SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

		-- ################################# HUF BIM #################################

	UNION ALL

		SELECT 
			 'PLN BIM BELOW'
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
			,'PLN BIM BELOW' /*pnl*/
			,'PLN BIM BELOW' /*volume_new*/

	UNION ALL

		SELECT 
			'KopfIdent'
			,'Buchungskreis'
			,'Belegdatum'
			,'Belegart'
			,'Buchungsdatum'
			,'Currency'
			,'Belegkopftext'
			,'Referenz'
			,'dummy1'
			,'dummy2'
			,'dummy3'
			,'dummy4'
			,'dummy5'
			,'dummy6'
			,'dummy7'
			,'dummy8'
			,'dummy9'  /*pnl*/
			,'dummy10' /*volume_new*/
	
	UNION ALL

		SELECT 
			[KopfIdent]
			, [Buchungskreis]
			, [Belegdatum]
			, [Belegart]
			, [Buchungsdatum]
			, [Currency]
			, [Belegkopftext]
			, [Referenz]
			, [dummy1]
			, [dummy2]
			, [dummy3]
			, [dummy4]
			, [dummy5]
			, [dummy6]
			, [dummy7]
			, [dummy8]
			,'pnl'				/*pnl*/
			,'volume_new' /*volume_new*/
		FROM 
			[dbo].[table_PE2PE_BIM_header]

	UNION ALL

		SELECT 
			'BKPF'
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
			,NULL /*pnl*/
			,NULL /*volume_new*/
	
	UNION ALL

		SELECT 
			NULL
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
			,convert(varchar,SUM(Realised))						 /*pnl*/
			,convert(varchar,ROUND(SUM(Volume_new),3)) /*volume_new*/
		FROM 
			[FinRecon].[dbo].[table_D2D_with_matching_deals]
		WHERE 
			[Currency] = 'PLN'
		GROUP BY 
			OrderNO
			, SAP_Account
			, InstrumentType
			, CashflowType
			, [ExternalPortfolio]
			, [Ticker]
			, [UNIT_TO]
		HAVING 
			NOT (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	UNION ALL

		SELECT 
			'VOLUME CORRECTION BELOW'
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
			,'VOLUME CORRECTION BELOW' /*pnl*/
			,'VOLUME CORRECTION BELOW' /*volume_new*/

	UNION ALL

		SELECT 
			'BKPF'
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
			,NULL /*pnl*/
			,NULL /*volume_new*/

	UNION ALL

		SELECT 
			''
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
			,'artificial'							/*pnl*/
			,convert(varchar,ROUND(SUM(Volume_new),3)) /*volume_new*/
		FROM 
			[FinRecon].[dbo].[table_D2D_with_matching_deals]
		WHERE 
			[Currency] = 'PLN'
		GROUP BY 
			OrderNO
			, SAP_Account
			, InstrumentType
			, CashflowType
			, [ExternalPortfolio]
			, [Ticker]
			, [UNIT_TO]
		HAVING 
			(SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

	)

GO

