SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[stp_itw_int_cleanup_itw_bu_hierarchy]

as

begin
/* =============================================
	Author: Matt Fraser
	Create date: 1/8/2010
	Description: Updates the itw_bu_hierarchy table with the laborlevelentryid
				corresponding to each BU as well as the divisionid from the 
				itw_division table.
	Example: exec dbo.stp_itw_int_cleanup_itw_bu_hierarchy
	Revisions: MF 1/8/2010 1.0 Created
   =============================================*/
	set nocount on;

	update  h 
	set laborlevelentryid = e.laborlevelentryid,
	divisionid = d.division_id
	from itw_bu_hierarchy h, laborlevelentry e, itw_division d
	where h.bu_code = e.name
	and h.division_code = d.code
	and d.personnum = 1
	and e.laborleveldefid = 2;

	delete from itw_bu_hierarchy
	where laborlevelentryid is null;
	
	set nocount off;
	
end;


GO


