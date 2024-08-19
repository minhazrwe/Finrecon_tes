CREATE TABLE [dbo].[innogy_split FT_all_before closing converted] (
    [COB]                    DATETIME     NULL,
    [Subsidiary]             VARCHAR (50) NULL,
    [Reference ID]           VARCHAR (50) NULL,
    [Trade Date]             DATETIME     NULL,
    [Term Start]             DATETIME     NULL,
    [Term End]               DATETIME     NULL,
    [Internal Portfolio]     VARCHAR (50) NULL,
    [Source System Book ID]  VARCHAR (50) NULL,
    [Counterparty Ext Bunit] VARCHAR (50) NULL,
    [Counterparty Group]     VARCHAR (50) NULL,
    [Volume]                 FLOAT (53)   NULL,
    [Fixed Price]            FLOAT (53)   NULL,
    [Curve Name]             VARCHAR (50) NULL,
    [Projection Index Group] VARCHAR (50) NULL,
    [Instrument Type]        VARCHAR (50) NULL,
    [UOM]                    VARCHAR (50) NULL,
    [Ext legal Entity]       VARCHAR (50) NULL,
    [Ext Portfolio]          VARCHAR (50) NULL,
    [Product]                VARCHAR (50) NULL,
    [Discounted MtM]         FLOAT (53)   NULL,
    [Discounted PnL]         FLOAT (53)   NULL,
    [Discounted AOCI]        FLOAT (53)   NULL,
    [Undiscounted PNL]       FLOAT (53)   NULL,
    [Undiscounted AOCI]      FLOAT (53)   NULL,
    [Volume Available]       FLOAT (53)   NULL,
    [Volume Used]            FLOAT (53)   NULL
);


GO

