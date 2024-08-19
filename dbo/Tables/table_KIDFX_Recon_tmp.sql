CREATE TABLE [dbo].[table_KIDFX_Recon_tmp] (
    [Reference_ID]           NVARCHAR (50) NULL,
    [Trade_Date]             DATE          NULL,
    [Term_End]               DATE          NULL,
    [Internal_Portfolio]     NVARCHAR (50) NULL,
    [Counterparty]           NVARCHAR (50) NULL,
    [Counterparty_Group]     NVARCHAR (50) NULL,
    [Volume]                 FLOAT (53)    NULL,
    [Curve_Name]             NVARCHAR (50) NULL,
    [Projection_Index_Group] NVARCHAR (50) NULL,
    [Instrument_Type]        NVARCHAR (50) NULL,
    [Fixed_Price_CCY]        NVARCHAR (50) NULL,
    [Discounted_PNL]         FLOAT (53)    NULL,
    [Subsidiary]             NVARCHAR (50) NULL,
    [Transaction_Type]       NVARCHAR (50) NULL,
    [Reference]              NVARCHAR (50) NULL
);


GO

