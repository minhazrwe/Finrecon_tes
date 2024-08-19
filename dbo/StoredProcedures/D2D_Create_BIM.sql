
/*=============================================
 Author:  MKB
 Created: 2023-12
 Purpose:	Create BIMs for D2D Recon
					Instead of joining misc. hard coded queries we run trough a dynamic loop 
					identifing all possible combinations of LE/CCY from the raw data.
 ---------------------------------------------
 updates: (when/who/what/why)

 ============================================== */


CREATE PROCEDURE [dbo].[D2D_Create_BIM] 
AS	
	DECLARE @ReturnValue int
	
	DECLARE @ProcName nvarchar (60)
	DECLARE @step Integer	
	DECLARE @COB as date

	DECLARE @LegalEntity nvarchar(50)	
	DECLARE @CompanyCode nvarchar(50)	
	DECLARE @CountryCode nvarchar(3)	
	DECLARE @CCY nvarchar(50)	
	
	DECLARE @RecordsInserted nvarchar(10)

	DECLARE @SQL nvarchar(max)
	DECLARE @LogEntry nvarchar(max)
	DECLARE @Main_Process nvarchar(100)
	DECLARE @Calling_Application nvarchar(100)
	DECLARE @Session_Key nvarchar(100)
	
BEGIN TRY

	/*initial settings */
	SELECT @step=10
	SELECT @ProcName = Object_Name(@@PROCID)
	SELECT @Main_Process = ''
	SELECT @Calling_Application = ''
	SELECT @Session_Key = ''
	SELECT @LogEntry = 'START'
	EXECUTE [dbo].[Write_Log] 'Info', @LogEntry, @ProcName, @Main_Process, @Calling_Application, @Step, 1 , @Session_Key
	


	/*identify COB as we need it multiple times...*/
	SELECT @step=20
	SELECT @COB = asofdate_eom FROM dbo.AsOfDate
	
	/* prepare data table to store BIMN in*/
	SELECT @step=30		
	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' and TABLE_NAME ='table_D2D_BIM'))
	BEGIN 
		drop table [dbo].table_D2D_BIM 				
	END
			
	SELECT @step=40	
	CREATE TABLE dbo.table_D2D_BIM
	(
		KopfIdent [varchar](100) NULL
		,Buchungskreis [varchar](100) NULL
		,Belegdatum [varchar](100) NULL
		,Belegart [varchar](100) NULL
		,Buchungsdatum [varchar](100) NULL
		,[Currency] [varchar](100) NULL
		,Belegkopftext [varchar](100) NULL
		,Referenz [varchar](100) NULL
		,dummy1 [varchar](100) NULL
		,dummy2 [varchar](100) NULL
		,dummy3 [varchar](100) NULL
		,dummy4 [varchar](100) NULL
		,dummy5 [varchar](100) NULL
		,dummy6 [varchar](100) NULL
		,dummy7 [varchar](100) NULL
		,dummy8 [varchar](100) NULL
		,dummy9 [varchar](100) NULL
		,dummy10 [varchar](100) NULL	
		,dummy11 [varchar](100) NULL	
		,ID [int] IDENTITY(1,1) NOT NULL
		,lastUpdate [datetime] NULL
	) 
	
	SELECT @step=50	
	/*add the autoID; to ensure proper sorting of entered records*/
	ALTER TABLE [dbo].[table_D2D_BIM] ADD  CONSTRAINT [DF_table_D2D_BIM_lastUpdate] DEFAULT (getdate()) FOR lastUpdate
	
	SELECT @step=60
	IF CURSOR_STATUS('global', 'CursorCombo') >= 0
	BEGIN
			DEALLOCATE CursorCombo
	END

	/*now identify all possible combinations of currencies per LE from underlying raw data and read them into a cursor*/
	SELECT @step=70
	DECLARE CursorCombo CURSOR FOR
		SELECT
			distinct case when map_order.LegalEntity = 'n/a' then 'RWEST DE' else map_order.LegalEntity  end as LegalEntity
			,case when map_order.LegalEntity = 'n/a' then '0600' else CompanyCode  end	as CompanyCode
			,case when map_order.LegalEntity = 'n/a' then 'DE' else CountryCode  end	as CountryCode
			,[currency] as CCY			
		FROM 
				dbo.table_D2D_with_matching_deals
				left join dbo.map_order on table_D2D_with_matching_deals.OrderNo= map_order.OrderNo
				left join dbo.table_Clearer_map_LegalEntity_CompanyCode on dbo.map_order.LegalEntity = dbo.table_Clearer_map_LegalEntity_CompanyCode.LegalEntity
		WHERE 
			map_order.LegalEntity	not in ('RWEST SH','RWESTA - PE')
		ORDER BY 
			LegalEntity
			,[currency]


			
	/* open cursor and step through the cursor and create one BIM per record.*/
	SELECT @step=100
	OPEN CursorCombo
		FETCH NEXT FROM CursorCombo INTO @LegalEntity, @CompanyCode, @CountryCode, @CCY
		WHILE @@FETCH_STATUS = 0
			BEGIN /*cursor loop start*/
	
			/*now fill the different elements into the table*/
				SET @step=@step-(@step%10)+100
				
				SELECT @LogEntry = 'Creating BIM for ' + @LegalEntity + ', ' + @CCY
				EXECUTE [dbo].[Write_Log] 'Info', @LogEntry, @ProcName, @Main_Process, @Calling_Application, @Step, 1 , @Session_Key
									
				SET @step=@step+1 --201
				INSERT INTO dbo.table_D2D_BIM 
				(KopfIdent)
				VALUES
				('NEXT:' + @LegalEntity  + '/' + @CCY)

				SET @step=@step+1		--202
				INSERT INTO dbo.table_D2D_BIM 
				(
					KopfIdent
					,Buchungskreis
					,Belegdatum
					,Belegart
					,Buchungsdatum
					,[Currency]
					,Belegkopftext
					,Referenz
					,dummy1
					,dummy2
					,dummy3
					,dummy4
					,dummy5
					,dummy6
					,dummy7
					,dummy8
					,dummy9
					,dummy10
					,dummy11
					)
					(	
						SELECT 
							 KopfIdent
							,Buchungskreis
							,Belegdatum
							,Belegart
							,Buchungsdatum
							,[Currency]
							,Belegkopftext
							,Referenz
							,dummy1
							,dummy2
							,dummy3
							,dummy4
							,dummy5
							,dummy6
							,dummy7
							,dummy8
							,dummy9
							,dummy10
							,dummy11
						FROM 
							dbo.table_PE2PE_BIM_header					
					)
				
				SET @step=@step+1 --203
				INSERT INTO dbo.table_D2D_BIM 
				(
					KopfIdent
					,Buchungskreis
					,Belegdatum
					,Belegart
					,Buchungsdatum
					,[Currency]
					,Belegkopftext
					,Referenz
					,dummy1
					,dummy2
					,dummy3
					,dummy4
					,dummy5
					,dummy6
					,dummy7
					,dummy8
					,dummy9
					,dummy10
					,dummy11
				)
				(
					SELECT 
							'BKPF' as kopfident
							,@CompanyCode	as buchungskreis								/* was: ,'0600'*/
							,FORMAT(@COB, 'dd.MM.yyyy') as belegdatum			/* was: ,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))*/
							,'AB' as belegart
							,FORMAT(@COB, 'dd.MM.yyyy') as buchungsdatum	/* was: ,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))*/
							,@CCY	as ccy																	/* was: 'EUR'*/
							,'D2D' as belegkopftext
							,'D2D ' + FORMAT(@COB, 'yyyy/MM') as referenz	/*was: ,'D2D ' + (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))*/
							,NULL as dummy1
							,NULL as dummy2
							,NULL as dummy3
							,NULL as dummy4
							,NULL as dummy5
							,NULL as dummy6
							,NULL as dummy7
							,NULL as dummy8
							,'PortfolioID' as dummy9
							,'pnl' as dummy10
							,'volume_new' as dummy11 
					)
				
				SET @step=@step+1 --204
				INSERT INTO dbo.table_D2D_BIM 
				(
					KopfIdent
					,Buchungskreis
					,Belegdatum
					,Belegart
					,Buchungsdatum
					,[Currency]
					,Belegkopftext
					,Referenz
					,dummy1
					,dummy2
					,dummy3
					,dummy4
					,dummy5
					,dummy6
					,dummy7
					,dummy8
					,dummy9
					,dummy10
					,dummy11
				)
				(
					SELECT 
								NULL as kopfident
								,IIF(SUM(Realised) < 0, '40', '50')
								,SAP_Account
								,table_D2D_with_matching_deals.OrderNo
								,CONVERT(Varchar, FORMAT(ABS(round(SUM(Realised),3)), 'G'))
								,CONVERT(Varchar, FORMAT(ABS(round(SUM(Volume_new),3)), 'G'))
								,IIF([InstrumentType] LIKE 'REN-%' OR InstrumentType LIKE 'EM-%', 'ST', 'MWh')
								,FORMAT(@COB, 'yyyy/MM') /* was: ,(SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))*/								
								,IIF(Ticker = 'not assigned' OR Ticker = '', InstrumentType, Ticker) + ';' +@CountryCode + ';;' + ExternalPortfolio
								,IIF(LEFT(SAP_Account, 1) = '4', 'AP', 'VP')
								,@CompanyCode
								,NULL
								,NULL
								,Ticker
								,InstrumentType
								,ExternalPortfolio
								,PfID
								,convert(varchar,SUM(Realised))							/*pnl*/
								,convert(varchar,ROUND(SUM(Volume_new),3)) /*volume_new*/
							FROM 
								dbo.table_D2D_with_matching_deals								
							WHERE 
								LegalEntity = @LegalEntity
								AND [Currency] = @CCY
							GROUP BY 
									table_D2D_with_matching_deals.OrderNO
								, SAP_Account
								, InstrumentType
								, CashflowType
								, ExternalPortfolio
								, Ticker
								, UNIT_TO
								, PfID
							HAVING 
								NOT (SUM(Realised) = 0 AND SUM(Volume_new) <> 0)
				)

				SET @step=@step+1 --205
				INSERT INTO dbo.table_D2D_BIM  (KopfIdent) VALUES ('VOLUME Corr. BELOW')

				SET @step=@step+1 --206
				INSERT INTO dbo.table_D2D_BIM 
				(
					KopfIdent
					,Buchungskreis
					,Belegdatum
					,Belegart
					,Buchungsdatum
					,[Currency]
					,Belegkopftext
					,Referenz
					,dummy1
					,dummy2
					,dummy3
					,dummy4
					,dummy5
					,dummy6
					,dummy7
					,dummy8
					,dummy9
					,dummy10
					,dummy11
				)
				(
					SELECT 
							'BKPF'
						,@CompanyCode
						,format(@COB, 'dd.MM.yyy') /*was: (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))*/
						,'AB'
						,format(@COB, 'dd.MM.yyy') /*was: (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'dd.MM.yyy'))*/
						,@CCY
						,'D2D'
						,'D2D ' + format(@COB, 'yyyy/MM') /*was: (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))*/
						,NULL
						,NULL
						,NULL
						,NULL
						,NULL
						,NULL
						,NULL
						,NULL
						,NULL /* pfid*/
						,NULL /* pnl */
						,NULL /* volume_new */

				)

				SET @step=@step+1 --207
				INSERT INTO dbo.table_D2D_BIM 
				(
					KopfIdent
					,Buchungskreis
					,Belegdatum
					,Belegart
					,Buchungsdatum
					,[Currency]
					,Belegkopftext
					,Referenz
					,dummy1
					,dummy2
					,dummy3
					,dummy4
					,dummy5
					,dummy6
					,dummy7
					,dummy8
					,dummy9
					,dummy10
					,dummy11
				)
				(
					SELECT 
								 ''
								,IIF(SUM(Volume_new) < 0, '40', '50')
								,SAP_Account
								,OrderNo
								,'0.01'
								,CONVERT(Varchar, FORMAT(ABS(round(SUM(Volume_new),3)), 'G'))
								,IIF(InstrumentType LIKE 'REN-%' OR InstrumentType LIKE 'EM-%', 'ST', 'MWh')
								,FORMAT(@COB, 'yyyy/MM') /*was: (SELECT FORMAT ((SELECT [AsOfDate_EOM] FROM [FinRecon].[dbo].[AsOfDate]), 'yyyy/MM'))*/
								,IIF(Ticker = 'not assigned' OR Ticker = '', InstrumentType, Ticker) + ';' + @CountryCode + ';;' + ExternalPortfolio
								,IIF(LEFT(SAP_Account, 1) = '4', 'AP', 'VP')
								,@CompanyCode
								,NULL
								,NULL
								,Ticker
								,InstrumentType
								,ExternalPortfolio
								,PfID
								,'artificial'							/*pnl*/
								,convert(varchar,ROUND(SUM(Volume_new),3)) /*volume_new*/
							FROM 
								[FinRecon].[dbo].[table_D2D_with_matching_deals]
							WHERE 
								[Currency] = 'EUR'
							GROUP BY 
								OrderNO
								,SAP_Account
								,InstrumentType
								,CashflowType
								,ExternalPortfolio
								,Ticker
								,UNIT_TO
								,PfID
							HAVING 
								(SUM(Realised) = 0 AND SUM(Volume_new) <> 0)
					)
				
				SET @step=@step+1 --208
				FETCH NEXT FROM CursorCombo INTO @LegalEntity, @CompanyCode, @CountryCode, @CCY
			END /* cursor loop end*/
	
	/* close cursor again*/
	SET @step=@step-(@step%10)+100
	CLOSE CursorCombo
	
	/* kill/remove cursor*/
	SET @Step=2000
	DEALLOCATE CursorCombo
	
	/*count and report inserted records*/
	SET @Step=2100
	select @RecordsInserted= convert(varchar, count(*)) from dbo.table_D2D_BIM

	SELECT @LogEntry = 'Total Records inserted: ' + convert(varchar(10),@RecordsInserted)
	EXECUTE [dbo].[Write_Log] 'Info', @LogEntry, @ProcName, @Main_Process, @Calling_Application, @Step, 1 , @Session_Key


	NoFurtherAction:
	
	/*tell the world we're done*/
	SET @Step=2200
	SELECT @LogEntry = 'FINISHED'
	EXECUTE [dbo].[Write_Log] 'Info', @LogEntry, @ProcName, @Main_Process, @Calling_Application, @Step, 1 , @Session_Key

	END TRY

BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @ProcName, @Step
		SELECT @LogEntry = 'FAILED WITH ERROR !' 
		EXECUTE [dbo].[Write_Log] 'Error', @LogEntry, @ProcName, @Main_Process, @Calling_Application, @Step /*Step*/, 1 /*Log_Info*/, @Session_Key		
	END CATCH

GO

