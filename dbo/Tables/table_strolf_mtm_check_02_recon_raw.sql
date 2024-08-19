CREATE TABLE [dbo].[table_strolf_mtm_check_02_recon_raw] (
    [DealID]                           NVARCHAR (200) NOT NULL,
    [SubDesk]                          NVARCHAR (200) NULL,
    [Book]                             NVARCHAR (200) NULL,
    [InternalPortfolio]                NVARCHAR (200) NULL,
    [InstrumentType]                   NVARCHAR (200) NULL,
    [CounterpartyExternalBusinessUnit] NVARCHAR (200) NULL,
    [ExternalPortfolio]                NVARCHAR (200) NULL,
    [TermEnd]                          NVARCHAR (50)  NULL,
    [Product]                          NVARCHAR (200) NULL,
    [RiskMTM]                          FLOAT (53)     NULL,
    [RiskRealised]                     FLOAT (53)     NULL,
    [FT]                               FLOAT (53)     NULL,
    [Kaskade]                          FLOAT (53)     NULL,
    [DiffMtM]                          FLOAT (53)     NULL,
    [LastUpdate]                       DATETIME       CONSTRAINT [DF_table_strolf_mtm_check_02_recon_raw_LastUpdate] DEFAULT (getdate()) NOT NULL
);


GO

