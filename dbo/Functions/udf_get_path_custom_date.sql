
/*========================================================================================================================
	author:		mkb
	created:	2024/01
	purpose:	Substitutes date-placeholders by a formatted values, given with input parameter @custom_date.
						if @custom_date is set to "NULL" or "default", the variable will be filled with "AsOfDate_EOM" from table dbo.AsOfDate.					
-----------------------------------------------------------------------------------------------------------------
	Changes:
	2024-01-00, mkb, initial setup
=========================================================================================================================*/


CREATE FUNCTION [dbo].[udf_get_path_custom_date] (@input_path_source nvarchar(2000), @custom_date date = NULL)
RETURNS nvarchar(2000)
AS
BEGIN

	DECLARE @path nvarchar (2000)
	DECLARE @COB date
	DECLARE @COB_EOM date
	DECLARE @output nvarchar(2000)
	

	/*get the path_string from path_to_files-table. */
	SELECT @path = [path] FROM dbo.pathtofiles WHERE [Source] = @input_path_source
		
	/*select the regular_as_of_date from dbo.AsOfDate*/
	SELECT @COB_EOM = AsOfDate_EOM FROM dbo.AsOfDate

	/*now take either the given parameter date or use the substiturte in case it's missing*/
	SELECT @COB = isnull(@custom_date,@COB_EOM)
	
	--/*replace the date potential placeholders*/				
	SELECT @output = replace (@path, '%YYYY%', format(@COB,'yyyy'))	/*replace 4-digit-year placeholder*/
	SELECT @output = replace (@output, '%YY%', format(@COB,'yy'))		/*replace 2-digit-year placeholder*/
	SELECT @output = replace (@output, '%MM%', format(@COB,'MM'))		/*replace month placeholder and consider leading zeros*/
	--/*...to be extended here...*/
	
	---SELECT @output = @path
	/*return the result*/
	RETURN @output
END

GO

