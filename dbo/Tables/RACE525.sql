CREATE TABLE [dbo].[RACE525] (
    [ID]         INT            IDENTITY (1, 1) NOT NULL,
    [Kons]       NVARCHAR (255) NULL,
    [RACE-Pos#]  NVARCHAR (255) NULL,
    [Produkt]    NVARCHAR (255) NULL,
    [Sachkonto]  NVARCHAR (255) NULL,
    [Kontentext] NVARCHAR (255) NULL,
    [Partner]    NVARCHAR (255) NULL,
    [Wert in HW] FLOAT (53)     NULL,
    [Menge]      FLOAT (53)     NULL,
    [ME]         NVARCHAR (255) NULL,
    [Status]     NVARCHAR (255) NULL
);


GO

