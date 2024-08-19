CREATE TABLE [dbo].[table_Automatic_Jobs] (
    [ID]                  INT           IDENTITY (1, 1) NOT NULL,
    [Job_Name]            VARCHAR (255) NOT NULL,
    [Job_Date_Start_Time] DATETIME      NOT NULL,
    [Job_Started]         DATETIME      NULL,
    [Job_Finished]        DATETIME      NULL,
    [Job_Duration_in_min] AS            ((CONVERT([real],[Job_Finished]-[Job_Started])*(24))*(60)) PERSISTED,
    CONSTRAINT [pk_table_Automatic_Jobs] PRIMARY KEY CLUSTERED ([ID] DESC),
    CONSTRAINT [UK_Job_Date_Start_Time] UNIQUE NONCLUSTERED ([Job_Date_Start_Time] ASC)
);


GO





CREATE trigger [dbo].[table_Automatic_Jobs-change-Log-insert] 
	on [dbo].[table_Automatic_Jobs]
	after insert 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
	select 
	'Automatic-Jobs'
	, isNULL(inserted.Job_Name,'') + ' //' 	+ isNULL(cast(inserted.Job_Date_Start_Time as varchar),''), 
	'Inserted'
	, user_name()
	, getdate() 
	from inserted;

GO





CREATE trigger [dbo].[table_Automatic_Jobs-change-Log-delete] 
	on [dbo].[table_Automatic_Jobs]
	after delete 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
	select 
	'Automatic-Jobs'
	, isNULL(deleted.Job_Name,'') + ' //' 	+ isNULL(cast(deleted.Job_Date_Start_Time as varchar),''), 
	'deleted'
	, user_name()
	, getdate() 
	from deleted;

GO

