

 

CREATE PROCEDURE [dbo].[AccessControlCheck] 
		 @user varchar (50)
		,@item varchar(200)
		,@status tinyint OUTPUT
AS
	SET NOCOUNT ON 

BEGIN 
---	declare @status tinyint

		SELECT @status = dbo.AccessControl.Status FROM dbo.AccessControl WHERE UserName= @user and (item = @item or item='ADMIN')
		     ---  select [dbo].[AccessControl].[Status] FROM [dbo].[AccessControl] WHERE [username]= @user and ([item] = @item or [item]='ADMIN')
		
		IF @@ERROR <>0   
			BEGIN  
				RETURN 13
			 END  
		ELSE  
			BEGIN  
				IF @status IS NULL 
					RETURN 13
				ELSE -- SUCCESS!!  
					RETURN 1
				END  
			END

GO

