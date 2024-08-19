CREATE TABLE [dbo].[table_map_accounts_unrealised] (
    [ID]                   INT           IDENTITY (1, 1) NOT NULL,
    [Accounting_Treatment] VARCHAR (255) NULL,
    [Counterparty_Group]   VARCHAR (255) NULL,
    [Commodity_Type]       VARCHAR (255) NULL,
    [ST_Asset]             VARCHAR (255) NULL,
    [LT_Asset]             VARCHAR (255) NULL,
    [ST_Liability]         VARCHAR (255) NULL,
    [LT_Liability]         VARCHAR (255) NULL,
    [PNL_OCI]              VARCHAR (255) NULL,
    [Last_Update]          DATETIME      CONSTRAINT [DF_table_map_accounts_unrealised_Last_Update] DEFAULT (getdate()) NULL,
    [Change_User]          VARCHAR (50)  CONSTRAINT [DF_table_map_accounts_unrealised_Change_User] DEFAULT (user_name()) NULL,
    CONSTRAINT [pk_table_unrealised_map_accounts] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [CHK_table_map_accounts_unrealised] CHECK ([Accounting_Treatment]='FV_OCI' OR [Accounting_Treatment]='FV_PNL' OR [Accounting_Treatment]='FV_NOR' OR [Accounting_Treatment]='own use' OR [Accounting_Treatment]='out of scope'),
    CONSTRAINT [UK_table_unrealised_map_accounts] UNIQUE NONCLUSTERED ([Accounting_Treatment] ASC, [Counterparty_Group] ASC, [Commodity_Type] ASC)
);


GO



/*=================================================================================================================
	Author:      mkb
	Created:     2024/07
	Description:	trigger to enable proper logging of any update to map_accounts_unrealised
	------------------------------------------------------------------------------------------
	change history: when, who, step, what, (why)
	2024-08-04, mkb, all, initial setup of trigger

=================================================================================================================*/

CREATE trigger [dbo].[trigger_map_accounts_unrealised_after_update] 
	ON [dbo].[table_map_accounts_unrealised] 
	after update
	as 
	INSERT INTO dbo.[Change-Log] 
	(
		 [Change-Table]
		,[Change-Entry]
		,[Change-Type]
		,[Change-User]
		,[Change-Datetime]
	) 
	SELECT
		'table_map_accounts_unrealised'
    ,'OLD: ' 
			+ isNULL(Deleted.Accounting_Treatment,'') + ' //'
			+ isNULL(Deleted.Counterparty_Group,'') + ' //'
			+ isNULL(Deleted.Commodity_Type,'') + ' //'			
			+ isNULL(Deleted.ST_Asset,'') + ' //'
			+ isNULL(Deleted.LT_Asset,'') + ' //'
			+ isNULL(Deleted.ST_Liability,'') + ' //'
			+ isNULL(Deleted.LT_Liability,'') + ' //'
			+ isNULL(Deleted.PNL_OCI,'') + ' //'
			+ isNULL(Deleted.Last_Update,'') + ' //'
			+ isNULL(Deleted.Change_User,'') + ' //'
		,'Deleted'
		,user_name()
		,getdate() 
	FROM
		 inserted
		,deleted 
	WHERE 
		inserted.id = deleted.ID

INSERT INTO dbo.[Change-Log] 
	(
		 [Change-Table]
		,[Change-Entry]
		,[Change-Type]
		,[Change-User]
		,[Change-Datetime]
	) 
	SELECT
		'table_map_accounts_unrealised'
    ,'NEW: ' 
			+ isNULL(inserted.Accounting_Treatment,'') + ' //'
			+ isNULL(inserted.Counterparty_Group,'') + ' //'
			+ isNULL(inserted.Commodity_Type,'') + ' //'			
			+ isNULL(inserted.ST_Asset,'') + ' //'
			+ isNULL(inserted.LT_Asset,'') + ' //'
			+ isNULL(inserted.ST_Liability,'') + ' //'
			+ isNULL(inserted.LT_Liability,'') + ' //'
			+ isNULL(inserted.PNL_OCI,'') + ' //'
			+ isNULL(inserted.Last_Update,'') + ' //'
			+ isNULL(inserted.Change_User,'') + ' //'
		,'Inserted'
		,user_name()
		,getdate() 
	FROM
		 inserted
		,deleted 
	WHERE 
		inserted.id = deleted.ID


		/*update lastupdate-timestamp and userID in data table*/
		UPDATE dbo.table_map_accounts_unrealised set 
			Last_update = getdate()
			,Change_User = user_name () 
		FROM 
			dbo.table_map_accounts_unrealised
			inner join inserted as i on dbo.table_map_accounts_unrealised.ID = i.ID 

	
ALTER TABLE dbo.table_map_accounts_unrealised ENABLE TRIGGER trigger_map_accounts_unrealised_after_update
GO
DISABLE TRIGGER [dbo].[trigger_map_accounts_unrealised_after_update]
    ON [dbo].[table_map_accounts_unrealised];


GO




/*=================================================================================================================
	Author:      mkb
	Created:     2024/07
	Description:	trigger to enable proper logging of any deelte from  table
	------------------------------------------------------------------------------------------
	change history: when, who, step, what, (why)
	2024-02-00, mkb, all, initial setup of procedure 

=================================================================================================================*/

CREATE trigger [dbo].[trigger_map_accounts_unrealised_after_delete] 
	ON [dbo].[table_map_accounts_unrealised] 
	after delete
	as 
	INSERT INTO dbo.[Change-Log] 
	(
		 [Change-Table]
		,[Change-Entry]
		,[Change-Type]
		,[Change-User]
		,[Change-Datetime]
	) 
	SELECT
		'table_map_accounts_unrealised'
    ,'OLD: ' 
			+ isNULL(Deleted.Accounting_Treatment,'') + ' //'
			+ isNULL(Deleted.Counterparty_Group,'') + ' //'
			+ isNULL(Deleted.Commodity_Type,'') + ' //'			
			+ isNULL(Deleted.ST_Asset,'') + ' //'
			+ isNULL(Deleted.LT_Asset,'') + ' //'
			+ isNULL(Deleted.ST_Liability,'') + ' //'
			+ isNULL(Deleted.LT_Liability,'') + ' //'
			+ isNULL(Deleted.PNL_OCI,'') + ' //'
			+ isNULL(cast(Deleted.Last_Update as varchar),'') + ' //'
			+ isNULL(Deleted.Change_User,'') + ' //'
		,'Deleted'
		,user_name()
		,getdate() 
	FROM
		 inserted
		,deleted 
	WHERE 
		inserted.id = deleted.ID

	
ALTER TABLE dbo.table_map_accounts_unrealised ENABLE TRIGGER trigger_map_accounts_unrealised_after_delete

GO

