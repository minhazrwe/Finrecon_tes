CREATE TABLE [dbo].[table_ROCK_MTM_Rawdata_FT] (
    [SourceSystem]            VARCHAR (2)   NOT NULL,
    [COB]                     DATETIME      NULL,
    [Desk_Risk]               VARCHAR (50)  NULL,
    [TradeDealNumber]         VARCHAR (50)  NULL,
    [InternalPortfolio]       VARCHAR (50)  NULL,
    [InstrumentType]          VARCHAR (50)  NULL,
    [CashflowDeliveryMonth]   VARCHAR (100) NULL,
    [LegEndDate]              DATETIME      NULL,
    [ExternalLegalEntity]     VARCHAR (50)  NULL,
    [ExternalBU]              VARCHAR (50)  NULL,
    [EXTERNAL_PORTFOLIO_NAME] VARCHAR (50)  NULL,
    [TRANSACTION_STATUS_NAME] VARCHAR (100) NULL,
    [SOURCE_OF_ROW]           VARCHAR (100) NULL,
    [BUSINESS_LINE_CURRENCY]  VARCHAR (100) NULL,
    [UnrealisedDiscounted]    FLOAT (53)    NULL,
    [RealisedDiscounted]      FLOAT (53)    NULL,
    [UNREAL_DISC_BUH_CCY]     FLOAT (53)    NULL,
    [REAL_DISC_BUH_CCY]       FLOAT (53)    NULL,
    [FileID]                  INT           NOT NULL
);


GO

