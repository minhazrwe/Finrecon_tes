



/*=================================================================================================================
 Context:			PART OF THE NEW UNREALISED APPROACH AFTER FT EXIT
 Author:      SU/mkb
 Created:     2024/01
 Description:	imports the mtm data FROM STROLF into the database.

 -- 2024/06/19 changed for new STROLF view (with CF-Type)
 ------------------------------------------------------------------------------------------------------------------
 change history: when, who, step, what, (why)
  2024-01-00, mkb,	all, initial setup of procedure 
  2024-02-20, su,		 ??, added create table and insert statement for STROLF table 
  2024-08-02, su,		140, changed import fields
	2024-08-04, mkb,	 10, introduced "AsOfDate_FT_Replacement" as alternative COB for testing
=================================================================================================================*/
CREATE PROCEDURE [dbo].[Import_Unrealised_STROLF]
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
		DECLARE @date_cob_string nvarchar(max)
		DECLARE @Log_Entry nvarchar (200)
		DECLARE @Main_Process nvarchar(50)
		
		DECLARE @recordcount numeric

		/*fill the required variables*/
		SET @step = 10
		SET @Current_Procedure = Object_Name(@@PROCID)
		SET @Data_Source	='STROLF_MTM'
		SET @Main_Process = 'TESTRUN UNREALISED STROLF DATA'
	
		/*identify the COB that the load should be done for*/	
		
		--SELECT @COB = AsOfDate_EOM FROM dbo.AsOfDate						/* regular cob date to be considered for month ends*/
		SELECT @COB = AsOfDate_FT_Replacement FROM dbo.AsOfDate		/* cob date used for testing purposes to not interfere with the AsOfDate_MtM_Check */
		
		SET @date_cob_string = CONVERT(NVARCHAR, CONVERT(DATE, @COB, 103), 120); 


		/*example for new log entry*/
		/*EXEC dbo.Write_Log [Status = info/warning/ERROR], [logentry], [Current_Procedure], [Main_Process]', '[Calling_Application]', [Step], [Log_Info=1/0], [Session_Key]		*/				
			
		EXEC dbo.Write_Log 'Info', 'START', @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL
		
		SET @step = 20	
		SET @Log_Entry = 'Importing MTM data for COB ' + cast(@COB AS varchar)
		EXEC dbo.Write_Log 'Info', @Log_Entry, @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL
	
		/*identify the number of desks to be imported */
		SET @step = 40	
		SELECT @counter = count(1) FROM dbo.FilestoImport WHERE [Source] in (@Data_Source) and ToBeImported=1
		
		/*in case nothing is set to be imported, create a related log entry and exit*/
		IF @counter=0 
		BEGIN 
			SET @step = 45			
			SET @Log_Entry = 'Nothing found to get imported.'
			EXEC dbo.Write_Log 'WARNING', @Log_Entry, @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL
			GOTO NoFurtherAction 
		END		
					
		/*prepare a temporary table for imports that gets deleted after import (done at the end of this procedure).*/									
		SET @step=50
		EXEC dbo.Write_Log 'Info', 'Preparing raw data table', @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL
			
		/*drop it first, in case it already exists*/ 
		DROP TABLE if exists dbo.table_unrealised_rawdata_STROLF 

		SET @step=60

		/*NOW WE NEED TO CONSIDER THE STROLF RELATED AVAILBLE FIELDS*/

