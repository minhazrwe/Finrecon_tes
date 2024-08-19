

/*
	Inserts data from a csv file, based on the entries in Table dbo.ImportFiles, for the passed @ImportType e.g. Endur
	which would import data into Table EndurImport.
	Calls:	only the ssis-package for import

	updates: 
	more speaking log entries (mkb, 2022/11/07)

*/
	CREATE PROCEDURE [dbo].[ImportGloriData] 
		@PathName nvarchar (255) ,
		@FileName nvarchar (255) ,
		@fileid integer,
		@LogInfo Integer,
		@TimeStamp Datetime,
		@howgenerated nvarchar(255)
	AS
	BEGIN TRY

	DECLARE @package varchar(200)
	DECLARE @CurrentServer varchar(200)
	DECLARE @StarterParm varchar(500)
	DECLARE @StarterDB varchar(50)
	DECLARE @result Integer
	DECLARE @proc nvarchar(40)
	DECLARE @step Integer
	DECLARE @sql nvarchar (max)
	DECLARE @Anzahl1 as integer
	DECLARE @Anzahl2 as integer

	select @step = 1
	---select @proc = '[dbo].[ImportGloriData]'
	SELECT @proc = Object_Name(@@PROCID)


	--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @FileName, GETDATE () END

		select @step = @step + 1
		delete from [dbo].[GloriImportStaging] where [FileID] = @fileid

		select @step = @step + 1
			delete from [dbo]."Realised Pnl-GloRi-Data" where [FileID] = @fileid

			if @howgenerated = 'automatic'
			BEGIN
					select @step = @step + 1
					delete from [dbo].[import-Realised Pnl-GloRi-Data-AUTOMATIC]

					select @step = @step + 1
					select @sql = N'BULK INSERT [FinRecon].[dbo].[import-Realised Pnl-GloRi-Data-AUTOMATIC]  FROM '  + '''' + @PathName + @FileName + ''''  + ' WITH (CODEPAGE = ''1252'',FIELDTERMINATOR =''~'', FIRSTROW = 2, ROWTERMINATOR =''\n'')';
					execute sp_executesql @sql
									
					if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - automatic generated file imported into tmp table: ' + @FileName, GETDATE () END


					insert into [FinRecon].[dbo]."Realised Pnl-GloRi-Data" (
						[Trade Deal Number],[Trade Reference Text],[Transaction Info Status],[Instrument Toolset Name],[Instrument Type Name],[Int Legal Entity Name],[Int Business Unit Name]
						,[Internal Portfolio Business Key],[Internal Portfolio Name],[External Portfolio Name],[Ext Business Unit Name],[Ext Legal Entity Name],[Index Name],[Trade Currency]
						,[Transaction Info Buy Sell],[Cashflow Type],[Side Pipeline Name],[Instrument Subtype Name],[Discounting Index Name],[Trade Price],[Cashflow Delivery Month],[Trade Date]
						,[Index Contract Size],[Discounting Index Contract Size],[Trade Instrument Reference Text],[Unit Name (Trade Std)],[Leg Exercise Date],[Cashflow Payment Date],[Leg End Date]
						,[Index Group],  [Delivery Vessel Name], [Static Ticket ID],[Volume],[PnL YtD Realised Undiscounted Original Currency],[PnL YtD Realised Discounted EUR]
						,[PnL YtD Realised Undiscounted EUR],[PnL YtD Realised Discounted GBP],[PnL YtD Realised Undiscounted GBP],[PnL YtD Realised Discounted USD],[PnL YtD Realised Undiscounted USD]
						,[Unrealised Discounted EUR],[Unrealised Undiscounted EUR],[Unrealised Discounted GBP],[Unrealised Undiscounted GBP],[Unrealised Discounted Original Currency]
						,[Unrealised Undiscounted Original Currency],[Unrealised Discounted USD],[Unrealised Undiscounted USD]
						,[Fileid])
					SELECT left([Trade Deal Number],100),left([Trade Reference Text],100),left([Transaction Info Status],100),left([Instrument Toolset Name],100),left([Instrument Type Name],100),left([Int Legal Entity Name],100),left([Int Business Unit Name],100)
						,left([Internal Portfolio Business Key],100),left([Internal Portfolio Name],100),left([External Portfolio Name],100),left([Ext Business Unit Name],100),left([Ext Legal Entity Name],100),left([Index Name],100),left([Trade Currency],100)
						,left([Transaction Info Buy Sell],100),left([Cashflow Type],100),left([Side Pipeline Name],100),left([Instrument Subtype Name],100),left([Discounting Index Name],100),left([Trade Price],100),left([Cashflow Delivery Month],100)
						,left([Trade Date],100),left([Index Contract Size],100),left([Discounting Index Contract Size],100),left([Trade Instrument Reference Text],100),left([Unit Name (Trade Std)],100),left([Leg Exercise Date],100),left([Cashflow Payment Date],100)
						,left([Leg End Date],100),left([Index Group],100),left([Delivery Vessel Name],50),left([Static Ticket ID],50),left([Volume],100),left([PnL YtD Realised Undiscounted Original Currency],100),left([PnL YtD Realised Discounted EUR],100)
						,left([PnL YtD Realised Undiscounted EUR],100),left([PnL YtD Realised Discounted GBP],100),left([PnL YtD Realised Undiscounted GBP],100),left([PnL YtD Realised Discounted USD],100),left([PnL YtD Realised Undiscounted USD],100)
						,left([Unrealised Discounted EUR],100),left([Unrealised Undiscounted EUR],100),left([Unrealised Discounted GBP],100),left([Unrealised Undiscounted GBP],100),left([Unrealised Discounted Original Currency],100)
						,left([Unrealised Undiscounted Original Currency],100),left([Unrealised Discounted USD],100),left([Unrealised Undiscounted USD],100),@Fileid
					FROM [FinRecon].[dbo].[import-Realised Pnl-GloRi-Data-AUTOMATIC]

					if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - automatic generated file copied Realised Pnl-GloRi-Data' + @FileName, GETDATE () END

					delete from [dbo].[import-Realised Pnl-GloRi-Data-AUTOMATIC]
			END

			if @howgenerated = ''
			BEGIN
						select @step = @step + 1
						--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select '### Starting IMPORT GLORI Proc ### => ' + convert(varchar,@fileid), GETDATE () END
						delete from [dbo].[import-Realised Pnl-GloRi-Data]
						select @step = @step + 1
						select @sql = N'BULK INSERT [FinRecon].[dbo].[import-Realised Pnl-GloRi-Data]  FROM '  + '''' + @PathName + @FileName + ''''  + ' WITH (CODEPAGE = ''1252'',FIELDTERMINATOR =''~'', FIRSTROW = 2, ROWTERMINATOR =''\n'')';
						--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @sql, GETDATE () END
						if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' -  manual generated file: ' + @FileName, GETDATE () END
						execute sp_executesql @sql

						--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'insert into "Realised Pnl-GloRi-Data"', GETDATE () END

						insert into [FinRecon].[dbo]."Realised Pnl-GloRi-Data" (
							[Trade Deal Number],[Trade Reference Text],[Transaction Info Status],[Instrument Toolset Name],[Instrument Type Name],[Int Legal Entity Name],[Int Business Unit Name]
							,[Internal Portfolio Business Key],[Internal Portfolio Name],[External Portfolio Name],[Ext Business Unit Name],[Ext Legal Entity Name],[Index Name],[Trade Currency]
							,[Transaction Info Buy Sell],[Cashflow Type],[Side Pipeline Name],[Instrument Subtype Name],[Discounting Index Name],[Trade Price],[Cashflow Delivery Month],[Trade Date]
							,[Index Contract Size],[Discounting Index Contract Size],[Trade Instrument Reference Text],[Unit Name (Trade Std)],[Leg Exercise Date],[Cashflow Payment Date],[Leg End Date]
							,[Index Group],  [Delivery Vessel Name], [Static Ticket ID],[Volume],[PnL YtD Realised Undiscounted Original Currency],[PnL YtD Realised Discounted EUR]
							,[PnL YtD Realised Undiscounted EUR],[PnL YtD Realised Discounted GBP],[PnL YtD Realised Undiscounted GBP],[PnL YtD Realised Discounted USD],[PnL YtD Realised Undiscounted USD]
							,[Unrealised Discounted EUR],[Unrealised Undiscounted EUR],[Unrealised Discounted GBP],[Unrealised Undiscounted GBP],[Unrealised Discounted Original Currency]
							,[Unrealised Undiscounted Original Currency],[Unrealised Discounted USD],[Unrealised Undiscounted USD]
							,[Fileid])
						SELECT left([Trade Deal Number],100),left([Trade Reference Text],100),left([Transaction Info Status],100),left([Instrument Toolset Name],100),left([Instrument Type Name],100),left([Int Legal Entity Name],100),left([Int Business Unit Name],100)
							,left([Internal Portfolio Business Key],100),left([Internal Portfolio Name],100),left([External Portfolio Name],100),left([Ext Business Unit Name],100),left([Ext Legal Entity Name],100),left([Index Name],100),left([Trade Currency],100)
							,left([Transaction Info Buy Sell],100),left([Cashflow Type],100),left([Side Pipeline Name],100),left([Instrument Subtype Name],100),left([Discounting Index Name],100),left([Trade Price],100),left([Cashflow Delivery Month],100)
							,left([Trade Date],100),left([Index Contract Size],100),left([Discounting Index Contract Size],100),left([Trade Instrument Reference Text],100),left([Unit Name (Trade Std)],100),left([Leg Exercise Date],100),left([Cashflow Payment Date],100)
							,left([Leg End Date],100),left([Index Group],100),left([Delivery Vessel Name],50),left([Static Ticket ID],50),left([Volume],100),left([PnL YtD Realised Undiscounted Original Currency],100),left([PnL YtD Realised Discounted EUR],100)
							,left([PnL YtD Realised Undiscounted EUR],100),left([PnL YtD Realised Discounted GBP],100),left([PnL YtD Realised Undiscounted GBP],100),left([PnL YtD Realised Discounted USD],100),left([PnL YtD Realised Undiscounted USD],100)
							,left([Unrealised Discounted EUR],100),left([Unrealised Undiscounted EUR],100),left([Unrealised Discounted GBP],100),left([Unrealised Undiscounted GBP],100),left([Unrealised Discounted Original Currency],100)
							,left([Unrealised Undiscounted Original Currency],100),left([Unrealised Discounted USD],100),left([Unrealised Undiscounted USD],100),@Fileid
						FROM [FinRecon].[dbo].[import-Realised Pnl-GloRi-Data]
						
						--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select '### delete from  [dbo].[import-Realised Pnl-GloRi-Data] ###', GETDATE () END
						delete from [dbo].[import-Realised Pnl-GloRi-Data]
			END
					 		 		
		select @step = @step + 1
		-- some extraordinary treatment
		If   @FileName = 'Realised Pnl other.txt'
		  BEGIN
	  		 select @step = @step + 1
			 -- if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'EXTRA FOR' + @FileName, GETDATE () END	 
			 UPDATE [dbo]."Realised Pnl-GloRi-Data" 
					SET [dbo]."Realised Pnl-GloRi-Data".[Unit Name (Trade Std)] = 'MWH' 
				WHERE [dbo]."Realised Pnl-GloRi-Data".[Trade Deal Number]=933285 
					AND [dbo]."Realised Pnl-GloRi-Data".[Index group]='Coal' 
						AND [dbo]."Realised Pnl-GloRi-Data".[FileID] = @fileid
						--AND [dbo]."Realised Pnl-GloRi-Data".[FileID] = 'Realised Pnl_GPG DE - Server.csv'

			select @step = @step + 1
			--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'EXTRA FOR' + @FileName, GETDATE () END
			UPDATE [dbo]."Realised Pnl-GloRi-Data" 
					SET [dbo]."Realised Pnl-GloRi-Data".[External Portfolio Name] = 'Not available', 
					[dbo]."Realised Pnl-GloRi-Data".[Ext Business Unit Name] = 'RWE GENERATION BU', 
					[dbo]."Realised Pnl-GloRi-Data".[Ext Legal Entity Name] = 'RWE GENERATION LE'
				WHERE[dbo]."Realised Pnl-GloRi-Data".[Internal Portfolio Name] ='EWO_EOS'
					AND [dbo]."Realised Pnl-GloRi-Data".[Instrument Type Name] = 'PWR-FWD-P'
						AND [dbo]."Realised Pnl-GloRi-Data".[FileID] = @fileid
						--AND [dbo]."Realised Pnl-GloRi-Data".[FileID] = 'Realised Pnl_GPG DE - Server.csv'
			END

		select @step = @step + 1
		-- insert into staging with come conversions
		--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - file before copy to GloriImportStaging ' + @FileName, GETDATE () END

		insert into [dbo].[GloriImportStaging] 
		SELECT 
				[Trade Deal Number], [Trade Reference Text], [Transaction Info Status], [Instrument Toolset Name], [Instrument Type Name], [Int Legal Entity Name]
				,[Int Business Unit Name], [Internal Portfolio Business Key], [Internal Portfolio Name], [External Portfolio Name], ltrim(rtrim([Ext Business Unit Name]))
				,[Ext Legal Entity Name], [Index Name], [Trade Currency], [Transaction Info Buy Sell], [Cashflow Type], [Side Pipeline Name], [Instrument Subtype Name]
				,[Discounting Index Name]
				,[Trade Price] = CASE [Trade Price] when '-' THEN cast('0' as float ) ELSE cast(replace([Trade Price],', ','')as float) END
				,[Cashflow Delivery Month], [Trade Date]
				,[Index Contract Size] = CASE [Index Contract Size] when '-' THEN cast('0' as float ) ELSE cast(replace([Index Contract Size],', ','')as float) END
				,[Discounting Index Contract Size]
				,[Trade Instrument Reference Text], [Unit Name (Trade Std)], [Leg Exercise Date], [Cashflow Payment Date], [Leg End Date]
				,[Index Group], [Delivery Vessel Name], [Static Ticket ID]
				,[Volume] = CASE [Volume] when '-' THEN cast('0' as float ) ELSE cast(replace(replace(replace([Volume],',',''),'(',''),')','')as float) END
				,[PnL YtD Realised Undiscounted Original Currency] = CASE [PnL YtD Realised Undiscounted Original Currency] when '-' THEN cast('0' as float ) ELSE cast(replace([PnL YtD Realised Undiscounted Original Currency],',','')as float) END
				,[PnL YtD Realised Discounted EUR] = CASE [PnL YtD Realised Discounted EUR] when '-' THEN cast('0' as float ) ELSE cast(replace([PnL YtD Realised Discounted EUR],',','')as float) END
				,[PnL YtD Realised Undiscounted EUR] = CASE [PnL YtD Realised Undiscounted EUR] when '-' THEN cast('0' as float ) ELSE cast(replace([PnL YtD Realised Undiscounted EUR],',','')as float) END
				,[PnL YtD Realised Discounted GBP] = CASE [PnL YtD Realised Discounted GBP] when '-' THEN cast('0' as float ) ELSE cast(replace([PnL YtD Realised Discounted GBP],',','')as float) END
				,[PnL YtD Realised Undiscounted GBP] = CASE [PnL YtD Realised Undiscounted GBP] when '-' THEN cast('0' as float ) ELSE cast(replace([PnL YtD Realised Undiscounted GBP],',','')as float) END
				,[PnL YtD Realised Discounted USD] = CASE [PnL YtD Realised Discounted USD] when '-' THEN cast('0' as float ) ELSE cast(replace([PnL YtD Realised Discounted USD],',','')as float) END
				,[PnL YtD Realised Undiscounted USD] = CASE [PnL YtD Realised Undiscounted USD] when '-' THEN cast('0' as float ) ELSE cast(replace([PnL YtD Realised Undiscounted USD],',','')as float) END
				,[Unrealised Discounted EUR] = CASE [Unrealised Discounted EUR] when '-' THEN cast('0' as float ) ELSE cast(replace([Unrealised Discounted EUR],',','')as float) END
				,[Unrealised Undiscounted EUR] = CASE [Unrealised Undiscounted EUR] when '-' THEN cast('0' as float ) ELSE cast(replace([Unrealised Undiscounted EUR],',','')as float) END
				,[Unrealised Discounted GBP] = CASE [Unrealised Discounted GBP] when '-' THEN cast('0' as float ) ELSE cast(replace([Unrealised Discounted GBP],',','')as float) END
				,[Unrealised Undiscounted GBP] = CASE [Unrealised Undiscounted GBP] when '-' THEN cast('0' as float ) ELSE cast(replace([Unrealised Undiscounted GBP],',','')as float) END
				,[Unrealised Discounted Original Currency] = CASE [Unrealised Discounted Original Currency] when '-' THEN cast('0' as float ) ELSE cast(replace([Unrealised Discounted Original Currency],',','')as float) END
				,[Unrealised Undiscounted Original Currency] = CASE [Unrealised Undiscounted Original Currency] when '-' THEN cast('0' as float ) ELSE cast(replace([Unrealised Undiscounted Original Currency],',','')as float) END
				,[Unrealised Discounted USD] = CASE [Unrealised Discounted USD] when '-' THEN cast('0' as float ) ELSE cast(replace([Unrealised Discounted USD],',','')as float) END
				,[Unrealised Undiscounted USD] = CASE [Unrealised Undiscounted USD] when '-' THEN cast('0' as float ) ELSE cast(replace([Unrealised Undiscounted USD],',','')as float) END
				,[FileID] 
				FROM [dbo]."Realised Pnl-GloRi-Data" where [FileID] = @fileid

				if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - file copied to GloriImportStaging ' + @FileName, GETDATE () END
				--=========================================================================================================

				--delete from [dbo]."Realised Pnl-GloRi-Data"

				if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - update [GloriImportStaging] correct special characters', GETDATE () END

				update [dbo].[GloriImportStaging] set [Ext Legal Entity Name] = replace([Ext Legal Entity Name],'Ã„','Ä') 
					where [Ext Legal Entity Name] like '%Ã„%'

				update [dbo].[GloriImportStaging] set [Ext Business Unit Name] = replace([Ext Business Unit Name],'Ã„','Ä') 
					where [Ext Business Unit Name] like '%Ã„%'
				
					--=========================================================================================================

				update [dbo].[GloriImportStaging] set [Ext Business Unit Name] = replace([Ext Business Unit Name],'Â ','') 
					where [Ext Business Unit Name] like '%Â %'

				update [dbo].[GloriImportStaging] set [Ext Legal Entity Name] = replace([Ext Legal Entity Name],'Â ','') 
					where [Ext Legal Entity Name] like '%Â %'

				--=========================================================================================================

				update [dbo].[GloriImportStaging] set [Ext Business Unit Name] = replace([Ext Business Unit Name],'Ãœ','Ü') 
					where [Ext Business Unit Name] like '%Ãœ%'

				update [dbo].[GloriImportStaging] set [Ext Legal Entity Name] = replace([Ext Legal Entity Name],'Ãœ','Ü') 
					where [Ext Legal Entity Name] like '%Ãœ%'

				--=========================================================================================================

				update [dbo].[GloriImportStaging] set [Ext Legal Entity Name] = replace([Ext Legal Entity Name],'Ã–','Ö') 
					where [Ext Legal Entity Name] like '%Ã–%'

				update [dbo].[GloriImportStaging] set [Ext Business Unit Name] = replace([Ext Legal Entity Name],'Ã–','Ö') 
					where [Ext Business Unit Name] like '%Ã–%'
				
				--=========================================================================================================

				update [dbo].[GloriImportStaging] set [Ext Legal Entity Name] = replace([Ext Legal Entity Name],'Ã‡','Ç') 
					where [Ext Legal Entity Name] like '%Ã‡%'

				update [dbo].[GloriImportStaging] set [Ext Business Unit Name] = replace([Ext Legal Entity Name],'Ã‡','Ç') 
					where [Ext Business Unit Name] like '%Ã‡%'
				
				--=========================================================================================================

				update [dbo].[GloriImportStaging] set [Ext Legal Entity Name] = replace([Ext Legal Entity Name],'Ã','Á') 
					where [Ext Legal Entity Name] like '%Ã%'

				update [dbo].[GloriImportStaging] set [Ext Business Unit Name] = replace([Ext Legal Entity Name],'Ã','Á') 
					where [Ext Business Unit Name] like '%Ã%'
				
				--=========================================================================================================

				update [dbo].[GloriImportStaging] set [Ext Legal Entity Name] = replace([Ext Legal Entity Name],'Ã“','Ó') 
					where [Ext Legal Entity Name] like '%Ã“%'

				update [dbo].[GloriImportStaging] set [Ext Business Unit Name] = replace([Ext Legal Entity Name],'Ã“','Ó') 
					where [Ext Business Unit Name] like '%Ã“%'
				
				--=========================================================================================================

				update [dbo].[GloriImportStaging] set [Ext Legal Entity Name] = replace([Ext Legal Entity Name],'Ã‘','Ñ') 
					where [Ext Legal Entity Name] like '%Ã‘%'

				update [dbo].[GloriImportStaging] set [Ext Business Unit Name] = replace([Ext Legal Entity Name],'Ã‘','Ñ') 
					where [Ext Business Unit Name] like '%Ã‘%'
				
				--=========================================================================================================

				update [dbo].[GloriImportStaging] set [Ext Legal Entity Name] = replace([Ext Legal Entity Name],'Á“','Ó') 
					where [Ext Legal Entity Name] like '%Á“%'

				update [dbo].[GloriImportStaging] set [Ext Business Unit Name] = replace([Ext Legal Entity Name],'Á“','Ó') 
					where [Ext Business Unit Name] like '%Á“%'
				
				--=========================================================================================================


		  select @step = @step + 1
		  select @Anzahl1 = count(*) from [dbo].[GloriImportStaging]
