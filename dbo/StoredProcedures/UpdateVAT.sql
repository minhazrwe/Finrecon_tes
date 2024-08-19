

	CREATE PROCEDURE [dbo].[UpdateVAT] 
	AS
	BEGIN TRY
	
	-- define some variables that are needed
	DECLARE @LogInfo Integer
	DECLARE @step Integer
	DECLARE @proc nvarchar(40)
		
	select @proc =  Object_Name(@@PROCID)

	select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

	--log the start of the proc
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ' - START', GETDATE () END

	--empty table as peparation
	select @step = @step + 1
	delete from [dbo].[Recon_VAT]

	--fill Recon table form view base recon update view
	-- in the view is the logic
	select @step = @step + 1
	insert into [dbo].[Recon_VAT] ( Source, DealID, DeliveryMonth, CashflowType, CounterpartyGroup, [SOLL_VAT], [SOLL_Account] )
	select Source, DealID, DeliveryMonth, CashflowType, CounterpartyGroup, [SOLL_VAT], [SOLL_Account]
	from [dbo].[base_recon_update_VAT]

	--and finally update the table
	select @step = @step + 1
	UPDATE [dbo].[Recon_zw1] 
		SET [dbo].[Recon_zw1].[VAT_Script]  = [dbo].[Recon_VAT].[SOLL_VAT],
		    [dbo].[Recon_zw1].[Account_Endur]  = [dbo].[Recon_VAT].[SOLL_Account]
		from 
			[dbo].[Recon_zw1] INNER JOIN [dbo].[Recon_VAT]
			ON ([dbo].[Recon_zw1].[Source] = [dbo].[Recon_VAT].[Source]) 
			AND ([dbo].[Recon_zw1].[CashflowType] = [dbo].[Recon_VAT].[CashflowType]) 
			AND ([dbo].[Recon_zw1].[DeliveryMonth] = [dbo].[Recon_VAT].[DeliveryMonth] ) 
			AND ([dbo].[Recon_zw1].[DealID] =[dbo].[Recon_VAT].[DealID])

		if @LogInfo >= 1 BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ' - FINISHED', GETDATE () END
END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step		
		BEGIN insert into [dbo].[Logfile] select @proc + ' - FAILED', GETDATE () END
	END CATCH

GO

