



CREATE PROCEDURE [dbo].[Reconciliation_archive]
AS
BEGIN TRY

	DECLARE @LogInfo Integer
	DECLARE @proc nvarchar(40)
	DECLARE @step Integer

	select @step = 1
	select @proc = '[dbo].[Reconciliation_archive]'

	select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

	truncate table [dbo].[Recon_archive]
	
	select @step = @step + 1
	EXEC [dbo].[InsertIntoRecon_archive]

	update dbo.Recon_archive
		set Recon_archive.Portfolio = o.MaxvonPortfolio
		from dbo.Recon_archive inner join  dbo.[00_map_order] o on Recon_archive.orderno = o.OrderNo
		where Recon_archive.Portfolio is null


	



END TRY

	BEGIN CATCH
		--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
	END CATCH

GO

