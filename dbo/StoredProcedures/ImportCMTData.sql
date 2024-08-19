




/*
	Inserts data from a csv file, based on the entries in Table dbo.ImportFiles, for the passed @ImportType e.g. Endur
	which would import data into Table EndurImport.
	Calls: omly the ssis-package for import
*/
	CREATE PROCEDURE [dbo].[ImportCMTData] 

	AS
	BEGIN TRY
		-- define some variables that been needed
		DECLARE @package nvarchar(200)
		DECLARE @CurrentServer nvarchar(200)
		DECLARE @StarterParm nvarchar(500)
		DECLARE @StarterDB nvarchar(50)
		DECLARE @FileName nvarchar (50) 
		DECLARE @PathName nvarchar (300)
		DECLARE @TimeStamp datetime
		DECLARE @LogInfo Integer
		DECLARE @proc nvarchar(40)
		DECLARE @step Integer
		DECLARE @asofdate datetime
		DECLARE @sql nvarchar (max)

		select @step = 1
		select @proc = '[dbo].[ImportCMTData]'

		-- we need the LogInfo for Logging
		select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

		select @step = @step + 1
		select @PathName = [path] from [dbo].[pathToFiles] where [source] = 'CMT'

		select @step = @step + 1
		select @FileName = [FileName] from [dbo].[FilesToImport] where [source] = 'CMT'

		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select '### getdate ###', GETDATE () END
		select @step = @step + 1
		select @TimeStamp = getdate()
	
		select @step = @step + 1
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @PathName + @FileName, @TimeStamp END

		select @step = @step + 1
		truncate table [dbo].[import_paymentdates_cmt]

		select @step = @step + 1
    	select @sql = N'BULK INSERT .[dbo].[import_Paymentdates_CMT] FROM '  + '''' + @PathName + @FileName + ''''  + ' WITH (FIELDTERMINATOR =''~'', FIRSTROW = 2, ROWTERMINATOR =''\n'')';
		execute sp_executesql @sql

		select @step = @step + 1
		truncate table [dbo].[Paymentdates_CMT]
	
		select @step = @step + 1
		insert into [dbo].[paymentdates_cmt] ([IntLegalEntityName], [Desk], [IntBusinessUnitName],[InternalPortfolioName], [ExtLegalEntityName],
					[ExtBusinessUnitName], [TradeDealNumber], [InstrumentTypeName],[TradeReferenceText], [TradeCurrency],[TransactionInfoBuySell],[CashflowType],
					[CashflowDeliveryMonth],[TradeDate],[UnitName],[CashflowPaymentDate],[LegEndDate],[IndexGroup], [Volume],[RealisedUndiscountedOriginalCurrency],
					[UnrealisedUndiscountedOriginalCurrency])
		select  [IntLegalEntityName], [Desk], [IntBusinessUnitName],[InternalPortfolioName], [ExtLegalEntityName],
				[ExtBusinessUnitName], [TradeDealNumber], [InstrumentTypeName],[TradeReferenceText], [TradeCurrency],[TransactionInfoBuySell],[CashflowType],
				[CashflowDeliveryMonth],[TradeDate],[UnitName],[CashflowPaymentDate],[LegEndDate],[IndexGroup], 
				[Volume] = CASE [Volume] when '-' THEN cast('0' as float ) ELSE cast(replace(replace(replace([Volume],',',''),'(',''),')','')as float) END,
				[RealisedUndiscountedOriginalCurrency] =  CASE [RealisedUndiscountedOriginalCurrency] when '-' THEN cast('0' as float ) ELSE cast(replace(replace(replace([RealisedUndiscountedOriginalCurrency],',',''),'(',''),')','')as float) END,
				[UnRealisedUndiscountedOriginalCurrency] = CASE [UnRealisedUndiscountedOriginalCurrency] when '-' THEN cast('0' as float ) ELSE cast(replace(replace(replace([UnRealisedUndiscountedOriginalCurrency],',',''),'(',''),')','')as float) END
				from [dbo].[import_Paymentdates_CMT]


		select @step = @step + 1
		update dbo.Paymentdates_CMT 
		set dbo.paymentdates_cmt.ctpygroup = c.[ctpygroup], 
			dbo.paymentdates_cmt.countrycode = c.[Country],
			dbo.paymentdates_cmt.CPNumber = c.Debitor,
			dbo.paymentdates_cmt.realised = convert(float,p.realisedundiscountedoriginalcurrency) + convert(float,p.unrealisedundiscountedoriginalcurrency),
			dbo.paymentdates_cmt.Volume_new =  (-Round( case when [InstrumentTypeName] = 'PWR-FWD-P' And p.[IndexGroup] Not In ('Electricity') And p.UnitName Not In ('MWH') then 0 else 
			case when i.[InstrumentGroup] = 'phys' and p.[InstrumentTypeName] not in ('GAS-EXCH-P','PWR-OPT-TRANS-H-P')
			then (p.[volume]*uom.[conv]) else 0 end end ,3 )) ,
			dbo.paymentdates_cmt.uom = uom.unit_to,
			dbo.paymentdates_cmt.deskFin = o.Desk
		from ((((dbo.[paymentdates_cmt] p left join dbo.map_counterparty c on p.extBusinessUnitName = c.ExtBunit) 
										left join dbo.map_instrument i on p.instrumenttypename = i.instrumenttype)
										left join dbo.map_uom_conversion uom on p.unitname = uom.unit_from)	
										left join dbo.map_order o on p.InternalPortfolioName = o.Portfolio)

		select @step = @step + 1
		UPDATE	[dbo].[Paymentdates_CMT] 
			SET	[dbo].[Paymentdates_CMT].[GLAccount] = [dbo].map_accounts.[Account_Loss], 
				[dbo].[Paymentdates_CMT].[TaxCode_zw1] = [dbo].[map_accounts].[VAT_Group]
			from ([dbo].[Paymentdates_CMT] inner join [dbo].[map_accounts] on 
				[dbo].[Paymentdates_CMT].[InstrumentTypeName] = [dbo].[map_accounts].[InstrumentType]
				AND [dbo].[Paymentdates_CMT].[IndexGroup] = [dbo].[map_accounts].[Commodity]
				AND [dbo].[Paymentdates_CMT].[CashflowType] = [dbo].[map_accounts].[CashflowType]
				AND dbo.[Paymentdates_CMT].[ctpygroup] = [dbo].[map_accounts].[CtpyGroup]
				AND [dbo].[Paymentdates_CMT].[DeskFin] = [dbo].[map_accounts].[Desk])
			
				inner join (select dbo.[Paymentdates_CMT].TradeDealNumber, case when sum(round(realised,10)) < 0 then 'negative' else 'positive' end as posneg		
			from dbo.[Paymentdates_CMT] group by TradeDealNumber) as posneg on dbo.[Paymentdates_CMT].TradeDealNumber = posneg.TradeDealNumber
			where posneg.posneg = 'negative' and dbo.[Paymentdates_CMT].InstrumentTypeName not like '%swap%'

		select @step = @step + 1
		UPDATE [dbo].[PaymentDates_CMT] 
		SET [dbo].[PaymentDates_CMT].[GLAccount] = [dbo].map_accounts.[Account_Loss], 
			[dbo].[PaymentDates_CMT].[TaxCode_zw1] = [dbo].[map_accounts].[VAT_Group]
		from ([dbo].[Paymentdates_CMT] inner join [dbo].[map_accounts] on 
			[dbo].[Paymentdates_CMT].[InstrumentTypeName] = [dbo].[map_accounts].[InstrumentType]
			AND [dbo].[Paymentdates_CMT].[IndexGroup] = [dbo].[map_accounts].[Commodity]
			AND [dbo].[Paymentdates_CMT].[CashflowType] = [dbo].[map_accounts].[CashflowType]
			AND dbo.[Paymentdates_CMT].[ctpygroup] = [dbo].[map_accounts].[CtpyGroup]
			AND [dbo].[Paymentdates_CMT].[DeskFin] = [dbo].[map_accounts].[Desk])
		where round([dbo].[PaymentDates_CMT].Realised,10) < 0 and dbo.[PaymentDates_CMT].InstrumentTypeName  like '%swap%'

		select @step = @step + 1
		UPDATE [dbo].[PaymentDates_CMT] 
		SET [dbo].[PaymentDates_CMT].[GLAccount] = [dbo].map_accounts.[Account_Profit], 
			[dbo].[PaymentDates_CMT].[TaxCode_zw1] = [dbo].[map_accounts].[VAT_Group]
		from  ([dbo].[Paymentdates_CMT] inner join [dbo].[map_accounts] on 
			[dbo].[Paymentdates_CMT].[InstrumentTypeName] = [dbo].[map_accounts].[InstrumentType]
			AND [dbo].[Paymentdates_CMT].[IndexGroup] = [dbo].[map_accounts].[Commodity]
			AND [dbo].[Paymentdates_CMT].[CashflowType] = [dbo].[map_accounts].[CashflowType]
			AND dbo.[Paymentdates_CMT].[ctpygroup] = [dbo].[map_accounts].[CtpyGroup]
			AND [dbo].[Paymentdates_CMT].[DeskFin] = [dbo].[map_accounts].[Desk]) inner join (select dbo.[PaymentDates_CMT].TradeDealNumber, case when sum(round(realised,10)) < 0 then 'negative' else 'positive' end as posneg		
		from dbo.[PaymentDates_CMT] group by TradeDealNumber) as posneg on dbo.[PaymentDates_CMT].TradeDealNumber = posneg.TradeDealNumber
		where posneg.posneg = 'positive' and dbo.[PaymentDates_CMT].InstrumentTypeName not like '%swap%'

		select @step = @step + 1
		UPDATE [dbo].[PaymentDates_CMT] 
		SET [dbo].[PaymentDates_CMT].[GLAccount] = [dbo].map_accounts.[Account_Profit], 
			[dbo].[PaymentDates_CMT].[TaxCode_zw1] = [dbo].[map_accounts].[VAT_Group]
		from  ([dbo].[Paymentdates_CMT] inner join [dbo].[map_accounts] on 
			[dbo].[Paymentdates_CMT].[InstrumentTypeName] = [dbo].[map_accounts].[InstrumentType]
			AND [dbo].[Paymentdates_CMT].[IndexGroup] = [dbo].[map_accounts].[Commodity]
			AND [dbo].[Paymentdates_CMT].[CashflowType] = [dbo].[map_accounts].[CashflowType]
			AND dbo.[Paymentdates_CMT].[ctpygroup] = [dbo].[map_accounts].[CtpyGroup]
			AND [dbo].[Paymentdates_CMT].[DeskFin] = [dbo].[map_accounts].[Desk])
		where round([dbo].[PaymentDates_CMT].Realised,10) > 0 and dbo.[PaymentDates_CMT].InstrumentTypeName  like '%swap%'

		select @step = @step + 1
		UPDATE [dbo].[PaymentDates_CMT]
		SET [dbo].[PaymentDates_CMT].[GLAccount] = 
			case when round([dbo].[PaymentDates_CMT].[volume],10) < 0 then [dbo].map_accounts.[Account_Profit] else [dbo].map_accounts.[Account_Loss] end, 
			[dbo].[PaymentDates_CMT].[TaxCode_zw1] = [dbo].[map_accounts].[VAT_Group]
		from  ([dbo].[Paymentdates_CMT] inner join [dbo].[map_accounts] on 
			[dbo].[Paymentdates_CMT].[InstrumentTypeName] = [dbo].[map_accounts].[InstrumentType]
			AND [dbo].[Paymentdates_CMT].[IndexGroup] = [dbo].[map_accounts].[Commodity]
			AND [dbo].[Paymentdates_CMT].[CashflowType] = [dbo].[map_accounts].[CashflowType]
			AND dbo.[Paymentdates_CMT].[ctpygroup] = [dbo].[map_accounts].[CtpyGroup]
			AND [dbo].[Paymentdates_CMT].[DeskFin] = [dbo].[map_accounts].[Desk])
		WHERE round([PaymentDates_CMT].[Realised],10) = 0

	select @step = @step + 1
	UPDATE [dbo].[Paymentdates_CMT] 
		SET [dbo].[Paymentdates_CMT] .[TaxCode] = 
			case when round([dbo].[Paymentdates_CMT] .[Realised],10) > 0 
				And [dbo].[Paymentdates_CMT].[TransactionInfoBuySell] = 'Buy' 
				And [dbo].[02g_Steuer_zw1].[Sells] = 'D6' 
			then 'A9'  
			else 
				case when round([dbo].[Paymentdates_CMT].[realised],10) > 0 
				then [dbo].[02g_Steuer_zw1].[Sells] 
				else 
					case when round([dbo].[Paymentdates_CMT].[volume_new],10) > 0 
					then [dbo].[02g_Steuer_zw1].[Sells] else [dbo].[02g_Steuer_zw1].[Buys] end end end
		from [dbo].[Paymentdates_CMT] LEFT JOIN [dbo].[02g_Steuer_zw1] 
		ON [dbo].[Paymentdates_CMT].[TaxCode_zw1] = [dbo].[02g_Steuer_zw1].[VAT_Group] 
		AND [dbo].[Paymentdates_CMT].CountryCode = [dbo].[02g_Steuer_zw1].countrycode
		AND [dbo].[Paymentdates_CMT].[ctpygroup] = [dbo].[02g_Steuer_zw1].ctpygroup 
	
	END TRY

	BEGIN CATCH
		--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
	END CATCH

GO

