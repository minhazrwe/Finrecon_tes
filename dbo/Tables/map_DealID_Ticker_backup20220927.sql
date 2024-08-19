CREATE TABLE [dbo].[map_DealID_Ticker_backup20220927] (
    [DealID]             VARCHAR (100) NOT NULL,
    [InstrumentTypeName] VARCHAR (100) NOT NULL,
    [Ticker]             VARCHAR (100) NOT NULL,
    [User]               VARCHAR (255) NOT NULL,
    [TimeStamp]          DATETIME      NOT NULL,
    [ID]                 INT           IDENTITY (1, 1) NOT NULL,
    [DeliveryMonth]      VARCHAR (7)   NULL
);


GO