/*		CREATE TABLE dbo.table_unrealised_rawdata_STROLF
		(
			COB                     nvarchar(255) NULL -- Ziel: DATE
			,REGION                 nvarchar(255) NULL -- Ziel: VARCHAR(255)
			,DESK                   nvarchar(255) NULL -- Ziel: VARCHAR(255) -> STRATEGY
			,DESK_CCY               nvarchar(255) NULL -- Ziel: VARCHAR(255)
			,PORTFOLIO_NAME         nvarchar(255) NULL -- Ziel: VARCHAR(255)
			,PORTFOLIO_ID           nvarchar(255) NULL -- Ziel: VARCHAR(255)
			,BUY_SELL               nvarchar(255) NULL -- Ziel: VARCHAR(255)
			,TRADE_DATE             nvarchar(255) NULL -- Ziel: DATE
			,DEAL_NUM               nvarchar(255) NULL -- Ziel: VARCHAR(255)
			,REALISATION_DATE       nvarchar(255) NULL -- Ziel: DATE
			,REAL_DATE_ORIG         nvarchar(255) NULL -- Ziel: DATE
			,[START_DATE]           nvarchar(255) NULL -- Ziel: DATE
			,END_DATE               nvarchar(255) NULL -- Ziel: DATE
			,LAST_UPDATE            nvarchar(255) NULL -- Ziel: DATE
			,OFFSET                 nvarchar(255) NULL -- Ziel: VARCHAR(255)
			,PNL_TYPE_RISK          nvarchar(255) NULL -- Ziel: VARCHAR(255)
			,PNL_TYPE               nvarchar(255) NULL -- Ziel: VARCHAR(255)
			,PNL_TYPE_ORIG          nvarchar(255) NULL -- Ziel: VARCHAR(255)
			,INS_TYPE_NAME          nvarchar(255) NULL -- Ziel: VARCHAR(255)
			,EXT_BUNIT_NAME         nvarchar(255) NULL -- Ziel: VARCHAR(255)
			,EXT_LENTITY_NAME       nvarchar(255) NULL -- Ziel: VARCHAR(255)
			,EXT_PORTFOLIO_NAME     nvarchar(255) NULL -- Ziel: VARCHAR(255)
			,REFERENCE              nvarchar(255) NULL -- Ziel: VARCHAR(255)
			,INS_REFERENCE          nvarchar(255) NULL -- Ziel: VARCHAR(255)
			,[TYPE]                 nvarchar(255) NULL -- Ziel: VARCHAR(255)
			,SUBTYPE                nvarchar(255) NULL -- Ziel: VARCHAR(255)
			,LEG_UNIT               nvarchar(255) NULL -- Ziel: VARCHAR(255)
			,LEG_CURRENCY           nvarchar(255) NULL -- Ziel: VARCHAR(255)
			,COMMODITY_TYPE         nvarchar(255) NULL -- Ziel: VARCHAR(255)
			,INDEX_NAME             nvarchar(255) NULL -- Ziel: VARCHAR(255)
			,FIXED_PRICE            nvarchar(255) NULL -- Ziel: DECIMAL(18,2)
			,DEAL_VOLUME            nvarchar(255) NULL -- Ziel: FLOAT
			,PNL                    nvarchar(255) NULL -- Ziel: FLOAT
			,UNDISC_PNL             nvarchar(255) NULL -- Ziel: FLOAT
			,UNDISC_PNL_ORIG_CCY    nvarchar(255) NULL -- Ziel: FLOAT
			,CFLOW_TYPE				nvarchar(255) NULL -- Ziel: DECIMAL(10, 0)
		) ON [PRIMARY]
*/				
			
		/*identify the name of the desk to be loaded */					
		SET @step=110	
		SELECT
			 @File_Name = [FileName]
			,@FileID   = ID
		FROM dbo.FilestoImport 
			WHERE [Source] in (@Data_Source) and ToBeImported=1
					
		SET @step=115	
		SET @Log_Entry = 'Import #' + cast(@counter AS varchar) + ' started.'  
		EXEC dbo.Write_Log 'Info', @Log_Entry, @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL


---------------------------------- ANFANG --------------------------------------------- 
			/* the import itself via linked server*/
			SET @sql = 'SELECT * INTO dbo.table_unrealised_rawdata_STROLF FROM OPENQUERY(ROCKCAO_CE, ''SELECT * FROM CAO_CE.XPORT.' + @File_Name + ' WHERE COB = ''''' + @date_cob_string + ''''' AND PNL_TYPE_ORIG = ''''UNREALIZED'''' '')';
			EXECUTE sp_executesql @sql			
