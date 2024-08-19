
/*========================================================================================
created:		2022/05, 
created by: MKB
purpose:		generate the mtm files that will get uploaded to FT
------------------------------------------------------------------------------------------
changes: (when, who, step, what/why:
2022/05, MKB, initial setup

========================================================================================*/

CREATE PROCEDURE [dbo].[FTvsROCK_ExportPreparations]
AS
BEGIN TRY

		DECLARE @proc nvarchar (50)
		DECLARE @step integer
		DECLARE @LogInfo Integer
		
		Declare @LogEntry nvarchar(100)
		Declare @Main_Process [varchar](100)
		Declare @Calling_Application [varchar](100)
		DECLARE @Session_Key NVARCHAR(100)
	
		/*Get Data from the calling application from the table_log*/
		select @Calling_Application = isnull(a.Calling_Application,''), @Session_Key = isnull(Session_Key,''), @Main_Process = isnull(Main_Process,'') from (select top 1 * from [dbo].[table_log] where [User] = [dbo].[udf_Get_Current_User]() and Time_Stamp_CET > [dbo].[udf_Get_Current_Timestamp]()-0.00005 /*ca. 6 Sec*/ ) a 
 
		select @step = 1
		select @proc = Object_Name(@@PROCID)
		 
		/* check, if Logging is globally enabled */
		select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]
		
		/* write log that import starts */
		select @step = 10
		select @LogEntry= 'START'
		EXEC dbo.Write_Log 'info',@LogEntry,@proc,@Main_Process,@Calling_Application,@step,@LogInfo,@Session_Key
		
		select @LogEntry= 'Delete old export data'
		EXEC dbo.Write_Log 'info',@LogEntry,@proc,@Main_Process,@Calling_Application,@step,@LogInfo,@Session_Key

		/*helper table with aggregated data*/
		IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' and TABLE_NAME = 'table_FTvsROCK_DifferencesAggregrated_tmp'))
		BEGIN			
		/*das hier scheint nicht richtig zu funktionieren !!!*/
			drop table dbo.table_FTvsROCK_DifferencesAggregrated_tmp
			--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc+ ' - dropped helper table table_FTvsROCK_DifferencesAggregrated_tmp', GETDATE () END
			select @LogEntry= 'Dropped helper table table_FTvsROCK_DifferencesAggregrated_tmp'
			EXEC dbo.Write_Log 'info',@LogEntry,@proc,@Main_Process,@Calling_Application,@step,@LogInfo,@Session_Key


		END
			
		/* persist data from aggregated view to speed up following queries*/
		Select @step = 20
		--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc+ ' - refill identified data', GETDATE () END
		select @LogEntry= 'Refill identified data'
		EXEC dbo.Write_Log 'info',@LogEntry,@proc,@Main_Process,@Calling_Application,@step,@LogInfo,@Session_Key

		SELECT 
			COB
			,LegalEntity
			,Desk
			,TradeDealNumber
			,InternalPortfolio
			,InstrumentType
			,TermEnd
			,Product
			,ROCK
			,FASTracker
			,DiffRounded
			,AbsDiffRounded
			,Info
		INTO 		
			dbo.table_FTvsROCK_DifferencesAggregrated_tmp
		FROM 
			dbo.view_FTvsROCK_DifferencesAggregrated

		select @step = 30
		--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - prepare data for export queries', GETDATE () END								
		select @LogEntry= 'Prepare data for export queries'
		EXEC dbo.Write_Log 'info',@LogEntry,@proc,@Main_Process,@Calling_Application,@step,@LogInfo,@Session_Key
			
		/*create temp table with potential data for mtm_file_generation to speed up trailing queries*/
		IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' and TABLE_NAME = 'table_FTvsROCK_ExportData'))
		BEGIN												
			drop table dbo.table_FTvsROCK_ExportData
			--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc+ ' - dropped helper table table_FTvsROCK_ExportData', GETDATE () END
			select @LogEntry= 'Dropped helper table table_FTvsROCK_ExportData'
			EXEC dbo.Write_Log 'info',@LogEntry,@proc,@Main_Process,@Calling_Application,@step,@LogInfo,@Session_Key
		END

		/*refill temp table*/
		select @step = 32
		SELECT 
			COB
			,TradeDealNumber
			,TermEnd
			,Sum(ROCK) AS ROCK_MtM
		INTO dbo.table_FTvsROCK_ExportData
		FROM 
			dbo.table_FTvsROCK_CombinedData
		WHERE 
			datasource = 'ROCK'
		GROUP BY 
			COB
			,TradeDealNumber
			,TermEnd
		HAVING 
			Sum(ROCK)<>0

		/*table with data to be exported*/			
		select @step = 34
		IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' and TABLE_NAME = 'table_FTvsROCK_ExportData_formatted'))
		BEGIN												
			drop table dbo.table_FTvsROCK_ExportData_formatted
			--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc+ ' - dropped  helper table', GETDATE () END
			select @LogEntry= 'Dropped helper table table_FTvsROCK_ExportData_formatted'
			EXEC dbo.Write_Log 'info',@LogEntry,@proc,@Main_Process,@Calling_Application,@step,@LogInfo,@Session_Key
		END
			
			
		/*	now run the query to create the correctly formatted mtm data that needs to get uploaded to FT (and fill it into a table to speed up the further process) */			
		Select @step = 40
		SELECT 
			dbo.table_FTvsROCK_DifferencesAggregrated_tmp.TradeDealNumber + '|' 
			+ Format(dbo.table_FTvsROCK_DifferencesAggregrated_tmp.COB,'dd/MM/yyyy') + '|'  
			+ Format(isnull(dbo.table_FTvsROCK_ExportData.Termend,dbo.table_FTvsROCK_DifferencesAggregrated_tmp.COB),'dd/MM/yyyy') + '|EUR|1.0000|' 
			+ cast(format(round(isnull(dbo.table_FTvsROCK_ExportData.ROCK_MtM,0),2),'##.##') as varchar) + '|'	
			+ cast(format(round(isnull(dbo.table_FTvsROCK_ExportData.ROCK_MTM,0),2),'##.##') as varchar) AS remove_this_header
		INTO dbo.table_FTvsROCK_ExportData_formatted
		FROM 
				dbo.table_FTvsROCK_DifferencesAggregrated_tmp 
				left join dbo.table_FTvsROCK_ExportData 
				ON table_FTvsROCK_ExportData.TradeDealNumber = dbo.table_FTvsROCK_DifferencesAggregrated_tmp.TradeDealNumber
		WHERE 
			dbo.table_FTvsROCK_DifferencesAggregrated_tmp.ROCK<>0
			AND dbo.table_FTvsROCK_DifferencesAggregrated_tmp.info Is Null

		/*cleanup*/
		Select @step = 42
		IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' and TABLE_NAME = 'table_FTvsROCK_DifferencesAggregrated_tmp'))
		BEGIN			
			drop table dbo.table_FTvsROCK_DifferencesAggregrated_tmp
			--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc+ ' - cleanup: dropped helper table again', GETDATE () END
			select @LogEntry= 'Cleanup: dropped helper table again'
			EXEC dbo.Write_Log 'info',@LogEntry,@proc,@Main_Process,@Calling_Application,@step,@LogInfo,@Session_Key

		END

		/* done with it all */			
		--IF @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc+ ' - FINISHED', GETDATE () END
		
		SELECT @LogEntry= 'FINISHED'
		EXEC dbo.Write_Log 'info',@LogEntry,@proc,@Main_Process,@Calling_Application,@step,@LogInfo,@Session_Key
		RETURN 0
			
END TRY

BEGIN CATCH
	EXEC [dbo].[usp_GetErrorInfo] @proc, @step
	--BEGIN insert into [dbo].[Logfile] select @proc+ ' - FAILED at step: ' + cast(@step as varchar), GETDATE () END
	select @LogEntry= 'FAILED at step: ' + cast(@step as varchar)
	EXEC dbo.Write_Log 'ERROR',@LogEntry,@proc,@Main_Process,@Calling_Application,@step,@LogInfo,@Session_Key
	RETURN 666
END CATCH

GO

