



CREATE PROCEDURE [dbo].[Import_GloRi]

	@howgenerated varchar(255)

AS
BEGIN TRY

	-- define some variables that are needed for processing
		DECLARE @FILEPath varchar (300)
		DECLARE @LogInfo Integer
		DECLARE @counter Integer
		DECLARE @filename nvarchar (200)
		DECLARE @fileid integer
		DECLARE @source nvarchar (300)
		DECLARE @target nvarchar (300)
		DECLARE @tobeimported int
		DECLARE @importpath nvarchar (400)
		DECLARE @TimeStamp as datetime
		DECLARE @proc nvarchar (40)
		DECLARE @step integer
		DECLARE @output integer
		DECLARE @deletecounter integer

	select @step = 1
	select @proc = '[dbo].[Import]'
	-- we need the LogInfo for Logging
	select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

	select @step = @step + 1
	-- define the timestamp for the inputfiles
	select @TimeStamp = getdate ()

	select @step = @step + 1
	-- how many file will be imported; get this info out of the tables
		--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @counter, GETDATE () END
	select @counter = count(1) from [dbo].[FilestoImport] where [dbo].[FilestoImport].[ToBeImported] = 1 
		and [dbo].[FilestoImport].[Source] in ('Glori', 'Endur') 
		--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @counter, GETDATE () END

	select @step = @step + 1
	-- get the path for the files where they should be to be imported.
	select @importpath = [dbo].[PathToFiles].[Path] from [dbo].[PathToFiles] where [Source] = 'Import'

	select @step = @step + 1
	-- write info that the import starts now
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import - START', GETDATE () END

	--==================================================================================================================================================================================

	select @deletecounter = count(ID) from [dbo].[Filestoimport] where [ToBeImported] = 1 and [FileName] like '%UKNEW%'

			if @deletecounter > 0
			BEGIN
				if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import - delete all %UKNEW% deletecounter =>  ' + convert(varchar,@deletecounter), GETDATE () END

				--delete from [dbo]."RealizedCashPNL-Endur-Data" where FileId in (
				--select distinct dd.FileId from [dbo]."RealizedCashPNL-Endur-Data" as dd right join  [dbo].[FilestoImport] as gg on dd.FileId = gg.ID and gg.FileName like '%UKNEW%')

				delete from [dbo]."01_realised_all" where FileId in (
				select distinct dd.FileId from [dbo]."01_realised_all" as dd right join  [dbo].[FilestoImport] as gg on dd.FileId = gg.ID and gg.FileName like '%UKNEW%')
			END



	select @deletecounter = count(ID) from [dbo].[Filestoimport] where [ToBeImported] = 1 and [FileName] like '%DENEW1%'

			if @deletecounter > 0
			BEGIN
				if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import - delete all %DENEW1% deletecounter =>  ' + convert(varchar,@deletecounter), GETDATE () END

				--delete from [dbo]."RealizedCashPNL-Endur-Data" where FileId in (
				--select distinct dd.FileId from [dbo]."RealizedCashPNL-Endur-Data" as dd right join  [dbo].[FilestoImport] as gg on dd.FileId = gg.ID and gg.FileName like '%DENEW1%')

				delete from [dbo]."01_realised_all" where FileId in (
				select distinct dd.FileId from [dbo]."01_realised_all" as dd right join  [dbo].[FilestoImport] as gg on dd.FileId = gg.ID and gg.FileName like '%DENEW1%')
			END

	--==================================================================================================================================================================================

	select @deletecounter = count(ID) from [dbo].[Filestoimport] where [ToBeImported] = 1 and [FileName] like '%DENEW2%'

		if @deletecounter > 0
			BEGIN
				if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import - delete all %DENEW2% deletecounter  =>  ' + convert(varchar,@deletecounter), GETDATE () END

				--delete from [dbo]."RealizedCashPNL-Endur-Data" where FileId in (
				--elect distinct dd.FileId from [dbo]."RealizedCashPNL-Endur-Data" as dd right join  [dbo].[FilestoImport] as gg on dd.FileId = gg.ID and gg.FileName like '%DENEW2%')

				delete from [dbo]."01_realised_all" where FileId in (
				select distinct dd.FileId from [dbo]."01_realised_all" as dd right join  [dbo].[FilestoImport] as gg on dd.FileId = gg.ID and gg.FileName like '%DENEW2%')
			END
	--==================================================================================================================================================================================
	--==================================================================================================================================================================================

	update [dbo].[FilestoImport] set [ToBeImported] = 0 where [Source] in ('Endur') and [FileName] like '%UKNEW1%'

	--==================================================================================================================================================================================
	--==================================================================================================================================================================================

	select @step = @step + 1
	-- loop over all files that should be imported.
		while @counter > 0
		BEGIN

				select @step = @step + 1
				-- get the filename in order of appearance
					select  @filename = [FileName] 
						from ( select *, ROW_NUMBER() OVER(ORDER BY ID) AS ROW from [dbo].[FilestoImport] where [dbo].[FilestoImport].[ToBeImported] = 1 and [dbo].[FilestoImport].[Source] in ('Glori', 'Endur')) 
							as TMP where ROW = @counter

					select @step = @step + 1
				-- get the filename in order of appearance
					select  @fileid =[ID] 
						from ( select *, ROW_NUMBER() OVER(ORDER BY ID) AS ROW from [dbo].[FilestoImport] where [dbo].[FilestoImport].[ToBeImported] = 1 and [dbo].[FilestoImport].[Source] in ('Glori', 'Endur')) 
							as TMP where ROW = @counter

				select @step = @step + 1
				-- and also get the source of the file to have an individual treatment
					select @source = [Source] 
						from ( select *, ROW_NUMBER() OVER(ORDER BY ID) AS ROW from [dbo].[FilestoImport] where [dbo].[FilestoImport].[ToBeImported] = 1 and [dbo].[FilestoImport].[Source] in ('Glori', 'Endur')) 
							as TMP where ROW = @counter

				select @step = @step + 1
				-- for GloRi files that have been exported via IE from GloRi GUI
				--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @source, GETDATE () END
					if @source = 'Glori'
						BEGIN
							select @step = @step + 1
							if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @FileName, GETDATE () END
							-- just import the files from dedicated directory
							--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @FileName + @importpath + convert (varchar,@fileid), GETDATE () END
							EXEC [dbo].[ImportGloriData] @importpath, @filename, @fileid, @LogInfo, @TimeStamp, @howgenerated
						END
				-- now the treatment for the Endur files that have been renamed in the Access database that calls this import.
						IF @source = 'Endur'
							BEGIN
								select @step = @step + 1
								-- get the path where they are stored by EoD of Endur to be copied over to the import directory
								select @FILEPath = [dbo].[PathToFiles].[Path] from [dbo].[PathToFiles] where [Source] = @source
								--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @FILEPath, GETDATE () END
								select @step = @step + 1
								-- define the source of the copy process
								select @source = @FILEPath + @filename
								--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @source, GETDATE () END
								select @step = @step + 1
								-- define the target of the copy process
								select @target = @importpath + @filename
								--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @importpath + @filename, GETDATE () END
								select @step = @step + 1
								-- check if file exists
								exec master.dbo.xp_fileexist @source, @output output
								--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select convert(varchar,@output) +'++++' + @source, GETDATE () END
								IF @output = 1
									BEGIN
										if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @importpath + @filename, GETDATE () END
										select @step = @step + 1
										-- copy over the files
										exec master.dbo.xp_fileexist @target, @output output
										IF @output = 1
											BEGIN
												select @step = @step + 1
												EXEC [Master].[FileSystem].[DeleteFile] @target
											END
										select @step = @step + 1
										EXEC [Master].[FileSystem].[CopyFile] @source,  @target, 1
										select @step = @step + 1
										-- and import the files from import directory.
										EXEC [dbo].[ImportEndurData] @importpath, @filename, @fileid, @LogInfo, @TimeStamp
									END
							END
				-- counter will be decreased for the next file to be processed
		select @counter = @counter - 1
		END 
	-- give the info that the proc has been finished
		select @step = @step + 1
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import - FINISHED', GETDATE () END

END TRY

	BEGIN CATCH
		--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
		BEGIN insert into [dbo].[Logfile] select 'Import - FAILED', GETDATE () END
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
	END CATCH

GO

