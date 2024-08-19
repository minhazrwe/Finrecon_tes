

CREATE PROCEDURE [dbo].[fill_AWV_Export]

@nameofquery nvarchar(255)

AS
BEGIN TRY

	DECLARE @LogInfo Integer
	DECLARE @proc nvarchar(40)
	DECLARE @step Integer
	DECLARE @CoBDate as datetime
	DECLARE @Anzahl Integer

	select @CoBDate = AsOfDate_EOM from [dbo].[AsOfDate]

	select @step = 1
	select @proc = Object_Name(@@PROCID)

	select @step = @step + 1
	select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - START', GETDATE () END


	if @nameofquery = 'Z10_Responsible'
		Begin
			select @Anzahl = count(*) from [AWV_Log_Diff_Part]
			if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - Anzahl vorher [AWV_Log_Diff_Part] => ' + convert(varchar(100), @Anzahl), GETDATE () END

			insert into [AWV_Log_Diff_Part] ( SAPAccount, SAPDocumentNumber,SAPResponsible ) select distinct dd.[SAP-Konto], dd.[SAP-Belegnummer], dd.[AWV-Responsible] 
			from dbo.AWV_Results as dd  where dd.[AWV-Responsible] = @nameofquery and  not (([SAP-Konto] = '4008038' or [SAP-Konto] = '6018038') and ([SAP-Text] like '%;290;%' or [SAP-Text]  like '%;286;%')) 
			
			select @Anzahl = count(*) from [AWV_Log_Diff_Part]
			if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - Anzahl nachher [AWV_Log_Diff_Part] => ' + convert(varchar(100), @Anzahl), GETDATE () END
		End

	if @nameofquery = 'Diverse'
		Begin
			select @Anzahl = count(*) from [AWV_Log_Diff_Part]
			if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - Anzahl vorher [AWV_Log_Diff_Part] => ' + convert(varchar(100), @Anzahl), GETDATE () END

			insert into [AWV_Log_Diff_Part] ( SAPAccount, SAPDocumentNumber,SAPResponsible ) select distinct dd.[SAP-Konto], dd.[SAP-Belegnummer], dd.[AWV-Responsible] 
			from dbo.AWV_Results as dd  where dd.[AWV-Responsible] = @nameofquery or (([SAP-Konto] = '4008038' or [SAP-Konto] = '6018038') and ([SAP-Text] like '%;290;%' or [SAP-Text]  like '%;286;%')) 

			select @Anzahl = count(*) from [AWV_Log_Diff_Part]
			if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - Anzahl nachher [AWV_Log_Diff_Part] => ' + convert(varchar(100), @Anzahl), GETDATE () END
		End

	if @nameofquery != 'Diverse' and @nameofquery != 'Z10_Responsible'

		Begin
			select @Anzahl = count(*) from [AWV_Log_Diff_Part]
			if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - Anzahl vorher [AWV_Log_Diff_Part] => ' + convert(varchar(100), @Anzahl), GETDATE () END

			insert into [AWV_Log_Diff_Part] ( SAPAccount, SAPDocumentNumber,SAPResponsible ) select distinct dd.[SAP-Konto], dd.[SAP-Belegnummer], dd.[AWV-Responsible] 
				from dbo.AWV_Results as dd  where dd.[AWV-Responsible] = @nameofquery 

			select @Anzahl = count(*) from [AWV_Log_Diff_Part]
			if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - Anzahl nachher [AWV_Log_Diff_Part] => ' + convert(varchar(100), @Anzahl), GETDATE () END
		END
			
		select @Anzahl = count(*) from [AWV_Log_Diff]
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - Anzahl vorher [AWV_Log_Diff] => ' + convert(varchar(100), @Anzahl), GETDATE () END

		INSERT INTO dbo.AWV_Log_Diff ( SAPAccount, SAPDocumentNumber) select distinct SAPAccount, SAPDocumentNumber  from [AWV_Log_Diff_Part] 
           except select [SAPAccount], [SAPDocumentNumber] from dbo.AWV_Log

		select @Anzahl = count(*) from [AWV_Log_Diff]
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - Anzahl nachher [AWV_Log_Diff] => ' + convert(varchar(100), @Anzahl), GETDATE () END


	select @Anzahl = count(*) from [AWV_Export]
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - Anzahl vorher  [AWV_Export] => ' + convert(varchar(100), @Anzahl), GETDATE () END

	insert into [dbo].[AWV_Export] ([SAP-Buchungskreis],[SAP-Konto],[SAP-Debitor/Kreditor],[SAP-Belegnummer],[SAP-Buchungsschlüssel],[SAP-Belegart],[SAP-Belegkopftext]
				,[SAP-Buchungsdatum],[SAP-Referenz],[SAP-Text],[SAP-Belegdatum],[SAP-Zuordnung],[RefSchl2],[SAP-Betrag in Hauswährung],[SAP-Hauswährung],[SAP-Betrag in Belegwährung]
				,[SAP-Belegwährung],[SAP-Steuerkennzeichen],[SAP-Menge],[AWV-Bezeichnung],[AWV-Bemerkung/Zahlungszweck],[New_BZ],[AWV-Info],[Absatz/Bezug],[AusschlussKommentar],[AWV-LZB]
				,[AWV-LZB-Inland],[AWV-Anlage],[TradingPartner],[Counterparty Land],[Liefer Land],[AWV-Responsible],[ROWID])
	select [SAP-Buchungskreis],[SAP-Konto],[SAP-Debitor/Kreditor],[SAP-Belegnummer],[SAP-Buchungsschlüssel],[SAP-Belegart],[SAP-Belegkopftext]
				,[SAP-Buchungsdatum],[SAP-Referenz],[SAP-Text],[SAP-Belegdatum],[SAP-Zuordnung],[RefSchl2],[SAP-Betrag in Hauswährung],[SAP-Hauswährung],[SAP-Betrag in Belegwährung]
				,[SAP-Belegwährung],[SAP-Steuerkennzeichen],[SAP-Menge],[AWV-Bezeichnung],[AWV-Bemerkung/Zahlungszweck],[New_BZ],[AWV-Info],[Absatz/Bezug],[AusschlussKommentar],[AWV-LZB]
				,[AWV-LZB-Inland],[AWV-Anlage],[TradingPartner],[Counterparty Land],[Liefer Land],[AWV-Responsible],[ROWID]  FROM [dbo].[AWV_Results_Diff]
				
	select @Anzahl = count(*) from [AWV_Export]
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - Anzahl nachher [AWV_Export] => ' + convert(varchar(100), @Anzahl), GETDATE () END
			
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - FINISHED', GETDATE () END
END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
		BEGIN insert into [dbo].[Logfile] select @proc + ' - FAILED', GETDATE () END
	END CATCH

GO

