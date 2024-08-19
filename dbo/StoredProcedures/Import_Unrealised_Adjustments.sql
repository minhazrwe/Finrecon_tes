
/*=================================================================================================================
	author:		mkb
	created:	2024/01
	purpose:	imports the data for unrealised adjustments into the unrealised workstream.
-----------------------------------------------------------------------------------------------------------------
	Changes:
	2024-08-06, mkb, complete refurbisch.
=================================================================================================================*/
CREATE PROCEDURE [dbo].[Import_Unrealised_Adjustments]
AS
BEGIN TRY

		DECLARE @Current_Procedure nvarchar (40)
		
		DECLARE @step integer
		DECLARE @sql nvarchar (max)
		DECLARE @return_value integer
		DECLARE @counter Integer

		DECLARE @Data_Source nvarchar (60)
		DECLARE @Import_Path varchar(2000)
		DECLARE @File_Name nvarchar (200)
		DECLARE @FileID integer
		
		DECLARE @Path_Name varchar(100)
		Declare @FileExists	int
		DECLARE @Path_File varchar(300)
		declare @Desk_Name varchar(20)
		
		DECLARE @COB date
		DECLARE @COB_String date

		DECLARE @Log_Entry nvarchar (200)
		DECLARE @Main_Process nvarchar(50)
		
		DECLARE @recordcount numeric
		DECLARE @Warning_Counter int

		SET @step = 1
		/*fill the required variables*/		
		SET @Current_Procedure = Object_Name(@@PROCID)
		SET @Data_Source	='ADJUSTMENT_MTM'
		SET @Main_Process = 'TESTRUN UNREALISED ADJUSTMENT DATA'
		SET @Warning_Counter = 0

		/*example for new log entry*/
		/*EXEC dbo.Write_Log [Status = info/warning/ERROR], [logentry], [Current_Procedure], [Main_Process]', '[Calling_Application]', [Step], [Log_Info=1/0], [Session_Key]		*/				

				
		SET @step = 10
		/*identify the COB that the load should be done for*/	
		SELECT @COB = AsOfDate_FT_Replacement FROM dbo.AsOfDate		/* alternative COB for testing purposes */
		--SELECT @COB = AsOfDate_EOM FROM dbo.AsOfDate							/* standard EOM to be imported */
		
		
		SET @step = 20	
		EXEC dbo.Write_Log 'Info', 'START', @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL
		
		SET @Log_Entry = 'Importing Adjustments for COB ' + cast(@COB AS varchar)
		EXEC dbo.Write_Log 'Info', @Log_Entry, @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL
		
		
		/*identify the number of files to be imported */
		SET @step = 30			
		SELECT @counter = count(1) FROM dbo.FilestoImport WHERE [Source] in (@Data_Source) and ToBeImported=1

		
		SET @step = 35			
		/*in case nothing is set to be imported, create a related log entry and exit*/		
		IF @counter=0 
		BEGIN 
			SET @Warning_Counter = @Warning_Counter + 1
			SET @Log_Entry = 'Nothing found to get imported.'			
			EXEC dbo.Write_Log 'WARNING', @Log_Entry, @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL
			GOTO NoFurtherAction 
		END		

		
		SET @step = 36			
		/*tell the world how many desks we are going to import*/
		SET @Log_Entry = 'Going to import ' + cast(@counter AS varchar) + ' data file(s).'
		EXEC dbo.Write_Log 'Info', @Log_Entry, @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL
		

		SET @step = 40	
		/*loop over counter, reduce it at then end*/ 	
		WHILE @counter >0
		BEGIN						
			
				SET @step=100			
				/*prepare rawdata_import_table first*/ 
				truncate TABLE dbo.table_unrealised_rawdata_Adjustments
				
				SET @step=110	
				/*identify all adjustment files to be loaded */					
				SELECT
						@FileID = ID
					 ,@File_Name = [FileName]
					 ,@Path_name = [Path]
					 ,@Path_File = Path_File
				FROM 
					(SELECT FilestoImport.id, [FileName],[Path], [Path] + [FileName] as Path_File, ROW_NUMBER() OVER(ORDER BY FilestoImport.ID DESC) AS ROW 
						FROM dbo.FilestoImport left outer join dbo.PathToFiles on cast(FilestoImport.PathID as varchar)= cast(PathToFiles.id as varchar)
						WHERE FilestoImport.[Source] in (@Data_Source) and ToBeImported=1
					) AS TMP 
				WHERE 
					ROW = @counter
			
				SET @step=120	
				/*replace date placeholders in filename to make it a proper string*/
				SET @File_Name = dbo.udf_Resolve_Date_Placeholder_custom_asofdate(@File_Name,@COB)
				
				SET @step=130
				/*identify deskname we want to load adjustments for*/
				SET @Desk_Name = Substring(@File_Name, 1,CHARINDEX('_', @File_Name, 1)-1) 

				SET @step=140	
				/*check if file exists at all*/
				EXEC xp_fileexist @Path_File, @FileExists OUTPUT

				IF @FileExists = 0
					BEGIN 
						/* file not found */
						Set @warning_counter = @warning_counter +1
						SET @Log_Entry = 'No file found for desk: ' + @Desk_Name
						EXEC dbo.Write_Log 'WARNING', @Log_Entry, @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL
					END
				ELSE
					BEGIN 
						/* file found, import it*/
						SET @Log_Entry = 'Import #' + cast(@counter AS varchar) + ' started for Desk: '  + @Desk_Name
						EXEC dbo.Write_Log 'Info', @Log_Entry, @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL

						BEGIN TRY 
							SELECT @sql = N'BULK INSERT [dbo].[table_unrealised_rawdata_Adjustments] FROM '  + '''' + @Path_File + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR =''~'', FIRSTROW = 2, ROWTERMINATOR =''0x0d0a'')';												
							EXECUTE sp_executesql @sql			
						END TRY

						BEGIN CATCH
							Set @warning_counter = @warning_counter +1
							SET @Log_Entry = 'Import for: '  + @Desk_Name + ' FAILED.'
							EXEC dbo.Write_Log 'ERROR', @Log_Entry, @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL
						END CATCH
					END 
					
					/*import itself is done, now transfer imported data into first stage table*/
					
					SET @step=150										
					/*delete old entries in data table */
					DELETE FROM dbo.table_unrealised_01 WHERE fileID=@FileID
		

					SET @step=160
					/*tranfer data with correct formatinto first stage table*/
					INSERT INTO dbo.table_unrealised_01 
					(
						COB
	 					,[Deal_Number]
						,[Term_Start]
						,[Term_End]
						,[Internal_Legal_Entity]
						,[Desk_Name]
						,[Internal_Portfolio]
						,[Portfolio_ID]
						,[Instrument_Type]
						,[External_Business_Unit]
						,[Adjustment_ID]
						,[Cashflow_Type]
						,[Unit_Of_Account]
						,[Accounting_Delivery_Month]
						,[Counterparty_Group]
						,[Partner_Code]
						,[Accounting_Treatment]
						,[Volume]
						,[Cashflow_CCY]
						,[Accounting_Comment]
						,[Adjustment_Comment]
						,[Adjustment_Category]
						,[Unrealised_Discounted_BU_CCY]
						,[DataSource]
			      ,[FileID]
				)
				SELECT 
					 convert(date, cob, 103)
					,Deal_Number
					,convert(date, Term_Start, 103) as Term_Start
					,convert(date, Term_End, 103) as Term_End
					,Internal_Legal_Entity
					,Desk_Name
					,Internal_Portfolio
					,Portfolio_ID
					,Instrument_Type
					,External_Business_Unit
					,Adjustment_ID
					,Cashflow_Type
					,Unit_Of_Account
					,convert(date, Accounting_Delivery_Month ,103) as Accounting_Delivery_Month
					,Counterparty_Group
					,Partner_Code
					,Accounting_Treatment
					,convert(float, Volume) as Volume
					,Cashflow_CCY
					,Accounting_Comment
					,Adjustment_Comment
					,Adjustment_Category
					,convert(float, Unrealised_Discounted_BU_CCY) as Unrealised_Discounted_BU_CCY
					,'ADJUSTMENT' as DataSource
					,@FileID as fileID
				FROM 
					[dbo].[table_unrealised_rawdata_Adjustments]
					
					SET @step=170
					/*statistics*/
					SELECT @recordcount = count(*) FROM dbo.table_unrealised_rawdata_Adjustments 

					SET @Log_Entry = 'Import #' + cast(@counter AS varchar) + ' done. Imported records: '+ cast(format(@recordcount,'###,###') AS varchar)
					EXEC dbo.Write_Log 'Info', @Log_Entry, @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL
			
					SET @step=180
					/*document import timestamp for just imported file*/
					update dbo.FilestoImport set LastImport = getdate() WHERE id = @FileID

NextFile:
					SET @step=190
					/*reduce counter*/
					SELECT @counter = @counter - 1		 

		END ---while @counter > 0
					

		SET @step=200
		/*-- count total number of imported records*/
		SELECT @recordcount = count(*) FROM dbo.table_unrealised_01 WHERE DataSource like 'ADJUSTMENTS' 				
		SET @Log_Entry = 'Import completely done, ADJUSTMENTS in table: '+ cast(format(@recordcount,'###,###') AS varchar)
		EXEC dbo.Write_Log 'Info', @Log_Entry, @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL


------------------
NoFurtherAction:
/*No further action to be done, so tell the world we're done and inform about potential WARNINGs.*/
	SELECT @step = 210
	SET @Log_Entry = 'FINISHED'
	IF @Warning_Counter = 0
			BEGIN
					EXEC dbo.Write_Log 'Info', @Log_Entry, @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL
			END
		ELSE
			BEGIN
				SET @Log_Entry = @Log_Entry + ' WITH ' + cast(@Warning_Counter as varchar) +  ' WARNING(S)! - check log for details!'
				EXEC dbo.Write_Log 'WARNING', @Log_Entry, @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL
			END
		Return 0
END TRY

BEGIN CATCH
	/*tell the world procedure failed*/
	EXEC [dbo].[usp_GetErrorInfo] @Current_Procedure, @step, @Main_Process; 
	EXEC dbo.Write_Log 'FAILED', 'FAILED with error, details in ERROR entry', @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL;	
	RETURN @step
END CATCH

GO

