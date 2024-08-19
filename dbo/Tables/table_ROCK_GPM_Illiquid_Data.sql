CREATE TABLE [dbo].[table_ROCK_GPM_Illiquid_Data] (
    [CoB]                            DATETIME       NULL,
    [Intermediate_5_Name]            NVARCHAR (100) NULL,
    [Deal_Number]                    NVARCHAR (100) NULL,
    [Instrument_Type_Name]           NVARCHAR (100) NULL,
    [PnL_Disc_Unreal_BU_CCY]         FLOAT (53)     NULL,
    [PnL_Disc_Unreal_LGBY_BU_CCY]    FLOAT (53)     NULL,
    [PnL_Disc_Unreal_YtD_BU_CCY]     FLOAT (53)     NULL,
    [PnL_Disc_Unreal_LtD_PH_BU_CCY]  FLOAT (53)     NULL,
    [PnL_Disc_Unreal_LGBY_PH_BU_CCY] FLOAT (53)     NULL,
    [PnL_Disc_Unreal_YtD_PH_BU_CCY]  FLOAT (53)     NULL,
    [fileID]                         INT            NULL,
    [LastUpdate]                     DATETIME       CONSTRAINT [DF_table_ROCK_GPM_Illiquid_Data_LastUpdate] DEFAULT (getdate()) NULL
);


GO

