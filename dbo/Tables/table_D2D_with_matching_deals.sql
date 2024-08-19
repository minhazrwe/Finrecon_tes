CREATE TABLE [dbo].[table_D2D_with_matching_deals] (
    [group]                VARCHAR (100)   NULL,
    [IntDesk]              VARCHAR (100)   NULL,
    [ExtDesk]              VARCHAR (50)    NULL,
    [Commodity]            VARCHAR (100)   NULL,
    [OrderNo]              VARCHAR (100)   NULL,
    [UNIT_TO]              VARCHAR (100)   NULL,
    [Unit]                 VARCHAR (100)   NULL,
    [Volume_new]           FLOAT (53)      NULL,
    [Deal]                 VARCHAR (100)   NULL,
    [OffsetDealNumber]     INT             NULL,
    [Reference]            VARCHAR (100)   NULL,
    [Tran Status]          VARCHAR (100)   NULL,
    [InstrumentType]       VARCHAR (100)   NULL,
    [InternalLegalEntity]  VARCHAR (100)   NULL,
    [InternalBusinessUnit] VARCHAR (100)   NULL,
    [PfID]                 VARCHAR (100)   NULL,
    [InternalPortfolio]    VARCHAR (100)   NULL,
    [ExternalBusinessUnit] VARCHAR (100)   NULL,
    [ExternalLegalEntity]  VARCHAR (100)   NULL,
    [ExternalPortfolio]    VARCHAR (100)   NULL,
    [Currency]             VARCHAR (5)     NULL,
    [Action]               VARCHAR (5)     NULL,
    [DocumentNumber]       INT             NULL,
    [EventDate]            VARCHAR (100)   NULL,
    [TradeDate]            DATETIME        NULL,
    [DeliveryMonth]        VARCHAR (100)   NULL,
    [FXRate]               FLOAT (53)      NULL,
    [Realised]             NUMERIC (20, 2) NULL,
    [CashflowType]         VARCHAR (100)   NULL,
    [InstrumentSubType]    VARCHAR (100)   NULL,
    [Ticker]               VARCHAR (100)   NULL,
    [SAP_Account]          VARCHAR (100)   NULL,
    [LegalEntity]          VARCHAR (100)   NULL,
    [Partner]              VARCHAR (255)   NULL,
    [StKZ_zw1]             VARCHAR (255)   NULL,
    [VAT_CountryCode]      VARCHAR (255)   NULL,
    [LegEndDate]           DATETIME        NULL,
    [UpdateKonten]         VARCHAR (255)   NULL
);


GO

