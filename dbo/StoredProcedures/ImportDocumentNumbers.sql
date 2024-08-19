
/* ==========================================================================================================
author:		unknown
created:	unknown 
purpose:	Inserts data from a csv file, based on the entries in Table dbo.ImportFiles, 
					for the passed @ImportType e.g. Endur	which would import data into Table EndurImport.
					Calls: only the ssis-package for import
-------------------------------------------------------------------------------------------------------------
changes: when, who, step, what, (why)

=============================================================================================================*/
	CREATE PROCEDURE [dbo].[ImportDocumentNumbers] 

	AS
	BEGIN TRY
		-- define some variables that been needed
		DECLARE @package nvarchar(200)
		DECLARE @CurrentServer nvarchar(200)
		DECLARE @StarterParm nvarchar(500)
		DECLARE @StarterDB nvarchar(50)
		DECLARE @FileName nvarchar (70) 
		DECLARE @PathName nvarchar (300)
		DECLARE @TimeStamp datetime
		DECLARE @LogInfo Integer
		DECLARE @proc nvarchar(40)
		DECLARE @step Integer
		DECLARE @asofdate datetime
		DECLARE @sql nvarchar (max)

		select @step = 1
		select @proc = Object_Name(@@PROCID)

		/*-- we need the LogInfo for Logging*/
		select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import Document Numbers', GETDATE () END


		select @step = 2
		/*-- select the source definitio, means where the file is located and the name of the file*/
		select @PathName = [path] from [dbo].[pathToFiles] where [source] = 'DocumentNumbers'


		select @step = 3
		/*-- select the source definitio, means where the file is located and the name of the file*/
		select @FileName = [FileName] from [dbo].[FilesToImport] where [source] = 'DocumentNumbers'

		
		select @step = 4
		select @TimeStamp = getdate()
	

		select @step = 5
		/* log the start of the procedure with the source file definitions*/
		/*--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @PathName + @FileName, @TimeStamp END*/

		
		select @step = 6
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import Document Numbers - delete from table', GETDATE () END
		delete from [dbo].[map_documentnumber]

		select @step = 7
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import Document Numbers - Starting BULK IMPORT', GETDATE () END
		select @sql = N'BULK INSERT [dbo].[map_documentnumber]  FROM '  + '''' + @pathname + @filename + ''''  + ' WITH (FIELDTERMINATOR ='','', FIRSTROW = 2, ROWTERMINATOR =''\n'')';
		execute sp_executesql @sql

		select @step = 8
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import Document Numbers - update 02_realised_all_details', GETDATE () END
		update  r 
			set r.[documentnumber] = d.[max_document_num] 
			from 
				dbo.[02_Realised_all_details] r inner join dbo.[map_documentnumber] d 
				on	r.[Deal] = d.[deal_tracking_num] 
						and convert(datetime,r.[EventDate],104) = convert(datetime,d.[event_date],104)
						and replace(r.[cashflowtype],'Interest','Settlement') = d.[cflow_type]
			where 
				r.[documentnumber] is null

		

		select @step = 9
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import Document Numbers - update 01_realised_all', GETDATE () END

		update r 
			set r.[document number] = d.[max_document_num] 
			from 
				dbo.[01_realised_all] r inner join dbo.[map_documentnumber] d 
				on	r.[Trade Deal Number] = d.[deal_tracking_num]
						and convert(datetime,r.[Cashflow Payment Date],104) = convert(datetime,d.[event_date],104)
						and replace(r.[Cashflow Type],'Interest','Settlement') = d.[cflow_type]
			where 
				r.[Document Number] is null

		
		select @step = 10
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import Document Numbers - IMPORT finished', GETDATE () END
		
		--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import CS Deal Numbers Files - IMPORT started', GETDATE () END

		--IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'map_CS_Settled_DealID_TEMP'))
		--		BEGIN 
		--			DROP TABLE [dbo].[map_CS_Settled_DealID_TEMP] 
		--		END

		--CREATE TABLE [dbo].[map_CS_Settled_DealID_TEMP](	[EndurDealID] [varchar](100) NOT NULL)

		--select @FileName = 'Finance_BespokeDE_Gas_CS_' + 
		--					convert(varchar,year(GETDATE ())) + 
		--					case when len(month(getdate())) = 1 then '0' + convert(varchar,month(getdate())) else convert(varchar,month(getdate())) end +
		--					case when len(day(getdate())) = 1 then '0' + convert(varchar,day(getdate())) else convert(varchar,day(getdate())) end + '.csv'

		--select @step = @step + 1
		--select @sql = N'BULK INSERT [dbo].[map_CS_Settled_DealID_TEMP]  FROM '  + '''' + @pathname + @filename + ''''  + ' WITH (FIELDTERMINATOR ='','', FIRSTROW = 2, ROWTERMINATOR =''\n'')';
		--execute sp_executesql @sql

		--insert into [dbo].[map_CS_Settled_DealID] (EndurDealid,Comment) select gg.EndurDealid,  'Endur ID => Gas'
		--		from ( select rr.EndurDealid from [dbo].[map_CS_Settled_DealID_TEMP] as rr except select tt.EndurDealID from [dbo].[map_CS_Settled_DealID] as tt) as gg

		--truncate Table [dbo].[map_CS_Settled_DealID_TEMP]

		--select @FileName = 'Finance_BespokeDE_Pwr_CS_' + 
		--					convert(varchar,year(GETDATE ())) + 
		--					case when len(month(getdate())) = 1 then '0' + convert(varchar,month(getdate())) else convert(varchar,month(getdate())) end +
		--					case when len(day(getdate())) = 1 then '0' + convert(varchar,day(getdate())) else convert(varchar,day(getdate())) end + '.csv'

		--select @step = @step + 1
		--select @sql = N'BULK INSERT [dbo].[map_CS_Settled_DealID_TEMP]  FROM '  + '''' + @pathname + @filename + ''''  + ' WITH (FIELDTERMINATOR ='','', FIRSTROW = 2, ROWTERMINATOR =''\n'')';
		--execute sp_executesql @sql

		--insert into [dbo].[map_CS_Settled_DealID] (EndurDealid,Comment) select gg.EndurDealid,  'Endur ID => Power'
		--		from ( select rr.EndurDealid from [dbo].[map_CS_Settled_DealID_TEMP] as rr except select tt.EndurDealID from [dbo].[map_CS_Settled_DealID] as tt) as gg

		--IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'map_CS_Settled_DealID_TEMP'))
		--		BEGIN 
		--			DROP TABLE [dbo].[map_CS_Settled_DealID_TEMP] 
		--		END

		--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import CS Deal Numbers Files - IMPORT finished', GETDATE () END


	END TRY

	BEGIN CATCH
		--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
	END CATCH

GO

