




/*Basisabfrage der Strolf-Daten für die Gonzales-DB.
Sollten die Daten für CS mit abgefragt werden, ist das statement entsprechend 
zu ergänzen, dann ist Heike G-S bezüglich der Filterbedingungen zu kontaktieren 
2022-07-28:
Abgefragte Tabelle angepaßt zu Testzwecken (veränderter pnl_type in den ursprungsdaten)
Rückfragen an VP+MKB

*/

CREATE view [dbo].[view_strolf_mtm_check_00_all_deals_strolf_TEST] as
		SELECT 
			cast([DEAL_NUM] as varchar)  dealnum_strolf ,
      [PNL] as mtm_strolf,
			[INS_TYPE_NAME] as instype_strolf
		FROM 
			--[FinRecon].[dbo].[Strolf_MOP_PLUS_REAL_CORR_EOM]
			[FinRecon].[dbo].[FIN_MOP_PLUS_REAL_CORR_mit_PNL_TYPE_ORIG_SUMMIERT]
		WHERE 
			pnl_type = 'UNREALIZED'
			AND PORTFOLIO_NAME not in ('RES_BE') /* exlcuded 2022-05-03*/

GO

