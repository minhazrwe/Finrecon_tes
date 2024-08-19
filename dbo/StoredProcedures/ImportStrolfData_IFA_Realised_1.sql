
/*=================================================================================================================
	Author:		MK
	Created:	2024-04-17
	Purpose:	Import IFA Realised data FROM Strolf to Finrecon. Procedure 1 is a preliminary load to get data
				INTO Finrecon and sort out mappings. Asset name needs to be isolated FROM TRADE_REFERENCE_TEXT
				free text field via mappings TABLE. Procedure 2 pushes data INTO 01_realised_all.
-----------------------------------------------------------------------------------------------------------------
	Changes:
	2024-06-04, MK, step 3, Added import of strolf_fin_deal_to_dp
=================================================================================================================*/

CREATE PROCEDURE [dbo].[ImportStrolfData_IFA_Realised_1] 
AS
BEGIN TRY

-- Vartype definition
DECLARE @Current_Procedure nvarchar(40)
DECLARE @step Integer

-- Var definition
SET @step = 1
SET @Current_Procedure = Object_Name(@@PROCID)

EXEC dbo.Write_Log 'Info', 'Started preliminary import of realised IFA data from Strolf', @Current_Procedure, NULL, NULL, @step, 1
EXEC dbo.Write_Log 'Info', 'clear [dbo].[Strolf_realized_IFA]', @Current_Procedure, NULL, NULL, @step, 1

	TRUNCATE TABLE [dbo].[Strolf_realized_IFA]

SET @step = 2
EXEC dbo.Write_Log 'Info', 'fill [dbo].[Strolf_realized_IFA]', @Current_Procedure, NULL, NULL, @step, 1

	INSERT INTO [dbo].[Strolf_realized_IFA] (COB,TRADE_DEAL_NUMBER,TRAN_STATUS,INS_TYPE_NAME,LENTITY_NAME,BUNIT_NAME,PORTFOLIO_ID,PORTFOLIO_NAME,EXT_PORTFOLIO_NAME,EXT_BUNIT_NAME,EXT_LENTITY_NAME,INDEX_NAME,TRADE_CURRENCY,TRANSACTION_INFO_BUY_SELL,CASHFLOW_TYPE,TRADE_PRICE,TRADE_DATE,TICKER,UNIT_NAME,CASHFLOW_PAYMENT_DATE,INDEX_GROUP,VOLUME,REALISED_ORIGCCY_UNDISC,REALISED_EUR_UNDISC,DELIVERY_MONTH,TRADE_REFERENCE_TEXT)
	SELECT
		COB,TRADE_DEAL_NUMBER,TRAN_STATUS,INS_TYPE_NAME,LENTITY_NAME,BUNIT_NAME,PORTFOLIO_ID,PORTFOLIO_NAME,EXT_PORTFOLIO_NAME,EXT_BUNIT_NAME,EXT_LENTITY_NAME,INDEX_NAME,TRADE_CURRENCY,TRANSACTION_INFO_BUY_SELL
		-- Cashflowtype is overwritten with custom cflowtype in order to set accounts on deal leg level (business requirement)
		,'IFA Dummy ' + CAST(DEAL_LEG AS VARCHAR) AS CASHFLOW_TYPE
		,TRADE_PRICE,TRADE_DATE,TICKER,UNIT_NAME,CASHFLOW_PAYMENT_DATE,INDEX_GROUP
		-- Set volume = 0 when Cashflowtype = 2285, otherwise volume will be double when leg is aggregated in 02.
		,IIF(CASHFLOW_TYPE = '2285', 0, VOLUME) AS VOLUME
		,REALISED_ORIGCCY_UNDISC,REALISED_EUR_UNDISC,DELIVERY_MONTH,LEFT(TRADE_REFERENCE_TEXT, 100)
	FROM [ROCKCAO_CE].[CAO_CE].[XPORT].[FIN_REALIZED_IFA]
	
EXEC dbo.Write_Log 'Info', 'Finished preliminary import of realised IFA data from Strolf. Please check mappings.', @Current_Procedure, NULL, NULL, @step, 1

-- Importing DP (=destination point) data for analysis of IFA data 
SET @step = 3
EXEC dbo.Write_Log 'Info', 'Started import of strolf_fin_deal_to_dp', @Current_Procedure, NULL, NULL, @step, 1
EXEC dbo.Write_Log 'Info', 'clear [dbo].[strolf_fin_deal_to_dp]', @Current_Procedure, NULL, NULL, @step, 1

	TRUNCATE TABLE [dbo].[strolf_fin_deal_to_dp]

SET @step = 4
EXEC dbo.Write_Log 'Info', 'fill [dbo].[strolf_fin_deal_to_dp]', @Current_Procedure, NULL, NULL, @step, 1

	INSERT INTO [dbo].[strolf_fin_deal_to_dp] ([COB],[DEAL_NUM],[DP_ID],[DP_NAME],[CITY],[TECHNOLOGY_NAME])
	SELECT	[COB],[DEAL_NUM],[DP_ID],[DP_NAME],[CITY],[TECHNOLOGY_NAME]
	FROM [ROCKCAO_CE].[CAO_CE].[XPORT].[FIN_DEAL_TO_DP]
	
EXEC dbo.Write_Log 'Info', 'Finished import of strolf_fin_deal_to_dp.', @Current_Procedure, NULL, NULL, @step, 1


END TRY

	BEGIN CATCH
		--INSERT INTO [dbo].[Logfile] SELECT 'ERROR-OCCURED', @TimeStamp
		EXEC [dbo].[usp_GetErrorInfo] @Current_Procedure, @step
	END CATCH

GO

