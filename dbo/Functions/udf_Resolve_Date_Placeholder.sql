
/* 
=======================================================================================================================================
Author:		mkb			
Created:	2021/12
Purpose:	replace date pattern placeholders in @data_input string with values from dbo.asofdate.asOfDate
=======================================================================================================================================
*/

CREATE FUNCTION [dbo].[udf_Resolve_Date_Placeholder] (@data_input nvarchar(1000)) RETURNS nvarchar(1000)
AS
BEGIN
	DECLARE @asofdate datetime
	DECLARE @output nvarchar(2000)

	/*first get the current set AsOfDate*/
	SELECT @asofdate = [AsOfDate_EOM] from [dbo].[AsofDate]

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

