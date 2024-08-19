

/*=================================================================================================================
 Context:			PART OF THE NEW UNREALISED APPROACH AFTER FT EXIT
 Author:      mkb
 Created:     2024/01
 Description:	imports the mtm data FROM ROCK into the database.
  ------------------------------------------------------------------------------------------
	change history: when, step, who, what, (why)
	 2024-02-00, all, mkb, initial setup of procedure 
	 2024-06-13, all, mkb, updated to import from linked server instead of dumped files
	 2024-08-08, 160, su, added Term_Start, Term_End
	 2024-08-16, 160, mkb, added BU_CCY

=================================================================================================================*/
CREATE PROCEDURE [dbo].[Import_Unrealised_ROCK]
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
		
		DECLARE @COB date
		DECLARE @COB_String date

		DECLARE @Desk_Name nvarchar (200)
		DECLARE @Warning_Counter int 	

		DECLARE @Log_Entry nvarchar (200)
		DECLARE @Main_Process nvarchar(50)
		
		DECLARE @recordcount numeric
		declare @unmapped_instypes varchar (300)
		declare @insHelper varchar(30)
		
		

		/*fill variables*/
		SET @step = 10
		SET @Current_Procedure = Object_Name(@@PROCID)
		SET @Data_Source	='ROCK_MTM'
		SET @Main_Process = 'TESTRUN UNREALISED ROCK DATA'
		SET @Warning_Counter = 0
		
	/*identify the COB the load should be done for*/	
		--SELECT @COB = AsOfDate_EOM FROM dbo.AsOfDate	/* standard COB for month end processing */
		SELECT @COB = AsOfDate_FT_Replacement FROM dbo.AsOfDate /* date in case you want to run against another date than the "official" COB */
		

	/*example for new log entry*/
		/*EXEC dbo.Write_Log [Status = info/warning/ERROR], [logentry], [Current_Procedure], [Main_Process]', '[Calling_Application]', [Step], [Log_Info=1/0], [Session_Key]		*/				
			
		EXEC dbo.Write_Log 'Info', 'START', @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL

		SET @step = 20	
		SET @Log_Entry = 'Importing ROCK MTM data for COB ' + cast(@COB AS varchar)
		EXEC dbo.Write_Log 'Info', @Log_Entry, @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL
	
		/*identify the number of desks to be imported */
		SET @step = 30			
		SELECT @counter = count(1) FROM dbo.FilestoImport WHERE [Source] in (@Data_Source) and ToBeImported=1
				
		/*in case nothing is set to be imported, create a related log entry and exit*/
		IF @counter=0 
		BEGIN 
			SET @step = 35			
			SET @Log_Entry = 'Nothing found to get imported.'
			SET @Warning_Counter = @Warning_Counter + 1
			EXEC dbo.Write_Log 'WARNING', @Log_Entry, @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL
			GOTO NoFurtherAction 
		END		
					
		/*tell the world how many desks we are going to import*/
		SET @Log_Entry = 'Going to import ' + cast(@counter AS varchar) + ' data file(s).'
		EXEC dbo.Write_Log 'Info', @Log_Entry, @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL
	
