CREATE TABLE [dbo].[map_asset_reference] (
    [ID]                   INT           IDENTITY (1, 1) NOT NULL,
    [TRADE_REFERENCE_TEXT] VARCHAR (100) NOT NULL,
    [Asset_Name]           VARCHAR (100) NOT NULL,
    [User]                 VARCHAR (255) CONSTRAINT [DF_map_asset_reference2_user] DEFAULT (user_name()) NOT NULL,
    [Timestamp]            DATETIME      CONSTRAINT [DF_map_asset_reference2_TimeStamp] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_map_asset_reference] PRIMARY KEY CLUSTERED ([Asset_Name] ASC, [TRADE_REFERENCE_TEXT] ASC)
);


GO


CREATE trigger [dbo].[map_asset_reference-change-Log-insert] 
	on [dbo].[map_asset_reference]
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
		'map_asset_reference'
		, isNULL(inserted.[TRADE_REFERENCE_TEXT],'') + ' //' 
		+ isNULL(inserted.[Asset_Name],'')
		, 'Inserted'
		, user_name()
		, getdate() 
	from 
		inserted;

GO


CREATE trigger [dbo].[map_asset_reference-change-Log-delete] 
	on [dbo].[map_asset_reference] 
	after delete 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
	select 'map_asset_reference', isNULL(deleted.TRADE_REFERENCE_TEXT,'') + ' //' + isNULL(deleted.Asset_Name,''), 'Deleted', user_name(), getdate() from deleted;

GO


/* trigger reactivated 2022-05-20, with deativated logging of user who did the changes, as this is not approved by workers council 
deactivation was discussed in mfa-x daystart meeting on 2022-05-20)*/

CREATE trigger [dbo].[map_asset_reference-change-Log-update] 
	on [dbo].[map_asset_reference] 
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
				'map_order'
				,'OLD => ' 
					+ isNULL(deleted.[TRADE_REFERENCE_TEXT], '') + ' //' 
					+ isNULL(deleted.[Asset_Name], '')
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
			'map_order'
			,'NEW => ' 
				+ isNULL(inserted.[TRADE_REFERENCE_TEXT], '') + ' //' 
				+ isNULL(inserted.[Asset_Name], '')
			,'Updated'
			,user_name()
			,getdate()
			FROM 
					inserted
				,deleted
			WHERE 
				inserted.id = deleted.ID;

		UPDATE [dbo].[map_asset_reference]
		SET 
			dbo.[map_asset_reference].TimeStamp = getdate()
			,[dbo].[map_asset_reference].[User] = user_name()
		FROM 
			[dbo].[map_asset_reference]
			INNER JOIN inserted ON [dbo].[map_asset_reference].ID = inserted.ID
	END

GO

