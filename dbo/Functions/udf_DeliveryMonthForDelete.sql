

CREATE FUNCTION [dbo].[udf_DeliveryMonthForDelete] (@AsOfDate Date)

RETURNS nvarchar (10)
AS
BEGIN
	DECLARE @output nvarchar (10)
	DECLARE @month as nvarchar (2)

	--select @AsOfDate = AsOfDate_EOM from [dbo].[AsOfDate]

	if month(@AsOfDate) = 12 
		BEGIN 
			set @output = convert(nvarchar, year(@AsOfDate)+1) + '/' + '01'
		END
	else
		if month(@AsOfDate) in (9,10,11)
			BEGIN
				set @output = convert(nvarchar, year(@AsOfDate)) + '/' + convert(nvarchar,month(@AsOfDate)+1)
			END
		else
			set @output = convert(nvarchar, year(@AsOfDate)) + '/' + '0' + convert(nvarchar,month(@AsOfDate)+1)
	RETURN @output
END

GO

