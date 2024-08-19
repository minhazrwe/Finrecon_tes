
/*=================================================================================================================
	Author:		MK
	Created:	2024-04-17
	Purpose:	Import IFA Realised data FROM Strolf to Finrecon. Procedure 1 is a preliminary load to get data
				INTO Finrecon and sort out mappings. AsSET name needs to be isolated FROM TRADE_REFERENCE_TEXT
				free text field via mappings table. Procedure 2 pushes data INTO 01_realised_all.
-----------------------------------------------------------------------------------------------------------------
	Changes:
	2024-XX-XX, USER, step X, DESCRIPTION
=================================================================================================================*/

CREATE PROCEDURE [dbo].[ImportStrolfData_IFA_Realised_2] 
AS
BEGIN TRY

-- Vartype definition
DECLARE @Current_Procedure nvarchar(40)
DECLARE @step Integer
DECLARE @FileID Integer

-- Var definition
SET @FileID = 3269
SET @step = 1
SET @Current_Procedure = Object_Name(@@PROCID)

EXEC dbo.Write_Log 'Info', 'Started final import of realised IFA data from Strolf', @Current_Procedure, NULL, NULL, @step, 1
EXEC dbo.Write_Log 'Info', 'Remove IFA data from [dbo].[01_realised_all]', @Current_Procedure, NULL, NULL, @step, 1

	DELETE FROM [dbo].[01_realised_all] WHERE fileid = @FileID

EXEC dbo.Write_Log 'Info', 'Insert IFA data into [dbo].[01_realised_all]', @Current_Procedure, NULL, NULL, @step, 1

	SET @step = 2

	INSERT INTO [01_realised_all] ([Trade Deal Number],[Trade Reference Text],[Transaction Info Status],[Instrument Type Name],[Int Legal Entity Name],[Int Business Unit Name],[Internal Portfolio Name],[External Portfolio Name],[Ext Business Unit Name],[Ext Legal Entity Name],[Index Name],[Trade Currency],[Transaction Info Buy Sell],[Cashflow Type],[Trade Price],[Trade Date],[Trade Instrument Reference Text],[Unit Name (Trade Std)],[Cashflow Payment Date],[Leg End Date],[Index Group],[volume],[Realised_OrigCCY_Undisc],[Realised_EUR_Undisc],[FileID])
	SELECT [TRADE_DEAL_NUMBER],[Strolf_realized_IFA].[TRADE_REFERENCE_TEXT],[TRAN_STATUS],[INS_TYPE_NAME],[LENTITY_NAME],[BUNIT_NAME]
		,[PORTFOLIO_NAME] + ' / ' + [dbo].[map_asSET_reference].[AsSET_Name]
		,[EXT_PORTFOLIO_NAME],[EXT_BUNIT_NAME],[EXT_LENTITY_NAME],[INDEX_NAME],[TRADE_CURRENCY],[TRANSACTION_INFO_BUY_SELL],[CASHFLOW_TYPE],[TRADE_PRICE],[TRADE_DATE],[TICKER],[UNIT_NAME],[CASHFLOW_PAYMENT_DATE],[DELIVERY_MONTH],[INDEX_GROUP],[VOLUME],[REALISED_ORIGCCY_UNDISC],[REALISED_EUR_UNDISC],@FileID
	FROM [dbo].[Strolf_realized_IFA]
	INNER JOIN [dbo].[map_asset_reference]
		ON [dbo].[Strolf_realized_IFA].[TRADE_REFERENCE_TEXT] = [dbo].[map_asSET_reference].[TRADE_REFERENCE_TEXT]

EXEC dbo.Write_Log 'Info', 'Update [dbo].[FilesToImport]', @Current_Procedure, NULL, NULL, @step, 1

	SET @step = 3
	
	UPDATE [dbo].[FilestoImport] 
	SET LastImport = GETDATE()
	WHERE id = @FileID

EXEC dbo.Write_Log 'Info', 'Finished final import of realised IFA data from Strolf', @Current_Procedure, NULL, NULL, @step, 1

END TRY

BEGIN CATCH
	--INSERT INTO [dbo].[Logfile] SELECT 'ERROR-OCCURED', @TimeStamp
	EXEC [dbo].[usp_GetErrorInfo] @Current_Procedure, @step
END CATCH

GO

