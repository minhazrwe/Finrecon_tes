CREATE TABLE [dbo].[table_ROCK_MTM_Rawdata_GLORI] (
    [SourceSystem]            VARCHAR (5)    NOT NULL,
    [COB]                     DATE           NULL,
    [Desk_Name]               VARCHAR (50)   NULL,
    [TradeDealNumber]         NVARCHAR (20)  NULL,
    [InternalPortfolio]       NVARCHAR (100) NULL,
    [InstrumentType]          NVARCHAR (100) NULL,
    [CashflowDeliveryMonth]   DATE           NULL,
    [LegEndDate]              DATE           NULL,
    [ExternalLegalEntity]     NVARCHAR (100) NULL,
    [ExternalBU]              NVARCHAR (100) NULL,
    [EXTERNAL_PORTFOLIO_NAME] NVARCHAR (100) NULL,
    [TRANSACTION_STATUS_NAME] NVARCHAR (100) NULL,
    [SOURCE_OF_ROW]           NVARCHAR (100) NULL,
    [BUSINESS_LINE_CURRENCY]  NVARCHAR (10)  NULL,
    [UnrealisedDiscounted]    FLOAT (53)     NULL,
    [RealisedDiscounted]      FLOAT (53)     NULL,
    [UNREAL_DISC_BUH_CCY]     FLOAT (53)     NULL,
    [REAL_DISC_BUH_CCY]       FLOAT (53)     NULL,
    [FileID]                  INT            NULL
);


GO

