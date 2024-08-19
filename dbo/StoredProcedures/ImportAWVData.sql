













/*
	Inserts data from a csv file, based on the entries in Table dbo.ImportFiles, for the passed @ImportType e.g. Endur
	which would import data into Table EndurImport.
	Calls: omly the ssis-package for import
*/
	CREATE PROCEDURE [dbo].[ImportAWVData] 
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
		select @proc = '[dbo].[ImportAWVData]'

		select @step = @step + 1
		-- we need the LogInfo for Logging
		select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

		select @step = @step + 1
		select @TimeStamp = getdate()

		IF (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_NAME = 'AWV_Import_Temp'))
		BEGIN
			if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select '### drops temp table ### ', GETDATE () END
			drop table [dbo].[AWV_Import_Temp]
		END

		select @step = @step + 1
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select '### crreates temp table ### ', GETDATE () END
		CREATE TABLE [dbo].[AWV_Import_temp]([SAP-Buchungskreis] [int] NULL,[SAP-Konto] [varchar](50) NULL,[SAP-Belegnummer] [varchar](50) NULL,[SAP-Buchungsdatum] [date] NULL,[SAP-Belegart] [varchar](50) NULL,
							[SAP-Referenz] [varchar](50) NULL,[SAP-Debitor/Kreditor] [varchar](50) NULL,[SAP-Buchungsschlüssel] [int] NULL,[SAP-Zuordnung] [varchar](50) NULL,
							[AWV-Bezeichnung] [varchar](1000) NULL,[AWV-Info] [varchar](1000) NULL,[AWV-Bemerkung/Zahlungszweck] [varchar](1000) NULL,[Absatz/Bezug] [varchar](10) NULL,
							[AWV-LZB] [varchar](100) NULL,[AWV-Anlage] [varchar](20) NULL,[Counterparty Land] [varchar](100) NULL,[SAP-Text] [varchar](100) NULL,[SAP-Belegdatum] [date] NULL,
							[SAP-Betrag in Hauswährung] [varchar](50) NULL,[SAP-Hauswährung] [varchar](50) NULL,[SAP-Betrag in Belegwährung] [varchar](50) NULL,[SAP-Belegwährung] [varchar](50) NULL,
							[SAP-Steuerkennzeichen] [varchar](50) NULL,[SAP-Menge] [varchar](50) NULL,[AusschlussKommentar] [varchar](100) NULL,[SAP-Belegkopftext]  [varchar](300) NULL,[TradingPartner] [varchar](50) NULL,
							[Liefer Land] [varchar](100) NULL,[RefSchl2]  [varchar](300) NULL, [AWV-Responsible] [varchar](50) NULL,[ROWID] [bigint] NULL) ON [PRIMARY]

		select @step = @step + 1
		select @filename = 'temp_AWV-DATA.csv' 

		select @step = @step + 1
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select '### File Name ### ' + @pathname + @filename, GETDATE () END

		select @sql = N'BULK INSERT [dbo].[AWV_Import_Temp]  FROM '  + '''' + @pathname + @filename + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR ='','', FIRSTROW = 2, ROWTERMINATOR =''\n'')';
		execute sp_executesql @sql

		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import is done for AWV-DATA ' , GETDATE () END

		select @step = @step + 1
		select @filename = 'temp_AWV-Ausschluss.csv' 

		select @step = @step + 1
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select '### File Name ### ' + @pathname + @filename, GETDATE () END

		select @sql = N'BULK INSERT [dbo].[AWV_Import_Temp]  FROM '  + '''' + @pathname + @filename + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR ='','', FIRSTROW = 2, ROWTERMINATOR =''\n'')';
		execute sp_executesql @sql

		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import is done for Ausschluss ' , GETDATE () END

		delete from [dbo].[AWV_Import_Temp] where [AWV-Responsible] = '' or [AWV-Responsible] is NULL

		update [dbo].[AWV_Import_temp] set [SAP-Betrag in Hauswährung] = replace([SAP-Betrag in Hauswährung],'~', '.')
		update [dbo].[AWV_Import_temp] set [SAP-Betrag in Belegwährung] = replace([SAP-Betrag in Belegwährung],'~', '.')
		update [dbo].[AWV_Import_temp] set [SAP-Menge] = replace([SAP-Menge],'~', '.')

		select @step = @step + 1
		--delete before insert
		delete from [dbo].[AWV_Import] where [AWV-Responsible] in (select distinct [AWV-Responsible] from [dbo].[AWV_Import_Temp])
		
		insert into  [dbo].[AWV_Import]([SAP-Buchungskreis],[SAP-Konto],[SAP-Belegnummer],[SAP-Buchungsdatum],[SAP-Belegart],[SAP-Referenz],[SAP-Debitor/Kreditor],[SAP-Buchungsschlüssel],[SAP-Zuordnung]
			  ,[AWV-Bezeichnung],[AWV-Info],[AWV-Bemerkung/Zahlungszweck],[Absatz/Bezug],[AWV-LZB],[AWV-Anlage],[Counterparty Land],[SAP-Text],[SAP-Belegdatum],[SAP-Betrag in Hauswährung]
			  ,[SAP-Hauswährung],[SAP-Betrag in Belegwährung],[SAP-Belegwährung],[SAP-Steuerkennzeichen],[SAP-Menge],[AusschlussKommentar],[SAP-Belegkopftext],[TradingPartner],[Liefer Land],[RefSchl2],
			  [AWV-Responsible],[ROWID])
		SELECT  [SAP-Buchungskreis],[SAP-Konto],[SAP-Belegnummer],[SAP-Buchungsdatum],[SAP-Belegart],[SAP-Referenz],[SAP-Debitor/Kreditor],[SAP-Buchungsschlüssel],[SAP-Zuordnung]
			  ,[AWV-Bezeichnung],[AWV-Info],[AWV-Bemerkung/Zahlungszweck],[Absatz/Bezug],[AWV-LZB],[AWV-Anlage],[Counterparty Land],[SAP-Text],[SAP-Belegdatum],[SAP-Betrag in Hauswährung]
			  ,[SAP-Hauswährung],[SAP-Betrag in Belegwährung],[SAP-Belegwährung],[SAP-Steuerkennzeichen],[SAP-Menge],[AusschlussKommentar],[SAP-Belegkopftext],[TradingPartner],[Liefer Land],[RefSchl2],
			  [AWV-Responsible],[ROWID]
		 FROM [dbo].[AWV_Import_temp]
		 
		 update [dbo].[AWV_Import] set [SAP-Text] = replace([SAP-Text],'~', ',')
		 update [dbo].[AWV_Import] set [AWV-Info] = replace([AWV-Info],'~', ',')
		 update [dbo].[AWV_Import] set [AWV-Bemerkung/Zahlungszweck] = replace([AWV-Bemerkung/Zahlungszweck],'~', ',')
		 update [dbo].[AWV_Import] set [SAP-Belegkopftext] = replace([SAP-Belegkopftext],'~', ',')
		 update [dbo].[AWV_Import] set [RefSchl2] = replace([RefSchl2],'~', ',')
		 update [dbo].[AWV_Import] set [AWV-Bezeichnung] = replace([AWV-Bezeichnung],'~', ',')
		 update [dbo].[AWV_Import] set [AusschlussKommentar] = replace([AusschlussKommentar],'~', ',')
		 update [dbo].[AWV_Import] set [SAP-Belegkopftext] = replace([SAP-Belegkopftext],'~', ',')
		 
		 drop table [dbo].[AWV_Import_Temp]
		
	END TRY

	BEGIN CATCH
		--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
	END CATCH

GO

