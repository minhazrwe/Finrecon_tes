CREATE TABLE [dbo].[map_InterPE] (
    [ID]                INT           IDENTITY (1, 1) NOT NULL,
    [Subsidiary]        VARCHAR (255) NOT NULL,
    [CounterpartyGroup] VARCHAR (255) NOT NULL,
    [MappingGroup]      VARCHAR (255) NOT NULL,
    [LastUpdate]        DATETIME      CONSTRAINT [DF_map_InterPE_LastUpdate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [pk_map_InterPE] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [UK_map_InterPE] UNIQUE NONCLUSTERED ([Subsidiary] ASC, [CounterpartyGroup] ASC, [MappingGroup] ASC)
);


GO


CREATE trigger [dbo].[trigger_map_InterPE_afterUpdate] 
	on [dbo].[map_InterPE] 
	after update 
	AS 
	BEGIN

	--document old entry
		insert into dbo.[Change-Log] (
			[Change-Table], 
			[Change-Entry], 
			[Change-Type], 
			[Change-User], 
			[Change-Datetime]) 		
		select	
				'map_InterPE', 
				'OLD => ' + isNULL(deleted.Subsidiary,'') + ' //' + isNULL(deleted.CounterpartyGroup,'') + ' //' + + isNULL(deleted.MappingGroup,'')
				, 'Updated'
				, user_name()
				, getdate() 
			from 
				inserted, 
				deleted 
			where 
				inserted.id = deleted.ID;
		
--document new entry
		insert into dbo.[Change-Log] (
			[Change-Table], 
			[Change-Entry], 
			[Change-Type], 
			[Change-User], 
			[Change-Datetime]) 
			select	
				'map_InterPE', 
				'NEW => ' + isNULL(inserted.Subsidiary,'') + ' //' + isNULL(inserted.CounterpartyGroup,'') + ' //' + + isNULL(inserted.MappingGroup,'')
				, 'Updated'
				, user_name()
				, getdate() 
			from 
				inserted, 
				deleted 
			where 
				inserted.id = deleted.ID;
	
	-- trigger-action: update the "last update" timestamp field:
		update [dbo].[map_InterPE] set 
			[dbo].[map_InterPE].[LastUpdate] = getdate()
		from 
			[dbo].[map_InterPE] inner join inserted as i on [dbo].[map_InterPE].ID = i.ID 
	END

GO

