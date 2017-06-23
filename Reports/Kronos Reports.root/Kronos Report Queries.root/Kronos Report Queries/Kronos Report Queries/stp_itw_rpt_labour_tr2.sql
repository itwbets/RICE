USE [TKCSDB]
GO

IF OBJECT_ID ('[dbo].[stp_itw_rpt_labour_tr2]') IS NOT NULL
DROP PROCEDURE [dbo].[stp_itw_rpt_labour_tr2]; 

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


/* =============================================
	Author:		 Peter Chan
	Create date: 1/26/2010
	Description: Retention Premium Report in MyERP version 2 (for SSRS2008)
	Parameter:	 @pResort_Code - Tremblant (TR)
				 @pDivision - either 0 for all divisions or a specific division code ex 4 (Food & Beverage)
				 @pBU_Code - blank for all BU's or a comma separated list of BUs. ex 19010,19011,19012
				 @pStart_Date - The beginning date used for data selection
				 @pEnd_Date - The end date used for data selection
				 @owner - either 1 for regular division or AB# for user-defined codes
	Example:	 exec dbo.stp_itw_rpt_labour_tr2 'TR', '1', '10018', '1/1/2009', '1/31/2009', '1'
	Revisions:	 PC		1/26/2010	1.0 Created
   =============================================*/

CREATE procedure [dbo].[stp_itw_rpt_labour_tr2]

/*
The Tremblant version of the Daily Labour is largely the same as the regular version of the DL.
BK 9/15/2008  Tremblant has a new paycode for ot dollars that requires the amount to be grabbed from the
moneyamt column instead of wageamt column. Will add @overtime_dlrs2 and then add this to @overtime_dlrs
*/
@pResort_Code	varchar(3) = 'TR',
@pDivision		int,
@pBU_Code 		varchar(4000),
@pStart_Date	datetime,
@pEnd_Date	datetime,
@owner	varchar(15)

as
begin

	
	--Regular
	declare @regular_hrs decimal(9,3), @overtime_hrs decimal(9,3);
	declare @regular_dlrs decimal(9,3), @overtime_dlrs decimal(9,3), @overtime_dlrs2 decimal(9,3);

	-- Adjustment
	declare	@adjust_hrs decimal(9,3), @nonpaid_hrs decimal(9,3);
	declare	@adjust_dlrs decimal(9,3), @nonpaid_dlrs decimal(9,3);

	declare @wtd_hrs decimal(9,3), @wtd_dlrs decimal(9,3);
	declare @total_hrs  decimal(9,3), @total_dlrs  decimal(9,3);

	declare @flat_amount decimal(9,3);
	declare	@pBU_Code_dollars decimal(9,3), @pBU_Code_wtd decimal(9,3);

	declare @empnumber varchar(15), @empname varchar(64);
	declare @employeeid integer, @weekday varchar(20), @wtd_date datetime;
	declare @pBU_Code_name varchar(50), @pBU_Code_descr varchar(250);
	declare @wtd_temp datetime, @Division int;
	declare @job varchar(50);

	-- Newly added variables for new SQL (pchan)
	declare @Wage_Type varchar(25), @Wage_Type_List varchar(1000), @Wage_Type_1 varchar(3);
	declare @job_step_sql varchar(200);
	declare @BU_Code_List varchar(8000), @BU_Code_1 varchar(6), @pBU_Code_sql varchar(8000);
	declare @Position int;

	create table #hold_report
	(bu					varchar(50),
	 emp_number 		varchar(15),
	 emp_name			varchar(64),
	 flat_amount		decimal(9,3),
	 reg_hours			decimal(9,3),
	 reg_dollars		decimal(9,3),
	 ot_hours			decimal(9,3),
	 ot_dollars			decimal(9,3),
	 ot_maint_hours		decimal(9,3),
	 ot_maint_dollars	decimal(9,3),
	 ot_house_hours		decimal(9,3),
	 ot_house_dollars	decimal(9,3),
	 ot_fdesk_hours		decimal(9,3),
	 ot_fdesk_dollars	decimal(9,3),
	 ot_mtnops_hours	decimal(9,3),
	 ot_mtnops_dollars	decimal(9,3),
	 adjust_hours		decimal(9,3),
	 adjust_dollars		decimal(9,3),
	 nonpaid_hours		decimal(9,3),
	 nonpaid_dollars	decimal(9,3),
	 total_hours		decimal(9,3),
	 total_dollars		decimal(9,3),
	 wtd_hours			decimal(9,3),
	 wtd_dollars		decimal(9,3),
	 bu_amount			decimal(9,3),
	 bu_wtd				decimal(9,3),
	 division			int);
	 
	 set @BU_Code_List = ''
	 set @Wage_Type_List = ''
	
	--create an SQL expression to handle the job step filter	 
	set @Wage_Type = '0,1,2,3,4,5,6,7,8,9';
	set @Position = CHARINDEX(',', @Wage_Type, 1);
	if replace(@Wage_Type, ',', '') <> ''
	begin
		while @Position > 0
		begin
			set @Wage_Type_1 = ltrim(rtrim(left(@Wage_Type, @Position -1)))
			if @Wage_Type_1 <> ''
			begin
				set @Wage_Type_List = @Wage_Type_List + '''' + @Wage_Type_1 + '''' + ',';
