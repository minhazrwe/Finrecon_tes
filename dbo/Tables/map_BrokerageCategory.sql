CREATE TABLE [dbo].[map_BrokerageCategory] (
    [ID]           INT            IDENTITY (1, 1) NOT NULL,
    [CounterParty] NVARCHAR (200) NOT NULL,
    [Category]     NVARCHAR (50)  NOT NULL,
    CONSTRAINT [pk_map_BrokerageCategory] PRIMARY KEY CLUSTERED ([CounterParty] ASC, [Category] ASC)
);


GO



/* trigger Added 2022-06-14 by MKu*/

CREATE TRIGGER [dbo].[map_BrokerageCategory-change-Log-insert] 
	ON [dbo].[map_BrokerageCategory]
	AFTER INSERT 
	AS INSERT INTO dbo.[Change-Log] 
		(
		[Change-Table]
		, [Change-Entry]
		, [Change-Type]
		--, [Change-User]
		, [Change-Datetime]
		) 
		SELECT 'map_BrokerageCategory',
			isNULL(inserted.[CounterParty], '') + ' //'
			+ isNULL(inserted.[Category], '') + ' //'
		,'Inserted'
		--, user_name()
		, getdate() from inserted;

GO



/* trigger Added 2022-06-14 by MKu*/

CREATE TRIGGER [dbo].[map_BrokerageCategory-change-Log-delete] 
	ON [dbo].[map_BrokerageCategory]
	AFTER INSERT 
	AS INSERT INTO dbo.[Change-Log] 
		(
		[Change-Table]
		, [Change-Entry]
		, [Change-Type]
		--, [Change-User]
		, [Change-Datetime]
		) 
		SELECT 'map_BrokerageCategory',
			isNULL(deleted.[CounterParty], '') + ' //'
			+ isNULL(deleted.[Category], '') + ' //'
		,'Deleted'
		--, user_name()
		, getdate() from deleted;

GO



/* trigger Added 2022-06-14 by MKu*/

CREATE trigger [dbo].[map_BrokerageCategory-change-Log-update] 
	on [dbo].[map_BrokerageCategory] 
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
				'map_BrokerageCategory'
				,'OLD => ' 
					+ isNULL(deleted.[CounterParty], '') + ' //'
					+ isNULL(deleted.[Category], '') + ' //'
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
			'map_BrokerageCategory'
			,'NEW => ' 
				+ isNULL(inserted.[CounterParty], '') + ' //'
				+ isNULL(inserted.[Category], '') + ' //'
			,'Updated'
			--,user_name()
			,getdate()
			FROM 
					inserted
				,deleted
			WHERE 
				inserted.id = deleted.ID;

		/*update the timestamp of the changed record: */
		/*not possible, as no field for lastUpdate*/
		

	END

GO

