CREATE TABLE [dbo].[AsOfDate] (
    [AsOfDate_EOM]            DATETIME NULL,
    [AsOfDate_prevEOM]        DATETIME NULL,
    [AsOfDate_EOY]            DATETIME NULL,
    [AsOfDate_prevEOY]        DATETIME NULL,
    [ID]                      INT      IDENTITY (1, 1) NOT NULL,
    [AsOfDate_MtM_Check]      DATETIME NULL,
    [AsOfDate_FT_Replacement] DATETIME NULL,
    CONSTRAINT [pk_AsOfDate] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO



CREATE trigger [dbo].[AsOfDate-change-Log-insert] 
	on [dbo].[AsOfDate] 
	after insert as
		if (select count(*) from [dbo].[AsOfDate]) > 1
			BEGIN
				RAISERROR ('This table has only 1 line', 1, 1)
				ROLLBACK TRANSACTION
				RETURN
			END

GO



/*
purpose: 
checks, who is allowed to change entries in dbo.asofdate 

*/

CREATE trigger [dbo].[AsOfDate-change-Log-user-rights] 
	on [dbo].[AsOfDate] after update as
	if user_name () <> 'ENERGY\R884862'     /*MBE*/
		and user_name () <> 'ENERGY\R880382'  /*MKB*/
		and user_name () <> 'ENERGY\R884018'  /*VP*/
		and user_name () <> 'ENERGY\UI856115' /*SH*/
		and user_name () <> 'ENERGY\UI626985' /*MK*/
		and user_name () <> 'ENERGY\UI788089' /*MU*/
		and user_name () <> 'ENERGY\UI555471' /*PG*/
		and user_name () <> 'ENERGY\UI919293' /*SU*/
		and user_name () <> 'ENERGY\UI155028' /*R2D2*/
	BEGIN
		INSERT INTO [dbo].[AsOfDate] (AsOfDate_EOM, AsOfDate_prevEOM, AsOfDate_EOY,AsOfDate_MtM_Check )
			SELECT AsOfDate_EOM, AsOfDate_prevEOM, AsOfDate_EOY, AsOfDate_MtM_Check FROM deleted
	END

GO

