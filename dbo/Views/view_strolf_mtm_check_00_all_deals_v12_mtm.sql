
---drop view [dbo].view_strolf_mtm_check_00_all_deals_strolf 
---drop view [dbo].view_strolf_mtm_check_00_all_deals_v12_mtm

---view für die strolf daten anlegen


--create view [dbo].view_strolf_mtm_check_00_all_deals_strolf as
--		SELECT 
--			[DEAL_NUM] dealnum_strolf,
--      [PNL] as mtm_strolf,
--			[INS_TYPE_NAME] as instype_strolf
--		FROM [FinRecon].[dbo].[Strolf_MOP_PLUS_REAL_CORR_EOM]
--		WHERE pnl_type = 'UNREALIZED'
----/* ab hier teil für CS */
----	UNION ALL 
----		SELECT 
----			[DEAL_NUM],
----      [PNL],
----			[INS_TYPE_NAME] 
----		FROM [FinRecon].[dbo].[dbo].[Strolf_IS_EUR_EOM]
----		WHERE 
----/* hier heike nach filterbedingungen fragen!!!*/

----view für die fastracker daten anlegen
create view [dbo].[view_strolf_mtm_check_00_all_deals_v12_mtm] as
SELECT 
	distinct [Reference_ID] as dealnum_FT,
	[Discounted_PNL] as MTM_FT,
	[INSTRUMENT_TYPE] as instype_ft
FROM 
	[FinRecon].[dbo].[table_strolf_mtm_check_00_v12_mtm_all]
WHERE
--	Strategy like 'CAO POWER'
	Strategy like 'CAO%'
	and Projection_Index_Group in ('Electricity')
	---and Projection_Index_Group not in ('Natural Gas','FX','Emissions','Coal', 'none','Biofuel','Swap')


-----jetzt den abgleich machen
--SELECT 
--	dealnum_FT, 
--	dealnum_strolf,
--	mtm_ft,
--	mtm_strolf,
--	instype_ft,
--	instype_strolf
--FROM 
--	[dbo].[view_strolf_mtm_check_00_all_deals_v12_mtm]
--	full outer join 
--	[dbo].[view_strolf_mtm_check_00_all_deals_strolf]
--	ON dealnum_FT=dealnum_strolf
--WHERE
--	(
--		dealnum_FT is null
--		or
--		dealnum_strolf is null
--	)

GO

