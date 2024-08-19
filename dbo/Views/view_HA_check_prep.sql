

create view dbo.view_HA_check_prep as
SELECT 
	 Reference_ID
	,Trade_Date
	,Min(Term_Start) AS Term_Start
	,Max(Term_End) AS Term_End
	,Internal_Portfolio
	,Counterparty_Group
	,Sum(Volume) AS Volume
	,Curve_Name
	,Projection_Index_Group 
	,Instrument_Type
	,Int_Bunit 
	,Ext_Portfolio 
	,Sum(Discounted_PNL) AS Discounted_PNL
	,Strategy
	,Subsidiary
	,Accounting_Treatment
FROM 
	dbo.table_HA_Trades
WHERE 
	Strategy IN ('CAO Gas','Power Continental','Gas Desk','Global Options Desk','Power Desk')
GROUP BY 
	Reference_ID
	,Trade_Date
	,Internal_Portfolio
	,Counterparty_Group
	,Curve_Name
	,Projection_Index_Group
	,Instrument_Type
	,Int_Bunit
	,Ext_Portfolio
	,Strategy
	,Subsidiary
	,Accounting_Treatment

GO

