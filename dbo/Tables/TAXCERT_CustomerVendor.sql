CREATE TABLE [dbo].[TAXCERT_CustomerVendor] (
    [cv_id]           INT           NOT NULL,
    [comp_id]         INT           NOT NULL,
    [sap_id]          INT           NULL,
    [sap_group_id]    INT           NULL,
    [bu_id]           INT           NULL,
    [successor_cv_id] INT           NULL,
    [succession_date] DATE          NULL,
    [name_3]          VARCHAR (500) NULL,
    [city]            VARCHAR (500) NULL,
    [country]         VARCHAR (500) NULL,
    [comment]         VARCHAR (500) NULL
);


GO

