CREATE TABLE [dbo].[table_KIDFX_Deal_Mapping_manual] (
    [ID]           INT           IDENTITY (1, 1) NOT NULL,
    [KID]          VARCHAR (50)  NOT NULL,
    [ENDUR_DEALID] VARCHAR (50)  NOT NULL,
    [TRADEDATE]    DATETIME      NULL,
    [MaturityDate] DATETIME      NULL,
    [Comment]      VARCHAR (255) NULL,
    [LastUpdate]   DATETIME      CONSTRAINT [DF_KIDFX_Deal_Mapping_manual_LastUpdate] DEFAULT (getdate()) NULL,
    CONSTRAINT [pk_KIDFX_Deal_Mapping_manual_ENDUR_DEALID] PRIMARY KEY CLUSTERED ([ENDUR_DEALID] ASC)
);


GO

