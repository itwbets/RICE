USE [TKCSReports]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_itw_rpt_retention]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_itw_rpt_retention]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* =============================================
	Author:		 Peter Chan
	Create date: 1/21/2010
	Description: Retention Premium Report in MyERP
	Example:	 exec dbo.sp_itw_rpt_retention 'TR7', '1/1/2009', '1/31/2009'
	Revisions:	 PC		1/21/2010	1.0 Created
   =============================================*/

CREATE procedure [dbo].[sp_itw_rpt_retention]

@HighLevelJobStep as char(3),
@from_date as datetime,
@to_date as datetime

as
begin

	set nocount on;

	select  p.personfullname, p.personnum, p.homelaborlevelnm1, laborlevelname3, laborlevelname1, paycodename, sum(timeinseconds/3600.000) as hours, homestreet + '  ' + ISNULL(homecity,'') + '  ' + ISNULL(homestate,'') + '  ' + ISNULL(homezip,'') as [Home Address]
	from dbo.vp_totals t inner join dbo.vp_personv42 p on t.personid = p.personid
	where  t.paycodetype <> 'G'
	and t.paycodeid in (1,2,4,5,15,16,18,1001,2103,2104,2105,2106,2108,2109,2110,2111,2113,2114,2115,2116,2118,2119,2120,2121)
	and t.employeeid in 
		(select distinct(employeeid) from wfctotal t1 inner join laboracct la on t1.laboracctid = la.laboracctid 
		    where left(la.LABORLEV1NM, 3) like @HighLevelJobStep and t1.applydtm between @from_date and @to_date)
	and t.applydate between @from_date and @to_date
	group by p.personfullname, p.personnum, p.homelaborlevelnm1, laborlevelname3, laborlevelname1, paycodename, homestreet + '  ' + ISNULL(homecity,'') + '  ' + ISNULL(homestate,'') + '  ' + ISNULL(homezip,'')
	order by p.personfullname

	set nocount off;

end;
GO


