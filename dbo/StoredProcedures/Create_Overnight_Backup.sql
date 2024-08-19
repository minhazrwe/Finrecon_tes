



	
	CREATE procedure [dbo].[Create_Overnight_Backup]
	as
	BEGIN TRY

		DECLARE @Current_Procedure nvarchar(50)
		DECLARE @step int

		SET @step = 1

		SELECT @Current_Procedure = Object_Name(@@PROCID)

		EXEC dbo.Write_Log 'Info', 'START', @Current_Procedure, NULL, NULL, @step, 1
		SET @step = 2
		exec dbo.AutoBackup '[dbo].[Adjustments]'

		SET @step = 3
		exec dbo.AutoBackup '[dbo].[map_order]'
		
		EXEC dbo.Write_Log 'Info', 'FINISHED', @Current_Procedure, NULL, NULL, @step, 1

	END TRY

		BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @Current_Procedure, ''		
		EXEC dbo.Write_Log 'ERROR', 'FAILED', @Current_Procedure, NULL, NULL, @step, 1
	END CATCH

GO

