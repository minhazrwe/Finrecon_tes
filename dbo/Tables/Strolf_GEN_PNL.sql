CREATE TABLE [dbo].[Strolf_GEN_PNL] (
    [ID]             INT            IDENTITY (1, 1) NOT NULL,
    [COB]            DATE           NULL,
    [Desk]           NVARCHAR (100) NULL,
    [PORTFOLIO_ID]   INT            NULL,
    [PORTFOLIO_NAME] NVARCHAR (100) NULL,
    [DELIVERY_MONTH] DATE           NULL,
    [PNL_TYPE]       NVARCHAR (50)  NULL,
    [PNL]            FLOAT (53)     NULL,
    CONSTRAINT [pk_Strolf_Gen_PnL] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

