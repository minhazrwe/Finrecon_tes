





CREATE view [dbo].[AWV_Results] as 
select distinct dd.[CompanyCode] as [SAP-Buchungskreis], dd.[Account] as [SAP-Konto],dd.[OffsettingAccount] as [SAP-Debitor/Kreditor],dd.[DocumentNumber] as [SAP-Belegnummer], 
dd.[PostingKey] as [SAP-Buchungsschlüssel],dd.[DocumentType] as [SAP-Belegart],
dd.DocumentHeaderText as [SAP-Belegkopftext],dd.[PostingDate] as [SAP-Buchungsdatum],dd.[Reference] as [SAP-Referenz],
dd.[Text] as [SAP-Text]
,dd.[DocumentDate] as [SAP-Belegdatum],dd.Assignment as [SAP-Zuordnung],dd.[RefKey3] as [RefSchl2],
round(dd.[Amountinlocalcurrency],2) as [SAP-Betrag in Hauswährung],dd.[LocalCurrency] as [SAP-Hauswährung],round(dd.[Amountindoccurr],2) as [SAP-Betrag in Belegwährung],dd.[Documentcurrency] as [SAP-Belegwährung],dd.[Taxcode] as [SAP-Steuerkennzeichen],
dd.[Quantity] as [SAP-Menge],gg.[AWV-Bezeichnung],gg.[AWV-Bemerkung/Zahlungszweck],isnull(jj.[AWV-Bemerkung/Zahlungszweck],gg.[AWV-Bemerkung/Zahlungszweck]) as New_BZ,gg.[AWV-Info],
case when left(dd.[Account],1) in ('4','5') then 'Absatz' else 
	case when left(dd.[Account],1) in ('6','7') then 'Bezug' else '' end end as [Absatz/Bezug] ,
case when dd.[DocumentType] = 'ZM' and not dd.[Account] in ('4008112','6010112') then 'Ausgeschlossen: Belegart = ZM' else 
	case when finrecon.dbo.udf_SplitData(dd.[Text],2) = 'DE' then 'Ausgeschlossen: Land = DE' else 
		case when dd.[Reference] like 'PE2PE%' and dbo.udf_SplitData(dd.[Text],3) like '%centausgleich%' then 'Ausgeschlossen: InterPE Centausgleich' else 
			case when dd.[Text] like '%ECC Clearing%' then 'Ausgeschlossen: SAP Text beinhaltet ECC Clearing*' else
			case when (dd.[Text] Like 'accr%' or dd.[Text] like '%Bestand%' or dd.[Text] like '%Bewertung%' or dd.[Text] like '%Schätz%' or dd.[Text] like '%minus%' or dd.[Text] like '%Null%') and dd.Text not like '%LUMINUS%' then  'Ausgeschlossen: SAP Text beinhaltet accr*; *Bestand*; *Minus*; *Null*, *Schätz* oder *Bewertung*' else
				case when dd.[Reference] Like 'accr%' or dd.[Reference] Like '%Korr%' or dd.[Reference] Like '%Schätz%' then 'Ausgeschlossen: Referenz enthält accr*, *Schätz* oder *Korr*' else 
					NULL end end end end end end as [AusschlussKommentar],
case when dd.[Reference] like 'PE2PE%' or (len(dbo.udf_SplitData(dd.[Text],3)) = 3 and  gg.[AWV-Responsible] ='Diverse') then dbo.udf_SplitData(dd.[Text],3) else  
	case when finrecon.dbo.udf_SplitData(dd.[Text],5) = 'DE' and finrecon.dbo.udf_SplitData(dd.[Text],6) = 'DE' then gg.[AWV-LZB-Inland] else gg.[AWV-LZB] end end as [AWV-LZB],
gg.[AWV-LZB-Inland],gg.[AWV-Anlage],dd.[TradingPartner],
case when len(dbo.udf_SplitData(dd.[Text],2)) = 2 and ascii(left(dbo.udf_SplitData(dd.[Text],2),1)) > 64 and ascii(left(dbo.udf_SplitData(dd.[Text],2),1)) < 91 then dbo.udf_SplitData(dd.[Text],2) else '' end as [Counterparty Land],
case when len(dbo.udf_SplitData(dd.[Text],6)) = 2 then dbo.udf_SplitData(dd.[Text],6) else '' end as [Liefer Land],
gg.[AWV-Responsible], ROW_NUMBER() OVER (ORDER BY [CompanyCode] ASC) AS ROWID
from dbo.asofdate rr, 
	dbo.SAP as dd
	inner join dbo.map_ReconGroupAccount as gg on dd.[account] = gg.Account 
	left outer join  [dbo].[AWV_LZB] as jj on jj.[LZB] = case when dd.[Reference] like 'PE2PE%' then dbo.udf_SplitData(dd.[Text],3) else 
		case when finrecon.dbo.udf_SplitData(dd.[Text],5) = 'DE' and finrecon.dbo.udf_SplitData(dd.[Text],6) = 'DE' then gg.[AWV-LZB-Inland] else gg.[AWV-LZB] end end
where dd.[CompanyCode] = (600) and gg.[AWV-Responsible] is NOT NULL and gg.[AWV-Required] <> 'Nein'and gg.[AWV-Required] = 'Ja'

GO

