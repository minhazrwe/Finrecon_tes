




/* 
==========================================================================================================================
Author:Dennis Schley
Create date: 23/11/2021, 
Description:   
--------------------------------------------------------------------------------------------------------------------------
Changes (when, who, step, what, why
23/11/2021: Procedure Created
2024-04-10, mkb, step 40, replaced sql-statement for nasdaq import, as underlying table has changed unanounced
==========================================================================================================================
*/
CREATE PROCEDURE [dbo].[VM_Netting_2_ImportBocarData]
AS
BEGIN TRY
	DECLARE @LogInfo INTEGER
	DECLARE @proc NVARCHAR(40)
	DECLARE @step INTEGER
	DECLARE @PathName NVARCHAR(300)
	DECLARE @filename NVARCHAR(100)
	DECLARE @counter INTEGER
	DECLARE @sql NVARCHAR(max)
	DECLARE @COB date

	SELECT @step = 1

	SELECT @proc = '[dbo].[VM_Netting_2_ImportBocarData]'

	SELECT @step = @step + 1 --2

	SELECT @LogInfo = [dbo].[LogInfo].[LogInfo]	FROM [dbo].[LogInfo]

	IF @LogInfo >= 1
	BEGIN INSERT INTO [dbo].[Logfile] SELECT 'VM_Netting_DE - START' ,GETDATE() END

	
	SELECT @step = @step + 1 --3
	IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT 'VM_Netting_DE - empty table [VM_NETTING_Deals]' ,GETDATE()END
	
	-- delete VM Netting Deals --
	TRUNCATE TABLE [dbo].[VM_NETTING_Deals]

	
	SELECT @step = @step + 1 --4
	IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT 'VM_Netting_DE - empty table [VM_NETTING_Deallevel]' ,GETDATE() END

	-- delete VM Deallevel --
	TRUNCATE TABLE [dbo].[VM_NETTING_Deallevel]


	SELECT @step = @step + 1 --7
	-- get the import path for the Bocar files
	SELECT @PathName = dbo.udf_get_path('NScale')
	
	-- get number of Bocar files
	SELECT @counter = count(1) FROM [dbo].[FilestoImport] WHERE [dbo].[FilestoImport].[Source] IN ('NScale')

	-- drop temp table if exists
	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'VM_Netting_DE_Deals_Temp'))
	BEGIN
		DROP TABLE [dbo].[VM_Netting_DE_Deals_Temp]
	END

	IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT 'VM_Netting_DE - re-create table [VM_Netting_DE_Deals_Temp]',GETDATE() END
	-- create the temp table
	CREATE TABLE [dbo].[VM_NETTING_DE_Deals_Temp] (
		[BusinessDate] [varchar](50) NULL
		,[DealNumber] [varchar](50) NULL
		,[TradeDate] [varchar](50) NULL
		,[TradePrice] [varchar](50) NULL
		,[OLFPosition] [varchar](50) NULL
		,[OLFPnl] [varchar](50) NULL
		,[OLFVM] [varchar](50) NULL
		,[Product] [varchar](50) NULL
		,[ExchangeCode] [varchar](50) NULL
		,[OLFAccount] [varchar](50) NULL
		,[ContractDate] [varchar](50) NULL
		,[CallPut] [varchar](50) NULL
		,[StrikePrice] [varchar](50) NULL
		,[StmClosingPrice] [varchar](50) NULL
		,[StmPreviousClosingPrice] [varchar](50) NULL
		,[StmTotalPosition] [varchar](50) NULL
		,[StmTotalVM] [varchar](50) NULL
		,[StmTotalPnl] [varchar](50) NULL
		,[Toolset] [varchar](50) NULL
		,[ProjectionIndex1] [varchar](50) NULL
		,[ProjectionIndex2] [varchar](50) NULL
		,[ExternalBU] [varchar](50) NULL
		,[Portfolio] [varchar](50) NULL
		,[Trader] [varchar](50) NULL
		,[Currency] [varchar](50) NULL
		) ON [PRIMARY]

	
	SELECT @step = @step + 1 --8
	IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT 'VM_Netting_2_ImportBocarData - import deal files start.' ,GETDATE() END

	--einlesen aller einzelnen deal dateien:
	WHILE @counter > 0
	BEGIN
		-- get the filename
		SELECT @filename = [FileName]
		FROM (
			SELECT *
				,ROW_NUMBER() OVER (
					ORDER BY ID
					) AS ROW
			FROM [dbo].[FilestoImport]
			WHERE [dbo].[FilestoImport].[Source] IN ('NScale')
			) AS TMP
		WHERE ROW = @counter

		
		SELECT @step = @step + 1 --9+x
		IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT 'VM_Netting_2_ImportBocarData - import deals from ' + @pathname + @filename ,GETDATE() END

		
		-- Bukk insert the file
		SELECT @sql = N' SET QUOTED_IDENTIFIER OFF BULK INSERT [dbo].[VM_Netting_DE_Deals_Temp]  FROM ' + '''' + @pathname + @filename + '''' + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR =''~'', FIRSTROW = 2, ROWTERMINATOR =''\n'')';
		EXECUTE sp_executesql @sql

		IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] 	SELECT 'VM_Netting_2_ImportBocarData - copy import deals to target' ,GETDATE() END
		
		-- Copy the deals to target
		INSERT INTO [dbo].[VM_NETTING_Deals] (
			BusinessDate
			,DealNumber
			,TradeDate
			,TradePrice
			,OLFPosition
			,OLFPnl
			,OLFVM
			,Product
			,ExchangeCode
			,OLFAccount
			,ContractDate
			,CallPut
			,StrikePrice
			,StmClosingPrice
			,StmPreviousClosingPrice
			,StmTotalPosition
			,StmTotalVM
			,StmTotalPnl
			,Toolset
			,ProjectionIndex1
			,ProjectionIndex2
			,ExternalBU
			,Portfolio
			,Trader
			,[Currency]
			,[Dealtype]
			)
		SELECT SUBSTRING([dbo].[VM_Netting_DE_Deals_Temp].BusinessDate, 2, len([dbo].[VM_Netting_DE_Deals_Temp].BusinessDate) - 2)
			,SUBSTRING([dbo].[VM_Netting_DE_Deals_Temp].DealNumber, 2, len([dbo].[VM_Netting_DE_Deals_Temp].DealNumber) - 2)
			,SUBSTRING([dbo].[VM_Netting_DE_Deals_Temp].TradeDate, 2, len([dbo].[VM_Netting_DE_Deals_Temp].TradeDate) - 2)
			,SUBSTRING([dbo].[VM_Netting_DE_Deals_Temp].TradePrice, 2, len([dbo].[VM_Netting_DE_Deals_Temp].TradePrice) - 2)
			,SUBSTRING([dbo].[VM_Netting_DE_Deals_Temp].OLFPosition, 2, len([dbo].[VM_Netting_DE_Deals_Temp].OLFPosition) - 2)
			,SUBSTRING([dbo].[VM_Netting_DE_Deals_Temp].OLFPnl, 2, len([dbo].[VM_Netting_DE_Deals_Temp].OLFPnl) - 2)
			,SUBSTRING([dbo].[VM_Netting_DE_Deals_Temp].OLFVM, 2, len([dbo].[VM_Netting_DE_Deals_Temp].OLFVM) - 2)
			,SUBSTRING([dbo].[VM_Netting_DE_Deals_Temp].Product, 2, len([dbo].[VM_Netting_DE_Deals_Temp].Product) - 2)
			,SUBSTRING([dbo].[VM_Netting_DE_Deals_Temp].ExchangeCode, 2, len([dbo].[VM_Netting_DE_Deals_Temp].ExchangeCode) - 2)
			,SUBSTRING([dbo].[VM_Netting_DE_Deals_Temp].OLFAccount, 2, len([dbo].[VM_Netting_DE_Deals_Temp].OLFAccount) - 2)
			,CONVERT(DATETIME, SUBSTRING([dbo].[VM_Netting_DE_Deals_Temp].ContractDate, 2, len([dbo].[VM_Netting_DE_Deals_Temp].ContractDate) - 2), 103)
			,SUBSTRING([dbo].[VM_Netting_DE_Deals_Temp].CallPut, 2, len([dbo].[VM_Netting_DE_Deals_Temp].CallPut) - 2)
			,SUBSTRING([dbo].[VM_Netting_DE_Deals_Temp].StrikePrice, 2, len([dbo].[VM_Netting_DE_Deals_Temp].StrikePrice) - 2)
			,SUBSTRING([dbo].[VM_Netting_DE_Deals_Temp].StmClosingPrice, 2, len([dbo].[VM_Netting_DE_Deals_Temp].StmClosingPrice) - 2)
			,SUBSTRING([dbo].[VM_Netting_DE_Deals_Temp].StmPreviousClosingPrice, 2, len([dbo].[VM_Netting_DE_Deals_Temp].StmPreviousClosingPrice) - 2)
			,SUBSTRING([dbo].[VM_Netting_DE_Deals_Temp].StmTotalPosition, 2, len([dbo].[VM_Netting_DE_Deals_Temp].StmTotalPosition) - 2)
			,SUBSTRING([dbo].[VM_Netting_DE_Deals_Temp].StmTotalVM, 2, len([dbo].[VM_Netting_DE_Deals_Temp].StmTotalVM) - 2)
			,SUBSTRING([dbo].[VM_Netting_DE_Deals_Temp].StmTotalPnl, 2, len([dbo].[VM_Netting_DE_Deals_Temp].StmTotalPnl) - 2)
			,SUBSTRING([dbo].[VM_Netting_DE_Deals_Temp].Toolset, 2, len([dbo].[VM_Netting_DE_Deals_Temp].Toolset) - 2)
			,SUBSTRING([dbo].[VM_Netting_DE_Deals_Temp].ProjectionIndex1, 2, len([dbo].[VM_Netting_DE_Deals_Temp].ProjectionIndex1) - 2)
			,SUBSTRING([dbo].[VM_Netting_DE_Deals_Temp].ProjectionIndex2, 2, len([dbo].[VM_Netting_DE_Deals_Temp].ProjectionIndex2) - 2)
			,SUBSTRING([dbo].[VM_Netting_DE_Deals_Temp].ExternalBU, 2, len([dbo].[VM_Netting_DE_Deals_Temp].ExternalBU) - 2)
			,SUBSTRING([dbo].[VM_Netting_DE_Deals_Temp].Portfolio, 2, len([dbo].[VM_Netting_DE_Deals_Temp].Portfolio) - 2)
			,SUBSTRING([dbo].[VM_Netting_DE_Deals_Temp].Trader, 2, len([dbo].[VM_Netting_DE_Deals_Temp].Trader) - 2)
			,SUBSTRING([dbo].[VM_Netting_DE_Deals_Temp].[Currency], 2, len([dbo].[VM_Netting_DE_Deals_Temp].[Currency]) - 2)
			,left(@filename, len(@filename) - 4)
		FROM [dbo].[VM_Netting_DE_Deals_Temp]

		TRUNCATE TABLE [dbo].[VM_Netting_DE_Deals_Temp]

		SELECT @counter = @counter - 1
	END

	SELECT @step = 30
	-- change null to empty for callput and StrikePrice
	UPDATE [dbo].[VM_NETTING_Deals]
	SET [dbo].[VM_NETTING_Deals].callput = NULL
	WHERE [dbo].[VM_NETTING_Deals].callput = ''
	
	SELECT @step = 31
	UPDATE [dbo].[VM_NETTING_Deals]
	SET [dbo].[VM_NETTING_Deals].StrikePrice = NULL
	WHERE [dbo].[VM_NETTING_Deals].StrikePrice = ''

	SELECT @step = 40
	IF @LogInfo >= 1 BEGIN 	INSERT INTO [dbo].[Logfile]		SELECT 'VM_Netting_2_ImportBocarData - import deal files done.' ,GETDATE() END
	IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT 'VM_Netting_2_ImportBocarData - insert into [VM_NETTING_Deallevel]' ,GETDATE() END

	-- Get data from [VM_NETTING_Deals] and insert different dealtypes into VM_NETTING_Deallevel
	INSERT INTO [dbo].[VM_NETTING_Deallevel] (
		[source]
		,DealNumber
		,olfpnl
		,Product
		,ExchangeCode
		,[Currency]
		,Portfolio
		,ExternalBU
		,ContractDate
		,[Dealtype] 
		)
	SELECT t.olfaccount
		,t.DealNumber
		,Sum([dbo].[udf_NZ_FLOAT](OLFPnl) + 0) AS vm
		,Max(t.Product) AS MaxvonProduct
		,t.ExchangeCode
		,t.Currency
		,t.Portfolio
		,t.ExternalBU
		,Max(t.ContractDate) AS MaxvonContractDate
		,[Dealtype] 
	FROM (
		SELECT OLFAccount
			,DealNumber
			,olfpnl
			,Product
			,ExchangeCode
			,Currency
			,Portfolio
			,ExternalBU
			,ContractDate
			,[Dealtype] 
		FROM [dbo].[VM_NETTING_Deals]
		WHERE [Dealtype] IN (
				'Deals_ASX'
				,'Deals_ASX_AP'
				)
		
		UNION ALL
		
		SELECT olfaccount
			,DealNumber
			,olfpnl
			,Product
			,ExchangeCode
			,Currency
			,Portfolio
			,ExternalBU
			,ContractDate
			,[Dealtype] 
		FROM [dbo].[VM_NETTING_Deals]
		WHERE [dbo].[VM_NETTING_Deals].[Dealtype] IN (
				'Deals_ECC'
				,'Deals_ECC_AP'
				,'Deals_ECC_JP'
				,'Deals_ICE'
				,'Deals_LME'
				,'Deals_Mizuho'
				,'Deals_Nodal'
				--,'Deals_NOMXC' -- 2022-08-16 The Nasdaq data is taken from BocarX directly.
				,'Deals_SocGen'
				,'Deals_SocGen_AP'
				,'Deals_SocGen_JP'
				,'Deals_ECCEmissions'
				--,'Deals_BNP Paribas_JP' -- Dennis: 07/06/2024 JP from BocarX
				--'Deals_ABNAMRO_ICEEmissions', --- no longer available 
				--'Deals_NFX'                                                                                   --- no longer available
				)
			-- 09.03.2021, DS: For futurestyle options, we also need options as part of VM_Netting_Deallevel. Future-style options are identified via specific produrct type like ("TFO", "EFM", "TFM", ...) in table "Produktnung_Ausnahmen_vom_Produktnetting"
			AND (
				callput IS NULL
				OR [ExchangeCode] IN (
					SELECT Kennzeichnung_in_InsRef
					FROM VM_NETTING_Produktzuordnung_Ausnahmen_vom_Produktnetting
					)
				)
		
		UNION ALL		
		/*Load Data from BocarX for Nasdaq*/

		/* deactivated 2024-04-10 and replaced by sql below (mkb)
		------SELECT
		------OLFAccount as olfaccount
		------,cast(DealNumber as nvarchar(20)) as DealNumber
		------,cast(cast(round(OLFPnl,2) as numeric(36,2)) as nvarchar(40)) as  olfpnl
		------,Product
		------,ExchangeCode
		------,Currency
		------,Portfolio
		------,ExternalBU
		------,format(ContractDate,'MMM dd yyyy hh:mmtt') as ContractDate
		------,'Deals_NOMXC' as Dealtype
		------FROM
		------	BOCAR_1P.BOCAR1P.bocarx.nasdaq_open_trades_view
		------WHERE 
		------	 --BusinessDate = '2022-07-29'
		------	 BusinessDate = (SELECT format(AsOfDate_EOM,'yyyy-MM-dd') FROM [dbo].AsOfDate)
		------	 and ( isnull(CallPut,'')='' 
		------			OR [ExchangeCode] IN (
		------			SELECT Kennzeichnung_in_InsRef
		------			FROM VM_NETTING_Produktzuordnung_Ausnahmen_vom_Produktnetting
		------			)
		------		)
		*/

		

		SELECT
			olf_account as olfaccount
			,cast(Deal_Number as nvarchar(20)) as DealNumber
			,cast(cast(round(OLF_Pnl,2) as numeric(36,2)) as nvarchar(40)) as  olfpnl
			,Product
			,Exchange_Code as ExchangeCode
			,ccy as [Currency]
			,Portfolio
			,External_BU as ExternalBU
			,format(Contract_Date,'MMM dd yyyy hh:mmtt') as ContractDate
			,'Deals_BocarX' as Dealtype --former:,'Deals_NOMXC' as Dealtype -- Dennis 07/06/2024, JP also from BocarX
		FROM
			BOCAR_1P.BOCAR1P.bocarx.accounting_open_positions_view
		WHERE 
				Business_Date = (SELECT format(AsOfDate_EOM,'yyyy-MM-dd') FROM dbo.AsOfDate)
				and 
				(
				isnull(Call_Put,'') = '' 
				OR 
				[Exchange_Code] IN 
					(
						SELECT distinct Kennzeichnung_in_InsRef
						FROM dbo.VM_NETTING_Produktzuordnung_Ausnahmen_vom_Produktnetting
					)
				)

			 
		UNION ALL
		
		SELECT olfaccount
			,DealNumber
			,olfpnl
			,Product
			,ExchangeCode
			,Currency
			,Portfolio
			,ExternalBU
			,CONVERT(DATETIME, [ContractDate], 103) AS ContractDate
			,[Dealtype] 
		FROM [dbo].[VM_NETTING_Deals]
		WHERE [Dealtype] IN (
				'Deals_BNP Paribas'
				,'Deals_BNP Paribas_AP'
				,'Deals_BNP Paribas ICEEndex'
				)
			/*2023-01-11 Requested by Anna Buschert to take out the filter*/
			/*AND (
				(CONVERT(DATETIME, [ContractDate], 103)) > (
					SELECT AsOfDate_EOM
					FROM [dbo].AsOfDate
					)
				)*/

/*		union all
-- Ergänze alle fehlenden Börsen als noch einzusortieren (in eine der Gruppen nach Format oben)
		SELECT OLFAccount
			,DealNumber
			,olfpnl
			,Product
			,ExchangeCode
			,Currency
			,Portfolio
			,ExternalBU
			,ContractDate
		FROM [dbo].[VM_NETTING_Deals]
		WHERE [Dealtype] not IN (
				'Deals_ASX'
				,'Deals_ASX_AP'
				,'Deals_BNP Paribas'
				,'Deals_BNP Paribas_AP'
				,'Deals_ECC'
				,'Deals_ECC_AP'
				,'Deals_ECC_JP'
				,'Deals_ICE'
				,'Deals_LME'
				,'Deals_Mizuho'
				,'Deals_Nodal'
				,'Deals_NOMXC'
				,'Deals_SocGen'
				,'Deals_SocGen_AP'
				,'Deals_SocGen_JP'
				,'Deals_ECCEmissions'
				)*/
		) AS t
	GROUP BY t.olfaccount
		,t.DealNumber
		,t.ExchangeCode
		,t.Currency
		,t.Portfolio
		,t.ExternalBU
		,[Dealtype] 
	
	IF @LogInfo >= 1 BEGIN 	INSERT INTO [dbo].[Logfile]		SELECT 'VM_Netting_2_ImportBocarData - Adjust JPY by factor 1.000' ,GETDATE() END
	
	Update [FinRecon].[dbo].[VM_NETTING_Deallevel]
	SET [dbo].[VM_NETTING_Deallevel].OLFPnl = OLFPnl*1000
	where [Currency] = 'JPY'

	IF @LogInfo >= 1 BEGIN 	INSERT INTO [dbo].[Logfile]		SELECT 'VM_Netting_2_ImportBocarData - DONE' ,GETDATE() END
		

END TRY




BEGIN CATCH
	EXEC [dbo].[usp_GetErrorInfo] @proc
		,@step
END CATCH

GO

