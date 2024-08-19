








CREATE FUNCTION [dbo].[udf_Get_Current_User] ()
/*This function returns the windows domain\username of the current user (e.g. ENERGY\UI123456)*/
RETURNS nvarchar(100) 
AS
BEGIN
	DECLARE @output nvarchar(100)

	/*Identify the user (R2D2 is identified as dbo)*/
	SELECT @output = case when CURRENT_USER = 'dbo' then 'dbo_R2D2' else CURRENT_USER end
	
	RETURN @output
END

GO

