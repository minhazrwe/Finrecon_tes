CREATE TABLE [dbo].[table_map_cashflow_type] (
    [ID]                 INT            IDENTITY (1, 1) NOT NULL,
    [Cashflow_Type_ID]   INT            NOT NULL,
    [Cashflow_Type_Name] NVARCHAR (255) NOT NULL,
    [Change_User]        NVARCHAR (50)  CONSTRAINT [DF_table_map_cashflow_type_change_user] DEFAULT (user_name()) NULL,
    [Last_Update]        DATETIME       CONSTRAINT [DF_table_map_cashflow_type_Last_Update] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_table_map_cashflow_type] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [UK_table_map_cashflow_type1] UNIQUE NONCLUSTERED ([Cashflow_Type_Name] ASC),
    CONSTRAINT [UK_table_map_cashflow_type2] UNIQUE NONCLUSTERED ([Cashflow_Type_ID] ASC, [Cashflow_Type_Name] ASC)
);


GO


/*=================================================================================================================
	Author:      mkb
	Created:     2024/07
	Description:	trigger to enable proper logging of any update to table
	------------------------------------------------------------------------------------------
	change history: when, who, step, what, (why)
	2024-07-05, mkb, all, initial setup of procedure 

=================================================================================================================*/


CREATE trigger [dbo].[trigger_table_map_cashflow_type_after_update] 
	ON [dbo].[table_map_cashflow_type] 
	after update
	as 
	/*log old entry*/
	INSERT INTO dbo.[Change-Log] 
	(
		 [Change-Table]
		,[Change-Entry]
		,[Change-Type]
		,[Change-User]
		,[Change-Datetime]
	) 
	SELECT
		'table_map_cashflow_type'
		,'OLD: ' + isNULL(Deleted.Cashflow_Type_ID,'') + ' //'
			+ isNULL(Deleted.Cashflow_Type_Name,'') + ' //'
			+ isNULL(Deleted.Change_User,'') + ' //'
			+ isNULL(Deleted.Last_Update,'') 
		,'Deleted'
		,user_name()
		,getdate() 
	FROM 
		 inserted
		,deleted 
	WHERE 
		inserted.id = deleted.ID

	
	/*log updatedentry*/
	INSERT INTO dbo.[Change-Log] 
	(
		 [Change-Table]
		,[Change-Entry]
		,[Change-Type]
		,[Change-User]
		,[Change-Datetime]
	) 
	SELECT
		'table_map_cashflow_type'
		,'Updated:' + isNULL(inserted.Cashflow_Type_ID,'') + ' //'
			+ isNULL(inserted.Cashflow_Type_Name,'') + ' //'
			+ isNULL(inserted.Change_User,'') + ' //'
			+ isNULL(inserted.Last_Update,'') 
		,'Deleted'
		,user_name()
		,getdate() 
	FROM 
		 deleted,
		 inserted
	WHERE 
		inserted.id = deleted.ID

	/*update lastupdate-timestamp and userID in data table*/
	UPDATE dbo.table_map_cashflow_type SET 
			Last_update = getdate()
		,Change_User = user_name () 
	FROM 
		dbo.table_map_cashflow_type
		inner join inserted as i on dbo.table_map_cashflow_type.ID = i.ID 

	
ALTER TABLE dbo.table_map_cashflow_type ENABLE TRIGGER trigger_table_map_cashflow_type_after_update

GO



/*=================================================================================================================
	Author:      mkb
	Created:     2024/07
	Description:	trigger to enable proper logging of any delete from table
	------------------------------------------------------------------------------------------
	change history: when, who, step, what, (why)
	2024-07-05, mkb, all, initial setup of procedure 
=================================================================================================================*/

CREATE trigger dbo.trigger_table_map_cashflow_type_after_delete 
	on dbo.table_map_cashflow_type
	after delete 
	as 
	insert into dbo.[Change-Log] 
	(
		 [Change-Table]
		,[Change-Entry]
		,[Change-Type]
		,[Change-User]
		,[Change-Datetime]
	) 
	SELECT
		'table_unrealised_map_accounts'
		,isNULL(Deleted.Cashflow_Type_ID,'') + ' //'
			+ isNULL(Deleted.Cashflow_Type_Name,'') + ' //'
			+ isNULL(Deleted.Change_User,'') + ' //'
			+ isNULL(Deleted.Last_Update,'') 
		,'Deleted'
		,user_name()
		,getdate() 
	FROM 
		deleted;

ALTER TABLE dbo.table_map_cashflow_type ENABLE TRIGGER trigger_table_map_cashflow_type_after_delete

GO

