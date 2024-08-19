CREATE TABLE [dbo].[table_KIDFX_map_HEDGE] (
    [ID]                      INT           IDENTITY (1, 1) NOT NULL,
    [PortfolioName]           VARCHAR (150) NOT NULL,
    [ProjectionIndex]         VARCHAR (150) NOT NULL,
    [Internal_Safety_ID_SOLL] VARCHAR (150) NOT NULL,
    [External_Safety_ID_SOLL] VARCHAR (150) NOT NULL,
    [HedgeInfo]               VARCHAR (255) NULL,
    [valid_until]             DATETIME      NOT NULL,
    [LastUpdate]              DATETIME      CONSTRAINT [DF_KIDFX_map_HEDGE_LastUpdate] DEFAULT (getdate()) NULL,
    CONSTRAINT [pk_KIDFX_map_HEDGE] PRIMARY KEY CLUSTERED ([PortfolioName] ASC)
);


GO

