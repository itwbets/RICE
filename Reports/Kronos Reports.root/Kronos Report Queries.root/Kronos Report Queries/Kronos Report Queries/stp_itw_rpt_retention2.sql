USE [TKCSDB]
GO

IF OBJECT_ID ('[dbo].[stp_itw_rpt_retention2]') IS NOT NULL
DROP PROCEDURE [dbo].[stp_itw_rpt_retention2]; 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* =============================================
	Author:		 Peter Chan
	Create date: 1/21/2010
	Description: Retention Premium Report in MyERP
	Example:	 exec dbo.stp_itw_rpt_retention2 'TR7', '1/1/2009', '1/31/2009'
	Revisions:	 PC		1/21/2010	1.0 Created
   =============================================*/

CREATE procedure [dbo].[stp_itw_rpt_retention2]

@HighLevelJobStep as char(3),
@from_date as datetime,
@to_date as datetime

as
begin

	set nocount on;

	select  p.personfullname, p.personnum, p.homelaborlevelnm1, p.homelaborlevelnm3, t.laborlevelname1, t.paycodename, sum(timeinseconds/3600.000) as hours, 
		homestreet + CASE WHEN homecity is null THEN ' ' ELSE  ',  ' + homecity  END
		+ CASE WHEN homestate is null THEN ' ' ELSE ',  ' + homestate END
		+ CASE WHEN homezip is null THEN ' ' ELSE ',  ' + homezip END as [Home Address]
	from dbo.vp_totals t inner join dbo.vp_personv42 p on t.personid = p.personid
	where  t.paycodetype <> 'G'
	and t.paycodeid in (1,2,4,5,15,16,18,1001,2103,2104,2105,2106,2108,2109,2110,2111,2113,2114,2115,2116,2118,2119,2120,2121)
	and t.employeeid in 
		(select distinct(employeeid) from wfctotal t1 inner join laboracct la on t1.laboracctid = la.laboracctid 
		    where left(la.LABORLEV1NM, 3) like @HighLevelJobStep and t1.applydtm between @from_date and @to_date)
	and t.applydate between @from_date and @to_date
	group by p.personfullname, p.personnum, p.homelaborlevelnm1, p.homelaborlevelnm3, t.laborlevelname1, t.paycodename, 
		homestreet + CASE WHEN homecity is null THEN ' ' ELSE  ',  ' + homecity  END
		+ CASE WHEN homestate is null THEN ' ' ELSE ',  ' + homestate END
		+ CASE WHEN homezip is null THEN ' ' ELSE ',  ' + homezip END
	order by p.personfullname, t.laborlevelname1, t.paycodename

	set nocount off;

end;
GO

GRANT EXECUTE ON [dbo].[stp_itw_rpt_retention2] TO KronosReports


