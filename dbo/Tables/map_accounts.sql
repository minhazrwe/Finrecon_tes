CREATE TABLE [dbo].[map_accounts] (
    [ID]             INT           IDENTITY (1, 1) NOT NULL,
    [Desk]           VARCHAR (50)  NOT NULL,
    [CtpyGroup]      VARCHAR (25)  NOT NULL,
    [InstrumentType] VARCHAR (40)  NOT NULL,
    [Commodity]      VARCHAR (25)  NOT NULL,
    [CashflowType]   VARCHAR (40)  NOT NULL,
    [Account_Loss]   VARCHAR (25)  NULL,
    [Account_Profit] VARCHAR (25)  NULL,
    [VAT_Group]      VARCHAR (255) NULL,
    [updateKonten]   VARCHAR (255) NULL,
    [Comment]        VARCHAR (255) NULL,
    [TimeStamp]      DATETIME      CONSTRAINT [DF_map_accounts_TimeStamp] DEFAULT (getdate()) NULL,
    [User]           VARCHAR (50)  CONSTRAINT [DF_map_accounts_user] DEFAULT (user_name()) NULL,
    CONSTRAINT [PK_map_accounts] PRIMARY KEY CLUSTERED ([Desk] ASC, [CtpyGroup] ASC, [InstrumentType] ASC, [Commodity] ASC, [CashflowType] ASC)
);


GO




CREATE trigger [dbo].[map_accounts-change-Log-delete] 
	on [dbo].[map_accounts] 
	after delete 
	as 
	insert into dbo.[Change-Log] 
	(
		[Change-Table]
		,[Change-Entry]
		,[Change-Type]
		,[Change-User]
		,[Change-Datetime]
	) 
	select	
		'map_accounts', 
		isNULL(Deleted.Desk,'') + ' //' 
		+ isNULL(Deleted.CtpyGroup,'') + ' //' 
		+ isNULL(Deleted.InstrumentType,'') + ' //' 
		+ isNULL(Deleted.Commodity,'') + ' //'
		+ isNULL(Deleted.CashflowType,'') + ' //'
		+ isNULL(Deleted.Account_Loss,'') + ' //'
		+ isNULL(Deleted.Account_Profit,'') + ' //'
		+ isNULL(Deleted.VAT_Group,'') + ' //' 
		+ isNULL(Deleted.Comment,'')	+ ' //' 
		+ isNULL(Deleted.updateKonten,'')
		,'Deleted'
		,user_name()
		, getdate() from deleted;

GO


CREATE trigger [dbo].[map_accounts-change-Log-update] 
	on [dbo].[map_accounts] 
	after update 
	as 
	BEGIN
		insert into dbo.[Change-Log] 
		(
			[Change-Table]
			, [Change-Entry]
			, [Change-Type]
			, [Change-User]
			, [Change-Datetime]
		) 
		select	
			'map_accounts'
			,'OLD => ' 
				+ isNULL(Deleted.Desk,'') + ' //' 
				+ isNULL(Deleted.CtpyGroup,'') + ' //' 
				+ isNULL(Deleted.InstrumentType,'') + ' //' 
				+ isNULL(Deleted.Commodity,'') + ' //' 
				+ isNULL(Deleted.CashflowType,'') + ' //' 
				+ isNULL(Deleted.Account_Loss,'') + ' //' 
				+ isNULL(Deleted.Account_Profit,'') + ' //' 
				+ isNULL(Deleted.VAT_Group,'') + ' //' 
				+ isNULL(Deleted.Comment,'') + ' //' 
				+ isNULL(Deleted.updateKonten,'')
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
			, [Change-Entry]
			, [Change-Type]
			, [Change-User]
			, [Change-Datetime]
		) 
		select	
			'map_accounts'
			, 'NEW => ' 
				+ isNULL(inserted.Desk,'') + ' //' 
				+ isNULL(inserted.CtpyGroup,'') + ' //' 
				+ isNULL(inserted.InstrumentType,'') + ' //' 
				+ isNULL(inserted.Commodity,'') + ' //' 
				+ isNULL(inserted.CashflowType,'') + ' //' 
				+ isNULL(inserted.Account_Loss,'') + ' //' 
				+ isNULL(inserted.Account_Profit,'') + ' //' 
				+ isNULL(inserted.VAT_Group,'') + ' //' 
				+ isNULL(inserted.Comment,'') + ' //' 
				+ isNULL(inserted.updateKonten,'')
			, 'Updated'
			, user_name()
			, getdate() 
		from 
			inserted
			,deleted 
		where 
			inserted.id = deleted.ID;

		/*update lastupdate-timestamp and userID in data table*/
		update [dbo].map_accounts set 
			[dbo].map_accounts.[TimeStamp] = getdate()
			,[dbo].map_accounts.[User] = user_name () 
		from 
			[dbo].map_accounts 
			inner join inserted as i on [dbo].map_accounts.ID = i.ID 
	END

GO



CREATE trigger [dbo].[map_accounts-change-Log-insert] 
	on [dbo].[map_accounts]
	after insert 
	as 
	insert into dbo.[Change-Log] 
	(
		 [Change-Table]
		, [Change-Entry]
		, [Change-Type]
		, [Change-User]
		, [Change-Datetime]
	) 
	select 
		'map_accounts'
		, isNULL(inserted.Desk,'') + ' //' 
			+ isNULL(inserted.CtpyGroup,'') + ' //' 
			+ isNULL(inserted.InstrumentType,'') + ' //' 
			+ isNULL(inserted.Commodity,'') + ' //' 
			+ isNULL(inserted.CashflowType,'') + ' //' 
			+ isNULL(inserted.Account_Loss,'') + ' //' 
			+ isNULL(inserted.Account_Profit,'') + ' //' 
			+ isNULL(inserted.VAT_Group,'') + ' //' 
			+ isNULL(inserted.Comment,'')	 + ' //' 
			+ isNULL(inserted.updateKonten,'')
		, 'Inserted'
		, user_name()
		, getdate() 
		from inserted;

GO

