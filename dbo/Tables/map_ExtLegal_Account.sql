CREATE TABLE [dbo].[map_ExtLegal_Account] (
    [ID]             INT           IDENTITY (1, 1) NOT NULL,
    [ExtBunit]       VARCHAR (255) NOT NULL,
    [InstrumentType] VARCHAR (255) NOT NULL,
    [Account_old]    VARCHAR (255) NOT NULL,
    [Account_new]    VARCHAR (255) NOT NULL,
    [Comment]        VARCHAR (255) NULL,
    [TimeStamp]      DATETIME      CONSTRAINT [DF_map_ExtLegal_Account_TimeStamp] DEFAULT (getdate()) NULL,
    [USER]           VARCHAR (50)  CONSTRAINT [DF_map_ExtLegal_Account_USER] DEFAULT (user_name()) NULL,
    CONSTRAINT [pk_map_ExtLegal_Account] PRIMARY KEY CLUSTERED ([ExtBunit] ASC, [InstrumentType] ASC, [Account_old] ASC)
);


GO



/* trigger Added 2022-06-14 by MKu*/

CREATE TRIGGER [dbo].[map_ExtLegal_Account-change-Log-insert] 
	ON [dbo].[map_ExtLegal_Account]
	AFTER INSERT 
	AS INSERT INTO dbo.[Change-Log] 
		(
		[Change-Table]
		, [Change-Entry]
		, [Change-Type]
		--, [Change-User]
		, [Change-Datetime]
		) 
		SELECT 'map_ExtLegal_Account',
			isNULL(inserted.[ExtBunit], '') + ' //'
			+ isNULL(inserted.[InstrumentType], '') + ' //'
			+ isNULL(inserted.[Account_old], '') + ' //'
			+ isNULL(inserted.[Account_new], '') + ' //'
			+ isNULL(inserted.[Comment], '') + ' //'
		,'Inserted'
		--, user_name()
		, getdate() from inserted;

GO



/* trigger Added 2022-06-14 by MKu*/

CREATE TRIGGER [dbo].[map_ExtLegal_Account-change-Log-delete] 
	ON [dbo].[map_ExtLegal_Account]
	AFTER INSERT 
	AS INSERT INTO dbo.[Change-Log] 
		(
		[Change-Table]
		, [Change-Entry]
		, [Change-Type]
		--, [Change-User]
		, [Change-Datetime]
		) 
		SELECT 'map_ExtLegal_Account',
			isNULL(deleted.[ExtBunit], '') + ' //'
			+ isNULL(deleted.[InstrumentType], '') + ' //'
			+ isNULL(deleted.[Account_old], '') + ' //'
			+ isNULL(deleted.[Account_new], '') + ' //'
			+ isNULL(deleted.[Comment], '') + ' //'
		,'Deleted'
		--, user_name()
		, getdate() from deleted;

GO



/* trigger Added 2022-06-14 by MKu*/

CREATE trigger [dbo].[map_ExtLegal_Account-change-Log-update] 
	on [dbo].[map_ExtLegal_Account] 
	after update 
	as 
	BEGIN
	
		/* document the old entry */
		INSERT INTO dbo.[Change-Log] 
			(
			 [Change-Table]
			,[Change-Entry]
			,[Change-Type]
			--,[Change-User] 
			,[Change-Datetime]
			)
			SELECT 
				'map_ExtLegal_Account'
				,'OLD => '
					+ isNULL(deleted.[ExtBunit], '') + ' //'
					+ isNULL(deleted.[InstrumentType], '') + ' //'
					+ isNULL(deleted.[Account_old], '') + ' //'
					+ isNULL(deleted.[Account_new], '') + ' //'
					+ isNULL(deleted.[Comment], '') + ' //'
				,'Updated'
				--,user_name()
				,getdate()
			FROM  
				inserted
				,deleted
			WHERE 
				inserted.id = deleted.ID;


		/*document the new entry:*/
		INSERT INTO dbo.[Change-Log] (
			 [Change-Table]
			,[Change-Entry]
			,[Change-Type]
			--,[Change-User]
			,[Change-Datetime]
			)
		SELECT 
			'map_ExtLegal_Account'
			,'NEW => '
				+ isNULL(inserted.[ExtBunit], '') + ' //'
				+ isNULL(inserted.[InstrumentType], '') + ' //'
				+ isNULL(inserted.[Account_old], '') + ' //'
				+ isNULL(inserted.[Account_new], '') + ' //'
				+ isNULL(inserted.[Comment], '') + ' //'
			,'Updated'
			--,user_name()
			,getdate()
			FROM 
					inserted
				,deleted
			WHERE 
				inserted.id = deleted.ID;

		
		/*update timestamp field*/
			update [dbo].[map_ExtLegal_Account] set 
					[dbo].[map_ExtLegal_Account].[TimeStamp] = getdate()
					,[dbo].[map_ExtLegal_Account].[User] = user_name () 
			from 
				[dbo].[map_ExtLegal_Account] 
				inner join inserted as i on [dbo].[map_ExtLegal_Account].ID = i.ID 


	END

GO

