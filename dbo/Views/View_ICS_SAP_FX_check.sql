



CREATE view [dbo].[View_ICS_SAP_FX_check] as
SELECT 
	 CompanyCode
	,DocumentType
	,PostingDate								/*date the posting was made for*/
	,DocumentNumber	
	,DocumentDate	
	,DocumentHeaderText
	,Reference	
	,[TEXT] as posting_text
	,EntryDate 								/*date the posting mas physically made*/	
	,Assignment
	,LocalCurrency as local_CCY
	,Documentcurrency as doc_CCY
	,Amountinlocalcurrency as amount_local_CCY
	,Amountindoccurr as amount_Doc_CCY
	,SAP_Kurs as SAP_rate 
	,EZB_Kurs as ECB_rate
	,abs(round(Differenz,2)) as Abs_Difference
	,round(relation,2) as 'Relation_gap'
	,IIf(EntryDate < asOfDate_prevEOM, 'booking from old months',
	 IIf(Abs(1 - relation) <= 0.05, 'relation gap within tolerance', 
	 IIf(Abs(differenz) < 100000, 'difference within tolerance', 'to be checked'))) AS AutoPreCheck
	,IIf(EntryDate < asOfDate_prevEOM, 'checked in prev. months', NULL) AS Comment
FROM (
	SELECT * FROM dbo.View_ICS_SAP_FX_CHECK_EUR
	UNION ALL	
	SELECT * FROM dbo.View_ICS_SAP_FX_CHECK_nonEUR
	) AS subsql
	,dbo.AsOfDate
WHERE
	EntryDate >  DATEADD(MONTH,-3,asOfDate_EOM) /*only entries of the past three months*/

GO

