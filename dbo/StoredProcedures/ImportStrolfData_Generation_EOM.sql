








	CREATE PROCEDURE [dbo].[ImportStrolfData_Generation_EOM] 
	AS
	BEGIN TRY

	DECLARE @proc nvarchar(40)
	DECLARE @step Integer
	DECLARE @LogInfo Integer
	DECLARE @MAX_COB Date

	select @step = 1

	-- we need the LogInfo for Logging
	select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

	select @proc = '[dbo].[ImportStrolfDataGeneration_EOM]'

	select @step = @step + 1
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import Strolf Data Generation EOM - Start Import Strolf Generation EOM', GETDATE () END

	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import Strolf Data Generation - fill [dbo].[Strolf_ROM_POS_BENE_EOM]', GETDATE () END

		truncate table [dbo].[Strolf_ROM_POS_BENE_EOM]

		SELECT @MAX_COB = max(cob) from [ROCKCAO_CE].[CAO_CE].[XPORT].[FIN_ROM_POS_BENE] 

		select @step = @step + 1
		insert into [dbo].[Strolf_ROM_POS_BENE_EOM] ([COB],[DELIVERY_MONTH],[POWER_NL],[POWER_BE],[CO2_BENE],[COAL_NL],[GAS_BENE])
		select [COB],[DELIVERY_MONTH],[POWER_NL],[POWER_BE],[CO2_BENE],[COAL_NL],[GAS_BENE] from [ROCKCAO_CE].[CAO_CE].[XPORT].[FIN_ROM_POS_BENE] 
		where [COB] = @MAX_COB

	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import Strolf Data Generation - fill [dbo].[Strolf_ROM_POS_DE_EOM]', GETDATE () END

		truncate table [dbo].[Strolf_ROM_POS_DE_EOM]

		SELECT @MAX_COB = max(cob) from [ROCKCAO_CE].[CAO_CE].[XPORT].[FIN_ROM_POS_DE] 

		select @step = @step + 1
		insert into [dbo].[Strolf_ROM_POS_DE_EOM] ([COB],[DELIVERY_MONTH],[POWER_DE],[CO2_DE],[COAL_DE],[GAS_DE])
		select [COB],[DELIVERY_MONTH],[POWER_DE],[CO2_DE],[COAL_DE],[GAS_DE] from [ROCKCAO_CE].[CAO_CE].[XPORT].[FIN_ROM_POS_DE]
		where [COB] = @MAX_COB


	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import Strolf Data Generation - fill Strolf_BMT_ROM_POS', GETDATE () END

		truncate table [dbo].[Strolf_BMT_ROM_POS]

		SELECT @MAX_COB = max(cob) from [ROCKCAO_CE].[CAO_CE].[XPORT].[FIN_BMT_ROM_POS] 
	
		select @step = @step + 1
		insert into  [dbo].[Strolf_BMT_ROM_POS]([COB] ,[MONTH] ,[Position] ,[Position_Type],[Commodity] )
		SELECT [COB]      ,[MONTH]      ,[Value]      ,[POSITION_TYPE]      ,[COMMODITY]  FROM [ROCKCAO_CE].[CAO_CE].[XPORT].[FIN_BMT_ROM_POS] 
		where [COB] = @MAX_COB
	
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import Strolf Data Generation EOM - Import Strolf Data Generation EOM has finished', GETDATE () END

END TRY

	BEGIN CATCH
		--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
	END CATCH

GO

