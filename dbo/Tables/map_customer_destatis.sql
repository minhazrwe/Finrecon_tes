CREATE TABLE [dbo].[map_customer_destatis] (
    [ID]                   INT          IDENTITY (1, 1) NOT NULL,
    [customer_name]        VARCHAR (50) NOT NULL,
    [possible_sap_txt_str] VARCHAR (50) NULL,
    CONSTRAINT [PK_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