--		  if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select  @proc + ' - Anzahl vor Löschung der 0 aus [GloriImportStaging]' + convert(varchar(12),@Anzahl), GETDATE () END
	
			delete FROM [dbo].[GloriImportStaging] WHERE (((Volume)=0 Or (Volume) Is Null) 
				AND (([PnL YtD Realised Undiscounted Original Currency])=0 Or ([PnL YtD Realised Undiscounted Original Currency]) Is Null) 
				AND (([Unrealised Undiscounted Original Currency])=0 Or ([Unrealised Undiscounted Original Currency]) Is Null) 
				AND (([PnL YtD Realised Undiscounted EUR])=0 Or ([PnL YtD Realised Undiscounted EUR]) Is Null) 
				AND (([Unrealised Undiscounted EUR])=0 Or ([Unrealised Undiscounted EUR]) Is Null)) and [FileID] = @fileid
			
			select @Anzahl2 = count(*) from [dbo].[GloriImportStaging]
			if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select  @proc + ' - Anzahl vor/nach Löschung der 0 aus [GloriImportStaging]' + convert(varchar(12),@Anzahl1) + '/' + convert(varchar(12),@Anzahl2), GETDATE () END

		  select @step = @step + 1
		  delete from [dbo].[01_realised_all] where [FileID] = @fileid

		  select @step = @step + 1
		  insert into [dbo].[01_realised_all] SELECT
				[Trade Deal Number], [Trade Reference Text], [Transaction Info Status], [Instrument Toolset Name], [Instrument Type Name], [Int Legal Entity Name]
				,[Int Business Unit Name], [Internal Portfolio Business Key], [Internal Portfolio Name], [External Portfolio Name], [Ext Business Unit Name]
				,[Ext Legal Entity Name], [Index Name], [Trade Currency], [Transaction Info Buy Sell], [Cashflow Type], [Side Pipeline Name], [Instrument Subtype Name]
				,[Discounting Index Name], [Trade Price], NULL, [Cashflow Delivery Month], 
				CONVERT(datetime,case when [Trade Date] = '' or [Trade Date] = 'Dummy' or [Trade Date] = '-' then NULL else [Trade Date] end ,104), 
				[Index Contract Size]
				,[Discounting Index Contract Size], [Trade Instrument Reference Text], [Unit Name (Trade Std)],
				CONVERT(datetime,case when [Leg Exercise Date] = '' or [Leg Exercise Date] = 'Dummy' or [Leg Exercise Date] = '-' then NULL else [Leg Exercise Date] end ,104),
				CONVERT(datetime,case when [Cashflow Payment Date] = '' or [Cashflow Payment Date] = 'Dummy' or [Cashflow Payment Date] = '-' then NULL else [Cashflow Payment Date] end, 104),
				CONVERT(datetime,case when [Leg End Date] = '' or [Leg End Date] = 'Dummy' or [Leg End Date] = '-' then NULL else [Leg End Date] end ,104)
				,[Index Group],  [Delivery Vessel Name], [Static Ticket ID], '',[Volume]
				,[PnL YtD Realised Undiscounted Original Currency]+[Unrealised Undiscounted Original Currency]/*YK & MKB, 2022/08/04: warum wird hier zum realised das unrealised hinzuaddiert?*/
				,[PnL YtD Realised Undiscounted EUR]+[Unrealised Undiscounted EUR]/*YK & MKB, 2022/08/04: warum wird hier zum realised das unrealised hinzuaddiert?*/
				,[PnL YtD Realised Discounted EUR]+[Unrealised Discounted EUR]/*YK & MKB, 2022/08/04: warum wird hier zum realised das unrealised hinzuaddiert?*/
				,[PnL YtD Realised Undiscounted GBP]+[Unrealised Undiscounted GBP]/*YK & MKB, 2022/08/04: warum wird hier zum realised das unrealised hinzuaddiert?*/
				,[PnL YtD Realised Discounted GBP]+[Unrealised Discounted GBP]/*YK & MKB, 2022/08/04: warum wird hier zum realised das unrealised hinzuaddiert?*/
				,[PnL YtD Realised Undiscounted USD]+[Unrealised Undiscounted USD]/*YK & MKB, 2022/08/04: warum wird hier zum realised das unrealised hinzuaddiert?*/
				,[PnL YtD Realised Discounted USD]+[Unrealised Discounted USD]/*YK & MKB, 2022/08/04: warum wird hier zum realised das unrealised hinzuaddiert?*/
				,NULL,[FileId]
		  FROM [dbo].[GloriImportStaging] where [FileID] = @fileid

		  --=========================================================================================================

		  delete from [dbo].[GloriImportStaging]

		  update [dbo].[FilestoImport]
			SET [dbo].[FilestoImport].[LastImport] = @TimeStamp
				where [dbo].[FilestoImport].[ID] = @fileid
		
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select  @proc + ' - FINISHED', GETDATE () END

END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
		BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - FAILED', GETDATE () END
	END CATCH

GO

