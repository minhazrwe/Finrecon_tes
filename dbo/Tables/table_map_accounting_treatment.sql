CREATE TABLE [dbo].[table_map_accounting_treatment] (
    [ID]                     INT           IDENTITY (1, 1) NOT NULL,
    [Internal_Portfolio]     VARCHAR (255) NOT NULL,
    [Counterparty_Group]     VARCHAR (255) NOT NULL,
    [Instrument_Type]        VARCHAR (255) NOT NULL,
    [Cashflow_Type]          VARCHAR (255) NULL,
    [External_Business_Unit] VARCHAR (255) NULL,
    [Accounting_Treatment]   VARCHAR (255) NULL,
    [Last_Update]            DATETIME      CONSTRAINT [DF_table_map_accounting_treatment_Last_Update] DEFAULT (getdate()) NULL,
    [Change_User]            VARCHAR (50)  CONSTRAINT [DF_table_map_accounting_treatment_Change_User] DEFAULT (user_name()) NULL,
    [Portfolio_ID]           VARCHAR (100) NULL,
    CONSTRAINT [pk_table_map_accounting_treatment] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [chk_table_map_accounting_treatment] CHECK ([Accounting_Treatment]='FV_OCI' OR [Accounting_Treatment]='FV_PNL' OR [Accounting_Treatment]='Hedged Items' OR [Accounting_Treatment]='own use' OR [Accounting_Treatment]='out of scope' OR [Accounting_Treatment]='FV_NOR'),
    CONSTRAINT [UK_table_map_accounting_treatment] UNIQUE NONCLUSTERED ([Internal_Portfolio] ASC, [Counterparty_Group] ASC, [Instrument_Type] ASC, [Cashflow_Type] ASC, [External_Business_Unit] ASC)
);


GO

create trigger [dbo].[trigger_map_accounting_treatment_after_delete] 
	on [dbo].table_map_accounting_treatment
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
		'table_map_accounting_treatment'
    ,isNULL(Deleted.Internal_Portfolio,'') + ' //'
			+ isNULL(Deleted.Counterparty_Group,'') + ' //'
			+ isNULL(Deleted.Instrument_Type,'') + ' //'
			+ isNULL(Deleted.Cashflow_Type,'') + ' //'
			+ isNULL(Deleted.External_Business_Unit,'') + ' //'  
			+ isNULL(Deleted.Accounting_Treatment,'') + ' //'
			+ isNULL(Deleted.Last_Update,'') + ' //'
			+ isNULL(Deleted.Change_User,'') + ' //'
		,'Deleted'
		,user_name()
		,getdate() 
	FROM 
		deleted;

ALTER TABLE [dbo].table_map_accounting_treatment ENABLE TRIGGER [trigger_map_accountment_treating_after_delete]
GO
DISABLE TRIGGER [dbo].[trigger_map_accounting_treatment_after_delete]
    ON [dbo].[table_map_accounting_treatment];


GO


/*=================================================================================================================
	Author:      mkb
	Created:     2024/07
	Description:	trigger to enable proper logging of any update to table table_map_accounting_treatment
	------------------------------------------------------------------------------------------
	change history: when, who, step, what, (why)
	2024-07-10, mkb, all, initial setup of trigger
	2024-08-04, mkb, all, disabled trigger
	=================================================================================================================*/

CREATE trigger [dbo].[trigger_table_map_accounting_treatment_after_update] 
	ON [dbo].[table_map_accounting_treatment] 
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
		'table_map_accounting_treatment'
    ,'OLD: ' 
			+ isNULL(Deleted.Internal_Portfolio,'') + ' //'
			+ isNULL(Deleted.Counterparty_Group,'') + ' //'
			+ isNULL(Deleted.Instrument_Type,'') + ' //'
			+ isNULL(Deleted.Cashflow_Type,'') + ' //'
			+ isNULL(Deleted.External_Business_Unit,'') + ' //'   
			+ isNULL(Deleted.Accounting_Treatment,'') + ' //'
			+ isNULL(cast(Deleted.Last_Update as varchar),'') + ' //'
			+ isNULL(Deleted.Change_User,'') 
		,'Deleted'
		,user_name()
		,getdate() 
	FROM
		 inserted
		,deleted 
	WHERE 
		inserted.id = deleted.ID

	insert into dbo.[Change-Log] 
	(
		 [Change-Table]
		,[Change-Entry]
		,[Change-Type]
		,[Change-User]
		,[Change-Datetime]
	) 
	SELECT
		'table_map_accounting_treatment'
    ,'Updated: '
			+ isNULL(inserted.Internal_Portfolio,'') + ' //'
			+ isNULL(inserted.Counterparty_Group,'') + ' //'
			+ isNULL(inserted.Instrument_Type,'') + ' //'
			+ isNULL(inserted.Cashflow_Type,'') + ' //'
			+ isNULL(inserted.External_Business_Unit,'') + ' //'   
			+ isNULL(inserted.Accounting_Treatment,'') + ' //'
			+ isNULL(cast(inserted.Last_Update as varchar),'') + ' //'
			+ isNULL(inserted.Change_User,'') 
		,'Updated'
		,user_name()
		,getdate() 
	FROM  
		 inserted
		,deleted 
	WHERE 
		inserted.id = deleted.ID;


		/*update lastupdate-timestamp and userID in data table*/
		UPDATE dbo.table_map_accounting_treatment set 
			Last_update = getdate()
			,Change_User = user_name () 
		FROM 
			dbo.table_map_accounting_treatment
			inner join inserted as i on dbo.table_map_accounting_treatment.ID = i.ID 

	
ALTER TABLE dbo.table_map_accounting_treatment ENABLE TRIGGER trigger_table_map_accounting_treatment_after_update

--ALTER TABLE dbo.table_map_accounting_treatment DISABLE TRIGGER trigger_table_map_accounting_treatment_after_update

GO

