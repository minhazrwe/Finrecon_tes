CREATE TABLE [dbo].[AWV_CreditorDebitor] (
    [ID]                     INT            IDENTITY (1, 1) NOT NULL,
    [NameCreditorDebitor]    NVARCHAR (200) NULL,
    [NumberCreditorDebitor]  NVARCHAR (20)  NULL,
    [CountryCreditorDebitor] NVARCHAR (5)   NULL,
    CONSTRAINT [PK_AWV_CreditorDebitor] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