---------------------------------- ENDE ---------------------------------------------
			
		SET @step=130
		/*delete old entries in data table */
		DELETE FROM dbo.table_unrealised_01 WHERE DataSource='STROLF'
			
		SET @step=140
		/*refill data table with STROLF data */						

		INSERT INTO dbo.table_unrealised_01
		(
			COB,
			Deal_Number,
			Trade_Date,
			Term_Start,
			Term_End,
--			Legal_Entity,
			Desk_Name,
			Desk_ID,
--			Strategy,
--			Reporting_CCY,
--			Desk_CCY,
			SubDesk,
			Book_Name,
			Book_ID,
			Internal_Portfolio,
			Portfolio_ID,
			Instrument_Type,
			Unit_of_Measure,
			External_Legal_Entity,
			External_Business_Unit,
			External_Portfolio,
			Projection_Index_Name,
			Projection_Index_Group,
--			Product,
			Adjustment_ID,
			Cashflow_Payment_Date,
--			LegEndDate,
			Delivery_Date,
			Delivery_Month,
			Trade_Price,
			Cashflow_Type,
			Cashflow_Type_ID,
			Contract_Name,
			Unit_Of_Account,
			ShortTerm_LongTerm,
			Accounting_Delivery_Month,
			Counterparty_Group,
			Order_Number,
			Partner_Code,
			Active_Period,
			Buy_Sell,
			Orig_Month,
			Accounting_Treatment,
			Volume,
			Volume_Avaliable,
			Volume_Used,
--			AOCI,
			Hedge_ID,
			Hedge_Quote,
			Product_ticker,
			RACE_Position,
			Unrealised_Discounted_Cashflow_CCY,
--			Unrealised_Undiscounted_,
			Realised_Discounted_Cashflow_CCY,
--			Realised_Undiscounted,
			Adjustment_Comment,
			DataSource,
			FileID
		)
		SELECT
			CONVERT(DATE, COB, 103) AS COB,                      -- Umwandlung in DATE
			DEAL_NUM AS Deal_Number,                             -- Direktes Mapping
			CONVERT(DATE, TRADE_DATE, 103) AS Trade_Date,        -- Umwandlung in DATE
			CONVERT(DATE, START_DATE, 103) AS Term_Start,        -- Umwandlung in DATE
			CONVERT(DATE, END_DATE, 103) AS Term_End,            -- Umwandlung in DATE
--			NULL AS Legal_Entity,                                -- Fallback auf NULL
			NULL AS Desk_Name,                                     -- Fallback auf NULL
			NULL AS Desk_ID,                                     -- Fallback auf NULL
--			DESK AS Strategy,                                    -- DESK is the strategy
--			NULL AS Reporting_CCY,                               -- Fallback auf NULL
--			DESK_CCY,                                            -- Direktes Mapping
			NULL AS SubDesk,                                     -- Fallback auf NULL
			NULL AS Book_Name,                                   -- Fallback auf NULL
			NULL AS Book_ID,                                     -- Fallback auf NULL
			PORTFOLIO_NAME AS Internal_Portfolio,                -- Mapping auf Internal_Portfolio
			TRY_CONVERT(INTEGER, PORTFOLIO_ID) AS Portfolio_ID,  -- Mapping auf Internal_Portfolio Id
			INS_TYPE_NAME AS Instrument_Type,                    -- Direktes Mapping
			LEG_UNIT AS Unit_of_Measure,                         -- UOM for this Leg
			EXT_LENTITY_NAME AS External_Legal_Entity,           -- Mapping auf External_Legal_Entity
			EXT_BUNIT_NAME AS External_Counterparty,             -- Mapping auf External_Counterparty
			EXT_PORTFOLIO_NAME AS External_Portfolio,            -- Mapping auf External Portfolio Name
			NULL AS Projection_Index_Name,                       -- Fallback auf NULL
			NULL AS Projection_Index_Group,                      -- Fallback auf NULL
--			NULL AS Product,                                     -- Fallback auf NULL
			NULL AS Adjustment_ID,                               -- Fallback auf NULL
			NULL AS Cashflow_Payment_Date,	                     -- Fallback auf NULL
