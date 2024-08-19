
create view dbo.TAXCERT_Differenzen as 

select * from (
select ExtBunit, ExtLegalEntity, Country, 
case when TAXCERT_Auswertung.[Wiederverkäufer_Strom] = 'Nein' and TAXCERT_Auswertung.[Wiederverkäufer_GAS] = 'Nein' then 'DE_19' else
	case when TAXCERT_Auswertung.[Wiederverkäufer_Strom] = 'Ja' and TAXCERT_Auswertung.[Wiederverkäufer_GAS] = 'Nein' then 'DE_19_Gas' else
		case when TAXCERT_Auswertung.[Wiederverkäufer_Strom] = 'Ja' and TAXCERT_Auswertung.[Wiederverkäufer_GAS] = 'Ja' then 'DE' else
			case when TAXCERT_Auswertung.[Wiederverkäufer_Strom] = 'Nein' and TAXCERT_Auswertung.[Wiederverkäufer_GAS] = 'Ja' then 'DE_19_Strom' 
			end end end end as Certificate_Country
from map_counterparty left join TAXCERT_Auswertung on map_counterparty.CtpyID_Endur = TAXCERT_Auswertung.[LegalEntityID] 
where Country like '%DE%' and (not [Wiederverkäufer_Strom] is null or not [Wiederverkäufer_GAS] is NULL)) as dd where Certificate_Country <> Country

GO

