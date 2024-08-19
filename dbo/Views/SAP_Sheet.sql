
/* Author: Markus Beckmann; Strommengenabstimmung Annika*/
CREATE view [dbo].[SAP_Sheet] as select rr.CompanyCode, rr.Account, rr.Reference, rr.Assignment, rr.DocumentNumber, rr.DocumentType, substring(convert(varchar,rr.PostingDate),6,2) as [Postin gDate],
rr.PostingDate,rr.DocumentDate, rr.PostingKey, rr.Documentcurrency, rr.Amountindoccurr, rr.LocalCurrency, rr.Amountinlocalcurrency,
rr.Quantity, rr.BaseUnitofMeasure, rr.Taxcode, rr.Text, rr.TradingPartner, rr.DocumentHeaderText
FROM FinRecon.dbo.SAP as rr, finrecon.dbo.RACE525 dd where rr.TradingPartner = dd.Partner

GO

