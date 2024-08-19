








CREATE FUNCTION [dbo].[udf_StringToDate] (@date nvarchar(100))
/* Function that return a date. The following date formats are valid as an input:
- YYYY-MM-DD
- YYYY.MM.DD
- YYYY/MM/DD
- e.g. "YYYY-MM-DD" 
- DD.MM.YYYY
- DD/MM/YYYY
- DD-MM-YYYY
- e.g. "DD.MM.YYYY" 
- e.g. "20-Jan-2022" 

NOT ACCEPTED: MM/DD/YYYY !!!
*/
RETURNS date 
AS
BEGIN
	DECLARE @output date
	DECLARE @date_length int
	DECLARE @year nvarchar(4)
	DECLARE @day nvarchar(2)
	DECLARE @month nvarchar(3)
	SET @date_length = len(@date)
	set @output =  null
	/*Remove spaces from the input*/
	set @date = REPLACE(@date,char(32),'')
	
	/*Remove a preceding/succeeding character like quotation marks: "2022-07-20" */
	if ISNUMERIC(left(@date,1))=0
	begin
		SET @date= right(@date,len(@date)-1)
	end
	if ISNUMERIC(right(@date,1))=0
	begin
		SET @date= left(@date,len(@date)-1)
	end

	/*Get the date for formats like 20-Jan-2022*/
	if len(@date) = 11
	begin
		if ISNUMERIC(left(@date,4))=1 and ISNUMERIC(right(@date,2))=1
		begin
			Set @year = left(@date,4)
			Set @day = right(@date,2)
		end
		else if ISNUMERIC(right(@date,4))=1 and ISNUMERIC(left(@date,2))=1
		begin
			Set @year = right(@date,4)
			Set @day = left(@date,2)
		end
		if ISNUMERIC(SUBSTRING(@date,4,3))=0
		begin
			Set @month = upper(SUBSTRING(@date,4,3))
			if @month = 'JAN'
				Set @month = '01'
			else if @month = 'FEB'
				Set @month = '02'
			else if @month = 'MAR' or @month = 'MÄR' or @month = 'MRZ'
				Set @month = '03'
			else if @month = 'APR'
				Set @month = '04'
			else if @month = 'MAY' or @month = 'MAI'
				Set @month = '05'
			else if @month = 'JUN'
				Set @month = '06'
			else if @month = 'JUL'
				Set @month = '07'
			else if @month = 'AUG'
				Set @month = '08'
			else if @month = 'SEP'
				Set @month = '09'
			else if @month = 'OCT' or @month = 'OKT'
				Set @month = '10'
			else if @month = 'NOV'
				Set @month = '11'
			else if @month = 'DEC' or @month = 'DEZ'
				Set @month = '12'
		end
		if len(@year)=4 and len(@day)=2 and len(@month)=2 
			SET @output = convert(date,datefromparts(@year,@month,@day))
	end

	/*Get the date for formats like 2022-01-20*/
	if len(@date) = 10 
	begin
		if SUBSTRING(@date,5,1) in ('-','.','/') and SUBSTRING(@date,8,1) in ('-','.','/') --Format is e.g. YYYY-MM-DD
		begin
			SET @output = convert(date,@date) 
		end
		if SUBSTRING(@date,3,1) in ('-','.','/') and SUBSTRING(@date,6,1) in ('-','.','/') --Format is e.g. DD.MM.YYYY
		begin
			SET @output = convert(date,datefromparts(substring(@date,7,4),substring(@date,4,2),substring(@date,1,2))) 
		end
	end 
	


	--PRINT @output

	RETURN @output
END

GO

