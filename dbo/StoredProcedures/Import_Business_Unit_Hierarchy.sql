

/* 
 =============================================
 Author:      MKB
 Created:     2023/02
 Description:	importing ROCK Business unit hierarchy from dumped file
 ---------------------------------------------
 updates:  (when, who, step, what)
 2023-02-17, mkb, 0: initial setup
 2024-08-07,  
 2024-08-08, MT,  get rid of new line chachter in line 185-190 for the column Internal_Order_ID
==============================================
*/

CREATE PROCEDURE [dbo].[Import_Business_Unit_Hierarchy] 
AS
BEGIN TRY

	DECLARE @step Integer		
	DECLARE @Current_Procedure nvarchar(50)
	DECLARE @LogInfo Integer
	
	DECLARE @FileSource nvarchar(300)
	DECLARE @PathName nvarchar (300)
	DECLARE @FileName nvarchar(300)
	DECLARE @FileID Integer
				
	DECLARE @sql nvarchar (max)
	DECLARE @counter Integer

	DECLARE	@RecordCount1 Integer
	DECLARE @RecordCount2 Integer
	DECLARE @RecordCount3 Integer
	DECLARE @Main_Process varchar(20)
	DECLARE @Log_Entry varchar(200) 


		/*fill the required variables*/
		SET @step = 1
		SET @Current_Procedure = Object_Name(@@PROCID)
		SET @FileSource = 'BUH'
		SET @Main_Process = 'Data Import'
		
		EXEC dbo.Write_Log 'Info', 'START', @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL	
		

		SELECT @step = 10
		/*identify importpath*/
		SET @Log_Entry = 'Identify and load import file'
		EXEC dbo.Write_Log 'Info', @Log_Entry, @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL	
		
		SELECT @PathName = [dbo].[udf_get_path](@FileSource)      

		
		SELECT @step = 20
		/*count the number of files that should get imported*/
		SELECT @counter = count(*) FROM [dbo].[FilestoImport] WHERE  [dbo].[FilestoImport].[Source] like @FileSource and ToBeImported=1
		
		
		SELECT @step = 30
		/*in case here is no importfile, just refill the 01_realised table and set DeleteFlags*/
		IF @counter=0 
		BEGIN 
			SET @Log_Entry ='No data found to get imported, will quit.'
			EXEC dbo.Write_Log 'WARNING', @Log_Entry, @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL	
			GOTO NoFurtherAction 
		END		
	
		SELECT @step = 40
		/*drop out in case there was found more than one file*/
		IF @counter>1 
		BEGIN 
			SET @Log_Entry ='Too many files found to get imported, will quit.'
			EXEC dbo.Write_Log 'WARNING', @Log_Entry, @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL	
			GOTO NoFurtherAction 
		END		
	
		SELECT @step=50					
		SET @Log_Entry ='Start import of: ' + @PathName+@FileName 
		EXEC dbo.Write_Log 'Info', @Log_Entry, @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL	

		/*preparing raw_data table*/		
		DROP TABLE if exists dbo.table_business_unit_hierarchy_tmp
				
		SELECT @step=60	
		CREATE TABLE dbo.table_business_unit_hierarchy_tmp
			(
				BusinessLineName [nvarchar](100) NULL
				,BusinessLine_ID int NULL
				,DeskName [nvarchar](100) NULL
				,Desk_ID int NULL
				,Intermediate1Name [nvarchar](100) NULL
				,Intermediate1_ID int NULL
				,Intermediate2Name [nvarchar](100) NULL
				,Intermediate2_ID int NULL
				,Intermediate3Name [nvarchar](100) NULL
				,Intermediate3_ID int NULL
				,Intermediate4Name [nvarchar](100) NULL
				,Intermediate4_ID int NULL
				,Intermediate5Name [nvarchar](100) NULL
				,Intermediate5_ID int NULL
				,Intermediate6Name [nvarchar](100) NULL
				,Intermediate6_ID int NULL
				,BookName [nvarchar](100) NULL
				,Book_ID int NULL
				,PortfolioName [nvarchar](100) NULL
				,Portfolio_Id [int] NULL
				,Internal_Order_ID [nvarchar](100) NULL
			)
	
		SELECT @step=70
		SELECT 
			@FileName = [FileName] 
			,@FileID = [ID] 
		FROM 
			(
				SELECT *, ROW_NUMBER() OVER(ORDER BY ID) AS ROW 
				FROM [dbo].[FilestoImport] 
				WHERE [dbo].[FilestoImport].[Source] like @FileSource and ToBeImported=1
			) as TMP 
		WHERE 
			ROW = @counter
								
			
		/*import data into import tmp-table*/									
		SELECT @step=80
		SELECT @sql = N'BULK INSERT [dbo].[table_business_unit_hierarchy_tmp] FROM '  + '''' + @PathName + @filename + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR =''~'', FIRSTROW = 2, ROWTERMINATOR =''0x0a'')';
		EXECUTE sp_executesql @sql
			
		/*prepare final table*/						
		SELECT @step=90
		TRUNCATE TABLE dbo.table_business_unit_hierarchy
			
		/*transfer data into final table*/						
		SELECT @step=100			
		INSERT INTO dbo.table_business_unit_hierarchy
		(
			BusinessLineName
			,BusinessLine_ID
			,DeskName
			,Desk_ID
			,Intermediate1Name
			,Intermediate1_ID
			,Intermediate2Name
			,Intermediate2_ID
			,Intermediate3Name
			,Intermediate3_ID
			,Intermediate4Name
			,Intermediate4_ID
			,Intermediate5Name
			,Intermediate5_ID
			,Intermediate6Name
			,Intermediate6_ID
			,BookName
			,Book_ID
			,PortfolioName
			,Portfolio_Id
			,Internal_Order_ID
		)		
		Select	
			BusinessLineName
			,BusinessLine_ID
			,DeskName
			,Desk_ID
			,Intermediate1Name
			,Intermediate1_ID
			,Intermediate2Name
			,Intermediate2_ID
			,Intermediate3Name
			,Intermediate3_ID
			,Intermediate4Name
			,Intermediate4_ID
			,Intermediate5Name
			,Intermediate5_ID
			,Intermediate6Name
			,Intermediate6_ID
			,BookName
			,Book_ID
			,PortfolioName
			,Portfolio_Id
			,RTRIM(REPLACE(REPLACE(Internal_Order_ID, CHAR(13), ''), CHAR(10), '')) AS Internal_Order_ID
            --REPLACE(Internal_Order_ID, CHAR(13), ''): Removes any carriage return (\r) characters.
            --REPLACE(..., CHAR(10), ''): Removes any newline (\n) characters.
		FROM
			dbo.table_business_unit_hierarchy_tmp
		
		
		/*now document the last successful import timestamp*/
		SELECT @step=110
		update [dbo].[FilestoImport] set LastImport = getdate() WHERE [Source] like @FileSource and [filename]= @filename and ToBeImported=1


		/*count imported records*/				
		SELECT @step=120
		SELECT @recordcount1 = COUNT(*) from dbo.table_business_unit_hierarchy 
		SET @Log_Entry ='Records imported: '+ cast(format(@recordcount1,'#,#') as varchar)
		EXEC dbo.Write_Log 'Info', @Log_Entry, @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL	
		
		
		/*cleanup rawdata import table*/		
		SELECT @step=130		
		DROP TABLE if exists dbo.table_business_unit_hierarchy_tmp 


NoFurtherAction:
		EXEC dbo.Write_Log 'Info', 'FINISHED', @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL	

END TRY

BEGIN CATCH
	/*tell the world procedure failed*/
	EXEC [dbo].[usp_GetErrorInfo] @Current_Procedure, @step, NULL; 
	EXEC dbo.Write_Log 'FAILED', 'FAILED with error, check log for details', @Current_Procedure, @Main_Process,NULL, @step, 1;
	Return @step
END CATCH

GO

