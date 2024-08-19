CREATE TABLE [dbo].[table_map_Instrument_Commodity] (
    [ID]              INT            IDENTITY (1, 1) NOT NULL,
    [Instrument_Type] VARCHAR (100)  NOT NULL,
    [Commodity_Type]  VARCHAR (100)  NOT NULL,
    [Comment]         VARCHAR (2000) NULL,
    [UserName]        VARCHAR (30)   CONSTRAINT [DF_table_map_Instrument_Commodity_UserName] DEFAULT (user_name()) NULL,
    [Last_Update]     DATETIME       CONSTRAINT [DF_table_map_Instrument_Commodity_Last_Update] DEFAULT (getdate()) NULL,
    CONSTRAINT [pk_table_map_Instrument_Commodity] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [chk_table_map_Instrument_Commodity] CHECK ([Commodity_Type]='OTHER' OR [Commodity_Type]='POWER' OR [Commodity_Type]='OIL' OR [Commodity_Type]='METAL' OR [Commodity_Type]='GAS' OR [Commodity_Type]='COAL' OR [Commodity_Type]='CARBON' OR [Commodity_Type]='BIOMASS' OR [Commodity_Type]='FX' OR [Commodity_Type]='FREIGHT' OR [Commodity_Type]='IRS'),
    CONSTRAINT [UK_table_map_Instrument_Commodity01] UNIQUE NONCLUSTERED ([Instrument_Type] ASC)
);


GO


--drop trigger [dbo].[trigger_table_map_Instrument_Commodity_after_delete];

create trigger [dbo].[trigger_table_map_Instrument_Commodity_after_delete] 
	on [dbo].[table_map_Instrument_Commodity]
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
		'table_map_Instrument_Commodity'
    ,isNULL(Deleted.Instrument_Type,'') + ' //'
			+ isNULL(Deleted.Commodity_Type,'') + ' //'
			+ isNULL(Deleted.Comment,'') + ' //'				
			+ isNULL(cast(Deleted.Last_Update as varchar),'') + ' //'
			+ isNULL(Deleted.UserName,'') + ' //'
		,'Deleted'
		,user_name()
		,getdate() 
	FROM 
		deleted;

ALTER TABLE [dbo].table_map_Instrument_Commodity ENABLE TRIGGER [trigger_table_map_Instrument_Commodity_after_delete]

GO


--drop  trigger [dbo].[trigger_table_map_Instrument_Commodity_after_update] 

create trigger [dbo].[trigger_table_map_Instrument_Commodity_after_update] 
	on [dbo].[table_map_Instrument_Commodity]
	after update 
	as 
	/*log old entry*/
	insert into dbo.[Change-Log] 
	(
		 [Change-Table]
		,[Change-Entry]
		,[Change-Type]
		,[Change-User]
		,[Change-Datetime]
	) 
	SELECT
		'table_map_Instrument_Commodity'
    ,isNULL(Deleted.Instrument_Type,'') + ' //'
			+ isNULL(Deleted.Commodity_Type,'') + ' //'
			+ isNULL(Deleted.Comment,'') + ' //'	
			+ isNULL(cast(Deleted.Last_Update as varchar),'') + ' //'
			+ isNULL(Deleted.UserName,'') + ' //'
		,'Deleted'
		,user_name()
		,getdate() 
	FROM 
		 inserted
		,deleted 
	WHERE 
		inserted.id = deleted.ID

	/*log updated entry*/
		insert into dbo.[Change-Log] 
	(
		 [Change-Table]
		,[Change-Entry]
		,[Change-Type]
		,[Change-User]
		,[Change-Datetime]
	) 
	SELECT
		'table_map_Instrument_Commodity'
    ,isNULL(inserted.Instrument_Type,'') + ' //'
			+ isNULL(inserted.Commodity_Type,'') + ' //'
			+ isNULL(inserted.Comment,'') + ' //'	
			+ isNULL(cast(inserted.Last_Update as varchar),'') + ' //'
			+ isNULL(inserted.UserName,'') + ' //'
		,'Updated'
		,user_name()
		,getdate() 
	FROM 
		 inserted
		,deleted 
	WHERE 
		inserted.id = deleted.ID

	/*update timestamp for Last_Update and userID in data table*/
	UPDATE dbo.table_map_Instrument_Commodity SET 
		Last_update = getdate()
		,UserName = user_name () 
	FROM 
		dbo.table_map_Instrument_Commodity
		inner join inserted on dbo.table_map_Instrument_Commodity.ID = inserted.ID 

	
ALTER TABLE dbo.table_map_Instrument_Commodity ENABLE TRIGGER trigger_table_map_Instrument_Commodity_after_update

GO

