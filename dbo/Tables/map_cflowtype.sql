CREATE TABLE [dbo].[map_cflowtype] (
    [name]           NVARCHAR (255) NULL,
    [id_number]      FLOAT (53)     NULL,
    [user_id]        NVARCHAR (50)  NULL,
    [last_update]    DATETIME       NULL,
    [version_number] FLOAT (53)     NULL
);


GO

/* trigger Added 2022-06-14 by MKu*/

CREATE TRIGGER [dbo].[map_cflowtype-change-Log-delete] 
	ON dbo.map_cflowtype
	AFTER INSERT 
	AS INSERT INTO dbo.[Change-Log] 
		(
		[Change-Table]
		, [Change-Entry]
		, [Change-Type]
		--, [Change-User]
		, [Change-Datetime]
		) 
		SELECT 'map_cflowtype',
			isNULL(deleted.[name], '') + ' //'
			+ convert(varchar,isNULL(deleted.[id_number], '')) + ' //'
			+ convert(varchar,isNULL(deleted.[user_id], '')) + ' //'
			+ convert(varchar,isNULL(deleted.[last_update], '')) + ' //'
			+ convert(varchar,isNULL(deleted.[version_number], '')) + ' //'
		,'Deleted'
		--, user_name()
		, getdate() from deleted;

GO

/* trigger Added 2022-06-14 by MKu*/

CREATE TRIGGER [dbo].[map_cflowtype-change-Log-insert] 
	ON dbo.map_cflowtype
	AFTER INSERT 
	AS INSERT INTO dbo.[Change-Log] 
		(
		[Change-Table]
		, [Change-Entry]
		, [Change-Type]
		--, [Change-User]
		, [Change-Datetime]
		) 
		SELECT 'map_cflowtype',
			isNULL(inserted.[name], '') + ' //'
			+ convert(varchar,isNULL(inserted.[id_number], '')) + ' //'
			+ convert(varchar,isNULL(inserted.[user_id], '')) + ' //'
			+ convert(varchar,isNULL(inserted.[last_update], '')) + ' //'
			+ convert(varchar,isNULL(inserted.[version_number], '')) + ' //'
		,'Inserted'
		--, user_name()
		, getdate() from inserted;

GO

/* trigger Added 2022-06-14 by MKu*/

CREATE trigger [dbo].[map_cflowtype-change-Log-update] 
	on dbo.map_cflowtype 
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
				'map_cflowtype'
				,'OLD => '
					+ isNULL(deleted.[name], '') + ' //'
					+ convert(varchar,isNULL(deleted.[id_number], '')) + ' //'
					+ convert(varchar,isNULL(deleted.[user_id], '')) + ' //'
					+ convert(varchar,isNULL(deleted.[last_update], '')) + ' //'
					+ convert(varchar,isNULL(deleted.[version_number], '')) + ' //'
				,'Updated'
				--,user_name()
				,getdate()
			FROM  
				inserted
				,deleted
			WHERE 
				inserted.id_number = deleted.id_number;


		/*document the new entry:*/
		INSERT INTO dbo.[Change-Log] (
			 [Change-Table]
			,[Change-Entry]
			,[Change-Type]
			--,[Change-User]
			,[Change-Datetime]
			)
		SELECT 
			'map_cflowtype'
			,'NEW => '
				+ isNULL(inserted.[name], '') + ' //'
				+ convert(varchar,isNULL(inserted.[id_number], '')) + ' //'
				+ convert(varchar,isNULL(inserted.[user_id], '')) + ' //'
				+ convert(varchar,isNULL(inserted.[last_update], '')) + ' //'
				+ convert(varchar,isNULL(inserted.[version_number], '')) + ' //'
			,'Updated'
			--,user_name()
			,getdate()
			FROM 
					inserted
				,deleted
			WHERE 
				inserted.id_number = deleted.id_number;


	
	END

GO

