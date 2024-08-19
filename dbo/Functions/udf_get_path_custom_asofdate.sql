


CREATE FUNCTION [dbo].[udf_get_path_custom_asofdate] (@data_input nvarchar(300), @custom_asofdate nvarchar(10) = '')

RETURNS nvarchar(2000)
AS
BEGIN
	DECLARE @path [nvarchar] (2000)
	DECLARE @asofdate date
	DECLARE @output nvarchar(2000)
		SELECT @path = [path] from  [dbo].[pathtofiles] where [dbo].[pathtofiles].[Source] = '' + @data_input + ''
		IF @custom_asofdate = ''
			SELECT @asofdate = cast(asofdate_eom as date) FROM dbo.asofdate as cob
		ELSE
			SELECT @asofdate = cast(@custom_asofdate as date)

		set @output =
			case 
				when  LTRIM(RTRIM(len(month(@asofdate)))) = 1 then replace (@path, '%MM%', '0' +  LTRIM(RTRIM(month(@asofdate))))
				when  LTRIM(RTRIM(len(month(@asofdate)))) = 2 then replace (@path, '%MM%', LTRIM(RTRIM( month(@asofdate))))
		end
			SET @output = LTRIM(RTRIM(replace (@output, '%YYYY%', year(@asofdate))))
	RETURN @output
end

GO

