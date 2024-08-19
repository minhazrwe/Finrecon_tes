
/* 
-- =============================================
-- Author:		MBE
-- Create date: 05.10.2021, 
-- Description:	importing data FROM Ledger Exports from SAP
-- =============================================
*/

CREATE PROCEDURE [dbo].[ImportLedgerData]
   @pathName nvarchar(500),
   @CompanyCode nvarchar(500),
   @PeriodeYear nvarchar(500),
   @Variante nvarchar(500)
AS
BEGIN TRY

	DECLARE @LogInfo Integer
	DECLARE @proc nvarchar(40)
	DECLARE @Step Integer
	DECLARE @SQL as nvarchar(max)
	DECLARE @counter Integer
	
	SELECT @proc = Object_Name(@@PROCID)
	
	
  --/* get Info if Logging is enabled */  
	SELECT @Step=1

	SELECT @LogInfo = [dbo].[LogInfo].[LogInfo] FROM [dbo].[LogInfo]
		---IF @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] SELECT 'Import Ledger Data into Temp Table' + ' - START', GETDATE () END
		IF @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] SELECT 'Import Ledger Data for ' + cast(@CompanyCode as varchar) + ' into Temp Table - START', GETDATE () END

	--/*drop and recreate temp table*/
	SELECT @Step=2

		IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'table_LedgerData_temp'))
		BEGIN DROP TABLE [dbo].[table_LedgerData_temp] END

	SELECT @Step=3
	CREATE TABLE [dbo].[table_LedgerData_temp](
		[Kons] [nvarchar](100) NULL,
		[RACEPosition] [nvarchar](100) NULL,
		[RACEPositionType] [nvarchar](100) NULL,
		[RACE-UP] [nvarchar](100) NULL,
		[Product] [nvarchar](100) NULL,
		[Restlaufzeit] [nvarchar](100) NULL,
		[Kundengruppe] [nvarchar](100) NULL,
		[Segment] [nvarchar](100) NULL,
		[Sachkonto] [nvarchar](100) NULL,
		[Kontentext] [nvarchar](100) NULL,
		[Kontenart] [nvarchar](100) NULL,
		[ProfitCenter] [nvarchar](100) NULL,
		[BWAFI] [nvarchar](100) NULL,
		[BWAFIAA] [nvarchar](100) NULL,
		[BWATR] [nvarchar](100) NULL,
		[Vertragstyp] [nvarchar](100) NULL,
		[Basisdatum] [nvarchar](100) NULL,
		[Zahlungsbedingungen] [nvarchar](100) NULL,
		[Debitor] [nvarchar](100) NULL,
		[Kreditor] [nvarchar](100) NULL,
		[Partner] [nvarchar](100) NULL,
		[PGDK] [nvarchar](100) NULL,
		[Status] [nvarchar](100) NULL,
		[Gesellschaftsform] [nvarchar](100) NULL,
		[Land] [nvarchar](100) NULL,
		[Meldeeinheit] [nvarchar](100) NULL,
		[WertInHW] [nvarchar](100) NULL,
		[Menge] [nvarchar](100) NULL,
		[ME] [nvarchar](100) NULL,
	) ON [PRIMARY]
			
    SELECT @Step = 4
		--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] SELECT 'Clearer - Import Trades Data ' + @ClearerToImport + ' - import from ' + @pathname + @FileName, GETDATE () END
		  SELECT @sql = N'BULK INSERT [dbo].[table_LedgerData_temp] FROM '  + '''' +@pathName + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR ='','', FIRSTROW = 2, ROWTERMINATOR =''\n'')';
			execute sp_executesql @sql

		SELECT @Step = 5
		delete from [dbo].[SAP_LedgerData] where [Periode] = @PeriodeYear and  [Variante] = @Variante and [Company] = '''' + @CompanyCode

		SELECT @Step = 6
		Insert into [dbo].[SAP_LedgerData] 
				([Kons],[RACEPosition],[RACEPositionType],[RACE-UP],[Product],[Restlaufzeit],[Kundengruppe],[Segment],[Sachkonto],
				[Kontentext],[Kontenart],[ProfitCenter],[BWAFI],[BWAFIAA],[BWATR],[Vertragstyp],[Basisdatum],[Zahlungsbedingungen],
				[Debitor],[Kreditor],[Partner],[PGDK],[Status],[Gesellschaftsform],[Land],[Meldeeinheit],[WertInHW],[Menge],[ME])
		select	[Kons],[RACEPosition],[RACEPositionType],[RACE-UP],[Product],[Restlaufzeit],[Kundengruppe],[Segment],[Sachkonto],
				[Kontentext],[Kontenart],[ProfitCenter],[BWAFI],[BWAFIAA],[BWATR],[Vertragstyp],[Basisdatum],[Zahlungsbedingungen],
				[Debitor],[Kreditor],[Partner],[PGDK],[Status],[Gesellschaftsform],[Land],[Meldeeinheit],[WertInHW],[Menge],[ME]
				from [dbo].[table_LedgerData_temp]

		SELECT @Step = 7
		update [dbo].[SAP_LedgerData] set [Periode] = @PeriodeYear where [Periode] is NULL
		update [dbo].[SAP_LedgerData] set [Variante] = @Variante where [Variante] is NULL
		update [dbo].[SAP_LedgerData] set [Company] = '''' + @CompanyCode where [Company] is NULL
			
		update [FinRecon].[dbo].[SAP_LedgerData] set [Variante] = '' where [Variante] is NULL
		update [FinRecon].[dbo].[SAP_LedgerData] set [Periode] = '' where [Periode] is NULL
		update [FinRecon].[dbo].[SAP_LedgerData] set [Company] = '' where [Company] is NULL
		update [FinRecon].[dbo].[SAP_LedgerData] set [Kons] = '' where [Kons] is NULL
		update [FinRecon].[dbo].[SAP_LedgerData] set [RACEPosition] = '' where [RACEPosition] is NULL
		update [FinRecon].[dbo].[SAP_LedgerData] set [RACEPositionType] = '' where [RACEPositionType] is NULL
		update [FinRecon].[dbo].[SAP_LedgerData] set [RACE-UP] = '' where [RACE-UP] is NULL
		update [FinRecon].[dbo].[SAP_LedgerData] set [Product] = '' where [Product] is NULL
		update [FinRecon].[dbo].[SAP_LedgerData] set [Restlaufzeit] = '' where [Restlaufzeit] is NULL
		update [FinRecon].[dbo].[SAP_LedgerData] set [Kundengruppe] = '' where [Kundengruppe] is NULL
		update [FinRecon].[dbo].[SAP_LedgerData] set [Segment] = '' where [Segment] is NULL
		update [FinRecon].[dbo].[SAP_LedgerData] set [Sachkonto] = '' where [Sachkonto] is NULL
		update [FinRecon].[dbo].[SAP_LedgerData] set [Kontentext] = '' where [Kontentext] is NULL
		update [FinRecon].[dbo].[SAP_LedgerData] set [Kontenart] = '' where [Kontenart] is NULL
		update [FinRecon].[dbo].[SAP_LedgerData] set [ProfitCenter] = '' where [ProfitCenter] is NULL
		update [FinRecon].[dbo].[SAP_LedgerData] set [BWAFI] = '' where [BWAFI] is NULL
		update [FinRecon].[dbo].[SAP_LedgerData] set [BWAFIAA] = '' where [BWAFIAA] is NULL
		update [FinRecon].[dbo].[SAP_LedgerData] set [BWATR] = '' where [BWATR] is NULL
		update [FinRecon].[dbo].[SAP_LedgerData] set [Vertragstyp] = '' where [Vertragstyp] is NULL
		update [FinRecon].[dbo].[SAP_LedgerData] set [Basisdatum] = '' where [Basisdatum] is NULL
		update [FinRecon].[dbo].[SAP_LedgerData] set [Zahlungsbedingungen] = '' where [Zahlungsbedingungen] is NULL
		update [FinRecon].[dbo].[SAP_LedgerData] set [Debitor] = '' where [Debitor] is NULL
		update [FinRecon].[dbo].[SAP_LedgerData] set [Kreditor] = '' where [Kreditor] is NULL
		update [FinRecon].[dbo].[SAP_LedgerData] set [Partner] = '' where [Partner] is NULL
		update [FinRecon].[dbo].[SAP_LedgerData] set [PGDK] = '' where [PGDK] is NULL
		update [FinRecon].[dbo].[SAP_LedgerData] set [Status] = '' where [Status] is NULL
		update [FinRecon].[dbo].[SAP_LedgerData] set [Gesellschaftsform] = '' where [Gesellschaftsform] is NULL
		update [FinRecon].[dbo].[SAP_LedgerData] set [Land] = '' where [Land] is NULL
		update [FinRecon].[dbo].[SAP_LedgerData] set [Meldeeinheit] = '' where [Meldeeinheit] is NULL
		update [FinRecon].[dbo].[SAP_LedgerData] set [WertInHW] = '' where [WertInHW] is NULL
		update [FinRecon].[dbo].[SAP_LedgerData] set [Menge] = '' where [Menge] is NULL
		update [FinRecon].[dbo].[SAP_LedgerData] set [ME] = '' where [ME] is NULL

		SELECT @Step = 8
		IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'table_LedgerData_temp'))
			BEGIN DROP TABLE [dbo].[table_LedgerData_temp] END

		SELECT @Step = 9
		---if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] SELECT 'Import Ledger Data into Temp Table ' +  ' - FINISHED', GETDATE () END
		IF @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] SELECT 'Import Ledger Data for ' + cast(@CompanyCode as varchar) + ' into Temp Table - FINISHED', GETDATE () END
END TRY
	
BEGIN CATCH
	EXEC [dbo].[usp_GetErrorInfo] @proc, @Step
	---BEGIN INSERT INTO [dbo].[Logfile] SELECT 'Clearer - Import Trades Data ' + ' - FAILED', GETDATE () END
		BEGIN insert into [dbo].[Logfile] SELECT 'Import Ledger Data for ' + cast(@CompanyCode as varchar) + ' - FAILED', GETDATE () END
END CATCH

GO

