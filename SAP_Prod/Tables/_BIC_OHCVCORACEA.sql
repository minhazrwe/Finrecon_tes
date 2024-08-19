CREATE TABLE [SAP_Prod].[/BIC/OHCVCORACEA] (
    [REQTSN]         NVARCHAR (23) DEFAULT ('00000000000000000000000') NOT NULL,
    [DATAPAKID]      INT           DEFAULT ((0)) NOT NULL,
    [RECORD]         INT           DEFAULT ((0)) NOT NULL,
    [SOURSYSTEM]     NVARCHAR (2)  DEFAULT (' ') NOT NULL,
    [/BIC/CGLCOMPCD] NVARCHAR (4)  DEFAULT (' ') NOT NULL,
    [/BIC/CGCORACEA] NVARCHAR (10) DEFAULT (' ') NOT NULL,
    [/BIC/CGCORPOTY] NVARCHAR (4)  DEFAULT (' ') NOT NULL,
    [/BIC/CGCORMAP]  NVARCHAR (2)  DEFAULT (' ') NOT NULL,
    [/BIC/CGCORM1]   NVARCHAR (4)  DEFAULT (' ') NOT NULL,
    [/BIC/CGCORM2]   NVARCHAR (4)  DEFAULT (' ') NOT NULL,
    [/BIC/CGCORPO]   NVARCHAR (10) DEFAULT (' ') NOT NULL,
    [/BIC/CCARRACPO] NVARCHAR (12) DEFAULT (' ') NOT NULL,
    CONSTRAINT [/BIC/OHCVCORACEA~0] PRIMARY KEY CLUSTERED ([REQTSN] ASC, [DATAPAKID] ASC, [RECORD] ASC)
);


GO

