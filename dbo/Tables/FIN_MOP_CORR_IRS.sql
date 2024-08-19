CREATE TABLE [dbo].[FIN_MOP_CORR_IRS] (
    [COB]                       DATETIME2 (7)  NOT NULL,
    [TRADE_DATE]                DATETIME2 (7)  NOT NULL,
    [PORTFOLIO_NAME]            NVARCHAR (75)  NOT NULL,
    [DESK]                      NVARCHAR (75)  NOT NULL,
    [REGION]                    NVARCHAR (4)   NULL,
    [DEAL_NUM]                  NUMERIC (13)   NOT NULL,
    [REALISATION_DATE]          DATETIME2 (7)  NOT NULL,
    [REALISATION_DATE_Original] DATETIME2 (7)  NULL,
    [START_DATE]                DATETIME2 (7)  NOT NULL,
    [END_DATE]                  DATETIME2 (7)  NOT NULL,
    [LAST_UPDATE]               DATETIME2 (7)  NOT NULL,
    [OFFSET]                    FLOAT (53)     NULL,
    [PNL_TYPE]                  NVARCHAR (10)  NULL,
    [INS_TYPE_NAME]             NVARCHAR (50)  NOT NULL,
    [EXT_BUNIT_NAME]            NVARCHAR (50)  NULL,
    [EXTERNAL_PORTFOLIO_NAME]   NVARCHAR (75)  NULL,
    [REFERENCE]                 NVARCHAR (250) NULL,
    [TYPE]                      NVARCHAR (20)  NULL,
    [SUBTYPE]                   NVARCHAR (20)  NULL,
    [DEAL_VOLUME]               FLOAT (53)     NULL,
    [PNL]                       FLOAT (53)     NULL,
    [UNDISC_PNL]                FLOAT (53)     NULL,
    [UNDISC_PNL_ORIG_CCY]       FLOAT (53)     NULL,
    [LEG_CURRENCY]              NVARCHAR (30)  NOT NULL
);


GO

