CREATE TABLE [dbo].[map_VAT] (
    [ID]              INT           IDENTITY (1, 1) NOT NULL,
    [ctpygroup]       VARCHAR (255) NOT NULL,
    [VAT_Group]       VARCHAR (255) NOT NULL,
    [VAT_CountryCode] VARCHAR (255) NOT NULL,
    [Buys]            VARCHAR (255) NULL,
    [Sells]           VARCHAR (255) NULL,
    [TimeStamp]       DATETIME      CONSTRAINT [DF_map_VAT_TimeStamp] DEFAULT (getdate()) NULL,
    [User]            VARCHAR (50)  CONSTRAINT [DF_map_VAT_User] DEFAULT (user_name()) NULL,
    CONSTRAINT [PK_VAT] PRIMARY KEY CLUSTERED ([ctpygroup] ASC, [VAT_Group] ASC, [VAT_CountryCode] ASC)
);


GO







CREATE trigger [dbo].[map_VAT-change-Log-insert] 
	on [dbo].[map_VAT]
	after insert 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_VAT', isNULL(inserted.Buys,'') + ' //' + isNULL(inserted.ctpygroup,'') + ' //' + 
		isNULL(inserted.Sells,'') + ' //' + isNULL(inserted.VAT_CountryCode,'') + ' //' + isNULL(inserted.VAT_Group,''), 'Inserted', user_name(), getdate() from inserted;

GO






create trigger [dbo].[map_VAT-change-Log-delete] 
	on [dbo].[map_VAT] 
	after delete 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_VAT', isNULL(deleted.ctpygroup,'') + ' //' + isNULL(deleted.Buys,'') + ' //' + 
		isNULL(deleted.Sells,'') + ' //' + isNULL(deleted.VAT_CountryCode,'') + ' //' + isNULL(deleted.VAT_Group,'') , 'Deleted', user_name(), getdate() from deleted;

GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE trigger [dbo].[map_VAT-change-Log-update] 
	on [dbo].[map_VAT] 
	after update 
	as 
	BEGIN
		insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_VAT', 'OLD => ' + isNULL(deleted.ctpygroup,'') + ' //' + isNULL(deleted.Buys,'') + ' //' + 
		isNULL(deleted.Sells,'') + ' //' + isNULL(deleted.VAT_CountryCode,'') + ' //' + isNULL(deleted.VAT_Group,'') , 'Deleted', user_name(), getdate() from inserted, deleted where inserted.id = deleted.ID;
		
		insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_VAT', 'NEW => ' + isNULL(inserted.Buys,'') + ' //' + isNULL(inserted.ctpygroup,'') + ' //' + 
		isNULL(inserted.Sells,'') + ' //' + isNULL(inserted.VAT_CountryCode,'') + ' //' + isNULL(inserted.VAT_Group,''), 'Updated', user_name(), getdate() from inserted, deleted where inserted.id = deleted.ID;
		
		update [dbo].[map_VAT] set [dbo].[map_VAT].[TimeStamp] = getdate(), [dbo].[map_VAT].[User] = user_name () 
		from [dbo].[map_VAT] inner join inserted as i on [dbo].[map_VAT].ID = i.ID 
	END

GO

