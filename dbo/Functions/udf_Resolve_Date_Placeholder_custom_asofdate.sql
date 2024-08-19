
/* 
-- =======================================================================================================================================
Author:		mkb			
Created:	2021/12
Purpose:	replace date pattern placeholders in @data_input string with date given in @custom_asofdate, 
					if @custom_asofdate is missing, asofdate_eom from dbo.asofdate is taken
-- =======================================================================================================================================
*/

CREATE FUNCTION [dbo].[udf_Resolve_Date_Placeholder_custom_asofdate] (@data_input nvarchar(1000), @custom_asofdate nvarchar(10) = '') RETURNS nvarchar(1000)
AS
BEGIN
	DECLARE @asofdate date
	DECLARE @output nvarchar(2000)

	/*check if @custom AsOfDate is filled at all*/
	IF @custom_asofdate = ''
		SELECT @asofdate = cast(asofdate_eom as date) FROM dbo.asofdate as cob
	ELSE
		SELECT @asofdate = cast(@custom_asofdate as date)

	/*now replace the possible date patterns*/	

	/*for days*/
	SET @data_input = replace (@data_input, '%DD%', format(@asofdate ,'dd'))
	
	/*for months -- always a two-digit month gets returned!*/
	SET @data_input= replace (@data_input, '%MM%', format(@asofdate ,'MM'))

	/*for years*/
	SET @data_input = replace (@data_input, '%YY%', format(@asofdate ,'yy'))
	SET @data_input = replace (@data_input, '%YYYY%', format(@asofdate ,'yyyy'))

	/*return the input string with replaced patterns*/
	SET @output = @data_input

	RETURN @output
END

--select [dbo].[udf_resolve_date_placeholder]('%MM%-%YYYY%')
--select [dbo].[udf_resolve_date_placeholder]('%MM%-%DD%')
--select [dbo].[udf_resolve_date_placeholder]('%MM%_%YYYY%')
--select [dbo].[udf_resolve_date_placeholder]('%YY%')
--select [dbo].[udf_resolve_date_placeholder]('%YYYY%')
--select [dbo].[udf_resolve_date_placeholder]('%YY%_FUELLTEXT_%YYYY%')

GO

