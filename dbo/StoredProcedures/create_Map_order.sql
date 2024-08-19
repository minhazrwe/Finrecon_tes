







/* 
-- =============================================
-- Author: Markus Beckmann
-- Create date: 2024-02-10, 
-- Description: This procedure will create two map_order tables
--				It can only be executed by the technical RtwoDtwo FortyTwo User.
-- =============================================

*/
CREATE PROCEDURE [dbo].[create_Map_order]
AS
BEGIN TRY
	
	DECLARE @proc nvarchar(40)
	DECLARE @step integer
	
	select @proc = Object_Name(@@PROCID)

	--select @step= 46
	--BEGIN insert into [dbo].[Logfile] select @proc + ' - Create Table 00_map_Order and 00_map_order_PortfolioID', GETDATE () END

	--if (exists(select * from INFORMATION_SCHEMA.TABLES where [TABLE_SCHEMA] = 'dbo'and [TABLE_NAME] = '00_map_order'))
	--begin
	--	drop Table [dbo].[00_map_order]
	--end

	--select * into dbo.[00_map_order] from dbo.[view_00_map_order]

	--if (exists(select * from INFORMATION_SCHEMA.TABLES where [TABLE_SCHEMA] = 'dbo'and [TABLE_NAME] = '00_map_order_PortfolioID'))
	--begin
	--	drop Table [dbo].[00_map_order_PortfolioID]
	--end

	--select * into dbo.[00_map_order_PortfolioID] from dbo.[view_00_map_order_PortfolioID]




NoFurtherAction:
		
END TRY

BEGIN CATCH
	EXEC [dbo].[usp_GetErrorInfo] @proc
		,@step
END CATCH

GO

