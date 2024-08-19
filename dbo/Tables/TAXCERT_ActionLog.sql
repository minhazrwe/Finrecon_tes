CREATE TABLE [dbo].[TAXCERT_ActionLog] (
    [log_id]   INT           NOT NULL,
    [comp_id]  INT           NOT NULL,
    [cert_id]  INT           NULL,
    [ctype_id] INT           NOT NULL,
    [cstatus]  VARCHAR (500) NULL,
    [date]     DATE          NULL,
    [comment]  VARCHAR (500) NULL,
    [user_id]  VARCHAR (500) NULL
);


GO

