USE [TKCSDB]
GO
/****** Object:  StoredProcedure [dbo].[stp_itw_rpt_daily_labour_wo]    Script Date: 02/17/2010 11:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE procedure [dbo].[stp_itw_rpt_daily_labour_wo]
/* =============================================
-- Author:		Betsy Kowan
-- Create date:	2/10/2010
-- Parameters:	@pResort_Code - the short resort code ex 'MC' 
--				@pDivision - either 0 for all divisions or a specific division code ex 4 (Food & Beverage)
				@pBU_Code - blank for all BU's or a comma separated list of BUs. ex 19010,19011,19012
				@pStart_Date - The beginning date used for data selection
				@pEnd_Date - The end date used for data selection
				@pOwner - either 1 for regular division or AB# for user-defined codes
				@pWage_Type - a comma separated list of Wage Types. ex 1,2,3
-- Description:	This version of the Daily Labour report allocates the cost of work done on a work order
				to the BU for which the WO is performed.
-- Example:		exec dbo.stp_itw_rpt_daily_labour_wo 'MC',0,'19010,19011,19012,19013,19014,19015','1/26/2010','1/26/2010','1','1,2'
-- Revisions:	BK	2/10/2010	1.0	Created from dbo.sp_itw_rpt_daily_labour_wo
					has been updated to be called from Reporting Services.
-- =============================================*/

@pResort_Code 	char(2),
@pDivision		int,
@pBU_Code 		varchar(1000), 
@pStart_Date	datetime,
@pEnd_Date	datetime,
@pOwner	varchar(15),
@pWage_Type	varchar(1000)

as
begin

set nocount on

declare @regular_hrs decimal(9,3), @overtime_hrs decimal(9,3);
declare	@adjust_hrs decimal(9,3), @nonpaid_hrs decimal(9,3);
declare	@bu_dollars decimal(9,3), @bu_wtd decimal(9,3);
declare @total_hrs  decimal(9,3), @statpay_hrs decimal(9,3);
declare @flat_amount decimal(9,3), @wtd_hrs decimal(9,3);
declare @ski_school_com decimal(9,3);

declare @empnumber varchar(15), @empname varchar(100);
declare @employeeid integer, @weekday varchar(20), @wtd_date datetime;
declare @bu_name varchar(50), @bu_descr varchar(250);
declare @wtd_temp datetime, @division int;
declare @wo_name varchar(25), @wo_description varchar(100), @wo_bu varchar(8);
declare @job varchar(50);

declare @job_step_sql varchar(500), @bu_sql varchar(8000), @pDivision_sql varchar(1000);

declare @Wage_Type_List varchar(1000), @Wage_Type_1 varchar(3), @Position int;
declare @BU_Code_List varchar(8000), @BU_Code_1 varchar(6);

create table #hold_report
(bu_name	varchar(50),
 bu_desc	varchar(250),
 emp_number 	varchar(15),
 emp_name	varchar(64),
 flat_amount	decimal(9,3),
 reg_hours	decimal(9,3),
 ot_hours	decimal(9,3),
 adjust_hours	decimal(9,3),
 nonpaid_hours	decimal(9,3),
 stat_hours	decimal(9,3),
 total_hours	decimal(9,3),
 wtd_hours	decimal(9,3),
 bu_amount	decimal(9,3),
 bu_wtd		decimal(9,3),
 division	int,
 ski_school_com decimal(9,3));

set @Wage_Type_List = ''
set @BU_Code_List = ''
--create an SQL expression to handle the job step filter
if (@pWage_Type is null or rtrim(@pWage_Type) = '')
begin
	select @job_step_sql = '';
end;
else
begin
	set @pWage_Type = ltrim(rtrim(@pWage_Type)) + ',';
	set @Position = CHARINDEX(',', @pWage_Type, 1);
	if replace(@pWage_Type, ',', '') <> ''
	begin
		while @Position > 0
		begin
			set @Wage_Type_1 = ltrim(rtrim(left(@pWage_Type, @Position -1)))
			if @Wage_Type_1 <> ''
			begin
				set @Wage_Type_List = @Wage_Type_List + '''' + @Wage_Type_1 + '''' + ',';
--				print @Wage_Type_List
			
			end;
			set @pWage_Type = right(@pWage_Type, len(@pWage_Type) - @Position);
			set @Position = charindex(',', @pWage_Type, 1);
			
		end;
	end;
	set @Wage_Type_List = left(@Wage_Type_List, len(@Wage_Type_List) - 1);
	select @job_step_sql = ' right(left(a.laborlevelname1, 3),1) in ( ' + @Wage_Type_List + ') and ';
--	print @job_step_sql
end;

