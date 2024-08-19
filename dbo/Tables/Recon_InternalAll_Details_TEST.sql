CREATE TABLE [dbo].[Recon_InternalAll_Details_TEST] (
    [Recon]             VARCHAR (255) NULL,
    [InstrumentType]    VARCHAR (255) NULL,
    [ReferenceID]       VARCHAR (255) NULL,
    [InternalPortfolio] VARCHAR (255) NULL,
    [ExtPortfolio]      VARCHAR (255) NULL,
    [Product]           VARCHAR (255) NULL,
    [TradeDate]         DATE          NULL,
    [LastTermEnd]       DATE          NULL,
    [Account_Asset]     VARCHAR (255) NULL,
    [Account_Liab]      VARCHAR (255) NULL,
    [Account_PNL]       VARCHAR (255) NULL,
    [RWEST_DE]          FLOAT (53)    NULL,
    [RWEST_UK]          FLOAT (53)    NULL,
    [RWEST_CZ]          FLOAT (53)    NULL,
    [RWEST_P]           FLOAT (53)    NULL,
    [RWEST_AP]          FLOAT (53)    NULL,
    [RWEST_SH]          FLOAT (53)    NULL,
    [TS_DE]             FLOAT (53)    NULL,
    [TS_UK]             FLOAT (53)    NULL,
    [MtM]               FLOAT (53)    NULL,
    [DiffAbs]           FLOAT (53)    NULL,
    [LastUpdate]        DATETIME      NOT NULL
);


GO

