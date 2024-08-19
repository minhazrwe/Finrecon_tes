



CREATE VIEW [dbo].[View_ICS_SAP_FX_CHECK_EUR] AS
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
	,IIf(Amountinlocalcurrency = 0, 0.00001, Amountinlocalcurrency) AS Amountinlocalcurrency
	,Documentcurrency
	,Amountindoccurr
	,Round(amountindoccurr / amountinlocalcurrency, 4) AS SAP_Kurs
	,Table_FX_Rates_Timeseries_ECB.FX_Rate AS EZB_Kurs
	,Round(Amountindoccurr / FX_Rate - amountinlocalcurrency, 0) AS Differenz
	,Round(amountindoccurr / amountinlocalcurrency, 4)/FX_Rate AS relation
	,IIf([amountinlocalcurrency] = 0, 'Amount in local currency is 0', null) AS comment
FROM 
	(SELECT 
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
		,Amountinlocalcurrency
		,Documentcurrency
		,Amountindoccurr
		,EntryDate
	FROM 
 		dbo.SAP
	WHERE 
		LocalCurrency = 'EUR' 
		AND Documentcurrency <> 'EUR' 
		AND abs(Amountindoccurr)>2
	) as SAP_FX_EUR_zw1 INNER JOIN dbo.Table_FX_Rates_Timeseries_ECB ON 
	SAP_FX_EUR_zw1.PostingDate = Table_FX_Rates_Timeseries_ECB.COB
	AND SAP_FX_EUR_zw1.Documentcurrency = Table_FX_Rates_Timeseries_ECB.CCY
WHERE 
	abs(Round(Amountindoccurr/FX_Rate - IIf(amountinlocalcurrency = 0, 0.00001, amountinlocalcurrency), 0))> 100000 
	OR
	(Round(amountindoccurr/IIf(amountinlocalcurrency = 0, 0.00001, amountinlocalcurrency), 4)/FX_Rate) not between 0.8 and 1.2

GO

