CREATE TABLE [dbo].[PathToFiles] (
    [ID]        INT            IDENTITY (1, 1) NOT NULL,
    [Path]      VARCHAR (2000) NULL,
    [Source]    NVARCHAR (100) NULL,
    [TimeStamp] DATETIME       CONSTRAINT [DF_PathToFiles_TimeStamp] DEFAULT (getdate()) NULL,
    [User]      VARCHAR (50)   CONSTRAINT [DF_PathToFiles_User] DEFAULT (user_name()) NULL,
    CONSTRAINT [pk_PathToFiles] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

-- =============================================
-- Author:		MKB
-- Create date: 2024-04-05
-- Description:	After Update trigger
-- =============================================
CREATE TRIGGER dbo.trigger_pathtofiles_after_update
   ON  dbo.pathtofiles
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	UPDATE dbo.PathToFiles
  SET [TimeStamp] = GETDATE(),   -- Aktualisieren des Felds XYZ mit dem aktuellen Datum
			[USER]=CURRENT_USER
  WHERE ID IN (SELECT ID FROM inserted)  -- Nur den Datensatz aktualisieren, der gerade geändert wurde
END

GO

