CREATE TABLE [dbo].[table_VM_NETTING_1b_OtherExchangesInput_Archive] (
    [ID]            INT            IDENTITY (1, 1) NOT NULL,
    [AsofDate]      DATETIME       NULL,
    [DataSource]    NVARCHAR (255) NULL,
    [DealNumber]    NVARCHAR (255) NULL,
    [TradeDate]     DATETIME       NULL,
    [InternalBU]    NVARCHAR (255) NULL,
    [ExternalBU]    NVARCHAR (255) NULL,
    [Position]      FLOAT (53)     NULL,
    [Price]         FLOAT (53)     NULL,
    [BuySell]       NVARCHAR (255) NULL,
    [BrokerID]      NVARCHAR (255) NULL,
    [StartDate]     DATETIME       NULL,
    [MaturityDate]  DATETIME       NULL,
    [Status]        NVARCHAR (255) NULL,
    [InsReference]  NVARCHAR (255) NULL,
    [Portfolio]     NVARCHAR (50)  NULL,
    [Ticker]        NVARCHAR (255) NULL,
    [VM]            FLOAT (53)     NULL,
    [UnrealizedPNL] FLOAT (53)     NULL,
    [CCY]           NVARCHAR (50)  NULL,
    [LastUpdate]    DATETIME       NULL
);


GO

