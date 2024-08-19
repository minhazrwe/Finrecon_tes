CREATE TABLE [dbo].[VM_NETTING_report_controlling_CheckToBeDeleted] (
    [Accounting]      VARCHAR (6)   NOT NULL,
    [Subsidiary]      VARCHAR (255) NULL,
    [Strategy]        VARCHAR (255) NULL,
    [Productyear]     DATE          NULL,
    [id1]             VARCHAR (50)  NULL,
    [id2]             VARCHAR (50)  NULL,
    [id3]             VARCHAR (50)  NULL,
    [id4]             VARCHAR (50)  NULL,
    [Extlegal]        VARCHAR (101) NULL,
    [ExtBusinessUnit] VARCHAR (50)  NULL,
    [InsReference]    VARCHAR (50)  NULL,
    [Position]        FLOAT (53)    NULL,
    [mtm_gesamt]      FLOAT (53)    NULL,
    [LastUpdate]      DATETIME      NOT NULL
);


GO

