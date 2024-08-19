CREATE TABLE [dbo].[table_ROCK_GPM_FT_Data] (
    [COB]                    DATETIME       NULL,
    [Subsidiary]             NVARCHAR (100) NULL,
    [Strategy]               NVARCHAR (100) NULL,
    [Reference_ID]           NVARCHAR (100) NULL,
    [Trade_Date]             DATE           NULL,
    [Term_Start]             DATE           NULL,
    [Term_End]               DATE           NULL,
    [Internal_Portfolio]     NVARCHAR (100) NULL,
    [Counterparty_Ext_Bunit] NVARCHAR (100) NULL,
    [Counterparty_Group]     NVARCHAR (100) NULL,
    [Volume]                 FLOAT (53)     NULL,
    [Header_Buy_Sell]        NVARCHAR (100) NULL,
    [Curve_Name]             NVARCHAR (100) NULL,
    [Projection_Index_Group] NVARCHAR (100) NULL,
    [Instrument_Type]        NVARCHAR (100) NULL,
    [UOM]                    NVARCHAR (100) NULL,
    [Int_Legal_Entity]       NVARCHAR (100) NULL,
    [Int_Bunit]              NVARCHAR (100) NULL,
    [Ext_Legal_Entity]       NVARCHAR (100) NULL,
    [Ext_Portfolio]          NVARCHAR (100) NULL,
    [Discounted_PNL]         FLOAT (53)     NULL,
    [Undiscounted_PNL]       FLOAT (53)     NULL,
    [Accounting_Treatment]   NVARCHAR (100) NULL,
    [Reference]              NVARCHAR (100) NULL,
    [Product]                NVARCHAR (100) NULL,
    [FileID]                 INT            NULL,
    [Lastupdate]             DATETIME       CONSTRAINT [DF_table_ROCK_GPM_FT_Data_LastUpdate] DEFAULT (getdate()) NULL
);


GO

