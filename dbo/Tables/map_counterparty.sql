CREATE TABLE [dbo].[map_counterparty] (
    [ID]               INT            IDENTITY (1, 1) NOT NULL,
    [ExtBunit]         VARCHAR (70)   NOT NULL,
    [ExtLegalEntity]   VARCHAR (70)   NULL,
    [Partner]          VARCHAR (255)  NULL,
    [Debitor]          VARCHAR (255)  NULL,
    [Country]          VARCHAR (255)  NULL,
    [ctpygroup]        VARCHAR (255)  NULL,
    [AccrualOnDebitor] BIT            NOT NULL,
    [Exchange]         BIT            NOT NULL,
    [UStID]            VARCHAR (255)  NULL,
    [CtpyID_Endur]     VARCHAR (10)   NULL,
    [TimeStamp]        DATETIME       CONSTRAINT [DF_map_counterparty_TimeStamp] DEFAULT (getdate()) NULL,
    [User]             VARCHAR (50)   CONSTRAINT [DF_map_counterparty_USER] DEFAULT (user_name()) NULL,
    [LegalEntity]      NVARCHAR (255) NULL,
    [CompanyCode]      NVARCHAR (4)   NULL,
    CONSTRAINT [PK_map_counterparty] PRIMARY KEY CLUSTERED ([ExtBunit] ASC)
);


GO



/*CREATE trigger [dbo].[map_counterparty-change-Log-insert] 
	on [dbo].[map_counterparty]
	after insert 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
	select 'map_counterparty', isNULL(inserted.ExtBunit,'') + ' //' + isNULL(inserted.ExtLegalEntity,'') + ' //' + isNULL(inserted.Partner,'') + ' //' + isNULL(inserted.Debitor,'') + ' //' + 
	isNULL(inserted.Country,'') + ' //' + isNULL(inserted.ctpygroup,'') + ' //' + convert(varchar,isNULL(inserted.AccrualOnDebitor,'')) + ' //' + convert(varchar,isNULL(inserted.Exchange,'')) + ' //' + isNULL(inserted.UStID,'')
	 + ' //' + isNULL(inserted.CtpyID_Endur,''), 'Inserted', user_name(), getdate() from inserted;*/

/*CREATE trigger [dbo].[map_counterparty-change-Log-delete] 
	on [dbo].[map_counterparty] 
	after delete 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
	select	'map_counterparty', isNULL(Deleted.ExtBunit,'') + ' //' + isNULL(Deleted.ExtLegalEntity,'') + ' //' + isNULL(Deleted.Partner,'') + ' //' + isNULL(Deleted.Debitor,'') + ' //' + 
	isNULL(Deleted.Country,'') + ' //' + isNULL(Deleted.ctpygroup,'') + ' //' + convert(varchar,isNULL(Deleted.AccrualOnDebitor,'')) + ' //' + convert(varchar,isNULL(Deleted.Exchange,'')) + ' //' + isNULL(Deleted.UStID,'')
	 + ' //' + isNULL(Deleted.CtpyID_Endur,''), 'Deleted', user_name(), getdate() from deleted;*/

CREATE trigger [dbo].[map_counterparty-change-Log-update] 
	on [dbo].[map_counterparty] 
	after update 
	as 
	BEGIN
	
	insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_counterparty', 'OLD => ' + isNULL(Deleted.ExtBunit,'') + ' //' + isNULL(Deleted.ExtLegalEntity,'') + ' //' + isNULL(Deleted.Partner,'') + ' //' + isNULL(Deleted.Debitor,'') + ' //' + 
	isNULL(Deleted.Country,'') + ' //' + isNULL(Deleted.ctpygroup,'') + ' //' + convert(varchar,isNULL(Deleted.AccrualOnDebitor,'')) + ' //' + convert(varchar,isNULL(Deleted.Exchange,'')) + ' //' + isNULL(Deleted.UStID,'')
	 + ' //' + isNULL(Deleted.CtpyID_Endur,''), 'Updated', user_name(), getdate() from inserted, deleted where inserted.id = deleted.ID;
	
	insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_counterparty', 'NEW => ' + isNULL(inserted.ExtBunit,'') + ' //' + isNULL(inserted.ExtLegalEntity,'') + ' //' + isNULL(inserted.Partner,'') + ' //' + isNULL(inserted.Debitor,'') + ' //' + 
	isNULL(inserted.Country,'') + ' //' + isNULL(inserted.ctpygroup,'') + ' //' + convert(varchar,isNULL(inserted.AccrualOnDebitor,'')) + ' //' + convert(varchar,isNULL(inserted.Exchange,'')) + ' //' + isNULL(inserted.UStID,'')
	 + ' //' + isNULL(inserted.CtpyID_Endur,''), 'Updated', user_name(), getdate() from inserted, deleted where inserted.id = deleted.ID;
	
	update [dbo].map_counterparty set [dbo].map_counterparty.[TimeStamp] = getdate(), [dbo].map_counterparty.[User] = user_name () 
		from [dbo].map_counterparty inner join inserted as i on [dbo].map_counterparty.ID = i.ID 
	END

