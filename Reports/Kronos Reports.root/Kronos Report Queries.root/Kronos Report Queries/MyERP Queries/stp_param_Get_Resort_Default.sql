USE [ERPWEBAdmin]
GO

/****** Object:  StoredProcedure [dbo].[stp_param_Get_Resort_Default]    Script Date: 01/11/2010 13:07:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




alter procedure [dbo].[stp_param_Get_Resort_Default]

@NetworkID VARCHAR(100)

as

begin
/* =============================================
	Author: Matt Fraser
	Create date: 1/4/2010
	Parameters: @networkid - The Windows logon name of the person for which the data is being retrieved
	Description: Returns the default resort for the person
	Example: exec dbo.stp_param_Get_Resort_default 'mattf'
	Revisions:	MF 1/4/2010 1.0 Created
   =============================================*/
	set nocount on;
	
	DECLARE @vUSER_ID INT, @vUSERTYPE VARCHAR(10);

	set @NetworkID = upper(@NetworkID);

	SELECT @vUSER_ID = USERID
	FROM dbo.Users
	WHERE Network = @NetworkID or Network = ('IDIRECTORY\'+@NetworkID);

	Select l.LocationID, l.Name, l.ResortCode 
	From dbo.Location l inner join dbo.users u
		on l.locationid = u.locationid
	Where u.UserID = @vUSER_ID;
	
	set nocount off;
	
end;



GO

