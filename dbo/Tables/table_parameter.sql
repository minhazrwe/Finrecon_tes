CREATE TABLE [dbo].[table_parameter] (
    [ID]                       INT            IDENTITY (1, 1) NOT NULL,
    [Parameter_Name]           VARCHAR (100)  NOT NULL,
    [Parameter_Value_Integer]  INT            NULL,
    [Parameter_Value_Float]    FLOAT (53)     NULL,
    [Parameter_Value_Datetime] DATETIME       NULL,
    [Parameter_Value_Text]     VARCHAR (2000) NULL,
    [Last_Update]              DATETIME       CONSTRAINT [DF_table_parameter_Last_Update] DEFAULT (getdate()) NULL,
    [Change_User]              VARCHAR (1)    CONSTRAINT [DF_table_parameter_Change_User] DEFAULT (user_name()) NULL,
    CONSTRAINT [UK_table_parameter_Change_User] UNIQUE NONCLUSTERED ([Parameter_Name] ASC)
);


GO

