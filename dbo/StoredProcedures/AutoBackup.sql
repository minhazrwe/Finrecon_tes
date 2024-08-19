


/* 
=======================================================================================================================================
Author:				Martin Ulken
Created:			2022-03-28 
Description:	This Procedure will backup the current entries of a provided table @table into a table @tablename_AutoBackup. 
							It can also be used to restore data from the backup.
==========================================================================================
Changes:
28/03/2022, mkb: small tidy up.
=======================================================================================================================================*/

CREATE PROCEDURE [dbo].[AutoBackup]
	@table nvarchar(200),
	@restore_backup_id bigint = 0 --Please only set this value if you want to restore data. When this value is set to a valid backup_id, the backup is restored.  
AS
BEGIN TRY
	
	DECLARE @LogInfo INTEGER
	DECLARE @backup_id BIGINT 
	DECLARE @maxBackupRecords INT 
	DECLARE @count BIGINT 
	DECLARE @sql NVARCHAR(max)
	DECLARE @tablename NVARCHAR(200)
	DECLARE @backupTable NVARCHAR(200)
	DECLARE @backupTablename NVARCHAR(200)
	DECLARE @schema NVARCHAR(20)
	DECLARE @proc NVARCHAR(40) 
	DECLARE @step INTEGER 
	DECLARE @i as INT
	DECLARE @colToDelete as NVARCHAR(100)
	DECLARE @columns as nvarchar(max)
	DECLARE @stringPosition INT

	/* fill variables with initial values*/
	SELECT @step = 1
	SELECT @backup_id = 0
	SELECT @maxBackupRecords = 70
	SELECT @count = 0
	SELECT @schema = 'dbo'
	SELECT @proc =  Object_Name(@@PROCID)
	
	SET @columns = ''	
	

	SELECT @LogInfo = [dbo].[LogInfo].[LogInfo]	FROM [dbo].[LogInfo]
	
	IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile]  SELECT @proc + ' - START',GETDATE() END		

	/*correct the format of table to have @table = [<schema>].[<tablename>] */
	SELECT @step = 2 
	SET  @table = ltrim(rtrim(@table))

	SELECT @step = 3 
	IF left(@table,1) <> '[' 
		BEGIN 
			SET @table = '[' + @table
		END
	
	SELECT @step = 4 
	IF right(@table,1) <> ']' 
		BEGIN
			SET @table = @table + ']'
		END
	
	SELECT @step = 5 
	IF @table not like '%.%' 
		BEGIN
			SELECT @table = '['+ @schema +'].' + @table
		END
	ELSE
		BEGIN
			SELECT @stringPosition = CHARINDEX('.', @table)
			IF SUBSTRING(@table,@stringPosition-1,1)<>']' 
				BEGIN
					SELECT @table = SUBSTRING(@table,1,@stringPosition-1) + '].[' +  SUBSTRING(@table,@stringPosition+1,len(@table))
				END
		END

	/*Extract the pure table name*/
	SELECT @step = 6 
	SET @tablename = substring(@table,CHARINDEX('.', @table)+2, len(@table)-CHARINDEX('.', @table)-2)
	
	/*Create the backup table name*/	
	SELECT @step = 7 
	SET @backupTable = '['+ @schema +'].['+@tablename + '_AutoBackup]'
	SET @backupTablename = @tablename + '_AutoBackup'


	/*Get List of all non identity columns of the @table to be imported into the backup table*/	
	SELECT @step = 8 
	select @columns = '[' + COALESCE([columns].[name], '' ) + '], ' + @columns from sys.tables [tables] Inner Join sys.all_columns [columns] On [tables].[object_id]=[columns].[object_id] Where [tables].[name] = @tablename and is_identity=0 order by [columns].[column_id] desc
	SET @columns = left(@columns, len(@columns)-1)

	/*Check if backup needs to be restored*/ 
	SELECT @step = 9 
	IF @restore_backup_id > 0
	BEGIN
		/*Restore table content from backup*/
		IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @backupTablename))
		BEGIN
			/*Check if @restore_backup_id exists*/
			SET @sql = 'SELECT @restore_backup_id = max([backup_id]) FROM ' + @backupTable + ' WHERE backup_id = ' + convert(nvarchar,@restore_backup_id)
			EXEC sp_executesql @sql, N'@restore_backup_id bigint OUTPUT',@restore_backup_id = @restore_backup_id OUTPUT
			
			IF  @restore_backup_id is not null 
			BEGIN
				/*Truncate @table and insert the backup*/
				SET @sql = N'TRUNCATE table '+ @table
				EXEC sp_executesql @sql
				
				SET @sql = 'INSERT INTO ' + @table + ' ( ' + @columns + ' ) SELECT ' + @columns + ' FROM ' + @backupTable + ' WHERE backup_id = ' + convert(nvarchar,@restore_backup_id) 
				EXEC sp_executesql @sql
				
				SELECT @step = 6 IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - Backup from ' + @backupTable + ' with id ' + convert(nvarchar, @restore_backup_id) + ' has been restored' ,GETDATE() END
			END
		END
		RETURN
	END 


	IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - Start Autobackup for table ' + @table ,GETDATE() END
	
		/*If the AutoBackup table does not exist it has to be created*/
	SELECT @step = 10 
	IF NOT (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @backupTablename))
		BEGIN
			IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile]  SELECT @proc + ' - Create AutoBackup table: ' + @backupTable ,GETDATE() END
		
			/*Create the empty table based on the source table using into*/
			SELECT @step = 20 
			SET @sql = N'SELECT top 0 * into '+ @backupTable + ' FROM ' + @table
			EXEC sp_executesql @sql

			/*Delete the Identity Columns*/
				SELECT @step = 30 
			Select @i=min([columns].[column_id]) from sys.tables [tables] Inner Join sys.all_columns [columns] On [tables].[object_id]=[columns].[object_id] Where is_identity=1 and [tables].[name] = @backupTablename
			
			SELECT @step = 40 
			WHILE @i is not null
			BEGIN
				Select @colToDelete = [columns].[name] from sys.tables [tables] Inner Join sys.all_columns [columns] On [tables].[object_id]=[columns].[object_id] Where [columns].[column_id] = @i and [tables].[name] = @backupTablename
				SET @sql ='ALTER TABLE ' + @backupTable + ' DROP COLUMN ' + @colToDelete				
				EXEC sp_executesql @sql

				Select @i = min([columns].[column_id]) from sys.tables [tables] Inner Join sys.all_columns [columns] On [tables].[object_id]=[columns].[object_id] Where is_identity=1 and [tables].[name] = @backupTablename and [columns].[column_id] > @i
			END

			/*Add additional backup columns*/
			SELECT @step = 50 
			SET @sql = N'ALTER TABLE ' + @backupTable + ' ADD [backup_id] BIGINT NULL, backup_timestamp DATETIME NULL, backup_user varchar(100) NULL'
			EXEC sp_executesql @sql
		END 
	ELSE
		BEGIN
			/* Delete if more than 100 Backups have been created. Needs to be replaced by a configuration*/
			SELECT @step = 60 
			SET @sql = N'delete from ' + @backupTable + ' where backup_id < (select max(backup_id)- (' + convert(nvarchar, @maxBackupRecords) + ' - 2 ) from ' + @backupTable + ')'
			EXEC sp_executesql @sql
		END
	

	/*Get the next backup id*/
	SELECT @step = 70 
	SET @sql = 'SELECT @backup_id = max([backup_id]) FROM ' + @backupTable
	EXEC sp_executesql @sql, N'@backup_id bigint OUTPUT',@backup_id = @backup_id OUTPUT
	
	SELECT @step = 80 
	IF @backup_id is null
		BEGIN
			SET @backup_id = 1
		END
	ELSE 
		BEGIN
			SET @backup_id = @backup_id + 1
		END
	
	/*Insert Data into the backup table*/
	SELECT @step = 90
	SET @sql = 'INSERT INTO ' + @backupTable + ' ( ' + @columns + ' , [backup_id], [backup_timestamp], [backup_user]) SELECT ' + @columns + ', ' + convert(nvarchar,@backup_id) + ', CURRENT_TIMESTAMP, CURRENT_USER FROM ' + @table
	EXEC sp_executesql @sql

	SELECT @step = 100 
	IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile]  SELECT @proc + ' - Inserted data in backup table: ' + @backupTable + ' with id ' +convert(nvarchar,@backup_id)  ,GETDATE() END	

	IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile]  SELECT @proc + ' - FINISHED',GETDATE() END		
END TRY


BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step		
		BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - FAILED', GETDATE () END
END CATCH

GO

