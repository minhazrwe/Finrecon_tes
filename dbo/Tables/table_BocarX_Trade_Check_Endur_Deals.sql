CREATE TABLE [dbo].[table_BocarX_Trade_Check_Endur_Deals] (
    [ID]                 INT           IDENTITY (1, 1) NOT NULL,
    [Report_Date]        DATE          NULL,
    [Account_Name]       VARCHAR (30)  NULL,
    [CCY]                VARCHAR (30)  NULL,
    [Trade_Date]         DATE          NULL,
    [Deal_Number]        INT           NULL,
    [Contract_Name]      VARCHAR (30)  NULL,
    [Start_Date]         DATE          NULL,
    [End_Date]           DATE          NULL,
    [Projection_Index_1] VARCHAR (30)  NULL,
    [External_BU]        VARCHAR (30)  NULL,
    [Internal_Portfolio] VARCHAR (30)  NULL,
    [Toolset]            VARCHAR (30)  NULL,
    [Contract_Size]      FLOAT (53)    NULL,
    [Position]           FLOAT (53)    NULL,
    [Trade_Price]        FLOAT (53)    NULL,
    [Call_Put]           VARCHAR (30)  NULL,
    [Strike_Price]       FLOAT (53)    NULL,
    [Premium]            FLOAT (53)    NULL,
    [Broker_Name]        VARCHAR (100) NULL,
    [Fee_Rate]           FLOAT (53)    NULL,
    [Total_Fee]          FLOAT (53)    NULL,
    [Report_Name]        VARCHAR (100) NULL,
    [Clearer_ID]         INT           NOT NULL,
    [Last_Import]        DATETIME      CONSTRAINT [DF_table_BocarX_Trade_Check_Endur_Deals_Last_Import] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_table_BocarX_Trade_Check_Endur_Deals] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

