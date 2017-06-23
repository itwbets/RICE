USE [TKCSDB]
GO
/****** Object:  StoredProcedure [dbo].[stp_itw_rpt_daily_labour_enhanced]    Script Date: 02/10/2010 13:47:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


Create procedure [dbo].[stp_itw_rpt_daily_labour_enhanced]
@pResort_Code 	char(2),
@pDivision		int,
@pBU_Code 		varchar(4000), 
@pStart_Date	datetime,
@pEnd_Date	datetime,
@owner		varchar(15),
@pWage_Type	varchar(1000)

as
begin

/* =============================================
-- Author:		Betsy Kowan
-- Create date:	2/10/2010
-- Parameters:	@pResort_Code - the short resort code ex 'MC' 
--				@pDivision - either 0 for all divisions or a specific division code ex 4 (Food & Beverage)
				@pBU_Code - blank for all BU's or a comma separated list of BUs. ex 19010,19011,19012
				@pStart_Date - The beginning date used for data selection
				@pEnd_Date - The end date used for data selection
				@owner - either 1 for regular division or AB# for user-defined codes
				@pWage_Type - a comma separated list of Wage Types. ex 1,2,3
-- Description:	This enhanced version of the report includes employee base hourly rates and whether the employee is follows salary or other payrules.
-- Example:		exec dbo.stp_itw_rpt_daily_labour_enhanced 'MC',0,'19010,19011,19012,19013,19014,19015','1/26/2010','1/26/2010','1','1,2'
-- Revisions:	BK	2/10/2010	1.0	Created from dbo.sp_itw_rpt_daily_labour
					has been updated to be called from Reporting Services.
-- =============================================*/

declare @regular_hrs decimal(9,3), @overtime_hrs decimal(9,3);
declare	@adjust_hrs decimal(9,3), @nonpaid_hrs decimal(9,3);
declare	@pBU_Code_dollars decimal(9,3), @rate decimal(6,3);
declare @total_hrs  decimal(9,3), @statpay_hrs decimal(9,3);
declare @flat_amount decimal(9,3);

declare @empnumber varchar(15), @empname varchar(100);
declare @employeeid integer, @weekday varchar(20);
declare @pBU_Code_name varchar(50), @pBU_Code_descr varchar(250);
declare @div int;
declare @job varchar(50), @job_step varchar(50);

declare @job_step_sql varchar(200), @pBU_Code_sql varchar(8000);

declare @Wage_Type_List varchar(1000), @Wage_Type_1 varchar(3), @Position int;
declare @BU_Code_List varchar(8000), @BU_Code_1 varchar(6);

create table #hold_report
(bu_name	varchar(50),
 bu_desc	varchar(250),
 job		char(6),
 emp_number 	varchar(15),
 emp_name	varchar(64),
 flat_amount	decimal(9,3),
 reg_hours	decimal(9,3),
 ot_hours	decimal(9,3),
 adjust_hours	decimal(9,3),
 nonpaid_hours	decimal(9,3),
 stat_hours	decimal(9,3),
 total_hours	decimal(9,3),
 bu_amount	decimal(9,3),
 division	int,
 rate		decimal(6,3),
job_step	varchar(50));

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

end;

--create an SQL expression to handle the bu filter
if (@pBU_Code is null or rtrim(@pBU_Code) = '') 
begin
	select @pBU_Code_sql = '';
end;
else
begin
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
--				print @BU_Code_List
			
			end;
			set @pBU_Code = right(@pBU_Code, len(@pBU_Code) - @Position);
			set @Position = charindex(',', @pBU_Code, 1);
			
		end;
	end;
	set @BU_Code_List = left(@BU_Code_List, len(@BU_Code_List) - 1);
	select @pBU_Code_sql = ' a.laborlevelname2 IN (' + @BU_Code_List + ') and ';
--	print @pBU_Code_sql;
end;


select @regular_hrs = 0.00, @overtime_hrs = 0.00, @adjust_hrs = 0.00;
select @nonpaid_hrs = 0.00, @total_hrs = 0.00, @flat_amount = 0.00;
select @statpay_hrs = 0.00;

