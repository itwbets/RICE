SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[stp_itw_param_Get_Jobs]

@labourleveldefid int,
@filter varchar(50)

as

begin
/* =============================================
	Author: Betsy Kowan
	Create date: 2/24/2010
	Parameters: @labourleveldefid - The labour level definition id.  1 through 7, but only 1, 2, 3, 4, 
				and 6 will return useful data. 
				1 - Job Step
				2 - BU
				3 - Job
				4 - Work Order,
				6 - ROSS/RTP Rate
				@filter - Used to filter the data returned.  Compared against the start of the LABORLEV1DSC
				column.
	Description: Returns all labour level records from the desired labour level that match the filter.
	Example: exec dbo.stp_itw_param_get_jobs 3, 'TR'
	Revisions: BK 2/24/2010 1.0 Created
   =============================================*/
	set nocount on;

	select distinct a.name, a.description
	from dbo.laborlevelentry a inner join dbo.laboracct b on a.name = b.laborlev3nm
	where LABORLEVELDEFID = @labourleveldefid
	and laborlev1dsc like @filter + '%';
	
	set nocount off;
	
end;


GO