GO



CREATE trigger [dbo].[map_counterparty-change-Log-insert] 
	on [dbo].[map_counterparty]
	after insert 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
	select 'map_counterparty', isNULL(inserted.ExtBunit,'') + ' //' + isNULL(inserted.ExtLegalEntity,'') + ' //' + isNULL(inserted.Partner,'') + ' //' + isNULL(inserted.Debitor,'') + ' //' + 
	isNULL(inserted.Country,'') + ' //' + isNULL(inserted.ctpygroup,'') + ' //' + convert(varchar,isNULL(inserted.AccrualOnDebitor,'')) + ' //' + convert(varchar,isNULL(inserted.Exchange,'')) + ' //' + isNULL(inserted.UStID,'')
	 + ' //' + isNULL(inserted.CtpyID_Endur,''), 'Inserted', user_name(), getdate() from inserted;


/*CREATE trigger [dbo].[map_countryCode-change-Log-delete] 
	on [dbo].[map_countryCode] 
	after delete 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
	select	'map_countryCode', isNULL(Deleted.country,'') + ' //' + isNULL(Deleted.[ISO-2],'') + ' //' + isNULL(Deleted.[ISO-3],'') + ' //' + isNULL(Deleted.Assignment,'')+ ' //' + 
	convert(varchar,isNULL(Deleted.numeric,'')), 'Deleted', user_name(), getdate() from deleted;*/

/*CREATE trigger [dbo].[map_countryCode-change-Log-update] 
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
	END*/

GO



/*CREATE trigger [dbo].[map_counterparty-change-Log-insert] 
	on [dbo].[map_counterparty]
	after insert 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
	select 'map_counterparty', isNULL(inserted.ExtBunit,'') + ' //' + isNULL(inserted.ExtLegalEntity,'') + ' //' + isNULL(inserted.Partner,'') + ' //' + isNULL(inserted.Debitor,'') + ' //' + 
	isNULL(inserted.Country,'') + ' //' + isNULL(inserted.ctpygroup,'') + ' //' + convert(varchar,isNULL(inserted.AccrualOnDebitor,'')) + ' //' + convert(varchar,isNULL(inserted.Exchange,'')) + ' //' + isNULL(inserted.UStID,'')
	 + ' //' + isNULL(inserted.CtpyID_Endur,''), 'Inserted', user_name(), getdate() from inserted;*/

CREATE trigger [dbo].[map_counterparty-change-Log-delete] 
	on [dbo].[map_counterparty] 
	after delete 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
	select	'map_counterparty', isNULL(Deleted.ExtBunit,'') + ' //' + isNULL(Deleted.ExtLegalEntity,'') + ' //' + isNULL(Deleted.Partner,'') + ' //' + isNULL(Deleted.Debitor,'') + ' //' + 
	isNULL(Deleted.Country,'') + ' //' + isNULL(Deleted.ctpygroup,'') + ' //' + convert(varchar,isNULL(Deleted.AccrualOnDebitor,'')) + ' //' + convert(varchar,isNULL(Deleted.Exchange,'')) + ' //' + isNULL(Deleted.UStID,'')
	 + ' //' + isNULL(Deleted.CtpyID_Endur,''), 'Deleted', user_name(), getdate() from deleted;

/*CREATE trigger [dbo].[map_countryCode-change-Log-update] 
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
	END*/

GO

