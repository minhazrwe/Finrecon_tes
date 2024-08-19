CREATE TABLE [dbo].[table_Clearer_map_ExternalBusinessUnit] (
    [ID]                   INT            IDENTITY (1, 1) NOT NULL,
    [AccountName]          NVARCHAR (100) NOT NULL,
    [ExternalBusinessUnit] NVARCHAR (100) NULL,
    [Commodity]            NVARCHAR (50)  NULL,
    [CCY]                  NVARCHAR (10)  NOT NULL,
    [LocationName]         NVARCHAR (50)  NULL,
    [InternalOrder]        NVARCHAR (50)  NULL,
    [ClearerID]            INT            NOT NULL,
    [LastUpdate]           DATETIME       CONSTRAINT [DF_table_map_ExternalBusinessUnit_LastUpdate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_table_Clearer_map_ExternalBusinessUnit] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [UK_table_map_ExternalBusinessUnit] UNIQUE NONCLUSTERED ([AccountName] ASC, [CCY] ASC)
);


GO

CREATE trigger [dbo].[table_Clearer_map_ExternalBusinessUnit_after_delete]
	on [dbo].[table_Clearer_map_ExternalBusinessUnit] 
	after delete 
		as insert into dbo.[Change-Log] 
		(
			[Change-Table]
			,[Change-Entry]
			,[Change-Type]
			,[Change-Datetime]
			,[Change-User]
		) 
		select 
			'table_Clearer_map_ExternalBusinessUnit'
			,isNULL(deleted.AccountName,'') + ' //' 
				+ isNULL(deleted.ExternalBusinessUnit,'') + ' //' 
				+ isNULL(deleted.Commodity,'') + ' //' 
				+ isNULL(deleted.CCY,'') + ' //' 
				+ isNULL(deleted.LocationName,'') + ' //' 
				+ isNULL(deleted.InternalOrder,'') + ' //' 
				+ isNULL(cast(deleted.ClearerID as varchar),'') 
			,'Deleted'		
			,getdate() 
			,current_user
		from 
			deleted

GO


CREATE trigger [dbo].[table_Clearer_map_ExternalBusinessUnit_after_insert] 
	on [dbo].[table_Clearer_map_ExternalBusinessUnit]
	after insert 
		as INSERT INTO dbo.[Change-Log] 
		(
			[Change-Table]
			,[Change-Entry]
			,[Change-Type]
			,[Change-Datetime]
			,[Change-User]
		) 
		select 
			'table_Clearer_map_ExternalBusinessUnit'
			,isNULL(inserted.AccountName,'') + ' //' 
				+ isNULL(inserted.ExternalBusinessUnit,'') + ' //' 
				+ isNULL(inserted.Commodity,'') + ' //' 
				+ isNULL(inserted.CCY,'') + ' //' 
				+ isNULL(inserted.LocationName,'') + ' //' 
				+ isNULL(inserted.InternalOrder,'') + ' //' 
				+ isNULL(cast(inserted.ClearerID as varchar),'') 
			,'Inserted'		
			,getdate() 
			,CURRENT_USER
		from 
			inserted

GO

CREATE trigger [dbo].[table_Clearer_map_ExternalBusinessUnit_after_update] 
	on [dbo].[table_Clearer_map_ExternalBusinessUnit] 
	after update 
	as 
		BEGIN
		insert into dbo.[Change-Log] 
		(
			[Change-Table]
			,[Change-Entry]
			,[Change-Type]
			,[Change-Datetime]
			,[Change-User]
		) 
		select			
			'table_Clearer_map_ExternalBusinessUnit'
			,'OLD => ' 
				+ isNULL(deleted.AccountName,'') + ' //' 
				+ isNULL(deleted.ExternalBusinessUnit,'') + ' //' 
				+ isNULL(deleted.Commodity,'') + ' //' 
				+ isNULL(deleted.CCY,'') + ' //' 
				+ isNULL(deleted.LocationName,'') + ' //' 
				+ isNULL(deleted.InternalOrder,'') + ' //' 
				+ isNULL(cast(deleted.ClearerID as varchar),'') 
			,'Updated'
			,getdate() 
			,CURRENT_USER
		from 
			inserted
			,deleted 
		where 
			inserted.id = deleted.ID;

		insert into dbo.[Change-Log] 
		(
			[Change-Table]
			,[Change-Entry]
			,[Change-Type]
			,[Change-Datetime]
			,[Change-User]
		) 
		select			
			'table_Clearer_map_ExternalBusinessUnit'
			,'NEW => ' 
				+ isNULL(inserted.AccountName,'') + ' //' 
				+ isNULL(inserted.ExternalBusinessUnit,'') + ' //' 
				+ isNULL(inserted.Commodity,'') + ' //' 
				+ isNULL(inserted.CCY,'') + ' //' 
				+ isNULL(inserted.LocationName,'') + ' //' 
				+ isNULL(inserted.InternalOrder,'') + ' //' 
				+ isNULL(cast(inserted.ClearerID as varchar),'') 
			,'Updated'
			,getdate() 		
			,CURRENT_USER
		from 
			inserted
			,deleted 
		where 
			inserted.id = deleted.ID;

		update [dbo].table_Clearer_map_ExternalBusinessUnit 
			set [dbo].table_Clearer_map_ExternalBusinessUnit.LastUpdate = getdate()
			from 
				[dbo].table_Clearer_map_ExternalBusinessUnit 
				inner join inserted as i on [dbo].table_Clearer_map_ExternalBusinessUnit.ID = i.ID 
	END

GO

