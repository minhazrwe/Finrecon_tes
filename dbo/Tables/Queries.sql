CREATE TABLE [dbo].[Queries] (
    [ID]         INT            IDENTITY (1, 1) NOT NULL,
    [Name]       VARCHAR (100)  NOT NULL,
    [Statement]  VARCHAR (MAX)  NOT NULL,
    [ExportPath] INT            NULL,
    [Purpose]    VARCHAR (100)  NULL,
    [Comment]    VARCHAR (2000) NULL,
    [Temp_Table] INT            CONSTRAINT [DF_Queries_Temp_Table] DEFAULT ((0)) NULL,
    [TimeStamp]  DATETIME       CONSTRAINT [DF_Queries_TimeStamp] DEFAULT (getdate()) NOT NULL,
    [User]       VARCHAR (50)   CONSTRAINT [DF_Queries_user] DEFAULT (user_name()) NOT NULL,
    CONSTRAINT [PK_Queries] PRIMARY KEY CLUSTERED ([ID] ASC, [Name] ASC)
);


GO



CREATE trigger [dbo].[Queries-change-Log-delete] 
	on [dbo].[Queries] 
	after delete 
	as 
	insert into dbo.[Change-Log] 
	(
		[Change-Table], 
		[Change-Entry], 
		[Change-Type], 
		[Change-User], 
		[Change-Datetime]
	) 
	select
		'Queries', 
		isNULL(deleted.Name,'') + ' //' 
			+ isNULL(deleted.Purpose,'') + ' //' 
			+ convert(varchar,isNULL(deleted.[Statement],'')) + ' //' 
			+ isNULL(deleted.comment,'') + ' //' 
			+ convert(nvarchar,isNULL(deleted.ExportPath,'')), 
		'Deleted', 
		user_name(), 
		getdate() 
	from 
		deleted;

GO



CREATE trigger [dbo].[Queries-change-Log-insert] 
	on [dbo].[Queries]
	after insert 
	as 
	insert into dbo.[Change-Log] 
	(
		[Change-Table], 
		[Change-Entry], 
		[Change-Type], 
		[Change-User], 
		[Change-Datetime]
	) 		
	select	
		'Queries', 
		isNULL(inserted.Name,'') + ' //' 
			+ isNULL(inserted.Purpose,'') + ' //' 
			+ convert(varchar,isNULL(inserted.Statement,'')) + ' //' 
			+ isNULL(inserted.[comment],'') + ' //' 
			+ convert(nvarchar,isNULL(inserted.ExportPath,'')), 
			'Inserted', 
			user_name(), 
			getdate() 
	from 
		inserted;

GO




CREATE trigger [dbo].[Queries-change-Log-update] 
	on [dbo].[Queries] 
	after update 
	as 
	BEGIN
		insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'Queries', 'OLD => ' + isNULL(deleted.Name,'') + ' //' + isNULL(deleted.Purpose,'') + ' //' + 
		convert(varchar,isNULL(deleted.[Statement],'')) + ' //' + isNULL(deleted.comment,'') + ' //' + convert(nvarchar,isNULL(deleted.ExportPath,'')), 'Updated', user_name(), getdate() from inserted, deleted where inserted.id = deleted.ID;
		insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'Queries', 'NEW => ' + isNULL(inserted.Name,'') + ' //' + isNULL(inserted.Purpose,'') + ' //' + 
			convert(varchar,isNULL(inserted.Statement,'')) + ' //' + isNULL(inserted.[comment],'') + ' //' + convert(nvarchar,isNULL(inserted.ExportPath,'')), 'Updated', user_name(), getdate() from inserted, deleted where inserted.id = deleted.ID;
		update [dbo].[Queries] set [dbo].[Queries].[TimeStamp] = getdate(), [dbo].[Queries].[User] = user_name () 
		from [dbo].[Queries] inner join inserted as i on [dbo].[Queries].ID = i.ID 
	END

GO

