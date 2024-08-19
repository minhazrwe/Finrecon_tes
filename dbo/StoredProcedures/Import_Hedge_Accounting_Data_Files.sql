
CREATE PROCEDURE dbo.Import_Hedge_Accounting_Data_Files
AS 
BEGIN TRY

		DECLARE @proc nvarchar (40)
		DECLARE @step integer
		DECLARE @sql nvarchar (max)
		DECLARE @LogInfo Integer
		DECLARE @counter Integer
		
		DECLARE @filename nvarchar (200)
		DECLARE @FileID integer
		DECLARE @FileSource nvarchar (40)
		DECLARE @importpath nvarchar (400)
		DECLARE @found_file INTEGER	
		
		declare @recordcount as numeric
		declare @COB as date
		
		select @step = 1		
		select @proc = Object_Name(@@PROCID)
		select @FileSource = 'HedgeAccounting'
		select @COB = AsOfDate_EOM from dbo.AsOfDate
		SELECT @found_file = 0

		/* check if logging is globally enabled*/
		select @step = 2
		select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - START', GETDATE () END
				
		select @step = 3						
		SELECT @importpath = [dbo].[udf_get_path](@FileSource) 
		
		/* identify how many file should be imported */
		select @step = 4
		select @counter = count(*) from [dbo].[FilestoImport] where [dbo].[FilestoImport].[Source] in (@FileSource) and ToBeImported=1
		select @found_file = @counter		
		
		/*in case here is no importfile, create a reladed log entry and jump out*/
		select @step = 5
		IF @counter=0 		
		BEGIN 
			if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - nothing found to get imported', GETDATE () END
			GOTO NoFurtherAction 
		END				
		
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - will import ' + CAST(@counter as varchar) + ' files from: ' + @importpath , GETDATE () END

		WHILE @counter >0
		BEGIN						
			
			SELECT @step=100			
			SELECT
				@filename = [FileName]
				,@FileID   = [ID]
			FROM
				(
					select *, ROW_NUMBER() OVER(ORDER BY ID DESC) AS ROW 
					from [dbo].[FilestoImport] 
					where [dbo].[FilestoImport].[Source] in (@FileSource) and ToBeImported=1
				) as TMP 
			WHERE 
				ROW = @counter 
							
			select @step = 110						
			IF @filename = 'HedgingRelationship1.csv'
			BEGIN			
				select @step = 200						
				truncate table dbo.table_HA_Hedging_Relationships_raw 			
				
				SELECT @step =	210
				SELECT @sql = N'BULK INSERT [dbo].[table_HA_Hedging_Relationships_raw] FROM '  + '''' + @importpath + @filename + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR ='','', FIRSTROW = 2, ROWTERMINATOR =''\n'')';
				EXECUTE sp_executesql @sql

				SELECT @step = 220
				truncate table dbo.table_HA_Hedging_Relationships 

				SELECT @step = 230

				INSERT INTO dbo.table_HA_Hedging_Relationships
				(
						COB 
					,Subsidiary
					,Strategy
					,Book
					,Hedge_Rel_Type_ID
					,Hedge_Rel_Type_Name
					,Relation_ID
					,Dedesig_Rel_ID
					,Rel_Type
					,Effective_Date
					,Perfect_Hedge
					,Hedge_Type
					,Ref_Deal_ID
					,Deal_ID
					,Perc_Included
					,Deal_Date
					,Leg
					,Index_Name
					,Term_Start
					,Term_End
					,Buy_Sell
					,Volume
					,Allocated_Volume
					,UOM
					,Frequency
					,Price
					,Internal_Portfolio
					,Counterparty_Group
					,Instrument_Type
					,Projection_Index_Group
					,FileID
				)
				SELECT 
						@COB			
					,Subsidiary
					,Strategy
					,Book
					,convert(int,Hedge_Rel_Type_ID) as Hedge_Rel_Type_ID
					,Hedge_Rel_Type_Name
					,convert(int,Relation_ID) as Relation_ID
					,convert(int,Dedesig_Rel_ID) as Dedesig_Rel_ID
					,Rel_Type
					,convert(date,Effective_Date,103) as Effective_Date
					,Perfect_Hedge
					,Hedge_Type
					,convert(int,Ref_Deal_ID) as Ref_Deal_ID
					,convert(int,Deal_ID) as Deal_ID 
					,convert(float, Perc_Included) as Perc_Included
					,convert(date, Deal_Date,103) as Deal_Date
					,convert(int,Leg) as Leg
					,Index_Name
					,convert(date, Term_Start,103) as Term_Start
					,convert(date, Term_End,103) as Term_End
					,Buy_Sell
					,convert(float, Volume) as Volume
					,convert(float, Allocated_Volume) as Allocated_Volume
					,UOM
					,Frequency
					,convert(float, Price) as Price
					,Internal_Portfolio
					,Counterparty_Group
					,Instrument_Type
					,Projection_Index_Group
					,@FileID        
				FROM
					dbo.table_HA_Hedging_Relationships_raw

				select @recordcount =count(*) from dbo.table_HA_Hedging_Relationships_raw											
			END /*IF @filename = 'HedgingRelationship.csv'*/
	
			select @step = 120						
			IF @filename = 'Measurement_report_detailed1.csv'
			BEGIN			
				select @step = 300						
				truncate table dbo.table_HA_Measurement_report_detailed_raw 			
				
				SELECT @step =	310
				SELECT @sql = N'BULK INSERT [dbo].[table_HA_Measurement_report_detailed_raw] FROM '  + '''' + @importpath + @filename + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR ='','', FIRSTROW = 2, ROWTERMINATOR =''\n'')';
				EXECUTE sp_executesql @sql
				
				SELECT @step =	315 /*get rid of 'nulls' that are text rather than nothing*/
				update dbo.table_HA_Measurement_report_detailed_raw
				SET 
					Sub = case when Sub ='Null' then null else Sub end,
					Strategy = case when Strategy ='Null' then null else Strategy end,
					Book = case when Book ='Null' then null else Book end,
					Der_Item = case when Der_Item ='Null' then null else Der_Item end,
					Deal_REF_ID = case when Deal_REF_ID ='Null' then null else Deal_REF_ID end,
					Deal_ID = case when Deal_ID ='Null' then null else Deal_ID end,
					Rel_ID = case when Rel_ID ='Null' then null else Rel_ID end,
					DeDesig_Rel_ID = case when DeDesig_Rel_ID ='Null' then null else DeDesig_Rel_ID end,
					Rel_TYPE = case when Rel_TYPE ='Null' then null else Rel_TYPE end,
					Counterparty = case when Counterparty ='Null' then null else Counterparty end,
					Deal_DATE = case when Deal_DATE ='Null' then null else Deal_DATE end,
					Rel_Eff_DATE = case when Rel_Eff_DATE ='Null' then null else Rel_Eff_DATE end,
					DeDesig_DATE = case when DeDesig_DATE ='Null' then null else DeDesig_DATE end,
					Term = case when Term ='Null' then null else Term end,
					Perc = case when Perc ='Null' then null else Perc end,
					Total_Volume = case when Total_Volume ='Null' then null else Total_Volume end,
					Volume_Used = case when Volume_Used ='Null' then null else Volume_Used end,
					UOM = case when UOM ='Null' then null else UOM end,
					Index_Name = case when Index_Name ='Null' then null else Index_Name end,
					DF = case when DF ='Null' then null else DF end,
					Deal_Price = case when Deal_Price ='Null' then null else Deal_Price end,
					Market_Price = case when Market_Price ='Null' then null else Market_Price end,
					Inception_Price = case when Inception_Price ='Null' then null else Inception_Price end,
					CCY = case when CCY ='Null' then null else CCY end,
					Cum_FV = case when Cum_FV ='Null' then null else Cum_FV end,
					Cum_INT_FV = case when Cum_INT_FV ='Null' then null else Cum_INT_FV end,
					Incpt_FV = case when Incpt_FV ='Null' then null else Incpt_FV end,
					Incpt_INT_FV = case when Incpt_INT_FV ='Null' then null else Incpt_INT_FV end,
					Cum_Hedge_FV = case when Cum_Hedge_FV ='Null' then null else Cum_Hedge_FV end,
					Hedge_AOCI_Ratio = case when Hedge_AOCI_Ratio ='Null' then null else Hedge_AOCI_Ratio end,
					Dollar_Offset_Ratio = case when Dollar_Offset_Ratio ='Null' then null else Dollar_Offset_Ratio end,
					Test_Result = case when Test_Result ='Null' then null else Test_Result end,
					AOCI = case when AOCI ='Null' then null else AOCI end,
					PNL = case when PNL ='Null' then null else PNL end,
					AOCI_Released = case when AOCI_Released ='Null' then null else AOCI_Released end,
					PNL_Settled = case when PNL_Settled ='Null' then null else PNL_Settled end

					
				SELECT @step = 320
				truncate table dbo.table_HA_Measurement_report_detailed

				SELECT @step = 330
				INSERT INTO dbo.table_HA_Measurement_report_detailed
				(
					 cob
					,Valuation_DATE
					,Sub
					,Strategy
					,Book
					,DER_Item
					,Deal_REF_ID
					,Deal_ID
					,Rel_ID
					,DeDesig_Rel_ID
					,Rel_TYPE
					,Counterparty
					,Deal_DATE
					,Rel_Eff_DATE
					,DeDesig_DATE
					,Term
					,Perc
					,Total_Volume
					,Volume_Used
					,UOM
					,Index_Name
					,DF
					,Deal_Price
					,Market_Price
					,Inception_Price
					,CCY
					,Cum_FV
					,Cum_INT_FV
					,Incpt_FV
					,Incpt_INT_FV
					,Cum_Hedge_FV
					,Hedge_AOCI_Ratio
					,Dollar_Offset_Ratio
					,Test_result
					,AOCI
					,PNL
					,AOCI_Released
					,PNL_Settled
					,FileID
				)
				SELECT 
					 @COB,
					convert(date, Valuation_DATE,103) as Valuation_DATE
					,Sub
					,Strategy
					,Book
					,DER_Item
					,convert(int,Deal_REF_ID) as Deal_REF_ID
					,convert(int,Deal_ID) as Deal_ID
					,convert(int,Rel_ID) as Rel_ID
					,convert(int,DeDesig_Rel_ID) as DeDesig_Rel_ID
					,Rel_TYPE
					,Counterparty
					,convert(date, Deal_DATE,103) as Deal_DATE
					,convert(date, Rel_Eff_DATE,103) as Rel_Eff_DATE
					,convert(date, case when DeDesig_DATE = 'Null' then NULL else isnull(DeDesig_DATE,NULL) end,103) as DeDesig_DATE					
					,convert(date, Term,103) as Term
					,convert(float,Perc) as Perc
					,convert(float,Total_Volume) as Total_Volume
					,convert(float,Volume_Used) as Volume_Used
					,UOM
					,Index_Name
					,DF
					,convert(float,Deal_Price) as Deal_Price
					,convert(float,Market_Price) as Market_Price
					,convert(float,Inception_Price) as Inception_Price
					,CCY
					,convert(float,Cum_FV) as Cum_FV
					,convert(float,Cum_INT_FV) as Cum_INT_FV
					,convert(float,Incpt_FV) as Incpt_FV
					,convert(float,Incpt_INT_FV) as Incpt_INT_FV
					,convert(float,Cum_Hedge_FV) as Cum_Hedge_FV
					,convert(float, case when Hedge_AOCI_Ratio = 'Null' then NULL else isnull(Hedge_AOCI_Ratio,NULL) end) as DeDesig_DATE					
					,convert(float, case when Dollar_Offset_Ratio = 'Null' then NULL else isnull(Dollar_Offset_Ratio,NULL) end) as Dollar_Offset_Ratio
					,Test_Result
					,convert(float, case when AOCI = 'Null' then NULL else isnull(AOCI,NULL) end) as AOCI
					,convert(float,PNL) as PNL
					,convert(float,AOCI_Released) as AOCI_Released
					,convert(float,PNL_Settled) as PNL_Settled
					,@FileID
				FROM 
					dbo.table_HA_Measurement_report_detailed_raw

				select @recordcount =count(*) from dbo.table_HA_Measurement_report_detailed_raw	

		END/*IF @filename = 'Measurement_report_detailed.csv'*/
			
		SELECT @step = 130						
		IF @filename = 'Trades1.csv'
		BEGIN			
				select @step = 400						
				truncate table dbo.table_HA_Trades_raw 			
				
				SELECT @step =	410
				SELECT @sql = N'BULK INSERT [dbo].[table_HA_Trades_raw] FROM '  + '''' + @importpath + @filename + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR ='','', FIRSTROW = 2, ROWTERMINATOR =''\n'')';
				EXECUTE sp_executesql @sql

				SELECT @step = 420
				truncate table dbo.table_HA_Trades
				/*hier nochmal die converts checken !*/
				SELECT @step = 430
				INSERT INTO dbo.table_HA_Trades
				(
					COB
					,Reference_ID
					,Trade_Date
					,Term_Start
					,Term_End
					,Internal_Portfolio
					,Counterparty_Group
					,Volume
					,Curve_Name
					,Projection_Index_Group
					,Instrument_Type
					,Int_Bunit
					,Ext_Portfolio
					,Discounted_PNL
					,Start_Date
					,End_Date
					,Strategy
					,Subsidiary
					,Accounting_Treatment
					,FileID
				)
				SELECT 
					convert(date, @COB,103) as cob
					,convert(integer,Reference_ID) as Reference_ID
					,convert(date, Trade_Date,103) as Trade_Date
					,convert(date, Term_Start,103) as Term_Start
					,convert(date, Term_End,103) as Term_End
					,Internal_Portfolio
					,Counterparty_Group
					,convert(float,Volume) as Volume
					,Curve_Name
					,Projection_Index_Group
					,Instrument_Type
					,Int_Bunit
					,Ext_Portfolio
					,convert(float,Discounted_PNL) as Discounted_PNL
					,convert(date, [Start_Date],103) as [Start_Date]
					,convert(date, End_Date,103) as End_Date
					,Strategy
					,Subsidiary
					,Accounting_Treatment
					,@FileID as fileID
				FROM 
					dbo.table_HA_Trades_raw
		
			select @recordcount = count(*) from dbo.table_HA_Trades_raw	
			
			
			END/*IF @filename = 'Trades.csv'*/

			SELECT @step=140		

			if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - file #' + cast(format(@counter,'#,#.#') as varchar) + ': ' + @filename +', records imported: ' + CAST(@recordcount as varchar), GETDATE ()	END
			
			/*document import timestamp fpor just imported file*/
			SELECT @step=150
			update dbo.FilestoImport set LastImport = getdate() where id = @FileID
		
			/*reduce counter*/
			SELECT @step=160
			select @counter = @counter - 1			
		
		END /*while counter > 0*/
		
NoFurtherAction:
		select @step = 180
		IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - FINISHED', GETDATE () END				
		RETURN iif (@found_file = 3, 1,@found_file)  /*tell the world procedure was succesful*/
			 		
END TRY

BEGIN CATCH
	/*tell the world that the procedure failed*/
	EXEC [dbo].[usp_GetErrorInfo] @proc, @step
	BEGIN insert into [dbo].[Logfile] select @proc + ' - FAILED', GETDATE () END	
	RETURN @step

END CATCH

GO

