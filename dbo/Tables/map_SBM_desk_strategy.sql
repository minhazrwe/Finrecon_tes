CREATE TABLE [dbo].[map_SBM_desk_strategy] (
    [ID]         INT           IDENTITY (1, 1) NOT NULL,
    [DeskName]   VARCHAR (255) NULL,
    [Strategy]   VARCHAR (255) NULL,
    [LastUpdate] DATETIME      CONSTRAINT [DF_map_SBM_desk_strategy_LastUpdate] DEFAULT (getdate()) NULL,
    [username]   VARCHAR (50)  CONSTRAINT [DF_map_SBM_desk_strategy_Username] DEFAULT (user_name()) NULL,
    CONSTRAINT [pk_map_SBM_desk_strategy] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

