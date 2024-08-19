CREATE TABLE [dbo].[Strolf_CAO_PNL_OV] (
    [ID]            INT            IDENTITY (1, 1) NOT NULL,
    [REP_DATE]      DATE           NULL,
    [PREV_DATE]     DATE           NULL,
    [EOLM_COB_DATE] DATE           NULL,
    [EOLY_COB_DATE] DATE           NULL,
    [Desk]          NVARCHAR (100) NULL,
    [PFG_NAME]      NVARCHAR (100) NULL,
    [BUSINESS_TYPE] NVARCHAR (100) NULL,
    [MTM_REP]       FLOAT (53)     NULL,
    [MTM_PREV]      FLOAT (53)     NULL,
    [REAL_REP]      FLOAT (53)     NULL,
    [REAL_PREV]     FLOAT (53)     NULL,
    [ALL_REP]       FLOAT (53)     NULL,
    [ALL_PREV]      FLOAT (53)     NULL,
    [DTD_PNL]       FLOAT (53)     NULL,
    [MTD_PNL]       FLOAT (53)     NULL,
    [YTD_PNL]       FLOAT (53)     NULL,
    CONSTRAINT [pk_Strolf_CAO_PnL_OV] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

