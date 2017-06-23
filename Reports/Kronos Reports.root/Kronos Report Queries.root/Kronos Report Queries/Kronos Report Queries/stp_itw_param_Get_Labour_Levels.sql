SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[stp_itw_param_Get_Labour_Levels]

@labourleveldefid int,
@filter varchar(50),
@inactive int = -1

as

begin
/* =============================================
	Author: Matt Fraser
	Create date: 1/4/2010
	Parameters: @labourleveldefid - The labour level definition id.  1 through 7, but only 1, 2, 3, 4, 
				and 6 will return useful data. 
				1 - Job Step
				2 - BU
				3 - Job
				4 - Work Order,
				6 - ROSS/RTP Rate
				@filter - Used to filter the data returned.  Compared against the start of the NAME
				column.
				@inactive - 1 if the labor level is inactive, 0 if it is active and -1 for both active
				and inactive.
	Description: Returns all labour level records from the desired labour level that match the filter.
	Example: exec dbo.stp_itw_param_get_labour_levels 1, 'WB'
	Revisions: MF 1/4/2010 1.0 Created
			   MF 2/25/2010	1.1	Added parameter to specify the Active status of the labor level.
   =============================================*/
	set nocount on;

	select * from LABORLEVELENTRY
	where LABORLEVELDEFID = @labourleveldefid
	and NAME like @filter + '%'
	and (INACTIVE = @inactive
	or isnull(@inactive, -1) = -1);
	
	set nocount off;
	
end;


GO


