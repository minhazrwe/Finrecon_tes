CREATE TABLE [dbo].[map_deliveryMonth] (
    [ID]               INT          IDENTITY (1, 1) NOT NULL,
    [DeliveryMonth]    VARCHAR (50) NOT NULL,
    [DeliveryMonthNew] VARCHAR (50) NULL,
    [MonthNum]         INT          NULL,
    [AsOfDate]         DATETIME     NULL,
    [TimeStamp]        DATETIME     CONSTRAINT [DF_map_deliveryMonth_TimeStamp] DEFAULT (getdate()) NULL,
    [USER]             VARCHAR (50) CONSTRAINT [DF_map_deliveryMonth_USER] DEFAULT (user_name()) NULL,
    CONSTRAINT [pk_map_deliveryMonth] PRIMARY KEY CLUSTERED ([DeliveryMonth] ASC)
);


GO



CREATE trigger [dbo].[map_deliveryMonth-change-Log-update] 
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
	END

GO



CREATE trigger [dbo].[map_deliveryMonth-change-Log-insert] 
	on [dbo].[map_deliveryMonth]
	after insert 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_deliveryMonth', isNULL(inserted.DeliveryMonth,'') + ' //' + isNULL(inserted.DeliveryMonthNew,'') + ' //' + 
			convert(varchar,isNULL(inserted.MonthNum,'')) + ' //' + convert(varchar,isNULL(inserted.AsOfDate,'')), 'Inserted', user_name(), getdate() from inserted;

GO



/*CREATE trigger [dbo].[map_deliveryMonth-change-Log-insert] 
	on [dbo].[map_deliveryMonth]
	after insert 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_deliveryMonth', isNULL(inserted.DeliveryMonth,'') + ' //' + isNULL(inserted.DeliveryMonthNew,'') + ' //' + 
			convert(varchar,isNULL(inserted.MonthNum,'')) + ' //' + convert(varchar,isNULL(inserted.AsOfDate,'')), 'Inserted', user_name(), getdate() from inserted;*/

CREATE trigger [dbo].[map_deliveryMonth-change-Log-delete] 
	on [dbo].[map_deliveryMonth] 
	after delete 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_deliveryMonth', isNULL(deleted.DeliveryMonth,'') + ' //' + isNULL(deleted.DeliveryMonthNew,'') + ' //' + 
			convert(varchar,isNULL(deleted.MonthNum,'')) + ' //' + convert(varchar,isNULL(deleted.AsOfDate,'')), 'Deleted', user_name(), getdate() from deleted;

/*CREATE trigger [dbo].[map_ExtLegal_Account-change-Log-update] 
	on [dbo].[map_ExtLegal_Account] 
	after update 
	as 
	BEGIN
		insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_ExtLegal_Account', 'OLD => ' + isNULL(deleted.ExtLegal,'') + ' //' + isNULL(deleted.InstrumentType,'') + ' //' + 
			isNULL(deleted.Account_new,'') + ' //' + isNULL(deleted.Account_old,'') + ' //' +isNULL(deleted.[comment],''), 'Updated', user_name(), getdate() from inserted, deleted where inserted.id = deleted.ID;
		insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_ExtLegal_Account', 'NEW => ' + isNULL(inserted.ExtLegal,'') + ' //' + isNULL(inserted.InstrumentType,'') + ' //' + 
			isNULL(inserted.Account_new,'') + ' //' + isNULL(inserted.Account_old,'') + ' //' +isNULL(inserted.[comment],''), 'Updated', user_name(), getdate() from inserted, deleted where inserted.id = deleted.ID;
		update [dbo].map_ExtLegal_Account set [dbo].map_ExtLegal_Account.[TimeStamp] = getdate(), [dbo].map_ExtLegal_Account.[User] = user_name () 
		from [dbo].map_ExtLegal_Account inner join inserted as i on [dbo].map_ExtLegal_Account.ID = i.ID 
	END*/

GO

