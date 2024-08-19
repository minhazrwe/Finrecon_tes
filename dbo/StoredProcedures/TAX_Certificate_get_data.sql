


	-- ########################################################################################################################################################
	-- MBE 14.12.2021
	-- new proc to replace the Wiederverkäuferliste ( Excel - based )
	-- analysis of the data will be done by 2 views => 
	-- TAXCERT_Auswertung
	-- TAXCERT_Differenzen
	-- ########################################################################################################################################################


CREATE PROCEDURE [dbo].[TAX_Certificate_get_data]

AS
BEGIN TRY

	DECLARE @proc nvarchar(40)
	DECLARE @step Integer
	DECLARE @LogInfo Integer

	-- ########################################################################################################################################################
	-- select necessary data
	-- ########################################################################################################################################################

	select @step = 1
	select @proc = '[dbo].[Certificate_get_data]'


	select @step = @step + 1
	select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

	-- ########################################################################################################################################################
	-- ´fill table [TAXCERT_Organship]
	-- ########################################################################################################################################################
		
	delete from [dbo].[TAXCERT_Organship]

	insert into [dbo].[TAXCERT_Organship]
		 ([cv_id],[organship_id],[organship_valid_from],[organship_valid_to])
	select [cv_id],[organship_id],[organship_valid_from],[organship_valid_to] 
	from wa000009.taxcert.taxcert.organship

	-- ########################################################################################################################################################
	-- ´fill table [TAXCERT_CustomerVendor]
	-- ########################################################################################################################################################

	delete from [dbo].[TAXCERT_CustomerVendor]

	insert into [dbo].[TAXCERT_CustomerVendor] 
		  ([cv_id],[comp_id],[sap_id],[sap_group_id],[bu_id],[successor_cv_id],[succession_date],[name_3],[city],[country],[comment])
	select [cv_id],[comp_id],[sap_id],[sap_group_id],[bu_id],[successor_cv_id],[succession_date],[name_3],[city],[country],[comment] 
	from wa000009.taxcert.taxcert.customervendor

	-- ########################################################################################################################################################
	-- ´fill table [TAXCERT_CType]
	-- ########################################################################################################################################################

	delete from [dbo].[TAXCERT_CType]

	insert into [dbo].[TAXCERT_CType] 
		  ([ctype_id],[name],[tax],[commodity],[country]) 
	select [ctype_id],[name],[tax],[commodity],[country] 
	from wa000009.taxcert.taxcert.ctype

	-- ########################################################################################################################################################
	-- ´fill table [TAXCERT_CStatus]
	-- ########################################################################################################################################################

	delete from [dbo].[TAXCERT_CStatus]

	insert into [dbo].[TAXCERT_CStatus] ([name]) select [name] from wa000009.taxcert.taxcert.cstatus

	-- ########################################################################################################################################################
	-- ´fill table [TAXCERT_Companycode]
	-- ########################################################################################################################################################

	delete from [dbo].[TAXCERT_Companycode] 

	insert into [dbo].[TAXCERT_Companycode] 
		  ([cv_id],[company_code]) 
	select [cv_id],[company_code]  
	FROM wa000009.taxcert.taxcert.companycode

	-- ########################################################################################################################################################
	-- ´fill table [TAXCERT_Company]
	-- ########################################################################################################################################################

	delete from [dbo].[TAXCERT_Company]

	insert into [dbo].[TAXCERT_Company]	
			([comp_id],[name_1],[name_2],[le_id],[former_name],[former_name_change_date],[country],[comment],[csource],[le_shortname],[le_longname])
	select	 [comp_id],[name_1],[name_2],[le_id],[former_name],[former_name_change_date],[country],[comment],[csource],[le_shortname],[le_longname] 
	from wa000009.taxcert.taxcert.company

	-- ########################################################################################################################################################
	-- ´fill table [TAXCERT_Certificate]
	-- ########################################################################################################################################################

	delete from [dbo].[TAXCERT_Certificate]

	insert into [dbo].[TAXCERT_Certificate] 
		  ([cert_id],[comp_id],[ctype_id],[csubtype],[local_auth_office],[cnumber],[valid_from],[valid_to],[url],[fpath],[comment])
	select [cert_id],[comp_id],[ctype_id],[csubtype],[local_auth_office],[cnumber],[valid_from],[valid_to],[url],[fpath],[comment] 
	from wa000009.taxcert.taxcert.[certificate]

	-- ########################################################################################################################################################
	-- ´fill table [TAXCERT_Company]
	-- ########################################################################################################################################################

	delete from [dbo].[TAXCERT_Company]

	insert into [dbo].[TAXCERT_Company]
		  ([comp_id],[name_1],[name_2],[le_id],[former_name],[former_name_change_date],[country],[comment],[csource],[le_shortname],[le_longname])
	select [comp_id],[name_1],[name_2],[le_id],[former_name],[former_name_change_date],[country],[comment],[csource],[le_shortname],[le_longname]
	from  wa000009.taxcert.taxcert.company


	-- ########################################################################################################################################################
	-- ´fill table [TAXCERT_ActionLog]
	-- ########################################################################################################################################################

	delete from [dbo].[TAXCERT_ActionLog]

	insert into [dbo].[TAXCERT_ActionLog]
		  ([log_id],[comp_id],[cert_id],[ctype_id],[cstatus],[date],[comment],[user_id])
	select [log_id],[comp_id],[cert_id],[ctype_id],[cstatus],[date],[comment],[user_id]
	from  wa000009.taxcert.taxcert.actionlog



	-- ########################################################################################################################################################
	-- attached the definitions of the views to analyse the data
	-- ########################################################################################################################################################

