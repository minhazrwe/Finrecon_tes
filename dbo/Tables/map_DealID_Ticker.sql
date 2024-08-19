CREATE TABLE [dbo].[map_DealID_Ticker] (
    [DealID]             VARCHAR (100) NOT NULL,
    [InstrumentTypeName] VARCHAR (100) NOT NULL,
    [Ticker]             VARCHAR (100) NOT NULL,
    [User]               VARCHAR (255) CONSTRAINT [DF_map_Product_user] DEFAULT (user_name()) NOT NULL,
    [TimeStamp]          DATETIME      CONSTRAINT [DF_map_Product_TimeStamp] DEFAULT (getdate()) NOT NULL,
    [ID]                 INT           IDENTITY (1, 1) NOT NULL,
    [DeliveryMonth]      VARCHAR (7)   NULL,
    CONSTRAINT [PK_map_Product_1] PRIMARY KEY CLUSTERED ([DealID] ASC)
);


GO



/*CREATE trigger [dbo].[map_DealID_Ticker-change-Log-insert] 
	on [dbo].[map_DealID_Ticker]
	after insert 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_DealID_Ticker', isNULL(inserted.DealID,'') + ' //' + isNULL(inserted.InstrumentTypeName,'') + ' //' + isNULL(inserted.Ticker,''), 'Inserted', user_name(), getdate() from inserted;*/

CREATE trigger [dbo].[map_DealID_Ticker-change-Log-delete] 
	on [dbo].[map_DealID_Ticker] 
	after delete 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_DealID_Ticker', isNULL(Deleted.DealID,'') + ' //' + isNULL(Deleted.InstrumentTypeName,'') + ' //' + isNULL(Deleted.Ticker,''), 'Deleted', user_name(), getdate() from deleted;

/*CREATE trigger [dbo].[map_DealIDUpdate-change-Log-update] 
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
	END*/

GO



CREATE trigger [dbo].[map_DealID_Ticker-change-Log-insert] 
	on [dbo].[map_DealID_Ticker]
	after insert 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_DealID_Ticker', isNULL(inserted.DealID,'') + ' //' + isNULL(inserted.InstrumentTypeName,'') + ' //' + isNULL(inserted.Ticker,''), 'Inserted', user_name(), getdate() from inserted;

/*CREATE trigger [dbo].[map_DealIDUpdate-change-Log-delete] 
	on [dbo].[map_DealIDUpdate] 
	after delete 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_DealIDUpdate', isNULL(Deleted.DealID_Old,'') + ' //' + isNULL(Deleted.DealID_New,'') + ' //' + isNULL(Deleted.comment,''), 'Deleted', user_name(), getdate() from deleted;*/

/*CREATE trigger [dbo].[map_DealIDUpdate-change-Log-update] 
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
	END*/

GO


CREATE trigger [dbo].[map_DealID_Ticker-change-Log-update] 
	on [dbo].[map_DealID_Ticker] 
	after update 
	as 
	BEGIN
		insert into dbo.[Change-Log] 
		(
			[Change-Table]
			,[Change-Entry]
			,[Change-Type]
			,[Change-User]
			,[Change-Datetime]
		) 
		select	
			'map_DealID_Ticker'
			, 'OLD => ' + isNULL(Deleted.DealID,'') + ' //' 
				+ isNULL(Deleted.InstrumentTypeName,'') + ' //' 
				+ isNULL(Deleted.Ticker,'')
			, 'Updated'
			, user_name()
			, getdate() 
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
			,[Change-User]
			,[Change-Datetime]
		) 
		select	
			'map_DealID_Ticker'
			, 'NEW => ' + isNULL(inserted.DealID,'') + ' //' 
				+ isNULL(inserted.InstrumentTypeName,'') + ' //' 
				+ isNULL(inserted.Ticker,'')
			, 'Updated'
			, user_name()
			, getdate() 
		from 
			inserted
			,deleted 
		where 
			inserted.id = deleted.ID;
		
		update [dbo].map_DealID_Ticker set 
			[dbo].map_DealID_Ticker.[TimeStamp] = getdate()
			,[dbo].map_DealID_Ticker.[User] = user_name () 
		from 
			[dbo].map_DealID_Ticker 
			inner join inserted as i on [dbo].map_DealID_Ticker.ID = i.ID 
	END

GO

