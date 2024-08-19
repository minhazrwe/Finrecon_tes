









CREATE PROCEDURE [dbo].[InsertAdjustmentsintoRecon_zw1] 
AS
BEGIN TRY
	
	/*define some variables */
		DECLARE @LogInfo Integer
		DECLARE @step Integer
		DECLARE @proc varchar(40)
		DECLARE @COB as date
		
		SELECT @proc = Object_Name(@@PROCID)

		select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

		select @Step = 1
		select @cob = [AsOfDate_EOM] from [dbo].[AsOfDate]

		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - '+ @proc + ' - START' , GETDATE () END


		/*fx rates are used here, as these adjustments stem from accounting, not from Risk */
		select @Step = 2
		INSERT INTO Recon_zw1 
		( 
			[Source]
			, InternalLegalEntity
			, ReconGroup
			, OrderNo
			, DeliveryMonth
			, DealID_Recon
			, DealID
			, Account_Endur
			, ccy
			, DeskCcy
			, Volume_Adj
			, realised_ccy_adj
			, realised_deskccy_adj
			, realised_EUR_adj
			, Adj_Category
			, Adj_Comment
			, [ExternalBusinessUnit]
			, [ExternalPortfolio]
			, [Portfolio_ID]
			, [Partner]
			, [VAT_Script] 
		)
		SELECT 
			'adj' AS src
			,left([dbo].[00_map_order].[LegalEntity],100)
			,[dbo].[Adjustments].[ReconGroup] 
			,[dbo].[Adjustments].[OrderNO] 
			,[dbo].[Adjustments].[DeliveryMonth] 
			,RTrim(left([dbo].[Adjustments].[DealID],50))
			,RTrim(left([Adjustments].[DealID],50))  
			,left([dbo].[Adjustments].[Account],20) 
			,left([dbo].[Adjustments].[Currency],5) 
			,left([dbo].[00_map_order].[SubDeskCCY],5)
			,[dbo].[udf_NZ_FLOAT]([dbo].[Adjustments].[Quantity]) 
			,[dbo].[udf_NZ_FLOAT]([dbo].[Adjustments].[Realised_CCY]) 
			,[dbo].[udf_NZ_FLOAT]([dbo].[Adjustments].[Realised_CCY]/fx1.raterisk*fx2.raterisk) 
			,[dbo].[udf_NZ_FLOAT]([dbo].[Adjustments].[Realised_CCY]/FX1.RateRisk) 
			,[dbo].[Adjustments].[Category]
			,[dbo].[Adjustments].[Comment]
			,left([dbo].[Adjustments].[ExternalBusinessUnit],100)
			,[dbo].[Adjustments].[External_Portfolio]
			,[dbo].[Adjustments].[Internal_Portfolio_ID]
			,left([dbo].[Adjustments].[Partner],20)
			,left([dbo].[Adjustments].[VAT],20)
	FROM 
		(
			(
				(
					[dbo].[Adjustments] 
					LEFT JOIN [dbo].[00_map_order] ON [dbo].[Adjustments].[OrderNo] = [dbo].[00_map_order].[OrderNo]
				)
				LEFT JOIN dbo.fxrates fx1 ON dbo.Adjustments.currency = fx1.currency
			)
			LEFT JOIN dbo.fxrates fx2 ON dbo.[00_map_order].SubDeskCCY = fx2.currency
		)
		WHERE 
			[dbo].[Adjustments].[Valid_From] <= @cob 
			AND [dbo].[Adjustments].[Valid_To] >= @cob


	/*adding Portfolio enrichment via portfolio ID for SAP 2024-02-16, MK*/
	select @Step = 3
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ' - update PortfolioID for adjustments', GETDATE () END

	UPDATE [dbo].[recon_zw1]
	SET [dbo].[recon_zw1].[Portfolio] = dbo.[00_map_order_PortfolioID].MaxvonPortfolio
	from [dbo].[recon_zw1] 
	left join dbo.[00_map_order_PortfolioID] on
	dbo.Recon_zw1.Portfolio_ID = dbo.[00_map_order_PortfolioID].PortfolioID
	where recon_zw1.Source in ('adj')


	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - '+ @proc + ' - FINISHED' , GETDATE () END

END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step		
		BEGIN INSERT INTO [dbo].[Logfile] SELECT 'Reconciliation - ' + @proc + ' - FAILED', GETDATE () END
	END CATCH

GO

