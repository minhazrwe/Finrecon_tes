




/* 
 =============================================
 Author:      	MK
 Created:     	2023-01
 Description:	Create report for Destatis (Documentation can be found here: https://confluence.rwe.com:8443/display/MFA/Destatis+Report)
 ---------------------------------------------
 updates:
 

 ==============================================
*/

CREATE PROCEDURE [dbo].[Create_Destatis_Report] 
AS
BEGIN TRY

	DECLARE @step Integer		
	DECLARE @proc nvarchar(50)
	DECLARE @LogInfo Integer
		
	SELECT @proc = Object_Name(@@PROCID)
	
	-- SET @FileSource = 'ROCK_Realised'

  /* get Info if Logging is enabled */
	SELECT @LogInfo = [dbo].[LogInfo].[LogInfo] FROM [dbo].[LogInfo]

	IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - START', GETDATE () END

	-- Create temp table
	IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - Creating temp_destatis_report table', GETDATE () END
	SELECT @step=1		
	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'temp_destatis_report'))
	BEGIN DROP TABLE [dbo].[temp_destatis_report] END

	SELECT @step=2
	CREATE TABLE [dbo].[temp_destatis_report]
	(
		[VertragsNummer] [nchar](100) NULL,
		[AccountName] [varchar](255) NULL,
		[Account] [varchar](50) NULL,
		[DocumentNumber] [varchar](50) NULL,
		[DocumentType] [varchar](50) NULL,
		[Order] [varchar](50) NULL,
		[Text] [varchar](50) NULL,
		[Assignment] [varchar](50) NULL,
		[PostingDate] [date] NULL,
		[DocumentDate] [date] NULL,
		[EntryDate] [date] NULL,
		[Amountinlocalcurrency] [float] NULL,
		[Quantity] [float] NULL,
		[BaseUnitofMeasure] [varchar](50) NULL,
		[customer_name] [varchar](50) NULL,
		[commodity] [varchar](5) NULL
	)
	
	-- Fill Table with sap info and customer name via mapping	
	IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - Filling temp_destatis_report table with SAP data and matching customer name', GETDATE () END
	SELECT @step=3		
	INSERT INTO [dbo].[temp_destatis_report] 
	(
		[VertragsNummer],
		[AccountName],
		[Account],
		[DocumentNumber],
		[DocumentType],
		[Order],
		[Text],
		[Assignment],
		[PostingDate],
		[DocumentDate],
		[EntryDate],
		[Amountinlocalcurrency],
		[Quantity],
		[BaseUnitofMeasure],
		[customer_name],
		[commodity]
	)
	SELECT
		[SAP].[VertragsNummer],
		[SAP].[AccountName],
		[SAP].[Account],
		[SAP].[DocumentNumber],
		[SAP].[DocumentType],
		[SAP].[Order],
		[SAP].[Text],
		[SAP].[Assignment],
		[SAP].[PostingDate],
		[SAP].[DocumentDate],
		[SAP].[EntryDate],
		[SAP].[Amountinlocalcurrency],
		[SAP].[Quantity] * -1,
		[SAP].[BaseUnitofMeasure],
		[MAP].[customer_name],
		CASE
			WHEN [Account] in ('4008000') THEN 'Strom'
			WHEN [Account] in ('4010001','4010002') THEN 'Gas'
			ELSE 'Other'
		END AS [commodity]
	FROM 
	(
		select dd.* from (
		select case when left(dd.[TEXT],3) = 'VG_' 
		or left(dd.[TEXT],3) = 'VS_'or left(dd.[TEXT],3) = 'VF_' 
		or left(dd.[TEXT],3) = 'VL_' or left(dd.[TEXT],3) = 'VC_' 
		then finrecon.dbo.udf_splitdata(dd.[TEXT],1) else finrecon.dbo.udf_splitdata(dd.[TEXT],3) end as 'VertragsNummer' ,
		gg.AccountName , dd.Account, dd.DocumentNumber, dd.DocumentType, dd.[Order], dd.[Text], dd.Assignment,dd.PostingDate,dd.DocumentDate, dd.EntryDate,dd.Amountinlocalcurrency,dd.Quantity, dd.BaseUnitofMeasure
		from finrecon.dbo.[zzz_DestatisSAPJOIN] dd inner join finrecon.dbo.map_ReconGroupAccount  gg on dd.Account = gg.Account where 
		[Order] in  ('HS1000','HG1000') and dd.[Account] not like 'I%' and dd.[account] not like 'H%' and dd.[DocumentType] not in ('ZM','ZA')
		and 
		dd.Account in ('4008000', '4096031', '4000722', '4000723', '7760090', '4000764', '4003012', '4003570', '4003014', '4100028', '6016725', '6016750', 
		'4010001', '4010002', '4010008', '4010016', '4010017', '4089902', '4006147', '7780000', '6030001', '4006066', '4003025')
		and Left(dd.Assignment, 4) in ('2023','2024')) as dd where VertragsNummer <> 'EUR' --MBE 24.01.2024
	) AS SAP
	LEFT JOIN [map_customer_destatis] AS MAP ON
	[SAP].[Text] LIKE '%' +  [MAP].[possible_sap_txt_str] + '%'
	GROUP BY [SAP].[VertragsNummer], [SAP].[AccountName], [SAP].[Account], [SAP].[DocumentNumber], [SAP].[DocumentType], [SAP].[Order], [SAP].[Text], [SAP].[Assignment], [SAP].[PostingDate], [SAP].[DocumentDate], [SAP].[EntryDate], [SAP].[Amountinlocalcurrency], [SAP].[Quantity], [SAP].[BaseUnitofMeasure], [MAP].[customer_name]

	-- Create and fill Table with unmatched entries
	IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - Create temp_destatis_report_unmatched_entries table', GETDATE () END
	SELECT @step=4		
	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'temp_destatis_report_unmatched_entries'))
	BEGIN DROP TABLE [dbo].[temp_destatis_report_unmatched_entries] END

	SELECT @step=5
	CREATE TABLE [dbo].[temp_destatis_report_unmatched_entries]
	(
		[VertragsNummer] [nchar](100) NULL,
		[AccountName] [varchar](255) NULL,
		[Account] [varchar](50) NULL,
		[DocumentNumber] [varchar](50) NULL,
		[DocumentType] [varchar](50) NULL,
		[Order] [varchar](50) NULL,
		[Text] [varchar](50) NULL,
		[Assignment] [varchar](50) NULL,
		[PostingDate] [date] NULL,
		[DocumentDate] [date] NULL,
		[EntryDate] [date] NULL,
		[Amountinlocalcurrency] [float] NULL,
		[Quantity] [float] NULL,
		[BaseUnitofMeasure] [varchar](50) NULL,
		[customer_name] [varchar](50) NULL,
		[commodity] [varchar](5) NULL
	)
	
	-- Fill Table with sap info and customer name via mapping
	IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - Filling temp_destatis_report_unmatched_entries with unmatched entries', GETDATE () END
	SELECT @step=6		
	INSERT INTO [dbo].[temp_destatis_report_unmatched_entries] 
	(
		[VertragsNummer],
		[AccountName],
		[Account],
		[DocumentNumber],
		[DocumentType],
		[Order],
		[Text],
		[Assignment],
		[PostingDate],
		[DocumentDate],
		[EntryDate],
		[Amountinlocalcurrency],
		[Quantity],
		[BaseUnitofMeasure],
		[customer_name],
		[commodity]
	)
	SELECT [VertragsNummer]
		  ,[AccountName]
		  ,[Account]
		  ,[DocumentNumber]
		  ,[DocumentType]
		  ,[Order]
		  ,[Text]
		  ,[Assignment]
		  ,[PostingDate]
		  ,[DocumentDate]
		  ,[EntryDate]
		  ,[Amountinlocalcurrency]
		  ,[Quantity]
		  ,[BaseUnitofMeasure]
		  ,[customer_name]
		  ,[commodity]
	  FROM [FinRecon].[dbo].[temp_destatis_report]
	  WHERE customer_name IS NULL
		
	-- Create and fill Table with aggregated quantity based on customer and commodity
	IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - Creating temp_destatis_report_agg table', GETDATE () END
	SELECT @step=7	
	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'temp_destatis_report_agg'))
	BEGIN DROP TABLE [dbo].[temp_destatis_report_agg] END

	SELECT @step=8
	CREATE TABLE [dbo].[temp_destatis_report_agg]
	(
		[customer_name] [varchar](50) NULL,
		[Account] [varchar](50) NULL,
		[commodity] [varchar](5) NULL,
		[SumQuantity] [float] NULL,
		[bin] [varchar](50) NULL,
	)
		
	-- Fill Table with aggregated quantity based on customer and commodity	
	IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - Filling temp_destatis_report_agg with analysed and binned data', GETDATE () END
	SELECT @step=9		
	INSERT INTO [dbo].[temp_destatis_report_agg] 
	(
		[customer_name],
		[Account],
		[commodity],
		[SumQuantity],
		[bin]
	)
	SELECT
		[customer_name],
		[Account],
		[commodity],
		SUM([Quantity]),
		CASE
			WHEN [commodity] = 'Strom' THEN
				CASE
					WHEN SUM([Quantity]) < 20 THEN '1'
					WHEN SUM([Quantity]) <= 500 THEN '2'
					WHEN SUM([Quantity]) <= 2000 THEN '3'
					WHEN SUM([Quantity]) <= 20000 THEN '4'
					WHEN SUM([Quantity]) <= 70000 THEN '5'
					WHEN SUM([Quantity]) <= 150000 THEN '6'
					WHEN SUM([Quantity]) > 150000 THEN '7'
				END
			WHEN [commodity] = 'Gas' THEN
				CASE
					WHEN SUM([Quantity]) < 278 THEN '1'
					WHEN SUM([Quantity]) <= 2778 THEN '2'
					WHEN SUM([Quantity]) <= 27778 THEN '3'
					WHEN SUM([Quantity]) <= 277778 THEN '4'
					WHEN SUM([Quantity]) <= 1111111 THEN '5'
					WHEN SUM([Quantity]) > 1111111 THEN '6'
				END			
			ELSE 'n/a'
		END AS [bin]
	FROM [temp_destatis_report]
	GROUP BY [customer_name], [Account], [commodity]

NoFurtherAction:
		IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - FINISHED', GETDATE () END
	END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step		
		BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - FAILED', GETDATE () END
	END CATCH

GO

