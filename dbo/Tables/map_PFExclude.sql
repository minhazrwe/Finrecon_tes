CREATE TABLE [dbo].[map_PFExclude] (
    [ID]                INT           IDENTITY (1, 1) NOT NULL,
    [InternalPortfolio] VARCHAR (255) NOT NULL,
    [COMMENT]           VARCHAR (255) NULL,
    [LastUpdate]        DATETIME      CONSTRAINT [DF_map_PFExclude_LastUpdate] DEFAULT (getdate()) NULL,
    [Username]          VARCHAR (50)  CONSTRAINT [DF_map_PFExclude_Username] DEFAULT (user_name()) NULL,
    CONSTRAINT [pk_map_PFExclude] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create trigger [dbo].[trigger_map_PFExclude_AfterUpdate] 
	on [dbo].[map_PFExclude] 
	after update 
	as 
	BEGIN
		
		insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_PFExclude', 'OLD => ' + isNULL(deleted.InternalPortfolio,'') + ' //' + isNULL(deleted.COMMENT,'') , 'Deleted', user_name(), getdate() from inserted, deleted where inserted.id = deleted.ID;
		
		insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_PFExclude', 'NEW => ' + isNULL(inserted.InternalPortfolio,'') + ' //' + isNULL(inserted.COMMENT,''), 'Updated', user_name(), getdate() from inserted, deleted where inserted.id = deleted.ID;
		
		update [dbo].[map_PFExclude] set [dbo].[map_PFExclude].[LastUpdate] = getdate(), [dbo].[map_PFExclude].[Username] = user_name () 
		from [dbo].[map_PFExclude] inner join inserted as i on [dbo].[map_PFExclude].ID = i.ID 
	END

GO


create trigger [dbo].[trigger_map_PFExclude_AfterDelete] 
	on [dbo].[map_PFExclude] 
	after delete 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_PFExclude', isNULL(InternalPortfolio,'') + ' //' + isNULL(COMMENT,''), 'Deleted', user_name(), getdate() from deleted;

GO







create trigger [dbo].[trigger_map_PFExclude_AfterInsert] 
	on [dbo].[map_PFExclude] 
	after insert 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_PFExclude', isNULL(InternalPortfolio,'') + ' //' + isNULL(COMMENT,''), 'Inserted', user_name(), getdate() from inserted;

GO

