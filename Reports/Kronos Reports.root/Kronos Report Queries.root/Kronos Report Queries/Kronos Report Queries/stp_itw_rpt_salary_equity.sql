USE [TKCSDB]
GO
/****** Object:  StoredProcedure [dbo].[stp_itw_rpt_salary_equity]    Script Date: 03/16/2010 09:01:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[stp_itw_rpt_salary_equity]

@pStart_Date datetime,
@pEnd_Date datetime,
@pResort_Code char(2),
@pJob varchar(50)

as
begin

set nocount on

SELECT 
	pl.fiscal_year, 
	pl.pay_period, 
	pp.start_date, 
	pp.end_date, 
	law.laborlev3nm as 'worked job', 
	lah.laborlev3nm as 'home job', 
	p.fullnm as personfullname, 
	pl.personnum,
	es.shortnm as 'employmentstatus', 
	isnull(coalesce(pl.reg_hours, pl.ot_hours, pl.hours3_amount, pl.hours4_amount), 0.0) as hours, 
	isnull(coalesce(pl.reg_hours, pl.ot_hours, pl.hours3_amount, pl.hours4_amount), 0.0) * coalesce(pl.temp_rate, pl.basewagehourlyamt)  + (isnull(pl.earnings3_amount, 0.000) + isnull(pl.earnings4_amount, 0.000)) as Wage,
	pc.name as paycodename, 
	c.customdata as 'pay grade step',
	coalesce(pl.temp_rate, pl.basewagehourlyamt) as basewagehourlyamt,
	pa2.streetaddresstxt as 'homestreet', 
	pa2.citynm as 'homecity', 
	pa2.statenm as 'homestate', 
	pa2.postalcd as 'homezip', 
	pa2.countrynm as 'homecountry', 
	pn1.phonenum as 'phonenum1'

FROM 
	itw_payroll_log_adp pl, 
	itw_pay_period pp, 
	laboracct law,
	laboracct lah,
	person p,
	paycode pc,
	employmentstat es,
	personstatusmm pg,
	vp_personcustdata c,
	phonenumber pn1, 
	postaladdress pa2

WHERE 
	pl.fiscal_year = pp.fiscal_year
	and pl.pay_period = pp.pay_period
	and pl.resort = pp.resort
	and pl.worked_laboracctid = law.laboracctid
	and pl.home_laboracctid = lah.laboracctid
	and pl.paycodeid = pc.paycodeid
	and pl.personnum = p.personnum
	and p.personid = pg.personid
	and getdate() between pg.effectivedtm and pg.expirationdtm
	and pg.employmentstatid = es.employmentstatid
	and p.personid *= c.personid
	and c.customdatadefid = 3
	and p.personid *= pn1.personid
	and pn1.contacttypeid = 1
	and p.personid *= pa2.personid 
	and pa2.contacttypeid = 5
	and pp.resort = @pResort_Code
	and left(lah.laborlev1nm, 2) = @pResort_Code
	and pc.type <> 'G'
	and pp.start_date >= @pStart_Date 
	and pp.end_date <= @pEnd_Date
	and (law.laborlev3nm = @pJob
	or lah.laborlev3nm = @pJob)
	
ORDER BY 
	pp.start_date;
	
end;