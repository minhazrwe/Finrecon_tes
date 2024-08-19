CREATE TABLE [dbo].[GloriRiskAdj] (
    [ID]                                 INT            IDENTITY (1, 1) NOT NULL,
    [COB]                                DATETIME       NULL,
    [L04 - Intermediate1 (Current Name)] VARCHAR (50)   NULL,
    [L07 - Intermediate4 (Current Name)] VARCHAR (50)   NULL,
    [Internal Portfolio Name]            VARCHAR (50)   NULL,
    [Adjustment Category]                VARCHAR (50)   NULL,
    [Adjustment Sub Category]            VARCHAR (50)   NULL,
    [Adjustment Comment]                 VARCHAR (1500) NULL,
    [Adjustment User ID]                 VARCHAR (50)   NULL,
    [Metriken]                           VARCHAR (50)   NULL,
    [Realised Discounted EUR - EOLY]     FLOAT (53)     NULL,
    [Realised Discounted EUR]            FLOAT (53)     NULL,
    [Unrealised Discounted EUR - EOLY]   FLOAT (53)     NULL,
    [Unrealised Discounted EUR]          FLOAT (53)     NULL,
    [Realised Discounted USD - EOLY]     FLOAT (53)     NULL,
    [Realised Discounted USD]            FLOAT (53)     NULL,
    [Unrealised Discounted USD - EOLY]   FLOAT (53)     NULL,
    [Unrealised Undiscounted USD]        FLOAT (53)     NULL,
    [Realised Discounted GBP - EOLY]     FLOAT (53)     NULL,
    [Realised Discounted GBP]            FLOAT (53)     NULL,
    [Unrealised Discounted GBP EOLY]     FLOAT (53)     NULL,
    [Unrealised Discounted GBP]          FLOAT (53)     NULL,
    [LastUpdate]                         DATETIME       NULL,
    [FileId]                             INT            NULL
);


GO

