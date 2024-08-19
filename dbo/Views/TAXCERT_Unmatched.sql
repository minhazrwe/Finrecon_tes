

CREATE view [dbo].[TAXCERT_Unmatched] as 
/*This view shows all entries in the [map_counterparty] table with Country like '%DE%' 
for which no pendant can be found in the TaxCert database. 
The Query is restricted to counterparties for which we have deals in the [02_Realised_all_details] table*/

select * from (
select ExtBunit, ExtLegalEntity, map_counterparty.CtpyID_Endur,map_counterparty.Debitor,Country,

case when TAXCERT_Auswertung.[Wiederverkäufer_Strom] = 'Nein' and TAXCERT_Auswertung.[Wiederverkäufer_GAS] = 'Nein' then 'DE_19' else
	case when TAXCERT_Auswertung.[Wiederverkäufer_Strom] = 'Ja' and TAXCERT_Auswertung.[Wiederverkäufer_GAS] = 'Nein' then 'DE_19_Gas' else
		case when TAXCERT_Auswertung.[Wiederverkäufer_Strom] = 'Ja' and TAXCERT_Auswertung.[Wiederverkäufer_GAS] = 'Ja' then 'DE' else
			case when TAXCERT_Auswertung.[Wiederverkäufer_Strom] = 'Nein' and TAXCERT_Auswertung.[Wiederverkäufer_GAS] = 'Ja' then 'DE_19_Strom' 
			end end end end as Certificate_Country
from map_counterparty left join TAXCERT_Auswertung on map_counterparty.CtpyID_Endur = TAXCERT_Auswertung.[LegalEntityID] 
where Country like '%DE%' and TAXCERT_Auswertung.[LegalEntityID]  is NULL) as dd --where Certificate_Country <> Country
where
ExtBunit NOT in (
/*Select all ExtBunit entries for which there is no deal in the 02_Realised_all_details table*/
SELECT distinct [dbo].[map_counterparty].ExtBunit
FROM [dbo].[map_counterparty]
LEFT JOIN [dbo].[02_Realised_all_details] 
ON [dbo].[02_Realised_all_details].[ExternalBusinessUnit] = [dbo].[map_counterparty].ExtBunit
Where (
		(
			([dbo].[map_counterparty].ctpygroup) NOT IN (
				'InterPE'
				,'Intradesk'
				)
			)
		AND (([dbo].[02_Realised_all_details].[ExternalBusinessUnit]) IS NULL)
		)
)

GO

