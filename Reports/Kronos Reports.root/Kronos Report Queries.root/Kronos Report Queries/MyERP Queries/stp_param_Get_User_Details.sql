USE [ERPWEBAdmin]
GO

/****** Object:  StoredProcedure [dbo].[stp_param_Get_User_Details]    Script Date: 01/11/2010 13:07:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[stp_param_Get_User_Details]

@NetworkID VARCHAR(100)

as

begin
/* =============================================
	Author: Matt Fraser
	Create date: 1/4/2010
	Parameters: @networkid - The Windows logon name of the person for which the data is being retrieved
	Description: Returns the details for the desired user
	Example: exec dbo.stp_param_Get_User_Details 'mattf'
	Revisions: MF 1/4/2010 1.0 Created
   =============================================*/
	set nocount on;
	
	set @NetworkID = upper(@NetworkID);

	Select u.*, l.Name, l.ResortCode 
	From dbo.Location l inner join dbo.users u
		on l.locationid = u.locationid
	Where Network = @NetworkID or Network = ('IDIRECTORY\'+@NetworkID);
	
	set nocount off;
	
end;



GO

