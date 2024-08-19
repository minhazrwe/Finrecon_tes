






/*
	Inserts data from a csv file, based on the entries in Table dbo.ImportFiles, for the passed @ImportType e.g. Endur
	which would import data into Table EndurImport.
	Calls: omly the ssis-package for import
*/
	CREATE PROCEDURE [dbo].[ImportAWVAccounts] 
			@PathName nvarchar (300)
	AS
	BEGIN TRY
		DECLARE @FileName nvarchar (50) 
		DECLARE @TimeStamp datetime
		DECLARE @LogInfo Integer
		DECLARE @proc nvarchar(40)
		DECLARE @step Integer
		DECLARE @counter Integer
		DECLARE @sql nvarchar (max)

		select @step = 1
		select @proc = '[dbo].[ImportAWVAccounts]'

		select @step = @step + 1
		-- we need the LogInfo for Logging
		select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

		select @step = @step + 1
		select @TimeStamp = getdate()

		IF (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_NAME = 'AWV_Import_Accounts'))
		BEGIN
			if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select '### drops temp table ### ', GETDATE () END
			drop table [dbo].[AWV_Import_Accounts]
		END

		select @step = @step + 1
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select '### crreates temp table ### ', GETDATE () END
		CREATE TABLE [dbo].[AWV_Import_Accounts]([Account] [varchar](255) NOT NULL,[AccountName] [varchar](255) NULL,[recon_group] [varchar](40) NULL,[Commodity] [varchar](255) NULL,
													[comment] [varchar](255) NULL,[AWV-Anlage] [varchar](20) NULL,[AWV-LZB] [varchar](20) NULL,[AWV-Bemerkung/Zahlungszweck] [varchar](1000) NULL,
													[AWV-Responsible] [varchar](50) NULL,) ON [PRIMARY]

		select @step = @step + 1
		select @filename = 'temp_AWV-Accounts.csv' 

		select @step = @step + 1
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select '### File Name ### ' + @pathname + @filename, GETDATE () END

		select @sql = N'BULK INSERT [dbo].[AWV_Import_Accounts]  FROM '  + '''' + @pathname + @filename + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR ='','', FIRSTROW = 2, ROWTERMINATOR =''\n'')';
		execute sp_executesql @sql

		update [dbo].[AWV_Import_Accounts] set [AccountName] = replace([AccountName],'~', ',')
		update [dbo].[AWV_Import_Accounts] set [recon_group] = replace([recon_group],'~', ',')
		update [dbo].[AWV_Import_Accounts] set [Commodity] = replace([Commodity],'~', ',')
		update [dbo].[AWV_Import_Accounts] set [comment] = replace([comment],'~', ',')
		update [dbo].[AWV_Import_Accounts] set [AWV-Anlage] = replace([AWV-Anlage],'~', ',')
		update [dbo].[AWV_Import_Accounts] set [AWV-Bemerkung/Zahlungszweck] = replace([AWV-Bemerkung/Zahlungszweck],'~', ',')
		update [dbo].[AWV_Import_Accounts] set [AWV-Responsible] = replace([AWV-Responsible],'~', ',')


		select @step = @step + 1
		update dd set dd.[AWV-Anlage] =  ff.[AWV-Anlage] from  dbo.map_ReconGroupAccount as dd 
						inner join  [dbo].[AWV_Import_Accounts] as ff on dd.Account = ff.Account and dd.AccountName = ff.AccountName and dd.[AWV-Anlage] <> ff.[AWV-Anlage]

		update dd set dd.[AWV-LZB] =  ff.[AWV-LZB] from  dbo.map_ReconGroupAccount as dd 
						inner join  [dbo].[AWV_Import_Accounts] as ff on dd.Account = ff.Account and dd.AccountName = ff.AccountName and dd.[AWV-LZB] <> ff.[AWV-LZB]

		update dd set dd.[AWV-Bemerkung/Zahlungszweck] =  ff.[AWV-Bemerkung/Zahlungszweck] from  dbo.map_ReconGroupAccount as dd 
						inner join  [dbo].[AWV_Import_Accounts] as ff on dd.Account = ff.Account and dd.AccountName = ff.AccountName and dd.[AWV-Bemerkung/Zahlungszweck] <> ff.[AWV-Bemerkung/Zahlungszweck]

		update dd set dd.[AWV-Responsible] =  ff.[AWV-Bemerkung/Zahlungszweck] from  dbo.map_ReconGroupAccount as dd 
						inner join  [dbo].[AWV_Import_Accounts] as ff on dd.Account = ff.Account and dd.AccountName = ff.AccountName and dd.[AWV-Responsible] <> ff.[AWV-Responsible]

		drop table [dbo].[AWV_Import_Accounts]

	END TRY

	BEGIN CATCH
		--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
	END CATCH

GO

