

















CREATE view [dbo].[Recon_Diff_archive_new] as SELECT 
InternalLegalEntity, 
Desk, 
Subdesk, 
ReconGroup, 
[dbo].Recon_archive.[OrderNo], 
DeliveryMonth, 
DealID_Recon, 
Account,
ccy, 
Portfolio, 
CounterpartyGroup, 
InstrumentType, 
CashflowType, 
ProjIndexGroup, 
CurveName, 
ExternalLegal,

ltrim(rtrim(ExternalBusinessUnit)) as ExternalBusinessUnit , 

ExternalPortfolio, 
DocumentNumber, 
Reference,

case when dbo.Recon_archive.Partner Is Null then '/' else dbo.Recon_archive.Partner end as partner,

[Ref3] + case when [recongroup] In ('Physical Gas','Swaps') then ';GAS;' ELsE ';PWR;' end + case when c.[ctpygroup]='Internal'  THEN 'INT' ELsE 'EXT' end AS RefFeld3,

case when len(day(TradeDate)) = 1 then '0' +convert(varchar,day(TradeDate)) else convert(varchar,day(TradeDate)) end + '.' +
case when len(month(TradeDate)) = 1 then '0' +convert(varchar,month(TradeDate)) else convert(varchar,month(TradeDate)) end + '.' +
convert(varchar,year(TradeDate)) as TradeDate, 

case when len(day(EventDate)) = 1 then '0' +convert(varchar,day(EventDate)) else convert(varchar,day(EventDate)) end + '.' +
case when len(month(EventDate)) = 1 then '0' +convert(varchar,month(EventDate)) else convert(varchar,month(EventDate)) end + '.' +
convert(varchar,year(EventDate)) as EventDate, 

SAP_DocumentNumber, 
Volume_Endur, 
Volume_SAP, 
Volume_Adj, 
UOM_Endur, 
UOM_SAP, 
realised_ccy_Endur,
realised_ccy_SAP, 
realised_ccy_adj, 
realised_EUR_Endur, 
realised_EUR_SAP, 
realised_EUR_adj, 
Account_Endur, 
Account_SAP,

round(Diff_Volume,3) as [Diff_Volume],

round(Diff_Realised_CCY	,2)  as [Diff_CCY],

round(Diff_Realised_DeskCCY	,2)  as [Diff_DeskCCY],

round(Diff_Realised_EUR,2) as [Diff_EUR],

Round(Abs([diff_realised_EUR]),2) AS abs_diff_EUR,

case when eventdate > (select [asofdate_eom] from dbo.asofdate) then 'future payment date' else '' end as PaymentDateInfo,

case when recongroup = 'Exchanges' then [DealID_Recon] else 'Schätz ' + Case when [InstrumentType] is null then '' else replace([InstrumentType],'-STD','') end end
    +  ';' + case when [VAT_CountryCode] is null then '' else [VAT_CountryCode] end + ';' 
	+ case when [ExternalBusinessUnit] is null then '' else [ExternalBusinessUnit] end + ';' 
	+ case when [DeliveryMonth] is null then '' else [DeliveryMonth] end  AS AccrualPostingText,

VAT_CountryCode as CountryCode,


case when Recon_archive.recongroup = 'Exchanges' then 
	case when Recon_archive.account like '4%' then 
		case when Recon_archive.InternalLegalEntity = 'RWEST DE' then 'N5' else case when Recon_archive.InternalLegalEntity = 'RWEST UK'  then '28' else 'AN' end end
	else case when Recon_archive.InternalLegalEntity = 'RWEST DE' then 'VM' else case when Recon_archive.InternalLegalEntity = 'RWEST UK'  then '88' else 'VN' end end end else 


case when InternalLegalEntity = 'RWEST CZ' then case when Diff_Realised_CCY <0 then 'VN' else 'AN' end else
Case when ([VAT_Script] Is Null and [vat_sap] is null) then '/' 
	ELSE case when [account] Like '4%' then case when ([vat_sap] is null or [realised_EUR_SAP]= 0) then [vat_script] else [vat_sap] end
	ELSE case when c.[ctpygroup]='Internal'  And [vat_countrycode]='DE' THEN 'V4' else 'VN' end end end end end AS StKZ,

Case when [diff_realised_ccy]>0 THEN '50' ELSE CASE when [diff_realised_ccy]<0 THEN '40' ELSE CASE when [diff_volume]<0 THEN '40' ELSE '50' end end end AS [BS_GUV], 