--select distinct [TAXCERT_ERGEBNISSE].[LegalEntityName],
--		[TAXCERT_ERGEBNISSE].[LegalEntityID],
--		[TAXCERT_ERGEBNISSE].[LegalEntityCountry],
--		[TAXCERT_ERGEBNISSE].[LegalEntityShortName],
--		[TAXCERT_ERGEBNISSE].[LegalEntityLongName],
--		min([TAXCERT_ERGEBNISSE].[Wiederverkäufer_Strom]) as [Wiederverkäufer_Strom],
--		min([TAXCERT_ERGEBNISSE].[Wiederverkäufer_GAS]) as [Wiederverkäufer_GAS]
--from
--		(select	distinct 
--			[TAXCERT_Company_Details].LegalEntityName,
--			[TAXCERT_Company_Details].LegalEntityID,
--			[TAXCERT_Company_Details].LegalEntityCountry,
--			[TAXCERT_Company_Details].LegalEntityShortName,
--			[TAXCERT_Company_Details].LegalEntityLongName,
--			[FinRecon].[dbo].[TAXCERT_CompanyCode].company_code as CompanyCode,
--			[FinRecon].[dbo].[TAXCERT_CType].tax,
--		  case when [FinRecon].[dbo].[TAXCERT_CType].[name] like 'UST%POWER%' and 
--			([TAXCERT_Company_Details].[valid_from] < (select [FinRecon].[dbo].[AsOfDate].AsOfDate_EOM from [FinRecon].[dbo].[AsOfDate])
--			and [TAXCERT_Company_Details].[valid_to]  >= (select [FinRecon].[dbo].[AsOfDate].AsOfDate_EOM from [FinRecon].[dbo].[AsOfDate])) 
--				then 'Ja' else 'Nein' end as [Wiederverkäufer_Strom],
--		  case when [FinRecon].[dbo].[TAXCERT_CType].[name] like 'UST%GAS%' and 
--			([TAXCERT_Company_Details].[valid_from]  < (select [FinRecon].[dbo].[AsOfDate].AsOfDate_EOM from [FinRecon].[dbo].[AsOfDate])
--			and [TAXCERT_Company_Details].[valid_to] >= (select [FinRecon].[dbo].[AsOfDate].AsOfDate_EOM from [FinRecon].[dbo].[AsOfDate])) 
--				then 'Ja' else 'Nein' end as [Wiederverkäufer_GAS]
--		  from

--					(SELECT [FinRecon].[dbo].[TAXCERT_CustomerVendor].cv_id,
--							[FinRecon].[dbo].[TAXCERT_Company].[comp_id],
--							[FinRecon].[dbo].[TAXCERT_Company].[name_1]   as [LegalEntityName],
--							[FinRecon].[dbo].[TAXCERT_CustomerVendor].[bu_id] as [LegalEntityID],
--							[FinRecon].[dbo].[TAXCERT_CustomerVendor].[country]  as [LegalEntityCountry],
--							[FinRecon].[dbo].[TAXCERT_CustomerVendor].[city]  as [LegalEntityCity],
--							[FinRecon].[dbo].[TAXCERT_Company].[le_shortname]  as [LegalEntityShortName],
--							[FinRecon].[dbo].[TAXCERT_Company].[le_longname] as [LegalEntityLongName],
--							[FinRecon].[dbo].[TAXCERT_Certificate].[cert_id],
--							case when [FinRecon].[dbo].[TAXCERT_Certificate].[valid_from] is NULL then '1900-01-01' else [FinRecon].[dbo].[TAXCERT_Certificate].[valid_from] end as [valid_from] ,
--							case when [FinRecon].[dbo].[TAXCERT_Certificate].[valid_to] is NULL then '2222-01-01' else [FinRecon].[dbo].[TAXCERT_Certificate].[valid_to] end as [Valid_to],
--							[FinRecon].[dbo].[TAXCERT_Certificate].[ctype_id]
--					  FROM  [FinRecon].[dbo].[TAXCERT_Company] 
--							join [FinRecon].[dbo].[TAXCERT_CustomerVendor] on [FinRecon].[dbo].[TAXCERT_CustomerVendor].comp_id = [FinRecon].[dbo].[TAXCERT_Company].comp_id
--							join [FinRecon].[dbo].[TAXCERT_Certificate] on [FinRecon].[dbo].[TAXCERT_Certificate].comp_id = [FinRecon].[dbo].[TAXCERT_Company].[comp_id])

--							as [TAXCERT_Company_Details]

--			join [FinRecon].[dbo].[TAXCERT_CompanyCode] on [TAXCERT_Company_Details].[cv_id] = [FinRecon].[dbo].[TAXCERT_CompanyCode].[cv_id] 
--			join [FinRecon].[dbo].[TAXCERT_CType] on [TAXCERT_Company_Details].ctype_id = [FinRecon].[dbo].[TAXCERT_CType].ctype_id
--				where	[FinRecon].[dbo].[TAXCERT_CompanyCode].[company_code] like '%600%' and 
--						len ([FinRecon].[dbo].[TAXCERT_CompanyCode].[company_code]) = 3 
--						--and ([FinRecon].[dbo].[TAXCERT_CType].[name] like 'UST%POWER%' or [FinRecon].[dbo].[TAXCERT_CType].[name] like 'UST%GAS%') 
--						) 
--						as [TAXCERT_ERGEBNISSE]
--						join [Finrecon].[dbo].[map_counterparty] on ltrim(rtrim([Finrecon].[dbo].[map_counterparty].CtpyID_Endur)) = [TAXCERT_ERGEBNISSE].LegalEntityID
--						group by [TAXCERT_ERGEBNISSE].[LegalEntityName],[TAXCERT_ERGEBNISSE].[LegalEntityID],[TAXCERT_ERGEBNISSE].[LegalEntityCountry],[TAXCERT_ERGEBNISSE].[LegalEntityShortName],
--									[TAXCERT_ERGEBNISSE].[LegalEntityLongName] order by 1
									
									
									
