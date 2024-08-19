



CREATE PROCEDURE [dbo].[Archive_map_SBM]

AS
BEGIN TRY

	DECLARE @LogInfo Integer
	DECLARE @proc nvarchar (40)
	DECLARE @step Integer

	select @step = 1
	select @proc = '[dbo].[Archive_map_SBM]'

	select @step = @step + 1
	select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

	select @step = @step + 1
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Archive_map_SBM - START', GETDATE () END

	select @step = @step + 1
	-- delete data for rerun purposes
	delete from [dbo].[map_SBM_Archive] where [dbo].[map_SBM_Archive].[AsOfDate] =(Select AsOfDate_EOM from dbo.AsOfDate)

	SET IDENTITY_INSERT [dbo].[map_SBM_Archive] ON

	select @step = @step + 1
	-- and inster the curent data
	insert into [dbo].[map_SBM_Archive] ([ID], [AsOfDate], [Subsidiary], [Strategy], [Book], [InternalPortfolio], [CounterpartyGroup],
		[InstrumentType], [ProjectionIndexGroup], [AccountingTreatment], [HedgeSTAsset], [HedgeLTAsset], [HedgeSTLiability],
		[HedgeLTLiability],[UnhedgedSTAsset], [UnhedgedLTAsset], [UnhedgedSTLiability], [UnhedgedLTLiability], [AOCI_Hedge Reserve],
		[UnrealizedEarnings], [PortfolioID],[TimeStamp], [User])
	select 
		[ID], [AsOfDate], [Subsidiary], [Strategy], [Book], [InternalPortfolio], [CounterpartyGroup],
		[InstrumentType], [ProjectionIndexGroup], [AccountingTreatment], [HedgeSTAsset], [HedgeLTAsset], [HedgeSTLiability],
		[HedgeLTLiability],[UnhedgedSTAsset], [UnhedgedLTAsset], [UnhedgedSTLiability], [UnhedgedLTLiability], [AOCI_Hedge Reserve],
		[UnrealizedEarnings], [PortfolioID],[TimeStamp], [User]
	from [dbo].[map_SBM]

	SET IDENTITY_INSERT [dbo].[map_SBM_Archive] OFF

	select @step = @step + 1
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Archive_map_SBM - FINISHED', GETDATE () END

END TRY

	BEGIN CATCH
		--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
		BEGIN insert into [dbo].[Logfile] select 'Archive_map_SBM - FAILED', GETDATE () END
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
	END CATCH

GO

