CREATE TABLE [dbo].[table_Clearer_CashData_Archive] (
    [ID]                      INT           IDENTITY (1, 1) NOT NULL,
    [AsofDate]                DATETIME      NULL,
    [Account_Name]            VARCHAR (120) NULL,
    [Report_Date]             DATETIME      NOT NULL,
    [Opening_Balance]         FLOAT (53)    NULL,
    [Margin_Funds_Transfer]   FLOAT (53)    NULL,
    [Commission_Fees]         FLOAT (53)    NULL,
    [Interests]               FLOAT (53)    NULL,
    [Option_Premium]          FLOAT (53)    NULL,
    [Net_Invoice]             FLOAT (53)    NULL,
    [Invoiced_VAT]            FLOAT (53)    NULL,
    [Realized_PNL]            FLOAT (53)    NULL,
    [Closing_Balance]         FLOAT (53)    NULL,
    [Variation_Margin]        FLOAT (53)    NULL,
    [Net_Option_Value]        FLOAT (53)    NULL,
    [Initial_Margin]          FLOAT (53)    NULL,
    [Intercommodity_Credit]   FLOAT (53)    NULL,
    [Special_Delivery_Margin] FLOAT (53)    NULL,
    [Collateral_Used]         FLOAT (53)    NULL,
    [Prefunding_Amount]       FLOAT (53)    NULL,
    [Letter_of_Credit]        FLOAT (53)    NULL,
    [Excess_Deficit]          FLOAT (53)    NULL,
    [Commentary]              VARCHAR (500) NULL,
    [Security_Interest_Check] FLOAT (53)    NULL,
    [CCY]                     VARCHAR (3)   NOT NULL,
    [Product_Name]            VARCHAR (30)  NULL,
    [Commodity]               VARCHAR (30)  NULL,
    [Clearer_id]              INT           NOT NULL,
    [LastImport]              DATETIME      NOT NULL
);


GO

