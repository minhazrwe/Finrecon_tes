CREATE TABLE [dbo].[table_VM_NETTING_1a_DeferralInput_AutoBackup] (
    [DataSource]       NVARCHAR (255) NULL,
    [CCY]              VARCHAR (50)   NULL,
    [SettlementDate]   DATETIME       NULL,
    [AccountName]      NVARCHAR (255) NULL,
    [Portfolio]        VARCHAR (50)   NULL,
    [DealNumber]       NVARCHAR (255) NULL,
    [ContractName]     NVARCHAR (255) NULL,
    [ContractDate]     DATETIME       NULL,
    [ProjectionIndex1] NVARCHAR (255) NULL,
    [ProjectionIndex2] NVARCHAR (255) NULL,
    [Toolset]          NVARCHAR (255) NULL,
    [Position]         FLOAT (53)     NULL,
    [TradePrice]       FLOAT (53)     NULL,
    [SettlementPrice]  FLOAT (53)     NULL,
    [RealizedPNL]      FLOAT (53)     NULL,
    [ExternalBU]       NVARCHAR (255) NULL,
    [GueltigVon]       DATETIME       NULL,
    [GueltigBis]       DATETIME       NULL,
    [LastUpdate]       DATETIME       NULL,
    [backup_id]        BIGINT         NULL,
    [backup_timestamp] DATETIME       NULL,
    [backup_user]      VARCHAR (100)  NULL,
    [Desk]             VARCHAR (100)  NULL
);


GO

