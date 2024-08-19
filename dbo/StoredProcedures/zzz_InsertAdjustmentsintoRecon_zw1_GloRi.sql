




	CREATE PROCEDURE [dbo].[zzz_InsertAdjustmentsintoRecon_zw1_GloRi] 
	AS
	BEGIN TRY
	
	-- define some variables that been needed
	DECLARE @LogInfo Integer

	select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'RealisedRecon - InsertAdjustmentsintoRecon_zw1', GETDATE () END

	INSERT INTO Recon_zw1 
		( [Source], InternalLegalEntity, ReconGroup, OrderNo, DeliveryMonth, DealID_Recon, DealID,  Account_Endur, ccy, DeskCcy,
		Volume_Adj, realised_ccy_adj, realised_deskccy_adj, realised_EUR_adj, Adj_Category, Adj_Comment, [ExternalBusinessUnit], [Partner],[VAT_Script] )
	SELECT 
		'adj' AS src, 
		left([dbo].[00_map_order].[LegalEntity],100), 
		[dbo].[Adjustments].[ReconGroup], 
		[dbo].[Adjustments].[OrderNO], 
		[dbo].[Adjustments].[DeliveryMonth], 
		left([dbo].[Adjustments].[DealID],50), 
		left([Adjustments].[DealID],50),  
		left([dbo].[Adjustments].[Account],20), 
		left([dbo].[Adjustments].[Currency],5), 
		left([dbo].[00_map_order].[SubDeskCCY],5),
		[dbo].[udf_NZ_FLOAT]([dbo].[Adjustments].[Quantity]), 
		[dbo].[udf_NZ_FLOAT]([dbo].[Adjustments].[Realised_CCY]), 
		[dbo].[udf_NZ_FLOAT]([dbo].[Adjustments].[Realised_CCY]/fx1.raterisk*fx2.raterisk), 
		[dbo].[udf_NZ_FLOAT]([dbo].[Adjustments].[Realised_CCY]/FX1.RateRisk), 
		[dbo].[Adjustments].[Category], [dbo].[Adjustments].[Comment],
		left([dbo].[Adjustments].[ExternalBusinessUnit],100), 
		left([dbo].[Adjustments].[Partner],20),
		left([dbo].[Adjustments].[VAT],20)
	FROM ((([dbo].[Adjustments] 
		LEFT JOIN [dbo].[00_map_order] ON [dbo].[Adjustments].[OrderNo] = [dbo].[00_map_order].[OrderNo])
		LEFT JOIN dbo.fxrates fx1 ON dbo.Adjustments.currency = fx1.currency)
		LEFT JOIN dbo.fxrates fx2 ON dbo.[00_map_order].SubDeskCCY = fx2.currency)


	WHERE ((([dbo].[Adjustments].[Valid_From]) <= (select [AsOfDate_EOM] from [dbo].[AsOfDate])) 
		AND (([dbo].[Adjustments].[Valid_To]) >= (select [AsOfDate_EOM] from [dbo].[AsOfDate])))



END TRY

	BEGIN CATCH
		--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
		EXEC [dbo].[usp_GetErrorInfo] '[dbo].[InsertAdjustmentsintoRecon_zw1]', 1
	END CATCH

GO

