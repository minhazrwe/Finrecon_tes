

CREATE FUNCTION [dbo].[udf_NZ_FLOAT] (@value FLOAT)

RETURNS FLOAT
AS
BEGIN
	
	DECLARE @output FLOAT

	-- Return Value or (0 instead of NULL)
	SET @output = 
		CASE WHEN @value is NULL then 0 else @value end

	RETURN @output
END

GO

