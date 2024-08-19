CREATE TABLE [dbo].[mailcenter] (
    [ID]                 INT            IDENTITY (1, 1) NOT NULL,
    [topic]              VARCHAR (200)  NOT NULL,
    [mail_to]            VARCHAR (2000) NOT NULL,
    [mail_cc]            VARCHAR (2000) CONSTRAINT [DF_mailcenter_mail_cc] DEFAULT ('MFA-X-AccountingDataServices@rwe.com') NULL,
    [mail_bcc]           VARCHAR (2000) NULL,
    [mail_subject]       VARCHAR (200)  NULL,
    [mail_body]          VARCHAR (2000) NULL,
    [mail_atttachements] VARCHAR (2000) NULL,
    [mail_importance]    INT            NULL,
    [mail_lastSent]      DATETIME       NULL,
    [mail_comment]       VARCHAR (2000) NULL,
    [lastUpdate]         DATETIME       CONSTRAINT [DF_mailcenter_LastUpdate] DEFAULT (getdate()) NULL,
    [AutoSend]           TINYINT        NULL,
    CONSTRAINT [PK_mailcenter_ID] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [UK_mailcenter_Topic] UNIQUE NONCLUSTERED ([topic] ASC)
);


GO



CREATE trigger [dbo].[mailcenter_after_update] 
	on [dbo].[mailcenter] 
	after update 
	as 
		BEGIN
		insert into dbo.[Change-Log] 
		(
			[Change-Table]
			,[Change-Entry]
			,[Change-Type]
			--,[Change-User]
			,[Change-Datetime]
		) 
		select			
			'mailcenter'
			,'OLD => ' 
				+ isNULL(deleted.topic,'') + ' //' 
				+ isNULL(deleted.mail_to,'') + ' //' 
				+ isNULL(deleted.mail_cc,'') + ' //' 
				+ isNULL(deleted.mail_bcc,'') + ' //' 
				+ isNULL(deleted.mail_subject,'') + ' //' 
				+ isNULL(deleted.mail_body,'') + ' //' 
				+ isNULL(deleted.mail_atttachements,'') + ' //' 
				+ convert(varchar,isNULL(deleted.mail_importance,'')) + ' //' 
				+ isNULL(deleted.mail_comment,'') 
			,'Updated'
			--,user_name()
			,getdate() 
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
		) 
		select			
			'mailcenter'
			,'NEW => ' 
				+ isNULL(inserted.topic,'') + ' //' 
				+ isNULL(inserted.mail_to,'') + ' //' 
				+ isNULL(inserted.mail_cc,'') + ' //' 
				+ isNULL(inserted.mail_bcc,'') + ' //' 
				+ isNULL(inserted.mail_subject,'') + ' //' 
				+ isNULL(inserted.mail_body,'') + ' //' 
				+ isNULL(inserted.mail_atttachements,'') + ' //' 
				+ convert(varchar,isNULL(inserted.mail_importance,'')) + ' //' 
				+ isNULL(inserted.mail_comment,'') 
			,'Updated'
			,getdate() 			
		from 
			inserted
			,deleted 
		where 
			inserted.id = deleted.ID;

	/*now update the lastupdate coulmn*/
		update [dbo].mailcenter 
			set [dbo].mailcenter.LastUpdate = getdate()
			from 
				[dbo].mailcenter 
				inner join inserted as i on [dbo].mailcenter.ID = i.ID 
	END

GO



CREATE trigger [dbo].[mailcenter_after_delete]
	on [dbo].[mailcenter] 
	after delete 
		as insert into dbo.[Change-Log] 
		(
			[Change-Table]
			,[Change-Entry]
			,[Change-Type]
			--,[Change-User]
			,[Change-Datetime]
		) 
		select 
			'mailcenter'
      ,isNULL(deleted.topic,'') + ' //' 
				+ isNULL(deleted.mail_to,'') + ' //' 
				+ isNULL(deleted.mail_cc,'') + ' //' 
				+ isNULL(deleted.mail_bcc,'') + ' //' 
				+ isNULL(deleted.mail_subject,'') + ' //' 
				+ isNULL(deleted.mail_body,'') + ' //' 
				+ isNULL(deleted.mail_atttachements,'') + ' //' 
				+ convert(varchar,isNULL(deleted.mail_importance,'')) + ' //' 
				+ isNULL(deleted.mail_comment,'') 
			,'Deleted'		
			--,user_name()
			,getdate() 
		from 
			deleted;

GO

	 
CREATE trigger [dbo].[mailcenter_after_insert] 
	on [dbo].[mailcenter]
	after insert 
		as INSERT INTO dbo.[Change-Log] 
		(
			[Change-Table]
			,[Change-Entry]
			,[Change-Type]
			--,[Change-User]
			,[Change-Datetime]
		) 
		select 
			'mailcenter'
				,isNULL(inserted.topic,'') + ' //' 
				+ isNULL(inserted.mail_to,'') + ' //' 
				+ isNULL(inserted.mail_cc,'') + ' //' 
				+ isNULL(inserted.mail_bcc,'') + ' //' 
				+ isNULL(inserted.mail_subject,'') + ' //' 
				+ isNULL(inserted.mail_body,'') + ' //' 
				+ isNULL(inserted.mail_atttachements,'') + ' //' 
				+ convert(varchar,isNULL(inserted.mail_importance,'')) + ' //' 
				+ isNULL(inserted.mail_comment,'') 
			,'Inserted'		
			--,user_name()
			,getdate() 
		from 
			inserted;

GO

