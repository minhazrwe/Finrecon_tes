

CREATE PROCEDURE [dbo].[Archive_FASTracker]

AS
BEGIN TRY

	DECLARE @LogInfo Integer
	DECLARE @proc nvarchar (40)
	DECLARE @step Integer
	DECLARE @timestamp as datetime

	select @step = 1
	select @proc = '[dbo].[Archive_FASTracker]'

	select @step = @step + 1
	select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

	select @timestamp = Getdate()

	select @step = @step + 1
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ArchiveFastracker - START', GETDATE () END

	select @step = @step + 1
	-- delete data for rerun purposes
	delete from [dbo].[FASTracker_Archive] where [dbo].[FASTracker_Archive].[AsOfDate] =(Select AsOfDate_EOM from dbo.AsOfDate)

	--SET IDENTITY_INSERT [dbo].[map_SBM_Archive] ON

	select @step = @step + 1
	-- and inster the curent data
	insert into [dbo].[FASTracker_Archive] ([AsofDate],[Sub ID],[ReferenceID],[Trade Date],[TermStart],[TermEnd],[InternalPortfolio],[SourceSystemBookID],[Counterparty_ExtBunit]
      ,[CounterpartyGroup],[Volume],[FixedPrice],[CurveName],[ProjIndexGroup],[InstrumentType],[UOM],[ExtLegalEntity],[ExtPortfolio], [Product]
      ,[Discounted_MTM],[Discounted_PNL],[Discounted_AOCI],[Undiscounted_MTM],[Undiscounted_PNL],[Undiscounted_AOCI],[Volume Available]
      ,[Volume Used],[TimeOfArchiving])
	select [AsofDate],[Sub ID],[ReferenceID],[Trade Date],[TermStart],[TermEnd],[InternalPortfolio],[SourceSystemBookID],[Counterparty_ExtBunit]
      ,[CounterpartyGroup],[Volume],[FixedPrice],[CurveName],[ProjIndexGroup],[InstrumentType],[UOM],[ExtLegalEntity],[ExtPortfolio], [Product]
      ,[Discounted_MTM],[Discounted_PNL],[Discounted_AOCI],[Undiscounted_MTM],[Undiscounted_PNL],[Undiscounted_AOCI],[Volume Available]
      ,[Volume Used],@timestamp from [dbo].[FASTracker]

	--SET IDENTITY_INSERT [dbo].[map_SBM_Archive] OFF

	select @step = @step + 1
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ArchiveFastracker - FINISHED', GETDATE () END

END TRY

	BEGIN CATCH
		--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
	END CATCH

GO

