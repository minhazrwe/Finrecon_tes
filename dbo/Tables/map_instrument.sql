CREATE TABLE [dbo].[map_instrument] (
    [ID]              INT           IDENTITY (1, 1) NOT NULL,
    [InstrumentType]  VARCHAR (50)  NOT NULL,
    [InstrumentGroup] VARCHAR (50)  NULL,
    [NonValueAdded]   BIT           NULL,
    [comment]         VARCHAR (255) NULL,
    [TimeStamp]       DATETIME      CONSTRAINT [DF_map_instrument_TimeStamp] DEFAULT (getdate()) NULL,
    [USER]            VARCHAR (50)  CONSTRAINT [DF_map_instrument_USER] DEFAULT (user_name()) NULL,
    CONSTRAINT [pk_map_instrument] PRIMARY KEY CLUSTERED ([InstrumentType] ASC)
);


GO



CREATE trigger [dbo].[map_instrument-change-Log-update] 
	on [dbo].[map_instrument] 
	after update 
	as 
	BEGIN
		insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_instrument', 'NEW => ' + isNULL(inserted.[InstrumentType],'') + ' //' + isNULL(inserted.[InstrumentGroup],'') + ' //' + 
			convert(varchar,isNULL(inserted.[NonValueAdded],'')) + ' //' + isNULL(inserted.[comment],''), 'Updated', user_name(), getdate() from inserted, deleted where inserted.id = deleted.ID;
	
	insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_instrument', 'OLD => ' + isNULL(deleted.[InstrumentType],'') + ' //' + isNULL(deleted.[InstrumentGroup],'') + ' //' + 
			convert(varchar,isNULL(deleted.[NonValueAdded],'')) + ' //' + isNULL(deleted.[comment],''), 'Updated', user_name(), getdate() from inserted, deleted where inserted.id = deleted.ID;
	
	update [dbo].[map_instrument] set [dbo].[map_instrument].[TimeStamp] = getdate(), [dbo].[map_instrument].[User] = user_name () 
		from [dbo].[map_instrument] inner join inserted as i on [dbo].[map_instrument].ID = i.ID 
	END

GO


/*CREATE trigger [dbo].[map_instrument-change-Log-insert] 
	on [dbo].[map_instrument]
	after insert 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_instrument', isNULL(inserted.[InstrumentType],'') + ' //' + isNULL(inserted.[InstrumentGroup],'') + ' //' + 
			convert(varchar,isNULL(inserted.[NonValueAdded],'')) + ' //' + isNULL(inserted.[comment],''), 'Inserted', user_name(), getdate() from inserted; */

CREATE trigger [dbo].[map_instrument-change-Log-delete] 
	on [dbo].[map_instrument] 
	after delete 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_instrument', isNULL(deleted.[InstrumentType],'') + ' //' + isNULL(deleted.[InstrumentGroup],'') + ' //' + 
			convert(varchar,isNULL(deleted.[NonValueAdded],'')) + ' //' + isNULL(deleted.[comment],''), 'Deleted', user_name(), getdate() from deleted;

/*CREATE trigger [dbo].[map_order-change-Log-update] 
	on [dbo].[map_order] 
	after update 
	as 
	BEGIN
		insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_order', 'OLD => ' + isNULL(deleted.[System],'') + ' //' + isNULL(deleted.[LegalEntity],'') + ' //' + isNULL(deleted.[Desk],'') + ' //' + isNULL(deleted.[SubDesk],'') + ' //' + isNULL(deleted.[Book],'') + ' //' + 
		isNULL(deleted.[Portfolio],'') + ' //' + isNULL(deleted.[PortfolioID],'') + ' //' + isNULL(deleted.[OrderNo],'') + ' //' + isNULL(deleted.[Ref3],'') + ' //' +
		isNULL(deleted.[ProfitCenter],'') + ' //' +		isNULL(deleted.[SubDeskCCY],'') + ' //' +	isNULL(deleted.[CommodityForFX],'') + ' //' +
		isNULL(deleted.[Comment],''), 'Updated', user_name(), getdate() from inserted, deleted where inserted.id = deleted.ID;
		insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_order', 'NEW => ' + isNULL(inserted.[System],'') + ' //' + isNULL(inserted.[LegalEntity],'') + ' //' + isNULL(inserted.[Desk],'') + ' //' + isNULL(inserted.[SubDesk],'') + ' //' + isNULL(inserted.[Book],'') + ' //' + 
		isNULL(inserted.[Portfolio],'') + ' //' + isNULL(inserted.[PortfolioID],'') + ' //' + isNULL(inserted.[OrderNo],'') + ' //' + isNULL(inserted.[Ref3],'') + ' //' +
		isNULL(inserted.[ProfitCenter],'') + ' //' +		isNULL(inserted.[SubDeskCCY],'') + ' //' +	isNULL(inserted.[CommodityForFX],'') + ' //' +
		isNULL(inserted.[Comment],''), 'Updated', user_name(), getdate() from inserted, deleted where inserted.id = deleted.ID;
		update [dbo].[map_order] set [dbo].[map_order].[TimeStamp] = getdate(), [dbo].[map_order].[User] = user_name () 
		from [dbo].[map_order] inner join inserted as i on [dbo].[map_order].ID = i.ID 
	END */

GO


CREATE trigger [dbo].[map_instrument-change-Log-insert] 
	on [dbo].[map_instrument]
	after insert 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_instrument', isNULL(inserted.[InstrumentType],'') + ' //' + isNULL(inserted.[InstrumentGroup],'') + ' //' + 
			convert(varchar,isNULL(inserted.[NonValueAdded],'')) + ' //' + isNULL(inserted.[comment],''), 'Inserted', user_name(), getdate() from inserted;

GO

