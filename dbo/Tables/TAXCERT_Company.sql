CREATE TABLE [dbo].[TAXCERT_Company] (
    [comp_id]                 INT           NOT NULL,
    [name_1]                  VARCHAR (500) NULL,
    [name_2]                  VARCHAR (500) NULL,
    [le_id]                   INT           NULL,
    [former_name]             VARCHAR (500) NULL,
    [former_name_change_date] DATE          NULL,
    [country]                 VARCHAR (500) NULL,
    [comment]                 VARCHAR (500) NULL,
    [csource]                 VARCHAR (500) NULL,
    [city]                    VARCHAR (500) NULL,
    [le_shortname]            VARCHAR (500) NULL,
    [le_longname]             VARCHAR (500) NULL
);


GO

