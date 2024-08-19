CREATE TABLE [dbo].[table_strolf_mtm_check_02_recon_raw_TEST] (
    [DEALID]                           VARCHAR (200)   NULL,
    [SubDesk]                          VARCHAR (200)   NULL,
    [Book]                             VARCHAR (255)   NULL,
    [InternalPortfolio]                NVARCHAR (100)  NULL,
    [InstrumentType]                   NVARCHAR (100)  NULL,
    [CounterpartyExternalBusinessUnit] NVARCHAR (100)  NULL,
    [ExternalPortfolio]                NVARCHAR (100)  NULL,
    [TermEnd]                          NVARCHAR (4000) NULL,
    [Product]                          VARCHAR (100)   NULL,
    [RiskMtM]                          FLOAT (53)      NULL,
    [RiskRealised]                     FLOAT (53)      NULL,
    [FT]                               FLOAT (53)      NULL,
    [Kaskade]                          INT             NULL,
    [DiffMtM]                          FLOAT (53)      NULL
);


GO

