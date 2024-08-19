CREATE TABLE [dbo].[map_UOM_conversion] (
    [UNIT_FROM] VARCHAR (50) NOT NULL,
    [UNIT_TO]   VARCHAR (50) NULL,
    [CONV]      FLOAT (53)   NULL,
    [XCOMMENT]  VARCHAR (50) NULL,
    [ID]        INT          IDENTITY (1, 1) NOT NULL,
    [TimeStamp] DATETIME     CONSTRAINT [DF_map_UOM_conversion_TimeStamp] DEFAULT (getdate()) NULL,
    [User]      VARCHAR (50) CONSTRAINT [DF_map_UOM_conversion_User] DEFAULT (user_name()) NULL,
    CONSTRAINT [pk_map_UOM_conversion] PRIMARY KEY CLUSTERED ([UNIT_FROM] ASC)
);


GO






CREATE trigger [dbo].[map_UOM_conversion-change-Log-delete] 
	on [dbo].[map_UOM_conversion] 
	after delete 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_UOM_conversion', convert(varchar,deleted.CONV) + ' //' + isNULL(deleted.UNIT_FROM,'') + ' //' + 	isNULL(deleted.UNIT_TO,'') + ' //' + isNULL(deleted.XCOMMENT,'') , 'Deleted', user_name(), getdate() from deleted;

GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE trigger [dbo].[map_UOM_conversion-change-Log-update] 
	on [dbo].[map_UOM_conversion] 
	after update 
	as 
	BEGIN
		insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_UOM_conversion', 'OLD => ' + convert(varchar,deleted.CONV) + ' //' + isNULL(deleted.UNIT_FROM,'') + ' //' + isNULL(deleted.UNIT_TO,'') + ' //' + isNULL(deleted.XCOMMENT,'')
		, 'Updated', user_name(), getdate() from inserted, deleted where inserted.id = deleted.ID;
	
	insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_UOM_conversion', 'NEW => ' + convert(varchar,inserted.CONV) + ' //' + isNULL(inserted.UNIT_FROM ,'') + ' //' + isNULL(inserted.UNIT_TO,'') + ' //' + isNULL(inserted.XCOMMENT,'')
		, 'Updated', user_name(), getdate() from inserted, deleted where inserted.id = deleted.ID;
	
	update [dbo].[map_UOM_conversion] set [dbo].[map_UOM_conversion].[TimeStamp] = getdate(), [dbo].[map_UOM_conversion].[User] = user_name () 
		from [dbo].[map_UOM_conversion] inner join inserted as i on [dbo].[map_UOM_conversion].ID = i.ID 
	END

GO







CREATE trigger [dbo].[map_UOM_conversion-change-Log-insert] 
	on [dbo].[map_UOM_conversion]
	after insert 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_UOM_conversion', 
		convert(varchar,inserted.CONV) + ' //' + inserted.UNIT_FROM + ' //' + isNULL(inserted.UNIT_TO,'') + ' //' + isNULL(inserted.XCOMMENT,'')
		, 'Inserted', user_name(), getdate() from inserted;

GO

