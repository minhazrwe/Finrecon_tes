



/*=================================================================================================================
	author:		mbe
	created:	ancient times
	purpose:
	Inserts data from a csv file, based on the entries in Table dbo.ImportFiles, for the passed @ImportType e.g. Endur
	which would import data into Table EndurImport.
	Calls: omly the ssis-package for import
-----------------------------------------------------------------------------------------------------------------
	Changes:
	2022-06-10: ?,						, remove GL account 6579203 after SAP import, as it'S for over overhead (mail April 10/06/2022)
	2024-01-09, PG/mkb, step 0, restricted the allowance to run the procedure for all
	2024-01-12, mkb,		step 0, restricted the allowance to run the procedure for YK & VP 
=================================================================================================================*/

	CREATE PROCEDURE [dbo].[ImportSAPData] 

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

		DECLARE @Log_Entry_Text as nvarchar (200)
		DECLARE @ExceptionalUserRunAllowance as integer
		DECLARE @weekday integer
		
		
		/*restriction start*/			 
		select @step = 0
		
		/*A Group of special users may run the procedure just after 18:00 UK time on weekdays and througout the whole weekend without timely constraint. (request SH, 2024-01-09*/
		SELECT @weekday  = DATEPART(dw, GETDATE())
		SELECT @ExceptionalUserRunAllowance = CASE WHEN (format(GETDATE(),'HH:mm:ss')>'17:00') OR (@Weekday in (1,7))	THEN 1 ELSE 0 END
		
		IF NOT ( 
		(
			-- Data team users with right to run SAP import anytime
			user_name () = 'ENERGY\R884862'  /*MBE*/
			OR user_name () = 'ENERGY\R880382'  /*MKB*/			
			OR user_name () = 'ENERGY\UI856115' /*SH*/
			OR user_name () = 'ENERGY\UI788089' /*MU*/
			OR user_name () = 'ENERGY\UI555471' /*PG*/						
			OR user_name () = 'ENERGY\UI626985' /*MK*/
			OR user_name () = 'ENERGY\UI919293' /*SU*/
			OR user_name () = 'dbo' /*R2D2*/
			OR user_name () = 'testuserbulkinsert' /* Bulk Insert Testuser */
			OR user_name () = 'ENERGY\UI707956' /*MT*/
		) OR (
			(
				-- Exceptional user group, who can run, when @ExceptionalUserRunAllowance = 1
				user_name () ='ENERGY\R920983'			/*April Xin */
				OR user_name () ='ENERGY\UI567004'	/*Yasemin Koser */
				OR user_name () = 'ENERGY\R884018'  /*VP*/
			) AND @ExceptionalUserRunAllowance = 1
		)
		)
		BEGIN
			SET @Log_Entry_Text ='Skipped SAP import run by ' + user_name ()
			EXEC dbo.Write_Log 'Warning', @Log_Entry_Text, @proc, NULL, NULL, @step, 1 , NULL
			GOTO NoFurtherAction 
		END
		/*restriction end*/		
		
		select @step = 1
		select @proc = '[dbo].[ImportSAPData]'
		select  TOP 1 @machineName = HOST_NAME()
		select @step = @step + 1
		-- we need the LogInfo for Logging
		select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]
		
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportSAPData - START', GETDATE () END

		select @step = @step + 1
		-- select the source definition, means where the file is located and the name of the file

		--hard coded path:
		--select @PathName = [path] from [dbo].[pathToFiles] where [source] = 'SAP'
		
		--dynamic path:
		select @PathName = [dbo].[udf_get_path] ('SAP_Automatic')
		--when switching to win10 deactivate above line and activate line below (mkb, 15/06/2020):
		--select @PathName = [dbo].[udf_get_path] ('SAP_Win10')


		select @step = @step + 1
		select @TimeStamp = getdate()

		select @step = @step + 1
		-- delete before insert
		delete from [dbo].[import-SAP-Data]

		select @step = @step + 1
		select @filename = 'temp_SAP.csv' 

		select @step = @step + 1
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportSAPData - Import ' + @pathname + @filename, GETDATE () END

		select @sql = N'BULK INSERT [dbo].[Import-SAP-Data]  FROM '  + '''' + @pathname + @filename + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR ='','', FIRSTROW = 2, ROWTERMINATOR =''\n'')';
		execute sp_executesql @sql

		select @step = @step + 1
		--delete from  [dbo].[import-SAP-Data] where [dbo].[import-SAP-Data].[Buchungsdatum] is null and [dbo].[import-SAP-Data].[Belegdatum] is NULL

		select @step = @step + 1
		select @counter = count(1) from [dbo].[import-SAP-Data]

		select @step = @step + 1
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportSAPData - Anzahl in import-SAP-Data ' + convert(varchar(12),@counter), GETDATE () END

		select @step = @step + 1
		select @counter = count(1) from dbo.SAP

		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportSAPData - Anzahl in SAP vorher ' + convert(varchar(12),@counter), GETDATE () END

		select @step = @step + 1
		select @counter = count(1) from [FinRecon].[dbo].[SAP] where PostingDate 
		in (SELECT distinct convert(datetime, Buchungsdatum,104)  FROM [FinRecon].[dbo].[import-SAP-Data])
		and CompanyCode in (select distinct convert(integer,Buchungskreis) from [FinRecon].[dbo].[import-SAP-Data])

		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportSAPData - Anzahl der Datensätze, die in SAP gelöscht werden ' + convert(varchar(12),@counter), GETDATE () END

		-- Delete all entries of current month. Remaining Data reflects postings from previous months.
		select @step = @step + 1
		delete from [FinRecon].[dbo].[SAP] where PostingDate 
		in (SELECT distinct convert(datetime,[Buchungsdatum],104)  FROM [FinRecon].[dbo].[import-SAP-Data])
		and CompanyCode in (select distinct convert(integer,Buchungskreis) from [FinRecon].[dbo].[import-SAP-Data])
		
		select @step = @step + 1
		select @counter = count(1) from dbo.SAP

		--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select '### Anzahl in SAP nach Löschung ###' + convert(varchar(5),@counter), GETDATE () END
		
		-- Insert postings of current month
		select @step = @step + 1
		INSERT INTO [FinRecon].[dbo].[SAP] (
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

		  update [FinRecon].[dbo].[SAP] set [Quantity] = 0 where [Account] = '6070030' and [CompanyCode] = '611'

		  /*remove unneeded accounts*/ 
		  /*2023-05-08 (MU): Commented out since account 7639001 is empty and documents from 6579203 are needed for AWV Reporting (Anna Buschert, Sabine Meinke, Sascha Haag, Heike GS) */
		  --delete from [FinRecon].[dbo].[SAP] where [Account] in  ('7639001','6579203')

		  select @step = @step + 1
		  select @counter = count(1) from dbo.SAP

		  if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportSAPData - Anzahl in SAP nach Import, aber vor löschen => where Company Code is NULL ' + convert(varchar(12),@counter), GETDATE () END

			delete from [FinRecon].dbo.sap where companycode is null

			-- entered on request from April. Mail from 17.06.2021 | MBE
			--delete from SAP where Account in ('5360000','7636000')
		  
		  select @step = @step + 1
		  select @counter = count(1) from dbo.SAP

		 

		  if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportSAPData - Anzahl in SAP nachher ' + convert(varchar(12),@counter), GETDATE () END

		  if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportSAPData - FINISHED', GETDATE () END

NoFurtherAction:
/* hier passiert NIX mehr*/
	END TRY

	BEGIN CATCH		
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
		BEGIN insert into [dbo].[Logfile] select 'ImportSAPData - FAILED' + CURRENT_USER + ' on ' + @machineName + ' on server: ' + @@SERVERNAME, GETDATE () END
	END CATCH

GO

