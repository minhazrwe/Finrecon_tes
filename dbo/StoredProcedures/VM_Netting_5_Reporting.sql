





/* 
-- =============================================
-- Author:      Martin Ulken
-- Create date: 2023-05-12, 
-- Description:   
-- This storped procedure provides data for the reports in the VM_Netting Access application
-- =============================================
*/
CREATE PROCEDURE [dbo].[VM_Netting_5_Reporting]
AS
BEGIN TRY
	DECLARE @LogInfo INTEGER
	DECLARE @proc NVARCHAR(40)
	DECLARE @step INTEGER
	
	SELECT @proc = Object_Name(@@PROCID)

	SELECT @step = 100

	SELECT @LogInfo = [dbo].[LogInfo].[LogInfo] FROM [dbo].[LogInfo]
	IF @LogInfo >= 1 BEGIN	INSERT INTO [dbo].[Logfile]	SELECT @proc + ' - START'	,GETDATE()	END

	/*Write the data in the table for the Changes in Derivatives Report for Controlling*/
	DROP TABLE [dbo].[table_VM_NETTING_5_Report_Changes_in_Derivatives]
	SELECT * INTO [dbo].[table_VM_NETTING_5_Report_Changes_in_Derivatives] FROM [dbo].[view_VM_NETTING_5_Report_Changes_in_Derivatives]
		


	SELECT @step = 999
	BEGIN INSERT INTO [dbo].[Logfile] SELECT  @proc + ' - FINISH' ,GETDATE()	END


END TRY

BEGIN CATCH
	EXEC [dbo].[usp_GetErrorInfo] @proc
		,@step
END CATCH

GO

