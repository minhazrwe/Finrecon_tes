CREATE TABLE [dbo].[SAP_2020] (
    [ID]                    INT           IDENTITY (1, 1) NOT NULL,
    [CompanyCode]           INT           NULL,
    [Account]               VARCHAR (50)  NULL,
    [OffsettingAccount]     VARCHAR (50)  NULL,
    [DocumentHeaderText]    VARCHAR (300) NULL,
    [Reference]             VARCHAR (50)  NULL,
    [Assignment]            VARCHAR (50)  NULL,
    [DocumentNumber]        VARCHAR (50)  NULL,
    [BusinessArea]          VARCHAR (50)  NULL,
    [DocumentType]          VARCHAR (50)  NULL,
    [PostingDate]           DATE          NULL,
    [DocumentDate]          DATE          NULL,
    [PostingKey]            INT           NULL,
    [Amountinlocalcurrency] FLOAT (53)    NULL,
    [LocalCurrency]         VARCHAR (50)  NULL,
    [Taxcode]               VARCHAR (50)  NULL,
    [ClearingDocument]      VARCHAR (50)  NULL,
    [Text]                  VARCHAR (50)  NULL,
    [TradingPartner]        VARCHAR (50)  NULL,
    [TransactionType]       VARCHAR (50)  NULL,
    [Documentcurrency]      VARCHAR (50)  NULL,
    [Amountindoccurr]       FLOAT (53)    NULL,
    [Order]                 VARCHAR (50)  NULL,
    [CostCenter]            VARCHAR (50)  NULL,
    [Quantity]              FLOAT (53)    NULL,
    [BaseUnitofMeasure]     VARCHAR (50)  NULL,
    [Material]              VARCHAR (50)  NULL,
    [RefKey1]               VARCHAR (50)  NULL,
    [RefKey2]               VARCHAR (50)  NULL,
    [RefKey3]               VARCHAR (50)  NULL,
    [Username]              VARCHAR (50)  NULL,
    [EntryDate]             DATE          NULL,
    [EntryTime]             TIME (7)      NULL,
    [TimeStamp]             DATETIME      NULL
);


GO