--				print @Wage_Type_List
			
			end;
			set @Wage_Type = right(@Wage_Type, len(@Wage_Type) - @Position);
			set @Position = charindex(',', @Wage_Type, 1);
			
		end;
	end;
	set @Wage_Type_List = left(@Wage_Type_List, len(@Wage_Type_List) - 1);
	set @job_step_sql = ' right(left(a.laborlevelname1, 3),1) in ( ' + @Wage_Type_List + ') and ';
--	print @job_step_sql

	 
	 --create an SQL expression to handle the bu filter
	if (@pBU_Code is null or rtrim(@pBU_Code) = '') 
	begin
		set @pBU_Code_sql = '';
--		print @pBU_Code_sql
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
--					print @BU_Code_List				
				end;
				set @pBU_Code = right(@pBU_Code, len(@pBU_Code) - @Position);
				set @Position = charindex(',', @pBU_Code, 1);
			end;
		end;
		set @BU_Code_List = left(@BU_Code_List, len(@BU_Code_List) - 1);
		set @pBU_Code_sql = ' a.laborlevelname2 IN (' + @BU_Code_List + ') and ';

	end;


	--datepart returns a "1" for Sunday
	SELECT @weekday = rtrim(datepart(weekday, @pStart_Date));

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


	select @regular_hrs = 0.00, @overtime_hrs = 0.00;
	select @regular_dlrs = 0.00, @overtime_dlrs = 0.00, @overtime_dlrs2 = 0.00;

	select @adjust_hrs = 0.00, @nonpaid_hrs = 0.00;
	select @adjust_dlrs = 0.00, @nonpaid_dlrs = 0.00;

	select @wtd_hrs = 0.00, @wtd_dlrs = 0.00;
	select @total_hrs = 0.00, @total_dlrs = 0.00;

	select @flat_amount = 0.00;
	select @pBU_Code_dollars = 0.00, @pBU_Code_wtd = 0.00;


--Create the cursor upon which the report will be based

