CREATE TABLE [dbo].[Table_FX_Rates_Timeseries_ECB] (
    [ID]              INT           IDENTITY (1, 1) NOT NULL,
    [COB]             DATE          NOT NULL,
    [CCY]             VARCHAR (3)   NOT NULL,
    [FX_Rate]         FLOAT (53)    NULL,
    [FX_Rate_Comment] NVARCHAR (30) NULL,
    [LastUpdate]      DATETIME      CONSTRAINT [DF_TABLE_ECB_FX_RATES_LastUpdate] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_TABLE_ECB_FX_RATES] PRIMARY KEY CLUSTERED ([COB] ASC, [CCY] ASC)
);


GO

