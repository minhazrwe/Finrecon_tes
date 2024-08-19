


CREATE VIEW [dbo].[view_strolf_mtm_check_accounting_treatment_check] as
SELECT 
   ft_curr_month.cob
  ,ft_curr_month.DealID
	,ft_curr_month.InternalPortfolio
	,ft_curr_month.InstrumentType InstrumentType
	,ft_curr_month.CounterpartyGroup 
	,ft_prev_month.CounterpartyGroup AS CounterpartyGroupPrevious
	,ft_curr_month.ProjectionIndexGroup 
	,ft_curr_month.CounterpartyExternalBusinessUnit
	,Sum(ft_curr_month.mtm) AS mtm_aktuell
	,ft_curr_month.Accounting AS Accounting_aktuell
	,ft_prev_month.Accounting AS Accounting_Vormonat
FROM 
   dbo.table_strolf_mtm_check_01_FT_data as ft_curr_month
   left JOIN dbo.table_strolf_mtm_check_01_FT_data as ft_prev_month
	 ON 
		(ft_curr_month.TermEnd = ft_prev_month.TermEnd
		 AND ft_curr_month.DealID = ft_prev_month.DealID
		)
where 
	ft_curr_month.Accounting <> ft_prev_month.Accounting 
	and  ft_curr_month.COB = (select AsOfDate_eom from dbo.AsOfDate)
	and ft_curr_month.InternalPortfolio not in ('RES_BE') /* excluded 2022-05-03*/
GROUP BY 
   ft_curr_month.cob
	,ft_curr_month.DealID
	,ft_curr_month.InternalPortfolio
	,ft_curr_month.CounterpartyGroup
	,ft_prev_month.CounterpartyGroup
	,ft_curr_month.InstrumentType
	,ft_curr_month.ProjectionIndexGroup
	,ft_curr_month.CounterpartyExternalBusinessUnit
	,ft_curr_month.Accounting
	,ft_prev_month.Accounting

GO

