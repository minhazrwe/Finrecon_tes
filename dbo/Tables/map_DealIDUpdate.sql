CREATE TABLE [dbo].[map_DealIDUpdate] (
    [ID]         INT           IDENTITY (1, 1) NOT NULL,
    [DealID_Old] VARCHAR (255) NOT NULL,
    [DealID_New] VARCHAR (255) NOT NULL,
    [comment]    VARCHAR (255) NOT NULL,
    [TimeStamp]  DATETIME      CONSTRAINT [DF_map_DealIDUpdate_TimeStamp] DEFAULT (getdate()) NULL,
    [USER]       VARCHAR (50)  CONSTRAINT [DF_map_DealIDUpdate_USER] DEFAULT (user_name()) NULL,
    CONSTRAINT [PK_map_DealIDUpdate] PRIMARY KEY CLUSTERED ([DealID_Old] ASC)
);


GO



CREATE trigger [dbo].[map_DealIDUpdate-change-Log-insert] 
	on [dbo].[map_DealIDUpdate]
	after insert 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_DealIDUpdate', isNULL(inserted.DealID_Old,'') + ' //' + isNULL(inserted.DealID_New,'') + ' //' + isNULL(inserted.comment,''), 'Inserted', user_name(), getdate() from inserted;

GO



/*CREATE trigger [dbo].[map_DealIDUpdate-change-Log-insert] 
	on [dbo].[map_DealIDUpdate]
	after insert 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_DealIDUpdate', isNULL(inserted.DealID_Old,'') + ' //' + isNULL(inserted.DealID_New,'') + ' //' + isNULL(inserted.comment,''), 'Inserted', user_name(), getdate() from inserted;*/

CREATE trigger [dbo].[map_DealIDUpdate-change-Log-delete] 
	on [dbo].[map_DealIDUpdate] 
	after delete 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_DealIDUpdate', isNULL(Deleted.DealID_Old,'') + ' //' + isNULL(Deleted.DealID_New,'') + ' //' + isNULL(Deleted.comment,''), 'Deleted', user_name(), getdate() from deleted;

/*CREATE trigger [dbo].[map_deliveryMonth-change-Log-update] 
	on [dbo].[map_deliveryMonth] 
	after update 
	as 
	BEGIN
		insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_deliveryMonth', 'OLD => ' + isNULL(deleted.DeliveryMonth,'') + ' //' + isNULL(deleted.DeliveryMonthNew,'') + ' //' + 
			convert(varchar,isNULL(deleted.MonthNum,'')) + ' //' + convert(varchar,isNULL(deleted.AsOfDate,'')), 'Updated', user_name(), getdate() from inserted, deleted where inserted.id = deleted.ID;
		insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_deliveryMonth', 'NEW => ' + isNULL(inserted.DeliveryMonth,'') + ' //' + isNULL(inserted.DeliveryMonthNew,'') + ' //' + 
			convert(varchar,isNULL(inserted.MonthNum,'')) + ' //' + convert(varchar,isNULL(inserted.AsOfDate,'')), 'Updated', user_name(), getdate() from inserted, deleted where inserted.id = deleted.ID;
		update [dbo].map_deliveryMonth set [dbo].map_deliveryMonth.[TimeStamp] = getdate(), [dbo].map_deliveryMonth.[User] = user_name () 
		from [dbo].map_deliveryMonth inner join inserted as i on [dbo].map_deliveryMonth.ID = i.ID 
	END*/

GO



/*CREATE trigger [dbo].[map_DealIDUpdate-change-Log-insert] 
	on [dbo].[map_DealIDUpdate]
	after insert 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_DealIDUpdate', isNULL(inserted.DealID_Old,'') + ' //' + isNULL(inserted.DealID_New,'') + ' //' + isNULL(inserted.comment,''), 'Inserted', user_name(), getdate() from inserted;*/

/*CREATE trigger [dbo].[map_DealIDUpdate-change-Log-delete] 
	on [dbo].[map_DealIDUpdate] 
	after delete 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_DealIDUpdate', isNULL(Deleted.DealID_Old,'') + ' //' + isNULL(Deleted.DealID_New,'') + ' //' + isNULL(Deleted.comment,''), 'Deleted', user_name(), getdate() from deleted;*/

CREATE trigger [dbo].[map_DealIDUpdate-change-Log-update] 
	on [dbo].[map_DealIDUpdate] 
	after update 
	as 
	BEGIN
		insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_DealIDUpdate', 'OLD => ' + isNULL(Deleted.DealID_Old,'') + ' //' + isNULL(Deleted.DealID_New,'') + ' //' + isNULL(Deleted.comment,''), 'Updated', user_name(), getdate() from inserted, deleted where inserted.id = deleted.ID;
		
		insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_DealIDUpdate', 'NEW => ' + isNULL(inserted.DealID_Old,'') + ' //' + isNULL(inserted.DealID_New,'') + ' //' + isNULL(inserted.comment,''), 'Updated', user_name(), getdate() from inserted, deleted where inserted.id = deleted.ID;
		
		update [dbo].map_DealIDUpdate set [dbo].map_DealIDUpdate.[TimeStamp] = getdate(), [dbo].map_DealIDUpdate.[User] = user_name () 
		from [dbo].map_DealIDUpdate inner join inserted as i on [dbo].map_DealIDUpdate.ID = i.ID 
	END

GO

