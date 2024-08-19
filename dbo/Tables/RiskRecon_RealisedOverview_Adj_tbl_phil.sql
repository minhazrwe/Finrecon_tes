CREATE TABLE [dbo].[RiskRecon_RealisedOverview_Adj_tbl_phil] (
    [LegalEntity]           VARCHAR (50)  NULL,
    [Desk]                  VARCHAR (50)  NULL,
    [Subdesk]               VARCHAR (255) NULL,
    [RevRecSubDesk]         VARCHAR (255) NULL,
    [ReconGroup]            VARCHAR (40)  NOT NULL,
    [Internal_Portfolio_ID] VARCHAR (100) NULL,
    [Category]              VARCHAR (255) NULL,
    [Comment]               VARCHAR (255) NULL,
    [Currency]              VARCHAR (255) NULL,
    [Quantity]              FLOAT (53)    NULL,
    [Realised_CCY]          FLOAT (53)    NULL,
    [Realised_DeskCCY]      FLOAT (53)    NULL,
    [Realised_EUR]          FLOAT (53)    NULL
);


GO

