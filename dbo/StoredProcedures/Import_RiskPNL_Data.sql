





/* ==========================================
Author:				MBE														
Created:			2022/06											
Description:	importing ROCK Risk PnL Data  
Refurbished:	2022/10 (mkb)									
==================Changelog==================
DATE			STEP	USER		CHANGE
2024-08-13		14		MK			Added deletion of surplus entries

*/

CREATE PROCEDURE [dbo].[Import_RiskPNL_Data] 
AS
BEGIN TRY

	DECLARE @step Integer		
	DECLARE @proc nvarchar(50)
	DECLARE @LogInfo Integer	
	DECLARE @FileSource nvarchar(300)
	DECLARE @PathName nvarchar (300)
	DECLARE @FileName nvarchar(300)
	DECLARE @FileID Integer				
	DECLARE @sql nvarchar (max)
	DECLARE @counter Integer
	DECLARE @RecordCounter1 Integer
		
	SELECT @proc = Object_Name(@@PROCID)
	
	SET @FileSource = 'RISKPNL'
	
  --/* get Info if Logging is enabled */
	SELECT @step = 1
	SELECT @LogInfo = [dbo].[LogInfo].[LogInfo] FROM [dbo].[LogInfo]

	IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - START', GETDATE () END
	IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - identify and load import files', GETDATE () END
		
	--/*identify importpath (same for all mtm files)*/
	SELECT @step = 2
	SELECT @PathName = [dbo].[udf_get_path](@FileSource)

	--/*use a counter to get all available files*/
	SELECT @step = 3
	SELECT @counter = count(*) FROM [dbo].[FilestoImport] WHERE  [dbo].[FilestoImport].[Source] like @FileSource and ToBeImported=1
	
	--/*in case here is no importfile, create a reladed log entry and jump out*/
	SELECT @step = 4
	IF @counter=0 
	BEGIN 
		INSERT INTO [dbo].[Logfile] SELECT @proc + ' - no data found to get imported.', GETDATE () 		
		GOTO NoFurtherAction 
	END		
	
	
	IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - importing ' + cast(@counter as varchar) + ' files from ' + @PathName, GETDATE () END			
	--/*loop over counter, reduce it at the end*/ 	
	WHILE @counter >0
		BEGIN			
			--/*identify importfile(s)*/
		  SELECT @step=10
			SELECT 
				 @FileName = [FileName]
				,@FileID = [ID] 
			FROM 
				(SELECT *, ROW_NUMBER() OVER(ORDER BY ID) AS ROW 
				 FROM [dbo].[FilestoImport] 
				 WHERE 
					[dbo].[FilestoImport].[Source] like @FileSource 
					and ToBeImported=1
				) as TMP 
			WHERE ROW = @counter

			SELECT @step=11			
			IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'table_RISK_PNL_Rawdata_tmp'))
			BEGIN DROP TABLE dbo.table_RISK_PNL_Rawdata_tmp END
			
			SELECT @step=12
			CREATE TABLE finrecon.dbo.table_RISK_PNL_Rawdata_tmp
			(
				[COB] [nvarchar](100) NULL,
				[DESK_NAME] [nvarchar](100) NULL,
				[INTERMEDIATE1_NAME] [nvarchar](100) NULL,
				[INTERMEDIATE2_NAME] [nvarchar](100) NULL,
				[INTERMEDIATE3_NAME] [nvarchar](100) NULL,
				[BOOK_NAME] [nvarchar](100) NULL,
				[PORTFOLIO_NAME] [nvarchar](100) NULL,
				[INSTRUMENT_TYPE_NAME] [nvarchar](100) NULL,
				[EXT_BUSINESS_UNIT_NAME] [nvarchar](100) NULL,
				[DEAL_NUMBER] [nvarchar](100) NULL,
				[CASHFLOW_SETTLEMENT_TYPE] [nvarchar](100) NULL,
				[INSTRUMENT_REFERENCE_TEXT] [nvarchar](100) NULL,
				[TRANSACTION_STATUS_NAME] [nvarchar](100) NULL,
				[SOURCE_OF_ROW] [nvarchar](100) NULL,
				[CASHFLOW_CURRENCY] [nvarchar](100) NULL,
				[BUSINESS_LINE_CURRENCY] [nvarchar](100) NULL,
				[INTERMEDIATE1_CURRENCY] [nvarchar](100) NULL,
				INTERNAL_LEGAL_ENTITY_PARTY_NAME  [nvarchar](100) NULL,
				DEAL_PDC_END_DATE [nvarchar](100) NULL,
				CASHFLOW_PAYMENT_DATE [nvarchar](100) NULL,
                [INTERNAL_ORDER_ID] [nvarchar](200) NULL,
				[REAL_DISC_CASHFLOW_CCY] [float] NULL,
				[UNREAL_DISC_CASHFLOW_CCY] [float] NULL,
				[REAL_UNDISC_CASHFLOW_CCY] [float] NULL,
				[UNREAL_UNDISC_CASHFLOW_CCY] [float] NULL,
				[REAL_DISC_CASHFLOW_CCY_LGBY] [float] NULL,
				[UNREAL_DISC_CASHFLOW_CCY_LGBY] [float] NULL,
				[REAL_UNDISC_CASHFLOW_CCY_LGBY] [float] NULL,
				[UNREAL_UNDISC_CASHFLOW_CCY_LGBY] [float] NULL,
				[REAL_DISC_BL_CCY] [float] NULL,
				[UNREAL_DISC_BL_CCY] [float] NULL,
				[REAL_UNDISC_BL_CCY] [float] NULL,
				[UNREAL_UNDISC_BL_CCY] [float] NULL,
				[REAL_DISC_BL_CCY_LGBY] [float] NULL,
				[UNREAL_DISC_BL_CCY_LGBY] [float] NULL,
				[REAL_UNDISC_BL_CCY_LGBY] [float] NULL,
				[UNREAL_UNDISC_BL_CCY_LGBY] [float] NULL,
				[REAL_DISC_IM1_CCY] [float] NULL,
				[UNREAL_DISC_IM1_CCY] [float] NULL,
				[REAL_UNDISC_IM1_CCY] [float] NULL,
				[UNREAL_UNDISC_IM1_CCY] [float] NULL,
				[REAL_DISC_IM1_CCY_LGBY] [float] NULL,
				[UNREAL_DISC_IM1_CCY_LGBY] [float] NULL,
				[REAL_UNDISC_IM1_CCY_LGBY] [float] NULL,
				[UNREAL_UNDISC_IM1_CCY_LGBY] [float] NULL,
				[REAL_DISC_PH_BL_CCY] [float] NULL,
				[UNREAL_DISC_PH_BL_CCY] [float] NULL,
				[REAL_UNDISC_PH_BL_CCY] [float] NULL,
				[UNREAL_UNDISC_PH_BL_CCY] [float] NULL,
				[REAL_DISC_PH_BL_CCY_LGBY] [float] NULL,
				[UNREAL_DISC_PH_BL_CCY_LGBY] [float] NULL,
				[REAL_UNDISC_PH_BL_CCY_LGBY] [float] NULL,
				[UNREAL_UNDISC_PH_BL_CCY_LGBY] [float] NULL,
				[REAL_DISC_PH_IM1_CCY] [float] NULL,
				[UNREAL_DISC_PH_IM1_CCY] [float] NULL,
				[REAL_UNDISC_PH_IM1_CCY] [float] NULL,
				[UNREAL_UNDISC_PH_IM1_CCY] [float] NULL,
				[REAL_DISC_PH_IM1_CCY_LGBY] [float] NULL,
				[UNREAL_DISC_PH_IM1_CCY_LGBY] [float] NULL,
				[REAL_UNDISC_PH_IM1_CCY_LGBY] [float] NULL,
				[UNREAL_UNDISC_PH_IM1_CCY_LGBY] [float] NULL,
				REAL_DISC_PH_IM1_CCY_YTD [float] NULL,
				UNREAL_DISC_PH_IM1_CCY_YTD [float] NULL,
				TOTAL_VALUE_PH_IM1_CCY_YTD [float] NULL,
				REAL_DISC_PH_BL_CCY_YTD [float] NULL,
				UNREAL_DISC_PH_BL_CCY_YTD [float] NULL,
				TOTAL_VALUE_PH_BL_CCY_YTD [float] NULL,
				REAL_DISC_CASHFLOW_CCY_YTD [float] NULL,
				REAL_UNDISC_CASHFLOW_CCY_YTD [float] NULL,
				REAL_UNDISC_PH_BL_CCY_YTD [float] NULL
			) 
							
			--/*import data into temp table*/		
			SELECT @step=13		
			SELECT @sql = N'BULK INSERT dbo.table_RISK_PNL_Rawdata_tmp FROM '  + '''' + @PathName + @filename + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR =''~'', FIRSTROW = 2, ROWTERMINATOR =''0x0a'')';
			EXECUTE sp_executesql @sql

			SELECT @step=14
			/*number of Records before deleting entries*/
			select @RecordCounter1 = count(1) from [dbo].[table_RISK_PNL_Rawdata_tmp]
			
			IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - imported ' + cast(@counter as varchar) + ': ' + @filename + ' - records totals: ' + cast(format(@RecordCounter1,'#,#') as varchar) , GETDATE () END

			-- 2024-08-13 MK: Added deletion of surplus entries. Requested by Gina Tenuta
			DELETE FROM [FinRecon].[dbo].[table_RISK_PNL_Rawdata_tmp] WHERE [DESK_NAME] IN ('QUANTITATIVE TRADING DESK', 'BIOFUELS DESK', 'UK TRADING DESK') AND INSTRUMENT_TYPE_NAME = 'CASH'

			/*number of deleted Records*/
			select @RecordCounter1 = @RecordCounter1 - (SELECT count(1) from [dbo].[table_RISK_PNL_Rawdata_tmp])
			IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - imported ' + cast(@counter as varchar) + ': ' + @filename + ' - records deleted: ' + cast(format(@RecordCounter1,'#,#') as varchar) , GETDATE () END

			SELECT @step=15
			/*remove potential existing data for this cob from final data table*/
			delete from [FinRecon].[dbo].[GloriRisk] where fileid = @FileID
			
			SELECT @step=16
			/*refill final table*/
			INSERT INTO [FinRecon].[dbo].[GloriRisk] 
			(
				 [COB]
				,DESK_NAME
				,[L05 - Intermediate2 (Current Name)]
				,[L06 - Intermediate3 (Current Name)]
				,[L10 - Book (Current Name)]
				,[Internal Portfolio Name]
				,[Instrument Type Name]
				,[Ext Business Unit Name]
				,[Trade Deal Number]
				,[Cashflow Settlement Type]
				,[Trade Instrument Reference Text]
				,[Trade Currency]
				,INTERNAL_LEGAL_ENTITY_PARTY_NAME
				,DEAL_PDC_END_DATE 
				,CASHFLOW_PAYMENT_DATE 
				,[Realised Undiscounted Original Currency]
				,[Realised Undiscounted Original Currency GPG EOLY]
				,[Unrealised Discounted (EUR)]
				,[Unrealised Discounted EUR GPG EOLY]
				,[Realised Discounted (EUR)]
				,[Realised Undiscounted (EUR)]
				,[Realised Discounted EUR GPG EOLY]
				,[Unrealised Discounted (USD)]
				,[Unrealised Discounted USD GPG EOLY]
				,[Realised Discounted (USD)]
				,[Realised Undiscounted USD]
				,[Realised Discounted USD GPG EOLY]
				,[Unrealised Discounted (AUD)]
				,[Unrealised Discounted Original Currency GPG EOLY]
				,[Realised Discounted (AUD)]
				,[Realised Undiscounted (AUD)]
				,[Realised Discounted Original Currency GPG EOLY]
				,[Unrealised Discounted (GBP)]
				,[Unrealised Discounted GBP GPG EOLY]
				,[Realised Discounted (GBP)]
				,[Realised Undiscounted (GBP)]
				,[Realised Discounted GBP GPG EOLY]
				/*additionally storing as well the data from the original ROCK related metrics*/
				,TOTAL_VALUE_PH_IM1_CCY_YTD
				,REAL_DISC_PH_IM1_CCY_YTD
				,UNREAL_DISC_PH_IM1_CCY
				,UNREAL_DISC_PH_IM1_CCY_LGBY
				,TOTAL_VALUE_PH_BL_CCY_YTD
				,REAL_DISC_PH_BL_CCY_YTD
				,UNREAL_DISC_PH_BL_CCY
				,UNREAL_DISC_PH_BL_CCY_LGBY
				,UNREAL_DISC_BL_CCY
				,UNREAL_DISC_BL_CCY_LGBY
				,REAL_UNDISC_CASHFLOW_CCY_YTD
				,[FileId]
			)
			SELECT 				
				CONVERT(date, COB ,103) as COB
				,DESK_NAME
				,INTERMEDIATE2_NAME
				,INTERMEDIATE3_NAME
				,BOOK_NAME
				,PORTFOLIO_NAME
				,INSTRUMENT_TYPE_NAME
				,EXT_BUSINESS_UNIT_NAME
				,DEAL_NUMBER
				,CASHFLOW_SETTLEMENT_TYPE
				,CASE WHEN INSTRUMENT_REFERENCE_TEXT = '' THEN 'not assigned' ELSE INSTRUMENT_REFERENCE_TEXT END as [Trade Instrument Reference Text]
				,CASHFLOW_CURRENCY
				,INTERNAL_LEGAL_ENTITY_PARTY_NAME
				,CONVERT(date,DEAL_PDC_END_DATE,103) as DEAL_PDC_END_DATE 
				,CONVERT(date,CASHFLOW_PAYMENT_DATE,103) as CASHFLOW_PAYMENT_DATE
				,cast(REAL_UNDISC_CASHFLOW_CCY as float) as [Realised Undiscounted Original Currency] 
				,cast(REAL_UNDISC_CASHFLOW_CCY_LGBY as float) as [Realised Undiscounted Original Currency GPG EOLY]
				,cast(UNREAL_DISC_PH_BL_CCY as float)  as [Unrealised Discounted (EUR)]
				,cast(UNREAL_DISC_PH_BL_CCY_LGBY as float) as [Unrealised Discounted EUR GPG EOLY]
				,cast(REAL_DISC_PH_BL_CCY as float)  as [Realised Discounted (EUR)]
				,cast(REAL_UNDISC_PH_BL_CCY as float) as [Realised Undiscounted (EUR)]
				,cast(REAL_DISC_PH_BL_CCY_LGBY as float)  as [Realised Discounted EUR GPG EOLY]
				,iif(INTERMEDIATE1_CURRENCY ='USD',cast(UNREAL_DISC_PH_IM1_CCY as float),0) as [Unrealised Discounted (USD)] 
				,iif(INTERMEDIATE1_CURRENCY ='USD',cast(UNREAL_DISC_PH_IM1_CCY_LGBY as float),0) as [Unrealised Discounted USD GPG EOLY] 
				,iif(INTERMEDIATE1_CURRENCY ='USD',cast(REAL_DISC_PH_IM1_CCY as float),0) as [Realised Discounted (USD)]
				,iif(INTERMEDIATE1_CURRENCY ='USD',cast(REAL_UNDISC_PH_IM1_CCY as float),0) as [Realised Undiscounted USD]
				,iif(INTERMEDIATE1_CURRENCY ='USD',cast(REAL_UNDISC_PH_IM1_CCY_LGBY as float),0) as [Realised Discounted USD GPG EOLY]
				,iif(INTERMEDIATE1_CURRENCY ='AUD',cast(UNREAL_DISC_PH_IM1_CCY as float),0) as [Unrealised Discounted (AUD)]
				,cast(UNREAL_DISC_CASHFLOW_CCY_LGBY as float) as [Unrealised Discounted Original Currency GPG EOLY] 
				,iif(INTERMEDIATE1_CURRENCY ='AUD',cast(REAL_DISC_PH_IM1_CCY as float),0) as [Realised Discounted (AUD)]
				,iif(INTERMEDIATE1_CURRENCY ='AUD',cast(REAL_UNDISC_PH_IM1_CCY as float),0) as [Realised Undiscounted AUD]
				,cast(REAL_DISC_CASHFLOW_CCY_LGBY as float) as [Realised Discounted Original Currency GPG EOLY]
				,iif(INTERMEDIATE1_CURRENCY ='GBP',cast(UNREAL_DISC_PH_IM1_CCY as float),0) as [Unrealised Discounted (GBP)] 
				,iif(INTERMEDIATE1_CURRENCY ='GBP',cast(UNREAL_DISC_PH_IM1_CCY_LGBY as float),0) as [Unrealised Discounted GBP GPG EOLY] 
				,iif(INTERMEDIATE1_CURRENCY ='GBP',cast(REAL_DISC_PH_IM1_CCY as float),0) as [Realised Discounted (GBP)]
				,iif(INTERMEDIATE1_CURRENCY ='GBP',cast(REAL_UNDISC_PH_IM1_CCY as float),0) as [Realised Undiscounted GBP]
				,iif(INTERMEDIATE1_CURRENCY ='GBP',cast(REAL_UNDISC_PH_IM1_CCY_LGBY as float),0) as [Realised Discounted GBP GPG EOLY]
				/*additionally storing as well the data from the original ROCK related metrics*/
				,cast(TOTAL_VALUE_PH_IM1_CCY_YTD as float) as TOTAL_VALUE_PH_IM1_CCY_YTD
				,cast(REAL_DISC_PH_IM1_CCY_YTD as float) as REAL_DISC_PH_IM1_CCY_YTD
				,cast(UNREAL_DISC_PH_IM1_CCY as float) as UNREAL_DISC_PH_IM1_CCY
				,cast(UNREAL_DISC_PH_IM1_CCY_LGBY as float) as UNREAL_DISC_PH_IM1_CCY_LGBY
				,cast(TOTAL_VALUE_PH_BL_CCY_YTD as float) as TOTAL_VALUE_PH_BL_CCY_YTD
				,cast(REAL_DISC_PH_BL_CCY_YTD as float) as REAL_DISC_PH_BL_CCY_YTD
				,cast(UNREAL_DISC_PH_BL_CCY as float) as UNREAL_DISC_PH_BL_CCY
				,cast(UNREAL_DISC_PH_BL_CCY_LGBY as float) as UNREAL_DISC_PH_BL_CCY_LGBY
				,cast(UNREAL_DISC_BL_CCY as float) as UNREAL_DISC_BL_CCY
				,cast(UNREAL_DISC_BL_CCY_LGBY as float) as UNREAL_DISC_BL_CCY_LGBY
				,cast(REAL_UNDISC_CASHFLOW_CCY_YTD as float) as REAL_UNDISC_CASHFLOW_CCY_YTD				
				,@FileID
			FROM 
				[FinRecon].[dbo].[table_RISK_PNL_Rawdata_tmp] 
			
								
			SELECT @step=17		
			/*document the last successful import timestamp */
			update [dbo].[FilestoImport] set LastImport = getdate() WHERE [Source] like @FileSource and [filename]= @filename 

/*========================================================================================================================================*/
/*================================== update signage for BMT ==============================================================================*/
/*========================================================================================================================================*/
				/* fileid 1944 = "RiskPNL - UK - CAO UK.txt"	--> glori related */
				/* fileid 2909 / 3153 / 3154 = "Fin_Risk_PnL_CAOUK.csv"			--> rock related	*/

			if @fileid in ( 2909, 3153, 3154 )
			BEGIN
				BEGIN insert into [dbo].[Logfile] select @proc + ' - update signage for CAO UK-BMT-File (ID 2909, 3153, 3154)', GETDATE () END

				select @step = 20
				UPDATE dbo.GloriRisk SET 
					[Realised Undiscounted Original Currency] = -[Realised Undiscounted Original Currency] , 
					[Realised Undiscounted Original Currency GPG EOLY] = -[Realised Undiscounted Original Currency GPG EOLY] , 
					[Unrealised Discounted (EUR)] = -[Unrealised Discounted (EUR)] , 
					[Unrealised Discounted EUR GPG EOLY] = -[Unrealised Discounted EUR GPG EOLY] , 
					[Realised Discounted (EUR)] = -[Realised Discounted (EUR)] , 
					[Realised Undiscounted (EUR)] = -[Realised Undiscounted (EUR)] , 
					[Realised Discounted EUR GPG EOLY] = -[Realised Discounted EUR GPG EOLY] , 
					[Unrealised Discounted (USD)] = -[Unrealised Discounted (USD)] , 
					[Unrealised Discounted USD GPG EOLY] = -[Unrealised Discounted USD GPG EOLY] , 
					[Realised Discounted (USD)] = -[Realised Discounted (USD)] , 
					[Realised Undiscounted USD] = -[Realised Undiscounted USD] , 
					[Realised Discounted USD GPG EOLY] = -[Realised Discounted USD GPG EOLY] , 
					[Unrealised Discounted (AUD)] = -[Unrealised Discounted (AUD)] , 
					[Unrealised Discounted Original Currency GPG EOLY] = -[Unrealised Discounted Original Currency GPG EOLY] , 
					[Realised Discounted (AUD)] = -[Realised Discounted (AUD)] , 
					[Realised Undiscounted (AUD)] = -[Realised Undiscounted (AUD)] , 
					[Realised Discounted Original Currency GPG EOLY] = -[Realised Discounted Original Currency GPG EOLY] , 
					[Unrealised Discounted (GBP)] = -[Unrealised Discounted (GBP)] , 
					[Unrealised Discounted GBP GPG EOLY] = -[Unrealised Discounted GBP GPG EOLY] , 
					[Realised Discounted (GBP)] = -[Realised Discounted (GBP)] , 
					[Realised Undiscounted (GBP)] = -[Realised Undiscounted (GBP)] , 
					[Realised Discounted GBP GPG EOLY] = -[Realised Discounted GBP GPG EOLY],
					/*additionally updating the original ROCK related metrics*/
					TOTAL_VALUE_PH_IM1_CCY_YTD = -TOTAL_VALUE_PH_IM1_CCY_YTD,
					REAL_DISC_PH_IM1_CCY_YTD = -REAL_DISC_PH_IM1_CCY_YTD,
					UNREAL_DISC_PH_IM1_CCY = -UNREAL_DISC_PH_IM1_CCY,
					UNREAL_DISC_PH_IM1_CCY_LGBY = -UNREAL_DISC_PH_IM1_CCY_LGBY,
					TOTAL_VALUE_PH_BL_CCY_YTD = -TOTAL_VALUE_PH_BL_CCY_YTD,
					REAL_DISC_PH_BL_CCY_YTD = -REAL_DISC_PH_BL_CCY_YTD,
					UNREAL_DISC_PH_BL_CCY = -UNREAL_DISC_PH_BL_CCY,
					UNREAL_DISC_PH_BL_CCY_LGBY = -UNREAL_DISC_PH_BL_CCY_LGBY,
					UNREAL_DISC_BL_CCY = -UNREAL_DISC_BL_CCY,
					UNREAL_DISC_BL_CCY_LGBY = -UNREAL_DISC_BL_CCY_LGBY,
					REAL_UNDISC_CASHFLOW_CCY_YTD = -REAL_UNDISC_CASHFLOW_CCY_YTD
				where 
					fileid in ( 2909, 3153, 3154 )  /*Fin_Risk_PnL_CAOUK.csv*/
					and [Internal Portfolio Name] = 'CAO_UK_AOM_CSS_BMT'
			END
			
			SELECT @step=25
			/*reduce filecounter*/
			SELECT @counter = @counter - 1
		END				

		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - FINISHED', GETDATE () END

NoFurtherAction:
		/*down here the drops is gelutscht*/

	END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step		
		BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - FAILED', GETDATE () END
	END CATCH

GO

