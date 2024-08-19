
/*=================================================================================================================
	Author:		MK
	Created:	2024-04-30
	Purpose:	Import of Late PnL for CAO (on request by Yasemine Koser)
-----------------------------------------------------------------------------------------------------------------
	Changes:
	YYYY-MM-DD, AUTHOR, What has been done
=================================================================================================================*/

CREATE PROCEDURE [dbo].[Import_LATE_PNL_CAO] 
AS

DECLARE @Path AS Varchar(MAX)
DECLARE @sql nvarchar (max)

SET @Path = CONCAT('//energy.local/rwest/RWE-Trading/TC/MFA/02_Commodity Accounting/01_Realised/CAO/CAO CE/',(SELECT CAST(FORMAT([AsOfDate_EOM], 'yyyy') AS VARCHAR) FROM [FinRecon].[dbo].[AsOfDate]),'/',(SELECT CAST(FORMAT([AsOfDate_EOM], 'yyyy_MM') AS VARCHAR) FROM [FinRecon].[dbo].[AsOfDate]),'/Accruals/Late_Deals/LATE_PNL_raw.csv')

TRUNCATE TABLE [dbo].[table_LATE_PNL_CAO_raw]

SET @sql = N'BULK INSERT [dbo].[table_LATE_PNL_CAO_raw] FROM ' + '''' + @Path + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR ='','', FIRSTROW = 2, ROWTERMINATOR =''\n'')'

EXECUTE sp_executesql @sql

GO

