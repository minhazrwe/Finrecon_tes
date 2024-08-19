CREATE TABLE [dbo].[RiskRecon_Unrealised_FASTracker_SAP_tbl] (
    [Desk]                          VARCHAR (100)  NULL,
    [Subdesk]                       VARCHAR (255)  NULL,
    [InternalPortfolio]             VARCHAR (100)  NULL,
    [InstrumetType]                 NVARCHAR (100) NULL,
    [ytd_mtm_finance_PNL_EUR]       FLOAT (53)     NULL,
    [unrealised_EUR_SAP_PNL]        FLOAT (53)     NULL,
    [unrealised_EUR_SAP_conv_PNL]   FLOAT (53)     NULL,
    [Diff_PNL_EUR]                  FLOAT (53)     NULL,
    [ytd_mtm_finance_NOR_EUR]       FLOAT (53)     NULL,
    [unrealised_EUR_SAP_NOR]        FLOAT (53)     NULL,
    [unrealised_EUR_SAP_conv_NOR]   FLOAT (53)     NULL,
    [Diff_NOR_EUR]                  FLOAT (53)     NULL,
    [ytd_mtm_finance_total_EUR]     FLOAT (53)     NULL,
    [ytd_mtm_finance_OCI_EUR]       FLOAT (53)     NULL,
    [ytd_mtm_finance_OU_EUR]        FLOAT (53)     NULL,
    [unrealised_Deskccy_SAP_PNL]    FLOAT (53)     NULL,
    [unrealised_ccy_SAP_PNL]        FLOAT (53)     NULL,
    [unrealised_Deskccy_SAP_NOR]    FLOAT (53)     NULL,
    [unrealised_ccy_SAP_NOR]        FLOAT (53)     NULL,
    [ytd_mtm_finance_total_DeskCCY] FLOAT (53)     NULL,
    [ytd_mtm_finance_OCI_DeskCCY]   FLOAT (53)     NULL,
    [ytd_mtm_finance_PNL_DeskCCY]   FLOAT (53)     NULL,
    [ytd_mtm_finance_OU_DeskCCY]    FLOAT (53)     NULL,
    [ytd_mtm_finance_NOR_DeskCCY]   FLOAT (53)     NULL,
    [Volume_SAP]                    FLOAT (53)     NULL
);


GO

