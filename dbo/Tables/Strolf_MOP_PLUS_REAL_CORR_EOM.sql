CREATE TABLE [dbo].[Strolf_MOP_PLUS_REAL_CORR_EOM] (
    [ID]                        INT            IDENTITY (1, 1) NOT NULL,
    [COB]                       DATETIME       NULL,
    [Trade_Date]                DATETIME       NULL,
    [PORTFOLIO_NAME]            NVARCHAR (100) NULL,
    [DESK]                      NVARCHAR (100) NULL,
    [REGION]                    NVARCHAR (100) NULL,
    [DEAL_NUM]                  NVARCHAR (100) NULL,
    [REALISATION_DATE]          DATETIME       NULL,
    [REALISATION_DATE_Original] DATETIME       NULL,
    [START_DATE]                DATETIME       NULL,
    [END_DATE]                  DATETIME       NULL,
    [LAST_UPDATE]               DATETIME       NULL,
    [OFFSET]                    NVARCHAR (100) NULL,
    [PNL_TYPE]                  NVARCHAR (100) NULL,
    [INS_TYPE_NAME]             NVARCHAR (100) NULL,
    [EXT_BUNIT_NAME]            NVARCHAR (100) NULL,
    [EXTERNAL_PORTFOLIO_NAME]   NVARCHAR (100) NULL,
    [REFERENCE]                 NVARCHAR (300) NULL,
    [TYPE]                      NVARCHAR (100) NULL,
    [SUBTYPE]                   NVARCHAR (100) NULL,
    [DEAL_VOLUME]               FLOAT (53)     NULL,
    [PNL]                       FLOAT (53)     NULL,
    [UNDISC_PNL]                FLOAT (53)     NULL,
    [UNDISC_PNL_ORIG_CCY]       FLOAT (53)     NULL,
    [LEG_CURRENCY]              NVARCHAR (5)   NULL,
    CONSTRAINT [pk_Strolf_MOP_PLUS_REAL_CORR_Data_EOM] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

