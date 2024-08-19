CREATE TABLE [dbo].[Strolf_BMT_ROM_POS] (
    [ID]            INT            IDENTITY (1, 1) NOT NULL,
    [COB]           DATE           NULL,
    [MONTH]         DATE           NULL,
    [Position]      FLOAT (53)     NULL,
    [Position_Type] NVARCHAR (500) NULL,
    [Commodity]     NVARCHAR (500) NULL,
    CONSTRAINT [pk_Strolf_BMT_ROM_POS] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

