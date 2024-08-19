
CREATE PROCEDURE [dbo].[GASUpdateVAT] 
	AS
	BEGIN TRY

/*===============================================================================================================
	author:		mkb
	created:	2022
	purpose:	update of steuerkennzeichen to reflect the temporary change of VAT in Germany for Gas Products
						from 19% to 7% valid for the period from 01. October 2022 to 31. March  2023 	(mkb, 10/2022)
						
						Regarding the information of Tax the following tax codes need to be changed:
							I) Gaslieferungen mit Umsatzsteuerausweis: --> A2 
						 II) Gaslieferungen ohne Steuerausweis (Reverse Charge) an Kunden im Inland und Ausland bleiben unverändert 
						III) Korrekturen für Rechnungen über Gaslieferungen mit Umsatzsteuerausweis (bei 19% P9) --> P2 
						 IV) Gaseinkauf ohne Steuerausweis (Reverse Charge) von Lieferanten im Inland und Ausland: --> X7 
 
						ACHTUNG !!! finales Setzen findet erst nach Rücksprache mit Steffi, Heike und Diana Muhlman statt, aber nicht vor dem 11.10.2022!!!)
===============================================================================================================
changes: (when, who, step, what, (why)

===============================================================================================================*/

		DECLARE @LogInfo Integer
		DECLARE @proc nvarchar(50)

		SELECT @proc = Object_Name(@@PROCID)

		select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'MapAccounts - ' + @proc + ' - Start', GETDATE () END
	
		
		UPDATE [dbo].[02_Realised_all_details]
			SET StKZ =
				CASE 
					WHEN StKZ = 'A9' THEN 'A2' 
					WHEN StKZ = 'X6' THEN 'X7'
					ELSE StKZ
				END
			WHERE 
				StKZ in ('A9','X6')
				AND	InstrumentType in ('GAS-FWD-IMB-P','GAS-FWD-P','GAS-FWD-STD-P')
				AND CashFlowType in ('Settlement','Interest','None')
				AND	VAT_CountryCode in ('DE','DE_19','DE_19_Strom','DE_19_Gas')
				AND	DeliveryMonth IN ('2022/10','2022/11','2022/12','2023/01','2023/02','2023/03')
			
			
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select  'MapAccounts - ' + @proc + ' - FINISHED', GETDATE () END
	END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, 1
		BEGIN INSERT INTO [dbo].[Logfile] SELECT  @proc + ' - FAILED', GETDATE () END
	END CATCH

GO

