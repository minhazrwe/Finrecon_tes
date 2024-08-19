CREATE TABLE [dbo].[table_map_Desk] (
    [ID]          INT           IDENTITY (1, 1) NOT NULL,
    [Desk_Name]   VARCHAR (100) NULL,
    [Desk_Type]   VARCHAR (100) NULL,
    [Comment]     VARCHAR (100) NULL,
    [Last_Update] DATETIME      CONSTRAINT [DF_table_map_Desk_Last_Update] DEFAULT (getdate()) NULL,
    CONSTRAINT [pk_table_map_Desk] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [UK_table_map_Desk] UNIQUE NONCLUSTERED ([Desk_Name] ASC)
);


GO



CREATE TRIGGER dbo.trigger_table_map_Desk_after_delete
	ON table_map_Desk
	after delete 
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
		SELECT 
			'table_map_Desk'
			, 'OLD => ' 
				+ isNULL(deleted.Desk,'') + ' // ' 
				+ isNULL(deleted.Desk_Type,'') +' // '
				+ isnull(deleted.Comment,'')
			, 'deleted'
			, user_name()
			, getdate() 
		FROM 
			deleted 

		
	END

GO


CREATE TRIGGER dbo.trigger_table_map_Desk_after_update
	ON table_map_Desk
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
		SELECT 
			'table_map_Desk'
			, 'NEW => ' 
				+ isNULL(inserted.Desk,'') + ' // ' 
				+ isNULL(inserted.Desk_Type,'') +' // '
				+ isnull(inserted.Comment,'')
			, 'Updated'
			, user_name()
			, getdate() 
		FROM 
			inserted
			,deleted 
		WHERE 
			inserted.ID = deleted.ID;

/*old record */
		INSERT INTO dbo.[Change-Log] 
		(
			[Change-Table]
			, [Change-Entry]
			, [Change-Type]
			, [Change-User]
			, [Change-Datetime]
		) 
		SELECT 
			'table_map_Desk'
			, 'OLD => ' 
				+ isNULL(deleted.Desk,'') + ' // ' 
				+ isNULL(deleted.Desk_Type,'') +' // '
				+ isnull(deleted.Comment,'')
				, 'Updated'
				, user_name()
				, getdate() 
		FROM 
			inserted
			,deleted 
		WHERE 
			inserted.id = deleted.ID;

		
		UPDATE table_map_Desk SET 
			Last_Update = getdate()
		FROM 
			table_map_Desk inner join inserted 
			on table_map_Desk.ID = inserted.ID 
	END

GO