case when [ReconGroup]='Physical Power' 
				and (d.[ExtLegalEntity] not In ('RWEST CZ PE','RWEST DE - PE','RWEST UK - PE','RWEST ASIA PACIFIC PE','RWEST PARTICIPATIONS PE','RWE TS DE PE','RWE TS UK PE','RWE POWER','RWE GENERATION LE','INNOGY SPAIN') or d.[ExtLegalEntity] is null)
	  			and Month((select [asofdate_eom] from dbo.asofdate)) In (3,6,9,12)
	THEN Replace([account],'04','01') 	ELSE [account] end AS [Konto_GUV], 


case when ([internallegalentity] not in ('RWEST CZ') and (d.[AccrualOnDebitor] = 1) and ((d.ctpygroup = 'External' or (d.[ExtLegalEntity] In ('RWEST CZ PE','RWEST DE - PE','RWEST UK - PE','RWEST ASIA PACIFIC PE','RWEST PARTICIPATIONS PE','RWE TS DE PE','RWE TS UK PE','RWE POWER','RWE GENERATION LE','INNOGY SPAIN'))) or (Month((select [asofdate_eom] from dbo.asofdate)) not In (3,6,9,12))))
	THEN (Case when [diff_realised_ccy]>0 THEN '04' ELSE CASE when [diff_realised_ccy]<0 THEN '14' ELSE CASE when [diff_volume]<0 THEN '04' ELSE '14' end end end)
	ELSE (Case when [diff_realised_ccy]>0 THEN '40' ELSE CASE when [diff_realised_ccy]<0 THEN '50' ELSE CASE when [diff_volume]<0 THEN '50' ELSE '40' end end end)
    end  AS [BS_Bilanz], 


case when InternalLegalEntity = 'RWEST CZ' then 
	case when d.ctpygroup = 'Internal' 
	  then Case when [diff_realised_ccy]>0 THEN '1320221' ELSE 
		   CASE when [diff_realised_ccy]<0 THEN '3540207' ELSE 
		   CASE when [diff_volume]<0 THEN '3540207' ELSE '1320221' end end end
	  else Case when [diff_realised_ccy]>0 THEN '1319907' ELSE 
		   CASE when [diff_realised_ccy]<0 THEN '3500012' ELSE 
		   CASE when [diff_volume]<0 THEN '3500012' ELSE '1319907' end end end end
else case when ((d.[AccrualOnDebitor] = 1) and ((d.ctpygroup = 'External' or (d.[ExtLegalEntity] In ('RWEST CZ PE','RWEST DE - PE','RWEST UK - PE','RWEST ASIA PACIFIC PE','RWEST PARTICIPATIONS PE','RWE TS DE PE','RWE TS UK PE','RWE POWER','RWE GENERATION LE','INNOGY SPAIN'))) or (Month((select [asofdate_eom] from dbo.asofdate)) not In (3,6,9,12))))
	THEN d.Debitor 
	ELSE (Case when [diff_realised_ccy]>0 THEN '1319901' ELSE CASE when [diff_realised_ccy]<0 THEN '3500008' ELSE CASE when [diff_volume]<0 THEN '3500008' ELSE '1319901' end end end)
	end end AS [Konto_Bilanz], 


case when d.UstID is null then '/' else d.ustid end as UStID,
Recon_archive.VAT_CountryCode,
Identifier	

from 
((dbo.Recon_archive 
LEFT JOIN (SELECT OrderNo, Max(Ref3) AS Ref3 FROM dbo.map_order GROUP BY OrderNo) as r ON dbo.Recon_archive.orderno = r.orderno)
LEFT JOin (SELECT partner, max(ctpygroup) as ctpygroup from dbo.map_counterparty group by partner) as c on dbo.Recon_archive.partner = c.partner)
LEFT JOIN dbo.map_counterparty as d ON dbo.Recon_archive.externalbusinessunit = d.extbunit
WHERE 

ReconGroup not in ('prüfen', 'MTM', 'not relevant') AND ReconGroup not like 'non-IAS%' AND

(((abs([Diff_Volume])>1 OR abs([Diff_realised_ccy])>1  or abs([Diff_realised_eur])>1)
AND InternalLegalEntity not in ('n/a') AND InternalLegalEntity not in ('RWEST UK')) 

OR 

((abs([Diff_Volume]) >1 OR abs([Diff_realised_ccy])>1 or abs([Diff_realised_Deskccy])>1  or abs([Diff_realised_eur])>1 )
AND InternalLegalEntity  in ('RWEST UK')) 


)

GO

