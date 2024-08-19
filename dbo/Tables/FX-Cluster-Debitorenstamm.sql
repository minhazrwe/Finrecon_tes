CREATE TABLE [dbo].[FX-Cluster-Debitorenstamm] (
    [Buchungskreis]    NVARCHAR (5)   NULL,
    [Debitor]          NVARCHAR (10)  NULL,
    [Land]             NVARCHAR (200) NULL,
    [Debitorenname]    NVARCHAR (200) NULL,
    [Abstimmungskonto] NVARCHAR (20)  NULL,
    [ID]               INT            IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [pk_FX-Cluster-Debitorenstamm] PRIMARY KEY CLUSTERED ([ID] DESC)
);


GO