--create an SQL expression to handle the bu filter
if (@pBU_Code is null or rtrim(@pBU_Code) = '') 
begin
	select @bu_sql = '';
	
	--create an SQL expression to handle the division filter
	if (@pDivision = 0) 
	begin
		select @pDivision_sql = '';
	end;
	else
	begin
		select @pDivision_sql = ' ((dbr.divisionid = ' + cast(@pDivision as varchar(10)) + ' and a.laborlevelname4 = ''0'') or 
			(a.laborlevelname4 <> ''0'' and 
			(select dbr2.divisionid 
				from dbo.itw_bu_hierarchy dbr2 inner join
				     dbo.laborlevelentry lle on dbr2.laborlevelentryid = lle.laborlevelentryid
				where
				a.laborlevelname4 <> ''-'' and 
				lle.name = left(a.laborleveldsc4, charindex(''-'', a.laborleveldsc4) - 2) and
			dbr2.personnum = ''' + @pOwner + ''') = ' + cast(@pDivision as varchar(10)) + ')) and ';
	end;
end;
else
begin
	/*If one or more BUs are selected, there is no division filter, but 
	since the BUs of interest have been named, we have to include them and
	labour done on WOs for those BUs.  We do this by finding records with a
	WO of 0 (no WO) for the correct BU OR records with the BU number in the
	WO description.*/
	set @pBU_Code = ltrim(rtrim(@pBU_Code)) + ',';
	set @Position = CHARINDEX(',', @pBU_Code, 1);
	if replace(@pBU_Code, ',', '') <> ''
	begin
		while @Position > 0
		begin
			set @BU_Code_1 = ltrim(rtrim(left(@pBU_Code, @Position -1)))
			if @BU_Code_1 <> ''
			begin
				set @BU_Code_List = @BU_Code_List + '''' + @BU_Code_1 + '''' + ',';
			--	print @BU_Code_List
			
			end;
			set @pBU_Code = right(@pBU_Code, len(@pBU_Code) - @Position);
			set @Position = charindex(',', @pBU_Code, 1);
			
		end;
	end;
	set @BU_Code_List = left(@BU_Code_List, len(@BU_Code_List) - 1);
	select @bu_sql = ' ((a.laborlevelname4 = ''0'' and a.laborlevelname2 IN 
			(' + @BU_Code_List + ') )
		or (a.laborlevelname4 <> ''-'' and left(a.laborleveldsc4, replace(charindex(''-'', a.laborleveldsc4),0,3) - 2) IN
			(' + @BU_Code_List + ') ))
		and ';
--print @bu_sql

	select @pDivision_sql = '';
end;


--datepart returns a "1" for Sunday
SELECT @weekday = rtrim(datepart(weekday, @pStart_Date));

--Different resorts have different start dates to their week.
if @pResort_Code in ('SD', 'ST')

begin

	--Sandestin's week starts on Saturday
	SELECT @wtd_date = CASE @weekday 
				WHEN '1' THEN dateadd(Day, -1, @pStart_Date)			
				WHEN '2' THEN dateadd(Day, -2, @pStart_Date)
				WHEN '3' THEN dateadd(Day, -3, @pStart_Date)
				WHEN '4' THEN dateadd(Day, -4, @pStart_Date)
				WHEN '5' THEN dateadd(Day, -5, @pStart_Date)
				WHEN '6' THEN dateadd(Day, -6, @pStart_Date)
				WHEN '7' THEN @pStart_Date
			   END;
end;

else
begin
	if @pResort_Code = 'TR'
	begin

		--Tremblant's week starts on Sunday
		SELECT @wtd_date = CASE @weekday 
					WHEN '1' THEN @pStart_Date
					WHEN '2' THEN dateadd(Day, -1, @pStart_Date)			
					WHEN '3' THEN dateadd(Day, -2, @pStart_Date)
					WHEN '4' THEN dateadd(Day, -3, @pStart_Date)
					WHEN '5' THEN dateadd(Day, -4, @pStart_Date)
					WHEN '6' THEN dateadd(Day, -5, @pStart_Date)
					WHEN '7' THEN dateadd(Day, -6, @pStart_Date)
				   END;

	end;
	
	else
	begin
		--Everyone else starts on Monday
		SELECT @wtd_date = CASE @weekday 
					WHEN '1' THEN dateadd(Day, -6, @pStart_Date)
					WHEN '2' THEN @pStart_Date 	
					WHEN '3' THEN dateadd(Day, -1, @pStart_Date)			
					WHEN '4' THEN dateadd(Day, -2, @pStart_Date)
					WHEN '5' THEN dateadd(Day, -3, @pStart_Date)
					WHEN '6' THEN dateadd(Day, -4, @pStart_Date)
					WHEN '7' THEN dateadd(Day, -5, @pStart_Date)
				   END;
	end;
end;

select @regular_hrs = 0.00, @overtime_hrs = 0.00, @adjust_hrs = 0.00;
select @nonpaid_hrs = 0.00, @total_hrs = 0.00, @flat_amount = 0.00;
select @statpay_hrs = 0.00, @ski_school_com = 0.00;

