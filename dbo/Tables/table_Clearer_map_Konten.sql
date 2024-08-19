CREATE TABLE [dbo].[table_Clearer_map_Konten] (
    [ID]                 INT            IDENTITY (1, 1) NOT NULL,
    [Commodity]          NVARCHAR (100) NOT NULL,
    [FuturesBuy]         NVARCHAR (100) NOT NULL,
    [FuturesSell]        NVARCHAR (100) NOT NULL,
    [SwapBuy]            NVARCHAR (100) NOT NULL,
    [SwapSell]           NVARCHAR (100) NOT NULL,
    [OptionsBuy]         NVARCHAR (100) NOT NULL,
    [OptionsSell]        NVARCHAR (100) NOT NULL,
    [Fee]                NVARCHAR (100) NOT NULL,
    [MaterialCode]       NVARCHAR (100) NOT NULL,
    [MaterialCodeSwap]   NVARCHAR (100) NOT NULL,
    [MaterialCodeOption] NVARCHAR (100) NOT NULL,
    [MaterialCodeFEE]    NVARCHAR (100) NOT NULL,
    [LastUpdate]         DATETIME       CONSTRAINT [DF_table_map_Konten_LastUpdate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_table_map_Konten] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO



CREATE trigger [dbo].[table_Clearer_map_Konten_after_insert] 
	on [dbo].[table_Clearer_map_Konten]
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
			'table_Clearer_map_Konten'
      ,isNULL(inserted.Commodity,'') + ' //' 
				+ isNULL(inserted.FuturesBuy,'') + ' //' 
				+ isNULL(inserted.FuturesSell,'') + ' //' 
				+ isNULL(inserted.SwapBuy,'') + ' //' 
				+ isNULL(inserted.SwapSell,'') + ' //' 
				+ isNULL(inserted.OptionsBuy,'') + ' //' 
				+ isNULL(inserted.OptionsSell,'') + ' //' 
				+ isNULL(inserted.Fee,'') + ' //' 
				+ isNULL(inserted.MaterialCode,'') + ' //' 
				+ isNULL(inserted.MaterialCodeSwap,'') + ' //' 
				+ isNULL(inserted.MaterialCodeOption,'') + ' //' 
				+ isNULL(inserted.MaterialCodeFEE,'') 
			,'Inserted'		
			,getdate() 
			,CURRENT_USER
		from 
			inserted;

GO


CREATE trigger [dbo].[table_Clearer_map_Konten_after_delete]
	on [dbo].[table_Clearer_map_Konten] 
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
			'table_Clearer_map_Konten'
      ,isNULL(deleted.Commodity,'') + ' //' 
				+ isNULL(deleted.FuturesBuy,'') + ' //' 
				+ isNULL(deleted.FuturesSell,'') + ' //' 
				+ isNULL(deleted.SwapBuy,'') + ' //' 
				+ isNULL(deleted.SwapSell,'') + ' //' 
				+ isNULL(deleted.OptionsBuy,'') + ' //' 
				+ isNULL(deleted.OptionsSell,'') + ' //' 
				+ isNULL(deleted.Fee,'') + ' //' 
				+ isNULL(deleted.MaterialCode,'') + ' //' 
				+ isNULL(deleted.MaterialCodeSwap,'') + ' //' 
				+ isNULL(deleted.MaterialCodeOption,'') + ' //' 
				+ isNULL(deleted.MaterialCodeFEE,'') 
			,'Deleted'		
			,getdate() 
			,CURRENT_USER
		from 
			deleted;

GO


CREATE trigger [dbo].[table_Clearer_map_Konten_after_update] 
	on [dbo].[table_Clearer_map_Konten] 
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
			'table_Clearer_map_Konten'
			,'OLD => ' 
				+ isNULL(deleted.Commodity,'') + ' //' 
				+ isNULL(deleted.FuturesBuy,'') + ' //' 
				+ isNULL(deleted.FuturesSell,'') + ' //' 
				+ isNULL(deleted.SwapBuy,'') + ' //' 
				+ isNULL(deleted.SwapSell,'') + ' //' 
				+ isNULL(deleted.OptionsBuy,'') + ' //' 
				+ isNULL(deleted.OptionsSell,'') + ' //' 
				+ isNULL(deleted.Fee,'') + ' //' 
				+ isNULL(deleted.MaterialCode,'') + ' //' 
				+ isNULL(deleted.MaterialCodeSwap,'') + ' //' 
				+ isNULL(deleted.MaterialCodeOption,'') + ' //' 
				+ isNULL(deleted.MaterialCodeFEE,'') 
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
			'table_Clearer_map_Konten'
			,'NEW => ' 
				+ isNULL(inserted.Commodity,'') + ' //' 
				+ isNULL(inserted.FuturesBuy,'') + ' //' 
				+ isNULL(inserted.FuturesSell,'') + ' //' 
				+ isNULL(inserted.SwapBuy,'') + ' //' 
				+ isNULL(inserted.SwapSell,'') + ' //' 
				+ isNULL(inserted.OptionsBuy,'') + ' //' 
				+ isNULL(inserted.OptionsSell,'') + ' //' 
				+ isNULL(inserted.Fee,'') + ' //' 
				+ isNULL(inserted.MaterialCode,'') + ' //' 
				+ isNULL(inserted.MaterialCodeSwap,'') + ' //' 
				+ isNULL(inserted.MaterialCodeOption,'') + ' //' 
				+ isNULL(inserted.MaterialCodeFEE,'') 
			,'Updated'
			,getdate() 			
			,CURRENT_USER
		from 
			inserted
			,deleted 
		where 
			inserted.id = deleted.ID;

		update [dbo].table_Clearer_map_Konten 
			set [dbo].table_Clearer_map_Konten.LastUpdate = getdate()
			from 
				[dbo].table_Clearer_map_Konten 
				inner join inserted as i on [dbo].table_Clearer_map_Konten.ID = i.ID 
	END

GO

