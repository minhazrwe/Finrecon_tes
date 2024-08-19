
CREATE FUNCTION [dbo].[udf_InsTypeMatch] (@SAPText nvarchar(100))
/* Fompares all available instrument types to given text and returns the type if a match is found, otherwise 'n/a' will be returned
*/
RETURNS nvarchar(100)
AS
BEGIN
	DECLARE @strReturn nvarchar(100) = 'not set'
	DECLARE @intCounter Integer = 1
	
	WHILE @intCounter <= (SELECT Count([InstrumentType]) FROM [FinRecon].[dbo].[map_instrument])
	BEGIN
		IF CHARINDEX((SELECT InstrumentType FROM (SELECT [InstrumentType], ROW_NUMBER() OVER (ORDER BY [InstrumentType]) AS RowNumber FROM [FinRecon].[dbo].[map_instrument]) AS SubQuery WHERE RowNumber = @intCounter), @SAPText)<> 0 
		BEGIN
			SET @strReturn = (SELECT InstrumentType FROM (SELECT [InstrumentType], ROW_NUMBER() OVER (ORDER BY [InstrumentType]) AS RowNumber FROM [FinRecon].[dbo].[map_instrument]) AS SubQuery WHERE RowNumber = @intCounter)
			RETURN @strReturn
		END
		--If last element int map_instrument and still no match -> Return 'n/a'
		IF CHARINDEX((SELECT InstrumentType FROM (SELECT [InstrumentType], ROW_NUMBER() OVER (ORDER BY [InstrumentType]) AS RowNumber FROM [FinRecon].[dbo].[map_instrument]) AS SubQuery WHERE RowNumber = @intCounter), @SAPText) = 0 AND @intCounter = (SELECT Count([InstrumentType]) FROM [FinRecon].[dbo].[map_instrument])
		BEGIN
			SET  @strReturn = (SELECT 'n/a')
			RETURN @strReturn
		END
		
		SET @intCounter = @intCounter + 1
	END
	
	RETURN @strReturn
	
END

GO