/* PRINT 'DECLARE employee_cursor CURSOR FOR 
	SELECT DISTINCT
		e.personnum, e.personFULLNAME, e.EMPLOYEEID, 
		a.laborlevelname2, isnull(dbr.bu_desc, ''N/A''),
		dv.division_id, a.laborlevelname4, a.laborleveldsc4, a.laborlevelname3

	FROM 	
		V_itw_TOTALSV43 a, V_itw_EMPLOYEEV43 e, itw_paycode_grouping d, itw_bu_hierarchy dbr,
		itw_division dv, vp_laboraccount la
	WHERE 	a.employeeid = e.employeeid and                  
		a.paycodeid = d.paycodeid and '
		+ @job_step_sql +
		@bu_sql +
		' a.laboracctid = la.laboracctid and 
		la.laborlev2id = dbr.LABORLEVELENTRYID and 
		dbr.divisionid = dv.division_id and
		(a.timeinseconds <> 0 or a.moneyamount <> 0) and
		left(a.laborlevelname1, 2) = ''' + @pResort_Code + ''' and
		d.resort = ''' + @pResort_Code + ''' and
		a.notpaidsw = 0 and
		a.laborlevelname2 <> ''0'' and '
		+ @pDivision_sql + 
		' dbr.personnum = ''' + @pOwner + ''' and
		dv.personnum = ''' + @pOwner + ''' and
		a.applydate between ''' + cast(@wtd_date as varchar(20))+ ''' and ''' + cast(@pEnd_Date as varchar(20)) + ''';';
*/


	exec('DECLARE employee_cursor CURSOR FOR 
	SELECT DISTINCT
		e.personnum, e.personFULLNAME, e.EMPLOYEEID, 
		a.laborlevelname2, a.laborleveldsc2, 
		dv.division_id, a.laborlevelname4, a.laborleveldsc4, a.laborlevelname3
	FROM 	
		dbo.V_itw_TOTALSV43 a inner join
		dbo.V_itw_EMPLOYEEV43 e on a.employeeid = e.employeeid inner join
		dbo.itw_paycode_grouping d on a.paycodeid = d.paycodeid inner join
		dbo.vp_laboraccount la on a.laboracctid = la.laboracctid inner join
		dbo.itw_bu_hierarchy dbr on la.laborlev2id = dbr.LABORLEVELENTRYID inner join
		dbo.itw_division dv on dbr.divisionid = dv.division_id
		
	WHERE '
		+ @job_step_sql +
		@bu_sql +
		' (a.timeinseconds <> 0 or a.moneyamount <> 0) and
		left(a.laborlevelname1, 2) = ''' + @pResort_Code + ''' and
		d.resort = ''' + @pResort_Code + ''' and
		a.notpaidsw = 0 and
		a.laborlevelname2 <> ''0'' and '
		+ @pDivision_sql + 
		' dbr.personnum = ''' + @pOwner + ''' and
		dv.personnum = ''' + @pOwner + ''' and
		a.applydate between ''' + @wtd_date + ''' and ''' + @pEnd_Date + ''';');
  

open employee_cursor;

fetch next from employee_cursor into @empnumber, @empname, @employeeid, 
@bu_name, @bu_descr, @division, @wo_name, @wo_description, @job;

while @@fetch_status = 0
begin

	select @regular_hrs = 0.00, @overtime_hrs = 0.00, @adjust_hrs = 0.00;
	select @nonpaid_hrs = 0.00, @total_hrs = 0.00, @flat_amount = 0.00;
	select @statpay_hrs = 0.00, @ski_school_com = 0.00;
	
	--Exclude employees who worked on WOs for their own BU or they will come across twice
	if (@wo_name = '0')
	begin

		SELECT 	@regular_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
		FROM 	dbo.wfctotal a inner join
				dbo.itw_paycode_grouping d on a.paycodeid = d.paycodeid inner join
				dbo.laboracct l1 on a.laboracctid = l1.laboracctid
		WHERE l1.laborlev2nm = @bu_name and
			l1.laborlev3nm = @job and
			l1.laborlev4nm = @wo_name and
			a.employeeid = @employeeid and
			d.pay_type = 'R' and
			d.resort = @pResort_Code and
			a.notpaidsw = 0 and
			a.applydtm between @pStart_Date and @pEnd_Date;

		SELECT 	@overtime_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
		FROM 	dbo.wfctotal a inner join
				dbo.itw_paycode_grouping d on a.paycodeid = d.paycodeid inner join
				dbo.laboracct l1 on a.laboracctid = l1.laboracctid
		WHERE l1.laborlev2nm = @bu_name and
			l1.laborlev2nm = @bu_name and
			l1.laborlev3nm = @job and
			l1.laborlev4nm = @wo_name and
			a.employeeid = @employeeid and
			d.pay_type = 'O' and
			d.resort = @pResort_Code and
			a.notpaidsw = 0 and
			a.applydtm between @pStart_Date and @pEnd_Date;

		SELECT 	@adjust_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
		FROM 	dbo.wfctotal a inner join
				dbo.itw_paycode_grouping d on a.paycodeid = d.paycodeid inner join
				dbo.laboracct l1 on a.laboracctid = l1.laboracctid
		WHERE l1.laborlev2nm = @bu_name and
			l1.laborlev2nm = @bu_name and
			l1.laborlev3nm = @job and
			l1.laborlev4nm = @wo_name and
			a.employeeid = @employeeid and
			d.pay_type = 'A' and
			d.resort = @pResort_Code and
			a.notpaidsw = 0 and
			a.applydtm between @pStart_Date and @pEnd_Date;

		SELECT 	@nonpaid_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
		FROM 	dbo.wfctotal a inner join
				dbo.itw_paycode_grouping d on a.paycodeid = d.paycodeid inner join
				dbo.laboracct l1 on a.laboracctid = l1.laboracctid
		WHERE l1.laborlev2nm = @bu_name and
			l1.laborlev2nm = @bu_name and
			l1.laborlev3nm = @job and
			l1.laborlev4nm = @wo_name and
			a.employeeid = @employeeid and
			d.pay_type = 'N' and
			d.resort = @pResort_Code and
			a.notpaidsw = 0 and
			a.applydtm between @pStart_Date and @pEnd_Date;

		SELECT 	@statpay_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
		FROM 	dbo.wfctotal a inner join
				dbo.itw_paycode_grouping d on a.paycodeid = d.paycodeid inner join
				dbo.laboracct l1 on a.laboracctid = l1.laboracctid
		WHERE l1.laborlev2nm = @bu_name and
			l1.laborlev2nm = @bu_name and
			l1.laborlev3nm = @job and
			l1.laborlev4nm = @wo_name and
			a.employeeid = @employeeid and
			d.pay_type = 'S' and
			d.resort = @pResort_Code and
			a.notpaidsw = 0 and
			a.applydtm between @pStart_Date and @pEnd_Date;


		SELECT 	@total_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
		FROM 	dbo.wfctotal a inner join
				dbo.itw_paycode_grouping d on a.paycodeid = d.paycodeid inner join
				dbo.laboracct l1 on a.laboracctid = l1.laboracctid
		WHERE l1.laborlev2nm = @bu_name and
			l1.laborlev2nm = @bu_name and
			l1.laborlev3nm = @job and
			l1.laborlev4nm = @wo_name and
			a.employeeid = @employeeid and
			d.pay_type <> 'N' and
			d.pay_type <> 'FC' and
			d.resort = @pResort_Code and
			a.notpaidsw = 0 and
			a.applydtm between @pStart_Date and @pEnd_Date;

		SELECT 	@wtd_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
		FROM 	dbo.wfctotal a inner join
				dbo.itw_paycode_grouping d on a.paycodeid = d.paycodeid inner join
				dbo.laboracct l1 on a.laboracctid = l1.laboracctid
		WHERE l1.laborlev2nm = @bu_name and
			l1.laborlev2nm = @bu_name and
			l1.laborlev3nm = @job and
			l1.laborlev4nm = @wo_name and
			a.employeeid = @employeeid and
			d.pay_type <> 'N' and
			d.pay_type <> 'FC' and
			d.resort = @pResort_Code and
			a.notpaidsw = 0 and
			a.applydtm between @wtd_date and @pEnd_Date;

		SELECT 	@flat_amount = isnull(sum(a.moneyamt), 0)
		FROM 	dbo.wfctotal a inner join
				dbo.itw_paycode_grouping d on a.paycodeid = d.paycodeid inner join
				dbo.laboracct l1 on a.laboracctid = l1.laboracctid
		WHERE l1.laborlev2nm = @bu_name and
			l1.laborlev2nm = @bu_name and
			l1.laborlev3nm = @job and
			l1.laborlev4nm = @wo_name and
			a.employeeid = @employeeid and
			d.pay_type = 'F' and
			d.resort = @pResort_Code and
			a.notpaidsw = 0 and
			a.applydtm between @pStart_Date and @pEnd_Date;

		--Ski School Commissions
		SELECT 	@ski_school_com = isnull(sum(a.durationsecsqty/3600.000*(cast(l1.laborlev6nm as decimal(9,3))/100)), 0)
		FROM 	dbo.wfctotal a inner join
				dbo.itw_paycode_grouping d on a.paycodeid = d.paycodeid inner join
				dbo.laboracct l1 on a.laboracctid = l1.laboracctid
		WHERE l1.laborlev2nm = @bu_name and
			l1.laborlev2nm = @bu_name and
			l1.laborlev3nm = @job and
			l1.laborlev4nm = @wo_name and
			a.employeeid = @employeeid and
			d.pay_type = 'FC' and
			a.notpaidsw = 0 and
			d.resort = @pResort_Code and
			a.applydtm between @pStart_Date and @pEnd_Date;

		if @pResort_Code = 'WP' and (@job = 'FBBART' or @job = 'FBWAIT')
		begin
			if @job = 'FBBART'
			begin
				--Total Dollars
				SELECT 	@bu_dollars = isnull(sum((a.durationsecsqty/3600.000) * 6.50), 0) + isnull(sum(a.moneyamt), 0)
				FROM 	dbo.wfctotal a inner join
						dbo.itw_paycode_grouping d on a.paycodeid = d.paycodeid inner join
						dbo.laboracct l1 on a.laboracctid = l1.laboracctid
				WHERE l1.laborlev2nm = @bu_name and
					l1.laborlev2nm = @bu_name and
					l1.laborlev3nm = @job and
					l1.laborlev4nm = @wo_name and
					a.employeeid = @employeeid and
					d.resort = @pResort_Code and
					a.notpaidsw = 0 and
					d.pay_type <> 'N' and
					d.pay_type <> 'FC' and
					a.applydtm between @pStart_Date and @pEnd_Date;


				--Total WTD Dollars
				SELECT 	@bu_wtd = isnull(sum((a.durationsecsqty/3600.000) * 6.50), 0) + isnull(sum(a.moneyamt), 0)
				FROM 	dbo.wfctotal a inner join
						dbo.itw_paycode_grouping d on a.paycodeid = d.paycodeid inner join
						dbo.laboracct l1 on a.laboracctid = l1.laboracctid
				WHERE l1.laborlev2nm = @bu_name and
					l1.laborlev2nm = @bu_name and
					l1.laborlev3nm = @job and
					l1.laborlev4nm = @wo_name and
					a.employeeid = @employeeid and
					d.resort = @pResort_Code and
					a.notpaidsw = 0 and
					d.pay_type <> 'N' and
					d.pay_type <> 'FC' and
					a.applydtm between @wtd_date and @pEnd_Date;
			end;
			else  --Job is FBWAIT
			begin
				--Total Dollars
				SELECT 	@bu_dollars = isnull(sum((a.durationsecsqty/3600.000) * 2.75), 0) + isnull(sum(a.moneyamt), 0)
				FROM 	dbo.wfctotal a inner join
						dbo.itw_paycode_grouping d on a.paycodeid = d.paycodeid inner join
						dbo.laboracct l1 on a.laboracctid = l1.laboracctid
				WHERE l1.laborlev2nm = @bu_name and
					l1.laborlev2nm = @bu_name and
					l1.laborlev3nm = @job and
					l1.laborlev4nm = @wo_name and
					a.employeeid = @employeeid and
					d.resort = @pResort_Code and
					a.notpaidsw = 0 and
					d.pay_type <> 'N' and
					d.pay_type <> 'FC' and
					a.applydtm between @pStart_Date and @pEnd_Date;


				--Total WTD Dollars
				SELECT 	@bu_wtd = isnull(sum((a.durationsecsqty/3600.000) * 2.75), 0) + isnull(sum(a.moneyamt), 0)
				FROM 	dbo.wfctotal a inner join
						dbo.itw_paycode_grouping d on a.paycodeid = d.paycodeid inner join
						dbo.laboracct l1 on a.laboracctid = l1.laboracctid
				WHERE l1.laborlev2nm = @bu_name and
					l1.laborlev2nm = @bu_name and
					l1.laborlev3nm = @job and
					l1.laborlev4nm = @wo_name and
					a.employeeid = @employeeid and
					d.resort = @pResort_Code and
					a.notpaidsw = 0 and
					d.pay_type <> 'N' and
					d.pay_type <> 'FC' and
					a.applydtm between @wtd_date and @pEnd_Date;
			
			end;
		end;
		else --Regular calculation
		begin
			SELECT 	@bu_dollars = isnull(sum(a.wageamt), 0) + isnull(sum(a.moneyamt), 0)
			FROM 	dbo.wfctotal a inner join
					dbo.itw_paycode_grouping d on a.paycodeid = d.paycodeid inner join
					dbo.laboracct l1 on a.laboracctid = l1.laboracctid
			WHERE l1.laborlev2nm = @bu_name and
				l1.laborlev2nm = @bu_name and
				l1.laborlev3nm = @job and
				l1.laborlev4nm = @wo_name and
				a.employeeid = @employeeid and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				d.pay_type <> 'N' and
				d.pay_type <> 'FC' and
				a.applydtm between @pStart_Date and @pEnd_Date;


			--Total WTD Dollars
			SELECT 	@bu_wtd = isnull(sum(a.wageamt), 0) + isnull(sum(a.moneyamt), 0)
			FROM 	dbo.wfctotal a inner join
					dbo.itw_paycode_grouping d on a.paycodeid = d.paycodeid inner join
					dbo.laboracct l1 on a.laboracctid = l1.laboracctid
			WHERE l1.laborlev2nm = @bu_name and
				l1.laborlev2nm = @bu_name and
				l1.laborlev3nm = @job and
				l1.laborlev4nm = @wo_name and
				a.employeeid = @employeeid and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				d.pay_type <> 'N' and
				d.pay_type <> 'FC' and
				a.applydtm between @wtd_date and @pEnd_Date;
		end;

	end;
	else
	--there is a WO.  Repeat, but select based on the WO description as well
	begin
		
		SELECT 	@regular_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
		FROM 	dbo.wfctotal a inner join
				dbo.itw_paycode_grouping d on a.paycodeid = d.paycodeid inner join
				dbo.laboracct l1 on a.laboracctid = l1.laboracctid
		WHERE l1.laborlev2nm = @bu_name and
			l1.laborlev2nm = @bu_name and
			l1.laborlev3nm = @job and
			l1.laborlev4nm = @wo_name and
			l1.laborlev4dsc = @wo_description and
			a.employeeid = @employeeid and
			d.pay_type = 'R' and
			d.resort = @pResort_Code and
			a.notpaidsw = 0 and
			a.applydtm between @pStart_Date and @pEnd_Date;

		SELECT 	@overtime_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
		FROM 	dbo.wfctotal a inner join
				dbo.itw_paycode_grouping d on a.paycodeid = d.paycodeid inner join
				dbo.laboracct l1 on a.laboracctid = l1.laboracctid
		WHERE l1.laborlev2nm = @bu_name and
			l1.laborlev2nm = @bu_name and
			l1.laborlev3nm = @job and
			l1.laborlev4nm = @wo_name and
			l1.laborlev4dsc = @wo_description and
			a.employeeid = @employeeid and
			d.pay_type = 'O' and
			d.resort = @pResort_Code and
			a.notpaidsw = 0 and
			a.applydtm between @pStart_Date and @pEnd_Date;

		SELECT 	@adjust_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
		FROM 	dbo.wfctotal a inner join
				dbo.itw_paycode_grouping d on a.paycodeid = d.paycodeid inner join
				dbo.laboracct l1 on a.laboracctid = l1.laboracctid
		WHERE l1.laborlev2nm = @bu_name and
			l1.laborlev2nm = @bu_name and
			l1.laborlev3nm = @job and
			l1.laborlev4nm = @wo_name and
			l1.laborlev4dsc = @wo_description and
			a.employeeid = @employeeid and
			d.pay_type = 'A' and
			d.resort = @pResort_Code and
			a.notpaidsw = 0 and
			a.applydtm between @pStart_Date and @pEnd_Date;

		SELECT 	@nonpaid_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
		FROM 	dbo.wfctotal a inner join
				dbo.itw_paycode_grouping d on a.paycodeid = d.paycodeid inner join
				dbo.laboracct l1 on a.laboracctid = l1.laboracctid
		WHERE l1.laborlev2nm = @bu_name and
			l1.laborlev2nm = @bu_name and
			l1.laborlev3nm = @job and
			l1.laborlev4nm = @wo_name and
			l1.laborlev4dsc = @wo_description and
			a.employeeid = @employeeid and
			d.pay_type = 'N' and
			d.resort = @pResort_Code and
			a.notpaidsw = 0 and
			a.applydtm between @pStart_Date and @pEnd_Date;

		SELECT 	@statpay_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
		FROM 	dbo.wfctotal a inner join
				dbo.itw_paycode_grouping d on a.paycodeid = d.paycodeid inner join
				dbo.laboracct l1 on a.laboracctid = l1.laboracctid
		WHERE l1.laborlev2nm = @bu_name and
			l1.laborlev2nm = @bu_name and
			l1.laborlev3nm = @job and
			l1.laborlev4nm = @wo_name and
			l1.laborlev4dsc = @wo_description and
			a.employeeid = @employeeid and
			d.pay_type = 'S' and
			d.resort = @pResort_Code and
			a.notpaidsw = 0 and
			a.applydtm between @pStart_Date and @pEnd_Date;

		SELECT 	@total_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
		FROM 	dbo.wfctotal a inner join
				dbo.itw_paycode_grouping d on a.paycodeid = d.paycodeid inner join
				dbo.laboracct l1 on a.laboracctid = l1.laboracctid
		WHERE l1.laborlev2nm = @bu_name and
			l1.laborlev2nm = @bu_name and
			l1.laborlev3nm = @job and
			l1.laborlev4nm = @wo_name and
			l1.laborlev4dsc = @wo_description and
			a.employeeid = @employeeid and
			d.pay_type <> 'N' and
			d.pay_type <> 'FC' and
			d.resort = @pResort_Code and
			a.notpaidsw = 0 and
			a.applydtm between @pStart_Date and @pEnd_Date;

		SELECT 	@wtd_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
		FROM 	dbo.wfctotal a inner join
				dbo.itw_paycode_grouping d on a.paycodeid = d.paycodeid inner join
				dbo.laboracct l1 on a.laboracctid = l1.laboracctid
		WHERE l1.laborlev2nm = @bu_name and
			l1.laborlev2nm = @bu_name and
			l1.laborlev3nm = @job and
			l1.laborlev4nm = @wo_name and
			l1.laborlev4dsc = @wo_description and
			a.employeeid = @employeeid and
			d.pay_type <> 'N' and
			d.pay_type <> 'FC' and
			d.resort = @pResort_Code and
			a.notpaidsw = 0 and
			a.applydtm between @wtd_date and @pEnd_Date;

		SELECT 	@flat_amount = isnull(sum(a.moneyamt), 0)
		FROM 	dbo.wfctotal a inner join
				dbo.itw_paycode_grouping d on a.paycodeid = d.paycodeid inner join
				dbo.laboracct l1 on a.laboracctid = l1.laboracctid
		WHERE l1.laborlev2nm = @bu_name and
			l1.laborlev2nm = @bu_name and
			l1.laborlev3nm = @job and
			l1.laborlev4nm = @wo_name and
			l1.laborlev4dsc = @wo_description and
			a.employeeid = @employeeid and
			d.pay_type = 'F' and
			d.resort = @pResort_Code and
			a.notpaidsw = 0 and
			a.applydtm between @pStart_Date and @pEnd_Date;
			
		SELECT 	@ski_school_com = isnull(sum(a.durationsecsqty/3600.000*(cast(l1.laborlev6nm as decimal(9,3))/100)), 0)
		FROM 	dbo.wfctotal a inner join
				dbo.itw_paycode_grouping d on a.paycodeid = d.paycodeid inner join
				dbo.laboracct l1 on a.laboracctid = l1.laboracctid
		WHERE l1.laborlev2nm = @bu_name and
			l1.laborlev2nm = @bu_name and
			l1.laborlev3nm = @job and
			l1.laborlev4nm = @wo_name and
			l1.laborlev4dsc = @wo_description and
			a.employeeid = @employeeid and
			d.pay_type = 'FC' and
			a.notpaidsw = 0 and
			d.resort = @pResort_Code and
			a.applydtm between @pStart_Date and @pEnd_Date;
			
			
		if @pResort_Code = 'WP' and (@job = 'FBBART' or @job = 'FBWAIT')
		begin
			if @job = 'FBBART'
			begin
				--Total Dollars
				SELECT 	@bu_dollars = isnull(sum((a.durationsecsqty/3600.000) * 6.50), 0) + isnull(sum(a.moneyamt), 0)
		FROM 	dbo.wfctotal a inner join
				dbo.itw_paycode_grouping d on a.paycodeid = d.paycodeid inner join
				dbo.laboracct l1 on a.laboracctid = l1.laboracctid
		WHERE l1.laborlev2nm = @bu_name and
					l1.laborlev2nm = @bu_name and
					l1.laborlev3nm = @job and
					l1.laborlev4nm = @wo_name and
					l1.laborlev4dsc = @wo_description and
					a.employeeid = @employeeid and
					d.resort = @pResort_Code and
					a.notpaidsw = 0 and
					d.pay_type <> 'N' and
					d.pay_type <> 'FC' and
					a.applydtm between @pStart_Date and @pEnd_Date;


				--Total WTD Dollars
				SELECT 	@bu_wtd = isnull(sum((a.durationsecsqty/3600.000) * 6.50), 0) + isnull(sum(a.moneyamt), 0)
				FROM 	dbo.wfctotal a inner join
						dbo.itw_paycode_grouping d on a.paycodeid = d.paycodeid inner join
						dbo.laboracct l1 on a.laboracctid = l1.laboracctid
				WHERE l1.laborlev2nm = @bu_name and
					l1.laborlev2nm = @bu_name and
					l1.laborlev3nm = @job and
					l1.laborlev4nm = @wo_name and
					l1.laborlev4dsc = @wo_description and
					a.employeeid = @employeeid and
					d.resort = @pResort_Code and
					a.notpaidsw = 0 and
					d.pay_type <> 'N' and
					d.pay_type <> 'FC' and
					a.applydtm between @wtd_date and @pEnd_Date;
			end;
			else  --Job is FBWAIT
			begin
				--Total Dollars
				SELECT 	@bu_dollars = isnull(sum((a.durationsecsqty/3600.000) * 2.75), 0) + isnull(sum(a.moneyamt), 0)
				FROM 	dbo.wfctotal a inner join
						dbo.itw_paycode_grouping d on a.paycodeid = d.paycodeid inner join
						dbo.laboracct l1 on a.laboracctid = l1.laboracctid
				WHERE l1.laborlev2nm = @bu_name and
					l1.laborlev2nm = @bu_name and
					l1.laborlev3nm = @job and
					l1.laborlev4nm = @wo_name and
					l1.laborlev4dsc = @wo_description and
					a.employeeid = @employeeid and
					d.resort = @pResort_Code and
					a.notpaidsw = 0 and
					d.pay_type <> 'N' and
					d.pay_type <> 'FC' and
					a.applydtm between @pStart_Date and @pEnd_Date;


				--Total WTD Dollars
				SELECT 	@bu_wtd = isnull(sum((a.durationsecsqty/3600.000) * 2.75), 0) + isnull(sum(a.moneyamt), 0)
				FROM 	dbo.wfctotal a inner join
						dbo.itw_paycode_grouping d on a.paycodeid = d.paycodeid inner join
						dbo.laboracct l1 on a.laboracctid = l1.laboracctid
				WHERE l1.laborlev2nm = @bu_name and
					l1.laborlev2nm = @bu_name and
					l1.laborlev3nm = @job and
					l1.laborlev4nm = @wo_name and
					l1.laborlev4dsc = @wo_description and
					a.employeeid = @employeeid and
					d.resort = @pResort_Code and
					a.notpaidsw = 0 and
					d.pay_type <> 'N' and
					d.pay_type <> 'FC' and
					a.applydtm between @wtd_date and @pEnd_Date;
			
			end;
		end;
		else --Regular calculation
		begin
			SELECT 	@bu_dollars = isnull(sum(a.wageamt), 0) + isnull(sum(a.moneyamt), 0)
			FROM 	dbo.wfctotal a inner join
					dbo.itw_paycode_grouping d on a.paycodeid = d.paycodeid inner join
					dbo.laboracct l1 on a.laboracctid = l1.laboracctid
			WHERE l1.laborlev2nm = @bu_name and
				l1.laborlev2nm = @bu_name and
				l1.laborlev3nm = @job and
				l1.laborlev4nm = @wo_name and
				l1.laborlev4dsc = @wo_description and
				a.employeeid = @employeeid and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				d.pay_type <> 'N' and
				d.pay_type <> 'FC' and
				a.applydtm between @pStart_Date and @pEnd_Date;


			--Total WTD Dollars
			SELECT 	@bu_wtd = isnull(sum(a.wageamt), 0) + isnull(sum(a.moneyamt), 0)
			FROM 	dbo.wfctotal a inner join
					dbo.itw_paycode_grouping d on a.paycodeid = d.paycodeid inner join
					dbo.laboracct l1 on a.laboracctid = l1.laboracctid
			WHERE l1.laborlev2nm = @bu_name and
				l1.laborlev2nm = @bu_name and
				l1.laborlev3nm = @job and
				l1.laborlev4nm = @wo_name and
				a.employeeid = @employeeid and
				l1.laborlev4dsc = @wo_description and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				d.pay_type <> 'N' and
				d.pay_type <> 'FC' and
				a.applydtm between @wtd_date and @pEnd_Date;
		end;

		/* The division not be the same as the employee's
		"home" division.  We must do a lookup to find the proper
		division for the WO so that hours are allocated properly. */
		SELECT	@division = dbr.divisionid 
		FROM	dbo.itw_bu_hierarchy dbr inner join
				dbo.laborlevelentry lle on dbr.laborlevelentryid = lle.laborlevelentryid
		WHERE	lle.name = left(@wo_description, charindex('-', @wo_description) - 2) and
			dbr.personnum = @pOwner;

	end;
	

	if (UPPER(@wo_description) = 'DEFAULT - NO WORKORDER')
	begin

		insert into #hold_report
		(bu_name, emp_number, emp_name, flat_amount, reg_hours, ot_hours, 
		adjust_hours, nonpaid_hours, stat_hours, total_hours, wtd_hours, bu_amount, 
		bu_wtd, division, ski_school_com)
		values
		(@bu_name, @empnumber, @empname, @flat_amount, 
		@regular_hrs, @overtime_hrs, @adjust_hrs, @nonpaid_hrs, @statpay_hrs,
		@total_hrs, @wtd_hrs, @bu_dollars, @bu_wtd, @division, @ski_school_com);

	end;
	else
	begin
		
		insert into #hold_report
		(bu_name, emp_number, emp_name, flat_amount, reg_hours, ot_hours, 
		adjust_hours, nonpaid_hours, stat_hours, total_hours, wtd_hours, bu_amount, 
		bu_wtd, division, ski_school_com)
		values
		(left(@wo_description, charindex('-', @wo_description) - 2),
		@empnumber, @empname, @flat_amount, @regular_hrs, 
		@overtime_hrs, @adjust_hrs, @nonpaid_hrs, @statpay_hrs, @total_hrs, 
		@wtd_hrs, @bu_dollars, @bu_wtd, @division, @ski_school_com);

	end;
		


	fetch next from employee_cursor into @empnumber, @empname, @employeeid, 
	@bu_name, @bu_descr, @division, @wo_name, @wo_description, @job;
end;

close employee_cursor;
deallocate employee_cursor;


select 	
	cast(bu_name as int) as 'bu_name', isNull((SELECT cast(description as varchar(100))
		from dbo.laborlevelentry 
		where laborleveldefid = 2 and name = bu_name), 'N/A') as 'bu_desc',
	emp_number, emp_name, sum(flat_amount) as 'flat_amount',
	sum(reg_hours) as 'reg_hours', sum(ot_hours) as 'ot_hours',
	sum(adjust_hours) as 'adjust_hours', sum(nonpaid_hours) as 'nonpaid_hours',
	sum(stat_hours) as 'stat_hours',
	sum(total_hours) as 'total_hours', sum(wtd_hours) as 'wtd_hours',
	sum(bu_amount) as 'bu_amount', sum(bu_wtd) as 'bu_wtd',
	IsNull((SELECT div.description
	FROM dbo.itw_division div
	WHERE div.division_id = division), 'Unknown') as 'division',
	sum(ski_school_com) as 'ski_school_com'
from 	
	#hold_report
group by
	division, bu_name, emp_number, emp_name
order by 
	division, cast(bu_name as int), emp_name;

end;


GRANT  EXECUTE  ON [dbo].[stp_itw_rpt_daily_labour_wo]  TO [DBA_KronosSupport]
GO