


/*
In the source table we have two CoBs:

Last CoB and
Last Business day of last month
e.g.: 26.04.2023 as lastCoB on 27.04.2023 and 31.03.2023 as Last Business day of last month

ON FIRST WORKING DAY OF A MONTH WE HAVE ONLY ONE COB IN THE SOURCE TABLE, SO MAX(COB) WORKS.
LOADING ON A LATER DAY OF LAST BUSINESS DAY OF LAST MONTH NEED A CHANGE TO MIN(COB)

*/


	CREATE PROCEDURE [dbo].[ImportStrolfData_Carmen] 
	AS
	BEGIN TRY

	DECLARE @proc nvarchar(40)
	DECLARE @step Integer
	DECLARE @LogInfo Integer
	DECLARE @COB_DATE_C as Date

	SELECT @proc = Object_Name(@@PROCID)

		-- we need the LogInfo for Logging
	
	select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - START', GETDATE () END

	select @step = 100
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - fill [dbo].[Strolf_REALIZED_CARMEN]', GETDATE () END
	delete from [dbo].[Strolf_REALIZED_CARMEN] where cob = (select asofdate_eom from asofdate)

	select @step = 110
	select @COB_DATE_C = MAX(COB) from OPENQUERY(ROCKCAO_CE, 'select * from CAO_CE.XPORT.fin_realized_carmen')

	select @step = 120
	insert into [dbo].[Strolf_realized_CARMEN] (
		COB, 
		TRADE_DEAL_NUMBER, 
		INS_TYPE_NAME, 
		LENTITY_NAME, 
		PORTFOLIO_NAME, 
		EXT_LENTITY_NAME,
		TRADE_CURRENCY, 
		CASHFLOW_TYPE, 
		TRADE_DATE, 
		UNIT_NAME, 
		CASHFLOW_PAYMENT_DATE, 
		INDEX_GROUP,  
		VOLUME, 
		REALISED_EUR_UNDISC, 
		DELIVERY_MONTH
		)
		select 
			asofdate_eom, 
			TRADE_DEAL_NUMBER, 
			INS_TYPE_NAME, 
			LENTITY_NAME, 
			PORTFOLIO_NAME, 
			EXT_LENTITY_NAME, 
			TRADE_CURRENCY, 
			CASHFLOW_TYPE, 
			TRADE_DATE, 
			UNIT_NAME, 
			CASHFLOW_PAYMENT_DATE, 
			INDEX_GROUP, 
			VOLUME, 
			REALISED_EUR_UNDISC, 
			DELIVERY_MONTH 
	from 
		OPENQUERY(ROCKCAO_CE, 'select * from CAO_CE.XPORT.fin_realized_carmen') c, asofdate
	where 
		c.COB = @COB_DATE_C


	select @step = 130
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - update [dbo].[FilesToImport]', GETDATE () END
	update [dbo].[FilestoImport] set LastImport = getdate() where id = 2450

	select @step = 140
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - delete from [dbo].[01_realised_all]', GETDATE () END
	delete from [dbo].[01_realised_all] where fileid = 2450

	select @step = 150
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - insert into [dbo].[01_realised_all] (1/2)', GETDATE () END
	/*-- current month*/
	insert into [01_realised_all] 
	( 
		[Trade Deal Number], 
		[Trade Reference Text] ,
		[Instrument Type Name] ,
		[Int Legal Entity Name],
		[Internal Portfolio Name] ,
		[Ext Business Unit Name]  ,
		[Ext Legal Entity Name] ,
		[Trade Currency]  ,
		[Cashflow Type] ,
		[Trade Date],
		[Unit Name (Trade Std)] ,
		[Cashflow Payment Date] ,
		[Leg End Date], 
		[Index Group] ,
		[volume] ,
		[Realised_OrigCCY_Undisc] ,
		[Realised_EUR_Undisc] ,
		[FileID]
	)
	select 
		[TRADE_DEAL_NUMBER] , 
		[TRADE_REFERENCE_TEXT], 
		[INS_TYPE_NAME] ,
		[LENTITY_NAME] ,[PORTFOLIO_NAME] ,
		case when c.[ExtBunit] is NULL then left(r.EXT_LENTITY_NAME,100) else c.extbunit end ,
		left([EXT_LENTITY_NAME],100) ,
		[TRADE_CURRENCY] ,
		[CASHFLOW_TYPE],
		[TRADE_DATE],
		[UNIT_NAME],
		[CASHFLOW_PAYMENT_DATE],
		[DELIVERY_MONTH] ,
		[INDEX_GROUP] ,
		[VOLUME] ,
		[REALISED_EUR_UNDISC] ,
		[REALISED_EUR_UNDISC] ,
		2450
	FROM 
		[Strolf_REALIZED_CARMEN] r
		JOIN asofdate d  on r.cob = d.asofdate_eom
		left JOIN [map_CS_counterparty] c on c.[CS_LegalEntity] = r.[EXT_LENTITY_NAME] 


	select @step = 160
	/*-- insert Energy Tax for current year*/
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - insert into [dbo].[01_realised_all] (2/2)', GETDATE () END
  insert into [01_realised_all] 
	( 
		[Trade Deal Number], 
		[Trade Reference Text] ,
		[Instrument Type Name] ,
		[Int Legal Entity Name],
		[Internal Portfolio Name] ,
		[Ext Business Unit Name]  ,
		[Ext Legal Entity Name] ,
		[Trade Currency]  ,
		[Cashflow Type] ,
		[Trade Date],
		[Unit Name (Trade Std)] ,
		[Cashflow Payment Date] ,
		[Leg End Date], 
		[Index Group] ,
		[volume] ,
		[Realised_OrigCCY_Undisc] ,
		[Realised_EUR_Undisc] ,
		[FileID]
	)
  select 
		[TRADE_DEAL_NUMBER] , 
		[TRADE_REFERENCE_TEXT], 
		[INS_TYPE_NAME] ,
		[LENTITY_NAME] ,
		[PORTFOLIO_NAME], 
    case when c.[ExtBunit] is NULL then left(r.EXT_LENTITY_NAME,100) else c.extbunit end ,
		left([EXT_LENTITY_NAME],100) ,
		[TRADE_CURRENCY] ,
		'eTax 1' as Cflowtype,
		[TRADE_DATE],
		[UNIT_NAME],
		[CASHFLOW_PAYMENT_DATE],
		[DELIVERY_MONTH] ,
		Index_Group ,
		[VOLUME] ,
    -[VOLUME]*case when Ins_type_name = 'PWR-FWD-P' then Stromsteuer else Gassteuer end as realised_eur ,
    -[VOLUME]*case when Ins_type_name = 'PWR-FWD-P' then Stromsteuer else Gassteuer end as [REALISED_EUR_UNDISC] ,
		2450
  FROM 
		[Strolf_REALIZED_CARMEN] r
    JOIN asofdate d  on r.cob = d.asofdate_eom
    left JOIN [map_CS_counterparty] c on c.[CS_LegalEntity] = r.[EXT_LENTITY_NAME] 
  WHERE 
		[VOLUME]*case when Ins_type_name = 'PWR-FWD-P' then Stromsteuer else Gassteuer end <>0 
    and  INS_TYPE_NAME in ('GAS-FWD-P','PWR-FWD-P')


	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - FINISHED', GETDATE () END

END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step		
		BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - FAILED', GETDATE () END
	END CATCH

GO

