CREATE TABLE [dbo].[AWV_LZB] (
    [ID]                          INT           IDENTITY (1, 1) NOT NULL,
    [LZB]                         VARCHAR (3)   NOT NULL,
    [AWV-Bemerkung/Zahlungszweck] VARCHAR (500) NULL,
    CONSTRAINT [pk_AWV_LZB] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

