USE [TKCSDB]
GO

IF OBJECT_ID ('[dbo].[stp_itw_rpt_daily_labour_tr_wo2]') IS NOT NULL
DROP PROCEDURE [dbo].[stp_itw_rpt_daily_labour_tr_wo2]; 

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


/* =============================================
	Author:		 Peter Chan
	Create date: 2/19/2010
	Description: Tremblant Labour Report with WO Cost Allocation in MyERP version 2 (for SSRS2008)
	Parameter:	 @pDivision - either 0 for all divisions or a specific division code ex 4 (Food & Beverage)
				 @pBU_Code - blank for all BU's or a comma separated list of BUs. ex 19010,19011,19012
				 @pStart_Date - The beginning date used for data selection
				 @pEnd_Date - The end date used for data selection
				 @owner - either 1 for regular division or AB# for user-defined codes
	Example:	 exec dbo.stp_itw_rpt_daily_labour_tr_wo '1', '10123', '1/1/2009', '1/31/2009', '1'
	Revisions:	 PC		2/19/2010	1.0 Created
   =============================================*/

CREATE procedure [dbo].[stp_itw_rpt_daily_labour_tr_wo2]

/*
The Tremblant version of the Daily Labour is largely the same as the regular version of the DL.
The difference is that TR has many more columns on their report, hence there are many more
subqueries within the cursor loop.

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

	--Maintenance
	declare @regular_maint_hrs decimal(9,3), @overtime_maint_hrs decimal(9,3);
	declare @regular_maint_dlrs decimal(9,3), @overtime_maint_dlrs decimal(9,3);

	--Housekeeping
	declare @regular_house_hrs decimal(9,3), @overtime_house_hrs decimal(9,3);
	declare @regular_house_dlrs decimal(9,3), @overtime_house_dlrs decimal(9,3);

	--Front Desk
	declare @regular_fdesk_hrs decimal(9,3), @overtime_fdesk_hrs decimal(9,3);
	declare @regular_fdesk_dlrs decimal(9,3), @overtime_fdesk_dlrs decimal(9,3);

	--Mountain Ops
	declare @regular_mtnops_hrs decimal(9,3), @overtime_mtnops_hrs decimal(9,3);
	declare @regular_mtnops_dlrs decimal(9,3), @overtime_mtnops_dlrs decimal(9,3);

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
	declare @wo_name varchar(25), @wo_description varchar(100), @wo_bu varchar(8);
	declare @job varchar(50);

	-- Newly added variables for new SQL (pchan)
	declare @Wage_Type varchar(25), @Wage_Type_List varchar(1000), @Wage_Type_1 varchar(3);
	declare @job_step_sql varchar(200);
	declare @BU_Code_List varchar(8000), @BU_Code_1 varchar(6), @pBU_Code_sql varchar(8000),  @pDivision_sql varchar(1000);
	declare @Position int;

	create table #hold_report
	(bu					varchar(50),
	 emp_number 		varchar(15),
	 emp_name			varchar(64),
	 flat_amount		decimal(9,3),
	 reg_hours			decimal(9,3),
	 reg_dollars		decimal(9,3),
	 reg_maint_hours	decimal(9,3),
	 reg_maint_dollars	decimal(9,3),
	 reg_house_hours	decimal(9,3),
	 reg_house_dollars	decimal(9,3),
	 reg_fdesk_hours	decimal(9,3),
	 reg_fdesk_dollars	decimal(9,3),
	 reg_mtnops_hours	decimal(9,3),
	 reg_mtnops_dollars	decimal(9,3),
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
	 set @Wage_Type = '0,1,2,3,4,5,6,7,8,9';
	
	--create an SQL expression to handle the job step filter	 
	if (@Wage_Type is null or rtrim(@Wage_Type) = '')
	begin
		select @job_step_sql = '';
	end;
	else
	begin
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
	end;
		 
	 --create an SQL expression to handle the bu filter
	if (@pBU_Code is null or rtrim(@pBU_Code) = '') 
begin
	select @pBU_Code_sql = '';
	
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
				from itw_bu_hierarchy dbr2, laborlevelentry lle
				where dbr2.laborlevelentryid = lle.laborlevelentryid AND
				a.laborlevelname4 <> ''-'' and 
				lle.name = left(a.laborleveldsc4, charindex(''-'', a.laborleveldsc4) - 2) and
			dbr2.personnum = ''' + @Owner + ''') = ' + cast(@pDivision as varchar(10)) + ')) and ';
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
	select @pBU_Code_sql = ' ((a.laborlevelname4 = ''0'' and a.laborlevelname2 IN 
			(' + @BU_Code_List + ') )
		or (a.laborlevelname4 <> ''-'' and left(a.laborleveldsc4, replace(charindex(''-'', a.laborleveldsc4),0,3) - 2) IN
			(' + @BU_Code_List + ') ))
		and ';
--print @bu_sql

	select @pDivision_sql = '';
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

	select @regular_maint_hrs = 0.00, @overtime_maint_hrs = 0.00;
	select @regular_maint_dlrs = 0.00, @overtime_maint_dlrs = 0.00;

	select @regular_house_hrs = 0.00, @overtime_house_hrs = 0.00;
	select @regular_house_dlrs = 0.00, @overtime_house_dlrs = 0.00;

	select @regular_fdesk_hrs = 0.00, @overtime_fdesk_hrs = 0.00;
	select @regular_fdesk_dlrs = 0.00, @overtime_fdesk_dlrs = 0.00;

	select @regular_mtnops_hrs = 0.00, @overtime_mtnops_hrs = 0.00;
	select @regular_mtnops_dlrs = 0.00, @overtime_mtnops_dlrs = 0.00;

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
	a.laborlevelname2, a.laborleveldsc2, 
	dv.division_id, a.laborlevelname4, a.laborleveldsc4, a.laborlevelname3
FROM 	
	v_itw_totalsv43 a, itw_paycode_grouping d, v_itw_employeev43 e, itw_bu_hierarchy dbr,
	itw_division dv, vp_laboraccount la
WHERE 	a.employeeid = e.employeeid and 
	a.paycodeid = d.paycodeid and '
	+ @job_step_sql 
	+ @pBU_Code_sql +
	' a.laboracctid = la.laboracctid and 
	la.laborlev2id = dbr.LABORLEVELENTRYID and 
	dbr.divisionid = dv.division_id and
	(a.timeinseconds <> 0 or a.moneyamount <> 0) and  
	a.laborlevelname2 <> ''0'' and
	a.notpaidsw = 0 and
	left(a.laborlevelname1, 2) = ''' + @pResort_Code + ''' and
	d.resort = ''' + @pResort_Code + ''' and
	a.applydate between ''' + @wtd_date + ''' and ''' + @pEnd_Date + ''';');

	open employee_cursor;

	fetch next from employee_cursor into @empnumber, @empname, @employeeid, 
	@pBU_Code_name, @pBU_Code_descr, @division, @wo_name, @wo_description, @job;

	while @@fetch_status = 0
	begin

		select @regular_hrs = 0.00, @overtime_hrs = 0.00;
		select @regular_dlrs = 0.00, @overtime_dlrs = 0.00, @overtime_dlrs2 = 0.00;
		
		select @regular_maint_hrs = 0.00, @overtime_maint_hrs = 0.00;
		select @regular_maint_dlrs = 0.00, @overtime_maint_dlrs = 0.00;
		
		select @regular_house_hrs = 0.00, @overtime_house_hrs = 0.00;
		select @regular_house_dlrs = 0.00, @overtime_house_dlrs = 0.00;
		
		select @regular_fdesk_hrs = 0.00, @overtime_fdesk_hrs = 0.00;
		select @regular_fdesk_dlrs = 0.00, @overtime_fdesk_dlrs = 0.00;
		
		select @regular_mtnops_hrs = 0.00, @overtime_mtnops_hrs = 0.00;
		select @regular_mtnops_dlrs = 0.00, @overtime_mtnops_dlrs = 0.00;
		
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
	
	if (@wo_name = '0')
	begin
	
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

			--Maintenance
			SELECT 	@regular_maint_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				a.employeeid = @employeeid and
				d.pay_type = 'RM' and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			SELECT 	@overtime_maint_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				a.employeeid = @employeeid and
				d.pay_type = 'OM' and
				d.resort = @pResort_Code and	
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			SELECT 	@regular_maint_dlrs = isnull(sum(a.wageamt), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				a.employeeid = @employeeid and
				d.pay_type = 'RM' and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			SELECT 	@overtime_maint_dlrs = isnull(sum(a.wageamt), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				a.employeeid = @employeeid and
				d.pay_type = 'OM' and
				d.resort = @pResort_Code and	
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			--Housekeeping
			SELECT 	@regular_house_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				a.employeeid = @employeeid and
				d.pay_type = 'RH' and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			SELECT 	@overtime_house_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				a.employeeid = @employeeid and
				d.pay_type = 'OH' and
				d.resort = @pResort_Code and	
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			SELECT 	@regular_house_dlrs = isnull(sum(a.wageamt), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				a.employeeid = @employeeid and
				d.pay_type = 'RH' and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			SELECT 	@overtime_house_dlrs = isnull(sum(a.wageamt), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				a.employeeid = @employeeid and
				d.pay_type = 'OH' and
				d.resort = @pResort_Code and	
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			--Front Desk
			SELECT 	@regular_fdesk_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				a.employeeid = @employeeid and
				d.pay_type = 'RF' and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			SELECT 	@overtime_fdesk_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				a.employeeid = @employeeid and
				d.pay_type = 'OF' and
				d.resort = @pResort_Code and	
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			SELECT 	@regular_fdesk_dlrs = isnull(sum(a.wageamt), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				a.employeeid = @employeeid and
				d.pay_type = 'RF' and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			SELECT 	@overtime_fdesk_dlrs = isnull(sum(a.wageamt), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				a.employeeid = @employeeid and
				d.pay_type = 'OF' and
				d.resort = @pResort_Code and	
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			--Mountain Ops
			SELECT 	@regular_mtnops_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				a.employeeid = @employeeid and
				d.pay_type = 'RN' and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			SELECT 	@overtime_mtnops_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				a.employeeid = @employeeid and
				d.pay_type = 'ON' and
				d.resort = @pResort_Code and	
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			SELECT 	@regular_mtnops_dlrs = isnull(sum(a.wageamt), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				a.employeeid = @employeeid and
				d.pay_type = 'RN' and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			SELECT 	@overtime_mtnops_dlrs = isnull(sum(a.wageamt), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				a.employeeid = @employeeid and
				d.pay_type = 'ON' and
				d.resort = @pResort_Code and	
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;


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
		end;
		
	end; --wo_name=0
	else
	--there is a WO.  Repeat, but select based on the WO description as well
	begin
	
	--Regular	
			SELECT 	@regular_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				l1.laborlev4nm = @wo_name and
				l1.laborlev4dsc = @wo_description and
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
				l1.laborlev4nm = @wo_name and
				l1.laborlev4dsc = @wo_description and				
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
				l1.laborlev4nm = @wo_name and
				l1.laborlev4dsc = @wo_description and
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
				l1.laborlev4nm = @wo_name and
				l1.laborlev4dsc = @wo_description and
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
				l1.laborlev4nm = @wo_name and
				l1.laborlev4dsc = @wo_description and
				a.employeeid = @employeeid and
				d.pay_type = 'OA' and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			select @overtime_dlrs = @overtime_dlrs + @overtime_dlrs2;

			--Maintenance
			SELECT 	@regular_maint_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				l1.laborlev4nm = @wo_name and
				l1.laborlev4dsc = @wo_description and
				a.employeeid = @employeeid and
				d.pay_type = 'RM' and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			SELECT 	@overtime_maint_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				l1.laborlev4nm = @wo_name and
				l1.laborlev4dsc = @wo_description and
				a.employeeid = @employeeid and
				d.pay_type = 'OM' and
				d.resort = @pResort_Code and	
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			SELECT 	@regular_maint_dlrs = isnull(sum(a.wageamt), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				l1.laborlev4nm = @wo_name and
				l1.laborlev4dsc = @wo_description and
				a.employeeid = @employeeid and
				d.pay_type = 'RM' and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			SELECT 	@overtime_maint_dlrs = isnull(sum(a.wageamt), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				l1.laborlev4nm = @wo_name and
				l1.laborlev4dsc = @wo_description and
				a.employeeid = @employeeid and
				d.pay_type = 'OM' and
				d.resort = @pResort_Code and	
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			--Housekeeping
			SELECT 	@regular_house_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				l1.laborlev4nm = @wo_name and
				l1.laborlev4dsc = @wo_description and
				a.employeeid = @employeeid and
				d.pay_type = 'RH' and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			SELECT 	@overtime_house_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				l1.laborlev4nm = @wo_name and
				l1.laborlev4dsc = @wo_description and
				a.employeeid = @employeeid and
				d.pay_type = 'OH' and
				d.resort = @pResort_Code and	
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			SELECT 	@regular_house_dlrs = isnull(sum(a.wageamt), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				l1.laborlev4nm = @wo_name and
				l1.laborlev4dsc = @wo_description and
				a.employeeid = @employeeid and
				d.pay_type = 'RH' and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			SELECT 	@overtime_house_dlrs = isnull(sum(a.wageamt), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				l1.laborlev4nm = @wo_name and
				l1.laborlev4dsc = @wo_description and
				a.employeeid = @employeeid and
				d.pay_type = 'OH' and
				d.resort = @pResort_Code and	
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			--Front Desk
			SELECT 	@regular_fdesk_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				l1.laborlev4nm = @wo_name and
				l1.laborlev4dsc = @wo_description and
				a.employeeid = @employeeid and
				d.pay_type = 'RF' and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			SELECT 	@overtime_fdesk_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				l1.laborlev4nm = @wo_name and
				l1.laborlev4dsc = @wo_description and
				a.employeeid = @employeeid and
				d.pay_type = 'OF' and
				d.resort = @pResort_Code and	
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			SELECT 	@regular_fdesk_dlrs = isnull(sum(a.wageamt), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				l1.laborlev4nm = @wo_name and
				l1.laborlev4dsc = @wo_description and
				a.employeeid = @employeeid and
				d.pay_type = 'RF' and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			SELECT 	@overtime_fdesk_dlrs = isnull(sum(a.wageamt), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				l1.laborlev4nm = @wo_name and
				l1.laborlev4dsc = @wo_description and
				a.employeeid = @employeeid and
				d.pay_type = 'OF' and
				d.resort = @pResort_Code and	
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			--Mountain Ops
			SELECT 	@regular_mtnops_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				l1.laborlev4nm = @wo_name and
				l1.laborlev4dsc = @wo_description and
				a.employeeid = @employeeid and
				d.pay_type = 'RN' and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			SELECT 	@overtime_mtnops_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				l1.laborlev4nm = @wo_name and
				l1.laborlev4dsc = @wo_description and
				a.employeeid = @employeeid and
				d.pay_type = 'ON' and
				d.resort = @pResort_Code and	
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			SELECT 	@regular_mtnops_dlrs = isnull(sum(a.wageamt), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				l1.laborlev4nm = @wo_name and
				l1.laborlev4dsc = @wo_description and
				a.employeeid = @employeeid and
				d.pay_type = 'RN' and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;

			SELECT 	@overtime_mtnops_dlrs = isnull(sum(a.wageamt), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				l1.laborlev4nm = @wo_name and
				l1.laborlev4dsc = @wo_description and
				a.employeeid = @employeeid and
				d.pay_type = 'ON' and
				d.resort = @pResort_Code and	
				a.notpaidsw = 0 and
				a.applydtm between @pStart_Date and @pEnd_Date;


			--Adjustments
			SELECT 	@adjust_hrs = isnull(sum(a.durationsecsqty/3600.000), 0)
			FROM 	wfctotal a, itw_paycode_grouping d, laboracct l1
			WHERE 	a.paycodeid = d.paycodeid and
				a.laboracctid = l1.laboracctid and
				l1.laborlev2nm = @pBU_Code_name and
				l1.laborlev3nm = @job and
				l1.laborlev4nm = @wo_name and
				l1.laborlev4dsc = @wo_description and
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
				l1.laborlev4nm = @wo_name and
				l1.laborlev4dsc = @wo_description and
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
				l1.laborlev4nm = @wo_name and
				l1.laborlev4dsc = @wo_description and
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
				l1.laborlev4nm = @wo_name and
				l1.laborlev4dsc = @wo_description and
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
				l1.laborlev4nm = @wo_name and
				l1.laborlev4dsc = @wo_description and
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
				l1.laborlev4nm = @wo_name and
				l1.laborlev4dsc = @wo_description and
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
				l1.laborlev4nm = @wo_name and
				l1.laborlev4dsc = @wo_description and
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
				l1.laborlev4nm = @wo_name and
				l1.laborlev4dsc = @wo_description and
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
				l1.laborlev4nm = @wo_name and
				l1.laborlev4dsc = @wo_description and
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
				l1.laborlev4nm = @wo_name and
				l1.laborlev4dsc = @wo_description and
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
				l1.laborlev4nm = @wo_name and
				l1.laborlev4dsc = @wo_description and
				a.employeeid = @employeeid and
				d.resort = @pResort_Code and
				a.notpaidsw = 0 and
				-- missing this
				d.pay_type <> 'N' and
				d.pay_type <> 'FC' and
				-- end missing
				a.applydtm between @wtd_date and @pEnd_Date;
				
		/* The division not be the same as the employee's
		"home" division.  We must do a lookup to find the proper
		division for the WO so that hours are allocated properly. */
		SELECT	@division = dbr.divisionid 
		FROM	itw_bu_hierarchy dbr, laborlevelentry lle
		WHERE	dbr.laborlevelentryid = lle.laborlevelentryid and
			lle.name = left(@wo_description, charindex('-', @wo_description) - 2) and
			dbr.personnum = @owner;
	
	end;
	
	if (UPPER(@wo_description) = 'DEFAULT - NO WORKORDER')
	begin
		insert into #hold_report
			(bu, emp_number, emp_name, flat_amount, reg_hours, reg_dollars, 
			reg_maint_hours, reg_maint_dollars, reg_house_hours, reg_house_dollars, 
			reg_fdesk_hours, reg_fdesk_dollars, reg_mtnops_hours, reg_mtnops_dollars,
			ot_hours, ot_dollars, ot_maint_hours, ot_maint_dollars, 
			ot_house_hours, ot_house_dollars, ot_fdesk_hours, ot_fdesk_dollars, 
			ot_mtnops_hours, ot_mtnops_dollars, adjust_hours, adjust_dollars, 
			nonpaid_hours, nonpaid_dollars, total_hours, total_dollars, 
			wtd_hours, wtd_dollars, bu_amount, bu_wtd, division)
		values
			(@pBU_Code_name+'   '+@pBU_Code_descr, @empnumber, @empname, @flat_amount, @regular_hrs, @regular_dlrs,
			@regular_maint_hrs, @regular_maint_dlrs,@regular_house_hrs, @regular_house_dlrs,
			@regular_fdesk_hrs, @regular_fdesk_dlrs,@regular_mtnops_hrs, @regular_mtnops_dlrs,
			@overtime_hrs, @overtime_dlrs, @overtime_maint_hrs, @overtime_maint_dlrs, 
			@overtime_house_hrs, @overtime_house_dlrs, @overtime_fdesk_hrs, @overtime_fdesk_dlrs, 
			@overtime_mtnops_hrs, @overtime_mtnops_dlrs, @adjust_hrs, @adjust_dlrs,
			@nonpaid_hrs, @nonpaid_dlrs, @total_hrs, @total_dlrs, 
			@wtd_hrs, @wtd_dlrs, @pBU_Code_dollars, @pBU_Code_wtd, @Division);
	end
	else
	begin
		insert into #hold_report
			(bu, emp_number, emp_name, flat_amount, reg_hours, reg_dollars, 
			reg_maint_hours, reg_maint_dollars, reg_house_hours, reg_house_dollars, 
			reg_fdesk_hours, reg_fdesk_dollars, reg_mtnops_hours, reg_mtnops_dollars,
			ot_hours, ot_dollars, ot_maint_hours, ot_maint_dollars, 
			ot_house_hours, ot_house_dollars, ot_fdesk_hours, ot_fdesk_dollars, 
			ot_mtnops_hours, ot_mtnops_dollars, adjust_hours, adjust_dollars, 
			nonpaid_hours, nonpaid_dollars, total_hours, total_dollars, 
			wtd_hours, wtd_dollars, bu_amount, bu_wtd, division)
		values
			(left(@wo_description, charindex('-', @wo_description) - 2)+'   '+@pBU_Code_descr, @empnumber, @empname, @flat_amount, @regular_hrs, @regular_dlrs,
			@regular_maint_hrs, @regular_maint_dlrs,@regular_house_hrs, @regular_house_dlrs,
			@regular_fdesk_hrs, @regular_fdesk_dlrs,@regular_mtnops_hrs, @regular_mtnops_dlrs,
			@overtime_hrs, @overtime_dlrs, @overtime_maint_hrs, @overtime_maint_dlrs, 
			@overtime_house_hrs, @overtime_house_dlrs, @overtime_fdesk_hrs, @overtime_fdesk_dlrs, 
			@overtime_mtnops_hrs, @overtime_mtnops_dlrs, @adjust_hrs, @adjust_dlrs,
			@nonpaid_hrs, @nonpaid_dlrs, @total_hrs, @total_dlrs, 
			@wtd_hrs, @wtd_dlrs, @pBU_Code_dollars, @pBU_Code_wtd, @Division);
	end;
		
		fetch next from employee_cursor into @empnumber, @empname, @employeeid, @pBU_Code_name, @pBU_Code_descr, 
		@division, @wo_name, @wo_description, @job;
	end;

	close employee_cursor;
	deallocate employee_cursor;

	select 	
		--bu, emp_number, emp_name, flat_amount, reg_hours, reg_dollars, 
		isNull((SELECT cast(description as varchar(100))
		from laborlevelentry 
		where laborleveldefid = 2 and name = @pBU_Code_name), 'N/A') as 'bu', emp_number, emp_name, flat_amount, reg_hours, reg_dollars, 
		reg_maint_hours, reg_maint_dollars, reg_house_hours, reg_house_dollars, 
		reg_fdesk_hours, reg_fdesk_dollars, reg_mtnops_hours, reg_mtnops_dollars,
		ot_hours, ot_dollars, ot_maint_hours, ot_maint_dollars, 
		ot_house_hours, ot_house_dollars, ot_fdesk_hours, ot_fdesk_dollars, 
		ot_mtnops_hours, ot_mtnops_dollars, adjust_hours, adjust_dollars, 
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

GRANT EXECUTE ON [dbo].[stp_itw_rpt_daily_labour_tr_wo2] TO KronosReports
