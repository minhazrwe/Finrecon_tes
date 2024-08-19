


CREATE PROCEDURE [dbo].[InsertIntoAccessControl] (@item nvarchar(200),@username varchar(200),@status tinyint,@objecttype nvarchar(200))
AS
BEGIN
		
--prüfen, ob ein Eintrag für die Eigenschaft/Aktion/Prozedur @item und den Anwender @user besteht, wenn "ja" wird der Eintrag aktualisiert, andernfalls wird er angelegt.
    MERGE [dbo].[AccessControl] AS target  
    USING (SELECT @item, @username) AS source (ITEM,USERNAME)  
    ON (target.ITEM = source.ITEM and target.USERNAME = source.USERNAME)  
    WHEN MATCHED THEN
        UPDATE SET STATUS = @status
    WHEN NOT MATCHED THEN  
        INSERT (ITEM,USERNAME,STATUS, OBJECTTYPE)  
        VALUES (@item, @username, @status,@objecttype );
		
END

GO

