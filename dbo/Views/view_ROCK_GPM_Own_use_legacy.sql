

CREATE   view [dbo].[view_ROCK_GPM_Own_use_legacy] as 
SELECT 
	cast(COB as datetime) as cob
	,Subsidiary
	,Strategy
	,Reference_ID
	,Trade_Date
	,Term_Start
	,Term_End
	,Internal_Portfolio
	,Counterparty_Ext_Bunit
	,Counterparty_Group
	,Volume
	,Header_Buy_Sell
	,Curve_Name
	,Projection_Index_Group
	,Instrument_Type
	,UOM
	,Int_Legal_Entity
	,Int_Bunit
	,Ext_Legal_Entity
	,Ext_Portfolio
	,Discounted_PNL
	,Undiscounted_PNL
	,Accounting_Treatment
	,Reference
	,Product
	,FileID
	,Lastupdate
FROM 
	dbo.table_ROCK_GPM_FT_Data
WHERE 
	Counterparty_Group NOT LIKE 'Intradesk'
	AND Accounting_Treatment LIKE 'Own use'

GO

