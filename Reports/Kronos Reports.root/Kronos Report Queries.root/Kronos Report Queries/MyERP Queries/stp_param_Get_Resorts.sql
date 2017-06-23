USE [ERPWEBAdmin]
GO

/****** Object:  StoredProcedure [dbo].[stp_param_Get_Resorts]    Script Date: 01/11/2010 13:07:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




alter procedure [dbo].[stp_param_Get_Resorts]

@NetworkID VARCHAR(100)

as

begin
/* =============================================
	Author: Matt Fraser
	Create date: 1/4/2010
	Parameters: @networkid - The Windows logon name of the person for which the data is being retrieved
	Description: Returns all resorts to which the person has access
	Example: exec dbo.stp_param_Get_Resorts 'mattf'
	Revisions: MF 1/4/2010 1.0 Created
   =============================================*/
	set nocount on;
	
	DECLARE @vUSER_ID INT, @vUSERTYPE VARCHAR(10);

	set @NetworkID = upper(@NetworkID);

	SELECT @vUSER_ID = USERID, @vUSERTYPE = USERTYPE
	FROM dbo.Users
	WHERE Network = @NetworkID or Network = ('IDIRECTORY\'+@NetworkID);


	IF @vUSERTYPE <> 'Admin' and @vUSERTYPE <> 'SuperUser'
	begin
		Select Location.LocationID, Location.Name, Location.ResortCode 
		From dbo.Location 
		Where Location.Name <> 'All' 
		And Location.LocationID In	(Select User_Location.LocationId From User_Location Where User_Location.UserID = @vUSER_ID)
		Order By Location.Name ASC;
	end;
	else
	begin
		Select l.LocationID, l.Name, l.ResortCode 
		From dbo.Location l
		Where l.Name <> 'All'
		Order By l.Name;
	end;
	
	set nocount off;
	
end;



GO

