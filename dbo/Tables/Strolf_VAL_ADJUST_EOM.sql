CREATE TABLE [dbo].[Strolf_VAL_ADJUST_EOM] (
    [ID]               INT            IDENTITY (1, 1) NOT NULL,
    [COB]              DATETIME       NULL,
    [PORTFOLIO_NAME]   NVARCHAR (100) NULL,
    [PORTFOLIO_ID]     NVARCHAR (400) NULL,
    [PNL_TYPE]         NVARCHAR (100) NULL,
    [PNL]              FLOAT (53)     NULL,
    [CURRENCY]         NVARCHAR (3)   NULL,
    [INSTRUMENT]       NVARCHAR (50)  NULL,
    [DESCRIPTION]      NVARCHAR (100) NULL,
    [START_DATE]       DATETIME       NULL,
    [END_DATE]         DATETIME       NULL,
    [REALISATION_DATE] DATETIME       NULL,
    [ENTRY_DATE]       DATETIME       NULL,
    [CAT_NAME]         NVARCHAR (100) NULL,
    CONSTRAINT [pk_Strolf_VAL_ADJUST_EOM_NEW] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

