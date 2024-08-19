



	CREATE PROCEDURE [dbo].[InsertIntoRecon_archive] 
	AS
	BEGIN TRY
	
	-- define some variables that been needed
	DECLARE @LogInfo Integer

	select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'RealisedRecon - InsertIntoRecon_Archive - fill Recon', GETDATE () END

INSERT INTO Recon_archive ( Identifier, InternalLegalEntity, ReconGroup, Desk, SubDesk, OrderNo, 
		DeliveryMonth, DealID_Recon, DealID, Portfolio, CounterpartyGroup, 
		InstrumentType, ProjIndexGroup, CurveName, ExternalLegal, ExternalBusinessUnit, 
		ExternalPortfolio, TradeDate, EventDate, SAP_DocumentNumber, Volume_Endur, 
		Volume_SAP, Volume_Adj, UOM_Endur, UOM_SAP, realised_ccy_Endur, 
		realised_ccy_SAP, realised_ccy_adj, ccy, realised_Deskccy_Endur, 
		realised_Deskccy_SAP, realised_Deskccy_adj, Deskccy, realised_EUR_Endur, realised_EUR_SAP, realised_EUR_SAP_conv, 
		realised_EUR_adj, Account_Endur, Account_SAP, diff_Volume, Diff_Realised_EUR, Diff_Realised_DeskCCY, Diff_Realised_CCY, 
		InternalBusinessUnit, DocumentNumber, Reference, TranStatus, [Action], CashflowType, 
		Account, Adj_Category, Adj_Comment, [Partner], VAT_Script, VAT_SAP, VAT_CountryCode,Material)
	select Identifier, InternalLegalEntity, ReconGroup, Desk, SubDesk, OrderNo, 
		DeliveryMonth, DealID_Recon, DealID, Portfolio, CounterpartyGroup, 
		InstrumentType, ProjIndexGroup, CurveName, ExternalLegal, ExternalBusinessUnit, 
		ExternalPortfolio, TradeDate, EventDate, SAP_DocumentNumber, Volume_Endur, 
		Volume_SAP, Volume_Adj, UOM_Endur, UOM_SAP, realised_ccy_Endur, 
		realised_ccy_SAP, realised_ccy_adj, ccy, realised_Deskccy_Endur, 
		realised_Deskccy_SAP, realised_Deskccy_adj, Deskccy, realised_EUR_Endur, realised_EUR_SAP, realised_EUR_SAP_conv, 
		realised_EUR_adj, Account_Endur, Account_SAP, diff_Volume, Diff_Realised_EUR, Diff_Realised_DeskCCY, Diff_Realised_CCY, 
		InternalBusinessUnit, DocumentNumber, Reference, TranStatus, [Action], CashflowType, 
		Account, Adj_Category, Adj_Comment, [Partner], VAT_Script, VAT_SAP, VAT_CountryCode,Material
	from [dbo].[base_Recon_archive] 
END TRY

	BEGIN CATCH
		--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
		EXEC [dbo].[usp_GetErrorInfo] '[dbo].[InsertIntoRecon_archive]', 1
	END CATCH

GO