exec ('DECLARE employee_cursor CURSOR FOR 
SELECT DISTINCT
	e.personnum, e.personFULLNAME, e.EMPLOYEEID, 
	a.laborlevelname2, a.laborleveldsc2, a.laborlevelname3
FROM 	
	v_itw_totalsv43 a, itw_paycode_grouping d, v_itw_employeev43 e
WHERE 	a.employeeid = e.employeeid and 
	a.paycodeid = d.paycodeid and '
	+ @job_step_sql 
	+ @pBU_Code_sql +
	'(a.timeinseconds <> 0 or a.moneyamount <> 0) and  
	a.laborlevelname2 <> ''0'' and
	a.notpaidsw = 0 and
	left(a.laborlevelname1, 2) = ''' + @pResort_Code + ''' and
	d.resort = ''' + @pResort_Code + ''' and
	a.applydate between ''' + @wtd_date + ''' and ''' + @pEnd_Date + ''';');

	open employee_cursor;

	fetch next from employee_cursor into @empnumber, @empname, @employeeid, 
	@pBU_Code_name, @pBU_Code_descr, @job;

	while @@fetch_status = 0
	begin

		select @regular_hrs = 0.00, @overtime_hrs = 0.00;
		select @regular_dlrs = 0.00, @overtime_dlrs = 0.00, @overtime_dlrs2 = 0.00;
		
		select @adjust_hrs = 0.00, @nonpaid_hrs = 0.00;
		select @adjust_dlrs = 0.00, @nonpaid_dlrs = 0.00;
		
		select @wtd_hrs = 0.00, @wtd_dlrs = 0.00;
		select @total_hrs = 0.00, @total_dlrs = 0.00;
		
		select @flat_amount = 0.00;
		select @pBU_Code_dollars = 0.00, @pBU_Code_wtd = 0.00;
		
		select @Division = -1;
	
	--Find the division to which this BU belongs
	/*The "if" statement here was added to handle the case when a user adds a BU to more than one User-Defined BU 
		grouping. Without this, BUs that belong to more than one division will only be returned somewhat randomly when the report is 
		run for one of the user-defined divisions.
	However, if a user runs the report for "All Groupings", each BU will only appear once in the report.  The grouping 
	in which it appears	is somewhat random. */
	
	if @pDivision = 0
	--All divisions were selected
	begin
		SELECT	@Division = isNull(dbr.divisionid, -1)
		FROM	itw_bu_hierarchy dbr, laborlevelentry lle
		WHERE	lle.laborlevelentryid = dbr.laborlevelentryid and
			lle.laborleveldefid = 2 and
			lle.name = @pBU_Code_name and
			dbr.personnum = @owner;
	end;
	else 
	-- Only one division was selected
	begin
		SELECT	@Division = isNull(dbr.divisionid, -1)
		FROM	itw_bu_hierarchy dbr, laborlevelentry lle
		WHERE	lle.laborlevelentryid = dbr.laborlevelentryid and
			lle.laborleveldefid = 2 and
			lle.name = @pBU_Code_name and
			dbr.personnum = @owner and
			dbr.divisionid = @pDivision;
	end;

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
	

	
	if ((@Division = @pDivision) or (@pDivision = 0 and @owner = 1) or (@pDivision = 0 and @Division in (select divisionid from 
		itw_bu_hierarchy where personnum = @owner)))
	begin

--		print N'Div=' + RTRIM(CAST(@Division as nvarchar(10)));
--		print N'pDivision=' + RTRIM(CAST(@pDivision as nvarchar(10)));
			
			--Regular	
			SELECT 	@regular_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				a.employeeid = @employeeid and
				d.pay_type = 'R' and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			SELECT 	@overtime_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and				
				a.employeeid = @employeeid and
				d.pay_type = 'O' and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;
			
			SELECT 	@regular_dlrs = isnull(sum(a.wageamt), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				a.employeeid = @employeeid and
				d.pay_type = 'R' and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			SELECT 	@overtime_dlrs = isnull(sum(a.wageamt), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				a.employeeid = @employeeid and
				d.pay_type = 'O' and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			SELECT 	@overtime_dlrs2 = isnull(sum(a.moneyamt), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				a.employeeid = @employeeid and
				d.pay_type = 'OA' and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			select @overtime_dlrs = @overtime_dlrs + @overtime_dlrs2;

			


			--Adjustments
			SELECT 	@adjust_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				a.employeeid = @employeeid and
				d.pay_type = 'A' and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			SELECT 	@adjust_dlrs = isnull(sum(a.wageamt), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				a.employeeid = @employeeid and
				d.pay_type = 'A' and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			--Non-paid (time off)
			SELECT 	@nonpaid_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)		
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				a.employeeid = @employeeid and
				d.resort = @pResort_Code and
				d.pay_type = 'N' and
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			SELECT 	@nonpaid_dlrs = isnull(sum(a.wageamt), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				a.employeeid = @employeeid and
				d.resort = @pResort_Code and
				d.pay_type = 'N' and
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			--Total
			SELECT 	@total_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				a.employeeid = @employeeid and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			SELECT 	@total_dlrs = isnull(sum(a.wageamt), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				a.employeeid = @employeeid and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			--Week to Date
			SELECT 	@wtd_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				a.employeeid = @employeeid and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				a.applydtm between @wtd_date and @pEnd_Date;

			SELECT 	@wtd_dlrs = isnull(sum(a.wageamt), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				a.employeeid = @employeeid and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				a.applydtm between @wtd_date and @pEnd_Date;

			--Flat amounts
			SELECT 	@flat_amount = isnull(sum(a.moneyamt), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				a.employeeid = @employeeid and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				d.pay_type = 'F' and
				a.applydtm between @pStart_Date and @pEnd_Date;

			--Total Dollars
			SELECT 	@pBU_Code_dollars = isnull(sum(a.wageamt), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				a.employeeid = @employeeid and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				-- missing this
				d.pay_type <> 'N' and
				d.pay_type <> 'FC' and
				-- end missing
				a.applydtm between @pStart_Date and @pEnd_Date;

			--Total WTD Dollars
			SELECT 	@pBU_Code_wtd = isnull(sum(a.wageamt), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				a.employeeid = @employeeid and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				-- missing this
				d.pay_type <> 'N' and
				d.pay_type <> 'FC' and
				-- end missing
				a.applydtm between @wtd_date and @pEnd_Date;
				
		insert into #hold_report
		(bu, emp_number, emp_name, flat_amount, reg_hours, reg_dollars, 
		ot_hours, ot_dollars, adjust_hours, adjust_dollars, 
		nonpaid_hours, nonpaid_dollars, total_hours, total_dollars, 
		wtd_hours, wtd_dollars, bu_amount, bu_wtd, division)
		values
		(@pBU_Code_name+'   '+@pBU_Code_descr, @empnumber, @empname, @flat_amount, @regular_hrs, @regular_dlrs,
		@overtime_hrs, @overtime_dlrs, @adjust_hrs, @adjust_dlrs,
		@nonpaid_hrs, @nonpaid_dlrs, @total_hrs, @total_dlrs, 
		@wtd_hrs, @wtd_dlrs, @pBU_Code_dollars, @pBU_Code_wtd, @Division);

		end;
		
		fetch next from employee_cursor into @empnumber, @empname, @employeeid, @pBU_Code_name, @pBU_Code_descr, @job;
	end;

	close employee_cursor;
	deallocate employee_cursor;

	select 	
		--bu, emp_number, emp_name, flat_amount, reg_hours, reg_dollars, 
		distinct bu, emp_number, emp_name, flat_amount, reg_hours, reg_dollars, 
		ot_hours, ot_dollars, adjust_hours, adjust_dollars, 
		nonpaid_hours, nonpaid_dollars, total_hours, total_dollars, 
		wtd_hours, wtd_dollars, bu_amount, bu_wtd, 
		IsNull((SELECT div.description
		FROM itw_division div
		WHERE div.division_id = division), 'Unknown') as 'division'
	from 	
		#hold_report
	order by 
		bu, emp_number;
		
end;
GO

GRANT EXECUTE ON [dbo].[stp_itw_rpt_labour_tr2] TO KronosReports
GO