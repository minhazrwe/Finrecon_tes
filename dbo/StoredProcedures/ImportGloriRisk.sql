
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	The file must have allways the name Risk PNL Adjustments.xlsx
-- updates: simplified some log entries (mkb, 2022-11-07)

-- =============================================
CREATE PROCEDURE [dbo].[ImportGloriRisk]	
		@file_name nvarchar(300),
		@path_name nvarchar(300),
		@is_adjustment nvarchar(5),
		@path_id integer
AS
BEGIN TRY

		DECLARE @proc nvarchar(40)
		DECLARE @step integer
		DECLARE @LogInfo Integer
		DECLARE @TimeStamp as Datetime
		DECLARE @sql  as nvarchar (max)
		DECLARE @fileid as integer
		DECLARE @CoBDate as datetime
		DECLARE @NumberOfDataset as integer

		select @step = 1
		--select @proc = '[dbo].[ImportGloriRisk]'
		SELECT @proc = Object_Name(@@PROCID)


		-- we need the LogInfo for Logging
		select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

		select @step = @step + 1
		-- define the timestamp for the inputfiles
		select @TimeStamp = getdate ()
		
		select @step = @step + 1
		select @CoBDate = AsOfDate_EOM from [dbo].[AsOfDate]

		select @step = @step + 1
		IF left(@file_name,20) <> 'Risk PnL Adjustments'
		BEGIN
			select @fileid = ID from [dbo].[FilesToImport] where [FileName] =  @file_name
			if right(@file_name,3) = 'txt'
			BEGIN
				select @fileid = ID from [dbo].[FilesToImport] where [FileName] like left(@file_name, len(@file_name) - 3) + '%'
			END

			if right(@file_name,3) <> 'txt'
			BEGIN
				select @fileid = ID from [dbo].[FilesToImport] where [FileName] like left(@file_name, len(@file_name) - 4) + '%'
			END
		END

		IF left(@file_name,20) = 'Risk PnL Adjustments'
		BEGIN
			select @fileid = ID from [dbo].[FilesToImport] where [FileName] like 'Risk PnL Adjustments%'
		END

		select @step = @step + 1
		/*--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportGloriRisk - Starting IMPORT Proc for GloriRisk Files --- ' 
		--+ @file_name + '---' + convert(varchar, @fileid) + '---' + @path_name + '---' + @is_adjustment + '---' + convert(varchar,@path_id) , GETDATE () END*/
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + '- START ' , GETDATE () END
		

		select @step = @step + 1
		update [dbo].[FilesToImport] set [PathId] = @path_id where [ID] = @fileid
		update [dbo].[FilesToImport] set [LastImport] = @TimeStamp where [ID] = @fileid

--		select @step = @step + 1
		-- write info that the import starts now
