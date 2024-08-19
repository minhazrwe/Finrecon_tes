
/* 
 =============================================
 Author:      MKB
 Created:     2024/08
 Description:	Archiving unrealised_data
 ---------------------------------------------
 updates:  (when, who, step, what)
 2024-08-00, mkb,  all, initial setup of procedure
==============================================
*/
CREATE PROCEDURE [dbo].[Archive_Unrealised]
AS
BEGIN TRY

	DECLARE @Current_Procedure nvarchar(50)
	DECLARE @step Integer
	DECLARE @COB as date
	
	DECLARE	@RecordCount1 Integer
	DECLARE @RecordCount2 Integer
	DECLARE @RecordCount3 Integer
	DECLARE @Main_Process varchar(20)
	DECLARE @Log_Entry varchar(200) 
	

		SET @step = 10
		SET @Current_Procedure = Object_Name(@@PROCID)
		SET @Main_Process = 'Archiving'
		
		EXEC dbo.Write_Log 'Info', 'START', @Current_Procedure, @Main_Process, NULL, @step, 0 , NULL	
		
		SET @step = 20
		SELECT @COB = AsOfDate_EOM from dbo.AsOfDate
		
		SET @step = 30
		SET @Log_Entry = 'delete potential existing data for same month from archive'
		EXEC dbo.Write_Log 'Info', @Log_Entry , @Current_Procedure, @Main_Process, NULL, @step, 0 , NULL	

		DELETE FROM dbo.table_unrealised_02_archive WHERE COB = @COB

		
		SET @step = 40
		SET @Log_Entry = 'copy data to archive table.'
		EXEC dbo.Write_Log 'Info', @Log_Entry , @Current_Procedure, @Main_Process, NULL, @step, 0 , NULL	
	
		INSERT INTO dbo.table_unrealised_02_archive
		(
			 [ID]
			,[COB]
			,[Deal_Number]
			,[Trade_Date]
			,[Term_Start]
			,[Term_End]
			,[Internal_Legal_Entity]
			,[Desk_Name]
			,[Desk_ID]
			,[Desk_CCY]
			,[SubDesk]
			,[RevRec_SubDesk]
			,[Book_Name]
			,[Book_ID]
			,[Internal_Portfolio]
			,[Portfolio_ID]
			,[Instrument_Type]
			,[Unit_of_Measure]
			,[External_Legal_Entity]
			,[External_Business_Unit]
			,[External_Portfolio]
			,[Projection_Index_Name]
			,[Projection_Index_Group]
			,[Product_Name]
			,[Adjustment_ID]
			,[Cashflow_Payment_Date]
			,[LegEndDate]
			,[Delivery_Date]
			,[Delivery_Month]
			,[Trade_Price]
			,[Cashflow_Type]
			,[Cashflow_Type_ID]
			,[Contract_Name]
			,[Unit_Of_Account]
			,[ShortTerm_LongTerm]
			,[Accounting_Delivery_Month]
			,[Counterparty_Group]
			,[Order_Number]
			,[Partner_Code]
			,[Active_Period]
			,[Buy_Sell]
			,[Orig_Month]
			,[Target_Month]
			,[Accounting_Treatment]
			,[Volume]
			,[Volume_Avaliable]
			,[Volume_Used]
			,[Hedge_ID]
			,[Hedge_Quote]
			,[Product_ticker]
			,[RACE_Position]
			,[Commodity_Type]
			,[Balance_Sheet_Account]
			,[PNL_OCI_Account]
			,[Cashflow_CCY]
			,[Accounting_Comment]
			,[Adjustment_Comment]
			,[Adjustment_Category]
			,[Unrealised_Discounted_BU_CCY]
			,[Realised_Discounted_BU_CCY]
			,[Unrealised_Discounted_CF_CCY]
			,[Realised_Discounted_CF_CCY]
			,[Total_Discounted_BU_CCY]
			,[Total_Accounting_Discounted_BU_CCY]
			,[Total_Discounted_CF_CCY]
			,[Total_Accounting_Discounted_CF_CCY]
			,[Total_Accounting_Discounted_CF_CCY_SAP_EUR]
			,[FX_Rate_CF_CCY_EUR]
			,[FileID]
			,[DataSource]
			,[UserName]
			,[Last_Update]
		)
		SELECT
			 [ID]
			,[COB]
			,[Deal_Number]
			,[Trade_Date]
			,[Term_Start]
			,[Term_End]
			,[Internal_Legal_Entity]
			,[Desk_Name]
			,[Desk_ID]
			,[Desk_CCY]
			,[SubDesk]
			,[RevRec_SubDesk]
			,[Book_Name]
			,[Book_ID]
			,[Internal_Portfolio]
			,[Portfolio_ID]
			,[Instrument_Type]
			,[Unit_of_Measure]
			,[External_Legal_Entity]
			,[External_Business_Unit]
			,[External_Portfolio]
			,[Projection_Index_Name]
			,[Projection_Index_Group]
			,[Product_Name]
			,[Adjustment_ID]
			,[Cashflow_Payment_Date]
			,[LegEndDate]
			,[Delivery_Date]
			,[Delivery_Month]
			,[Trade_Price]
			,[Cashflow_Type]
			,[Cashflow_Type_ID]
			,[Contract_Name]
			,[Unit_Of_Account]
			,[ShortTerm_LongTerm]
			,[Accounting_Delivery_Month]
			,[Counterparty_Group]
			,[Order_Number]
			,[Partner_Code]
			,[Active_Period]
			,[Buy_Sell]
			,[Orig_Month]
			,[Target_Month]
			,[Accounting_Treatment]
			,[Volume]
			,[Volume_Avaliable]
			,[Volume_Used]
			,[Hedge_ID]
			,[Hedge_Quote]
			,[Product_ticker]
			,[RACE_Position]
			,[Commodity_Type]
			,[Balance_Sheet_Account]
			,[PNL_OCI_Account]
			,[Cashflow_CCY]
			,[Accounting_Comment]
			,[Adjustment_Comment]
			,[Adjustment_Category]
			,[Unrealised_Discounted_BU_CCY]
			,[Realised_Discounted_BU_CCY]
			,[Unrealised_Discounted_CF_CCY]
			,[Realised_Discounted_CF_CCY]
			,[Total_Discounted_BU_CCY]
			,[Total_Accounting_Discounted_BU_CCY]
			,[Total_Discounted_CF_CCY]
			,[Total_Accounting_Discounted_CF_CCY]
			,[Total_Accounting_Discounted_CF_CCY_SAP_EUR]
			,[FX_Rate_CF_CCY_EUR]
			,[FileID]
			,[DataSource]
			,[UserName]
			,[Last_Update]
		FROM 
			dbo.table_unrealised_02


		SET @step = 50
		SET @Log_Entry = 'FINISHED.'
		EXEC dbo.Write_Log 'Info', @Log_Entry , @Current_Procedure, @Main_Process, NULL, @step, 0 , NULL	


END TRY

BEGIN CATCH
	/*tell the world procedure failed*/
	EXEC [dbo].[usp_GetErrorInfo] @Current_Procedure, @step, @Main_Process; 
	EXEC dbo.Write_Log 'FAILED', 'FAILED with error, refer log for details', @Current_Procedure, @Main_Process, NULL, @step, 0 , NULL;	
	RETURN @step
END CATCH

GO

