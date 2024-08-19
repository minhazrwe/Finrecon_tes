CREATE TABLE [dbo].[table_KIDFX_KID_ID_OLF] (
    [ID]                              INT            IDENTITY (1, 1) NOT NULL,
    [Portfolio_Name]                  NVARCHAR (150) NULL,
    [WSS_Number]                      INT            NOT NULL,
    [OLF_Number]                      NVARCHAR (150) NULL,
    [OLF_Number_Transaction_Comments] NVARCHAR (150) NULL,
    [Instrument]                      NVARCHAR (150) NULL,
    [Param9_System_Reference]         INT            NULL,
    [CP]                              NVARCHAR (150) NULL,
    [UTI]                             NVARCHAR (150) NULL,
    [Parent_Deal_Number]              INT            NULL,
    [LastImport]                      DATETIME       CONSTRAINT [DF_KIDFX_KID_ID_OLF_LastImport] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [pk_KIDFX_KID_ID_OLF_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