--		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportGloriRisk - Starting IMPORT Proc for GloriRisk / GloriRiskAdj Files', GETDATE () END
		
		select @step = @step + 1
				if (@is_adjustment = 'FALSE' or @is_adjustment = 'FALSCH')

					BEGIN
						select @step = @step + 1
						-- delete from the table where the data will be imported the previous data of the last import
						delete from dbo.[import-GloriRisk-Data]
						delete from dbo.[import-GloriRisk-Data-TXT] --neu für Dateien mit TXT hinten
						select @step = @step + 1
						delete from [dbo].[GloriRisk-Data] where [FileId] = @fileid
						select @step = @step + 1
						delete from [dbo].[GloriRisk] where [FileId] = @fileid

						select @step = @step + 1
						if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - Starting IMPORT Proc for GloriRisk Files', GETDATE () END

						select @step = @step + 1
						
						if right(@file_name,3) <> 'txt'
						BEGIN
							select @sql = N'BULK INSERT [dbo].[import-GloriRisk-Data]  FROM ' + '''' + @path_name + 'temp.csv' + '''' +   ' WITH (CODEPAGE = ''1252'', FIELDTERMINATOR ='','', FIRSTROW = 2, ROWTERMINATOR =''\n'')'
							select @step = @step + 1
							execute sp_executesql @sql

							select @step = @step + 1
							insert into [dbo].[GloriRisk-Data] ([COB],[L05 - Intermediate2 (Current Name)],[L06 - Intermediate3 (Current Name)],[L10 - Book (Current Name)],[Internal Portfolio Name],[Instrument Type Name],[Ext Business Unit Name]
							  ,[Trade Deal Number],[Cashflow Settlement Type],[Trade Instrument Reference Text],[Trade Currency],[Realised Undiscounted Original Currency],[Realised Undiscounted Original Currency GPG EOLY]
							  ,[Unrealised Discounted (EUR)],[Unrealised Discounted EUR GPG EOLY],[Realised Discounted (EUR)],[Realised Undiscounted (EUR)],[Realised Discounted EUR GPG EOLY]
							  ,[Unrealised Discounted (USD)],[Unrealised Discounted USD GPG EOLY],[Realised Discounted (USD)],[Realised Undiscounted USD],[Realised Discounted USD GPG EOLY]
							  ,[Unrealised Discounted (AUD)],[Unrealised Discounted Original Currency GPG EOLY],[Realised Discounted (AUD)],[Realised Undiscounted (AUD)],[Realised Discounted Original Currency GPG EOLY]
							  ,[Unrealised Discounted (GBP)],[Unrealised Discounted GBP GPG EOLY],[Realised Discounted (GBP)],[Realised Undiscounted (GBP)],[Realised Discounted GBP GPG EOLY],[FileId])
							SELECT [COB],[L05 - Intermediate2 (Current Name)],[L06 - Intermediate3 (Current Name)],[L10 - Book (Current Name)],[Internal Portfolio Name],[Instrument Type Name],[Ext Business Unit Name]
								  ,[Trade Deal Number],[Cashflow Settlement Type],[Trade Instrument Reference Text],[Trade Currency],[Realised Undiscounted Original Currency],[Realised Undiscounted Original Currency GPG EOLY]
								  ,[Unrealised Discounted (EUR)],[Unrealised Discounted EUR GPG EOLY],[Realised Discounted (EUR)],[Realised Undiscounted (EUR)],[Realised Discounted EUR GPG EOLY]
								  ,[Unrealised Discounted (USD)],[Unrealised Discounted USD GPG EOLY],[Realised Discounted (USD)],[Realised Undiscounted USD],[Realised Discounted USD GPG EOLY]
								  ,[Unrealised Discounted (AUD)],[Unrealised Discounted Original Currency GPG EOLY],[Realised Discounted (AUD)],[Realised Undiscounted (AUD)]
								  ,[Realised Discounted Original Currency GPG EOLY],[Unrealised Discounted (GBP)],[Unrealised Discounted GBP GPG EOLY],[Realised Discounted (GBP)]
								  ,[Realised Undiscounted (GBP)],[Realised Discounted GBP GPG EOLY], @fileid
							  FROM [FinRecon].[dbo].[import-GloriRisk-Data]
						end
						if right(@file_name,3) = 'txt'
						BEGIN
							if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportGloriRisk - Starting IMPORT Proc for GloriRisk Files => TXT - Files' +  @path_name + @file_name, GETDATE () END
							select @sql = N'BULK INSERT [dbo].[import-GloriRisk-Data-TXT]  FROM ' + '''' + @path_name + @file_name + '''' +   ' WITH (CODEPAGE = ''1252'', FIELDTERMINATOR =''~'', FIRSTROW = 2, ROWTERMINATOR =''\n'')'
							select @step = @step + 1
							execute sp_executesql @sql

							select @step = @step + 1
							insert into [dbo].[GloriRisk-Data] ([COB],[L05 - Intermediate2 (Current Name)],[L06 - Intermediate3 (Current Name)],[L10 - Book (Current Name)],[Internal Portfolio Name],[Instrument Type Name],[Ext Business Unit Name]
							  ,[Trade Deal Number],[Cashflow Settlement Type],[Trade Instrument Reference Text],[Trade Currency],[Realised Undiscounted Original Currency],[Realised Undiscounted Original Currency GPG EOLY]
							  ,[Unrealised Discounted (EUR)],[Unrealised Discounted EUR GPG EOLY],[Realised Discounted (EUR)],[Realised Undiscounted (EUR)],[Realised Discounted EUR GPG EOLY]
							  ,[Unrealised Discounted (USD)],[Unrealised Discounted USD GPG EOLY],[Realised Discounted (USD)],[Realised Undiscounted USD],[Realised Discounted USD GPG EOLY]
							  ,[Unrealised Discounted (AUD)],[Unrealised Discounted Original Currency GPG EOLY],[Realised Discounted (AUD)],[Realised Undiscounted (AUD)],[Realised Discounted Original Currency GPG EOLY]
							  ,[Unrealised Discounted (GBP)],[Unrealised Discounted GBP GPG EOLY],[Realised Discounted (GBP)],[Realised Undiscounted (GBP)],[Realised Discounted GBP GPG EOLY],[FileId])
							SELECT [COB],[L05 - Intermediate2 (Current Name)],[L06 - Intermediate3 (Current Name)],[L10 - Book (Current Name)],[Internal Portfolio Name],[Instrument Type Name],[Ext Business Unit Name]
								  ,[Trade Deal Number],[Cashflow Settlement Type],[Trade Instrument Reference Text],[Trade Currency],[Realised Undiscounted Original Currency],[Realised Undiscounted Original Currency GPG EOLY]
								  ,[Unrealised Discounted (EUR)],[Unrealised Discounted EUR GPG EOLY],[Realised Discounted (EUR)],[Realised Undiscounted (EUR)],[Realised Discounted EUR GPG EOLY]
								  ,[Unrealised Discounted (USD)],[Unrealised Discounted USD GPG EOLY],[Realised Discounted (USD)],[Realised Undiscounted USD],[Realised Discounted USD GPG EOLY]
								  ,[Unrealised Discounted (AUD)],[Unrealised Discounted Original Currency GPG EOLY],[Realised Discounted (AUD)],[Realised Undiscounted (AUD)]
								  ,[Realised Discounted Original Currency GPG EOLY],[Unrealised Discounted (GBP)],[Unrealised Discounted GBP GPG EOLY],[Realised Discounted (GBP)]
								  ,[Realised Undiscounted (GBP)],[Realised Discounted GBP GPG EOLY], @fileid
							  FROM [FinRecon].[dbo].[import-GloriRisk-Data-TXT]

						end
						
						--- Insert GloriRisk-Data into GloriRisk
						if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportGloriRisk - copy over into GloriRisk', GETDATE () END
						select @step = @step + 1
						insert into [dbo].[GloriRisk]([COB], [L05 - Intermediate2 (Current Name)], [L06 - Intermediate3 (Current Name)], [L10 - Book (Current Name)],
									[Internal Portfolio Name], [Instrument Type Name], [Ext Business Unit Name], [Trade Deal Number], [Cashflow Settlement Type], [Trade Instrument Reference Text], [Trade Currency],
									[Realised Undiscounted Original Currency], [Realised Undiscounted Original Currency GPG EOLY], [Unrealised Discounted (EUR)],
									[Unrealised Discounted EUR GPG EOLY], [Realised Discounted (EUR)], [Realised Undiscounted (EUR)], [Realised Discounted EUR GPG EOLY],
									[Unrealised Discounted (USD)], [Unrealised Discounted USD GPG EOLY], [Realised Discounted (USD)], [Realised Undiscounted USD],
									[Realised Discounted USD GPG EOLY], [Unrealised Discounted (AUD)], [Unrealised Discounted Original Currency GPG EOLY], [Realised Discounted (AUD)],
									[Realised Undiscounted (AUD)], [Realised Discounted Original Currency GPG EOLY], [Unrealised Discounted (GBP)], [Unrealised Discounted GBP GPG EOLY],
									[Realised Discounted (GBP)], [Realised Undiscounted (GBP)], [Realised Discounted GBP GPG EOLY],[FileId])
						SELECT  
							CONVERT(datetime,case when [COB] = '' then NULL else [COB] end ,104)
							,[L05 - Intermediate2 (Current Name)], [L06 - Intermediate3 (Current Name)], [L10 - Book (Current Name)], [Internal Portfolio Name]      
							,[Instrument Type Name], [Ext Business Unit Name], [Trade Deal Number], [Cashflow Settlement Type], [Trade Instrument Reference Text], [Trade Currency]
							,[Realised Undiscounted Original Currency] = 
								CASE when [Realised Undiscounted Original Currency]   like ( '%-') or  [Realised Undiscounted Original Currency]IS  NULL  
									THEN cast('0' as float ) ELSE cast(replace([Realised Undiscounted Original Currency],',','')as float) END
							,[Realised Undiscounted Original Currency GPG EOLY] = 
								CASE when [Realised Undiscounted Original Currency GPG EOLY]   like ( '%-') or  [Realised Undiscounted Original Currency GPG EOLY]IS  NULL  
									THEN cast('0' as float ) ELSE cast(replace([Realised Undiscounted Original Currency GPG EOLY],',','')as float) END
							,[Unrealised Discounted (EUR)] = 
								CASE when [Unrealised Discounted (EUR)]   like ( '%-') or  [Unrealised Discounted (EUR)]IS  NULL  
									THEN cast('0' as float ) ELSE cast(replace([Unrealised Discounted (EUR)],',','')as float) END
							,[Unrealised Discounted EUR GPG EOLY] = 
								CASE when [Unrealised Discounted EUR GPG EOLY]   like ( '%-') or  [Unrealised Discounted EUR GPG EOLY]IS  NULL  
									THEN cast('0' as float ) ELSE cast(replace([Unrealised Discounted EUR GPG EOLY],',','')as float) END
							,[Realised Discounted (EUR)] = 
								CASE when [Realised Discounted (EUR)]   like ( '%-') or  [Realised Discounted (EUR)]IS  NULL  
									THEN cast('0' as float ) ELSE cast(replace([Realised Discounted (EUR)],',','')as float) END
							,[Realised Undiscounted (EUR)] = 
								CASE when [Realised Undiscounted (EUR)]   like ( '%-') or  [Realised Undiscounted (EUR)]IS  NULL  
									THEN cast('0' as float ) ELSE cast(replace([Realised Undiscounted (EUR)],',','')as float) END
							,[Realised Discounted EUR GPG EOLY] = 
								CASE when [Realised Discounted EUR GPG EOLY]   like ( '%-') or  [Realised Discounted EUR GPG EOLY]IS  NULL  
									THEN cast('0' as float ) ELSE cast(replace([Realised Discounted EUR GPG EOLY],',','')as float) END
							,[Unrealised Discounted (USD)] = 
								CASE when [Unrealised Discounted (USD)]   like ( '%-') or  [Unrealised Discounted (USD)]IS  NULL  
									THEN cast('0' as float ) ELSE cast(replace([Unrealised Discounted (USD)],',','')as float) END
							,[Unrealised Discounted USD GPG EOLY] = 
								CASE when [Unrealised Discounted USD GPG EOLY]   like ( '%-') or  [Unrealised Discounted USD GPG EOLY]IS  NULL  
									THEN cast('0' as float ) ELSE cast(replace([Unrealised Discounted USD GPG EOLY],',','')as float) END
							,[Realised Discounted (USD)] = 
								CASE when [Realised Discounted (USD)]   like ( '%-') or  [Realised Discounted (USD)]IS  NULL  
									THEN cast('0' as float ) ELSE cast(replace([Realised Discounted (USD)],',','')as float) END
							,[Realised Undiscounted USD] = 
								CASE when [Realised Undiscounted USD]   like ( '%-') or  [Realised Undiscounted USD]IS  NULL  
									THEN cast('0' as float ) ELSE cast(replace([Realised Undiscounted USD],',','')as float) END
							,[Realised Discounted USD GPG EOLY] = 
								CASE when [Realised Discounted USD GPG EOLY]   like ( '%-') or  [Realised Discounted USD GPG EOLY]IS  NULL  
									THEN cast('0' as float ) ELSE cast(replace([Realised Discounted USD GPG EOLY],',','')as float) END
							,[Unrealised Discounted (AUD)] = 
								CASE when [Unrealised Discounted (AUD)]   like ( '%-') or  [Unrealised Discounted (AUD)]IS  NULL  
									THEN cast('0' as float ) ELSE cast(replace([Unrealised Discounted (AUD)],',','')as float) END
							,[Unrealised Discounted Original Currency GPG EOLY] = 
								CASE when [Unrealised Discounted Original Currency GPG EOLY]   like ( '%-') or  [Unrealised Discounted Original Currency GPG EOLY]IS  NULL  
									THEN cast('0' as float ) ELSE cast(replace([Unrealised Discounted Original Currency GPG EOLY],',','')as float) END
							,[Realised Discounted (AUD)] = 
								CASE when [Realised Discounted (AUD)]   like ( '%-') or  [Realised Discounted (AUD)]IS  NULL  
									THEN cast('0' as float ) ELSE cast(replace([Realised Discounted (AUD)],',','')as float) END
							,[Realised Undiscounted (AUD)] = 
								CASE when [Realised Undiscounted (AUD)]   like ( '%-') or  [Realised Undiscounted (AUD)]IS  NULL  
									THEN cast('0' as float ) ELSE cast(replace([Realised Undiscounted (AUD)],',','')as float) END
							,[Realised Discounted Original Currency GPG EOLY] = 
								CASE when [Realised Discounted Original Currency GPG EOLY]   like ( '%-') or  [Realised Discounted Original Currency GPG EOLY]IS  NULL  
									THEN cast('0' as float ) ELSE cast(replace([Realised Discounted Original Currency GPG EOLY],',','')as float) END
							,[Unrealised Discounted (GBP)] = 
								CASE when [Unrealised Discounted (GBP)]   like ( '%-') or  [Unrealised Discounted (GBP)]IS  NULL  
									THEN cast('0' as float ) ELSE cast(replace([Unrealised Discounted (GBP)],',','')as float) END
							,[Unrealised Discounted GBP GPG EOLY] = 
								CASE when [Unrealised Discounted GBP GPG EOLY]   like ( '%-') or  [Unrealised Discounted GBP GPG EOLY]IS  NULL  
									THEN cast('0' as float ) ELSE cast(replace([Unrealised Discounted GBP GPG EOLY],',','')as float) END
							,[Realised Discounted (GBP)] = 
								CASE when [Realised Discounted (GBP)]   like ( '%-') or  [Realised Discounted (GBP)]IS  NULL  
									THEN cast('0' as float ) ELSE cast(replace([Realised Discounted (GBP)],',','')as float) END
							,[Realised Undiscounted (GBP)] = 
								CASE when [Realised Undiscounted (GBP)]   like ( '%-') or  [Realised Undiscounted (GBP)]IS  NULL  
									THEN cast('0' as float ) ELSE cast(replace([Realised Undiscounted (GBP)],',','')as float) END
							,[Realised Discounted GBP GPG EOLY] = 
								CASE when [Realised Discounted GBP GPG EOLY]   like ( '%-') or  [Realised Discounted GBP GPG EOLY]IS  NULL  
									THEN cast('0' as float ) ELSE cast(replace([Realised Discounted GBP GPG EOLY],',','')as float) END
							,FileID
						FROM [dbo].[GloriRisk-Data] where FileID = @fileID

						--#############################################################################################################################################

						if @fileid = 885 

						Begin
								-- ######## update physical unrealised where leg end date <=  end of year ######## 

								BEGIN insert into [dbo].[Logfile] select 'ImportGloriRisk - update physical unrealised EOY File ID 885', GETDATE () END

								select @step = @step + 1
								UPDATE dbo.GloriRisk SET 
								[Realised Undiscounted Original Currency] = 0, [Realised Undiscounted Original Currency GPG EOLY] = 0, [Unrealised Discounted (EUR)] = 0, [Unrealised Discounted EUR GPG EOLY] = -[Unrealised Discounted EUR GPG EOLY],
								[Realised Discounted (EUR)] = 0, [Realised Undiscounted (EUR)] = 0, [Realised Discounted EUR GPG EOLY] = 0, [Unrealised Discounted (USD)] = 0, [Unrealised Discounted USD GPG EOLY] = -[Unrealised Discounted USD GPG EOLY],
								[Realised Discounted (USD)] = 0, [Realised Undiscounted USD] = 0, [Realised Discounted USD GPG EOLY] = 0, [Unrealised Discounted (AUD)] = 0, [Unrealised Discounted Original Currency GPG EOLY] = -[Unrealised Discounted Original Currency GPG EOLY],
								[Realised Discounted (AUD)] = 0, [Realised Undiscounted (AUD)] = 0, [Realised Discounted Original Currency GPG EOLY] = 0, [Unrealised Discounted (GBP)] = 0, [Unrealised Discounted GBP GPG EOLY] = -[Unrealised Discounted GBP GPG EOLY],
								[Realised Discounted (GBP)] = 0, [Realised Undiscounted (GBP)] = 0, [Realised Discounted GBP GPG EOLY] = 0 
								where fileid = 885

								-- ######## copy physical unrealised  ######## 


								BEGIN insert into [dbo].[Logfile] select 'ImportGloriRisk - insert phyiscal unrealised EOY File ID 885', GETDATE () END

								select @step = @step + 1

								Insert into dbo.GloriRisk ([COB], [L05 - Intermediate2 (Current Name)], [L06 - Intermediate3 (Current Name)], [L10 - Book (Current Name)], [Internal Portfolio Name], [Instrument Type Name], [Ext Business Unit Name],
								[Trade Deal Number], [Cashflow Settlement Type], [Trade Instrument Reference Text], [Trade Currency], [Realised Undiscounted Original Currency], [Realised Undiscounted Original Currency GPG EOLY],
								[Unrealised Discounted (EUR)], [Unrealised Discounted EUR GPG EOLY], [Realised Discounted (EUR)], [Realised Undiscounted (EUR)], [Realised Discounted EUR GPG EOLY], [Unrealised Discounted (USD)],
								[Unrealised Discounted USD GPG EOLY], [Realised Discounted (USD)], [Realised Undiscounted USD], [Realised Discounted USD GPG EOLY], [Unrealised Discounted (AUD)], [Unrealised Discounted Original Currency GPG EOLY],
								[Realised Discounted (AUD)], [Realised Undiscounted (AUD)], [Realised Discounted Original Currency GPG EOLY], [Unrealised Discounted (GBP)], [Unrealised Discounted GBP GPG EOLY], [Realised Discounted (GBP)],
								[Realised Undiscounted (GBP)], [Realised Discounted GBP GPG EOLY], [FileId])

								Select 
								[COB], [L05 - Intermediate2 (Current Name)], [L06 - Intermediate3 (Current Name)], [L10 - Book (Current Name)], [Internal Portfolio Name], [Instrument Type Name], [Ext Business Unit Name],
								[Trade Deal Number]+'_phys', [Cashflow Settlement Type], [Trade Instrument Reference Text], [Trade Currency], -[Realised Undiscounted Original Currency], -[Realised Undiscounted Original Currency GPG EOLY],
								-[Unrealised Discounted (EUR)], -[Unrealised Discounted EUR GPG EOLY], -[Realised Discounted (EUR)], -[Realised Undiscounted (EUR)], -[Realised Discounted EUR GPG EOLY], -[Unrealised Discounted (USD)],
								-[Unrealised Discounted USD GPG EOLY], -[Realised Discounted (USD)], -[Realised Undiscounted USD], -[Realised Discounted USD GPG EOLY], -[Unrealised Discounted (AUD)], -[Unrealised Discounted Original Currency GPG EOLY],
								-[Realised Discounted (AUD)], -[Realised Undiscounted (AUD)], -[Realised Discounted Original Currency GPG EOLY], -[Unrealised Discounted (GBP)], -[Unrealised Discounted GBP GPG EOLY], -[Realised Discounted (GBP)],
								-[Realised Undiscounted (GBP)], -[Realised Discounted GBP GPG EOLY], [FileId] 
								from dbo.gloririsk where fileid in (885)
						END

						--#############################################################################################################################################

						if @fileid = 886  

						Begin
								-- ######## update physical unrealised where leg end date <=  current end of month ######## 

								BEGIN insert into [dbo].[Logfile] select 'ImportGloriRisk - update physical unrealised EOM File ID 886', GETDATE () END

								select @step = @step + 1
								UPDATE dbo.GloriRisk SET 
								[Realised Undiscounted Original Currency] = 0, [Realised Undiscounted Original Currency GPG EOLY] = 0, [Unrealised Discounted (EUR)] = -[Unrealised Discounted (EUR)], [Unrealised Discounted EUR GPG EOLY] = 0,
								[Realised Discounted (EUR)] = 0, [Realised Undiscounted (EUR)] = 0, [Realised Discounted EUR GPG EOLY] = 0, [Unrealised Discounted (USD)] = -[Unrealised Discounted (USD)], [Unrealised Discounted USD GPG EOLY] = 0,
								[Realised Discounted (USD)] = 0, [Realised Undiscounted USD] = 0, [Realised Discounted USD GPG EOLY] = 0, [Unrealised Discounted (AUD)] = -[Unrealised Discounted (AUD)], [Unrealised Discounted Original Currency GPG EOLY] = 0,
								[Realised Discounted (AUD)] = 0, [Realised Undiscounted (AUD)] = 0, [Realised Discounted Original Currency GPG EOLY] = 0, [Unrealised Discounted (GBP)] = -[Unrealised Discounted (GBP)], [Unrealised Discounted GBP GPG EOLY] = 0,
								[Realised Discounted (GBP)] = 0, [Realised Undiscounted (GBP)] = 0, [Realised Discounted GBP GPG EOLY] = 0
								where fileid = 886

								-- ######## copy physical unrealised  ######## 


								BEGIN insert into [dbo].[Logfile] select 'ImportGloriRisk - insert phyiscal unrealisd EOM File ID 886', GETDATE () END

								select @step = @step + 1

								Insert into dbo.GloriRisk ([COB], [L05 - Intermediate2 (Current Name)], [L06 - Intermediate3 (Current Name)], [L10 - Book (Current Name)], [Internal Portfolio Name], [Instrument Type Name], [Ext Business Unit Name],
								[Trade Deal Number], [Cashflow Settlement Type], [Trade Instrument Reference Text], [Trade Currency],  [Realised Undiscounted Original Currency], [Realised Undiscounted Original Currency GPG EOLY],
								[Unrealised Discounted (EUR)], [Unrealised Discounted EUR GPG EOLY], [Realised Discounted (EUR)], [Realised Undiscounted (EUR)], [Realised Discounted EUR GPG EOLY], [Unrealised Discounted (USD)],
								[Unrealised Discounted USD GPG EOLY], [Realised Discounted (USD)], [Realised Undiscounted USD], [Realised Discounted USD GPG EOLY], [Unrealised Discounted (AUD)], [Unrealised Discounted Original Currency GPG EOLY],
								[Realised Discounted (AUD)], [Realised Undiscounted (AUD)], [Realised Discounted Original Currency GPG EOLY], [Unrealised Discounted (GBP)], [Unrealised Discounted GBP GPG EOLY], [Realised Discounted (GBP)],
								[Realised Undiscounted (GBP)], [Realised Discounted GBP GPG EOLY], [FileId])

								Select 
								[COB], [L05 - Intermediate2 (Current Name)], [L06 - Intermediate3 (Current Name)], [L10 - Book (Current Name)], [Internal Portfolio Name], [Instrument Type Name],[Ext Business Unit Name],
								[Trade Deal Number]+'_phys', [Cashflow Settlement Type], [Trade Instrument Reference Text], [Trade Currency],  -[Realised Undiscounted Original Currency], -[Realised Undiscounted Original Currency GPG EOLY],
								-[Unrealised Discounted (EUR)], -[Unrealised Discounted EUR GPG EOLY], -[Realised Discounted (EUR)], -[Realised Undiscounted (EUR)], -[Realised Discounted EUR GPG EOLY], -[Unrealised Discounted (USD)],
								-[Unrealised Discounted USD GPG EOLY], -[Realised Discounted (USD)], -[Realised Undiscounted USD], -[Realised Discounted USD GPG EOLY], -[Unrealised Discounted (AUD)], -[Unrealised Discounted Original Currency GPG EOLY],
								-[Realised Discounted (AUD)], -[Realised Undiscounted (AUD)], -[Realised Discounted Original Currency GPG EOLY], -[Unrealised Discounted (GBP)], -[Unrealised Discounted GBP GPG EOLY], -[Realised Discounted (GBP)],
								-[Realised Undiscounted (GBP)], -[Realised Discounted GBP GPG EOLY], [FileId]  
								from dbo.gloririsk where fileid in (886)
						END

						--#############################################################################################################################################

						if @fileid = 1944

						Begin
								-- ######## update signage for BMT ######## 

								BEGIN insert into [dbo].[Logfile] select 'ImportGloriRisk - update signage for CAO UK - BMT - File ID 1944', GETDATE () END

								select @step = @step + 1
								UPDATE dbo.GloriRisk SET 
								[Realised Undiscounted Original Currency] 	 = -[Realised Undiscounted Original Currency] , 
								[Realised Undiscounted Original Currency GPG EOLY] 	 = -[Realised Undiscounted Original Currency GPG EOLY] , 
								[Unrealised Discounted (EUR)] 	 = -[Unrealised Discounted (EUR)] , 
								[Unrealised Discounted EUR GPG EOLY] 	 = -[Unrealised Discounted EUR GPG EOLY] , 
								[Realised Discounted (EUR)] 	 = -[Realised Discounted (EUR)] , 
								[Realised Undiscounted (EUR)] 	 = -[Realised Undiscounted (EUR)] , 
								[Realised Discounted EUR GPG EOLY] 	 = -[Realised Discounted EUR GPG EOLY] , 
								[Unrealised Discounted (USD)] 	 = -[Unrealised Discounted (USD)] , 
								[Unrealised Discounted USD GPG EOLY] 	 = -[Unrealised Discounted USD GPG EOLY] , 
								[Realised Discounted (USD)] 	 = -[Realised Discounted (USD)] , 
								[Realised Undiscounted USD] 	 = -[Realised Undiscounted USD] , 
								[Realised Discounted USD GPG EOLY] 	 = -[Realised Discounted USD GPG EOLY] , 
								[Unrealised Discounted (AUD)] 	 = -[Unrealised Discounted (AUD)] , 
								[Unrealised Discounted Original Currency GPG EOLY] 	 = -[Unrealised Discounted Original Currency GPG EOLY] , 
								[Realised Discounted (AUD)] 	 = -[Realised Discounted (AUD)] , 
								[Realised Undiscounted (AUD)] 	 = -[Realised Undiscounted (AUD)] , 
								[Realised Discounted Original Currency GPG EOLY] 	 = -[Realised Discounted Original Currency GPG EOLY] , 
								[Unrealised Discounted (GBP)] 	 = -[Unrealised Discounted (GBP)] , 
								[Unrealised Discounted GBP GPG EOLY] 	 = -[Unrealised Discounted GBP GPG EOLY] , 
								[Realised Discounted (GBP)] 	 = -[Realised Discounted (GBP)] , 
								[Realised Undiscounted (GBP)] 	 = -[Realised Undiscounted (GBP)] , 
								[Realised Discounted GBP GPG EOLY] 	 = -[Realised Discounted GBP GPG EOLY]

								where fileid = 1944 and [Internal Portfolio Name] = 'CAO_UK_AOM_CSS_BMT'

								
						END

						--#############################################################################################################################################

						--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportGloriRisk - ENDING IMPORT Proc for GloriRisk Files', GETDATE () END
						
					END --- GloriRisk finished

				if (@is_adjustment = 'WAHR' or @is_adjustment = 'TRUE') and (@file_name = 'Risk PnL Adjustments.txt' or @file_name = 'Risk PnL Adjustments.XLSX')
				BEGIN

					select @step = @step + 1

					-- write info that the import starts now
					if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportGloriRisk - Starting IMPORT Proc for Adjustments', GETDATE () END

					--==============================================================================================================================================================================================
					--==============================================================================================================================================================================================
					--==============================================================================================================================================================================================
					--==============================================================================================================================================================================================
					

					--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportGloriRisk - FileID is => ' + convert(varchar,@fileid), GETDATE () END

					if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportGloriRisk - Insert file into table => [dbo].[import-GloriRiskAdj-RAW-Data]', GETDATE () END
					delete from [dbo].[import-GloriRiskAdj-Raw-Data]
					
					if @file_name = 'Risk PnL Adjustments.txt'
					BEGIN
							select @step = @step + 1
							--select @sql = N'BULK INSERT [dbo].[import-GloriRiskAdj-Raw-Data]  FROM ' + '''' + @path_name + 'temp.csv' + '''' + ' WITH (CODEPAGE = ''1252'', FIELDTERMINATOR ='','', FIRSTROW = 2, ROWTERMINATOR =''\n'')'
							if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportGloriRisk - Risk PnL Adjustments.txt', GETDATE () END
							select @sql = N'BULK INSERT [dbo].[import-GloriRiskAdj-Raw-Data]  FROM ' + '''' + @path_name + 'Risk PnL Adjustments.txt' + '''' + ' WITH (CODEPAGE = ''1252'', FIELDTERMINATOR =''~'', FIRSTROW = 2, ROWTERMINATOR =''\n'')'
							execute sp_executesql @sql
					END

					if @file_name = 'Risk PnL Adjustments.XLSX'
					BEGIN
							select @step = @step + 1
							if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportGloriRisk - Risk PnL Adjustments.XLSX', GETDATE () END
							select @sql = N'BULK INSERT [dbo].[import-GloriRiskAdj-Raw-Data]  FROM ' + '''' + @path_name + 'temp.csv' + '''' + ' WITH (CODEPAGE = ''1252'', FIELDTERMINATOR ='','', FIRSTROW = 2, ROWTERMINATOR =''\n'')'
							execute sp_executesql @sql
					END

					if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportGloriRisk - update portfolio name', GETDATE () END
					-- now updatePortfolio Name
					-- =======================================================================================================================================================*/

					update [FinRecon].[dbo].[import-GloriRiskAdj-Raw-Data] 
						set [PORTFOLIO_NAME] = [BOOK_NAME_CURRENT] 
							where	[PORTFOLIO_NAME] like '%not avail%' and 
									[BOOK_NAME_CURRENT] not like '%-'

					update [FinRecon].[dbo].[import-GloriRiskAdj-Raw-Data]
						set [PORTFOLIO_NAME] = [INTERMEDIATE4_NAME_CURRENT] 
							where	[PORTFOLIO_NAME] like '%not avail%' and 
									[BOOK_NAME_CURRENT] like '%-' and 
									[INTERMEDIATE4_NAME_CURRENT] not like '%-'

					update [FinRecon].[dbo].[import-GloriRiskAdj-Raw-Data]
						set [PORTFOLIO_NAME] = [INTERMEDIATE3_NAME_CURRENT] 
							where	[PORTFOLIO_NAME] like '%not avail%' and 
									[BOOK_NAME_CURRENT] like '%-' and 
									[INTERMEDIATE4_NAME_CURRENT] like '%-' and 
									[INTERMEDIATE3_NAME_CURRENT] not like '%-'

					update [FinRecon].[dbo].[import-GloriRiskAdj-Raw-Data]
						set [PORTFOLIO_NAME] = [INTERMEDIATE2_NAME_CURRENT] 
							where	[PORTFOLIO_NAME] like '%not avail%' and 
									[BOOK_NAME_CURRENT] like '%-' and 
									[INTERMEDIATE4_NAME_CURRENT] like '%-' and 
									[INTERMEDIATE3_NAME_CURRENT] like '%-' and 
									[INTERMEDIATE2_NAME_CURRENT] not like '%-'

					update [FinRecon].[dbo].[import-GloriRiskAdj-Raw-Data]
						set [PORTFOLIO_NAME] = [INTERMEDIATE1_NAME_CURRENT] 
							where	[PORTFOLIO_NAME] like '%not avail%' and 
									[BOOK_NAME_CURRENT] like '%-' and 
									[INTERMEDIATE4_NAME_CURRENT] like '%-' and 
									[INTERMEDIATE3_NAME_CURRENT] like '%-' and 
									[INTERMEDIATE2_NAME_CURRENT] like '%-' and
									[INTERMEDIATE1_NAME_CURRENT] not like '%-'

					update [FinRecon].[dbo].[import-GloriRiskAdj-Raw-Data]
						set [PORTFOLIO_NAME] = [DESK_NAME_CURRENT] 
							where	[PORTFOLIO_NAME] like '%not avail%' and 
									[BOOK_NAME_CURRENT] like '%-' and 
									[INTERMEDIATE4_NAME_CURRENT] like '%-' and 
									[INTERMEDIATE3_NAME_CURRENT] like '%-' and 
									[INTERMEDIATE2_NAME_CURRENT] like '%-' and
									[INTERMEDIATE1_NAME_CURRENT] like '%-' and
									[DESK_NAME_CURRENT] not like '%-'

					
					update [FinRecon].[dbo].[import-GloriRiskAdj-Raw-Data]  
						set [PORTFOLIO_NAME] = 
								case when [CATEGORY_NAME] = 'Bid/Offer Valuation Adjustments' then left([Portfolio_Name],43) + '_ValADj' else 
							    case when [CATEGORY_NAME] = 'Valuation Adjustments Credit' then left([Portfolio_Name],40) + '_CreditAdj' else
								case when [CATEGORY_NAME] = 'Model Risk Valuation Adjustments' then left([Portfolio_Name],37) + '_ModelRiskAdj' else
								case when [CATEGORY_NAME] = 'Tax' then left([Portfolio_Name],46) + '_Tax' else
								case when [CATEGORY_NAME] = '(Other) Business related Costs' then left([Portfolio_Name],34) + '_BusinessRelCost' else
								case when [CATEGORY_NAME] = 'Cost of Cash' then left([Portfolio_Name],39) ++ '_CostOfCash' else
								case when [CATEGORY_NAME] = 'Working Capital Utilisation' then left([Portfolio_Name],42) + '_WorkCap' else
								case when [CATEGORY_NAME] = 'Brokerage and Exchange Fees' and [BOOK_NAME_CURRENT] like '%-' then left([Portfolio_Name],40) + '_Brokerage' 
								else left([PORTFOLIO_NAME],50) end end end end end end end end						



					--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @sql, GETDATE () END

					select @step = @step + 1
					select @NumberOfDataset = count(*) from [dbo].[import-GloriRiskAdj-RAW-Data]
					--==============================================================================================================================================================================================
					--==============================================================================================================================================================================================
					--==============================================================================================================================================================================================
					
					

					if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportGloriRisk - Inserted # from file into table => [dbo].[import-GloriRiskAdj-RAW-Data]  ' + convert(varchar,@NumberOfDataset), GETDATE () END

					if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportGloriRisk - Insert into table => [dbo].[GloriRiskAdjustments-Data]', GETDATE () END

					select @step = @step + 1
					select @NumberOfDataset = count(*) from [dbo].[GloriRiskAdjustments]

					if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportGloriRisk - # table => [dbo].[GloriRiskAdjustments] before ' + convert(varchar,@NumberOfDataset), GETDATE () END

					select @step = @step + 1
					update [dbo].[GloriRiskAdjustments] set 
													[Realised Discounted EUR] = 0, [Realised Discounted EUR - EOLY] = 0, [Unrealised Discounted EUR] = 0, [Unrealised Discounted EUR - EOLY] = 0,
													[Realised Discounted USD] = 0, [Realised Discounted USD - EOLY] = 0, [Unrealised Discounted USD] = 0, [Unrealised Discounted USD - EOLY] = 0,
													[Realised Discounted GBP] = 0, [Realised Discounted GBP - EOLY] = 0, [Unrealised Discounted GBP] = 0, [Unrealised Discounted GBP EOLY] = 0
												where [FileId] = @fileid


					select @step = @step + 1
					insert into [FinRecon].[dbo].[GloriRiskAdjustments] (
							[BUSINESS_LINE_NAME_CURRENT],[DESK_NAME_CURRENT],[INTERMEDIATE1_NAME_CURRENT],[INTERMEDIATE2_NAME_CURRENT],[INTERMEDIATE3_NAME_CURRENT],[INTERMEDIATE4_NAME_CURRENT],
							[BOOK_NAME_CURRENT],[PORTFOLIO_NAME],[CATEGORY_NAME],[SUB_CATEGORY_NAME],[ADJUSTMENT_ID],[USER_COMMENT] ,[User_ID],[MONTH_AS_INDIC_DTL_LVL],[CURRENCY])
					select  [BUSINESS_LINE_NAME_CURRENT],[DESK_NAME_CURRENT],[INTERMEDIATE1_NAME_CURRENT],[INTERMEDIATE2_NAME_CURRENT],[INTERMEDIATE3_NAME_CURRENT],[INTERMEDIATE4_NAME_CURRENT],
							[BOOK_NAME_CURRENT],[PORTFOLIO_NAME],[CATEGORY_NAME],[SUB_CATEGORY_NAME],[ADJUSTMENT_ID],[USER_COMMENT],[USER_ID],[MONTH_AS_INDIC_DTL_LVL],[CURRENCY] 
					from [FinRecon].[dbo].[import-GloriRiskAdj-Raw-Data] where [ADJUSTMENT_ID] in 
							(select [ADJUSTMENT_ID] FROM [FinRecon].[dbo].[import-GloriRiskAdj-Raw-Data]
								except
							select [ADJUSTMENT_ID]  from [FinRecon].[dbo].[GloriRiskAdjustments])

					--delete from [dbo].[import-GloriRiskAdj-Raw-Data]

					select @NumberOfDataset = count(*) from [dbo].[GloriRiskAdjustments]

					if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportGloriRisk - # table => [dbo].[GloriRiskAdjustments] after ' + convert(varchar,@NumberOfDataset), GETDATE () END

					select @step = @step + 1
					update [FinRecon].[dbo].[GloriRiskAdjustments] set [FileId] = @fileid where [FileId] is NULL

					select @step = @step + 1
					update [FinRecon].[dbo].[GloriRiskAdjustments] set [COB] = @CoBDate where [COB] is NULL

					select @step = @step + 1
					update [dbo].[GloriRiskAdjustments] set [LastUpdate] = @TimeStamp from [dbo].[GloriRiskAdjustments] as  dd inner join [import-GloriRiskAdj-Raw-Data] as rr on dd.[ADJUSTMENT_ID] = rr.[ADJUSTMENT_ID]

					-- =======================================================================================================================================================
					-- now update of figures
					-- =======================================================================================================================================================
					
					update [dbo].[GloriRiskAdjustments]
						set [BUSINESS_LINE_NAME_CURRENT] = gg.[BUSINESS_LINE_NAME_CURRENT] ,
							[DESK_NAME_CURRENT] = gg.[DESK_NAME_CURRENT],
							[INTERMEDIATE1_NAME_CURRENT]= gg.[INTERMEDIATE1_NAME_CURRENT],
							[INTERMEDIATE2_NAME_CURRENT]= gg.[INTERMEDIATE2_NAME_CURRENT],
							[INTERMEDIATE3_NAME_CURRENT]= gg.[INTERMEDIATE3_NAME_CURRENT],
							[INTERMEDIATE4_NAME_CURRENT]= gg.[INTERMEDIATE4_NAME_CURRENT],
							[BOOK_NAME_CURRENT]= gg.[BOOK_NAME_CURRENT],
							[PORTFOLIO_NAME]= gg.[PORTFOLIO_NAME],
							[CATEGORY_NAME]= gg.[CATEGORY_NAME],
							[SUB_CATEGORY_NAME]= gg.[SUB_CATEGORY_NAME],
							[USER_COMMENT]= gg.[USER_COMMENT],
							[User_ID]= gg.[User_ID],
							[MONTH_AS_INDIC_DTL_LVL]= gg.[MONTH_AS_INDIC_DTL_LVL],
							[CURRENCY]= gg.[CURRENCY],

						    [Realised Discounted EUR] = gg.[REAL_DISC_EUR], [Realised Discounted EUR - EOLY] = gg.[REAL_DISC_EUR_EOLY],
							[Unrealised Discounted EUR] = gg.[UNREAL_DISC_EUR], [Unrealised Discounted EUR - EOLY] = gg.[UNREAL_DISC_EUR_EOLY],
							[Realised Discounted USD] = gg.[REAL_DISC_USD], [Realised Discounted USD - EOLY] = gg.[REAL_DISC_USD_EOLY],
							[Unrealised Discounted USD] = gg.[UNREAL_DISC_USD], [Unrealised Discounted USD - EOLY] = gg.[UNREAL_DISC_USD_EOLY],
							[Realised Discounted GBP] = gg.[REAL_DISC_GBP], [Realised Discounted GBP - EOLY] = gg.[REAL_DISC_GBP_EOLY],
							[Unrealised Discounted GBP] = gg.[UNREAL_DISC_GBP], [Unrealised Discounted GBP EOLY] = gg.[UNREAL_DISC_GBP_EOLY] 
									from [dbo].[GloriRiskAdjustments]  as tt inner join 
										(select [BUSINESS_LINE_NAME_CURRENT],[DESK_NAME_CURRENT] ,[INTERMEDIATE1_NAME_CURRENT] ,[INTERMEDIATE2_NAME_CURRENT] ,[INTERMEDIATE3_NAME_CURRENT] ,[INTERMEDIATE4_NAME_CURRENT] ,
										[BOOK_NAME_CURRENT] ,[PORTFOLIO_NAME] ,[CATEGORY_NAME] ,[SUB_CATEGORY_NAME] ,[USER_COMMENT] ,[User_ID] ,[MONTH_AS_INDIC_DTL_LVL] ,[CURRENCY] ,
										sum ( CASE when rr.[REAL_DISC_EUR]   like ( '%-') or  rr.[REAL_DISC_EUR] IS  NULL THEN cast('0' as float ) ELSE cast(replace(rr.[REAL_DISC_EUR],',','')as float) END) as [REAL_DISC_EUR] , 
										sum ( CASE when rr.[REAL_DISC_EUR_EOLY]   like ( '%-') or  rr.[REAL_DISC_EUR_EOLY] IS  NULL THEN cast('0' as float ) ELSE cast(replace(rr.[REAL_DISC_EUR_EOLY],',','')as float) END) as [REAL_DISC_EUR_EOLY] , 
										sum ( CASE when rr.[UNREAL_DISC_EUR]   like ( '%-') or  rr.[UNREAL_DISC_EUR] IS  NULL THEN cast('0' as float ) ELSE cast(replace(rr.[UNREAL_DISC_EUR],',','')as float) END) as [UNREAL_DISC_EUR] , 
										sum ( CASE when rr.[UNREAL_DISC_EUR_EOLY]   like ( '%-') or  rr.[UNREAL_DISC_EUR_EOLY] IS  NULL THEN cast('0' as float ) ELSE cast(replace(rr.[UNREAL_DISC_EUR_EOLY],',','')as float) END) as [UNREAL_DISC_EUR_EOLY] , 
										sum ( CASE when rr.[REAL_DISC_USD]   like ( '%-') or  rr.[REAL_DISC_USD] IS  NULL THEN cast('0' as float ) ELSE cast(replace(rr.[REAL_DISC_USD],',','')as float) END) as [REAL_DISC_USD] , 
										sum ( CASE when rr.[REAL_DISC_USD_EOLY]   like ( '%-') or  rr.[REAL_DISC_USD_EOLY] IS  NULL THEN cast('0' as float ) ELSE cast(replace(rr.[REAL_DISC_USD_EOLY],',','')as float) END) as [REAL_DISC_USD_EOLY] , 
										sum ( CASE when rr.[UNREAL_DISC_USD]   like ( '%-') or  rr.[UNREAL_DISC_USD] IS  NULL THEN cast('0' as float ) ELSE cast(replace(rr.[UNREAL_DISC_USD],',','')as float) END) as [UNREAL_DISC_USD] , 
										sum ( CASE when rr.[UNREAL_DISC_USD_EOLY]   like ( '%-') or  rr.[UNREAL_DISC_USD_EOLY] IS  NULL THEN cast('0' as float ) ELSE cast(replace(rr.[UNREAL_DISC_USD_EOLY],',','')as float) END) as [UNREAL_DISC_USD_EOLY] , 
										sum ( CASE when rr.[REAL_DISC_GBP]   like ( '%-') or  rr.[REAL_DISC_GBP] IS  NULL THEN cast('0' as float ) ELSE cast(replace(rr.[REAL_DISC_GBP],',','')as float) END) as [REAL_DISC_GBP] , 
										sum ( CASE when rr.[REAL_DISC_GBP_EOLY]   like ( '%-') or  rr.[REAL_DISC_GBP_EOLY] IS  NULL THEN cast('0' as float ) ELSE cast(replace(rr.[REAL_DISC_GBP_EOLY],',','')as float) END) as [REAL_DISC_GBP_EOLY] , 
										sum ( CASE when rr.[UNREAL_DISC_GBP]   like ( '%-') or  rr.[UNREAL_DISC_GBP] IS  NULL THEN cast('0' as float ) ELSE cast(replace(rr.[UNREAL_DISC_GBP],',','')as float) END) as [UNREAL_DISC_GBP] , 
										sum ( CASE when rr.[UNREAL_DISC_GBP_EOLY]   like ( '%-') or  rr.[UNREAL_DISC_GBP_EOLY] IS  NULL THEN cast('0' as float ) ELSE cast(replace(rr.[UNREAL_DISC_GBP_EOLY],',','')as float) END) as [UNREAL_DISC_GBP_EOLY] , 
										rr.[ADJUSTMENT_ID] from  dbo.[import-GloriRiskAdj-Raw-Data] as rr group by rr.[ADJUSTMENT_ID],rr.[BUSINESS_LINE_NAME_CURRENT],rr.[DESK_NAME_CURRENT] ,rr.[INTERMEDIATE1_NAME_CURRENT] ,
										rr.[INTERMEDIATE2_NAME_CURRENT] ,rr.[INTERMEDIATE3_NAME_CURRENT] ,rr.[INTERMEDIATE4_NAME_CURRENT] , rr.[BOOK_NAME_CURRENT] ,rr.[PORTFOLIO_NAME] ,rr.[CATEGORY_NAME] ,rr.[SUB_CATEGORY_NAME]  ,
										rr.[USER_COMMENT] ,rr.[User_ID] ,rr.[MONTH_AS_INDIC_DTL_LVL] ,rr.[CURRENCY] ) as gg on tt.[ADJUSTMENT_ID] = gg.[ADJUSTMENT_ID]


					-- =======================================================================================================================================================
					-- =======================================================================================================================================================
					-- =======================================================================================================================================================

					select @NumberOfDataset = count(*) from [dbo].[GloriRiskAdjustments]

					if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportGloriRisk - # table => [dbo].[GloriRiskAdj] before deletion, after insert' + convert(varchar,@NumberOfDataset), GETDATE () END


					--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportGloriRisk - FileID is => ' + convert(varchar,@fileid), GETDATE () END

					select @step = @step + 1
					delete from [dbo].[GloriRiskAdjustments] where abs([Realised Discounted EUR - EOLY]) + abs([Realised Discounted EUR])
						+ abs([Unrealised Discounted EUR - EOLY]) + abs([Unrealised Discounted EUR]) +  abs([Realised Discounted USD - EOLY])
						+ abs([Realised Discounted USD]) + abs([Unrealised Discounted USD - EOLY]) + abs ([Unrealised Discounted USD])
						+ abs([Realised Discounted GBP - EOLY]) + abs([Realised Discounted GBP]) + abs([Unrealised Discounted GBP EOLY]) 
						+ abs([Unrealised Discounted GBP]) = 0
					
					select @NumberOfDataset = count(*) from [dbo].[GloriRiskAdjustments]

					if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportGloriRisk - # table => [dbo].[GloriRiskAdj] after deletion' + convert(varchar,@NumberOfDataset), GETDATE () END

					-- inserted by MBE on 28.04.2021

					if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportGloriRisk update for April -- start --' , GETDATE () END

					-- 
					delete from [FinRecon].[dbo].[GloriRiskAdjustments]  where PORTFOLIO_NAME = 'CF REPORTING_ValADj'

					update [dbo].[GloriRiskAdjustments] set [PORTFOLIO_NAME] = 'Bid/Offer Val. Adj – DBO' where CATEGORY_NAME = 'Bid/Offer Valuation Adjustments' and [INTERMEDIATE2_NAME_CURRENT] = 'DRY BULK ORIGINATION'

					update [dbo].[GloriRiskAdjustments] set [PORTFOLIO_NAME] = 'Bid/Offer Val. Adj – Coal Freight' where CATEGORY_NAME = 'Bid/Offer Valuation Adjustments' and [INTERMEDIATE2_NAME_CURRENT] in ('Coal Trading', 'FREIGHT')

					update [dbo].[GloriRiskAdjustments] set [PORTFOLIO_NAME] = 'Bid/Offer Val. Adj – Japan' where CATEGORY_NAME = 'Bid/Offer Valuation Adjustments' and [SUB_CATEGORY_NAME] = 'RWEST JAPAN PE'

					update [dbo].[GloriRiskAdjustments] set [PORTFOLIO_NAME] = 'Bid/Offer Val. Adj – China' where CATEGORY_NAME = 'Bid/Offer Valuation Adjustments' and [SUB_CATEGORY_NAME] = 'RWEST SHANGHAI PE'

					update [dbo].[GloriRiskAdjustments] set [PORTFOLIO_NAME] = 'Bid/Offer Val. Adj – Indonesia' where CATEGORY_NAME = 'Bid/Offer Valuation Adjustments' and [SUB_CATEGORY_NAME] = 'PT RHEINCOAL PE'

					update [dbo].[GloriRiskAdjustments] set [PORTFOLIO_NAME] = 'ASIA-PACIFIC TRADING REPORTING_ValADj' where CATEGORY_NAME = 'Bid/Offer Valuation Adjustments' and [SUB_CATEGORY_NAME] = 'Indonesia'

					update [dbo].[GloriRiskAdjustments] set [PORTFOLIO_NAME] = 'ASIA-PACIFIC TRADING REPORTING_ValADj' where CATEGORY_NAME = 'Bid/Offer Valuation Adjustments' and [SUB_CATEGORY_NAME] = 'China Commodities'

					--delete FROM [FinRecon].[dbo].[GloriRiskAdjustments] where PORTFOLIO_NAME = 'ASIA-PACIFIC TRADING REPORTING_ValADj' and SUB_CATEGORY_NAME = 'Japan Complex'

					delete from [FinRecon].[dbo].[GloriRiskAdjustments] where [PORTFOLIO_NAME] = 'Bid/Offer Val. Adj – AP'  and [SUB_CATEGORY_NAME] = 'Dummy' and [ADJUSTMENT_ID] = 'Dummy'

					insert into [FinRecon].[dbo].[GloriRiskAdjustments] ([COB] ,[BUSINESS_LINE_NAME_CURRENT] ,[DESK_NAME_CURRENT] ,[INTERMEDIATE1_NAME_CURRENT] ,[INTERMEDIATE2_NAME_CURRENT] ,
								[INTERMEDIATE3_NAME_CURRENT],[INTERMEDIATE4_NAME_CURRENT] ,[BOOK_NAME_CURRENT] ,[PORTFOLIO_NAME] ,[CATEGORY_NAME] ,[SUB_CATEGORY_NAME] ,[ADJUSTMENT_ID] ,
								[USER_COMMENT] ,[User_ID] ,[MONTH_AS_INDIC_DTL_LVL] ,[CURRENCY] ,[Realised Discounted EUR] ,[Realised Discounted EUR - EOLY] ,[Unrealised Discounted EUR] ,
								[Unrealised Discounted EUR - EOLY] ,[Realised Discounted USD] ,[Realised Discounted USD - EOLY] ,[Unrealised Discounted USD] ,[Unrealised Discounted USD - EOLY],
								[Realised Discounted GBP],[Realised Discounted GBP - EOLY] ,[Unrealised Discounted GBP] ,[Unrealised Discounted GBP EOLY] ,[LastUpdate] ,[FileId])
					SELECT		convert(Datetime,max([COB]),104) ,[BUSINESS_LINE_NAME_CURRENT], [DESK_NAME_CURRENT],[INTERMEDIATE1_NAME_CURRENT], [INTERMEDIATE2_NAME_CURRENT],	
								[INTERMEDIATE3_NAME_CURRENT],[INTERMEDIATE4_NAME_CURRENT],[BOOK_NAME_CURRENT],'Bid/Offer Val. Adj – AP'      ,[CATEGORY_NAME],'Dummy','Dummy', 
								MAX([User_Comment]), MAX([User_ID]), MAX([Month_as_Indic_DTL_LVL]), MAX([Currency]),
							    sum(case when PORTFOLIO_NAME like 'BID/Offer%' then -[Realised Discounted EUR] else [Realised Discounted EUR] end)      ,
							    sum(case when PORTFOLIO_NAME like 'BID/Offer%' then -[Realised Discounted EUR - EOLY] else [Realised Discounted EUR - EOLY] end)      ,
							    sum(case when PORTFOLIO_NAME like 'BID/Offer%' then -[Unrealised Discounted EUR] else [Unrealised Discounted EUR] end)    ,
							    sum(case when PORTFOLIO_NAME like 'BID/Offer%' then -[Unrealised Discounted EUR - EOLY] else [Unrealised Discounted EUR - EOLY] end),
							    sum(case when PORTFOLIO_NAME like 'BID/Offer%' then -[Realised Discounted USD] else [Realised Discounted USD] end),
							    sum(case when PORTFOLIO_NAME like 'BID/Offer%' then -[Realised Discounted USD - EOLY] else [Realised Discounted USD - EOLY] end),
							    sum(case when PORTFOLIO_NAME like 'BID/Offer%' then -[Unrealised Discounted USD] else [Unrealised Discounted USD] end),
							    sum(case when PORTFOLIO_NAME like 'BID/Offer%' then -[Unrealised Discounted USD - EOLY] else [Unrealised Discounted USD - EOLY] end),
							    sum(case when PORTFOLIO_NAME like 'BID/Offer%' then -[Realised Discounted GBP] else [Realised Discounted GBP] end),
							    sum(case when PORTFOLIO_NAME like 'BID/Offer%' then -[Realised Discounted GBP - EOLY] else [Realised Discounted GBP - EOLY] end),
							    sum(case when PORTFOLIO_NAME like 'BID/Offer%' then -[Unrealised Discounted GBP] else [Unrealised Discounted GBP] end),
							    sum(case when PORTFOLIO_NAME like 'BID/Offer%' then -[Unrealised Discounted GBP EOLY] else [Unrealised Discounted GBP EOLY] end),
								convert(datetime,MAX([LastUpdate]),104),'1464'
					  FROM [FinRecon].[dbo].[GloriRiskAdjustments] where [Category_Name] ='Bid/Offer Valuation Adjustments' and [DESK_NAME_CURRENT] = 'ASIA-PACIFIC TRADING DESK'  
					  group by  [BUSINESS_LINE_NAME_CURRENT],[INTERMEDIATE1_NAME_CURRENT],[INTERMEDIATE2_NAME_CURRENT],	[INTERMEDIATE3_NAME_CURRENT],	
								[INTERMEDIATE4_NAME_CURRENT]	,[BOOK_NAME_CURRENT],[DESK_NAME_CURRENT]     ,[CATEGORY_NAME]


					if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportGloriRisk - ENDING IMPORT Proc for Adjustments', GETDATE () END

					--delete from [dbo].[GloriRiskAdjustments] where  [CATEGORY_NAME] not in ('Brokerage and Exchange Fees','Bid/Offer Valuation Adjustments','Valuation Adjustments Credit')

				END

				if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc +' - FINISHED', GETDATE () END

END TRY
	BEGIN CATCH
		--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc +' - FAILED', GETDATE () END
	END CATCH

GO