--			NULL AS LegEndDate,                                  -- Fallback auf NULL
			NULL AS Delivery_Date,                               -- Fallback auf NULL
			NULL AS Delivery_Month,                              -- Fallback auf NULL
			TRY_CONVERT(FLOAT, FIXED_PRICE) AS Trade_Price,	     -- Umwandlung in FLOAT
			NULL AS Cashflow_Type,                               -- Fallback auf NULL
			TRY_CONVERT(INTEGER, CFLOW_TYPE) AS Cashflow_Type_ID, -- Umwandlung in INTEGER
			NULL AS Contract_Name,                               -- Fallback auf NULL
			NULL AS Unit_Of_Account,                             -- Fallback auf NULL
			NULL AS ShortTerm_LongTerm,                          -- Fallback auf NULL
			NULL AS Accounting_Delivery_Month,                   -- Fallback auf NULL
			NULL AS Counterparty_Group,                          -- Fallback auf NULL
			NULL AS Order_Number,                                -- Fallback auf NULL
			NULL AS Partner_Code,                                -- Fallback auf NULL
			NULL AS Active_Period,                               -- Fallback auf NULL
			BUY_SELL,                                            -- Direktes Mapping
			NULL AS Orig_Month,                                  -- Fallback auf NULL
			NULL AS Accounting_Treatment,                        -- Fallback auf NULL
			TRY_CONVERT(FLOAT, DEAL_VOLUME) AS Volume,           -- Umwandlung in FLOAT
			NULL AS Volume_Avaliable,                            -- Fallback auf NULL
			NULL AS Volume_Used,                                 -- Fallback auf NULL
--			NULL AS AOCI,                                        -- Fallback auf NULL
			NULL AS Hedge_ID,                                    -- Fallback auf NULL
			NULL AS Hedge_Quote,                                 -- Fallback auf NULL
			NULL AS Product_ticker,                              -- Fallback auf NULL
			NULL AS RACE_Position,                               -- Fallback auf NULL
			TRY_CONVERT(FLOAT, PNL) AS Unrealised_Discounted,    -- Umwandlung in FLOAT
--			TRY_CONVERT(FLOAT, UNDISC_PNL) AS Unrealised_Undiscounted,    -- Umwandlung in FLOAT
			NULL AS Realised_Discounted,                         -- Fallback auf NULL
--			NULL AS Realised_Undiscounted,                       -- Fallback auf NULL
			NULL AS Comment,		                                   -- Fallback auf NULL
			'STROLF' AS DataSource,																-- hard coded Wert 
			@FileID AS FileID                                      -- Fallback auf NULL
		FROM dbo.table_unrealised_rawdata_STROLF
   
	 	SET @step=150
		/*document import timestamp for just imported file*/
		update dbo.FilestoImport set LastImport = getdate() WHERE id = @FileID

		
		SET @step=250
		/*statistics*/
		SELECT @recordcount =count(*) FROM dbo.table_unrealised_rawdata_STROLF		
		SET @Log_Entry = 'Import ' + @Data_Source + ' View done, records: '+ cast(format(@recordcount,'###,###') AS varchar)
		EXEC dbo.Write_Log 'Info', @Log_Entry, @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL

			
		SET @step=290
		/*-- count total number of imported records*/
		SELECT @recordcount = count(*) FROM dbo.table_unrealised_01 WHERE DataSource like 'STROLF'
				
		SET @Log_Entry = 'Import completely done, records imported: '+ cast(format(@recordcount,'###,###') AS varchar)
		EXEC dbo.Write_Log 'Info', @Log_Entry, @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL

		SET @step = 310
		--/*drop rawdata table again*/ 
		--IF OBJECT_ID ('dbo.table_unrealised_rawdata_ROCK','U') IS NOT NULL  
		--BEGIN
		--	DROP TABLE dbo.table_unrealised_rawdata_ROCK 
		--END

NoFurtherAction:
		SET @step = 400
		EXEC dbo.Write_Log 'Info', 'FINISHED', @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL
	
	/*tell the world procedure was succesful*/
		RETURN 1	
		
END TRY

BEGIN CATCH
	/*tell the world procedure failed*/
	EXEC [dbo].[usp_GetErrorInfo] @Current_Procedure, @step, @Main_Process; 
	EXEC dbo.Write_Log 'Info', 'FAILED.', @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL;
	RETURN @step

END CATCH

GO

