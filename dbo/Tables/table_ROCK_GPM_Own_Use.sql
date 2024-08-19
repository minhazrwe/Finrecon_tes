CREATE TABLE [dbo].[table_ROCK_GPM_Own_Use] (
    [cob]                    DATE           NULL,
    [Subsidiary]             VARCHAR (255)  NULL,
    [Strategy]               NVARCHAR (100) NULL,
    [Book]                   VARCHAR (255)  NULL,
    [Internal_Portfolio]     NVARCHAR (100) NULL,
    [Counterparty_Group]     NVARCHAR (100) NULL,
    [Volume]                 FLOAT (53)     NULL,
    [BuySell]                NVARCHAR (100) NULL,
    [Curve_Name]             NVARCHAR (100) NULL,
    [Projection_Index_Group] NVARCHAR (100) NULL,
    [Instrument_Type]        NVARCHAR (100) NULL,
    [UOM]                    NVARCHAR (100) NULL,
    [Int_Legal_Entity]       NVARCHAR (100) NULL,
    [Int_Bunit]              NVARCHAR (100) NULL,
    [Ext_Legal_Entity]       NVARCHAR (100) NULL,
    [Ext_Portfolio]          NVARCHAR (100) NULL,
    [DiscPnL_mEUR]           FLOAT (53)     NULL,
    [Accounting_Treatment]   NVARCHAR (100) NULL,
    [TermEndYear]            INT            NULL,
    [PNL_OCI]                VARCHAR (11)   NOT NULL,
    [CtpyGroup2]             NVARCHAR (100) NULL,
    [Non-derivative]         VARCHAR (14)   NOT NULL,
    [Volume_MWh]             FLOAT (53)     NULL,
    [UndiscPnL_mEUR]         FLOAT (53)     NULL,
    [Active_Period]          INT            NOT NULL
);


GO