--select * from (
--select ExtBunit, ExtLegalEntity, Country, 
--case when TAXCERT_Auswertung.[Wiederverkäufer_Strom] = 'Nein' and TAXCERT_Auswertung.[Wiederverkäufer_GAS] = 'Nein' then 'DE_19' else
--	case when TAXCERT_Auswertung.[Wiederverkäufer_Strom] = 'Ja' and TAXCERT_Auswertung.[Wiederverkäufer_GAS] = 'Nein' then 'DE_19_Gas' else
--		case when TAXCERT_Auswertung.[Wiederverkäufer_Strom] = 'Ja' and TAXCERT_Auswertung.[Wiederverkäufer_GAS] = 'Ja' then 'DE' else
--			case when TAXCERT_Auswertung.[Wiederverkäufer_Strom] = 'Nein' and TAXCERT_Auswertung.[Wiederverkäufer_GAS] = 'Ja' then 'DE_19_Strom' 
--			end end end end as Certificate_Country
--from map_counterparty left join TAXCERT_Auswertung on map_counterparty.CtpyID_Endur = TAXCERT_Auswertung.[LegalEntityID] 
--where Country like '%DE%' and (not [Wiederverkäufer_Strom] is null or not [Wiederverkäufer_GAS] is NULL)) as dd where Certificate_Country <> Country
--order by 1

END TRY

	BEGIN CATCH
		--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
	END CATCH

GO

