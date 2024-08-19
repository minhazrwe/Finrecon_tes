
/*
	view related to cleaer process
	identifies the clearer related details plus the last import datetime of a clearer
	used within the access application to display the information
*/

CREATE VIEW [dbo].[view_Clearer_AllImportDetails] as
SELECT
	table_Clearer.ClearerID
	,case when dbo.FilestoImport.[source] like '%Trades%' Then SUBSTRING(dbo.FilestoImport.[Source],14,10) ELSE 
		case when dbo.FilestoImport.[source] like '%Premium%' Then SUBSTRING(dbo.FilestoImport.[Source],15,10) ELSE 
			case when dbo.FilestoImport.[source] like '%Settlement%' Then SUBSTRING(dbo.FilestoImport.[Source],18,10) ELSE 'DEAD END'END END END as Clearer
	,dbo.FilestoImport.[source] as ImportSource		
	,[FileName] as ImportFile	
	,[Path] as ImportPath
	,ToBeImported
	,dbo.FilestoImport.ID as FileID
	,LastImport
FROM 
	dbo.table_Clearer left join dbo.FilestoImport on (case when FilestoImport.[source] like '%Trades%' Then SUBSTRING(FilestoImport.[Source],14,10) ELSE 
		case when FilestoImport.[source] like '%Premium%' Then SUBSTRING(FilestoImport.[Source],15,10) ELSE 
			case when FilestoImport.[source] like '%Settlement%' Then SUBSTRING(FilestoImport.[Source],18,10) ELSE 'DEAD END'END END END) = dbo.table_Clearer.clearername
	join dbo.pathtofiles on dbo.FilestoImport.pathID =dbo.pathtofiles.ID 
WHERE
	dbo.FilestoImport.[Source] like '%clearer%'

GO

