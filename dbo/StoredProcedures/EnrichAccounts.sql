



CREATE PROCEDURE [dbo].[EnrichAccounts]

AS
BEGIN TRY

		/*define variables */
		DECLARE @LogInfo Integer
		DECLARE @Current_Procedure nvarchar(100)
		DECLARE @Main_Process nvarchar(100)
		DECLARE @step Integer

		/*set identifiers for log entries*/
		SELECT @step = 1
		SELECT @Main_Process = 'MapAccounts'
		SELECT @Current_Procedure = Object_Name(@@PROCID)
		
		EXEC dbo.Write_Log 'Info', 'START', @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL
		EXEC dbo.Write_Log 'Info', 'update map konten 1', @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL
	 	
		/*update the indetifier for comparison*/
		SELECT @step = 2
		UPDATE [02_Realised_all_details] 
			SET UpdateKonten = [IntDesk] + [group] + [InstrumentType] + [Commodity] + [CashflowType]
					
		EXEC dbo.Write_Log 'Info', 'update map konten 2', @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL

		/*update to have an identifier for comparison*/
		SELECT @step = 3
		/*disable trigger to speed for mass changes*/
		ALTER TABLE dbo.map_accounts DISABLE TRIGGER [map_accounts-change-Log-update] 

		SELECT @step = 4
		UPDATE [map_accounts] 
			SET [updateKonten] = [Desk] + [ctpygroup] + [InstrumentType] + [Commodity] + [CashflowType]

		SELECT @step = 5
		/*mass changes done, enable trigger again */
		Alter Table dbo.map_accounts ENABLE TRIGGER [map_accounts-change-Log-update]  
	
		EXEC dbo.Write_Log 'Info', 'FINISHED', @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL

END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @Current_Procedure, @step, @Main_Process; 
		EXEC dbo.Write_Log 'FAILED', 'FAILED with error, details in ERROR entry', @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL;		
	END CATCH

GO

