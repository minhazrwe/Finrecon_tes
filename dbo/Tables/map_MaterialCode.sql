CREATE TABLE [dbo].[map_MaterialCode] (
    [ID]                  INT           IDENTITY (1, 1) NOT NULL,
    [Material]            VARCHAR (255) NOT NULL,
    [MaterialDescription] VARCHAR (255) NULL,
    [TimeStamp]           DATETIME      CONSTRAINT [DF_map_MaterialCode_TimeStamp] DEFAULT (getdate()) NULL,
    [User]                VARCHAR (50)  CONSTRAINT [DF_map_MaterialCode_User] DEFAULT (user_name()) NULL,
    CONSTRAINT [pk_map_MaterialCode] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE trigger [dbo].[map_MaterialCode-Log-update] 
	on [dbo].[map_MaterialCode] 
	after update 
	as 
	BEGIN
		insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_MaterialCode', 'OLD => ' + isNULL(deleted.Material,'') + ' //' + isNULL(deleted.MaterialDescription,'') , 'Deleted', user_name(), getdate() from inserted, deleted where inserted.id = deleted.ID;
		
		insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_MaterialCode', 'NEW => ' + isNULL(inserted.Material,'') + ' //' + isNULL(inserted.MaterialDescription,''), 'Updated', user_name(), getdate() from inserted, deleted where inserted.id = deleted.ID;
		
		update [dbo].[map_MaterialCode] set [dbo].[map_MaterialCode].[TimeStamp] = getdate(), [dbo].[map_MaterialCode].[User] = user_name () 
		from [dbo].[map_MaterialCode] inner join inserted as i on [dbo].[map_MaterialCode].ID = i.ID 
	END

GO






create trigger [dbo].[map_Material-change-Log-delete] 
	on [dbo].[map_MaterialCode] 
	after delete 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_MaterialCode', isNULL(Material,'') + ' //' + isNULL(MaterialDescription,''), 'Deleted', user_name(), getdate() from deleted;

GO






create trigger [dbo].[map_Material-change-Log-Insert] 
	on [dbo].[map_MaterialCode] 
	after insert 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_MaterialCode', isNULL(Material,'') + ' //' + isNULL(MaterialDescription,''), 'Inserted', user_name(), getdate() from inserted;

GO

