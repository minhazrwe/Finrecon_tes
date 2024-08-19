
/*=================================================================================================================
	author:		unknown
	created:	ancient times
	purpose:	fills table "recon", executed a.o. during procedures "ImportFASTrackerData" and "Reconciliation"
-----------------------------------------------------------------------------------------------------------------
	Changes:
	when, who, step, what (why)	
=================================================================================================================*/



	CREATE PROCEDURE [dbo].[InsertIntoRecon] 
	AS
	BEGIN TRY
	
		DECLARE @LogInfo Integer
		DECLARE @step Integer
		DECLARE @proc varchar(40)
		DECLARE @COB as date
		
		SELECT @proc = Object_Name(@@PROCID)

		select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - '+ @proc + ' - START' , GETDATE () END
		
		select @step=1
		INSERT INTO Recon 
		( 
			Identifier
			,InternalLegalEntity
			,ReconGroup
			,Desk
			,SubDesk
			,RevRecSubDesk
			,OrderNo
			,DeliveryMonth
			,DealID_Recon
			,DealID
			,Portfolio
			,Portfolio_ID
			,CounterpartyGroup 
			,InstrumentType
			,ProjIndexGroup
			,CurveName
			,ExternalLegal
			,ExternalBusinessUnit 
			,ExternalPortfolio
			,TradeDate
			,EventDate
			,SAP_DocumentNumber
			,Volume_Endur 
			,Volume_SAP
			,Volume_Adj
			,UOM_Endur
			,UOM_SAP
			,realised_ccy_Endur 
			,realised_ccy_SAP
			,realised_ccy_adj
			,ccy
			,realised_Deskccy_Endur 
			,realised_Deskccy_SAP
			,realised_Deskccy_adj
			,Deskccy
			,realised_EUR_Endur
			,realised_EUR_SAP
			,realised_EUR_SAP_conv 
			,realised_EUR_adj
			,Account_Endur
			,Account_SAP
			,diff_Volume
			,Diff_Realised_EUR
			,Diff_Realised_DeskCCY
			,Diff_Realised_CCY 
			,InternalBusinessUnit
			,DocumentNumber
			,Reference
			,TranStatus
			,[Action]
			,CashflowType 
			,Account
			,Adj_Category
			,Adj_Comment
			,[Partner]
			,VAT_Script
			,VAT_SAP
			,VAT_CountryCode
			,Material
		)
	SELECT 
		Identifier
		,InternalLegalEntity
		,ReconGroup
		,Desk
		,SubDesk
		,RevRecSubDesk
		,OrderNo
		,DeliveryMonth
		,DealID_Recon
		,DealID
		,Portfolio
		,Portfolio_ID
		,CounterpartyGroup		 
		,InstrumentType
		,ProjIndexGroup
		,CurveName
		,ExternalLegal
		,ExternalBusinessUnit 
		,ExternalPortfolio
		,TradeDate
		,EventDate
		,SAP_DocumentNumber
		,Volume_Endur
		,Volume_SAP
		,Volume_Adj
		,UOM_Endur
		,UOM_SAP
		,realised_ccy_Endur
		,realised_ccy_SAP
		,realised_ccy_adj
		,ccy
		,realised_Deskccy_Endur
		,realised_Deskccy_SAP
		,realised_Deskccy_adj
		,Deskccy
		,realised_EUR_Endur
		,realised_EUR_SAP
		,realised_EUR_SAP_conv
		,realised_EUR_adj
		,Account_Endur
		,Account_SAP
		,diff_Volume
		,Diff_Realised_EUR
		,Diff_Realised_DeskCCY
		,Diff_Realised_CCY
		,InternalBusinessUnit
		,DocumentNumber
		,Reference
		,TranStatus
		,[Action]
		,CashflowType 
		,Account
		,Adj_Category
		,Adj_Comment
		,[Partner]
		,VAT_Script
		,VAT_SAP
		,VAT_CountryCode
		,Material
	from 
		[dbo].[base_Recon] 

	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - '+ @proc + ' - FINISHED' , GETDATE () END

END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step		
		BEGIN INSERT INTO [dbo].[Logfile] SELECT 'Reconciliation - ' + @proc + ' - FAILED', GETDATE () END
	END CATCH

GO

