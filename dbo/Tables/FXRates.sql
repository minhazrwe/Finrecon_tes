CREATE TABLE [dbo].[FXRates] (
    [ID]       INT         IDENTITY (1, 1) NOT NULL,
    [AsOfDate] DATETIME    NOT NULL,
    [Currency] VARCHAR (3) NOT NULL,
    [Rate]     FLOAT (53)  NULL,
    [RateRisk] FLOAT (53)  NULL,
    CONSTRAINT [pk_FXRates] PRIMARY KEY CLUSTERED ([AsOfDate] ASC, [Currency] ASC)
);


GO







CREATE trigger [dbo].[FXRates-change-Log-insert] 
	on [dbo].[FXRates]
	after insert 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'FXRates', isNULL(inserted.AsOfDate,'') + ' //' + isNULL(inserted.Currency,'') + ' //' + 
		isNULL(inserted.Rate,'') + ' //' + isNULL(inserted.RateRisk,''), 'Inserted', user_name(), getdate() from inserted;
GO
DISABLE TRIGGER [dbo].[FXRates-change-Log-insert]
    ON [dbo].[FXRates];


GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE trigger [dbo].[FXRates-change-Log-update] 
	on [dbo].[FXRates] 
	after update 
	as 
	BEGIN
		insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'FXRates', 'OLD => ' + isNULL(deleted.AsOfDate,'') + ' //' + isNULL(deleted.Currency,'') + ' //' + 
		isNULL(deleted.Rate,'') + ' //' + isNULL(deleted.RateRisk,''), 'Deleted', user_name(), getdate() from inserted, deleted where inserted.id = deleted.ID;
		insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'FXRates', 'NEW => ' + isNULL(inserted.AsOfDate, '') + ' //' + isNULL(inserted.Currency ,'') + ' //' + 
		isNULL(inserted.Rate,'') + ' //' + isNULL(inserted.RateRisk,''), 'Updated', user_name(), getdate() from inserted, deleted where inserted.id = deleted.ID;
		--update [dbo].[FXRates] set [dbo].[FXRates].[TimeStamp] = getdate(), [dbo].[FXRates].[User] = user_name () 
		--from [dbo].[FXRates] inner join inserted as i on [dbo].[FXRates].ID = i.ID 
	END
GO
DISABLE TRIGGER [dbo].[FXRates-change-Log-update]
    ON [dbo].[FXRates];


GO


CREATE trigger [dbo].[FXRates-change-Log-delete] 
	on [dbo].[FXRates] 
	after delete 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
		select	'FXRates', isNULL(deleted.AsOfDate,'') + ' //' + isNULL(deleted.Currency,'') + ' //' + 
		isNULL(deleted.Rate,'') + ' //' + isNULL(deleted.RateRisk,'') , 'Deleted', user_name(), getdate() from deleted;
GO
DISABLE TRIGGER [dbo].[FXRates-change-Log-delete]
    ON [dbo].[FXRates];


GO

