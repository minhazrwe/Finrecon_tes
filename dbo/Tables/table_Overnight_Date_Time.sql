CREATE TABLE [dbo].[table_Overnight_Date_Time] (
    [ID]                      INT      IDENTITY (1, 1) NOT NULL,
    [Overnight_Starting_Time] DATETIME NOT NULL,
    [Copy_FT_Reports_Time]    DATETIME NOT NULL,
    CONSTRAINT [pk_table_Overnight_Date_Time] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

CREATE trigger [dbo].[table_Overnight_Date_Time-change-Log-user-rights] on [dbo].[table_Overnight_Date_Time] 
after update 
as
	if 
		user_name () <> 'ENERGY\R884862'				/*mbe*/
		and user_name () <> 'energy\R880382'		/*mkb*/
		and user_name () <> 'energy\UI626985'		/*mk*/
		and user_name () <> 'energy\UI788089'		/*mu*/
		and user_name () <> 'ENERGY\UI155028'		/*r2d2*/
		and user_name () <> 'energy\UI555471'		/*pg*/
		and user_name () <> 'dbo'								/*r2d2 due to special rights*/
	BEGIN
		INSERT INTO [dbo].[table_Overnight_Date_Time] (Overnight_Starting_Time, Copy_FT_Reports_Time)
			SELECT Overnight_Starting_Time, Copy_FT_Reports_Time FROM deleted
	END

GO

CREATE trigger [dbo].[table_Overnight_Date_Time-change-Log-insert] 
	on dbo.table_Overnight_Date_Time 
	after insert as
		if (select count(*) from [dbo].[table_Overnight_Date_Time]) > 1
			BEGIN
				RAISERROR ('This table has only 1 line', 1, 1)
				ROLLBACK TRANSACTION
				RETURN
			END

GO

