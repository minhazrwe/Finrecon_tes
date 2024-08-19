CREATE TABLE [dbo].[table_Clearer_map_LegalEntity_CompanyCode] (
    [ID]                INT           IDENTITY (1, 1) NOT NULL,
    [LegalEntity]       NVARCHAR (50) NOT NULL,
    [CompanyCode]       NVARCHAR (10) NOT NULL,
    [PETransferAccount] VARCHAR (50)  NULL,
    [CountryCode]       NVARCHAR (10) NOT NULL,
    [LastUpdate]        DATETIME      CONSTRAINT [DF_table_Clearer_map_LegalEntity_CompanyCode] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_table_Clearer_map_LegalEntity_CompanyCode] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

