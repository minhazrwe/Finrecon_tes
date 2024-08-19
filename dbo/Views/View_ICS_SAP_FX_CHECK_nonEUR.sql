



CREATE view [dbo].[View_ICS_SAP_FX_CHECK_nonEUR] as
SELECT 
	CompanyCode
	,DocumentType
	,EntryDate
	,PostingDate
	,DocumentDate
	,DocumentNumber
	,DocumentHeaderText
	,Reference
	,Assignment
	,TEXT
	,LocalCurrency
	,Amountinlocalcurrency
	,Documentcurrency
	,Amountindoccurr
	,Round(amountindoccurr / IIf(amountinlocalcurrency = 0, 0.000001, amountinlocalcurrency), 4) AS SAP_FX_Rate
	,Round(Table_FX_Rates_Timeseries_ECB.FX_Rate / Table_FX_Rates_Timeseries_ECB_1.FX_Rate, 4) AS EZB_FX_Rate
	,Round(Amountindoccurr / Table_FX_Rates_Timeseries_ECB.FX_Rate - amountinlocalcurrency / Table_FX_Rates_Timeseries_ECB_1.FX_Rate, 0) AS Differenz_EUR
	,Round(amountindoccurr / IIf(amountinlocalcurrency = 0, 0.000001, amountinlocalcurrency), 4) / (Table_FX_Rates_Timeseries_ECB.FX_Rate / Table_FX_Rates_Timeseries_ECB_1.FX_Rate) AS relation
	,IIf(amountinlocalcurrency = 0, 'Amount in local currency is 0',null) AS comment
FROM 
	(
	SELECT 
	 CompanyCode
	,DocumentType
	,PostingDate
	,DocumentDate
	,DocumentNumber
	,DocumentHeaderText
	,Reference
	,Assignment
	,TEXT
	,LocalCurrency
	,amountinlocalcurrency
	,Documentcurrency
	,Amountindoccurr
	,EntryDate
FROM 
	dbo.SAP
WHERE 
	ABS (Amountindoccurr) > 2
	AND
	LocalCurrency <> Documentcurrency 
	and 
	LocalCurrency not in ('EUR')
	) as SAP_FX_nonEUR_zw1 INNER JOIN dbo.Table_FX_Rates_Timeseries_ECB
	ON (Documentcurrency = Table_FX_Rates_Timeseries_ECB.CCY) AND (PostingDate = Table_FX_Rates_Timeseries_ECB.COB)
	INNER JOIN Table_FX_Rates_Timeseries_ECB AS Table_FX_Rates_Timeseries_ECB_1
	ON (PostingDate = Table_FX_Rates_Timeseries_ECB_1.COB) AND (LocalCurrency = Table_FX_Rates_Timeseries_ECB_1.CCY)
WHERE 
	ABS(Round((Amountindoccurr / (Table_FX_Rates_Timeseries_ECB.FX_Rate / Table_FX_Rates_Timeseries_ECB_1.FX_Rate) - amountinlocalcurrency) / Table_FX_Rates_Timeseries_ECB_1.FX_Rate, 0)) > 100000 
	OR
	(Round(amountindoccurr/IIf(amountinlocalcurrency = 0, 0.000001, amountinlocalcurrency), 4)/(Table_FX_Rates_Timeseries_ECB.FX_Rate/Table_FX_Rates_Timeseries_ECB_1.FX_Rate)) not between 0.8 and 1.2

GO

