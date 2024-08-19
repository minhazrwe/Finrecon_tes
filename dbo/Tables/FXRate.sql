CREATE TABLE [dbo].[FXRate] (
    [ID]            INT          IDENTITY (1, 1) NOT NULL,
    [AsOfDate]      DATETIME     NOT NULL,
    [Currency]      VARCHAR (3)  NOT NULL,
    [Rate]          FLOAT (53)   NULL,
    [RateRisk]      FLOAT (53)   NULL,
    [DeliveryMonth] VARCHAR (10) NULL,
    CONSTRAINT [pk_FXRate] PRIMARY KEY CLUSTERED ([AsOfDate] ASC, [Currency] ASC)
);


GO

