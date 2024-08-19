CREATE TABLE [dbo].[table_HA_Trades] (
    [COB]                    DATE          NULL,
    [Reference_ID]           INT           NULL,
    [Trade_Date]             DATE          NULL,
    [Term_Start]             DATE          NULL,
    [Term_End]               DATE          NULL,
    [Internal_Portfolio]     VARCHAR (100) NULL,
    [Counterparty_Group]     VARCHAR (100) NULL,
    [Volume]                 FLOAT (53)    NULL,
    [Curve_Name]             VARCHAR (100) NULL,
    [Projection_Index_Group] VARCHAR (100) NULL,
    [Instrument_Type]        VARCHAR (100) NULL,
    [Int_Bunit]              VARCHAR (100) NULL,
    [Ext_Portfolio]          VARCHAR (100) NULL,
    [Discounted_PNL]         FLOAT (53)    NULL,
    [Start_Date]             DATE          NULL,
    [End_Date]               DATE          NULL,
    [Strategy]               VARCHAR (100) NULL,
    [Subsidiary]             VARCHAR (100) NULL,
    [Accounting_Treatment]   VARCHAR (100) NULL,
    [FileID]                 INT           NULL,
    [LastUpdate]             DATETIME      CONSTRAINT [DF_table_Trades_LastUpdate] DEFAULT (getdate()) NULL
);


GO

