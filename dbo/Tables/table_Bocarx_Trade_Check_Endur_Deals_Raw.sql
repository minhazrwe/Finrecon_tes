CREATE TABLE [dbo].[table_Bocarx_Trade_Check_Endur_Deals_Raw] (
    [Report_Date]        DATE          NULL,
    [Account_Name]       VARCHAR (30)  NULL,
    [CCY]                VARCHAR (30)  NULL,
    [Trade_Date]         DATE          NULL,
    [Deal_Number]        VARCHAR (500) NULL,
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
    [Broker_Name]        VARCHAR (30)  NULL,
    [Fee_Rate]           FLOAT (53)    NULL,
    [Total_Fee]          FLOAT (53)    NULL,
    [Report_Name]        VARCHAR (30)  NULL
);


GO