--Create the cursor upon which the report will be based
	
	exec ('DECLARE employee_cursor CURSOR FOR 
	SELECT DISTINCT
		e.personnum, e.personFULLNAME, e.EMPLOYEEID, 
		a.laborlevelname2, a.laborleveldsc2, a.laborlevelname3, e.basewagehourlyamt, a.laborlevelname1
	FROM 	
		v_itw_totalsv43 a, itw_paycode_grouping d, v_itw_employeev43 e
	WHERE 	a.employeeid = e.employeeid and 
		a.paycodeid = d.paycodeid and '
		+ @job_step_sql +
		@pBU_Code_sql +
		' (a.timeinseconds <> 0 or a.moneyamount <> 0) and  
		a.laborlevelname2 <> ''0'' and
		a.notpaidsw = 0 and
		left(a.laborlevelname1, 2) = ''' + @pResort_Code + ''' and
		d.resort = ''' + @pResort_Code + ''' and
		right(left(a.LABORLEVELNAME1,3),1) between ''0'' and ''9'' and
		a.applydate between ''' + @pStart_Date + ''' and ''' + @pEnd_Date + ''';');
			

open employee_cursor;

fetch next from employee_cursor into @empnumber, @empname, @employeeid, 
@pBU_Code_name, @pBU_Code_descr, @job, @rate, @job_step;

while @@fetch_status = 0
begin

	select @regular_hrs = 0.00, @overtime_hrs = 0.00, @adjust_hrs = 0.00;
	select @nonpaid_hrs = 0.00, @total_hrs = 0.00, @flat_amount = 0.00;
	select @statpay_hrs = 0.00;
	select @div = -1;
	
	--Find the division to which this BU belongs
	SELECT	@div = isNull(dbr.divisionid, -1)
	FROM	itw_bu_hierarchy dbr, laborlevelentry lle
	WHERE	lle.laborlevelentryid = dbr.laborlevelentryid and
		lle.laborleveldefid = 2 and
		lle.name = @pBU_Code_name and
		dbr.personnum = @owner;

	/*
	The following "if" statement decides whether or not to execute the sub queries.
	There are 3 conditions, one of which must be true:
		1. The division for the current BU is the same as the division selected
		on the web form, i.e., the report was run for one division (default, or 
		user-defined).
		2. No division was selected on the webform, and "All BUs", or "All Divisions"
		was selected.
		3. No division was selected and "All User-Defined Divisions" were chosen.
	*/
	if ((@div = @pDivision) or (@pDivision = 0 and @owner = 1) or (@pDivision = 0 and @div in (select divisionid from 
itw_bu_hierarchy where personnum = @owner)))
	begin

		/*
		The following "sub queries" get the actual data for the report.
		There is one sub query for each column that appears on the
		report.  Each column is a sum of the data for a particular
		grouping of pay codes.  The relationship between the pay codes
		and the column are made in the itw_paycode_grouping table.
		The pay codes that will appear in a particular column are
		given a common "pay_type" value.  For instance all paycodes
		that are grouped into "Regular Hours" have a pay_type of "R".
		
		Most of the data is summed over the time period selected by the
		user.  However, some of the columns give "Week to Date" sums.
		The start date for these summed values was determined above.
		*/
		
		--Regular Hours
		SELECT 	@regular_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
		FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
		WHERE 	a.paycodeid = d.paycodeid and
			a.laboracctid = l1.laboracctid and
			l1.laborlev2nm = @pBU_Code_name and
			l1.laborlev3nm = @job and
			l1.laborlev1nm = @job_step and
			a.employeeid = @employeeid and
			d.pay_type = 'R' and
			a.notpaidsw = 0 and
			d.resort = @pResort_Code and
			a.applydtm between @pStart_Date and @pEnd_Date;
		
		--Overtime Hours
		SELECT 	@overtime_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
		FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
		WHERE 	a.paycodeid = d.paycodeid and
			a.laboracctid = l1.laboracctid and
			l1.laborlev2nm = @pBU_Code_name and
			l1.laborlev3nm = @job and
			l1.laborlev1nm = @job_step and
			a.employeeid = @employeeid and
			d.pay_type = 'O' and
			a.notpaidsw = 0 and
			d.resort = @pResort_Code and
			a.applydtm between @pStart_Date and @pEnd_Date;
		
		--Adjustment Hours
		SELECT 	@adjust_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
		FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
		WHERE 	a.paycodeid = d.paycodeid and
			a.laboracctid = l1.laboracctid and
			l1.laborlev2nm = @pBU_Code_name and
			l1.laborlev3nm = @job and
			l1.laborlev1nm = @job_step and
			a.employeeid = @employeeid and
			d.pay_type = 'A' and
			a.notpaidsw = 0 and
			d.resort = @pResort_Code and
			a.applydtm between @pStart_Date and @pEnd_Date;
			
		--Non-Paid hours
		SELECT 	@nonpaid_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
		FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
		WHERE 	a.paycodeid = d.paycodeid and
			a.laboracctid = l1.laboracctid and
			l1.laborlev1nm = @job_step and
			l1.laborlev2nm = @pBU_Code_name and
			l1.laborlev3nm = @job and
			a.employeeid = @employeeid and
			d.pay_type = 'N' and
			a.notpaidsw = 0 and
			d.resort = @pResort_Code and
			a.applydtm between @pStart_Date and @pEnd_Date;
		
		--Stat Pay Hours
		SELECT 	@statpay_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
		FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
		WHERE 	a.paycodeid = d.paycodeid and
			a.laboracctid = l1.laboracctid and
			l1.laborlev1nm = @job_step and
			l1.laborlev2nm = @pBU_Code_name and
			l1.laborlev3nm = @job and
			a.employeeid = @employeeid and
			d.pay_type = 'S' and
			a.notpaidsw = 0 and
			d.resort = @pResort_Code and
			a.applydtm between @pStart_Date and @pEnd_Date;


		--Total Hours
		SELECT 	@total_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
		FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
		WHERE 	a.paycodeid = d.paycodeid and
			a.laboracctid = l1.laboracctid and
			l1.laborlev1nm = @job_step and
			l1.laborlev2nm = @pBU_Code_name and
			l1.laborlev3nm = @job and
			a.employeeid = @employeeid and
			d.pay_type <> 'N' and
			d.pay_type <> 'FC' and
			a.notpaidsw = 0 and
			d.resort = @pResort_Code and
			a.applydtm between @pStart_Date and @pEnd_Date;
			
		--Flat Amounts
		SELECT 	@flat_amount = isnull(sum(a.moneyamt), 0)
		FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
		WHERE 	a.paycodeid = d.paycodeid and
			a.laboracctid = l1.laboracctid and
			l1.laborlev1nm = @job_step and
			l1.laborlev2nm = @pBU_Code_name and
			l1.laborlev3nm = @job and
			a.employeeid = @employeeid and
			d.pay_type = 'F' and
			a.notpaidsw = 0 and
			d.resort = @pResort_Code and
			a.applydtm between @pStart_Date and @pEnd_Date;


		--Total Dollars
		SELECT 	@pBU_Code_dollars = isnull(sum(a.wageamt), 0) + isnull(sum(a.moneyamt), 0)
		FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
		WHERE 	a.paycodeid = d.paycodeid and
			a.laboracctid = l1.laboracctid and
			l1.laborlev1nm = @job_step and
			l1.laborlev2nm = @pBU_Code_name and
			l1.laborlev3nm = @job and
			a.employeeid = @employeeid and
			d.resort = @pResort_Code and
			a.notpaidsw = 0 and
			d.pay_type <> 'N' and
			d.pay_type <> 'FC' and
			a.applydtm between @pStart_Date and @pEnd_Date;
		

		insert into #hold_report
		(bu_name, bu_desc, job, emp_number, emp_name, flat_amount, reg_hours, ot_hours, 
		adjust_hours, nonpaid_hours, stat_hours, total_hours, bu_amount, 
		division, rate, job_step)
		values
		(@pBU_Code_name, @pBU_Code_descr, @job, @empnumber, @empname, @flat_amount, 
		@regular_hrs, @overtime_hrs, @adjust_hrs, @nonpaid_hrs, @statpay_hrs, @total_hrs, 
		@pBU_Code_dollars, @div, @rate, @job_step);


	end;

	fetch next from employee_cursor into @empnumber, @empname,  @employeeid, 
	@pBU_Code_name, @pBU_Code_descr, @job, @rate, @job_step;
end;

close employee_cursor;
deallocate employee_cursor;

/*
Users can select which wage profiles to show: Salary, not Salary, or all.
*/

--All wage profiles
select 	
	cast(bu_name as int) as 'bu_name', bu_desc, job as job_type, emp_number, emp_name, flat_amount, reg_hours, ot_hours, 
	adjust_hours, nonpaid_hours, stat_hours, total_hours, bu_amount, 
	IsNull((SELECT div.description
	FROM itw_division div
	WHERE div.division_id = division), 'Unknown') as 'division', rate, left(job_step, 3) as job_step
from 	
	#hold_report
order by 
	division, cast(bu_name as int), job_type, emp_name;

end;
GO

GRANT  EXECUTE  ON [dbo].[stp_itw_rpt_daily_labour_enhanced]  TO [DBA_KronosSupport]
GO
