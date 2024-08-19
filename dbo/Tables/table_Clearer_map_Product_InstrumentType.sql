CREATE TABLE [dbo].[table_Clearer_map_Product_InstrumentType] (
    [ID]             INT            IDENTITY (1, 1) NOT NULL,
    [InstrumentType] NVARCHAR (100) NOT NULL,
    [CurveName]      NVARCHAR (100) NOT NULL,
    [ProductName]    NVARCHAR (100) NOT NULL,
    [LastUpdate]     DATETIME       CONSTRAINT [DF_table_Clearer_map_Product_InstrumentType_LastUpdate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_table_Clearer_map_Product_InstrumentType] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO


CREATE trigger [dbo].[table_Clearer_map_Product_InstrumentType_after_update] 
	on [dbo].[table_Clearer_map_Product_InstrumentType] 
	after update 
	as 
		BEGIN
		insert into dbo.[Change-Log] 
		(
			[Change-Table]
			,[Change-Entry]
			,[Change-Type]
			,[Change-Datetime]
		) 
		select			
			'table_Clearer_map_Product_InstrumentType'
			,'OLD => ' 
				+ isNULL(deleted.InstrumentType,'') + ' //' 
				+ isNULL(deleted.CurveName,'') + ' //' 
				+ isNULL(deleted.ProductName,'') 
			,'Updated'
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
			'table_Clearer_map_Product_InstrumentType'
			,'NEW => ' 
				+ isNULL(inserted.InstrumentType,'') + ' //' 
				+ isNULL(inserted.CurveName,'') + ' //' 
				+ isNULL(inserted.ProductName,'') 
			,'Updated'
			,getdate() 			
		from 
			inserted
			,deleted 
		where 
			inserted.id = deleted.ID;

		update [dbo].table_Clearer_map_Product_InstrumentType 
			set [dbo].table_Clearer_map_Product_InstrumentType.LastUpdate = getdate()
			from 
				[dbo].table_Clearer_map_Product_InstrumentType 
				inner join inserted as i on [dbo].table_Clearer_map_Product_InstrumentType.ID = i.ID 
	END

GO



CREATE trigger [dbo].[table_Clearer_map_Product_InstrumentType_after_delete]
	on [dbo].[table_Clearer_map_Product_InstrumentType] 
	after delete 
		as insert into dbo.[Change-Log] 
		(
			[Change-Table]
			,[Change-Entry]
			,[Change-Type]
			,[Change-Datetime]
		) 
		select 
			'table_Clearer_map_Product_InstrumentType'
      ,isNULL(deleted.InstrumentType,'') + ' //' 
				+ isNULL(deleted.CurveName,'') + ' //' 
				+ isNULL(deleted.ProductName,'') 
			,'Deleted'		
			,getdate() 
		from 
			deleted;

GO

CREATE trigger [dbo].[table_Clearer_map_Product_InstrumentType_after_insert] 
	on [dbo].[table_Clearer_map_Product_InstrumentType]
	after insert 
		as INSERT INTO dbo.[Change-Log] 
		(
			[Change-Table]
			,[Change-Entry]
			,[Change-Type]
			,[Change-Datetime]
		) 
		select 
			'table_Clearer_map_Product_InstrumentType'
      ,isNULL(inserted.InstrumentType,'') + ' //' 
				+ isNULL(inserted.CurveName,'') + ' //' 
				+ isNULL(inserted.ProductName,'') 
			,'Inserted'		
			,getdate() 
		from 
			inserted;

GO

