CREATE TABLE [dbo].[Endur_CPTY_MAP] (
    [short_name] VARCHAR (50) NULL,
    [long_name]  VARCHAR (50) NULL,
    [name]       VARCHAR (50) NULL,
    [iso_code]   VARCHAR (50) NULL,
    [party_id]   VARCHAR (50) NULL
);


GO



Create trigger [dbo].[Endur_CPTY_MAP-change-Log-insert] 
	on [dbo].[Endur_CPTY_MAP]
	after insert 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
	select 'Endur_CPTY_MAP', isNULL(inserted.[short_name],'') + ' //' + isNULL(inserted.[long_name],'') + ' //' + isNULL(inserted.[name],'') + ' //' + isNULL(inserted.[iso_code],'')+ ' //' + isNULL(inserted.[party_id],''), 'Inserted', user_name(), getdate() from inserted;

GO


CREATE trigger [dbo].[Endur_CPTY_MAP-change-Log-delete] 
	on [dbo].[Endur_CPTY_MAP] 
	after delete 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
	select	'Endur_CPTY_MAP', isNULL(Deleted.[short_name],'') + ' //' + isNULL(Deleted.[long_name],'') + ' //' + isNULL(Deleted.[name],'') + ' //' + isNULL(Deleted.[iso_code],'') + ' //' + isNULL(Deleted.[party_id],''), 'Deleted', user_name(), getdate() from deleted;

GO

