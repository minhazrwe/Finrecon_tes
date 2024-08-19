CREATE TABLE [dbo].[SAP Ledger Mapping] (
    [ID]                   INT            IDENTITY (1, 1) NOT NULL,
    [Sachkonto]            NVARCHAR (255) NULL,
    [Produktname]          NVARCHAR (255) NULL,
    [Controling Structure] NVARCHAR (255) NULL,
    CONSTRAINT [pk_SAP_Ledger_Mapping] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

