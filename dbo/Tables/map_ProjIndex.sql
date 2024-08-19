CREATE TABLE [dbo].[map_ProjIndex] (
    [ID]            INT          IDENTITY (1, 1) NOT NULL,
    [ProjIndex]     VARCHAR (50) NOT NULL,
    [Commodity]     VARCHAR (50) NULL,
    [Sub_Commodity] VARCHAR (50) NULL,
    [Ccy]           VARCHAR (3)  NULL,
    [TimeStamp]     DATETIME     CONSTRAINT [DF_map_ProjIndex_TimeStamp] DEFAULT (getdate()) NULL,
    [User]          VARCHAR (50) CONSTRAINT [DF_map_ProjIndex_USER] DEFAULT (user_name()) NULL,
    CONSTRAINT [pk_map_ProjIndex] PRIMARY KEY CLUSTERED ([ProjIndex] ASC)
);


GO



/* trigger Added 2022-06-14 by MKu*/

CREATE trigger [dbo].[map_ProjIndex-change-Log-update] 
	on [dbo].[map_ProjIndex] 
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
				'map_ProjIndex'
				,'OLD => '
					+ isNULL(deleted.[ProjIndex], '') + ' //'
					+ isNULL(deleted.[Commodity], '') + ' //'
					+ isNULL(deleted.[Sub_Commodity], '') + ' //'
					+ isNULL(deleted.[Ccy], '') + ' //'
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
			'map_ProjIndex'
			,'NEW => '
				+ isNULL(inserted.[ProjIndex], '') + ' //'
				+ isNULL(inserted.[Commodity], '') + ' //'
				+ isNULL(inserted.[Sub_Commodity], '') + ' //'
				+ isNULL(inserted.[Ccy], '') + ' //'
			,'Updated'
			--,user_name()
			,getdate()
			FROM 
					inserted
				,deleted
			WHERE 
				inserted.id = deleted.ID;

		/*update lastUpdate filed in datatable*/
		update [dbo].[map_ProjIndex] set 
			[dbo].[map_ProjIndex].[TimeStamp] = getdate()
			,[dbo].[map_ProjIndex].[User] = user_name () 
		from 
			[dbo].[map_ProjIndex] 
			inner join inserted as i on [dbo].[map_ProjIndex].ID = i.ID 


	END

GO



/* trigger Added 2022-06-14 by MKu*/

CREATE TRIGGER [dbo].[map_ProjIndex-change-Log-delete] 
	ON [dbo].[map_ProjIndex]
	AFTER INSERT 
	AS INSERT INTO dbo.[Change-Log] 
		(
		[Change-Table]
		, [Change-Entry]
		, [Change-Type]
		--, [Change-User]
		, [Change-Datetime]
		) 
		SELECT 'map_ProjIndex',
			isNULL(deleted.[ProjIndex], '') + ' //'
			+ isNULL(deleted.[Commodity], '') + ' //'
			+ isNULL(deleted.[Sub_Commodity], '') + ' //'
			+ isNULL(deleted.[Ccy], '') + ' //'
		,'Deleted'
		--, user_name()
		, getdate() from deleted;

GO



/* trigger Added 2022-06-14 by MKu*/

CREATE TRIGGER [dbo].[map_ProjIndex-change-Log-insert] 
	ON [dbo].[map_ProjIndex]
	AFTER INSERT 
	AS INSERT INTO dbo.[Change-Log] 
		(
		[Change-Table]
		, [Change-Entry]
		, [Change-Type]
		--, [Change-User]
		, [Change-Datetime]
		) 
		SELECT 'map_ProjIndex',
			isNULL(inserted.[ProjIndex], '') + ' //'
			+ isNULL(inserted.[Commodity], '') + ' //'
			+ isNULL(inserted.[Sub_Commodity], '') + ' //'
			+ isNULL(inserted.[Ccy], '') + ' //'
		,'Inserted'
		--, user_name()
		, getdate() from inserted;

GO

