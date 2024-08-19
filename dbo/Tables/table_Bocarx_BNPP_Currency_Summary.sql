CREATE TABLE [dbo].[table_Bocarx_BNPP_Currency_Summary] (
    [ID]                      INT           IDENTITY (1, 1) NOT NULL,
    [Report_Date]             DATE          NULL,
    [Opening_Balance]         FLOAT (53)    NULL,
    [Margin_Funds_Transfer]   FLOAT (53)    NULL,
    [Commission_And_Fees]     FLOAT (53)    NULL,
    [Interests]               FLOAT (53)    NULL,
    [Option_Premium]          FLOAT (53)    NULL,
    [Realised_PNL]            FLOAT (53)    NULL,
    [Closing_Balance]         FLOAT (53)    NULL,
    [Variation_Margin]        FLOAT (53)    NULL,
    [Net_Option_Value]        FLOAT (53)    NULL,
    [Initial_Margin]          FLOAT (53)    NULL,
    [Intercommodity_Credit]   FLOAT (53)    NULL,
    [Special_Delivery_Margin] FLOAT (53)    NULL,
    [Collateral_Used]         FLOAT (53)    NULL,
    [Letter_Of_Credit]        FLOAT (53)    NULL,
    [Excess_And_Deficit]      FLOAT (53)    NULL,
    [Summary_Comment]         VARCHAR (300) NULL,
    [Security_Interest_Check] FLOAT (53)    NULL,
    [Net_Invoice]             FLOAT (53)    NULL,
    [Invoiced_VAT]            FLOAT (53)    NULL,
    [CCY]                     VARCHAR (30)  NULL,
    [Account_Name]            VARCHAR (30)  NULL,
    [Report_Name]             VARCHAR (30)  NULL,
    [Clearer_ID]              INT           NOT NULL,
    [Last_Import]             DATETIME      CONSTRAINT [DF_table_Bocarx_BNPP_Currency_Summary_Last_Import] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_table_Bocarx_BNPP_Currency_Summary] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

