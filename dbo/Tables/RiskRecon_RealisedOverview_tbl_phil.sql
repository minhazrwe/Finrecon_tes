CREATE TABLE [dbo].[RiskRecon_RealisedOverview_tbl_phil] (
    [internalLegalEntity] VARCHAR (60) NULL,
    [Desk]                VARCHAR (50) NULL,
    [Subdesk]             VARCHAR (50) NULL,
    [RevRecSubdesk]       VARCHAR (50) NULL,
    [ReconGroup]          VARCHAR (40) NULL,
    [EUR_Endur]           FLOAT (53)   NULL,
    [EUR_SAP]             FLOAT (53)   NULL,
    [EUR_Adj]             FLOAT (53)   NULL,
    [diff_EUR]            FLOAT (53)   NULL,
    [DeskCCY_Endur]       FLOAT (53)   NULL,
    [DeskCCY_SAPint]      FLOAT (53)   NULL,
    [DeskCCY_Adj]         FLOAT (53)   NULL,
    [diff_DeskCCY]        FLOAT (53)   NULL,
    [EUR_SAP_conv]        FLOAT (53)   NULL,
    [Desk_new]            VARCHAR (50) NULL
);


GO

