

CREATE FUNCTION [dbo].[udf_get_path] (@data_input nvarchar(300))

RETURNS nvarchar(2000)
AS
BEGIN
	DECLARE @path [nvarchar] (2000)
	DECLARE @asofdate datetime
	DECLARE @output nvarchar(2000)
		select @path = [path] from  [dbo].[pathtofiles] where [dbo].[pathtofiles].[Source] = '' + @data_input + ''
		select @asofdate = [AsOfDate_EOM] from [dbo].[AsofDate]
		set @output =
			case 
				when  LTRIM(RTRIM(len(month(@asofdate)))) = 1 then replace (@path, '%MM%', '0' +  LTRIM(RTRIM(month(@asofdate))))
				when  LTRIM(RTRIM(len(month(@asofdate)))) = 2 then replace (@path, '%MM%', LTRIM(RTRIM( month(@asofdate))))
		end
			SET @output = LTRIM(RTRIM(replace (@output, '%YYYY%', year(@asofdate))))
	RETURN @output
end

GO

