USE [TKCSDB]
GO

IF OBJECT_ID ('[dbo].[stp_itw_rpt_labour_hours2]') IS NOT NULL
DROP PROCEDURE [dbo].[stp_itw_rpt_labour_hours2]; 

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/* =============================================
	Author:		 Peter Chan
	Create date: 1/22/2010
	Description: Labour Hours Report in MyERP
	Example:	 exec dbo.stp_itw_rpt_labour_hours2 'TR', '1/1/2009', '1/31/2009'
	Revisions:	 PC		1/22/2010	1.0 Created
   =============================================*/

CREATE PROCEDURE [dbo].[stp_itw_rpt_labour_hours2]

@resort varchar(2), 
@startdate datetime, 
@enddate datetime

as

begin

	set nocount on;
	
	SELECT  left(la.laborlev1nm,2) as resort, dv.description,la.laborlev2nm, 
			la.laborlev3nm, sum(a.durationsecsqty/3600.000) as hours, count(distinct a.employeeid) as count            
	FROM	dbo.wfctotal a JOIN dbo.itw_paycode_grouping d ON a.paycodeid = d.paycodeid 
			JOIN dbo.laboracct la ON a.laboracctid = la.laboracctid
			JOIN dbo.itw_bu_hierarchy dbr ON la.laborlev2id = dbr.laborlevelentryid
			JOIN dbo.itw_division dv ON dbr.divisionid = dv.division_id
	WHERE   dbr.resort_code = @resort and
				dbr.personnum = 1 and
				a.notpaidsw = 0 and
				d.resort =  @resort and
				left(la.laborlev1nm,2) =  @resort and
				substring(la.laborlev1nm,3,1) in ('2','4','6') and
				d.pay_type not in ('N', 'FC') and
				a.applydtm between @startdate and @enddate
	group by left(la.laborlev1nm,2), dv.description, la.laborlev2nm, la.laborlev3nm

	union
	 
	SELECT  left(la.laborlev1nm,2) as resort, dv.description,
			la.laborlev2nm, la.laborlev3nm, 0 as hours, count(distinct a.employeeid) as count             
	FROM	dbo.wfctotal a JOIN dbo.itw_paycode_grouping d ON a.paycodeid = d.paycodeid 
			JOIN dbo.laboracct la ON a.laboracctid = la.laboracctid
			JOIN dbo.itw_bu_hierarchy dbr ON la.laborlev2id = dbr.laborlevelentryid
			JOIN dbo.itw_division dv ON dbr.divisionid = dv.division_id
	WHERE   dbr.resort_code =  @resort and
				dbr.personnum = 1 and
				a.notpaidsw = 0 and
				d.resort =  @resort and
				left(la.laborlev1nm,2) =  @resort and
				substring(la.laborlev1nm,3,1) in ('2','4','6') and
				d.pay_type = 'FC' and
				a.applydtm between @startdate and @enddate
	group by left(la.laborlev1nm,2), dv.description, la.laborlev2nm, la.laborlev3nm

	set nocount off;
	
end;

GO

GRANT EXECUTE ON [dbo].[stp_itw_rpt_labour_hours2] TO KronosReports


