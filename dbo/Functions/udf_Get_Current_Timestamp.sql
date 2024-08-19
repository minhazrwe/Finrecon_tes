










CREATE FUNCTION [dbo].[udf_Get_Current_Timestamp] ()
/*This function returns the correct CET date and time*/
RETURNS datetime 
AS
BEGIN
	DECLARE @output datetime
	SELECT @output = cast(GETUTCDATE() At Time Zone 'UTC' At Time Zone 'Central European Standard Time' As datetime)

	RETURN @output
END

GO

