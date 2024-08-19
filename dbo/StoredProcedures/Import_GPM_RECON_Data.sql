





/*
Date:			2022-01-11
Author:		YK/MKB
Purpose:  imports the GPM risk report recon file after being exported from ROCK

*/
	CREATE PROCEDURE [dbo].[Import_GPM_RECON_Data] 

	AS
	BEGIN TRY
		-- define some variables that been needed
		DECLARE @FileName nvarchar (50) 
		DECLARE @PathName nvarchar (300)
		DECLARE @FileID Integer
		DECLARE @LogInfo Integer
		DECLARE @proc nvarchar(40)
		DECLARE @step Integer
		DECLARE @sql nvarchar (max)
		DECLARE @FileSource varchar(100)
		Declare @RecordCount integer

		select @step = 1
		select @proc = Object_Name(@@PROCID)
		select @FileSource = 'GPM_RECON'

		select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - START', GETDATE () END

		/*select where the file is located*/
		select @step = 2		
		select @PathName = [dbo].[udf_get_path] (@FileSource)


		/*select the name of the file*/
		select @step = 3		
		select @FileName = [FileName], @FileID = [ID] from [dbo].[FilesToImport] where [source] = @FileSource

		select @step = 4
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - Importing: '+@PathName+@FileName, GETDATE () END

		/*truncate import tables*/ 
		select @step = 5
		/*import_table*/
		IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'table_GPM_RECON_RISK_REPORT_import'))
		BEGIN DROP TABLE dbo.table_GPM_RECON_RISK_REPORT_import END

		/*create import tables*/ 
		select @step = 6
		CREATE TABLE [dbo].[table_GPM_RECON_RISK_REPORT_import](
			[CoB] [nvarchar](100) NULL,
			[Intermediate_1_Name] [nvarchar](100) NULL,
			[Intermediate1_Currency] [nvarchar](100) NULL,
			[Intermediate_2_Name] [nvarchar](100) NULL,
			[Deal_Number] [nvarchar](100) NULL,
			[Delivery_Month] [nvarchar](100) NULL,
			[Portfolio_Name] [nvarchar](100) NULL,
			[Instrument_Type_Name] [nvarchar](100) NULL,
			[Ext_Business_Unit_Name] [nvarchar](100) NULL,
			[Cashflow_Type_Name] [nvarchar](100) NULL,
			[Adjustment_Comment] [nvarchar](500) NULL,
			[PnL_Disc_Total_YtD_PH_BU_CCY] [nvarchar](100) NULL,
			[PnL_Disc_Real_YtD_PH_BU_CCY] [nvarchar](100) NULL,
			[PnL_Disc_Unreal_YtD_PH_BU_CCY] [nvarchar](100) NULL,
			[PnL_Disc_Unreal_LtD_PH_BU_CCY] [nvarchar](100) NULL
		)

		
		/*final data table*/
		select @step = 7
		truncate table dbo.table_GPM_RECON_RISK_REPORT

		/*Starting IMPORT*/
		select @step = 8
		--select @sql = N'BULK INSERT [dbo].table_GPM_RECON_RISK_REPORT_import FROM '  + '''' + @pathname + @filename + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR =''~'', FIRSTROW = 2, ROWTERMINATOR =''0x0a'')';
		select @sql = N'BULK INSERT [dbo].table_GPM_RECON_RISK_REPORT_import FROM '  + '''' + @pathname + @filename + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR =''~'', FIRSTROW = 2, ROWTERMINATOR =''\n'')';
		execute sp_executesql @sql

		select @step = 9
		update [dbo].table_GPM_RECON_RISK_REPORT_import
			set 
				[PnL_Disc_Total_YtD_PH_BU_CCY] = isnull ([PnL_Disc_Total_YtD_PH_BU_CCY],0)
				,[PnL_Disc_Real_YtD_PH_BU_CCY] =isnull ([PnL_Disc_Real_YtD_PH_BU_CCY],0)
				,[PnL_Disc_Unreal_YtD_PH_BU_CCY]=isnull ([PnL_Disc_Unreal_YtD_PH_BU_CCY],0)
				,[PnL_Disc_Unreal_LtD_PH_BU_CCY] =isnull ([PnL_Disc_Unreal_LtD_PH_BU_CCY],0)
				
		select @step=10
		INSERT INTO [dbo].[table_GPM_RECON_RISK_REPORT]
		(
			 [CoB]
			,[Intermediate_1_Name]
			,[Intermediate1_Currency]
			,[Intermediate_2_Name]
			,[Deal_Number]
			,[Delivery_Month]
			,[Portfolio_Name]
			,[Instrument_Type_Name]
			,[Ext_Business_Unit_Name]
			,[Cashflow_Type_Name]
			,[Adjustment_Comment]
			,[PnL_Disc_Total_YtD_PH_BU_CCY]
			,[PnL_Disc_Real_YtD_PH_BU_CCY]
			,[PnL_Disc_Unreal_YtD_PH_BU_CCY]
			,[PnL_Disc_Unreal_LtD_PH_BU_CCY]
	)
    select 
			CONVERT(date, COB ,103) as COB
			,[Intermediate_1_Name]
			,Intermediate1_Currency
			,Intermediate_2_Name
			,Deal_Number
			,CONVERT(date, Delivery_Month ,103) as Delivery_Month
			,Portfolio_Name
			,Instrument_Type_Name
			,Ext_Business_Unit_Name
			,Cashflow_Type_Name
			,Adjustment_Comment
			,cast(cast(PnL_Disc_Total_YtD_PH_BU_CCY as nvarchar(50)) as float)
			,cast(cast(PnL_Disc_Real_YtD_PH_BU_CCY as nvarchar(50)) as float)
			,cast(cast(PnL_Disc_Unreal_YtD_PH_BU_CCY as nvarchar(50)) as float)
			,cast(cast(PnL_Disc_Unreal_LtD_PH_BU_CCY as nvarchar(50)) as float)
	FROM 
			dbo.table_GPM_RECON_RISK_REPORT_import

		/*update last import timestamp*/
		select @step = 11
	  update [dbo].[FilestoImport]
			SET [dbo].[FilestoImport].[LastImport] =GETDATE ()
			WHERE [dbo].[FilestoImport].[ID] = @FileID
	
		select @step = 12
		select @RecordCount = count(*) from table_GPM_RECON_RISK_REPORT
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + 'imported records: ' + cast(format(@RecordCount,'#,#') as nvarchar(50)), GETDATE () END

		select @step = 13
		drop table dbo.table_GPM_RECON_RISK_REPORT_import

		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - FINISHED', GETDATE () END

	END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
		BEGIN insert into [dbo].[Logfile] select @proc + ' - FAILED', GETDATE () END
	END CATCH

GO

