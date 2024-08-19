CREATE TABLE [dbo].[temp_destatis_report] (
    [VertragsNummer]        NCHAR (100)   NULL,
    [AccountName]           VARCHAR (255) NULL,
    [Account]               VARCHAR (50)  NULL,
    [DocumentNumber]        VARCHAR (50)  NULL,
    [DocumentType]          VARCHAR (50)  NULL,
    [Order]                 VARCHAR (50)  NULL,
    [Text]                  VARCHAR (50)  NULL,
    [Assignment]            VARCHAR (50)  NULL,
    [PostingDate]           DATE          NULL,
    [DocumentDate]          DATE          NULL,
    [EntryDate]             DATE          NULL,
    [Amountinlocalcurrency] FLOAT (53)    NULL,
    [Quantity]              FLOAT (53)    NULL,
    [BaseUnitofMeasure]     VARCHAR (50)  NULL,
    [customer_name]         VARCHAR (50)  NULL,
    [commodity]             VARCHAR (5)   NULL
);


GO

