CREATE TABLE [dbo].[TAXCERT_Certificate] (
    [cert_id]           INT            NOT NULL,
    [comp_id]           INT            NOT NULL,
    [ctype_id]          INT            NOT NULL,
    [csubtype]          VARCHAR (1000) NULL,
    [local_auth_office] VARCHAR (1000) NULL,
    [cnumber]           VARCHAR (1000) NULL,
    [valid_from]        DATE           NULL,
    [valid_to]          DATE           NULL,
    [url]               VARCHAR (1000) NULL,
    [fpath]             VARCHAR (1000) NULL,
    [comment]           VARCHAR (1000) NULL
);


GO

