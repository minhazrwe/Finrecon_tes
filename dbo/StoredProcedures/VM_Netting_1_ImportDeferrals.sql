
/* 
=============================================== =======================================================================================
 Author:			Martin Ulken
 Create date: 28/03/2022, 
 Description: Procedure to import deferrals for the VM Netting Process based on a csv created by a Access application.
---------------------------------------------------------------------------------------------------------------------------------------
Changes/updates (when, who, step, what/why):
2024-04-05, mkb, refurbished step logic, implemented new writelog logic and a proper return code 
=======================================================================================================================================
*/

CREATE PROCEDURE [dbo].[VM_Netting_1_ImportDeferrals]
AS
BEGIN TRY
	DECLARE @LogInfo INTEGER
	DECLARE @Current_Procedure NVARCHAR(50)
	DECLARE @step INTEGER
	DECLARE @PathName NVARCHAR(300)
	DECLARE @filename NVARCHAR(300)
	DECLARE @counter INTEGER
	DECLARE @sql NVARCHAR(max)

	DECLARE @LogEntry nvarchar(300)
	DECLARE @record_counter as int
	DECLARE @Status_Text as varchar(300)	

	DECLARE @LastColName nvarchar(200)
	DECLARE @sqlUpdateLastCol nvarchar(1000); 
	DECLARE @LastCOB as date
	
	SELECT @step = 1
	
	SELECT @Current_Procedure = Object_Name(@@PROCID)
	EXEC dbo.Write_Log 'Info', 'START', @Current_Procedure, NULL, NULL, @step, 1

	SET @LastCOB = EOMONTH(DATEADD(month, -1, GETDATE()))

	SELECT @LogInfo = 1
	
	SELECT @step = 5 
	SET @LogEntry = 'AutoBackup table_VM_NETTING_1a_DeferralInput START'
	EXEC dbo.Write_Log 'Info', @LogEntry, @Current_Procedure, NULL, NULL, @step, 1
	EXEC [dbo].[AutoBackup] '[dbo].[table_VM_NETTING_1a_DeferralInput]'	
	
	SET @LogEntry = 'AutoBackup table_VM_NETTING_1a_DeferralInput DONE'
	EXEC dbo.Write_Log 'Info', @LogEntry, @Current_Procedure, NULL, NULL, @step, 1
	
	SELECT @step = 10 
	SET @LogEntry = 'Identify files to import'
	EXEC dbo.Write_Log 'Info', @LogEntry, @Current_Procedure, NULL, NULL, @step, 1

	SELECT @PathName = dbo.udf_get_path('VMNetting_ImportDeferrals')
	SELECT @counter = count(1) FROM [dbo].[FilestoImport] WHERE [dbo].[FilestoImport].[Source] IN ('VMNetting_ImportDeferrals')
	
--SET @LogEntry = 'path: '+ @PathName
--EXEC dbo.Write_Log 'TESTENTRY',@LogEntry , @Current_Procedure, NULL, NULL, @step, 1
	
	SELECT @step = 20 
	SET @LogEntry = 'Prepare temporary helper table'
	EXEC dbo.Write_Log 'Info', @LogEntry, @Current_Procedure, NULL, NULL, @step, 1
	
	DROP TABLE IF EXISTS [dbo].[table_VM_NETTING_1a_DeferralInput_Temp]
		
	SELECT @step = 25 
	CREATE TABLE [dbo].[table_VM_NETTING_1a_DeferralInput_Temp] (
		[DataSource] [nvarchar](255) NULL,
		[CCY]  [nvarchar](255) NULL,
		[SettlementDate]  [nvarchar](255) NULL,
		[AccountName] [nvarchar](255) NULL,
		[Portfolio]  [nvarchar](255) NULL,
		[DealNumber] [nvarchar](255) NULL,
		[ContractName] [nvarchar](255) NULL,
		[ContractDate]  [nvarchar](255) NULL,
		[ProjectionIndex1] [nvarchar](255) NULL,
		[ProjectionIndex2] [nvarchar](255) NULL,
		[Toolset] [nvarchar](255) NULL,
		[Position]  [nvarchar](255) NULL,
		[TradePrice]  [nvarchar](255) NULL,
		[SettlementPrice]  [nvarchar](255) NULL,
		[RealizedPNL]  [nvarchar](255) NULL,
		[ExternalBU]  [nvarchar](255) NULL,
		[GueltigVon]  [nvarchar](255) NULL,
		[GueltigBis]  [nvarchar](255) NULL,
	) ON [PRIMARY]
		
	SELECT @step = 30 
	SET @LogEntry = 'Now importing ' + cast(@counter as varchar) + ' file(s).'
	EXEC dbo.Write_Log 'Info', @LogEntry, @Current_Procedure, NULL, NULL, @step, 1

	WHILE @counter > 0
	BEGIN
		SELECT @filename = [FileName]
		FROM (
			SELECT * , ROW_NUMBER() OVER (ORDER BY ID) AS ROW
			FROM [dbo].[FilestoImport]
			WHERE [dbo].[FilestoImport].[Source] IN ('VMNetting_ImportDeferrals')
			) AS TMP
		WHERE 
			ROW = @counter

