


	CREATE PROCEDURE [dbo].[UpdateEndurAccounts] 
	AS
	BEGIN TRY
	
	-- define some variables that been needed
	DECLARE @LogInfo Integer
	DECLARE @step Integer
	DECLARE @proc nvarchar(40)
		
	select @proc =  Object_Name(@@PROCID)

	select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ' - START', GETDATE () END

	select @step = 10
	delete from [dbo].[Recon_EndurAccount]


	select @step = 20
	insert into [dbo].[Recon_EndurAccount](	[OrderNo],[DeliveryMonth],[DealID_Recon],[diff_ccy],
		[Volume],[Endur],[SAP],[check],[AnzahlvonReconGroup],[Summevonrealised_ccy_Endur],
		[Summevonrealised_ccy_SAP],[ReconGroup],[ABS])
	select 
		[OrderNo],[DeliveryMonth],[DealID_Recon],[diff_ccy],
		[Volume],[Endur],[SAP],[check],[AnzahlvonReconGroup],[Summevonrealised_ccy_Endur],
		[Summevonrealised_ccy_SAP],[ReconGroup],[ABS]
	from [dbo].[base_recon_update_Endur]

	
	select @step = 30
	Update [dbo].[Recon_zw1] 
		SET [Account_Endur] = [dbo].[Recon_EndurAccount].[SAP]
		from 
			dbo.Recon_zw1 
			INNER JOIN [dbo].[Recon_EndurAccount] 
				ON [dbo].[Recon_zw1].[DealID_Recon] = [dbo].[Recon_EndurAccount].[DealID_Recon] 
				AND [dbo].[Recon_zw1].[DeliveryMonth] = [dbo].[Recon_EndurAccount].[DeliveryMonth] 
				AND [dbo].[Recon_zw1].[OrderNo] = [dbo].[Recon_EndurAccount].[OrderNo]
				AND [dbo].[Recon_zw1].[ReconGroup] = [dbo].[Recon_EndurAccount].[ReconGroup]
			INNER JOIN [dbo].[map_ReconGroupAccount] 
				ON [dbo].[Recon_EndurAccount].[SAP] = [dbo].[map_ReconGroupAccount].[Account] 
		WHERE 
			[dbo].[Recon_zw1].[Account_SAP] Is Null 
			AND [dbo].[Recon_zw1].[Source] = 'realised_script'


		if @LogInfo >= 1 BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ' - FINISHED', GETDATE () END
END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step		
		BEGIN insert into [dbo].[Logfile] select @proc + ' - FAILED', GETDATE () END
	END CATCH

GO

