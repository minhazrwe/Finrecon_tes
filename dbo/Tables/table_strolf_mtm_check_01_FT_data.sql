CREATE TABLE [dbo].[table_strolf_mtm_check_01_FT_data] (
    [COB]                              DATE          NOT NULL,
    [Subsidiary]                       VARCHAR (100) NULL,
    [Bereich]                          VARCHAR (100) NULL,
    [Strategy]                         VARCHAR (100) NULL,
    [DealID]                           VARCHAR (100) NULL,
    [TradeDate]                        DATE          NULL,
    [TermStart]                        DATE          NULL,
    [TermEnd]                          DATE          NULL,
    [InternalPortfolio]                VARCHAR (100) NULL,
    [CounterpartyExternalBusinessUnit] VARCHAR (100) NULL,
    [CounterpartyGroup]                VARCHAR (100) NULL,
    [Volume]                           FLOAT (53)    NULL,
    [BuySellHeader]                    VARCHAR (10)  NULL,
    [CurveName]                        VARCHAR (100) NULL,
    [ProjectionIndexGroup]             VARCHAR (100) NULL,
    [InstrumentType]                   VARCHAR (100) NULL,
    [InternalLegalEntity]              VARCHAR (100) NULL,
    [InternalBusinessUnit]             VARCHAR (100) NULL,
    [ExternalLegalEntity]              VARCHAR (100) NULL,
    [ExternalPortfolio]                VARCHAR (100) NULL,
    [Product]                          VARCHAR (100) NULL,
    [AccountingTreatment]              VARCHAR (100) NULL,
    [MtM]                              FLOAT (53)    NULL,
    [UndiscountedMtM]                  FLOAT (53)    NULL,
    [Accounting]                       VARCHAR (100) NULL,
    [JahrVonTermEnd]                   INT           NULL,
    [LastUpdate]                       DATETIME      CONSTRAINT [DF_table_strolf_mtm_check_01_FT_data_LastUpdate] DEFAULT (getdate()) NULL
);


GO

