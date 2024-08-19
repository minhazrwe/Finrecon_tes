

CREATE FUNCTION [dbo].[udf_Check_Accounts] (@Endur_Account varchar(255), @SAP_Account varchar(255))

RETURNS int
AS
BEGIN
	DECLARE @output int

	set @output = case when @Endur_Account = @SAP_Account then 0 else -1 end

	RETURN @output
END

GO

