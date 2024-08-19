CREATE TABLE [dbo].[table_Clearer_map_ExpirationDate] (
    [ID]                     INT            IDENTITY (1, 1) NOT NULL,
    [ReferenceID]            NVARCHAR (100) NOT NULL,
    [ContractExpirationDate] DATE           NOT NULL,
    [LastUpdate]             DATE           CONSTRAINT [DF_table_map_ExpirationDate_LastUpdate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_table_map_ExpirationDate] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [UK_table_map_ExpirationDate_ReferenceID] UNIQUE NONCLUSTERED ([ReferenceID] ASC)
);


GO



CREATE trigger [dbo].[table_Clearer_map_ExpirationDate_after_update] 
	on [dbo].[table_Clearer_map_ExpirationDate] 
	after update 
	as 
		BEGIN
		insert into dbo.[Change-Log] 
		(
			[Change-Table]
			,[Change-Entry]
			,[Change-Type]
			,[Change-Datetime]
			,[Change-User]
			) 
		select			
			'table_Clearer_map_ExpirationDate'
			,'OLD => ' +   isNULL(deleted.ReferenceID,'') + ' //' + isNULL(cast(deleted.ContractExpirationDate as varchar),'')
			,'Updated'
			,getdate() 
			,CURRENT_USER
		from 
			inserted
			,deleted 
		where 
			inserted.id = deleted.ID;

		insert into dbo.[Change-Log] 
		(
			[Change-Table]
			,[Change-Entry]
			,[Change-Type]
			,[Change-Datetime]
			,[Change-User]
		) 
		select			
			'table_Clearer_map_ExpirationDate'
			,'NEW => ' +   isNULL(inserted.ReferenceID,'') + ' //' + isNULL(cast(inserted.ContractExpirationDate as varchar),'')
			,'Updated'
			,getdate() 			
			,CURRENT_USER
		from 
			inserted
			,deleted 
		where 
			inserted.id = deleted.ID;

		update [dbo].table_Clearer_map_ExpirationDate 
			set [dbo].table_Clearer_map_ExpirationDate.LastUpdate = getdate()
			from 
				[dbo].table_Clearer_map_ExpirationDate 
				inner join inserted as i on [dbo].table_Clearer_map_ExpirationDate.ID = i.ID 
	END
	
--GO

--ALTER TABLE [dbo].[table_Clearer_map_ExpirationDate] ENABLE TRIGGER [table_Clearer_map_ExpirationDate_after_insert]
--ALTER TABLE [dbo].[table_Clearer_map_ExpirationDate] ENABLE TRIGGER [table_Clearer_map_ExpirationDate_after_delete]
--ALTER TABLE [dbo].[table_Clearer_map_ExpirationDate] ENABLE TRIGGER [table_Clearer_map_ExpirationDate_after_update]
--GO

GO




CREATE trigger [dbo].[table_Clearer_map_ExpirationDate_after_delete]
	on [dbo].[table_Clearer_map_ExpirationDate] 
	after delete 
		as insert into dbo.[Change-Log] 
		(
			[Change-Table]
			,[Change-Entry]
			,[Change-Type]
			,[Change-User]
			,[Change-Datetime]
		) 
		select	
			'table_Clearer_map_ExpirationDate'
			,isNULL(deleted.ReferenceID,'') + ' //' + isNULL(cast(deleted.ContractExpirationDate as varchar),'')
			,'Deleted'
			,CURRENT_USER
			, getdate() 
		from 
			deleted

GO




CREATE trigger [dbo].[table_Clearer_map_ExpirationDate_after_insert] 
	on [dbo].[table_Clearer_map_ExpirationDate]
	after insert 
		as INSERT INTO dbo.[Change-Log] 
		(
			[Change-Table]
			,[Change-Entry]
			,[Change-Type]			
			,[Change-Datetime]
			,[Change-User]
		) 
		select 
			'table_Clearer_map_ExpirationDate'
			,isNULL(inserted.ReferenceID,'') + ' //' + isNULL(cast(inserted.ContractExpirationDate as varchar),'')
			,'Inserted'			
			,getdate() 
			,CURRENT_USER	
		from 
			inserted

GO

