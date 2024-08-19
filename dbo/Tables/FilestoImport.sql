CREATE TABLE [dbo].[FilestoImport] (
    [ID]           INT           IDENTITY (1, 1) NOT NULL,
    [FileName]     VARCHAR (200) NOT NULL,
    [Source]       VARCHAR (100) NOT NULL,
    [PathID]       VARCHAR (200) NOT NULL,
    [ToBeImported] INT           NOT NULL,
    [LastImport]   DATETIME      NULL,
    [User]         VARCHAR (100) CONSTRAINT [DF_FilestoImport_User] DEFAULT (user_name()) NOT NULL,
    [Timestamp]    DATETIME      CONSTRAINT [DF_FilestoImport_Timestamp] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [pk_FilestoImport] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO



/* trigger Added 2022-06-14 by MKu*/

CREATE TRIGGER [dbo].[FilestoImport-change-Log-delete] 
	ON [dbo].[FilestoImport]
	AFTER INSERT 
	AS INSERT INTO dbo.[Change-Log] 
		(
		[Change-Table]
		, [Change-Entry]
		, [Change-Type]
		, [Change-User]
		, [Change-Datetime]
		) 
		SELECT 'FilestoImport',
			isNULL(deleted.[FileName], '') + ' //'
			+ isNULL(deleted.[Source], '') + ' //'
			+ isNULL(deleted.[PathID], '') + ' //'
			+ convert(varchar,isNULL(deleted.[ToBeImported], '')) + ' //'
			+ convert(varchar,isNULL(deleted.[LastImport], '')) + ' //'
		,'Deleted'
		, user_name()
		, getdate() from deleted;

GO


/* trigger Added 2022-06-14 by MKu*/

CREATE trigger [dbo].[FilestoImport-change-Log-update] 
	on [dbo].[FilestoImport] 
	after update 
	as 
	BEGIN
	
		/* document the old entry */
		INSERT INTO dbo.[Change-Log] 
			(
			 [Change-Table]
			,[Change-Entry]
			,[Change-Type]
			,[Change-User] 
			,[Change-Datetime]
			)
			SELECT 
				'FilestoImport'
				,'OLD => ' 
					+ isNULL(deleted.[FileName], '') + ' //'
					+ isNULL(deleted.[Source], '') + ' //'
					+ isNULL(deleted.[PathID], '') + ' //'
					+ convert(varchar,isNULL(deleted.[ToBeImported], '')) + ' //'
					+ convert(varchar,isNULL(deleted.[LastImport], '')) + ' //'
				,'Updated'
				,user_name()
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
			,[Change-User]
			,[Change-Datetime]
			)
		SELECT 
			'FilestoImport'
			,'NEW => ' 
				+ isNULL(inserted.[FileName], '') + ' //'
				+ isNULL(inserted.[Source], '') + ' //'
				+ isNULL(inserted.[PathID], '') + ' //'
				+ convert(varchar,isNULL(inserted.[ToBeImported], '')) + ' //'
				+ convert(varchar,isNULL(inserted.[LastImport], '')) + ' //'
			,'Updated'
			,user_name()
			,getdate()
			FROM 
					inserted
				,deleted
			WHERE 
				inserted.id = deleted.ID;
	END

GO



/* trigger Added 2022-06-14 by MKu*/

CREATE TRIGGER [dbo].[FilestoImport-change-Log-insert] 
	ON [dbo].[FilestoImport]
	AFTER INSERT 
	AS INSERT INTO dbo.[Change-Log] 
		(
		[Change-Table]
		, [Change-Entry]
		, [Change-Type]
		, [Change-User]
		, [Change-Datetime]
		) 
		SELECT 'FilestoImport',
			isNULL(inserted.[FileName], '') + ' //'
			+ isNULL(inserted.[Source], '') + ' //'
			+ isNULL(inserted.[PathID], '') + ' //'
			+ convert(varchar,isNULL(inserted.[ToBeImported], '')) + ' //'
			+ convert(varchar,isNULL(inserted.[LastImport], '')) + ' //'
		,'Inserted'
		, user_name()
		, getdate() from inserted;

GO

