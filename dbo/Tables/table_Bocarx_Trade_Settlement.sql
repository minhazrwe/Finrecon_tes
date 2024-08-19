CREATE TABLE [dbo].[table_Bocarx_Trade_Settlement] (
    [ID]                 INT          IDENTITY (1, 1) NOT NULL,
    [Report_Date]        DATE         NULL,
    [Settlement_Date]    DATE         NULL,
    [Account_name]       VARCHAR (30) NULL,
    [Deal_number]        INT          NULL,
    [Contract_Name]      VARCHAR (30) NULL,
    [Contract_Date]      DATE         NULL,
    [Projection_Index_1] VARCHAR (30) NULL,
    [Trade_Date]         DATE         NULL,
    [Toolset]            VARCHAR (30) NULL,
    [Position]           FLOAT (53)   NULL,
    [Trade_Price]        FLOAT (53)   NULL,
    [Settlement_Price]   FLOAT (53)   NULL,
    [Realised_PnL]       FLOAT (53)   NULL,
    [Internal_Portfolio] VARCHAR (30) NULL,
    [CCY]                VARCHAR (30) NULL,
    [Buy_Sell]           VARCHAR (30) NULL,
    [Report_Name]        VARCHAR (30) NULL,
    [Clearer_ID]         INT          NOT NULL,
    [Last_Import]        DATETIME     CONSTRAINT [DF_table_Bocarx_Trade_Settlement_Last_Import] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_table_Bocarx_Trade_Settlement] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

