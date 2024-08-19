


/* 
Author:		MKB
purpose:	PROCEDURE InsertIntoReconInternal is used within the process of internal recon of Interdesk / Intradesk / InterPE
					frontend is access-db: "Abgleich_Interne_Geschäfte_YYYY_MM" located under "COE-AT-C...\01_RWEST\02_Unrealised\Interne"
					used as well after  import of FT_ALL.
============================
changes:
07-05-2024:   Changed WHERE CLAUSE for accountingtreatment = 'Hedging Instrument (Der)'

*/

	CREATE PROCEDURE [dbo].[InsertIntoReconInternal] 
	AS
	BEGIN TRY
	------------------------------------
		DECLARE @LogInfo Integer
		DECLARE @step Integer
		DECLARE @proc varchar(40)

		select @step = 1
		SELECT @proc = Object_Name(@@PROCID)
		
		-- get LogInfo for Logging
		select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - START', GETDATE () END

		
		select @step = 10		
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - deleting old data entries', GETDATE () END
		TRUNCATE TABLE [dbo].[Recon_InternalAll]
		Truncate table [dbo].[Recon_InternalAll_Details] 

		select @step = 15 
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - Refill Recon_InternalAll', GETDATE () END
		
		INSERT INTO [dbo].[Recon_InternalAll]
				([AsofDate]
				,[Sub ID]
				,[ReferenceID]
				,[TradeDate]
				,[TermStart]
				,[TermEnd]
				,[InternalPortfolio]
				,[SourceSystemBookID]
				,[Counterparty_ExtBunit]
				,[CounterpartyGroup]
				,[Volume]
				,[FixedPrice]
				,[CurveName]
				,[ProjIndexGroup]
				,[InstrumentType]
				,[UOM]
				,[ExtLegalEntity]
				,[ExtPortfolio]
				,[Product]
				,[Discounted_MTM]
				,[Discounted_PNL]
				,[Discounted_AOCI]
				,[Undiscounted_MTM]
				,[Undiscounted_PNL]
				,[Undiscounted_AOCI]
				,[Volume Available]
				,[Volume Used]
				,[Subsidiary]
				,[Strategy]
				,[UnhedgedSTAsset]
				,[UnhedgedSTLiability]
				,[UnrealizedEarnings]
				,[accountingtreatment]
				,[PortfolioID]
				,[Account_Asset]
				,[Account_Liab]
				,[Account_PNL]
				,[LastUpdate])
		SELECT 
			 [AsofDate] 
			,[Sub ID]
			,[ReferenceID]
			,[Trade Date]
			,[TermStart]
			,[TermEnd]
			,FASTracker.[InternalPortfolio]
			,[SourceSystemBookID]
			,[Counterparty_ExtBunit]
			,FASTracker.[CounterpartyGroup]
			,[Volume]
			,[FixedPrice]
			,[CurveName]
			,[ProjIndexGroup]
			,FASTracker.[InstrumentType]
			,[UOM]
			,[ExtLegalEntity]
			,[ExtPortfolio]
			,[Product]
			,[Discounted_MTM]
			,[Discounted_PNL]
			,[Discounted_AOCI]
			,[Undiscounted_MTM]
			,[Undiscounted_PNL]
			,[Undiscounted_AOCI]
			,[Volume Available]
			,[Volume Used]
			,[subsidiary]
			,[strategy]
			,[UnhedgedSTAsset]
			,[UnhedgedSTLiability]
			,[UnrealizedEarnings]
			,[accountingtreatment] 
			,[PortfolioID]
			,[Asset]
			,[Liab]
			,[PNL]
			,getdate()
		FROM dbo.FASTracker 
		inner join 
				(SELECT  	 
					 subsidiary
					,strategy
					,InternalPortfolio
					,CounterpartyGroup
					,InstrumentType
					,ProjectionIndexGroup
					,UnhedgedSTAsset
					,UnhedgedSTLiability
					,UnrealizedEarnings 
					,accountingtreatment 
					,PortfolioID
					,left([UnhedgedSTAsset],8) as asset
					,left([UnhedgedSTLiability],8) as liab
					,left([UnrealizedEarnings],8) as pnl
				FROM 
					dbo.map_SBM 
				WHERE
					[AccountingTreatment] = 'Hedging Instrument (Der)'
					AND 
					( UnhedgedSTAsset like '%I1389153%' 
					OR UnhedgedSTAsset like '%I1389156%')
					OR( SUBSTRING([UnhedgedSTAsset], CHARINDEX('.', [UnhedgedSTAsset], CHARINDEX('.', [UnhedgedSTAsset]) + 1) + 1, 4) IN ('3080', '2648', '1702', '4026', '3304', '8918', '1445'))
								) as x		
				on FASTracker.InternalPortfolio = x.InternalPortfolio
						AND FASTracker.CounterpartyGroup = x.CounterpartyGroup
						AND FASTracker.InstrumentType = x.InstrumentType
						AND FASTracker.ProjIndexGroup = x.ProjectionIndexGroup		

		-- refill table "Recon_InternalAll_Details"
		select @step = 25
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - Refill Recon_InternalAll_Details', GETDATE () END

		INSERT INTO [dbo].[Recon_InternalAll_Details] 
			SELECT 
				ISNULL(Mappinggroup,'check - ' + [Recon_InternalAll].[Subsidiary] +' vs. ' + [Recon_InternalAll].[CounterpartyGroup]) AS 'Recon'
				, Recon_InternalAll.InstrumentType
				, Recon_InternalAll.ReferenceID
				, Recon_InternalAll.InternalPortfolio
				, Recon_InternalAll.ExtPortfolio
				, Recon_InternalAll.Product
				, Recon_InternalAll.TradeDate
				, Max(Recon_InternalAll.TermEnd) AS LastTermEnd
				, Recon_InternalAll.Account_Asset
				, Recon_InternalAll.Account_Liab
				, Recon_InternalAll.Account_PNL
				, round(Sum(case when [Recon_InternalAll].[Subsidiary] = 'RWEST DE' And [strategy] Not In ('CAO GAS CZ') then [Discounted_mtm] else 0 end),2) AS [RWEST_DE]
				, round(Sum(case when [Recon_InternalAll].[Subsidiary] = 'RWEST UK' then [Discounted_mtm] else 0 end),2) AS [RWEST_UK] 
				, round(Sum(case when [strategy]											 = 'CAO GAS CZ' then [Discounted_mtm] else 0 end),2) AS [RWEST_CZ] 
				, round(Sum(case when [Recon_InternalAll].[Subsidiary] = 'RWEST Participations' then [Discounted_mtm] else 0 end),2) AS [RWEST_P] 
				, round(Sum(case when [Recon_InternalAll].[Subsidiary] in('RWEST Asia Pacific','RWEST Asia Pacific PE')  then [Discounted_mtm] else 0 end),2) AS [RWEST_AP] 
				, round(Sum(case when [Recon_InternalAll].[Subsidiary] = 'RWEST Shanghai' then [Discounted_mtm] else 0 end),2) AS [RWEST_SH] 
				, round(Sum(case when [Recon_InternalAll].[Subsidiary] = 'Trading Services Essen' then [Discounted_mtm] else 0 end),2) AS [TS_DE] 
				, round(Sum(case when [Recon_InternalAll].[Subsidiary] = 'RWE Trading Services UK' then [Discounted_mtm] else 0 end),2) AS [TS_UK] 
				, round(Sum(Recon_InternalAll.Discounted_MTM),2) AS 'MtM'	
				, round(Abs(Sum([discounted_mtm])),2) AS Diffabs
				,getdate()
			FROM 
				Recon_InternalAll 
				LEFT JOIN map_InterPE ON 
					Recon_InternalAll.subsidiary = map_InterPE.Subsidiary
					AND Recon_InternalAll.CounterpartyGroup = map_InterPE.CounterpartyGroup
			GROUP BY 
				ISNULL(Mappinggroup,'check - ' + [Recon_InternalAll].[Subsidiary] +' vs. ' + [Recon_InternalAll].[CounterpartyGroup]) 
				, Recon_InternalAll.InstrumentType
				, Recon_InternalAll.ReferenceID
				, Recon_InternalAll.InternalPortfolio
				, Recon_InternalAll.ExtPortfolio
				, Recon_InternalAll.Product
				, Recon_InternalAll.tradedate
				, Recon_InternalAll.Account_Asset
				, Recon_InternalAll.Account_Liab
				, Recon_InternalAll.Account_PNL

		
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - FINISHED', GETDATE () END

END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
		BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - FAILED', GETDATE () END
	END CATCH

GO

