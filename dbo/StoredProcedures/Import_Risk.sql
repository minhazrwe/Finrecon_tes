




-- =============================================
-- Author:	MKB
-- Created: 2022/10
-- Purpose: calls import routines for regular data and adjustments to import data files from Risk System (currently ROCK)

-- =============================================
CREATE PROCEDURE [dbo].[Import_Risk]	

AS
BEGIN TRY

		DECLARE @proc nvarchar(40)
		DECLARE @step integer
		DECLARE @LogInfo Integer
		
		select @step = 1
		/*who are we ?*/
		SELECT @proc = Object_Name(@@PROCID)
		
		/*tell the world we've started*/ 
		IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - START', GETDATE () END

		select @step = 2

		/* check, if Logging is enabled in general*/
		select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]
		
		
		select @step = 3

		/*importing Risk_PnL FILES*/
			IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - importing Risk_PnL FILES', GETDATE () END
			EXECUTE [dbo].[Import_RiskPNL_Data] 
				
		select @step = 4

		/*importing Adjustments*/
			IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - importing Adjustments', GETDATE () END
			EXECUTE [dbo].[Import_RiskAdjustment_Data]

		
NoFurtherAction:
		/*tell the world we're done*/ 
		IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - FINISHED', GETDATE () END

END TRY
	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step		
		BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - FAILED', GETDATE () END
	END CATCH

GO

