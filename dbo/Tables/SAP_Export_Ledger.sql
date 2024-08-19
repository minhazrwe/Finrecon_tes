CREATE TABLE [dbo].[SAP_Export_Ledger] (
    [ID]          INT           IDENTITY (1, 1) NOT NULL,
    [SAPVariant]  VARCHAR (100) NOT NULL,
    [CompanyCode] VARCHAR (4)   NOT NULL,
    [Period]      VARCHAR (2)   NOT NULL,
    [Year]        VARCHAR (4)   NOT NULL,
    [TimeStamp]   DATETIME      CONSTRAINT [DF_SAP_Export_Ledger_TimeStamp] DEFAULT (getdate()) NULL,
    [USER]        VARCHAR (50)  CONSTRAINT [DF_SAP_Export_Ledger_User] DEFAULT (user_name()) NULL,
    CONSTRAINT [pk_SAP_Export_Ledger] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

