CREATE TABLE [dbo].[table_VM_NETTING_2_Mapping] (
    [ID]           INT            IDENTITY (1, 1) NOT NULL,
    [Product]      NVARCHAR (255) NULL,
    [ExchangeCode] NVARCHAR (255) NULL,
    [ExternalBU]   NVARCHAR (255) NULL,
    [NettingType]  NVARCHAR (255) NULL,
    [LastUpdate]   DATETIME       CONSTRAINT [DF_table_VM_NETTING_2_Mapping_New_LastUpdate] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_table_VM_NETTING_Mapping] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [UK_table_VM_NETTING_Mapping] UNIQUE NONCLUSTERED ([Product] ASC, [ExchangeCode] ASC)
);


GO

