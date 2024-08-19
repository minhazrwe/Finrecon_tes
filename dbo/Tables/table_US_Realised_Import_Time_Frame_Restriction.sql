CREATE TABLE [dbo].[table_US_Realised_Import_Time_Frame_Restriction] (
    [ID]            INT      IDENTITY (1, 1) NOT NULL,
    [Starting_Time] TIME (7) NOT NULL,
    [Ending_Time]   TIME (7) NOT NULL,
    CONSTRAINT [pk_US_Realised_Import_Time_Frame_Restriction] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

