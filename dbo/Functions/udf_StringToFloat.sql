









CREATE FUNCTION [dbo].[udf_StringToFloat] (@string nvarchar(100))
/* Function that returns a float number given a string as input. Following Formats are supported
1. 123,345.34
2. 123,345.3
3. 123.345,34
4. 123.345,3
5. 123.345 (The point will be interpreted as thousand separator!)
6. 123,345 (The comma will be interpreted as thousand separator!)
7. 123345
8. e.g. "123,456.23"
9. e.g. 123,456.23 $
*/
RETURNS float 
AS
BEGIN
	
	DECLARE @output float
	DECLARE @decimalseparator nvarchar(1)
	DECLARE @thousandseparator nvarchar(1)
	Set @decimalseparator = ''
	Set @thousandseparator = ''
	
	/*Remove Currency Characters*/
	set @string = replace(@string, '$','')
	set @string = replace(@string, '€','')
	set @string = replace(@string, '£','')

	/*Remove spaces from the input*/
	set @string = REPLACE(@string,char(32),'')
	
	/*Remove a preceding or succeeding character from the input*/
	if ISNUMERIC(left(@string,1))=0 and len(@string)>0 
	begin
			SET @string= right(@string,len(@string)-1)
	end
	if ISNUMERIC(right(@string,1))=0 and len(@string)>0 
	begin
		SET @string= left(@string,len(@string)-1)
	end

	/*Detect the decimal- and thousendseparator*/
	if left(right(@string,3),1) = '.' or left(right(@string,2),1) = '.' or right(@string,1) = '.'
	begin
		Set @decimalseparator = '.'
		Set @thousandseparator = ','
	end
	else 
	if left(right(@string,3),1) = ',' or left(right(@string,2),1) = ',' or right(@string,1) = ','
	begin
		Set @decimalseparator = ','
		Set @thousandseparator = '.'
	end
	else 
	if left(right(@string,4),1) = '.'
	begin
		Set @decimalseparator = ','
		Set @thousandseparator = '.'
	end
	else 
	if left(right(@string,4),1) = ','
	begin
		Set @decimalseparator = '.'
		Set @thousandseparator = ','
	end

	/*Remove the thousandseperator from the input and use '.' as a decimalseparator */
	if @thousandseparator <>''
	begin
		Set @string = replace(@string, @thousandseparator,'')
		if @decimalseparator = ',' 
		begin
			Set @string = replace(@string, @decimalseparator,'.')
		end
	end

	SET @output = try_convert(float,@string)


	RETURN @output
END

GO

