
CREATE PROCEDURE [dbo].[fill_AWV_Log_Diff]

@nameofquery nvarchar(255),
@nameofoption nvarchar(255)

AS
BEGIN TRY

	DECLARE @LogInfo Integer
	DECLARE @Current_Procedure nvarchar(40)
	DECLARE @step Integer
	DECLARE @CoBDate as datetime
	DECLARE @Anzahl Integer
	DECLARE @Log_Text varchar (200)

	SELECT @CoBDate = AsOfDate_EOM from [dbo].[AsOfDate]

	SELECT @step = 10
	SELECT @Current_Procedure = Object_Name(@@PROCID)
	
	SELECT @step = 20
	SELECT @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

	EXEC dbo.Write_Log 'Info', 'START', @Current_Procedure, NULL, NULL, @step, 1 
		--===========================================================================================================================================================================================
		-- fill now the table with the new combinations, so that we can use them next month
		-- also we need to distinguish between Z10 / Diverse and the rest of the reports
		--===========================================================================================================================================================================================
  SELECT @step = 30
	IF @nameofoption = 'Z10_Responsible'
		BEGIN
			SELECT @step = 31
			--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] SELECT @Current_Procedure + ' BEGIN fill [AWV_Log] for Z10_Responsible', GETDATE () END
			SET @Log_Text ='start fill [AWV_Log] for Z10_Responsible.'
			EXEC dbo.Write_Log 'Info', @Log_Text, @Current_Procedure, NULL, NULL, @step, 1 
			
			INSERT INTO AWV_Log ( SAPDocumentNumber, SAPAccount, AsOfDate, SAPCompanyCode, AWVAnlage, [AWV-Responsible], [User], ExportDate )
			SELECT distinct rr.[SAP-Belegnummer],rr.[SAP-Konto], @CoBDate, rr.[SAP-Buchungskreis], rr.[AWV-Anlage] ,rr.[AWV-Responsible], user_name(), GetDAte() 
			from   AWV_Results_Diff as rr 
			where  rr.[AWV-Responsible] = 'Z10_Responsible' and  not ((rr.[SAP-Konto]  = '4008038' or rr.[SAP-Konto] = '6018038') and (rr.[SAP-Text] like '%;290;%' or rr.[SAP-Text]  like '%;286;%'))
			
			--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] SELECT @Current_Procedure + ' end   fill [AWV_Log] for Z10_Responsible', GETDATE () END
			SET @Log_Text ='end fill [AWV_Log] for Z10_Responsible.'
			EXEC dbo.Write_Log 'Info', @Log_Text, @Current_Procedure, NULL, NULL, @step, 1 
		END

	SELECT @step = 40
	IF @nameofoption = 'Diverse'
		BEGIN				
			--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] SELECT @Current_Procedure + ' start fill [AWV_Log] for Diverse', GETDATE () END
			SELECT @step = 41
			SET @Log_Text ='start fill [AWV_Log] for Diverse.'
			EXEC dbo.Write_Log 'Info', @Log_Text, @Current_Procedure, NULL, NULL, @step, 1 

			INSERT INTO AWV_Log ( SAPDocumentNumber, SAPAccount, AsOfDate, SAPCompanyCode, AWVAnlage, [AWV-Responsible], [User], ExportDate )
			SELECT distinct rr.[SAP-Belegnummer],rr.[SAP-Konto], @CoBDate, rr.[SAP-Buchungskreis], rr.[AWV-Anlage] ,rr.[AWV-Responsible], user_name(), GetDAte() 
			from   AWV_Results_Diff as rr 
			where  rr.[AWV-Responsible] = 'Diverse' or ((rr.[SAP-Konto]  = '4008038' or rr.[SAP-Konto] = '6018038') and (rr.[SAP-Text] like '%;290;%' or rr.[SAP-Text]  like '%;286;%'))
			
			--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] SELECT @Current_Procedure + ' end   fill [AWV_Log] for Diverse', GETDATE () END
			SET @Log_Text ='end fill [AWV_Log] for Z10_Responsible.'
			EXEC dbo.Write_Log 'Info', @Log_Text, @Current_Procedure, NULL, NULL, @step, 1 
		END

	SELECT @step = 50
	IF @nameofoption != 'Diverse' and @nameofoption != 'Z10_Responsible'
		BEGIN
			SELECT @step = 51
			--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] SELECT @Current_Procedure + ' start fill [AWV_Log] for the rest', GETDATE () END
			SET @Log_Text ='BEGIN fill [AWV_Log] for the rest.'
			EXEC dbo.Write_Log 'Info', @Log_Text, @Current_Procedure, NULL, NULL, @step, 1 
		
			INSERT INTO AWV_Log ( SAPDocumentNumber, SAPAccount, AsOfDate, SAPCompanyCode, AWVAnlage, [AWV-Responsible], [User], ExportDate )
			SELECT distinct rr.[SAP-Belegnummer],rr.[SAP-Konto], @CoBDate, rr.[SAP-Buchungskreis], rr.[AWV-Anlage] ,rr.[AWV-Responsible], user_name(), GetDAte() 
			from   AWV_Results_Diff as rr 
			where  rr.[AWV-Responsible] = @nameofoption 
		
			--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] SELECT @Current_Procedure + ' end   fill [AWV_Log] for the rest', GETDATE () END
			SET @Log_Text ='end fill [AWV_Log] for the rest.'
			EXEC dbo.Write_Log 'Info', @Log_Text, @Current_Procedure, NULL, NULL, @step, 1 

		END
	--===========================================================================================================================================================================================
	-- delete now the interim tables
	-- we use "truncate" here as this is faster than "delete from"
	--===========================================================================================================================================================================================
		SELECT @step = 60
		IF @nameofoption = 'Delete_Log_Diff'
		BEGIN
			SELECT @step = 61
			--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] SELECT @Current_Procedure + ' delete from AWV_Log_Diff_Part ', GETDATE () END
			SET @Log_Text ='Delete from AWV_Log_Diff_Part.'
			EXEC dbo.Write_Log 'Info', @Log_Text, @Current_Procedure, NULL, NULL, @step, 1 
			TRUNCATE TABLE [AWV_Log_Diff_Part]
			
			SELECT @step = 62
			--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] SELECT @Current_Procedure + ' delete from AWV_Log_Diff', GETDATE () END
			SET @Log_Text ='Delete from AWV_Log_Diff.'
			EXEC dbo.Write_Log 'Info', @Log_Text, @Current_Procedure, NULL, NULL, @step, 1 

			TRUNCATE TABLE AWV_Log_Diff

			SELECT @step = 63						
			--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] SELECT @Current_Procedure + ' delete from AWV_Export', GETDATE () END
			SET @Log_Text ='Delete from AWV_Export.'
			EXEC dbo.Write_Log 'Info', @Log_Text, @Current_Procedure, NULL, NULL, @step, 1 
			TRUNCATE TABLE [AWV_Export]
			
			--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] SELECT @Current_Procedure + ' done with deletions', GETDATE () END
			SET @Log_Text ='Done with deletions.'
			EXEC dbo.Write_Log 'Info', @Log_Text, @Current_Procedure, NULL, NULL, @step, 1 
			
		END

		SELECT @step = 70
		--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] SELECT @Current_Procedure + ' - FINISHED', GETDATE () END
		SET @Log_Text ='FINISHED'
		EXEC dbo.Write_Log 'Info', @Log_Text, @Current_Procedure, NULL, NULL, @step, 1

END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @Current_Procedure, @step
		SET @Log_Text ='FAILED! - check log for details'
		EXEC dbo.Write_Log 'ERROR', @Log_Text, @Current_Procedure, NULL, NULL, @step, 1
		--BEGIN insert into [dbo].[Logfile] SELECT @Current_Procedure + ' - FAILED', GETDATE () END

	END CATCH

GO

