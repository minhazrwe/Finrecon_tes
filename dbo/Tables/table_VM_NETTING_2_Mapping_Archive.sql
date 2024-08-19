CREATE TABLE [dbo].[table_VM_NETTING_2_Mapping_Archive] (
    [ID]           INT            IDENTITY (1, 1) NOT NULL,
    [AsofDate]     DATETIME       NULL,
    [Product]      NVARCHAR (255) NULL,
    [ExchangeCode] NVARCHAR (255) NULL,
    [ExternalBU]   NVARCHAR (255) NULL,
    [NettingType]  NVARCHAR (255) NULL,
    [LastUpdate]   DATETIME       NULL
);


GO

