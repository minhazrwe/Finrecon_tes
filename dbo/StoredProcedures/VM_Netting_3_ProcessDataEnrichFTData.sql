

/* 
-- ==========================================================================================
-- Author:	Dennis Schley
-- Created: 23/11/2021 
-- Purpose: 
-- ==========================================================================================
Changes:
when / who / what why
2024-03-18, PG/MKB, step 50: added DESK to selected fields, request from SH.
2024-03-18, PG/MKB, refurbushed step counter and log writing
2024-03-18, PG, step 51: Added more Desk Information to table_VM_NETTING_4_Analysis_incl_FT
2024-07-16, PG, step 52: Added OrderNumber to table_VM_NETTING_4_Analysis_incl_FT
-- ==========================================================================================
*/
CREATE PROCEDURE [dbo].[VM_Netting_3_ProcessDataEnrichFTData]
AS
BEGIN TRY

	DECLARE @Current_Procedure NVARCHAR(40)
	DECLARE @step INTEGER
	DECLARE @sql NVARCHAR(max)

	DECLARE @Log_Entry nvarchar (200)
	DECLARE @Main_Process nvarchar(20)
	
	/*fill the required variables*/
	SET @step = 1
	SET @Current_Procedure = Object_Name(@@PROCID)
	SET @Main_Process = ''--TESTRUN UNREALISED'

	SELECT @step = 5	
	EXEC dbo.Write_Log 'Info', 'START', @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL

	SELECT @step = 10
	--IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT 'VM_Netting_3_ProcessDataEnrichFTData - insert into [table_VM_NETTING_3_Analysis_incl_CCY_NettingType]'	,GETDATE()	END
	EXEC dbo.Write_Log 'Info', 'insert data', @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL

		-- table_VM_NETTING_3_Analysis_incl_CCY_NettingType erstellen aus BoCar --
	TRUNCATE TABLE [dbo].table_VM_NETTING_3_Analysis_incl_CCY_NettingType
	
	SELECT @step = 11
	INSERT INTO table_VM_NETTING_3_Analysis_incl_CCY_NettingType (
		[DealNumber]
		,[source]
		,[Dealtype] 
		,[DataType] 
		,[Product]
		,[ExchangeCode]
		,[Currency]
		,[Portfolio]
		,[ExternalBU]
		,[ContractDate]
		,[NettingType]
		,[Rate]
		,[RateRisk]
		,[olfpnl]
		,[olfpnlCalcinEURRate]
		,[olfpnlCalcinEURRateRisk]
		)
	SELECT dd.[DealNumber]
		,dd.[source]
		,[Dealtype] 
		,'Bocar' as [DataType] 
		,dd.[Product]
		,dd.[ExchangeCode]
		,dd.[Currency]
		,dd.[Portfolio]
		,dd.[ExternalBU]
		,dd.[ContractDate]
		,gg.[NettingType]
		,[Rate]
		,[RateRisk]
		,sum(dd.[olfpnl]) AS olfpnl
		,sum(dd.olfpnl / fx2.[Rate]) AS olfpnlCalcinEURRate
		,sum(dd.olfpnl / fx2.[RateRisk]) AS olfpnlCalcinEURRateRisk
	FROM 
		[FinRecon].[dbo].[VM_NETTING_Deallevel] AS dd
		LEFT JOIN [FinRecon].[dbo].[table_VM_NETTING_2_Mapping] AS gg ON 
		(
			dd.Product = gg.[Product]
			AND dd.ExchangeCode = gg.[ExchangeCode]
			AND dd.[ExternalBU] = gg.[ExternalBU] --changed by Dennis Schley // added ExternalBU to join criteria
		)
		LEFT JOIN FXRates AS FX2 
		ON dd.Currency = FX2.currency

	GROUP BY dd.[DealNumber]
		,dd.[source]
		,[Dealtype] 
		,dd.[Product]
		,dd.[ExchangeCode]
		,dd.[Currency]
		,dd.[Portfolio]
		,dd.[ExternalBU]
		,dd.[ContractDate]
		,gg.[NettingType]
		,FX2.[Rate]
		,FX2.[RateRisk]

	
	SELECT @step = 20
	---IF @LogInfo >= 1 BEGIN	INSERT INTO [dbo].[Logfile]	SELECT 'VM_Netting_3_ProcessDataEnrichFTData - insert Deferrals into [table_VM_NETTING_3_Analysis_incl_CCY_NettingType]'	,GETDATE()	END
	EXEC dbo.Write_Log 'Info', 'insert Deferrals', @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL

	-- table_VM_NETTING_3_Analysis_incl_CCY_NettingType ergänzen um Deferrals --
	INSERT INTO table_VM_NETTING_3_Analysis_incl_CCY_NettingType (
		[DealNumber]
		,[source]
		,[DataType]
		,[Product]--,[ContractName]
		,[ExchangeCode]--[ContractName]
		,[Currency]
		,[Portfolio]
		,[ExternalBU]
		,[ContractDate]
		,[NettingType]
		,[Rate]
		,[RateRisk]
		,[olfpnl]
		,[olfpnlCalcinEURRate]
		,[olfpnlCalcinEURRateRisk]
		)
	SELECT [DealNumber]
		,[DataSource] 
		,'Deferral' as [DataType] 
		,[ContractName]
		,[ContractName]
		,[CCY]
		-- ,[SettlementDate]
		--,[AccountName]
		,[Portfolio]
		,[ExternalBU]
		,Max([GueltigBis])
		,'VM netting'  as [NettingType]
		-- ,[ProjectionIndex1]
		--,[ProjectionIndex2]
		--,[Toolset]
		-- ,[Position]
		--,[TradePrice]
		--,[SettlementPrice]
		,[Rate]
		,[RateRisk]
		,sum([RealizedPnL])
		,sum([RealizedPnL] / fx2.[Rate]) -- as RealizedPnLCalcinEURRate
		,sum([RealizedPnL] / fx2.[RateRisk]) -- as RealizedPnLCalcinEURRateRisk
	FROM table_VM_NETTING_1a_DeferralInput
			LEFT JOIN FXRates AS FX2 ON dbo.table_VM_NETTING_1a_DeferralInput.[CCY] = FX2.currency
	GROUP BY [DataSource]
		,[CCY]
		,[Portfolio]
		,[SettlementDate]
		,[AccountName]
		,[DealNumber]
		,[ContractName]
		,[ExternalBU]
	--[ContractDate]
		,[ProjectionIndex1]
		,[ProjectionIndex2]
		,[Toolset]
		,[Position]
		,[TradePrice]
		,[SettlementPrice]
		--[RealizedPnL]
		,[Rate]
		,[RateRisk]

	-- table_VM_NETTING_3_Analysis_incl_CCY_NettingType ergänzen um SonstigeBörsen --
	SELECT @step = 30
	--IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile]	SELECT 'VM_Netting_3_ProcessDataEnrichFTData - insert OtherExchanges into [table_VM_NETTING_3_Analysis_incl_CCY_NettingType]' ,GETDATE()	END
	EXEC dbo.Write_Log 'Info', 'insert OtherExchanges', @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL


	INSERT INTO table_VM_NETTING_3_Analysis_incl_CCY_NettingType (
		[DealNumber]
		,[source]
		,[DataType]
		,[Product]
		--,[ExchangeCode]
		,[Currency]
		,[Portfolio]
		,[ExternalBU]
		,[ContractDate]
		,[NettingType]
		,[Rate]
		,[RateRisk]
		,[olfpnl]
		,[olfpnlCalcinEURRate]
		,[olfpnlCalcinEURRateRisk]
		)
	SELECT [DealNumber]
		,[DataSource]
		,'OtherExchanges' as [DataType] 
		,[InsReference]
		,[CCY]
		--[TradeDate] [datetime] NULL,
		--[InternalBU] [nvarchar](255) NULL,
		--	[Position] [float] NULL,
		--[Price] [float] NULL,
		--[BuySell] [nvarchar](255) NULL,
		--[BrokerID] [nvarchar](255) NULL,
		--[StartDate] [datetime] NULL,
		,[Portfolio]
		,[ExternalBU]
		,[MaturityDate]
		,'VM netting'  as [NettingType]
		--[Status] [nvarchar](255) NULL,
		--[Ticker] [nvarchar](255) NULL,
		--[UnrealizedPNL] [float] NULL,
		--[LastUpdate] [datetime] NULL,
		,[Rate]
		,[RateRisk]
		,[UnrealizedPNL]
		,sum([UnrealizedPNL] / fx2.[Rate]) -- as RealizedPnLCalcinEURRate
		,sum([UnrealizedPNL] / fx2.[RateRisk]) -- as RealizedPnLCalcinEURRateRisk
	FROM table_VM_NETTING_1b_OtherExchangesInput
	LEFT JOIN FXRates AS FX2 ON dbo.table_VM_NETTING_1b_OtherExchangesInput.[CCY] = FX2.currency
	GROUP BY [DataSource]
		,[CCY]
		,[Portfolio]
		,[ExternalBU]
		,[MaturityDate]
		,[DealNumber]
		,[Position]
		,[UnrealizedPNL]
		,[Rate]
		,[RateRisk]
		,[InsReference]

	
	
	SELECT @step = 40	
	--IF @LogInfo >= 1 BEGIN	INSERT INTO [dbo].[Logfile]	SELECT 'VM_Netting_3_ProcessDataEnrichFTData - empty table [table_VM_NETTING_4_Analysis_incl_FT]'	,GETDATE()	END
	EXEC dbo.Write_Log 'Info', 'insert more data', @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL

	TRUNCATE TABLE [dbo].[table_VM_NETTING_4_Analysis_incl_FT]
	
	SELECT @step =50

	/*
update dbo.table_VM_NETTING_1a_DeferralInput		
		set table_VM_NETTING_1a_DeferralInput.AccountName = 'NC RWE D02C/NC RWE T01C/NC RWE FO03C'
		from   ([FinRecon].[dbo].[table_VM_NETTING_1a_DeferralInput] left join  (select distinct accountname, externalbusinessunit from table_Clearer_map_ExternalBusinessUnit) as d on [table_VM_NETTING_1a_DeferralInput].AccountName = d.AccountName)
		where table_VM_NETTING_1a_DeferralInput.DataSource in ('Nasdaq Kaskade EUR')
		
update dbo.table_VM_NETTING_1a_DeferralInput		
		set 
		table_VM_NETTING_1a_DeferralInput.ExternalBU = d.[externalbusinessunit]
		from   ([FinRecon].[dbo].[table_VM_NETTING_1a_DeferralInput] left join  (select distinct accountname, externalbusinessunit, CCY from table_Clearer_map_ExternalBusinessUnit) as d on [table_VM_NETTING_1a_DeferralInput].AccountName = d.AccountName)
		where table_VM_NETTING_1a_DeferralInput.ExternalBU is null  

update dbo.table_VM_NETTING_1a_DeferralInput		
		set 
		,table_VM_NETTING_1a_DeferralInput.CCY = d.CCY
		from   ([FinRecon].[dbo].[table_VM_NETTING_1a_DeferralInput] left join  (select distinct accountname, externalbusinessunit, CCY from table_Clearer_map_ExternalBusinessUnit) as d on [table_VM_NETTING_1a_DeferralInput].AccountName = d.AccountName)
		where table_VM_NETTING_1a_DeferralInput.CCY is null */ 

	
	-- table_VM_NETTING_4_Analysis_incl_FT inklusive der FT-Daten erstellen --
	INSERT INTO table_VM_NETTING_4_Analysis_incl_FT 
	(
		 [BODealNumber]
		,[BOsource]
		,[BODataType]
		,[BODealtype] 
		,[FTSubsidiary]
		,[FTStrategy]
		,[FTBook]
		,[FTReferenceID]
		,[FTInternalPortfolio]
		,[FTExtBusinessUnit]
		,[FTExtLegalEntity]
		,[FTCounterpartyGroup]
		,[FTCurvename]
		,[FTProjIndexGroup]
		,[FTInstrumentType]
		,[FTAccountingTreatment]
		,[BOProduct]
		,[BOExchangeCode]
		,[BOCurrency]
		,[BOPortfolio]
		,[BOExternalBU]
		,[BOContractDate]
		,[BONettingType]
		,[FTProductYearTermEnd]
		,[BORate]
		,[BORateRisk]
		,[BOolfpnl]
		,[BOolfpnlCalcinEURRate]
		,[BOolfpnlCalcinEURRateRisk]
		,[FTSummeVolume]
		,[FTSummeVolumefinal]
		,[FTPNL]
		,[FTOCI]
		,[FTTotal_MtM]
		,[FTTotal_MtMCalcinFXCCYRateRisk]
		,[DiffBOolfpnlCalcinEURRateRiskFTTotal_MtM]
    ,[FinMtMtoNet]
    ,[posnegVM]
    ,[CheckVZ]
    ,[HedgeExtern]
		,Desk
	)
	SELECT 
		 [DealNumber] AS [BODealNumber]
		,[source] AS [BOsource]
		,[DataType] as [BODataType]
		,[Dealtype] 
		,[FTSubsidiary]
		,[FTStrategy]
		,[FTBook]
		,[FTReferenceID]
		,[FTInternalPortfolio]
		,[FTExtBusinessUnit]
		,[FTExtLegalEntity]
		,[FTCounterpartyGroup]
		,[FTCurvename]
		,[FTProjIndexGroup]
		,[FTInstrumentType]
		,[FTAccountingTreatment]
		,table_VM_NETTING_3_Analysis_incl_CCY_NettingType.[Product] AS [BOProduct]
		,[dbo].table_VM_NETTING_3_Analysis_incl_CCY_NettingType.[ExchangeCode] AS [BOExchangeCode]
		,[Currency] AS [BOCurrency]
		,[Portfolio] AS [BOPortfolio]
		,[dbo].table_VM_NETTING_3_Analysis_incl_CCY_NettingType.[ExternalBU] AS [BOExternalBU]
		,[ContractDate] AS [BOContractDate]
		,[dbo].table_VM_NETTING_3_Analysis_incl_CCY_NettingType.[NettingType] AS [BONettingType]
		,[FTProductYearTermEnd]
		,[Rate] AS [BORate]
		,[RateRisk] AS [BORateRisk]
		,[olfpnl] AS [BOolfpnl]
		,[olfpnlCalcinEURRate] AS [BOolfpnlCalcinEURRate]
		,[olfpnlCalcinEURRateRisk] AS [BOolfpnlCalcinEURRateRisk]
		,[FTSummeVolume]
		,[FTSummeVolumefinal] = case when abs(FTpnl)>0 or (FTpnl=0 and [FTOCI] = 0 and abs(FTvolumeused)=0) then FTvolumeavailable 
				when (abs(FTvolumeused)>0  or abs(FTOCI)>0) then FTvolumeused else 0 end  -- Unterscheidung volumeused bei 'extern' oder volumeavailable bei 'hedge' 
		,[FTPNL]
		,[FTOCI]
		,[FTTotal_MtM]
		,[FTTotal_MtMCalcinFXCCYRateRisk] = [FTTotal_MtM] * [RateRisk] 
		,[DiffBOolfpnlCalcinEURRateRiskFTTotal_MtM] = ([olfpnlCalcinEURRateRisk]-[FTTotal_MtM])
    ,[FinMtMtoNet] = case when (abs([FTTotal_MtM])-abs([olfpnlCalcinEURRate])) >0 then [olfpnlCalcinEURRate] else [FTTotal_MtM] end  --6/01 - changed to EURRate instead of RateRisk as SAP is using that rate concept.
    ,[posnegVM] = case when [olfpnl] <0 then 'neg' else 'pos' end 
    ,[CheckVZ] = case when ([olfpnl] <0 and [FTTotal_MtM] >0) or ([olfpnl] >0 and [FTTotal_MtM] <0) then 'Exclude' else 'ok' end   -- 3.12.21 korrigiert von  ,[CheckVZ] = case when ([olfpnl] <0 and [olfpnlCalcinEURRateRisk] >0) or ([olfpnl] >0 and [olfpnlCalcinEURRateRisk] <0) then 'Exclude' else 'ok' end 
    ,[HedgeExtern] = case when abs(FTpnl)>0 or (FTpnl=0 and [FTOCI] = 0 and abs(FTvolumeused)=0) then 'Extern' when (abs(FTvolumeused)>0  or abs(FToci)>0) then 'Hedge' else '' end 
		,Desk
	FROM [FinRecon].[dbo].table_VM_NETTING_3_Analysis_incl_CCY_NettingType
	LEFT JOIN (
		SELECT
			[Subsidiary] AS [FTSubsidiary]
			,[Strategy] AS [FTStrategy]
			,[Book] AS [FTBook]
			,[ReferenceID] AS [FTReferenceID]
			,[InternalPortfolio] AS [FTInternalPortfolio]
			,[ExternalBusinessUnit] AS [FTExtBusinessUnit]
			,[ExtLegalEntity] AS [FTExtLegalEntity]
			,[CounterpartyGroup] AS [FTCounterpartyGroup]
			,sum([Volume]) AS FTSummeVolume
			,[Curvename] AS [FTCurvename]
			,[ProjIndexGroup] AS [FTProjIndexGroup]
			,[InstrumentType] AS [FTInstrumentType]
			,[AccountingTreatment] AS [FTAccountingTreatment]
			,max(format(Termend, 'yyyy/MM')) AS [FTProductYearTermEnd]
			,sum([PNL]) AS FTPNL
			,sum([OCI]) AS FTOCI
			,sum([Total_MtM]) AS FTTotal_MtM
			,SUM(volumeused) as FTvolumeused
			,SUM(volumeavailable) as FTvolumeavailable
			,Desk
		FROM 
			[dbo].[FASTracker_EOM]
		GROUP BY
			 [Subsidiary]
			,[Strategy]
			,[Book]
			,[ReferenceID]
			,[InternalPortfolio]
			,[ExternalBusinessUnit]
			,[ExtLegalEntity]
			,[CounterpartyGroup]
			,[Curvename]
			,[ProjIndexGroup]
			,[InstrumentType]
			,[AccountingTreatment]
			, Desk
		--	,format(Termend, 'yyyy/MM')
		) AS bb ON [dbo].table_VM_NETTING_3_Analysis_incl_CCY_NettingType.[DealNumber] = bb.[FTReferenceID]


		SELECT @step = 51
		EXEC dbo.Write_Log 'Info', 'adding Desk informations', @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL

		-- Update Desk information p1 // PG 03.03.2024
		UPDATE table_VM_NETTING_4_Analysis_incl_FT 
		SET 
			desk = RiskRecon.Desk
		FROM 
			table_VM_NETTING_4_Analysis_incl_FT INNER JOIN dbo.RiskRecon 
			ON table_VM_NETTING_4_Analysis_incl_FT.BODealNumber = RiskRecon.DealID
		WHERE 
			table_VM_NETTING_4_Analysis_incl_FT.desk IS NULL;

		-- Update Desk information p2 // PG 03.03.2024
		UPDATE table_VM_NETTING_4_Analysis_incl_FT
		SET 
			desk = [02_Realised_all_details].IntDesk
		FROM 
			table_VM_NETTING_4_Analysis_incl_FT INNER JOIN dbo.[02_Realised_all_details]
			ON table_VM_NETTING_4_Analysis_incl_FT.BODealNumber = [02_Realised_all_details].Deal
		WHERE 
			table_VM_NETTING_4_Analysis_incl_FT.desk IS NULL;

		SELECT @step = 52
		EXEC dbo.Write_Log 'Info', 'adding OrderNumber information', @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL

		--Add Ordernumber to table_VM_NETTING_4_Analysis_incl_FT // added on 16/07/2024 by PG -- request by Dennis Schley / Anna Lena Maas 
		Update table_VM_NETTING_4_Analysis_incl_FT
		Set 
			OrderNumber = map_order.OrderNo
		From 
			table_VM_NETTING_4_Analysis_incl_FT LEFT JOIN dbo.map_order 
			ON table_VM_NETTING_4_Analysis_incl_FT.FTInternalPortfolio = map_order.Portfolio

		-- added for the "Realised" data on the HedgeExtern Field to get these Ordernumbers // added on 29.07.2024 PG
		Update table_VM_NETTING_4_Analysis_incl_FT
		Set 
			OrderNumber = [02_Realised_all_details].OrderNo
		From 
			table_VM_NETTING_4_Analysis_incl_FT LEFT JOIN dbo.[02_Realised_all_details]
			ON table_VM_NETTING_4_Analysis_incl_FT.BODealNumber = [02_Realised_all_details].Deal
		where 
			table_VM_NETTING_4_Analysis_incl_FT.OrderNumber IS NULL

		SELECT @step = 60
		--BEGIN INSERT INTO [dbo].[Logfile] SELECT 'VM_Netting_3_ProcessDataEnrichFTData - Add LE to Realised Data'	,GETDATE()	END
		EXEC dbo.Write_Log 'Info', 'add LE to realised data', @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL


		--Update [FTSubsidiary] and [HedgeExtern]
		UPDATE [FinRecon].[dbo].table_VM_NETTING_4_Analysis_incl_FT
		SET [FinRecon].[dbo].table_VM_NETTING_4_Analysis_incl_FT.[FTSubsidiary] = dd.[Int Legal Entity Name], [HedgeExtern] = 'Realised'
		FROM table_VM_NETTING_4_Analysis_incl_FT
		LEFT JOIN (
			SELECT [Trade Deal Number]
				,Case 
				when [Int Legal Entity Name] = 'RWE TS DE PE' Then 'Trading Services Essen' 
				when [Int Legal Entity Name] = 'RWEST ASIA PACIFIC PE' Then 'RWEST Asia Pacific' 
				when [Int Legal Entity Name] = 'RWEST CZ PE' Then 'RWEST CZ' 
				when [Int Legal Entity Name] = 'RWEST DE - PE' Then 'RWEST DE' 
				when [Int Legal Entity Name] = 'RWEST INDIA PE' Then 'RWEST INDIA' 
				when [Int Legal Entity Name] = 'RWEST JAPAN PE' Then 'RWEST Japan' 
				when [Int Legal Entity Name] = 'RWEST SHANGHAI PE' Then 'RWEST Shanghai' 
				when [Int Legal Entity Name] = 'RWEST UK - PE' Then 'RWEST UK' 
				else [Int Legal Entity Name] end as [Int Legal Entity Name]
			FROM [dbo].[01_realised_all]
			GROUP BY [Trade Deal Number]
				,[Int Legal Entity Name]
			) AS dd ON [dbo].table_VM_NETTING_4_Analysis_incl_FT.[BODealNumber] = dd.[Trade Deal Number]
		where [FTSubsidiary] is null and dd.[Int Legal Entity Name] is not null

		SELECT @step = 70
		--BEGIN INSERT INTO [dbo].[Logfile] SELECT 'VM_Netting_3_ProcessDataEnrichFTData - DONE' ,GETDATE()	END
				EXEC dbo.Write_Log 'Info', 'FINISHED', @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL
		
END TRY


BEGIN CATCH
	/*tell the world procedure failed*/
	EXEC [dbo].[usp_GetErrorInfo] @Current_Procedure, @step, @Main_Process; 
	EXEC dbo.Write_Log 'FAILED', 'FAILED with error, details in ERROR entry', @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL;
	RETURN @step

END CATCH

GO

