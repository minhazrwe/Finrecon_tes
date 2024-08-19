

/* 
==========================================================================================
Author:      unknown
Created:     unknown
Description:	
------------------------------------------------------------------------------------------
change history: when, who, step, what, (why)
2024-07-05, mkb, all , inserted this header, hard coded steps 
=========================================================================================
*/

CREATE PROCEDURE [dbo].[D2D]

	@Area nvarchar (2),
	@CorrectionsOnly nvarchar (3)

AS
BEGIN TRY

		DECLARE @Current_Procedure nvarchar(40)
		DECLARE @step Integer
		DECLARE @LogInfo Integer
		DECLARE @AsOfDate Date

		select @step = 1
		SET @Current_Procedure = Object_Name(@@PROCID) 
		--select @proc = '[dbo].[D2D_AP]'
	

		SET @step = 2
		select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]


		SET @step = 3
		select @AsOfDate = AsOfDate_EOM from dbo.AsOfDate

	
		SET @step = 4
		DROP TABLE IF EXISTS [dbo].[D2D_map_order]

	
	
		SET @step = 5
		select map_order.Portfolio, Max(map_order.orderno) AS MaxvonAuftrag, Max(map_order.Desk) AS Desk, Max(map_order.LegalEntity) AS MaxvonLegalEntity 
				into dbo.D2D_map_order FROM map_order GROUP BY map_order.Portfolio


		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @Current_Procedure + 'D2D Create Source Data from 02_realised_all_details for ' + @Area, GETDATE () END

