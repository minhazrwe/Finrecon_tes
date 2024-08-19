CREATE TABLE [dbo].[table_HA_map_Curve_GROUP] (
    [ID]          INT           IDENTITY (1, 1) NOT NULL,
    [curve_name]  VARCHAR (200) NOT NULL,
    [group_name]  VARCHAR (100) NOT NULL,
    [Last_Update] DATETIME      CONSTRAINT [DF_table_HA_map_Curve_GROUP_LastUpdate] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_table_HA_map_Curve_GROUP] PRIMARY KEY CLUSTERED ([curve_name] ASC, [group_name] ASC)
);


GO

