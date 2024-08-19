CREATE TABLE [dbo].[table_Clearer_Settlement_Part_Data_Temp] (
    [Report Day]              NVARCHAR (50)   NULL,
    [Account]                 NVARCHAR (50)   NULL,
    [Original Trade Day]      NVARCHAR (50)   NULL,
    [Contract]                NVARCHAR (MAX)  NULL,
    [Contract Date]           NVARCHAR (50)   NULL,
    [Internal Trade Id]       NVARCHAR (50)   NULL,
    [Original Deal No]        NVARCHAR (50)   NULL,
    [Projection Index 1]      NVARCHAR (50)   NULL,
    [Projection Index 2]      NVARCHAR (50)   NULL,
    [Toolset]                 NVARCHAR (50)   NULL,
    [Closeout Deal No]        NVARCHAR (50)   NULL,
    [Position Closed Today]   DECIMAL (18)    NULL,
    [Total Original Position] NUMERIC (18, 2) NULL,
    [Original Trade Price]    NUMERIC (18, 2) NULL,
    [Closing Trade Price]     NUMERIC (18, 2) NULL,
    [Flat]                    NVARCHAR (50)   NULL,
    [PnL]                     NUMERIC (18, 2) NULL,
    [Portfolio]               NVARCHAR (MAX)  NULL,
    [CCY]                     NVARCHAR (50)   NULL
);


GO

