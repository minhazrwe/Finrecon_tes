






/*
purpose:
	Inserts data from a csv file, based on the entries in Table dbo.ImportFiles, for the passed @ImportType e.g. Endur
	which would import data into Table EndurImport.
	Calls: omly the ssis-package for import
*/


	CREATE PROCEDURE [dbo].[ImportSAPDataCurrentMonth] 

	AS
	BEGIN TRY
		DECLARE @FileName nvarchar (50) 
		DECLARE @PathName nvarchar (300)
		DECLARE @TimeStamp datetime
		DECLARE @LogInfo Integer
		DECLARE @machineName nvarchar(255)
		DECLARE @proc nvarchar(40)
		DECLARE @step Integer
		DECLARE @counter Integer
		DECLARE @source nvarchar (300)
		DECLARE @sql nvarchar (max)

		select @step = 1
		select @proc = '[dbo].[ImportSAPDataCurrentMonth]'
		select  TOP 1 @machineName = HOST_NAME()
		select @step = @step + 1
		-- we need the LogInfo for Logging
		select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]
		
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportSAPDataCurrentMonth - START', GETDATE () END

		select @step = @step + 1
		-- select the source definition, means where the file is located and the name of the file
		
		--dynamic path:
		select @PathName = [dbo].[udf_get_path] ('SAP_Automatic')

		select @step = @step + 1
		select @TimeStamp = getdate()

		select @step = @step + 1
		-- delete before insert
		delete from [dbo].[import-SAP-Data]

		select @step = @step + 1
		select @filename = 'temp_SAP.csv' 

		select @step = @step + 1
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportSAPDataCurrentMonth - Import ' + @pathname + @filename, GETDATE () END

		select @sql = N'BULK INSERT [dbo].[Import-SAP-Data]  FROM '  + '''' + @pathname + @filename + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR ='','', FIRSTROW = 2, ROWTERMINATOR =''\n'')';
		execute sp_executesql @sql

		select @step = @step + 1
		select @counter = count(1) from [dbo].[import-SAP-Data]

		select @step = @step + 1
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportSAPDataCurrentMonth - Anzahl in import-SAP-Data ' + convert(varchar(12),@counter), GETDATE () END

		select @step = @step + 1
		select @counter = count(1) from dbo.SAP_Current_Month

		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportSAPDataCurrentMonth - Anzahl in SAP werden gelöscht ' + convert(varchar(12),@counter), GETDATE () END

		-- Delete all entries of current month. Remaining Data reflects postings from previous months.
		select @step = @step + 1
		delete from [FinRecon].[dbo].[SAP_Current_Month]

		--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select '### Anzahl in SAP nach Löschung ###' + convert(varchar(5),@counter), GETDATE () END
		
		-- Insert postings of current month
		select @step = @step + 1
		INSERT INTO [FinRecon].[dbo].[SAP_Current_Month] (
			[CompanyCode], [Account], [OffsettingAccount], [DocumentHeaderText], [Reference], [Assignment], 
			[DocumentNumber], [BusinessArea], [DocumentType], [PostingDate], [DocumentDate], [PostingKey], 
			[Amountinlocalcurrency], [LocalCurrency], [Taxcode], [ClearingDocument], [Text], [TradingPartner], 
			[TransactionType], [Documentcurrency], [Amountindoccurr], [Order], [CostCenter], [Quantity], 
			[BaseUnitofMeasure], [Material], [RefKey1], [RefKey2], [RefKey3], [Username], [EntryDate]
			)
		SELECT convert(INTEGER, [Buchungskreis]) as [CompanyCode]
			,[Konto] as [Account]
			,[Konto Gegenbuchung] as [OffsettingAccount]
			,[Belegkopftext] as [DocumentHeaderText]
			,[Referenz] as [Reference]
			,[Zuordnung] as [Assignment]
			,[Belegnummer] as [DocumentNumber]
			,[Geschäftsbereich] as [BusinessArea]
			,[Belegart] as [DocumentType]
			,convert(DATETIME, [Buchungsdatum], 104) as [PostingDate]
			,convert(DATETIME, [Belegdatum], 104) as [DocumentDate]
			,convert(INTEGER, [Buchungsschlüssel]) as [PostingKey]
			,convert(FLOAT, [Betrag in Hauswährung]) as [Amountinlocalcurrency]
			,[Hauswährung]  as [LocalCurrency]
			,[Steuerkennzeichen] as [Taxcode]
			,[Ausgleichsbeleg] as [ClearingDocument]
			,left([Text], 50) as [Text]
			,[Partnergesellschaft] as [TradingPartner]
			,[Bewegungsart] as [TransactionType]
			,[Belegwährung] as [Documentcurrency]
			,convert(FLOAT, [Betrag in Belegwährung]) as [Amountindoccurr]
			,[Auftrag]  as [Order]
			,[Kostenstelle] as [CostCenter]
			,[Menge] as [Quantity]
			,[Basismengeneinheit] as [BaseUnitofMeasure]
			,[Material] as [Material]
			,[RefSchl1] as [RefKey1]
			,[RefSchl2] as [RefKey2]
			,[RefSchl3] as [RefKey3]
			,[Name des Benutzers] as [Username]
			,convert(DATETIME, [Erfassungsdatum], 104) as [EntryDate]
		FROM [FinRecon].[dbo].[import-SAP-Data]

		  select @step = @step + 1
		  select @counter = count(1) from dbo.SAP_Current_Month

		  if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportSAPDataCurrentMonth - Anzahl in SAP Current Month nach Import, aber vor löschen => where Company Code is NULL ' + convert(varchar(12),@counter), GETDATE () END

		  delete from [FinRecon].dbo.SAP_Current_Month where companycode is null
		  
		  select @step = @step + 1
		  select @counter = count(1) from dbo.SAP_Current_Month

		  select @step = @step + 1
		  delete from [dbo].[import-SAP-Data]
		 

		  if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportSAPDataCurrentMonth - Anzahl in SAP Current Month nachher ' + convert(varchar(12),@counter), GETDATE () END

		  if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportSAPDataCurrentMonth - FINISHED', GETDATE () END

	END TRY

	BEGIN CATCH		
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
		BEGIN insert into [dbo].[Logfile] select 'ImportSAPDataCurrentMonth - FAILED' + CURRENT_USER + ' on ' + @machineName + ' on server: ' + @@SERVERNAME, GETDATE () END
	END CATCH

GO

