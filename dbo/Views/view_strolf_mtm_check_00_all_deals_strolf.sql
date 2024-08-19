



/*Basisabfrage der Strolf-Daten für die Gonzales-DB.
Sollten die Daten für CS mit abgefragt werden, ist das statement entsprechend 
zu ergänzen, dann ist Heike G-S bezüglich der Filterbedingungen zu kontaktieren 
*/

/*ursprungsabfrage*/
--create view [dbo].view_strolf_mtm_check_00_all_deals_v12_mtm as
--SELECT 
--	distinct [Reference_ID] as deal_num_FT,
--	[Discounted_PNL] as MTM_FT
--FROM 
--	[FinRecon].[dbo].[table_strolf_mtm_check_00_v12_mtm_all]
--WHERE
--	Strategy like 'CAO POWER'
--/*--hier ergänzen um CS--> heike fragen */


/*neuer ansatz*/
CREATE view [dbo].[view_strolf_mtm_check_00_all_deals_strolf] as
		SELECT 
			[DEAL_NUM] dealnum_strolf,
      [PNL] as mtm_strolf,
			[INS_TYPE_NAME] as instype_strolf
		FROM 
			[FinRecon].[dbo].[Strolf_MOP_PLUS_REAL_CORR_EOM]
		WHERE 
			pnl_type = 'UNREALIZED'
			AND PORTFOLIO_NAME not in ('RES_BE') /* exlcuded 2022-05-03*/

/*--hier ergänzen um CS--> Heike fragen */
		--UNION ALL 
		--SELECT distinct [DEAL_NUM] FROM [FinRecon].[dbo].[Strolf_MOP_PLUS_REAL_CORR_EOM]

GO

