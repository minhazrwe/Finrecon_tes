CREATE TABLE [dbo].[map_order] (
    [ID]             INT           IDENTITY (1, 1) NOT NULL,
    [System]         VARCHAR (255) NOT NULL,
    [LegalEntity]    VARCHAR (50)  NOT NULL,
    [Desk]           VARCHAR (50)  NOT NULL,
    [Desk_ID]        VARCHAR (50)  NULL,
    [SubDesk]        VARCHAR (255) NULL,
    [SubDesk_ID]     VARCHAR (50)  NULL,
    [RevRecSubDesk]  VARCHAR (255) NULL,
    [Book]           VARCHAR (255) NULL,
    [Book_ID]        VARCHAR (50)  NULL,
    [Portfolio]      VARCHAR (90)  NOT NULL,
    [PortfolioID]    VARCHAR (50)  NULL,
    [OrderNo]        VARCHAR (50)  NOT NULL,
    [Ref3]           VARCHAR (255) NULL,
    [ProfitCenter]   VARCHAR (255) NULL,
    [SubDeskCCY]     VARCHAR (3)   NOT NULL,
    [CommodityForFX] VARCHAR (50)  NULL,
    [Comment]        VARCHAR (255) NULL,
    [RepCCY]         VARCHAR (3)   NULL,
    [User]           VARCHAR (255) CONSTRAINT [DF_map_order_user1] DEFAULT (user_name()) NOT NULL,
    [TimeStamp]      DATETIME      CONSTRAINT [DF_map_order_TimeStamp1] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_map_order_2] PRIMARY KEY CLUSTERED ([Portfolio] ASC)
);


GO

CREATE trigger [dbo].[map_Order-change-Log-insert] 
	on dbo.map_order
	after insert 
	as 
	insert into dbo.[Change-Log] 
	(
		[Change-Table]
		, [Change-Entry]
		, [Change-Type]
		, [Change-User]
		, [Change-Datetime]
	) 
	select 
		'map_order'
		, isNULL(inserted.Book,'') + ' //' 
		+ isNULL(inserted.CommodityForFX,'') + ' //' 
		+ isNULL(inserted.Desk,'') + ' //' 
			+ isNULL(inserted.OrderNo,'') + ' //' 
			+ isNULL(inserted.Portfolio,'') + ' //' +  ' //' 
			+ isNULL(inserted.ProfitCenter,'') + ' //' 
			+ isNULL(inserted.Ref3,'') + ' //' 
			+ isNULL(inserted.RepCCY,'') + ' //' 
			+ isNULL(inserted.SubDesk,'')	+ ' //' 
			+ isNULL(inserted.SubDeskCCY,'') + ' //' 
			+ isNULL(inserted.[System],'')
		, 'Inserted'
		, user_name()
		, getdate() 
	from 
		inserted;

GO

/* trigger reactivated 2022-05-20, with deativated logging of user who did the changes, as this is not approved by workers council 
deactivation was discussed in mfa-x daystart meeting on 2022-05-20)*/

CREATE trigger [dbo].[map_order-change-Log-update] 
	on dbo.map_order 
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
				'map_order'
				,'OLD => ' 
					+ isNULL(deleted.[System], '') + ' //' 
					+ isNULL(deleted.LegalEntity, '') + ' //' 
					+ isNULL(deleted.Desk, '') + ' //' 
					+ isNULL(deleted.SubDesk, '') + ' //' 
					+ isNULL(deleted.Book, '') + ' //' 
					+ isNULL(deleted.Portfolio, '') + ' //' + ' //' 
					+ isNULL(deleted.PortfolioId, '') + ' //' + ' //' 
					+ isNULL(deleted.OrderNo, '') + ' //' 
					+ isNULL(deleted.Ref3, '') + ' //' 
					+ isNULL(deleted.ProfitCenter, '') + ' //' 
					+ isNULL(deleted.SubDeskCCY, '') + ' //' 
					+ isNULL(deleted.CommodityForFX, '') + ' //' 
					+ isNULL(deleted.RepCCY, '') + ' //'
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
			'map_order'
			,'NEW => ' 
				+ isNULL(inserted.[System], '') + ' //' 
				+ isNULL(inserted.LegalEntity, '') + ' //' 
				+ isNULL(inserted.Desk, '') + ' //' 
				+ isNULL(inserted.SubDesk, '') + ' //' 
				+ isNULL(inserted.Book, '') + ' //' 
				+ isNULL(inserted.Portfolio, '') + ' //' + ' //' 
				+ isNULL(inserted.PortfolioId, '') + ' //' + ' //' 
				+ isNULL(inserted.OrderNo, '') + ' //' 
				+ isNULL(inserted.Ref3, '') + ' //' 
				+ isNULL(inserted.ProfitCenter, '') + ' //' 
				+ isNULL(inserted.SubDeskCCY, '') + ' //' 
				+ isNULL(inserted.CommodityForFX, '') + ' //' 
				+ isNULL(inserted.RepCCY, '') + ' //'
			,'Updated'
			,user_name()
			,getdate()
			FROM 
					inserted
				,deleted
			WHERE 
				inserted.id = deleted.ID;

		UPDATE [dbo].map_order
		SET 
			dbo.map_order.TimeStamp = getdate()
			,[dbo].map_order.[User] = user_name()
		FROM 
			[dbo].map_order
			INNER JOIN inserted ON [dbo].map_order.ID = inserted.ID
	END

GO

CREATE trigger [dbo].[map_order-change-Log-delete] 
	on dbo.map_order 
	after delete 
	as insert into dbo.[Change-Log] ([Change-Table], [Change-Entry], [Change-Type], [Change-User], [Change-Datetime]) 
	select 'map_order', isNULL(deleted.Book,'') + ' //' + isNULL(deleted.CommodityForFX,'') + ' //' + isNULL(deleted.Desk,'')
		+ ' //' + isNULL(deleted.OrderNo,'') + ' //' + isNULL(deleted.Portfolio,'') + ' //' +  ' //' + isNULL(deleted.ProfitCenter,'') + ' //' + isNULL(deleted.Ref3,'') 
		+ ' //' + isNULL(deleted.RepCCY,'') + ' //' + isNULL(deleted.SubDesk,'')
	 + ' //' + isNULL(deleted.SubDeskCCY,'') + ' //' + isNULL(deleted.[System],''), 'Deleted', user_name(), getdate() from deleted;

GO

