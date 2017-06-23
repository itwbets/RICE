SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

alter procedure [dbo].[stp_itw_param_Get_Divisions]

@JDEABNumber int = 1

as

begin
/* =============================================
	Author: Matt Fraser
	Create date: 1/4/2010
	Parameters: @JDEABNumber -	The JDE address book number which owns the desired list of divisions.
								The default is 1, which is the owner of the "standard" divisions.
	Description: Returns the list of available divisions for the desired JDE AB number.
	Example: exec dbo.stp_itw_param_get_divisions 1022023
	Revisions:	MF 1/4/2010		1.0 Created
				PC 2/11/2010	1.1 div_label column displays description only when code is null
   =============================================*/
	set nocount on;

	select division_id, description, personnum, code, 
	ISNULL(	code + ' - ' + description, description) as div_label	
	from itw_division
	where personnum = @JDEABNumber
	order by code;
	
	set nocount off;
	
end;
GO
