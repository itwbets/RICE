SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[stp_itw_param_Get_High_Level_Job_Steps]

@resort varchar(2)

as

begin
/* =============================================
	Author: Matt Fraser
	Create date: 1/4/2010
	Parameters: @resort - The resort used to filter the job step list
	Description: Returns the distinct list of "high-level" job steps which are the 
				first 3 characters of the job step.
	Example: exec dbo.stp_itw_param_get_High_Level_Job_Steps 'WB'
	Revisions: MF 1/4/2010 1.0 Created
   =============================================*/
	set nocount on;

	create table #jobsteps(
	[LABORLEVELENTRYID] [int],
	[NAME] [varchar](50),
	[LABORLEVELDEFID] [int],
	[DESCRIPTION] [varchar](250),
	[OVERHEAD] [int],
	[INACTIVE] [int],
	[UPDATE_DTM] [datetime],
	[UPDATEDBYUSRACCTID] [int],
	[VERSION] [int]);
	
	insert into #jobsteps
	exec dbo.stp_itw_param_get_labour_levels 1, @resort;
	
	select distinct LEFT(name,3) as job_step from #jobsteps;
	
	set nocount off;
	
end;


GO