/*============ START of loop for file import ===============================================================================================================*/
		SET @step = 40	
		/*loop over counter, reduce it at then end*/ 	
		WHILE @counter >0
		BEGIN						
			
		/*drop temporary import table first, in case it still exists*/ 
			SET @step=100			
			DROP TABLE IF EXISTS dbo.table_unrealised_rawdata_ROCK 
				
				

			/*identify the single desk-related snowflake-function to be loaded */					
			SET @step=110	
			SELECT
				 @File_Name = [FileName]
				,@FileID   = ID
			FROM 
				(SELECT *, ROW_NUMBER() OVER(ORDER BY ID DESC) AS ROW 
					FROM dbo.FilestoImport 
					WHERE [Source] in (@Data_Source) and ToBeImported=1
				) AS TMP 
			WHERE 
				ROW = @counter
			


			/*replace date placeholders in filename to make it a proper string*/
			SET @step=120	
			SET @File_Name = dbo.udf_Resolve_Date_Placeholder_custom_asofdate(@File_Name,@COB)

			/*identify deskname to be loaded, it is between two and six characters long*/
			SET @step=130
			SET @Desk_Name = Substring(@File_Name, 13,CHARINDEX('_', @File_Name, 14+CASE when CHARINDEX('CAO', @File_Name)>0 then 3 else 0 end)-13) 
			


			SET @step=140	
			SET @Log_Entry = 'Import #' + cast(@counter AS varchar) + ': started for: '  + @Desk_Name
			EXEC dbo.Write_Log 'Info', @Log_Entry, @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL
			
			/* the import itself via linked server*/
			SET @sql = 'SELECT * INTO dbo.table_unrealised_rawdata_ROCK FROM OPENQUERY(ROCK_PROD,''SELECT * FROM TABLE(ROCK_PROD.FINANCE.' + @File_Name +')'')'
			EXECUTE sp_executesql @sql			



			/*import itself is done here, now transfer imported data into first stage table*/
			SET @step=150
			/*delete old entries in data table */
			DELETE FROM dbo.table_unrealised_01 WHERE fileID=@FileID
			


			SET @step=160
			/*refill data table with new ROCK data */	
			INSERT INTO dbo.table_unrealised_01
			(
				 COB
				,Deal_Number
				,Trade_Date
				,Internal_Legal_Entity
				,Desk_Name
				,Desk_ID
				,Desk_CCY
				,Book_Name
				,Book_ID
				,Internal_Portfolio
				,Portfolio_ID
				,Instrument_Type
				,Unit_of_Measure
				,External_Legal_Entity
				,External_Business_Unit
				,External_Portfolio
				,Projection_Index_Name
				,Projection_Index_Group
				,Product_Name
				,Cashflow_Payment_Date
				,Leg_Start_Date
				,Leg_End_Date
				,Term_Start
				,Term_End
				,Delivery_Date
				,Delivery_Month
				,Trade_Price
				,Cashflow_Type
				,Cashflow_Type_ID
				,[Contract_Name]
				,Order_Number
				,Buy_Sell
				,Volume				
				,Cashflow_CCY
			--	,BU_CCY
				,Unrealised_Discounted_BU_CCY
				,Realised_Discounted_BU_CCY
				,Unrealised_Discounted_Cashflow_CCY
				,Realised_Discounted_Cashflow_CCY				
				,DataSource
				,FileID
			)
			SELECT
				 convert(date,COB,103) AS COB																									
				,cast(DEAL_NUMBER as varchar) as deal_number		
				,cast(Trade_Date as date) as Trade_Date																		
				,Int_Legal_Entity_Name as Legal_Entitiy																		
				,DESK_NAME																																/*ROCK, gets overwritten by data fom map_order*/
				,cast(Desk_ID as int) as Desk_ID																													
				,Desk_Currency as Desk_CCY																									
				,Book_NAME as Book_Name																																				
				,cast(Book_ID as int) as Book_ID
				,PORTFOLIO_NAME as Internal_Portfolio																					
				,cast(Portfolio_ID as int) as Portfolio_ID																								
				,INSTRUMENT_TYPE_NAME as Instrument_Type																						
				,Index_Unit_Name as Unit_of_Measure																				
				,Ext_Legal_Entity_Name as External_Legal_Entity			
				,Ext_Business_Unit_Name as External_Counterparty		
				,EXTERNAL_PORTFOLIO_NAME as External_Portfolio				
				,projection_Index_Name as Projection_Index_Name		
				,Index_Group_Name as Projection_Index_Group					
				,Product_Name
				,cashflow_payment_date as Cashflow_Payment_Date				
				,cast(DEAL_PDC_START_DATE as date) as Leg_Start_Date
				,cast(DEAL_PDC_END_DATE as date) as Leg_End_Date
				,cast(DEAL_PDC_START_DATE as date) as Term_Start
				,cast(DEAL_PDC_END_DATE as date) as Term_End
				,cast(Delivery_Date as date) as Delivery_Date											
				,cast(Delivery_Month as date)Delivery_Month										
				,ROUND(cast(Trade_Price as float),4) as Trade_Price												
				,Cashflow_Type
				,cast(Cashflow_Type_ID as int) as Cashflow_Type_ID
				,[Contract_Name]																			
				,INTERNAL_ORDER_ID as Order_Number										
				--,Active_Period																															/*ROCK, not yet requested*/
				,Buy_Sell_Name as Buy_Sell														
				,ROUND(SUM(CONVERT(float, Volume)),4) as volume
				,Cashflow_Currency
				--,BUSINESS_LINE_CURRENCY
				,ROUND(SUM(ISNULL(convert(float, UNREAL_DISC_PH_BL_CCY) ,0)),4) as Unrealised_Discounted_BU_CCY		
				,ROUND(SUM(ISNULL(convert(float, REAL_DISC_PH_BL_CCY) ,0)),4) as Realised_Discounted_BU_CCY				
				,ROUND(SUM(ISNULL(convert(float, UNREAL_DISC_Cashflow_CCY) ,0)),4) as Unrealised_Discounted_Cashflow_CCY		
				,ROUND(SUM(ISNULL(convert(float, REAL_DISC_Cashflow_CCY) ,0)),4) as Realised_Discounted_Cashflow_CCY		
				,'ROCK' as DataSource
				,@FileID as FileID				
			FROM 
				dbo.table_unrealised_rawdata_ROCK
				LEFT JOIN dbo.map_instype	ON dbo.table_unrealised_rawdata_ROCK.INSTRUMENT_TYPE_NAME = dbo.map_instype.InstrumentType
			GROUP BY 
			 convert(date,COB,103) 																							
				,cast(DEAL_NUMBER as varchar) 
				,cast(Trade_Date as date)
				,Int_Legal_Entity_Name
				,DESK_NAME																																/*ROCK, gets overwritten by data fom map_order*/
				,cast(Desk_ID as int)
				,Desk_Currency 
				,Book_NAME	
				,cast(Book_ID as int) 
				,PORTFOLIO_NAME 
				,cast(Portfolio_ID as int) 
				,INSTRUMENT_TYPE_NAME 
				,Index_Unit_Name 
				,Ext_Legal_Entity_Name 
				,Ext_Business_Unit_Name 
				,EXTERNAL_PORTFOLIO_NAME
				,projection_Index_Name 
				,Index_Group_Name 
				,Product_Name
				,cashflow_payment_date 
				,cast(DEAL_PDC_Start_DATE as date) 
				,cast(DEAL_PDC_END_DATE as date) 
				,cast(Delivery_Date as date) 
				,cast(Delivery_Month as date)
				,ROUND(cast(Trade_Price as float),4) 
				,Cashflow_Type
				,cast(Cashflow_Type_ID as int) 
				,[Contract_Name]																			
				,INTERNAL_ORDER_ID 
				,Buy_Sell_Name
				,Cashflow_Currency
				--,BUSINESS_LINE_CURRENCY
				

			SET @step=170
			/*statistics*/
			SELECT @recordcount = count(*) FROM dbo.table_unrealised_rawdata_ROCK 

			SET @Log_Entry = 'Import #' + cast(@counter AS varchar) + ': done for ' +   @Desk_Name + ', imported records: '+ cast(format(@recordcount,'###,###') AS varchar)
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
		SELECT @recordcount = count(*) FROM dbo.table_unrealised_01 WHERE DataSource like 'ROCK' 				
		SET @Log_Entry = 'Import completely done, ROCK related records in table: '+ cast(format(@recordcount,'###,###') AS varchar)
		EXEC dbo.Write_Log 'Info', @Log_Entry, @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL
		

		SET @step=210
		/* start identifying unmapped Instypes */
		SET @Log_Entry = 'Looking for unmapped Intrument_Types'
		EXEC dbo.Write_Log 'Info', @Log_Entry, @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL
		
		SET @counter = 0
		SET @unmapped_instypes =''

		drop table if exists dbo.tmp_check_instypes
		/*count found unmapped instypes*/

		SET @step=220
		select @counter = count(*) from 
			(SELECT 
				distinct dbo.Table_Unrealised_01.Instrument_Type 
			FROM 
				dbo.Table_Unrealised_01 LEFT JOIN dbo.map_instype 
				ON dbo.Table_Unrealised_01.Instrument_Type = dbo.map_instype.InstrumentType
			WHERE 
				dbo.map_instype.InstrumentType Is Null
			GROUP BY 
				dbo.Table_Unrealised_01.Instrument_Type
		) sub

		SET @step=230
		IF @counter>0		
		BEGIN 
				/*found at least one, so put it in a tmp-table*/
				SELECT	distinct dbo.Table_Unrealised_01.Instrument_Type			
				INTO 		dbo.tmp_check_instypes
				FROM		dbo.Table_Unrealised_01 LEFT JOIN dbo.map_instype 
								ON dbo.Table_Unrealised_01.Instrument_Type = dbo.map_instype.InstrumentType
				WHERE		dbo.map_instype.InstrumentType Is Null
				GROUP BY 
					dbo.Table_Unrealised_01.Instrument_Type 
					,dbo.map_instype.InstrumentType
			
				SET @step=240
				/*now list them all from the temp_table and concat them to ONE string*/
				WHILE @counter >0
				BEGIN
						SET @step=@step+1
						SELECT @inshelper = Instrument_Type
						FROM (SELECT Instrument_Type,ROW_NUMBER() OVER(ORDER BY Instrument_Type DESC) AS ROW
									FROM tmp_check_instypes
									) as tmp
						WHERE ROW = @counter
				
						SELECT @unmapped_instypes = @unmapped_instypes + IIF (@unmapped_instypes = '','', ', ') + @inshelper
						/*reduce counter*/
						SET @counter = @counter -1
				END
		
				SET @step=250
				/*drop helper table*/
				DROP TABLE IF EXISTS dbo.tmp_check_instypes
		
				SET @step=260
				/*present the resultset*/
				SELECT @unmapped_instypes as resultset				
				SET @Log_Entry = 'Found these unmapped instrument_types in imported data: '+ @unmapped_instypes
				SET @Warning_Counter = @Warning_Counter + 1
				EXEC dbo.Write_Log 'WARNING', @Log_Entry, @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL		
							
		END
		/*finished identifying unmapped Instypes */


------------
NoFurtherAction:
/*No further action to be done, so tell the world we're done and inform about potential WARNINGs.*/
	SELECT @step = 270
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

