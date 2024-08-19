CREATE TABLE [dbo].[RiskRecon_MtM_Overview_tbl] (
    [Desk]                             VARCHAR (50)  NULL,
    [Subdesk]                          VARCHAR (50)  NULL,
    [InternalPortfolio]                VARCHAR (50)  NULL,
    [AccountingTreatment]              VARCHAR (255) NULL,
    [nonVA]                            VARCHAR (255) NULL,
    [unwind]                           VARCHAR (17)  NULL,
    [mtm_finance_total_EUR]            FLOAT (53)    NULL,
    [prevYE_mtm_finance_total_EUR]     FLOAT (53)    NULL,
    [mtm_finance_OCI_EUR]              FLOAT (53)    NULL,
    [mtm_finance_PNL_EUR]              FLOAT (53)    NULL,
    [mtm_finance_OU_EUR]               FLOAT (53)    NULL,
    [mtm_finance_NOR_EUR]              FLOAT (53)    NULL,
    [ytd_mtm_finance_total_EUR]        FLOAT (53)    NULL,
    [ytd_mtm_finance_OCI_EUR]          FLOAT (53)    NULL,
    [ytd_mtm_finance_PNL_EUR]          FLOAT (53)    NULL,
    [ytd_mtm_finance_OU_EUR]           FLOAT (53)    NULL,
    [ytd_mtm_finance_NOR_EUR]          FLOAT (53)    NULL,
    [mtm_finance_total_DeskCCY]        FLOAT (53)    NULL,
    [prevYE_mtm_finance_total_DeskCCY] FLOAT (53)    NULL,
    [mtm_finance_OCI_DeskCCY]          FLOAT (53)    NULL,
    [mtm_finance_PNL_DeskCCY]          FLOAT (53)    NULL,
    [mtm_finance_OU_DeskCCY]           FLOAT (53)    NULL,
    [mtm_finance_NOR_DeskCCY]          FLOAT (53)    NULL,
    [ytd_mtm_finance_total_DeskCCY]    FLOAT (53)    NULL,
    [ytd_mtm_finance_OCI_DeskCCY]      FLOAT (53)    NULL,
    [ytd_mtm_finance_PNL_DeskCCY]      FLOAT (53)    NULL,
    [ytd_mtm_finance_OU_DeskCCY]       FLOAT (53)    NULL,
    [ytd_mtm_finance_NOR_DeskCCY]      FLOAT (53)    NULL
);


GO

