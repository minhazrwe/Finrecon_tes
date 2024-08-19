


CREATE view [dbo].[TAXCERT_Auswertung] as
select distinct [TAXCERT_ERGEBNISSE].[LegalEntityName],
		[TAXCERT_ERGEBNISSE].[LegalEntityID],
		[TAXCERT_ERGEBNISSE].[LegalEntityCountry],
		[TAXCERT_ERGEBNISSE].[LegalEntityShortName],
		[TAXCERT_ERGEBNISSE].[LegalEntityLongName],
		min([TAXCERT_ERGEBNISSE].[Wiederverkäufer_Strom]) as [Wiederverkäufer_Strom],
		min([TAXCERT_ERGEBNISSE].[Wiederverkäufer_GAS]) as [Wiederverkäufer_GAS]
from
		(select	distinct 
			[TAXCERT_Company_Details].LegalEntityName,
			[TAXCERT_Company_Details].LegalEntityID,
			[TAXCERT_Company_Details].LegalEntityCountry,
			[TAXCERT_Company_Details].LegalEntityShortName,
			[TAXCERT_Company_Details].LegalEntityLongName,
			[FinRecon].[dbo].[TAXCERT_CompanyCode].company_code as CompanyCode,
			[FinRecon].[dbo].[TAXCERT_CType].tax,
		  case when [FinRecon].[dbo].[TAXCERT_CType].[name] like 'UST%POWER%' and 
			([TAXCERT_Company_Details].[valid_from] < (select [FinRecon].[dbo].[AsOfDate].AsOfDate_EOM from [FinRecon].[dbo].[AsOfDate])
			and [TAXCERT_Company_Details].[valid_to]  >= (select [FinRecon].[dbo].[AsOfDate].AsOfDate_EOM from [FinRecon].[dbo].[AsOfDate])) 
				then 'Ja' else 'Nein' end as [Wiederverkäufer_Strom],
		  case when [FinRecon].[dbo].[TAXCERT_CType].[name] like 'UST%GAS%' and 
			([TAXCERT_Company_Details].[valid_from]  < (select [FinRecon].[dbo].[AsOfDate].AsOfDate_EOM from [FinRecon].[dbo].[AsOfDate])
			and [TAXCERT_Company_Details].[valid_to] >= (select [FinRecon].[dbo].[AsOfDate].AsOfDate_EOM from [FinRecon].[dbo].[AsOfDate])) 
				then 'Ja' else 'Nein' end as [Wiederverkäufer_GAS]
		  from

					(SELECT 
						[FinRecon].[dbo].[TAXCERT_CustomerVendor].cv_id,
						[FinRecon].[dbo].[TAXCERT_Company].[comp_id],
						[FinRecon].[dbo].[TAXCERT_Company].[name_1]   as [LegalEntityName],
						[FinRecon].[dbo].[TAXCERT_CustomerVendor].[bu_id] as [LegalEntityID],
						[FinRecon].[dbo].[TAXCERT_CustomerVendor].[country]  as [LegalEntityCountry],
						[FinRecon].[dbo].[TAXCERT_CustomerVendor].[city]  as [LegalEntityCity],
						[FinRecon].[dbo].[TAXCERT_Company].[le_shortname]  as [LegalEntityShortName],
						[FinRecon].[dbo].[TAXCERT_Company].[le_longname] as [LegalEntityLongName],
						[FinRecon].[dbo].[TAXCERT_Certificate].[cert_id],
						GGG.[cstatus],
						case when [FinRecon].[dbo].[TAXCERT_Certificate].[valid_from] is NULL then '1900-01-01' else [FinRecon].[dbo].[TAXCERT_Certificate].[valid_from] end as [valid_from] ,
						case when [FinRecon].[dbo].[TAXCERT_Certificate].[valid_to] is NULL then '2222-01-01' else [FinRecon].[dbo].[TAXCERT_Certificate].[valid_to] end as [Valid_to],
						[FinRecon].[dbo].[TAXCERT_Certificate].[ctype_id]
					FROM  [FinRecon].[dbo].[TAXCERT_Company] 
						join [FinRecon].[dbo].[TAXCERT_CustomerVendor] on [FinRecon].[dbo].[TAXCERT_CustomerVendor].comp_id = [FinRecon].[dbo].[TAXCERT_Company].comp_id
						join [FinRecon].[dbo].[TAXCERT_Certificate] on [FinRecon].[dbo].[TAXCERT_Certificate].comp_id = [FinRecon].[dbo].[TAXCERT_Company].[comp_id]
						join  
								(select [FinRecon].[dbo].[TAXCERT_ActionLog].log_id, [FinRecon].[dbo].[TAXCERT_ActionLog].[cstatus], [FinRecon].[dbo].[TAXCERT_ActionLog].[cert_id] from [FinRecon].[dbo].[TAXCERT_ActionLog] 
											where [FinRecon].[dbo].[TAXCERT_ActionLog].log_id in 
											(select max([FinRecon].[dbo].[TAXCERT_ActionLog].[log_id]) as logID from [FinRecon].[dbo].[TAXCERT_ActionLog] group by [cert_id])  
											and ( (cstatus = 'existent' or cstatus = 'enquired') and [cert_id] in ( select distinct [cert_id] from [FinRecon].[dbo].[TAXCERT_ActionLog] where [cstatus] = 'existent' ))) GGG 
                                on [FinRecon].[dbo].[TAXCERT_Certificate].[cert_id]  = GGG.[cert_id]
					)

							as [TAXCERT_Company_Details]

			join [FinRecon].[dbo].[TAXCERT_CompanyCode] on [TAXCERT_Company_Details].[cv_id] = [FinRecon].[dbo].[TAXCERT_CompanyCode].[cv_id] 
			join [FinRecon].[dbo].[TAXCERT_CType] on [TAXCERT_Company_Details].ctype_id = [FinRecon].[dbo].[TAXCERT_CType].ctype_id
				where	[FinRecon].[dbo].[TAXCERT_CompanyCode].[company_code] like '%600%' and 
						len ([FinRecon].[dbo].[TAXCERT_CompanyCode].[company_code]) = 3 
						--and ([FinRecon].[dbo].[TAXCERT_CType].[name] like 'UST%POWER%' or [FinRecon].[dbo].[TAXCERT_CType].[name] like 'UST%GAS%') 
						) 
						as [TAXCERT_ERGEBNISSE]
						join [Finrecon].[dbo].[map_counterparty] on ltrim(rtrim([Finrecon].[dbo].[map_counterparty].CtpyID_Endur)) = [TAXCERT_ERGEBNISSE].LegalEntityID
						group by [TAXCERT_ERGEBNISSE].[LegalEntityName],[TAXCERT_ERGEBNISSE].[LegalEntityID],[TAXCERT_ERGEBNISSE].[LegalEntityCountry],[TAXCERT_ERGEBNISSE].[LegalEntityShortName],
									[TAXCERT_ERGEBNISSE].[LegalEntityLongName]

GO

