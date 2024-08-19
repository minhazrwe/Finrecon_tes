

CREATE PROCEDURE [dbo].[fill_AWV_Log_Document_Numbers]

@nameofquery nvarchar(255)

AS
BEGIN TRY

	DECLARE @LogInfo Integer
	DECLARE @proc nvarchar(40)
	DECLARE @step Integer
	DECLARE @SQL nvarchar(max)

	select @step = 1
	select @proc = Object_Name(@@PROCID)

	select @step = @step + 1
	select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - START', GETDATE () END

	select @step = @step + 1
	if @nameofquery = 'Diverse' 
		Begin
			insert into [AWV_Log_Document_Numbers]([SAPDocumentNumber],[AsOfDate],[SAPCompanyCode],[AWVAnlage],[AWV-Responsible], [User],[ExportDate])
				select distinct rtrim(ltrim([DocumentNumber])), convert(date,pp.asofdate_EOM), dd.CompanyCode ,
				case when ((dd.[Account] = '4008038' or dd.[Account] = '6018038') and (dd.[Text] like '%;290;%' or dd.[Text]  like '%;286;%')) then 'Z4' else [AWV-Anlage] end as [AWV-Anlage], 'Diverse' ,user_name(), getdate()
					from asofdate as pp, SAP as dd
						inner join dbo.map_ReconGroupAccount as gg on dd.[account] = gg.Account
						left  join  AWV_Log_Document_Numbers as kk on  ltrim(rtrim(kk.SAPDocumentNumber)) = rtrim(ltrim(dd.DocumentNumber)) --and gg.[AWV-Anlage] = kk.AWVAnlage
						where kk.SAPDocumentNumber is NULL 
							and dd.CompanyCode in (600,616) 
								and  (gg.[AWV-Responsible] = 'Diverse' or ((dd.[Account] = '4008038' or dd.[Account] = '6018038') and (dd.[Text] like '%;290;%' or dd.[Text] like '%;286;%')))
		END

	if @nameofquery  = 'Z10_Responsible'
		Begin
			--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' Fill Log Document Numbers = started => Z10_Responsible', GETDATE () END
			insert into [AWV_Log_Document_Numbers]([SAPDocumentNumber],[AsOfDate],[SAPCompanyCode],[AWVAnlage],[AWV-Responsible], [User],[ExportDate])
				select distinct [DocumentNumber], convert(date,pp.asofdate_EOM), dd.CompanyCode ,gg.[AWV-Anlage], 'Z10-Responsible' ,user_name(), getdate()
					from asofdate as pp, SAP as dd
						inner join dbo.map_ReconGroupAccount as gg on dd.[account] = gg.Account
						left  join  AWV_Log_Document_Numbers as kk on  kk.SAPDocumentNumber = dd.DocumentNumber and gg.[AWV-Anlage] = kk.AWVAnlage
						where kk.SAPDocumentNumber is NULL 
							and dd.CompanyCode in (600,616) 
							and  not ((dd.[Account] = '4008038' or dd.[Account] = '6018038') and (dd.[Text] like '%;290;%' or dd.[Text]  like '%;286;%')) 
								and  gg.[AWV-Responsible] = 'Z10_Responsible' 
		END
	
	if  @nameofquery != 'Diverse' and @nameofquery  != 'Z10_Responsible'
		BEGIN
			--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' Fill Log Document Numbers = started => Rest', GETDATE () END
			insert into [AWV_Log_Document_Numbers]([SAPDocumentNumber],[AsOfDate],[SAPCompanyCode],[AWVAnlage],[AWV-Responsible], [User],[ExportDate])
			select distinct [DocumentNumber], convert(date,pp.asofdate_EOM), dd.CompanyCode ,gg.[AWV-Anlage], gg.[AWV-Responsible] ,user_name(), getdate()
				from asofdate as pp, SAP as dd
					inner join dbo.map_ReconGroupAccount as gg on dd.[account] = gg.Account
					left  join  AWV_Log_Document_Numbers as kk on  kk.SAPDocumentNumber = dd.DocumentNumber and gg.[AWV-Anlage] = kk.AWVAnlage
					where kk.SAPDocumentNumber is NULL 
						and dd.CompanyCode in (600,616) 
							and  gg.[AWV-Responsible] = @nameofquery
		END

	select @step = @step + 1
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - FINISHED', GETDATE () END
END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
		BEGIN insert into [dbo].[Logfile] select @proc + ' - FAILED', GETDATE () END
	END CATCH

GO

