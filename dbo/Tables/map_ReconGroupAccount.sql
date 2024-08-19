CREATE TABLE [dbo].[map_ReconGroupAccount] (
    [ID]                          INT            IDENTITY (1, 1) NOT NULL,
    [Account]                     VARCHAR (255)  NOT NULL,
    [AccountName]                 VARCHAR (255)  NULL,
    [recon_group]                 VARCHAR (40)   NULL,
    [Commodity]                   VARCHAR (255)  NULL,
    [comment]                     VARCHAR (255)  NULL,
    [AWV-Anlage]                  VARCHAR (20)   NULL,
    [AWV-LZB]                     VARCHAR (20)   NULL,
    [AWV-LZB-Inland]              VARCHAR (20)   NULL,
    [AWV-Bezeichnung]             VARCHAR (1000) NULL,
    [AWV-Bemerkung/Zahlungszweck] VARCHAR (1000) NULL,
    [AWV-Info]                    VARCHAR (1000) NULL,
    [AWV-Leistungsverzeichnis]    VARCHAR (1000) NULL,
    [AWV-Responsible]             VARCHAR (50)   NULL,
    [Marge]                       NVARCHAR (20)  NULL,
    [TimeStamp]                   DATETIME       CONSTRAINT [DF_map_ReconGroupAccount_TimeStamp] DEFAULT (getdate()) NULL,
    [User]                        VARCHAR (50)   CONSTRAINT [DF_map_ReconGroupAccount_User] DEFAULT (user_name()) NULL,
    [AWV-Required]                VARCHAR (5)    NULL,
    CONSTRAINT [pk_map_ReconGroupAccount] PRIMARY KEY CLUSTERED ([Account] ASC)
);


GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE trigger [dbo].[map_ReconGroupAccount-change-Log-update] 
	on [dbo].[map_ReconGroupAccount] 
	after update 
	as 
	BEGIN		
		insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_ReconGroupAccount', 'OLD => ' + isNULL(deleted.Account,'') + ' //' + isNULL(deleted.AccountName,'') + ' //' + 
		isNULL(deleted.[recon_group],'') + ' //' + isNULL(deleted.Commodity,'') + ' //' + isNULL(deleted.comment,'') + ' //' + 
		isNULL(deleted.[AWV-Anlage],'') + ' //' + isNULL(deleted.[AWV-LZB],'') + ' //' + isNULL(deleted.[AWV-LZB-Inland],'') + ' //' + isNULL(deleted.[AWV-Bezeichnung],'') + ' //' +
		isNULL(deleted.[AWV-Bemerkung/Zahlungszweck],'') + ' //' +		isNULL(deleted.[AWV-Info],'') + ' //' +	isNULL(deleted.[AWV-Leistungsverzeichnis],'') + ' //' +
		isNULL(deleted.[AWV-Responsible],'') + ' //' +	isNULL(deleted.[Marge],''), 'Updated', user_name(), getdate() from inserted, deleted where inserted.id = deleted.ID;
		
		insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_ReconGroupAccount', 'NEW => ' + isNULL(inserted.Account,'') + ' //' + isNULL(inserted.AccountName,'') + ' //' + 
		isNULL(inserted.[recon_group],'') + ' //' + isNULL(inserted.Commodity,'') + ' //' + isNULL(inserted.comment,'') + ' //' + 
		isNULL(inserted.[AWV-Anlage],'') + ' //' + isNULL(inserted.[AWV-LZB],'') + ' //' + isNULL(inserted.[AWV-LZB-Inland],'') + ' //' + isNULL(inserted.[AWV-Bezeichnung],'') + ' //' +
		isNULL(inserted.[AWV-Bemerkung/Zahlungszweck],'') + ' //' +		isNULL(inserted.[AWV-Info],'') + ' //' +	isNULL(inserted.[AWV-Leistungsverzeichnis],'') + ' //' +
		isNULL(inserted.[AWV-Responsible],'') + ' //' +	isNULL(inserted.[Marge],''), 'Updated', user_name(), getdate() from inserted, deleted where inserted.id = deleted.ID;
		
		update [dbo].[map_ReconGroupAccount] set [dbo].[map_ReconGroupAccount].[TimeStamp] = getdate(), [dbo].[map_ReconGroupAccount].[User] = user_name () 
		from [dbo].[map_ReconGroupAccount] inner join inserted as i on [dbo].[map_ReconGroupAccount].ID = i.ID 
	END

GO






CREATE trigger [dbo].[map_ReconGroupAccount-change-Log-insert] 
	on [dbo].[map_ReconGroupAccount]
	after insert 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_ReconGroupAccount', isNULL(Account,'') + ' //' + isNULL(AccountName,'') + ' //' + 
		isNULL([recon_group],'') + ' //' + isNULL(Commodity,'') + ' //' + isNULL(comment,'') + ' //' + 
		isNULL([AWV-Anlage],'') + ' //' + isNULL([AWV-LZB],'') + ' //' + isNULL([AWV-LZB-Inland],'') + ' //' + isNULL([AWV-Bezeichnung],'') + ' //' +
		isNULL([AWV-Bemerkung/Zahlungszweck],'') + ' //' +		isNULL([AWV-Info],'') + ' //' +	isNULL([AWV-Leistungsverzeichnis],'') + ' //' +
		isNULL([AWV-Responsible],'') + ' //' +	isNULL([Marge],''), 'Inserted', user_name(), getdate() from inserted;

GO





create trigger [dbo].[map_ReconGroupAccount-change-Log-delete] 
	on [dbo].[map_ReconGroupAccount] 
	after delete 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'map_ReconGroupAccount', isNULL(Account,'') + ' //' + isNULL(AccountName,'') + ' //' + 
		isNULL([recon_group],'') + ' //' + isNULL(Commodity,'') + ' //' + isNULL(comment,'') + ' //' + 
		isNULL([AWV-Anlage],'') + ' //' + isNULL([AWV-LZB],'') + ' //' + isNULL([AWV-LZB-Inland],'') + ' //' + isNULL([AWV-Bezeichnung],'') + ' //' +
		isNULL([AWV-Bemerkung/Zahlungszweck],'') + ' //' +		isNULL([AWV-Info],'') + ' //' +	isNULL([AWV-Leistungsverzeichnis],'') + ' //' +
		isNULL([AWV-Responsible],'') + ' //' +	isNULL([Marge],''), 'Deleted', user_name(), getdate() from deleted;

GO

