CREATE VIEW [dbo].[View_Export_Query_RevRec_VER_TRADING_Recon_MTM_Overview_To_CSV_Temp] as  SELECT [Desk],[Subdesk],[InternalPortfolio],[AccountingTreatment], case when [nonVA] = 'GM - Gas Position' then ''  else case when [internalportfolio] = 'SO DE WC CARBON' then 'x' else [nonVA]end end as 'nonVA',
		[unwind],[mtm_finance_total_EUR],[prevYE_mtm_finance_total_EUR],[mtm_finance_OCI_EUR],[mtm_finance_PNL_EUR],[mtm_finance_OU_EUR],[mtm_finance_NOR_EUR],[ytd_mtm_finance_total_EUR],[ytd_mtm_finance_OCI_EUR],[ytd_mtm_finance_PNL_EUR]
		,[ytd_mtm_finance_OU_EUR] ,[ytd_mtm_finance_NOR_EUR] 
		FROM [FinRecon].[dbo].[RiskRecon_MtM_Overview_tbl]  where desk in ('VER TRADING')

GO

