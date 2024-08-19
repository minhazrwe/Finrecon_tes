CREATE TABLE [dbo].[FIN_MOP_PLUS_REAL_CORR_mit_PNL_TYPE_ORIG_SNOWFLAKE] (
    [COB]                     NVARCHAR (75)  NULL,
    [TRADE_DATE]              NVARCHAR (75)  NULL,
    [PORTFOLIO_NAME]          NVARCHAR (75)  NOT NULL,
    [DESK]                    NVARCHAR (75)  NOT NULL,
    [REGION]                  NVARCHAR (40)  NULL,
    [DEAL_NUM]                NVARCHAR (75)  NULL,
    [REALISATION_DATE]        NVARCHAR (75)  NULL,
    [REAL_DATE_ORIG]          NVARCHAR (75)  NULL,
    [START_DATE]              NVARCHAR (75)  NULL,
    [END_DATE]                NVARCHAR (75)  NULL,
    [LAST_UPDATE]             NVARCHAR (75)  NULL,
    [OFFSET]                  NVARCHAR (75)  NULL,
    [PNL_TYPE]                NVARCHAR (75)  NULL,
    [PNL_TYPE_Orig]           NVARCHAR (75)  NULL,
    [INS_TYPE_NAME]           NVARCHAR (50)  NOT NULL,
    [EXT_BUNIT_NAME]          NVARCHAR (50)  NULL,
    [EXTERNAL_PORTFOLIO_NAME] NVARCHAR (75)  NULL,
    [REFERENCE]               NVARCHAR (250) NULL,
    [TYPE]                    NVARCHAR (200) NULL,
    [SUBTYPE]                 NVARCHAR (200) NULL,
    [DEAL_VOLUME]             NVARCHAR (75)  NULL,
    [PNL]                     NVARCHAR (75)  NULL,
    [UNDISC_PNL]              NVARCHAR (75)  NULL,
    [UNDISC_PNL_ORIG_CCY]     NVARCHAR (75)  NULL,
    [LEG_CURRENCY]            NVARCHAR (300) NOT NULL
);


GO

