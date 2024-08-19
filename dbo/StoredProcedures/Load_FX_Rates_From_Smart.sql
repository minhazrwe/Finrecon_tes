
Create Procedure dbo.Load_FX_Rates_From_Smart
AS
	BEGIN TRY
		
		DECLARE @step Integer		
		DECLARE @proc nvarchar(50)
		DECLARE @LogInfo Integer
		DECLARE @last_available_FX_Rate_COB DATE
		DECLARE @gestern DATE
		DECLARE @dead_curve_counter int
		declare @ccy varchar(3)
		declare @fxrate float

		SELECT @proc = Object_Name(@@PROCID)

		 /* get Info if Logging is enabled */
		SELECT @LogInfo = [dbo].[LogInfo].[LogInfo] FROM [dbo].[LogInfo]
		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - START', GETDATE () END

	
		/*get the latest available date from already loaded ecb-fx-rates for those curves that have not yet ended */
		SELECT @step = 1
		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - identify dates to load for living curves.', GETDATE () END
		SELECT @last_available_FX_Rate_COB = MIN(max_cob) 
			from (select MAX(COB) max_cob, CCY 
						from dbo.Table_FX_Rates_Timeseries_MKB 
						where CCY not in 
						(
							 'SIT'	/* 	Slovenian Tolar (SlT),	curve_id 15092, stopped 2006-12-29 as switched to EUR */
							,'CYP'	/* 	Cypriot Pound (CYP),		curve_id 15074, stopped 2007-12-31 as switched to EUR */
							,'MTL'	/* 	Maltese Lira (MTL),			curve_id 15085, stopped	2007-12-31 as switched to EUR */
							,'SKK'	/* Slovak Koruna (SKK),			curve_id 15091, stopped	2008-12-31 as switched to EUR */
							,'EEK'	/* 	Estonian Kroon (EEK),		curve_id 15077, stopped 2010-12-31 as switched to EUR */												
							,'LVL'	/* 	Latvian Lats (LVL),			curve_id 15083, stopped 2013-12-31 as switched to EUR */
							,'LTL'	/* 	Lithuanian Litas (LTL), curve_id 15084, stopped 2014-12-31 as switched to EUR */
							,'RUB'	/* 	Russian Rouble (RUB),		curve_id 23755, stopped	2022-03-01 due to ukraine war*/						
							,'HRK'	/* 	Croatian Kuna (HRK),		curve_id 23753, stopped 2022-12-30 as switched to EUR */
							,'CNH', 'UAH' /* get not delivered by ECB, see below */
						)
						group by CCY) sub_sql

		/*ensure all ecb-sourced CCY that have not yet ended have the same last COB*/
		SELECT @step = 10
		delete from dbo.Table_FX_Rates_Timeseries_MKB 
		where 
			COB > @last_available_FX_Rate_COB 
			and CCY not in ('SIT','CYP','MTL','SKK','EEK','LVL','LTL','RUB','HRK','CNH','UAH')

		/*get ecb-curve data directly from server-linked smart-table*/
		SELECT @step = 20
		INSERT INTO dbo.Table_FX_Rates_Timeseries_MKB (COB, CCY, FX_Rate)
			SELECT 
			cast(trading_date as date) as COB
			,pt.pt_name as CCY		
			,fx.MEAN as FX_Rate
		FROM 
			SMART1P..SMART.CURVES c
			inner join SMART1P..SMART.PRODUCT_TYPE pt on pt.pt_id = c.product_type_id
			inner join SMART1P..SMART.FX_RATES_SPOT fx on fx.curve_id = c.id
		WHERE 
			fx.curve_id in 
			(	
				15071,15072,15073,15075,
				15076,15078,15079,15080,
				15081,15082,15086,15087,
				15088,15089,15090,15093,
				15094,15095,15096,15097,
				15098,15099,23752,23757,
				23759,23762,23764,30755,
				41351,41352,99216
			)		
			and fx.validity >= 0 /* display only valid entries*/
			and trading_date > @last_available_FX_Rate_COB
					

		/*get the latest available date from already loaded ENDUR-fx-rates*/
		SELECT @step = 30
		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - identify dates to load for ENDUR sourced curves.', GETDATE () END		
		SELECT @last_available_FX_Rate_COB = MIN(max_cob) from (select MAX(COB) max_cob, CCY from dbo.Table_FX_Rates_Timeseries_MKB where CCY in ('CNH','UAH') GROUP BY CCY) sub_sql
		
		/*ensure all endur-sourced CCY have the same last COB*/
		SELECT @step = 40
		delete from dbo.Table_FX_Rates_Timeseries_MKB where COB > @last_available_FX_Rate_COB and CCY in ('CNH','UAH')


		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - load Endur sourced FX-Rates.', GETDATE () END		
		/* get data for CNH and UAH (ENDUR Sourced, not ECB !) directly from server-linked smart-table*/
		SELECT @step = 50
		INSERT INTO dbo.Table_FX_Rates_Timeseries_MKB (COB, CCY, FX_Rate)		
		SELECT 
			cast(fx.trading_date as date) as COB
			,case when pt.pt_name = 'CNH/EUR' then 'CNH' else pt.pt_name end as CCY
		  ,fx.MEAN as rate    
		FROM 
			SMART1P..SMART.CURVES c
			inner join SMART1P..SMART.PRODUCT_TYPE pt on pt.pt_id = c.product_type_id
			inner join SMART1P..SMART.V12_PRICE_CURVES fx on fx.curve_id = c.id
			inner join SMART1P..SMART.DELIVERY_PERIOD dp on dp.id = c.delivery_period_id 
		WHERE 
			fx.curve_id in 
			(
			 275393  /*UAH,			FX_PR_EUR.UAH	*/
			,286420  /*CNH/EUR,	FX_PR_EUR.CNH	*/
			)
			and fx.validity>=0
			and fx.trading_date> @last_available_FX_Rate_COB
			
			/*now extend the last available rates for curves that have ended (for wahtever reason).*/

		/*drop the helper table with curves that are dead since some time in case we didn't delete it last time*/
		SELECT @step=60		
		IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'zzz_table_Dead_FX_Rate_Curves'))
		BEGIN DROP TABLE dbo.zzz_table_Dead_FX_Rate_Curves END


		/*create the helper table with curves that are dead since some time*/
		SELECT @step=70		
		SELECT
				sub_sql.Curve_id
			,sub_sql.CCY
			,sub_sql.cob
			,fx2.mean as fx_rate  
		into dbo.zzz_table_Dead_FX_Rate_Curves
		FROM 
			(SELECT 
					distinct c.id as curve_id
					,pt.pt_name as CCY
					,MAX(trading_date) as cob
				FROM 
					SMART1P..SMART.CURVES c
					inner join SMART1P..SMART.PRODUCT_TYPE pt on pt.pt_id = c.product_type_id
					inner join SMART1P..SMART.FX_RATES_SPOT fx on fx.curve_id = c.id
					inner join SMART1P..SMART.DELIVERY_PERIOD dp on dp.id = c.delivery_period_id 
				WHERE 
					fx.curve_id In 
					(
							15074,15077,23753,15084,15083,
							15085,23755,15092,15091
					)
					and fx.validity>=0
				GROUP BY
					c.id
					,pt.pt_name
				)sub_sql 
				inner join SMART1P..SMART.FX_RATES_SPOT fx2
				on  fx2.curve_id = sub_sql.curve_id
				and fx2.trading_date = sub_sql.cob

		/*identify the number of dead curves*/
		SELECT @step=80	
		SELECT @dead_curve_counter = COUNT(*) from dbo.zzz_table_Dead_FX_Rate_Curves

		/*select the maximum load date*/
		SELECT @step=90
		SELECT @gestern  = GETDATE()-1

		/*load data per CCY/dead curve for all missing dates*/
		SELECT @step=100
		WHILE @dead_curve_counter >0
		BEGIN			
			SELECT @step=110
			SELECT 
				 @CCY = CCY
				,@FXRATE = fx_rate
			FROM 
				(SELECT *, ROW_NUMBER() OVER(ORDER BY curve_ID) AS ROW FROM dbo.zzz_table_Dead_FX_Rate_Curves) as TMP 
			WHERE ROW = @dead_curve_counter

			/*get the latest load date ber ccy*/
			SELECT @step=120					
			select @last_available_FX_Rate_COB = MAX(cob) from dbo.Table_FX_Rates_Timeseries_MKB where CCY = @ccy 
		
			/*fill the gap until yesterday*/
			SELECT @step=130
			WHILE @last_available_FX_Rate_COB < @gestern
			BEGIN
				insert into dbo.Table_FX_Rates_Timeseries_MKB(COB,CCY,FX_Rate,FX_Rate_comment) values(@last_available_FX_Rate_COB,@CCY,@fxrate,'dead curve, last available FX_rate')  				
				select @last_available_FX_Rate_COB = dateadd(d,1,@last_available_FX_Rate_COB)
			END
			
			/*reduce curvecounter*/
			SELECT @dead_curve_counter=@dead_curve_counter-1
		END
		
		
		/* as we do not need it before the next run of this procedure, drop the helper table with dead curves again*/
		SELECT @step=140		
		IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'zzz_table_Dead_FX_Rate_Curves'))
		BEGIN DROP TABLE dbo.zzz_table_Dead_FX_Rate_Curves END


NoFurtherAction:
		IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - FINISHED', GETDATE () END
	END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step		
		BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - FAILED', GETDATE () END
	END CATCH

GO

