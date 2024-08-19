CREATE TABLE [dbo].[FIN_MOP_PLUS_REAL_CORR_mit_PNL_TYPE_ORIG_SUMMIERT] (
    [COB]                       DATE          NOT NULL,
    [TRADE_DATE]                DATE          NOT NULL,
    [PORTFOLIO_NAME]            VARCHAR (75)  NOT NULL,
    [DESK]                      VARCHAR (75)  NOT NULL,
    [REGION]                    VARCHAR (4)   NULL,
    [DEAL_NUM]                  NUMERIC (38)  NOT NULL,
    [REALISATION_DATE]          DATE          NOT NULL,
    [REALISATION_DATE_Original] DATE          NOT NULL,
    [START_DATE]                DATE          NOT NULL,
    [END_DATE]                  DATE          NOT NULL,
    [LAST_UPDATE]               DATE          NOT NULL,
    [OFFSET]                    NUMERIC (9)   NULL,
    [PNL_TYPE]                  VARCHAR (10)  NULL,
    [INS_TYPE_NAME]             VARCHAR (50)  NOT NULL,
    [EXT_BUNIT_NAME]            VARCHAR (50)  NOT NULL,
    [EXTERNAL_PORTFOLIO_NAME]   VARCHAR (50)  NULL,
    [REFERENCE]                 VARCHAR (250) NULL,
    [TYPE]                      VARCHAR (20)  NOT NULL,
    [SUBTYPE]                   VARCHAR (20)  NOT NULL,
    [DEAL_VOLUME]               FLOAT (53)    NULL,
    [PNL]                       FLOAT (53)    NULL,
    [UNDISC_PNL]                FLOAT (53)    NULL,
    [UNDISC_PNL_ORIG_CCY]       FLOAT (53)    NULL,
    [LEG_CURRENCY]              VARCHAR (3)   NOT NULL
);


GO

