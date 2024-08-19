

CREATE FUNCTION [dbo].[udf_convertStrolfDate] (@date datetime2)

RETURNS nvarchar(100)
AS
BEGIN
	DECLARE @output nvarchar(10)
	
	if len(convert(varchar,day(@date))) = 1 
		Begin
			set @output = '0' + convert(varchar,day(@date)) + '.'
		end 
	else set @output =  convert(varchar,day(@date)) + '.'

		
	if len(convert(varchar,month(@date))) = 1
		Begin
			set @output = @output + '0' + convert(varchar,month(@date)) + '.'
		end 
	else set @output = @output + convert(varchar,month(@date)) + '.'
    
	set @output = @output + convert(varchar,year(@date))

--	PRINT @output

	RETURN @output
END

GO

