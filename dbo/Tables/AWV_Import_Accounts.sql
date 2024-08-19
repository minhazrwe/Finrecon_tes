CREATE TABLE [dbo].[AWV_Import_Accounts] (
    [Account]                     VARCHAR (255)  NOT NULL,
    [AccountName]                 VARCHAR (255)  NULL,
    [recon_group]                 VARCHAR (40)   NULL,
    [Commodity]                   VARCHAR (255)  NULL,
    [comment]                     VARCHAR (255)  NULL,
    [AWV-Anlage]                  VARCHAR (20)   NULL,
    [AWV-LZB]                     VARCHAR (20)   NULL,
    [AWV-Bemerkung/Zahlungszweck] VARCHAR (1000) NULL,
    [AWV-Responsible]             VARCHAR (50)   NULL
);


GO

