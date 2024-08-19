CREATE TABLE [dbo].[map_instype] (
    [ID]             INT          IDENTITY (1, 1) NOT NULL,
    [InstrumentType] VARCHAR (50) NOT NULL,
    [CDM]            VARCHAR (50) NULL,
    [LastUpdate]     DATETIME     CONSTRAINT [DF_map_instype_LastUpdate] DEFAULT (getdate()) NULL,
    CONSTRAINT [pk_map_instype] PRIMARY KEY CLUSTERED ([InstrumentType] ASC)
);


GO



CREATE trigger [dbo].[trigger_map_instype_after_insert] 
	on [dbo].[map_instype] 
	after insert 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_instype', isNULL(inserted.[InstrumentType],'') + ' //' + isNULL(inserted.[CDM],''), 'Inserted', user_name(), getdate() from inserted;

GO


CREATE trigger [dbo].[trigger_map_instype_after_update] 
	on [dbo].[map_instype] 
	after update 
	as 
	BEGIN
		insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_instype', 'NEW => ' + isNULL(inserted.[InstrumentType],'') + ' //' + isNULL(inserted.[CDM],'') , 'Updated', user_name(), getdate() from inserted, deleted where inserted.id = deleted.ID;
				
		insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_instype', 'OLD => ' + isNULL(deleted.[InstrumentType],'') + ' //' + isNULL(deleted.[CDM],'') , 'Updated', user_name(), getdate() from inserted, deleted where inserted.id = deleted.ID;

		update [dbo].[map_instype] set [dbo].[map_instype].[LastUpdate] = getdate()
		from [dbo].[map_instype] inner join inserted as i on [dbo].[map_instype].ID = i.ID 
	END

GO


CREATE trigger [dbo].[trigger_map_instype_after_delete] 
	on [dbo].[map_instype] 
	after delete 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_instype', isNULL(deleted.[InstrumentType],'') + ' //' + isNULL(deleted.[CDM],''), 'Deleted', user_name(), getdate() from deleted;

GO