--SET @LogEntry = 'Filename: ' + @PathName
--EXEC dbo.Write_Log 'TESTENTRY', @LogEntry  , @Current_Procedure, NULL, NULL, @step, 1

		SELECT @step = 40 
		SET @LogEntry = 'import #' + cast(@counter as varchar) + ': ' + @pathname + @filename 
		EXEC dbo.Write_Log 'Info', @LogEntry, @Current_Procedure, NULL, NULL, @step, 1

		SELECT @sql = N' SET QUOTED_IDENTIFIER OFF BULK INSERT [dbo].[table_VM_NETTING_1a_DeferralInput_Temp]  FROM ' + '''' + @pathname + @filename + '''' + ' WITH (DATAFILETYPE = ''widechar'', CODEPAGE = 1252, FIELDTERMINATOR =''\t'', FIRSTROW = 2, ROWTERMINATOR =''\n'')'
		EXECUTE sp_executesql @sql

		/*Remove Linebreaks etc. from last column*/
		SELECT @step = 42 
		SET @LogEntry = 'Remove linebreaks etc. from last column'
		EXEC dbo.Write_Log 'Info', @LogEntry, @Current_Procedure, NULL, NULL, @step, 1

		select top 1 @LastColName = Column_Name from INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'table_VM_NETTING_1a_DeferralInput_Temp' order by ORDINAL_POSITION desc
		
		SET @sqlUpdateLastCol = N'UPDATE dbo.table_VM_NETTING_1a_DeferralInput_Temp SET [' + @LastColName + '] = LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE( [' + @LastColName + '], CHAR(10), CHAR(32)),CHAR(13), CHAR(32)),CHAR(160), CHAR(32)),CHAR(9),CHAR(32)))) FROM dbo.table_VM_NETTING_1a_DeferralInput_Temp'
		Exec (@sqlUpdateLastCol)
		
		SELECT @step = 44
		SET @LogEntry = 'Parse Temp table and insert into table_VM_NETTING_1a_DeferralInput'
		EXEC dbo.Write_Log 'Info', @LogEntry, @Current_Procedure, NULL, NULL, @step, 1
		
		INSERT INTO [dbo].[table_VM_NETTING_1a_DeferralInput] 
		(
			 [DataSource]
      ,[CCY]
      ,[SettlementDate]
      ,[AccountName]
      ,[Portfolio]
      ,[DealNumber]
      ,[ContractName]
      ,[ContractDate]
      ,[ProjectionIndex1]
      ,[ProjectionIndex2]
      ,[Toolset]
      ,[Position]
      ,[TradePrice]
      ,[SettlementPrice]
      ,[RealizedPNL]
      ,[ExternalBU]
      ,[GueltigVon]
      ,[GueltigBis]
		)
		SELECT 
			 ltrim(rtrim([DataSource]))
			,ltrim(rtrim([CCY]))
			,dbo.udf_StringToDate([SettlementDate])
			,ltrim(rtrim([AccountName]))
			,ltrim(rtrim([Portfolio]))
      ,[DealNumber]
      ,ltrim(rtrim([ContractName]))
			,dbo.udf_StringToDate([ContractDate])
			,ltrim(rtrim([ProjectionIndex1]))
      ,ltrim(rtrim([ProjectionIndex2]))
      ,ltrim(rtrim([Toolset]))
			,dbo.udf_StringToFloat([Position])
			,dbo.udf_StringToFloat([TradePrice])
			,dbo.udf_StringToFloat([SettlementPrice])
			,dbo.udf_StringToFloat([RealizedPNL])
			,ltrim(rtrim([ExternalBU]))
			,dbo.udf_StringToDate([GueltigVon])
			,dbo.udf_StringToDate([GueltigBis])
			--,Deskname
		FROM 
			[dbo].[table_VM_NETTING_1a_DeferralInput_Temp] 
		WHERE 
			DataSource is not null 
			and 
			DataSource <> ''

		SELECT @step = 46 
		SELECT @counter = @counter - 1
	END
	 
	/*Delete all old Deferrals with GueltigBis smaller than the last day of the last month*/
	SELECT @step = 48
	SET @LogEntry = 'DELETE deferrals invalid since ' + convert(nvarchar, @LastCOB)
	EXEC dbo.Write_Log 'Info', @LogEntry, @Current_Procedure, NULL, NULL, @step, 1

	DELETE from  [dbo].[table_VM_NETTING_1a_DeferralInput] where GueltigBis < @LastCOB 
	
	SELECT @step = 50
	SET @LogEntry = 'Drop temporary helper table again' 
	EXEC dbo.Write_Log 'Info', @LogEntry, @Current_Procedure, NULL, NULL, @step, 1
	--DROP TABLE IF EXISTS [dbo].[table_VM_NETTING_1a_DeferralInput_Temp]
	

	SELECT @step = 60 
	EXEC dbo.Write_Log 'Info', 'FINISHED', @Current_Procedure, NULL, NULL, @step, 1
	/*set a proper return code*/
	Return 0

END TRY

BEGIN CATCH
	/*tell the world procedure failed*/
	EXEC [dbo].[usp_GetErrorInfo] @Current_Procedure, @step, NULL; 
	EXEC dbo.Write_Log 'FAILED', 'FAILED with error, check log for details', @Current_Procedure, NULL, NULL, @step, 1;
	Return @step
END CATCH

GO