/*#####################		 Asia Pacific Part for all data		#############################################################*/
		SET @step = 6
		if (@Area = 'AP' and @CorrectionsOnly = '')
		BEGIN


			SET @step = 7
			delete from dbo.[D2D_02_Realised_all_details_last_month] where [D2DSource] = 'AP'


			SET @step = 8
				insert into dbo.[D2D_02_Realised_all_details_last_month] 
							([CoB],[CounterPartyGroup],[DealID],[InternalDesk],[InternalPortfolio],[InternalBusinessUnit],[ExternalPortfolio],[ExternalBusinessUnit]
							,[InstrumentType],[CashflowType],[Commodity],[TradeDate],[EventDate],[Reference],[Ticker],[Action],[CCY],[Realised],[RealisedBase],[VolumeNew],[DeliveryMonth],[OrderNo],[SAPAccount]
							,[UNIT_TO],[LegalEntity],[Partner],[MaterialCode],[CounterPartyCode],[PowerRegion],[Source],[D2DSource]) 
					select	[CoB],[CounterPartyGroup],[DealID],[InternalDesk],[InternalPortfolio],[InternalBusinessUnit],[ExternalPortfolio],[ExternalBusinessUnit]
							,[InstrumentType],[CashflowType],[Commodity],[TradeDate],[EventDate],[Reference],[Ticker],[Action],[CCY],[Realised],[RealisedBase],[VolumeNew],[DeliveryMonth],[OrderNo],[SAPAccount]
							,[UNIT_TO],[LegalEntity],[Partner],[MaterialCode],[CounterPartyCode],[PowerRegion],[Source],[D2DSource] from dbo.[D2D_02_Realised_all_details]


				/*-- Asia Pacific Part delete data from table*/
			SET @step = 9
			delete from dbo.[D2D_02_Realised_all_details]  where [D2DSource] = 'AP'


			/*-- Asia Pacific Part copy in the new data*/
			SET @step = 10
			INSERT INTO dbo.[D2D_02_Realised_all_details] 
				([CounterPartyGroup] ,[DealID] ,[InternalDesk] ,[InternalPortfolio] ,[InternalBusinessUnit] ,[ExternalPortfolio] ,[ExternalBusinessUnit] 
				,[InstrumentType], [CashflowType], [Commodity]	,[TradeDate] ,[EventDate] ,[Reference], [Ticker], [Action], [CCY], [Realised],[RealisedBase]
				,[VolumeNew], [DeliveryMonth], [OrderNo], [SAPAccount], [UNIT_TO], [LegalEntity], [D2DSource])
			SELECT IIf([ctpygroup] = 'InterPE', 'InterPE', 'Intradesk') AS ctpygrp 
				,dbo.[02_realised_all_details].Deal
				,dbo.[02_realised_all_details].IntDesk 
				,dbo.[02_realised_all_details].[InternalPortfolio] 
				,dbo.[02_realised_all_details].[InternalBusinessUnit] 
				,dbo.[02_realised_all_details].[ExternalPortfolio] 
				,dbo.[02_realised_all_details].[ExternalBusinessUnit] 
				,dbo.[02_realised_all_details].[InstrumentType] 
				,dbo.[02_realised_all_details].CashflowType 
				,dbo.[02_realised_all_details].[Commodity] AS Comm 
				,dbo.[02_realised_all_details].[TradeDate] 
				,convert(date,dbo.[02_realised_all_details].[EventDate],103) as EVENTDATE
				,IIf(dbo.[02_realised_all_details].[Reference] IS NULL OR dbo.[02_realised_all_details].[reference] = '', 'leer', dbo.[02_realised_all_details].[Reference]) AS Ref 
				,dbo.[02_realised_all_details].Ticker
				,IIf(dbo.[02_realised_all_details].[commodity] IS NULL, 'leer', dbo.[02_realised_all_details].Action)
				, dbo.[02_realised_all_details].[Currency] AS Ausdr1
				,dbo.[02_realised_all_details].Realised AS Realized ,dbo.[02_realised_all_details].[RealisedBase] AS [Realized (Base)]
				,IIf([InstrumentGroup] = 'phys'	
						AND [volume_new] <> 0 
						AND [Cashflowtype] IN ('Interest', 'n/a', 'Settlement', 'None', 'Commodity'), - [Volume], 0) AS Vol
				,dbo.[02_realised_all_details].DeliveryMonth, dbo.[02_realised_all_details].OrderNo, dbo.[02_realised_all_details].SAP_Account, dbo.[02_realised_all_details].unit, D2D_Auftrag_1.MaxvonLegalEntity, 'AP'
			FROM  dbo.[02_realised_all_details] 
					LEFT JOIN dbo.D2D_map_order ON dbo.[02_realised_all_details].[ExternalPortfolio] = D2D_map_order.Portfolio
					LEFT JOIN D2D_map_order AS D2D_Auftrag_1 ON D2D_map_order.[Portfolio] = D2D_Auftrag_1.Portfolio
			LEFT JOIN map_instrument ON dbo.[02_realised_all_details].InstrumentType = map_instrument.InstrumentType
			WHERE (
					((dbo.[02_realised_all_details].[InternalPortfolio]) NOT LIKE 'CAO_UK%RHP%')
					AND (
						(dbo.[02_realised_all_details].[ExternalPortfolio]) 
							NOT IN ('Not available', 'BF_FOB_VS_CIF', 'CF_BLENDER', 'CF_FREIGHT_ARB', 'CF_SNG_T_REV_KUMIHO', 'CF_UKC_T_TIME_SPRD1', 'PHYS_BUNKER_LOSSES', 'PHYS_BUNKER_REDELIVERY', 'PHYS_BUNKER_ROLL', 'CF_OIL_STOCKARB', 'CAO_UK_POWER_POSITION', 'CAO_UK_EE_ZEPH_INDEX')
						AND (dbo.[02_realised_all_details].[ExternalPortfolio]) NOT LIKE 'CAO_UK%RHP%'
						)
					AND ((dbo.[02_realised_all_details].[InstrumentType]) NOT IN ('COAL-STEV', 'COAL-TRANSIT'))
					AND ((D2D_Auftrag_1.MaxvonLegalEntity) = 'RWEST AP')
					AND (
						(
							dbo.[02_realised_all_details].[GROUP]
							) IN ('Intradesk ')
						)
					)
				OR (
					((dbo.[02_realised_all_details].[ExternalBusinessUnit]) IN ('BF_POSBAL BU', 'LNG GATE VAC GMBH EUR BU'))
					AND ((D2D_Auftrag_1.MaxvonLegalEntity) = 'RWEST AP')
					AND (
						(
							dbo.[02_realised_all_details].[GROUP]
							) IN ('Intradesk ')
						)
					)

			SET @step = 10
			update dbo.[D2D_02_Realised_all_details] set [CoB] = @AsOfDate where [D2DSource] = 'AP'
		END
		

		/*Clean up database*/
		SET @step = 11
		DROP TABLE IF EXISTS [dbo].[D2D_map_order]

END TRY

	BEGIN CATCH
		--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
		EXEC [dbo].[usp_GetErrorInfo] @Current_Procedure, @step
	END CATCH

GO

