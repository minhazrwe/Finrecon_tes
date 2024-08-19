
CREATE FUNCTION [dbo].[udf_SplitData] (@data varchar(255), @colToReturn int)
-- Purpose:	Replaces all , with ;
-- Then returns the 'column' as per the passed argument.
-- Note: Only splits up to 4 columns.
-- So if @data = 'ABC,123;XYZ,890' and @colToReturn=3
-- Result is to be 'XYZ'

RETURNS nchar(100)
AS
BEGIN
	--DECLARE @test nvarchar(255)
	DECLARE @temp nvarchar(255)
	DECLARE @output nvarchar(200)
	DECLARE @firstPos int
	DECLARE @secondPos int
	DECLARE @thirdPos int
	DECLARE @fourthPos int
	DECLARE @fifthPos int
	DECLARE @sixthPos int



-- Test Data
--	DECLARE @data nvarchar(255)
--	DECLARE @colToReturn INT
--	SET @data = '1;BE;ELECTRAWINDS BASTOGN;2015/02;;'
--	SET @data = '*EEG Aufschlag, Schw,enk Zement, Ulm4003012'
--	SET @colToReturn = 4

	SET @temp = REPLACE(@data,',', ';')		-- Replace each occurrance of ' with ;

	-- Find the positions of each occurrance of a ; in the passed string.
	SET @firstPos = CHARINDEX(';', @temp, 1)
	SET @secondPos = CHARINDEX(';', @temp, @firstPos + 1)
	SET @thirdPos = CHARINDEX(';', @temp, @secondPos + 1)
	SET @fourthPos = CHARINDEX(';', @temp, @thirdPos + 1)
	SET @fifthPos = CHARINDEX(';', @temp, @fourthPos + 1)
	SET @sixthPos = CHARINDEX(';', @temp, @fifthPos + 1)
	
	-- Now find the position of the ;s which represent the 'column to return
	SET @output = 
		CASE
			WHEN @colToReturn = 1 AND @firstPos <> 0 THEN SUBSTRING(@temp, 1, @firstPos - 1)
					
			WHEN @colToReturn = 2 AND @secondPos = 0 THEN SUBSTRING(@temp, @firstPos + 1, LEN(@temp))
			WHEN @colToReturn = 2 AND @secondPos <> 0 THEN SUBSTRING(@temp, @firstPos + 1, (@secondPos - 1) - @firstPos)

			WHEN @colToReturn = 3 AND @thirdPos = 0 THEN SUBSTRING(@temp, @secondPos + 1, LEN(@temp))
			WHEN @colToReturn = 3 AND @thirdPos <> 0 THEN SUBSTRING(@temp, @secondPos + 1, (@thirdPos - 1) - @secondPos)

			WHEN @colToReturn = 4 AND @fourthPos = 0 THEN SUBSTRING(@temp, @thirdPos + 1, LEN(@temp))
			WHEN @colToReturn = 4 AND @fourthPos <> 0 THEN SUBSTRING(@temp, @thirdPos + 1, (@fourthPos - 1) - @thirdPos)

			WHEN @colToReturn = 5 AND @fifthPos = 0 THEN SUBSTRING(@temp, @fourthPos + 1, LEN(@temp))
			WHEN @colToReturn = 5 AND @fifthPos <> 0 THEN SUBSTRING(@temp, @fourthPos + 1, (@fifthPos - 1) - @fourthPos)

			WHEN @colToReturn = 6 AND @sixthPos = 0 THEN SUBSTRING(@temp, @fifthPos + 1, LEN(@temp))
			WHEN @colToReturn = 6 AND @sixthPos <> 0 THEN SUBSTRING(@temp, @fifthPos + 1, (@sixthPos - 1) - @fifthPos)

			WHEN @colToReturn = 7  THEN SUBSTRING(@temp, @fourthPos + 1, LEN(@temp))

		ELSE 'No section to return'	
		END
--	PRINT @temp
--	PRINT 'FROM ' + CAST(@secondPos + 1 AS VARCHAR(5)) + ' for ' + CAST((@thirdPos - 1) - @secondPos AS VARCHAR(5))
	SET @output = LTRIM(RTRIM(@output))
--	PRINT @output

	RETURN @output
END

GO

