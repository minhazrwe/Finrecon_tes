CREATE TABLE [dbo].[Adjustments] (
    [ID]                    INT           IDENTITY (1, 1) NOT NULL,
    [ReconGroup]            VARCHAR (40)  NOT NULL,
    [OrderNo]               VARCHAR (255) NOT NULL,
    [DeliveryMonth]         VARCHAR (255) NULL,
    [DealID]                VARCHAR (255) NULL,
    [Account]               VARCHAR (255) NULL,
    [Currency]              VARCHAR (255) NULL,
    [Quantity]              FLOAT (53)    NULL,
    [Realised_CCY]          FLOAT (53)    NULL,
    [Category]              VARCHAR (255) NULL,
    [Comment]               VARCHAR (255) NULL,
    [Valid_From]            DATETIME      NULL,
    [Valid_To]              DATETIME      NULL,
    [ExternalBusinessUnit]  VARCHAR (100) NULL,
    [Partner]               VARCHAR (20)  NULL,
    [VAT]                   VARCHAR (20)  NULL,
    [Internal_Portfolio_ID] VARCHAR (100) NULL,
    [External_Portfolio]    VARCHAR (100) NULL,
    [user]                  VARCHAR (255) NOT NULL,
    [timestamp]             DATETIME      NOT NULL,
    [CompanyCode]           VARCHAR (4)   NULL,
    CONSTRAINT [PK_Adjustments_2023] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO




CREATE trigger [dbo].[Adjustments-change-Log-insert] 
	on [dbo].[Adjustments]
	after insert 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
	select 
	'Adjustments'
	, isNULL(inserted.ReconGroup,'') + ' //' 
	+ isNULL(inserted.OrderNo,'') + ' //' 
	+ isNULL(inserted.DeliveryMonth,'') + ' //' 
	+ isNULL(inserted.DealID,'') + ' //' 
	+ isNULL(inserted.Account,'') + ' //' 
	+ isNULL(inserted.Currency,'') + ' //' 
	+ isNULL(convert(varchar,inserted.Quantity),'') + ' //' 
	+ isNULL(convert(varchar,inserted.Realised_CCY),'') + ' //'
	+ isNULL(inserted.Category,'') + ' //' 
	+ isNULL(inserted.Comment,'') + ' //' 
	+ isNULL(convert(char(10),inserted.Valid_From,126),'') + ' //' 
	+ isNULL(convert(char(10),inserted.Valid_To,126),'') + ' //' 
	+ isNULL(inserted.ExternalBusinessUnit,'') + ' //' 
	+ isNULL(inserted.Partner,'') + ' //' 
	+ isNULL(inserted.VAT,''), 
	'Inserted'
	, user_name()
	, getdate() 
	from inserted;

GO




CREATE trigger [dbo].[Adjustments-change-Log-delete] 
	on [dbo].[Adjustments] 
	after delete 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
	select 
	'Adjustments'
	, isNULL(deleted.ReconGroup,'') + ' //' 
		+ isNULL(deleted.OrderNo,'') + ' //' 
		+ isNULL(deleted.DeliveryMonth,'') + ' //' 
		+ isNULL(deleted.DealID,'') + ' //' 
		+ isNULL(deleted.Account,'') + ' //' 
		+ isNULL(deleted.Currency,'') + ' //' +  ' //' 
		+ isNULL(convert(varchar,deleted.Quantity),'') + ' //' 
		+ isNULL(convert(varchar,deleted.Realised_CCY),'') + ' //'  
		+ isNULL(deleted.Category,'') + ' //' 
		+ isNULL(deleted.Comment,'') + ' //' 
		+ isNULL(convert(char(10),deleted.Valid_From,126),'') + ' //' 
		+ isNULL(convert(char(10),deleted.Valid_To,126),'') + ' //' 
		+ isNULL(deleted.ExternalBusinessUnit,'') + ' //' 
		+ isNULL(deleted.Partner,'') + ' //' 
		+ isNULL(deleted.VAT,'')
, 'Deleted'
, user_name()
, getdate() 
from deleted;

GO





/*This Trigger will check if the username has the proper format. 
If this is not the case it is most likely that someone has tried to overwrite the username on insert*/
CREATE TRIGGER [dbo].[Adjustments-Check-Username-On-Insert]
ON [dbo].[Adjustments]
INSTEAD OF INSERT
AS
BEGIN
    -- Check if the user tries to fill the column [user]
    IF EXISTS (SELECT * FROM inserted WHERE [user] is not null)
    BEGIN
		RAISERROR ('[Adjustments-Check-Username-On-Insert] - Username should not be filled manually', 16, 1);
        RETURN;
    END
	
	-- Check if the user tries to fill the column [timestamp]
	IF EXISTS (SELECT * FROM inserted WHERE [timestamp] is not null)
    BEGIN
		RAISERROR ('[Adjustments-Check-Username-On-Insert] - Timestamp should not be filled manually', 16, 1);
        RETURN;
    END

    -- Update if the user did not try to fill [user] or [timestamp]
    INSERT INTO [dbo].[Adjustments] 
    (
        [ReconGroup]
      ,[OrderNo]
      ,[DeliveryMonth]
      ,[DealID]
      ,[Account]
      ,[Currency]
      ,[Quantity]
      ,[Realised_CCY]
      ,[Category]
      ,[Comment]
      ,[Valid_From]
      ,[Valid_To]
      ,[ExternalBusinessUnit]
      ,[Partner]
      ,[VAT]
      ,[Internal_Portfolio_ID]
      ,[External_Portfolio]
      ,[user]
      ,[timestamp]
    )
    SELECT
        [ReconGroup]
      ,[OrderNo]
      ,[DeliveryMonth]
      ,[DealID]
      ,[Account]
      ,[Currency]
      ,[Quantity]
      ,[Realised_CCY]
      ,[Category]
      ,[Comment]
      ,[Valid_From]
      ,[Valid_To]
      ,[ExternalBusinessUnit]
      ,[Partner]
      ,[VAT]
      ,[Internal_Portfolio_ID]
      ,[External_Portfolio]
		,USER_NAME()
		,getdate()
    FROM inserted;
END

GO




/*This Trigger will check if the username has the proper format. 
If this is not the case it is most likely that someone has tried to overwrite the username on insert*/
CREATE TRIGGER [dbo].[Adjustments-Check-Username-On-Update]
ON [dbo].[Adjustments]
INSTEAD OF UPDATE
AS
BEGIN
    -- Check if the user tries to fill the column [user]
    IF EXISTS (SELECT * FROM inserted i INNER JOIN deleted d ON i.ID = d.ID WHERE i.[user] is not null and i.[user] <> d.[user] )
    BEGIN
        RAISERROR ('[Adjustments-Check-Username-On-Update] - Username should not be filled manually.', 16, 1);
        RETURN;
    END
	
	-- Check if the user tries to fill the column [timestamp]
	IF EXISTS (SELECT * FROM inserted i INNER JOIN deleted d ON i.ID = d.ID WHERE i.[timestamp] is not null and i.[timestamp] <> d.[timestamp] )
    BEGIN
        RAISERROR ('[Adjustments-Check-Username-On-Update] - Timestamp should not be filled manually.', 16, 1);
        RETURN;
    END

    -- Update if the user did not try to fill [user] or [timestamp]
    UPDATE a
    SET
		a.[ReconGroup] = i.[ReconGroup],
		a.[OrderNo] = i.[OrderNo],
		a.[DeliveryMonth] = i.[DeliveryMonth],
		a.[DealID] = i.[DealID],
		a.[Account] = i.[Account],
		a.[Currency] = i.[Currency],
		a.[Quantity] = i.[Quantity],
		a.[Realised_CCY] = i.[Realised_CCY],
		a.[Category] = i.[Category],
		a.[Comment] = i.[Comment],
		a.[Valid_From] = i.[Valid_From],
		a.[Valid_To] = i.[Valid_To],
		a.[ExternalBusinessUnit] = i.[ExternalBusinessUnit],
		a.[Partner] = i.[Partner],
		a.[VAT] = i.[VAT],
		a.[Internal_Portfolio_ID] = i.[Internal_Portfolio_ID],
		a.[External_Portfolio] = i.[External_Portfolio],
		a.[user] = USER_NAME(),
		a.[timestamp] = getdate()
    FROM [dbo].[Adjustments] a
    INNER JOIN inserted i ON a.ID = i.ID
   
END

GO




CREATE trigger [dbo].[Adjustments-change-Log-update] 
	on [dbo].[Adjustments] 
	after update 
	as 
	BEGIN
	
		/* document the old entry */
		INSERT INTO dbo.[Change-Log] 
			(
			 [Change-Table]
			,[Change-Entry]
			,[Change-Type]
			,[Change-User] 
			,[Change-Datetime]
			)
			SELECT 
				'Adjustments'
				,'OLD => ' 
					+ isNULL(deleted.ReconGroup,'') + ' //' 
					+ isNULL(deleted.OrderNo,'') + ' //' 
					+ isNULL(deleted.DeliveryMonth,'') + ' //' 
					+ isNULL(deleted.DealID,'') + ' //' 
					+ isNULL(deleted.Account,'') + ' //' 
					+ isNULL(deleted.Currency,'') + ' //' +  ' //' 
					+ isNULL(convert(varchar,deleted.Quantity),'') + ' //' 
					+ isNULL(convert(varchar,deleted.Realised_CCY),'') + ' //'
					+ isNULL(deleted.Category,'') + ' //' 
					+ isNULL(deleted.Comment,'') + ' //' 
					+ isNULL(convert(char(10),deleted.Valid_From,126),'') + ' //' 
					+ isNULL(convert(char(10),deleted.Valid_To,126),'') + ' //' 
					+ isNULL(deleted.ExternalBusinessUnit,'') + ' //' 
					+ isNULL(deleted.Partner,'') + ' //' 
					+ isNULL(deleted.VAT,'')
				,'Updated'
				,user_name()
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
			,[Change-User]
			,[Change-Datetime]
			)
		SELECT 
			'Adjustments'
			,'NEW => ' 
				+ isNULL(inserted.ReconGroup,'') + ' //' 
				+ isNULL(inserted.OrderNo,'') + ' //' 
				+ isNULL(inserted.DeliveryMonth,'') + ' //' 
				+ isNULL(inserted.DealID,'')  + ' //' 
				+ isNULL(inserted.Account,'') + ' //' 
				+ isNULL(inserted.Currency,'') + ' //' +  ' //' 
				+ isNULL(convert(varchar,inserted.Quantity),'') + ' //' 
				+ isNULL(convert(varchar,inserted.Realised_CCY),'') + ' //'
				+ isNULL(inserted.Category,'') + ' //' 
				+ isNULL(inserted.Comment,'') + ' //' 
				+ isNULL(convert(char(10),inserted.Valid_From,126),'') + ' //' 
				+ isNULL(convert(char(10),inserted.Valid_To,126),'') + ' //' 
				+ isNULL(inserted.ExternalBusinessUnit,'') + ' //' 
				+ isNULL(inserted.Partner,'') + ' //' 
				+ isNULL(inserted.VAT,'')
			,'Updated'
			,user_name()
			,getdate()
			FROM 
					inserted
				,deleted
			WHERE 
				inserted.id = deleted.ID;

	END

GO

