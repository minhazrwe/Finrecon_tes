CREATE TABLE [dbo].[map_countryCode] (
    [ID]         INT           IDENTITY (1, 1) NOT NULL,
    [country]    VARCHAR (255) NULL,
    [ISO-2]      VARCHAR (255) NOT NULL,
    [ISO-3]      VARCHAR (255) NULL,
    [numeric]    FLOAT (53)    NULL,
    [Assignment] VARCHAR (255) NULL,
    [TimeStamp]  DATETIME      CONSTRAINT [DF_map_countryCode_TimeStamp] DEFAULT (getdate()) NULL,
    [USER]       VARCHAR (50)  CONSTRAINT [DF_map_countryCode_USER] DEFAULT (user_name()) NULL,
    CONSTRAINT [pk_map_countryCode] PRIMARY KEY CLUSTERED ([ISO-2] ASC)
);


GO





CREATE trigger [dbo].[map_countryCode-change-Log-update] 
	on [dbo].[map_countryCode] 
	after update 
	as 
	BEGIN
		insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_countryCode', 'OLD => ' + isNULL(Deleted.country,'') + ' //' + isNULL(Deleted.[ISO-2],'') + ' //' + isNULL(Deleted.[ISO-3],'') + ' //' + isNULL(Deleted.Assignment,'')+ ' //' + 
		convert(varchar,isNULL(Deleted.numeric,'')), 'Updated', user_name(), getdate() from inserted, deleted where inserted.id = deleted.ID;
		
		insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_countryCode', 'NEW => ' + isNULL(inserted.country,'') + ' //' + isNULL(inserted.[ISO-2],'') + ' //' + isNULL(inserted.[ISO-3],'') + ' //' + isNULL(inserted.Assignment,'')+ ' //' + 
		convert(varchar,isNULL(inserted.numeric,'')), 'Updated', user_name(), getdate() from inserted, deleted where inserted.id = deleted.ID;
		
		update [dbo].map_countryCode set [dbo].map_countryCode.[TimeStamp] = getdate(), [dbo].map_countryCode.[User] = user_name () 
		from [dbo].map_countryCode inner join inserted as i on [dbo].map_countryCode.ID = i.ID 
	END

GO



CREATE trigger [dbo].[map_countryCode-change-Log-insert] 
	on [dbo].[map_countryCode]
	after insert 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
	select 'map_countryCode', isNULL(inserted.country,'') + ' //' + isNULL(inserted.[ISO-2],'') + ' //' + isNULL(inserted.[ISO-3],'') + ' //' + isNULL(inserted.Assignment,'')+ ' //' + convert(varchar,isNULL(inserted.numeric,'')), 'Inserted', user_name(), getdate() from inserted;

GO


CREATE trigger [dbo].[map_countryCode-change-Log-delete] 
	on [dbo].[map_countryCode] 
	after delete 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
	select	'map_countryCode', isNULL(Deleted.country,'') + ' //' + isNULL(Deleted.[ISO-2],'') + ' //' + isNULL(Deleted.[ISO-3],'') + ' //' + isNULL(Deleted.Assignment,'')+ ' //' + convert(varchar,isNULL(Deleted.numeric,'')), 'Deleted', user_name(), getdate() from deleted;

GO

