






/*
	Inserts data from a csv file, based on the entries in Table dbo.ImportFiles, for the passed @ImportType e.g. Endur
	which would import data into Table EndurImport.
	Calls: omly the ssis-package for import
*/
	CREATE PROCEDURE [dbo].[FxHedgeDeliveryImportSAPCashData] 

	AS
	BEGIN TRY
		DECLARE @FileName nvarchar (50) 
		DECLARE @PathName nvarchar (300)
		DECLARE @TimeStamp datetime
		DECLARE @LogInfo Integer
		DECLARE @proc nvarchar(40)
		DECLARE @step Integer
		DECLARE @counter Integer
		DECLARE @source nvarchar (300)
		DECLARE @sql nvarchar (max)

		select @step = 1
		select @proc = '[dbo].[FxHedgeDeliveryImportSAPCashData]'

		select @step = @step + 1
		-- we need the LogInfo for Logging
		select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]
		
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'FxHedgeDeliveryImportSAPCashData - START', GETDATE () END

		select @step = @step + 1
		-- select the source definition, means where the file is located and the name of the file

		--hard coded path:
		--select @PathName = [path] from [dbo].[pathToFiles] where [source] = 'SAP'
		
		--dynamic path:
		select @PathName = [dbo].[udf_get_path] ('SAPFxHedgeDelivery_Automatic')
		--when switching to win10 deactivate above line and activate line below (mkb, 15/06/2020):
		--select @PathName = [dbo].[udf_get_path] ('SAP_Win10')


		select @step = @step + 1
		select @TimeStamp = getdate()

		select @step = @step + 1
		-- delete before insert
		delete from [dbo].[table_FxHedgeDelivery_SAPCash_import]

		select @step = @step + 1
		select @filename = 'FxHedgeDelivery_temp_SAP.csv' 

		select @step = @step + 1
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'FxHedgeDeliveryImportSAPCashData - Import ' + @pathname + @filename, GETDATE () END

		select @sql = N'BULK INSERT [dbo].[FxHedgeDeliveryImportSAPCashData]  FROM '  + '''' + @pathname + @filename + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR ='','', FIRSTROW = 2, ROWTERMINATOR =''\n'')';
		execute sp_executesql @sql

		select @step = @step + 1
		--delete from  [dbo].[import-SAP-Data] where [dbo].[import-SAP-Data].[Buchungsdatum] is null and [dbo].[import-SAP-Data].[Belegdatum] is NULL

		select @step = @step + 1
		select @counter = count(1) from [dbo].[FxHedgeDeliveryImportSAPCashData]

		select @step = @step + 1
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'FxHedgeDeliveryImportSAPCashData - Anzahl in import-SAP-Data ' + convert(varchar(12),@counter), GETDATE () END

		select @step = @step + 1
		select @counter = count(1) from dbo.table_FxHedgeDelivery_SAP_Cash

		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'FxHedgeDeliveryImportSAPCashData - Anzahl in SAP vorher ' + convert(varchar(12),@counter), GETDATE () END

		select @step = @step + 1
		select @counter = count(1) from [FinRecon].[dbo].[table_FxHedgeDelivery_SAP_Cash] where PostingDate 
		in (SELECT distinct convert(datetime, Buchungsdatum,104)  FROM [FinRecon].[dbo].[FxHedgeDeliveryImportSAPCashData])
		and CompanyCode in (select distinct convert(integer,Buchungskreis) from [FinRecon].[dbo].[FxHedgeDeliveryImportSAPCashData])

		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'FxHedgeDeliveryImportSAPCashData - Anzahl der Datensätze, die in SAP gelöscht werden ' + convert(varchar(12),@counter), GETDATE () END

		select @step = @step + 1
		delete from [FinRecon].[dbo].[table_FxHedgeDelivery_SAP_Cash] where PostingDate 
		in (SELECT distinct convert(datetime,[Buchungsdatum],104)  FROM [FinRecon].[dbo].[FxHedgeDeliveryImportSAPCashData])
		and CompanyCode in (select distinct convert(integer,Buchungskreis) from [FinRecon].[dbo].[FxHedgeDeliveryImportSAPCashData])
		
		select @step = @step + 1
		select @counter = count(1) from dbo.[table_FxHedgeDelivery_SAP_Cash]

		--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select '### Anzahl in SAP nach Löschung ###' + convert(varchar(5),@counter), GETDATE () END
		
		select @step = @step + 1
		insert into [FinRecon].[dbo].[table_FxHedgeDelivery_SAP_Cash] ([CompanyCode]      ,[Account]      ,[OffsettingAccount]     ,[DocumentHeaderText], [Reference]
			  ,[Assignment]      ,[DocumentNumber]      ,[BusinessArea]      ,[DocumentType]      ,[PostingDate]
			  ,[DocumentDate]      ,[PostingKey]      ,[Amountinlocalcurrency]      ,[LocalCurrency]      ,[Taxcode]
			  ,[ClearingDocument]      ,[Text]      ,[TradingPartner]      ,[TransactionType]      ,[Documentcurrency]
			  ,[Amountindoccurr]      ,[Order]      ,[CostCenter]      ,[Quantity]      ,[BaseUnitofMeasure]
			  ,[Material]      , [RefKey1]      ,[RefKey2]      ,[RefKey3] , [Username]      ,[EntryDate]      )
		SELECT convert(integer,[Buchungskreis])      ,[Konto]      ,[Konto Gegenbuchung], [Belegkopftext]      ,[Referenz]      ,[Zuordnung]
			  ,[Belegnummer]      ,[Geschäftsbereich]      ,[Belegart]      ,convert(datetime,[Buchungsdatum],104)      ,convert(datetime,[Belegdatum],104)
			  ,convert(integer,[Buchungsschlüssel])      ,convert(float,[Betrag in Hauswährung])      ,[Hauswährung]      ,[Steuerkennzeichen]
			  ,[Ausgleichsbeleg]      ,left([Text],50)      ,[Partnergesellschaft]      ,[Bewegungsart]
			  ,[Belegwährung]      ,convert(float,[Betrag in Belegwährung])      ,[Auftrag]      ,[Kostenstelle]      ,[Menge]
			  ,[Basismengeneinheit]      ,[Material]      ,[RefSchl1]      ,[RefSchl2]      ,[RefSchl3], [Name des Benutzers]      ,convert(datetime, [Erfassungsdatum],104)      
		  FROM [FinRecon].[dbo].[FxHedgeDeliveryImportSAPCashData]


		  		  
		  select @step = @step + 1
		  select @counter = count(1) from dbo.[table_FxHedgeDelivery_SAP_Cash]

		 

		  if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'FxHedgeDeliveryImportSAPCashData - Anzahl in SAP nachher ' + convert(varchar(12),@counter), GETDATE () END

		  if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'FxHedgeDeliveryImportSAPCashData - FINISHED', GETDATE () END

	

	END TRY

	BEGIN CATCH		
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
		BEGIN insert into [dbo].[Logfile] select 'FxHedgeDeliveryImportSAPCashData - FAILED', GETDATE () END
	END CATCH

GO

