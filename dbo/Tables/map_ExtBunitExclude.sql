CREATE TABLE [dbo].[map_ExtBunitExclude] (
    [ID]         INT          IDENTITY (1, 1) NOT NULL,
    [ExtBunit]   VARCHAR (50) NOT NULL,
    [ReconGroup] VARCHAR (50) NULL,
    [TimeStamp]  DATETIME     CONSTRAINT [DF_map_ExtBunitExclude_neu_new_timestamp] DEFAULT (getdate()) NULL,
    [User]       VARCHAR (50) CONSTRAINT [DF_map_ExtBunitExclude_neu_new_user] DEFAULT (user_name()) NULL,
    CONSTRAINT [PK_map_ExtBunitExclude] PRIMARY KEY CLUSTERED ([ExtBunit] ASC)
);


GO



CREATE trigger [dbo].[map_ExtBunitExclude-change-Log-insert] 
	on [dbo].[map_ExtBunitExclude]
	after insert 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
	select 'map_ExtBUnitExclude', isNULL(inserted.ExtBunit,'') + ' //' + isNULL(inserted.ReconGroup,''), 'Inserted', user_name(), getdate() from inserted

GO




CREATE trigger [dbo].[map_ExtBunitExclude-Log-update] 
	on [dbo].[map_ExtBunitExclude] 
	after update 
	as 
	BEGIN
		insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_ExtBUnitExclude', 'OLD => ' +   isNULL(deleted.ExtBunit,'') + ' //' + isNULL(deleted.ReconGroup,''), 'Updated', user_name(), getdate() from inserted, deleted where inserted.id = deleted.ID;
				
		insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_ExtBUnitExclude', 'NEW => ' +   isNULL(inserted.ExtBunit,'') + ' //' + isNULL(inserted.ReconGroup,''), 'Updated', user_name(), getdate() from inserted, deleted where inserted.id = deleted.ID;
	
	update [dbo].map_ExtBUnitExclude set [dbo].map_ExtBUnitExclude.[TimeStamp] = getdate(), [dbo].map_ExtBUnitExclude.[User] = user_name () 
		from [dbo].map_ExtBUnitExclude inner join inserted as i on [dbo].map_ExtBUnitExclude.ID = i.ID 
	END

GO




CREATE trigger [dbo].[map_ExtBunitExclude-change-Log-delete] 
	on [dbo].[map_ExtBunitExclude]
	after delete 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
	select 'map_ExtBUnitExclude', isNULL(deleted.ExtBunit,'') + ' //' + isNULL(deleted.ReconGroup,''), 'Deleted', user_name(), getdate() from deleted

	/*
	
CREATE trigger [dbo].[map_ExtBunitExclude-change-Log-delete]
	on [dbo].[map_ExtBunitExclude] 
	after delete 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
	select	'map_ExtBUnitExclude',  isNULL(inserted.ExtBunit,'') + ' //' + isNULL(inserted.ReconGroup,''),  'Deleted', user_name(), getdate() from deleted

CREATE trigger [dbo].[map_ExtBunitExclude-Log-update] 
	on [dbo].[map_ExtBunitExclude] 
	after update 
	as 
	BEGIN
		insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_ExtBUnitExclude', 'OLD => ' +   isNULL(inserted.ExtBunit,'') + ' //' + isNULL(inserted.ReconGroup,''), 'Updated', user_name(), getdate() from inserted, deleted where inserted.id = deleted.ID;
				
		insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_ExtBUnitExclude', 'NEW => ' +   isNULL(inserted.ExtBunit,'') + ' //' + isNULL(inserted.ReconGroup,''), 'Updated', user_name(), getdate() from inserted, deleted where inserted.id = deleted.ID;
		update [dbo].map_countryCode set [dbo].map_countryCode.[TimeStamp] = getdate(), [dbo].map_countryCode.[User] = user_name () 
		from [dbo].map_countryCode inner join inserted as i on [dbo].map_countryCode.ID = i.ID 
	END
	*/

GO

