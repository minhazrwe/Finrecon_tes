









/*
-- =============================================
-- Author: MBE/MKB
-- Created: 2022/10
-- Description:	importing the adjustment data file from Risk System
---------------------------------------------------------------------------------
updates/changes:
2024-07-16, After Step 66: Deactivated code to reach numbers desired by Nina Schlossarek and Osama Abo Jaib in Asia Pacific RevRec.
2024-07-31, added new columns to table_RISK_ADJUSTMENTS // PG
-- =============================================
*/

CREATE PROCEDURE [dbo].[Import_RiskAdjustment_Data]
AS
BEGIN TRY

		DECLARE @proc				nvarchar(50)
		DECLARE @step				Integer
		DECLARE @LogInfo			Integer
		DECLARE @FileSource			nvarchar(300)
		DECLARE @PathName			nvarchar (300)
		DECLARE @FileName			nvarchar(300)
		DECLARE @FileID				Integer
		DECLARE @sql				nvarchar (max)
		DECLARE @RecordsAffected	integer

		SELECT @proc = Object_Name(@@PROCID)

		 --/* get Info if Logging is enabled */
		SELECT @LogInfo = [dbo].[LogInfo].[LogInfo] FROM [dbo].[LogInfo]

		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - START', GETDATE () END
		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - identify and load import files', GETDATE () END

		SET @FileSource = 'RiskADJUSTMENT'

		--/*identify importpath (same for all files)*/
		SELECT @step= 2
		SELECT @PathName = [dbo].[udf_get_path]('RiskAdjustment')

		SELECT @step= 3
		SELECT
			 @FileName = [FileName]
			,@FileID = ID
		FROM
			dbo.FilestoImport
		WHERE
			Source = @FileSource

		--IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - identify and load import files ' + @PathName + @FileName, GETDATE () END

		SELECT @step=4
		TRUNCATE TABLE dbo.table_ADJUSTMENT_Rawdata

		SELECT @step=5
		--/*import data into raw data table */
		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - importing ' + ': ' + @PathName + @filename, GETDATE () END
		SELECT @sql = N'BULK INSERT [dbo].[table_ADJUSTMENT_Rawdata] FROM '  + '''' + @PathName + @filename + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR =''~'', FIRSTROW = 2, ROWTERMINATOR =''0x0a'')';
		EXECUTE sp_executesql @sql

		SELECT @step=6
		SELECT @RecordsAffected = count(*) from [dbo].[table_ADJUSTMENT_Rawdata]
		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - processing ' + cast(@RecordsAffected as varchar) + ' imported adjustments', GETDATE () END

		/* document the last successful import timestamp */
		SELECT @step=8
		update [dbo].[FilestoImport] set LastImport = getdate() WHERE [Source] like @FileSource and [filename]= @filename and ToBeImported=1

		SELECT @step = 10
		/*in case adjustments where not inserted on portfoliolevel, we need to set a level-corresponding name rather than keeping "DUMMY"*/
		UPDATE [dbo].[table_ADJUSTMENT_Rawdata]
			SET PORTFOLIO_NAME =
					CASE WHEN BOOK_NAME not like 'Dummy%' THEN BOOK_NAME ELSE
						CASE WHEN INTERMEDIATE4_NAME not like 'Dummy%' THEN INTERMEDIATE4_NAME ELSE
							CASE WHEN INTERMEDIATE3_NAME not like 'Dummy%' THEN INTERMEDIATE3_NAME ELSE
								CASE WHEN INTERMEDIATE2_NAME not like 'Dummy%' THEN INTERMEDIATE2_NAME ELSE
									CASE WHEN INTERMEDIATE1_NAME not like 'Dummy%' THEN INTERMEDIATE1_NAME ELSE
										CASE WHEN DESK_NAME not like 'Dummy%' THEN DESK_NAME
										ELSE BUSINESS_LINE_NAME END
									END
								END
							END
						END
					END
				WHERE PORTFOLIO_NAME like 'Dummy%'

		SELECT @step = 21
		/* add the adj. category to the portfolio_name, in a way, that the resulting name won't be max 50 characters long (only the devil knows why...)*/
		update [dbo].[table_ADJUSTMENT_Rawdata]
		SET [PORTFOLIO_NAME] =
			CASE WHEN [ADJUSTMENT_CATEGORY] = 'Bid/Offer Valuation Adjustments' THEN left([Portfolio_Name],43) + '_ValADj' ELSE
				CASE WHEN [ADJUSTMENT_CATEGORY] = 'Valuation Adjustments Credit' THEN left([Portfolio_Name],40) + '_CreditAdj' ELSE
					CASE WHEN [ADJUSTMENT_CATEGORY] = 'Model Risk Valuation Adjustments' THEN left([Portfolio_Name],37) + '_ModelRiskAdj' ELSE
						CASE WHEN [ADJUSTMENT_CATEGORY] = 'Tax' THEN left([Portfolio_Name],46) + '_Tax' ELSE
							CASE WHEN [ADJUSTMENT_CATEGORY] = '(Other) Business related Costs' THEN left([Portfolio_Name],34) + '_BusinessRelCost' ELSE
								CASE WHEN [ADJUSTMENT_CATEGORY] = 'Cost of Cash' THEN left([Portfolio_Name],39) ++ '_CostOfCash' ELSE
									CASE WHEN [ADJUSTMENT_CATEGORY] = 'Working Capital Utilisation' THEN left([Portfolio_Name],42) + '_WorkCap' ELSE
										CASE WHEN [ADJUSTMENT_CATEGORY] = 'Brokerage and Exchange Fees' THEN left([Portfolio_Name],40) + '_Brokerage'
										ELSE left([PORTFOLIO_NAME],50) END
									END
								END
							END
						END
					END
				END
			END

		SELECT @step = 22
		truncate table [dbo].[table_Risk_Adjustments]

		SELECT @step = 23
		/*transfer the NEW adjustments to the final table*/
		INSERT INTO dbo.table_RISK_ADJUSTMENTS
		(
			 [COB]
			,[BUSINESS_LINE_NAME]
			,[DESK_NAME]
			,[INTERMEDIATE1_NAME]
			,[INTERMEDIATE2_NAME]
			,[INTERMEDIATE3_NAME]
			,[INTERMEDIATE4_NAME]
			,[BOOK_NAME]
			,[PORTFOLIO_NAME]
			,[CATEGORY_NAME]
			,[SUB_CATEGORY_NAME]
			,[ADJUSTMENT_ID]
			,[USER_COMMENT]
			,[UserID]
			,CASHFLOW_CURRENCY
			,[VALID_FROM]
			,[VALID_TO]
			,[PAYMENT_DATE]
			,[BUSINESS_LINE_CURRENCY]
			,[INTERMEDIATE1_CURRENCY]
			/*now the metrics*/
			,[Realised Discounted EUR]
			,[Realised Discounted EUR - EOLY]
			,[Unrealised Discounted EUR]
			,[Unrealised Discounted EUR - EOLY]
			,[Realised Discounted USD]
			,[Realised Discounted USD - EOLY]
			,[Unrealised Discounted USD]
			,[Unrealised Discounted USD - EOLY]
			,[Realised Discounted GBP]
			,[Realised Discounted GBP - EOLY]
			,[Unrealised Discounted GBP]
			,[Unrealised Discounted GBP EOLY]
			,[REAL_DISC_PH_IM1_CCY]
			,[UNREAL_DISC_PH_IM1_CCY]
			,[REAL_DISC_PH_IM1_CCY_LGBY]
			,[UNREAL_DISC_PH_IM1_CCY_LGBY]
			,UNREAL_DISC_BL_CCY
			,UNREAL_DISC_PH_BL_CCY
			,UNREAL_DISC_BL_CCY_LGBY
			,UNREAL_DISC_PH_BL_CCY_LGBY
			,REAL_DISC_PH_BL_CCY_YTD
			,REAL_DISC_PH_IM1_CCY_YTD
			---
			,TOTAL_VALUE_PH_IM1_CCY_YTD /*11*/
			,TOTAL_VALUE_PH_BL_CCY_YTD /*12*/
			,REAL_UNDISC_CASHFLOW_CCY_YTD /*13*/
			,REAL_UNDISC_CASHFLOW_CCY
			,UNREAL_DISC_CASHFLOW_CCY
			,UNREAL_DISC_CASHFLOW_CCY_YTD
			,REAL_DISC_PH_BL_CCY_MTD
			,UNREAL_DISC_PH_BL_CCY_MTD
			,[FileId]
		)
		SELECT
			 convert(DATE, substring(COB, 7, 4) + '-' + substring(COB, 4, 2) + '-' + substring(COB, 1, 2)) as cob
			,BUSINESS_LINE_NAME
			,DESK_NAME
			,INTERMEDIATE1_NAME
			,INTERMEDIATE2_NAME
			,INTERMEDIATE3_NAME
			,INTERMEDIATE4_NAME
			,BOOK_NAME
			,PORTFOLIO_NAME
			,ADJUSTMENT_CATEGORY
			,ADJUSTMENT_SUBCATEGORY
			,ADJUSTMENT_ID
			,USER_COMMENT
			,ROCK_USER_ID
			,CASHFLOW_CURRENCY
			,[VALID_FROM]
			,[VALID_TO]
			,[PAYMENT_DATE]
			,BUSINESS_LINE_CURRENCY
			,INTERMEDIATE1_CURRENCY
			/*now the metrics*/
			,cast(isnull(REAL_DISC_PH_BL_CCY,0) as float) as [Realised Discounted EUR]
			,cast(isnull(REAL_DISC_PH_BL_CCY_LGBY,0) as float) as [Realised Discounted EUR - EOLY]
			,cast(isnull(UNREAL_DISC_PH_BL_CCY,0) as float) as [Unrealised Discounted EUR]
			,cast(isnull(UNREAL_DISC_PH_BL_CCY_LGBY,0) as float) as [Unrealised Discounted EUR - EOLY]
			,iif(CASHFLOW_CURRENCY='USD',cast(isnull(REAL_DISC_PH_IM1_CCY,0) as float),0) as [Realised Discounted USD]
			,iif(CASHFLOW_CURRENCY='USD',cast(isnull(REAL_DISC_PH_IM1_CCY_LGBY,0) as float),0) as [Realised Discounted USD - EOLY]
			,iif(CASHFLOW_CURRENCY='USD',cast(isnull(UNREAL_DISC_PH_IM1_CCY,0) as float),0) [Unrealised Discounted USD]
			,iif(CASHFLOW_CURRENCY='USD',cast(isnull(UNREAL_DISC_PH_IM1_CCY_LGBY,0) as float),0) as [Unrealised Discounted USD - EOLY]
			,iif(CASHFLOW_CURRENCY='GBP',cast(isnull(REAL_DISC_PH_IM1_CCY,0) as float),0) as [Realised Discounted GBP]
			,iif(CASHFLOW_CURRENCY='GBP',cast(isnull(REAL_DISC_PH_IM1_CCY_LGBY,0) as float),0) as [Realised Discounted GBP - EOLY]
			,iif(CASHFLOW_CURRENCY='GBP',cast(isnull(UNREAL_DISC_PH_IM1_CCY,0) as float),0) as [Unrealised Discounted GBP]
			,iif(CASHFLOW_CURRENCY='GBP',cast(isnull(UNREAL_DISC_PH_IM1_CCY_LGBY,0) as float),0) as [Unrealised Discounted GBP EOLY]
			,cast(isnull(REAL_DISC_PH_IM1_CCY,0) as float) as [REAL_DISC_PH_IM1_CCY]
			,cast(isnull(UNREAL_DISC_PH_IM1_CCY,0) as float) as [UNREAL_DISC_PH_IM1_CCY]
			,cast(isnull([REAL_DISC_PH_IM1_CCY_LGBY],0) as float) as [REAL_DISC_PH_IM1_CCY_LGBY]
			,cast(isnull([UNREAL_DISC_PH_IM1_CCY_LGBY],0) as float) as [UNREAL_DISC_PH_IM1_CCY_LGBY]
			,cast(isnull(UNREAL_DISC_BL_CCY,0) as float) as [UNREAL_DISC_BL_CCY]
			,cast(isnull(UNREAL_DISC_PH_BL_CCY,0) as float) as [UNREAL_DISC_PH_BL_CCY]
			,cast(isnull(UNREAL_DISC_BL_CCY_LGBY,0) as float) as [UNREAL_DISC_BL_CCY_LGBY]
			,cast(isnull(UNREAL_DISC_PH_BL_CCY_LGBY,0) as float) as [UNREAL_DISC_PH_BL_CCY_LGBY]
			,cast(isnull(REAL_DISC_PH_BL_CCY_YTD,0) as float) as [REAL_DISC_PH_BL_CCY_YTD]
			,cast(isnull(REAL_DISC_PH_IM1_CCY_YTD,0) as float) as [REAL_DISC_PH_IM1_CCY_YTD]
			,cast(isnull(TOTAL_VALUE_PH_IM1_CCY_YTD,0) as float) as TOTAL_VALUE_PH_IM1_CCY_YTD /*11*/
			,cast(isnull(TOTAL_VALUE_PH_BL_CCY_YTD,0) as float) as TOTAL_VALUE_PH_BL_CCY_YTD /*12*/
			,cast(isnull(REAL_UNDISC_CASHFLOW_CCY_YTD,0) as float) as REAL_UNDISC_CASHFLOW_CCY_YTD /*13*/

			,cast(isnull(REAL_UNDISC_CASHFLOW_CCY,0) as float) as REAL_UNDISC_CASHFLOW_CCY
			,cast(isnull(UNREAL_DISC_CASHFLOW_CCY,0) as float) as UNREAL_DISC_CASHFLOW_CCY
			,cast(isnull(UNREAL_DISC_CASHFLOW_CCY_YTD,0) as float) as UNREAL_DISC_CASHFLOW_CCY_YTD 
			,cast(isnull(REAL_DISC_PH_BL_CCY_MTD,0) as float) as REAL_DISC_PH_BL_CCY_MTD 
			,cast(isnull(UNREAL_DISC_PH_BL_CCY_MTD,0) as float) as UNREAL_DISC_PH_BL_CCY_MTD 
			,@FileID
		FROM
			dbo.table_ADJUSTMENT_Rawdata

		SELECT @step = 25
		/*delete all adjustments, that are in total  "0" */
		delete from [dbo].table_RISK_ADJUSTMENTS
			where
			(
				 abs(REAL_DISC_PH_IM1_CCY)
				+abs(UNREAL_DISC_PH_IM1_CCY)
				+abs(REAL_DISC_PH_IM1_CCY_LGBY)
				+abs(UNREAL_DISC_PH_IM1_CCY_LGBY)
				+abs(UNREAL_DISC_BL_CCY)
				+abs(UNREAL_DISC_PH_BL_CCY)
				+abs(UNREAL_DISC_BL_CCY_LGBY)
				+abs(UNREAL_DISC_PH_BL_CCY_LGBY)
				+abs(REAL_DISC_PH_BL_CCY_YTD)
				+abs(REAL_DISC_PH_IM1_CCY_YTD)
				+abs(TOTAL_VALUE_PH_IM1_CCY_YTD)/*11*/
				+abs(TOTAL_VALUE_PH_BL_CCY_YTD)/*12*/
				+abs(REAL_UNDISC_CASHFLOW_CCY_YTD)/*13*/

				+abs(REAL_UNDISC_CASHFLOW_CCY)
				+abs(UNREAL_DISC_CASHFLOW_CCY)
				+abs(UNREAL_DISC_CASHFLOW_CCY_YTD)
				+abs(REAL_DISC_PH_BL_CCY_MTD)
				+abs(UNREAL_DISC_PH_BL_CCY_MTD)
			) = 0


/* ======================================================================================================================================================= */
/* ========= START update for April - inserted by MBE on 28.04.2021 ====================================================================================== */
/* ======================================================================================================================================================= */


					/*updates for April,  as requested in 2021/04*/
					IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - run data updates for April ', GETDATE () END

					SELECT @step = 30
					IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - deleting C&F valuation adjustments (April)', GETDATE () END

					delete from [FinRecon].[dbo].table_RISK_ADJUSTMENTS  where PORTFOLIO_NAME = 'CF REPORTING_ValADj'

					delete from [FinRecon].[dbo].[table_RISK_ADJUSTMENTS] where [ADJUSTMENT_ID] = 'c1eda252-4db9-43d2-882b-96bf0e6da63f'

					SELECT @step = 31
					IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - updating PF Names for Bid/Offer Valuation adjustments (April)', GETDATE () END

					SELECT @step = 32
					update [dbo].table_RISK_ADJUSTMENTS set [PORTFOLIO_NAME] = 'Bid/Offer Val. Adj – DBO' where CATEGORY_NAME = 'Bid/Offer Valuation Adjustments' and [INTERMEDIATE2_NAME] = 'DRY BULK ORIGINATION'

					SELECT @step = 33
					update [dbo].table_RISK_ADJUSTMENTS set [PORTFOLIO_NAME] = 'Bid/Offer Val. Adj – Coal Freight' where CATEGORY_NAME = 'Bid/Offer Valuation Adjustments' and [INTERMEDIATE2_NAME] in ('Coal Trading', 'FREIGHT')

					SELECT @step = 33
					update [dbo].table_RISK_ADJUSTMENTS set [PORTFOLIO_NAME] = 'Bid/Offer Val. Adj – Japan' where CATEGORY_NAME = 'Bid/Offer Valuation Adjustments' and [SUB_CATEGORY_NAME] = 'RWEST JAPAN PE'

					SELECT @step = 34
					update [dbo].table_RISK_ADJUSTMENTS set [PORTFOLIO_NAME] = 'Bid/Offer Val. Adj – China' where CATEGORY_NAME = 'Bid/Offer Valuation Adjustments' and [SUB_CATEGORY_NAME] = 'RWEST SHANGHAI PE'

					SELECT @step = 35
					update [dbo].table_RISK_ADJUSTMENTS set [PORTFOLIO_NAME] = 'Bid/Offer Val. Adj – Indonesia' where CATEGORY_NAME = 'Bid/Offer Valuation Adjustments' and [SUB_CATEGORY_NAME] = 'PT RHEINCOAL PE'

					SELECT @step = 36
					update [dbo].table_RISK_ADJUSTMENTS set [PORTFOLIO_NAME] = 'ASIA-PACIFIC TRADING REPORTING_ValADj' where CATEGORY_NAME = 'Bid/Offer Valuation Adjustments' and [SUB_CATEGORY_NAME] = 'Indonesia'

					SELECT @step = 37
					update [dbo].table_RISK_ADJUSTMENTS set [PORTFOLIO_NAME] = 'ASIA-PACIFIC TRADING REPORTING_ValADj' where CATEGORY_NAME = 'Bid/Offer Valuation Adjustments' and [SUB_CATEGORY_NAME] = 'China Commodities'
					
					-- Added by MK on 2024-03-11 by request of April Xin
					SELECT @step = 66
					UPDATE [dbo].[table_RISK_ADJUSTMENTS] SET [PORTFOLIO_NAME] = 'GPM Non Performance NMT' WHERE [SUB_CATEGORY_NAME] IN ('Monthly Intrinsic Storage','Monthly Intrinsic Transport')

					-- 2024-07-16 MK: Deactivated code below to reach numbers desired by Nina Schlossarek and Osama Abo Jaib. IF CODE STAYS DEACTIVATED UNTIL AFTER 2025-08-01, DELETE COMPLETELY!
					--/*request of April: delete dummy Bid/Offer valuation adjustments for AP desk*/
					--IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - deleting dummy Bid/Offer valuation adjustments for AP', GETDATE () END
					--SELECT @step = 38
					--delete from [dbo].table_RISK_ADJUSTMENTS where [PORTFOLIO_NAME] = 'Bid/Offer Val. Adj – AP'  and [SUB_CATEGORY_NAME] = 'Dummy' and [ADJUSTMENT_ID] = 'Dummy'

					--SELECT @step = 39
					--INSERT INTO [FinRecon].[dbo].table_RISK_ADJUSTMENTS
					--(
					--	 [COB]
					--	,[BUSINESS_LINE_NAME]
					--	,[DESK_NAME]
					--	,[INTERMEDIATE1_NAME]
					--	,[INTERMEDIATE2_NAME]
					--	,[INTERMEDIATE3_NAME]
					--	,[INTERMEDIATE4_NAME]
					--	,[BOOK_NAME]
					--	,[PORTFOLIO_NAME]
					--	,[CATEGORY_NAME]
					--	,[SUB_CATEGORY_NAME]
					--	,[ADJUSTMENT_ID]
					--	,[USER_COMMENT]
					--	,[UserID]
					--	,CASHFLOW_CURRENCY
					--	,[BUSINESS_LINE_CURRENCY]
					--	,[INTERMEDIATE1_CURRENCY]
					--	/*now the metrics*/
					--	,[Realised Discounted EUR]
					--	,[Realised Discounted EUR - EOLY]
					--	,[Unrealised Discounted EUR]
					--	,[Unrealised Discounted EUR - EOLY]
					--	,[Realised Discounted USD]
					--	,[Realised Discounted USD - EOLY]
					--	,[Unrealised Discounted USD]
					--	,[Unrealised Discounted USD - EOLY]
					--	,[Realised Discounted GBP]
					--	,[Realised Discounted GBP - EOLY]
					--	,[Unrealised Discounted GBP]
					--	,[Unrealised Discounted GBP EOLY]
					--	,[REAL_DISC_PH_IM1_CCY]
					--	,[UNREAL_DISC_PH_IM1_CCY]
					--	,[REAL_DISC_PH_IM1_CCY_LGBY]
					--	,[UNREAL_DISC_PH_IM1_CCY_LGBY]
					--	,UNREAL_DISC_BL_CCY
					--	,UNREAL_DISC_PH_BL_CCY
					--	,UNREAL_DISC_BL_CCY_LGBY
					--	,UNREAL_DISC_PH_BL_CCY_LGBY
					--	,REAL_DISC_PH_BL_CCY_YTD
					--	,REAL_DISC_PH_IM1_CCY_YTD
					--	----
					--	,TOTAL_VALUE_PH_IM1_CCY_YTD /*11*/
					--	,TOTAL_VALUE_PH_BL_CCY_YTD /*12*/
					--	,REAL_UNDISC_CASHFLOW_CCY_YTD /*13*/
					--	,[FileId]
					--)
					--SELECT
					--	 COB
					--	,[BUSINESS_LINE_NAME]
					--	,[DESK_NAME]
					--	,[INTERMEDIATE1_NAME]
					--	,[INTERMEDIATE2_NAME]
					--	,[INTERMEDIATE3_NAME]
					--	,[INTERMEDIATE4_NAME]
					--	,[BOOK_NAME]
					--	,'Bid/Offer Val. Adj – AP' as PORTFOLIO_NAME
					--	,[CATEGORY_NAME]
					--	,'Dummy' AS [SUB_CATEGORY_NAME]
					--	,'Dummy' AS [ADJUSTMENT_ID]
					--	,[USER_COMMENT]
					--	,[UserID]
					--	,CASHFLOW_CURRENCY
					--	,[BUSINESS_LINE_CURRENCY]
					--	,[INTERMEDIATE1_CURRENCY]
					--	/*now the metrics*/
					--	,sum(CASE WHEN PORTFOLIO_NAME LIKE 'BID/Offer%' THEN - [Realised Discounted EUR] ELSE [Realised Discounted EUR] END)
					--	,sum(CASE WHEN PORTFOLIO_NAME LIKE 'BID/Offer%' THEN - [Realised Discounted EUR - EOLY] ELSE [Realised Discounted EUR - EOLY] END)
					--	,sum(CASE WHEN PORTFOLIO_NAME LIKE 'BID/Offer%' THEN - [Unrealised Discounted EUR] ELSE [Unrealised Discounted EUR] END)
					--	,sum(CASE WHEN PORTFOLIO_NAME LIKE 'BID/Offer%' THEN - [Unrealised Discounted EUR - EOLY] ELSE [Unrealised Discounted EUR - EOLY] END)
					--	,sum(CASE WHEN PORTFOLIO_NAME LIKE 'BID/Offer%' THEN - [Realised Discounted USD] ELSE [Realised Discounted USD] END)
					--	,sum(CASE WHEN PORTFOLIO_NAME LIKE 'BID/Offer%' THEN - [Realised Discounted USD - EOLY] ELSE [Realised Discounted USD - EOLY] END)
					--	,sum(CASE WHEN PORTFOLIO_NAME LIKE 'BID/Offer%' THEN - [Unrealised Discounted USD] ELSE [Unrealised Discounted USD] END)
					--	,sum(CASE WHEN PORTFOLIO_NAME LIKE 'BID/Offer%' THEN - [Unrealised Discounted USD - EOLY] ELSE [Unrealised Discounted USD - EOLY] END)
					--	,sum(CASE WHEN PORTFOLIO_NAME LIKE 'BID/Offer%' THEN - [Realised Discounted GBP] ELSE [Realised Discounted GBP] END)
					--	,sum(CASE WHEN PORTFOLIO_NAME LIKE 'BID/Offer%' THEN - [Realised Discounted GBP - EOLY] ELSE [Realised Discounted GBP - EOLY] END)
					--	,sum(CASE WHEN PORTFOLIO_NAME LIKE 'BID/Offer%' THEN - [Unrealised Discounted GBP] ELSE [Unrealised Discounted GBP] END)
					--	,sum(CASE WHEN PORTFOLIO_NAME LIKE 'BID/Offer%' THEN - [Unrealised Discounted GBP EOLY] ELSE [Unrealised Discounted GBP EOLY] END)
					--	,sum(CASE WHEN PORTFOLIO_NAME LIKE 'BID/Offer%' THEN - [REAL_DISC_PH_IM1_CCY] ELSE [REAL_DISC_PH_IM1_CCY] END)
					--	,sum(CASE WHEN PORTFOLIO_NAME LIKE 'BID/Offer%' THEN - [UNREAL_DISC_PH_IM1_CCY] ELSE [UNREAL_DISC_PH_IM1_CCY] END)
					--	,sum(CASE WHEN PORTFOLIO_NAME LIKE 'BID/Offer%' THEN - [REAL_DISC_PH_IM1_CCY_LGBY] ELSE [REAL_DISC_PH_IM1_CCY_LGBY] END)
					--	,sum(CASE WHEN PORTFOLIO_NAME LIKE 'BID/Offer%' THEN - [UNREAL_DISC_PH_IM1_CCY_LGBY] ELSE [UNREAL_DISC_PH_IM1_CCY_LGBY] END)
					--	,sum(CASE WHEN PORTFOLIO_NAME LIKE 'BID/Offer%' THEN - UNREAL_DISC_BL_CCY else UNREAL_DISC_BL_CCY END)
					--	,sum(CASE WHEN PORTFOLIO_NAME LIKE 'BID/Offer%' THEN - UNREAL_DISC_PH_BL_CCY else UNREAL_DISC_PH_BL_CCY END)
					--	,sum(CASE WHEN PORTFOLIO_NAME LIKE 'BID/Offer%' THEN - UNREAL_DISC_BL_CCY_LGBY else UNREAL_DISC_BL_CCY_LGBY END)
					--	,sum(CASE WHEN PORTFOLIO_NAME LIKE 'BID/Offer%' THEN - UNREAL_DISC_PH_BL_CCY_LGBY else UNREAL_DISC_PH_BL_CCY_LGBY END)
					--	,sum(CASE WHEN PORTFOLIO_NAME LIKE 'BID/Offer%' THEN - REAL_DISC_PH_BL_CCY_YTD else REAL_DISC_PH_BL_CCY_YTD END)
					--	,sum(CASE WHEN PORTFOLIO_NAME LIKE 'BID/Offer%' THEN - REAL_DISC_PH_IM1_CCY_YTD else REAL_DISC_PH_IM1_CCY_YTD END)
					--	---
					--	,sum(CASE WHEN PORTFOLIO_NAME LIKE 'BID/Offer%' THEN - TOTAL_VALUE_PH_IM1_CCY_YTD else TOTAL_VALUE_PH_IM1_CCY_YTD END)/*11*/
					--	,sum(CASE WHEN PORTFOLIO_NAME LIKE 'BID/Offer%' THEN - TOTAL_VALUE_PH_BL_CCY_YTD else TOTAL_VALUE_PH_BL_CCY_YTD END)/*12*/
					--	,sum(CASE WHEN PORTFOLIO_NAME LIKE 'BID/Offer%' THEN - REAL_UNDISC_CASHFLOW_CCY_YTD else REAL_UNDISC_CASHFLOW_CCY_YTD END)/*13*/
					--	,'1464'/* only the devil knows why it needs to be "1464" */
					--FROM
					--	[FinRecon].[dbo].table_RISK_ADJUSTMENTS
					--WHERE
					--	[Category_Name] = 'Bid/Offer Valuation Adjustments'
					--	AND [DESK_NAME] = 'ASIA-PACIFIC TRADING DESK'
					--GROUP BY
					--	COB
					--	,[BUSINESS_LINE_NAME]
					--	,[DESK_NAME]
					--	,[INTERMEDIATE1_NAME]
					--	,[INTERMEDIATE2_NAME]
					--	,[INTERMEDIATE3_NAME]
					--	,[INTERMEDIATE4_NAME]
					--	,[BOOK_NAME]
					--	,[CATEGORY_NAME]
					--	,[USER_COMMENT]
					--	,[UserID]
					--	,CASHFLOW_CURRENCY
					--	,[BUSINESS_LINE_CURRENCY]
					--	,[INTERMEDIATE1_CURRENCY]

			IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - data updates for April done.', GETDATE () END

			SELECT @step=40
			SELECT @RecordsAffected = count(*) from [dbo].[table_ADJUSTMENT_Rawdata]
			IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - records arrived in table_RISK_ADJUSTMENTS: '+ cast(@RecordsAffected as varchar) , GETDATE () END


NoFurtherAction:
		IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - FINISHED', GETDATE () END
END TRY

BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
		BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - FAILED', GETDATE () END
END CATCH

GO

