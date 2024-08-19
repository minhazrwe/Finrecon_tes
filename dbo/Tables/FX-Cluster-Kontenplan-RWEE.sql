CREATE TABLE [dbo].[FX-Cluster-Kontenplan-RWEE] (
    [Sachkonto]        NVARCHAR (100) NULL,
    [Kontobezeichnung] NVARCHAR (100) NULL,
    [ID]               INT            IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [pk_FX-Cluster-Kontenplan-RWEE] PRIMARY KEY CLUSTERED ([ID] DESC)
);


GO

