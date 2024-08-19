


CREATE PROCEDURE [dbo].[COVIDUpdateVAT] 
AS
BEGIN TRY

	/*purpose:

	update of steuerkennzeichen to reflect the temporary change of VAT in Germany 
	from 19% to 16% in the timeframte July 2020 to December 2020 (mkb, 06/2020)
	*/
	
		/*define variables */
		DECLARE @LogInfo Integer
		DECLARE @proc nvarchar(40)
		DECLARE @step Integer

		select @step = 1
		SELECT @proc = Object_Name(@@PROCID)
			
		select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ' - START', GETDATE () END
	
		
		select @step = 2
		UPDATE [Recon_zw1] 
		SET VAT_Script =
			CASE 
				WHEN VAT_Script = 'A9' THEN 'A1' 
				WHEN VAT_Script = 'A2' THEN 'A5' 
				WHEN VAT_Script = 'C8' THEN 'C1' 
				WHEN VAT_Script = 'C9' THEN 'C1' 
				WHEN VAT_Script = 'O9' THEN 'O2' 
				WHEN VAT_Script = 'P4' THEN 'P6' 
				WHEN VAT_Script = 'E9' THEN 'E1' 
				WHEN VAT_Script = 'E8' THEN 'E4' 
				WHEN VAT_Script = 'V2' THEN 'L2' 
				WHEN VAT_Script = 'T9' THEN 'T1'
				WHEN VAT_Script = 'V9' THEN 'V1' 
			END,
			VAT_SAP =
			CASE 
				WHEN VAT_SAP = 'A9' THEN 'A1' 
				WHEN VAT_SAP = 'A2' THEN 'A5' 
				WHEN VAT_SAP = 'C8' THEN 'C1' 
				WHEN VAT_SAP = 'C9' THEN 'C1' 
				WHEN VAT_SAP = 'O9' THEN 'O2' 
				WHEN VAT_SAP = 'P4' THEN 'P6' 
				WHEN VAT_SAP = 'E9' THEN 'E1' 
				WHEN VAT_SAP = 'E8' THEN 'E4' 
				WHEN VAT_SAP = 'V2' THEN 'L2' 
				WHEN VAT_SAP = 'T9' THEN 'T1'
				WHEN VAT_SAP = 'V9' THEN 'V1' 
			END 
		WHERE 
			(
				VAT_Script in ('A9','A2','C8','C9','O9','P4','E9','E8','V2','T9','V9') 
				or 
				VAT_SAP in ('A9','A2','C8','C9','O9','P4','E9','E8','V2','T9','V9') 
			)
			AND
			(
				DeliveryMonth IN ('2020/07', '2020/08','2020/09','2020/10','2020/11','2020/12')	OR 
				DeliveryMonth like '%07_2020' OR
				DeliveryMonth like '%08_2020' OR 
				DeliveryMonth like '%09_2020' OR 
				DeliveryMonth like '%10_2020' OR 
				DeliveryMonth like '%11_2020' OR 
				DeliveryMonth like '%12_2020'
			)
			
			if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ' - FINISHED', GETDATE () END
END TRY
	
	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
		BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ' - FINISHED', GETDATE () END
	END CATCH

GO

