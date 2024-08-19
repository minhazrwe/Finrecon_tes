CREATE TABLE [dbo].[Strolf_IS_EUR_EOM] (
    [ID]                      INT            IDENTITY (1, 1) NOT NULL,
    [COB]                     DATETIME       NULL,
    [PORTFOLIO_NAME]          NVARCHAR (100) NULL,
    [DEAL_NUM]                NVARCHAR (100) NULL,
    [REALISATION_DATE]        DATETIME       NULL,
    [OFFSET]                  FLOAT (53)     NULL,
    [PNL_TYPE]                NVARCHAR (50)  NULL,
    [INS_TYPE_NAME]           NVARCHAR (100) NULL,
    [EXT_BUNIT_NAME]          NVARCHAR (100) NULL,
    [EXTERNAL_PORTFOLIO_NAME] NVARCHAR (100) NULL,
    [REFERENCE]               NVARCHAR (250) NULL,
    [PNL]                     FLOAT (53)     NULL,
    [UNDISC_PNL]              FLOAT (53)     NULL,
    CONSTRAINT [pk_Strolf_IS_EUR_EOM] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

