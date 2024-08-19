



CREATE view [dbo].[Recon_Diff_archive] as SELECT 
InternalLegalEntity, Desk, Subdesk, ReconGroup, recon.[OrderNo], DeliveryMonth, DealID_Recon, Account,
ccy, Portfolio, CounterpartyGroup, InstrumentType, CashflowType, ProjIndexGroup, CurveName, ExternalLegal,

ltrim(rtrim(ExternalBusinessUnit)) as ExternalBusinessUnit , 

ExternalPortfolio, DocumentNumber, Reference,
case when recon.Partner Is Null then '/' else recon.Partner end as partner,

[Ref3] + case when [recongroup] In ('Physical Gas','Swaps') then ';GAS;' ELsE ';PWR;' end + case when c.[ctpygroup]='Internal'  THEN 'INT' ELsE 'EXT' end AS RefFeld3,

case when len(day(TradeDate)) = 1 then '0' +convert(varchar,day(TradeDate)) else convert(varchar,day(TradeDate)) end + '.' +
case when len(month(TradeDate)) = 1 then '0' +convert(varchar,month(TradeDate)) else convert(varchar,month(TradeDate)) end + '.' +
convert(varchar,year(TradeDate)) as TradeDate, 

case when len(day(EventDate)) = 1 then '0' +convert(varchar,day(EventDate)) else convert(varchar,day(EventDate)) end + '.' +
case when len(month(EventDate)) = 1 then '0' +convert(varchar,month(EventDate)) else convert(varchar,month(EventDate)) end + '.' +
convert(varchar,year(EventDate)) as EventDate, 

SAP_DocumentNumber, Volume_Endur, Volume_SAP, Volume_Adj, UOM_Endur, UOM_SAP, realised_ccy_Endur,

realised_ccy_SAP, realised_ccy_adj, realised_EUR_Endur, realised_EUR_SAP, realised_EUR_adj, Account_Endur, Account_SAP,

round(Diff_Volume,3) as [Diff_Volume],

round(Diff_Realised_CCY	,2)  as [Diff_CCY],

round(Diff_Realised_DeskCCY	,2)  as [Diff_DeskCCY],

round(Diff_Realised_EUR,2) as [Diff_EUR],

Round(Abs([diff_realised_EUR]),2) AS abs_diff_EUR,

case when eventdate > (select [asofdate_eom] from dbo.asofdate) then 'future payment date' else '' end as PaymentDateInfo,

'Schätz ' + Case when [InstrumentType] is null then '' else [InstrumentType] end 
    +  ';' + case when [VAT_CountryCode] is null then '' else [VAT_CountryCode] end + ';' 
	+ case when [ExternalBusinessUnit] is null then '' else [ExternalBusinessUnit] end + ';' 
	+ case when [DeliveryMonth] is null then '' else [DeliveryMonth] end  AS AccrualPostingText,

VAT_CountryCode as CountryCode,

Case when [VAT_Script] Is Null then '/' 
	ELSE case when [account] Like '4%' then [vat_script] 
	ELSE case when c.[ctpygroup]='Internal'  And [vat_countrycode]='DE' THEN 'V4' ELSE 'VN' end end end AS StKZ,

Case when [diff_realised_ccy]>0 THEN '50' ELSE CASE when [diff_realised_ccy]<0 THEN '40' ELSE CASE when [diff_volume]<0 THEN '40' ELSE '50' end end end AS [BS_GUV], 

case when [ReconGroup]='Strom physisch' And (Month((select [asofdate_eom] from dbo.asofdate)) In (3,6,9,12) Or d.[AccrualOnDebitor] In (0,Null) or d.[AccrualOnDebitor] is null) And 
		((d.[ExtBunit] Not In ('RWE GENERATION BU','RWE POWER BU')) Or d.[ExtBunit] Is Null) THEN Replace([account],'04','01') 
	ELSE [account] end AS [Konto_GUV], 

case when (Month((select [asofdate_eom] from dbo.asofdate)) In (3,6,9,12) Or d.[AccrualOnDebitor] In (0,Null,'') or d.[AccrualOnDebitor] is null) And ((d.[ExtBunit] Not In  ('RWE GENERATION BU','RWE POWER BU','ECC GAS LUX WD BU','ECC LUX BU','ECC GAS LUX BU','ECC CLEARING BU','ICE CLEAR BU','ICE CLEAR EUROPE BU','NE CLEARING ICEENDEX SPOT DE BU')) Or d.[ExtBunit] Is Null) 
	THEN (Case when [diff_realised_ccy]>0 THEN '40' ELSE CASE when [diff_realised_ccy]<0 THEN '50' ELSE CASE when [diff_volume]<0 THEN '50' ELSE '40' end end end)
	ELSE (Case when [diff_realised_ccy]>0 THEN '04' ELSE CASE when [diff_realised_ccy]<0 THEN '14' ELSE CASE when [diff_volume]<0 THEN '04' ELSE '14' end end end)
	end  AS [BS_Bilanz], 

case when (Month((select [asofdate_eom] from dbo.asofdate)) In (3,6,9,12) Or d.[AccrualOnDebitor] In (0,Null,'') or d.[AccrualOnDebitor] is null) And ((d.[ExtBunit] Not In  ('RWE GENERATION BU','RWE POWER BU','ECC GAS LUX WD BU','ECC LUX BU','ECC GAS LUX BU','ECC CLEARING BU','ICE CLEAR BU','ICE CLEAR EUROPE BU','NE CLEARING ICEENDEX SPOT DE BU')) Or d.[ExtBunit] Is Null) 
	THEN (Case when [diff_realised_ccy]>0 THEN '1319901' ELSE CASE when [diff_realised_ccy]<0 THEN '3500008' ELSE CASE when [diff_volume]<0 THEN '3500008' ELSE '1319901' end end end)
	ELSE d.Debitor end AS [Konto_Bilanz], 
Identifier	
from 
(([dbo].[base_Recon_archive] recon
LEFT JOIN (SELECT OrderNo, Max(Ref3) AS Ref3 FROM dbo.map_order GROUP BY OrderNo) as r ON recon.OrderNo = r.orderno)
LEFT JOin (SELECT partner, max(ctpygroup) as ctpygroup from dbo.map_counterparty group by partner) as c on recon.partner = c.partner)
LEFT JOIN dbo.map_counterparty as d ON recon.externalbusinessunit = d.extbunit
WHERE 

ReconGroup not in ('prüfen', 'MTM', 'not relevant') AND

((([Diff_Volume]<-1 Or [Diff_Volume] >1 OR [Diff_realised_ccy] <-1 or [Diff_realised_ccy] >1 or [Diff_realised_eur] <-1 or [Diff_realised_eur] >1)
AND InternalLegalEntity not in ('n/a') AND InternalLegalEntity not in ('RWEST UK')) 

OR 

(([Diff_Volume]<-1 Or [Diff_Volume] >1 OR [Diff_realised_ccy] <-1 or [Diff_realised_ccy] >1 )
AND InternalLegalEntity not in ('n/a') AND InternalLegalEntity  in ('RWEST UK')) 

OR 

(([Diff_Volume]<-1 Or [Diff_Volume] >1 OR [Diff_realised_Deskccy] <-1 or [Diff_realised_Deskccy] >1 )
AND InternalLegalEntity not in ('n/a') AND InternalLegalEntity  in ('RWEST UK')) 

)

GO

