CREATE TABLE [dbo].[table_unrealised_rawdata_Adjustments] (
    [COB]                          VARCHAR (100)  NULL,
    [Desk_Name]                    VARCHAR (100)  NULL,
    [Internal_Portfolio]           VARCHAR (100)  NULL,
    [Adjustment_Category]          VARCHAR (100)  NULL,
    [Adjustment_ID]                VARCHAR (200)  NOT NULL,
    [Adjustment_COMMENT]           VARCHAR (2000) NULL,
    [Cashflow_CCY]                 VARCHAR (20)   NULL,
    [Accounting_COMMENT]           VARCHAR (2000) NULL,
    [Exclude_Adjustment_Category]  VARCHAR (100)  NULL,
    [Exclude_Manual]               VARCHAR (100)  NULL,
    [Portfolio_ID]                 VARCHAR (100)  NULL,
    [Counterparty_Group]           VARCHAR (100)  NULL,
    [Instrument_Type]              VARCHAR (100)  NULL,
    [Accounting_Treatment]         VARCHAR (100)  NULL,
    [Accounting_Delivery_Month]    VARCHAR (100)  NULL,
    [Term_Start]                   VARCHAR (100)  NULL,
    [Term_End]                     VARCHAR (100)  NULL,
    [Deal_Number]                  VARCHAR (20)   NULL,
    [External_Business_Unit]       VARCHAR (100)  NULL,
    [Cashflow_Type]                VARCHAR (100)  NULL,
    [Unit_Of_Account]              VARCHAR (20)   NULL,
    [Partner_Code]                 VARCHAR (100)  NULL,
    [Internal_Legal_Entity]        VARCHAR (100)  NULL,
    [Volume]                       VARCHAR (100)  NULL,
    [Unrealised_Discounted_BU_CCY] VARCHAR (100)  NULL
);


GO

