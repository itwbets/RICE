SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[stp_itw_param_Get_Wage_Types]

as

begin
/* =============================================
	Author: Matt Fraser
	Create date: 1/4/2010
	Parameters: None
	Description: Returns the list of all wage types.
	Example: exec dbo.stp_itw_param_get_wage_types
	Revisions: MF 1/4/2010 1.0 Created
   =============================================*/
	set nocount on;

	select * from itw_wage_type
	order by sort_order;
	
	set nocount off;
	
end;


GO


