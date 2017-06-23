USE [TKCSDB]
GO
/****** Object:  StoredProcedure [dbo].[stp_itw_rpt_work_order_detail]    Script Date: 03/05/2010 16:23:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE procedure [dbo].[stp_itw_rpt_work_order_detail]
/* =============================================
-- Author:		Betsy Kowan
-- Create date:	2/17/2010
-- Parameters:	@pResort_Code - the short resort code ex 'MC' 
				@pWork_Order - blank for all WO's or a comma separated list of WOs. ex 19010,19011,19012
				@pStart_Date - The beginning date used for data selection
				@pEnd_Date - The end date used for data selection
				@pLabourLevelStatus - which WO's to select: -1=All, 0=Open, 1=Closed
-- Description:	The purpose of this report is to provide a snapshot of labour hours and dollars for one or many Business Units. 
-- Example:		exec dbo.stp_itw_rpt_work_order_detail 'MC','MC19010,MC19011,MC19012,MC19013,MC19014,MC19015','1/26/2010','1/26/2010',0
-- Revisions:	BK	2/17/2010	1.0	Created from dbo.sp_itw_rpt_work_order_detail
					has been updated to be called from Reporting Services.
-- =============================================*/
@pResort_Code 		char(2),
@pWork_Order 		varchar(4000), 
@pMWork_Order		varchar(4000),
@pStart_Date		datetime,
@pEnd_Date			datetime,
@pLabour_Level_Status int

as
begin

set nocount on;

declare @Work_Order_List varchar(8000), @WO_Code_1 varchar(8000), @Position int;
declare @Work_Order_Sql varchar(8000);

set @Work_Order_List = ''

	if ((@pWork_Order is null or rtrim(@pWork_Order) = '') and(@pMWork_Order is null or rtrim(@pMWork_Order) = ''))
	begin
		select @Work_Order_Sql = '';
	end;
	else
	begin
		set @pWork_Order = ltrim(rtrim(@pWork_Order)) + ',';
		set @Position = CHARINDEX(',', @pWork_Order, 1);
		if replace(@pWork_Order, ',', '') <> ''
		begin
			while @Position > 0
			begin
				set @WO_Code_1 = ltrim(rtrim(left(@pWork_Order, @Position -1)))
				if @WO_Code_1 <> ''
				begin
					set @Work_Order_List = @Work_Order_List + '''' + @WO_Code_1 + '''' + ',';			
				end;
				set @pWork_Order = right(@pWork_Order, len(@pWork_Order) - @Position);
				set @Position = charindex(',', @pWork_Order, 1);
				
			end;
		end;
		set @pMWork_Order = ltrim(rtrim(@pMWork_Order)) + ',';
		set @Position = CHARINDEX(',', @pMWork_Order, 1);
		if replace(@pMWork_Order, ',', '') <> ''
		begin
			while @Position > 0
			begin
				set @WO_Code_1 = ltrim(rtrim(left(@pMWork_Order, @Position -1)))
				if @WO_Code_1 <> ''
				begin
					set @Work_Order_List = @Work_Order_List + '''' + @WO_Code_1 + '''' + ',';			
				end;
				set @pMWork_Order = right(@pMWork_Order, len(@pMWork_Order) - @Position);
				set @Position = charindex(',', @pMWork_Order, 1);
				
			end;
		end;
		set @Work_Order_List = left(@Work_Order_List, len(@Work_Order_List) - 1);
--		print @Work_Order_List
		select @Work_Order_sql = 'and a.laborlevelname4 IN (' + @Work_Order_List + ')';
	end;
	if @pLabour_Level_Status = 1
	begin
		set @Work_Order_sql = @Work_Order_sql + ' and l.inactive = 1'
	end;
	else if @pLabour_Level_Status = 0
		begin
			set @Work_Order_sql = @Work_Order_sql + ' and l.inactive = 0'
		end;
	
/*PRINT 'declare wo_cursor cursor for
		SELECT	a.laborlevelname4, a.laborleveldsc4, e.personnum, e.personfullname, a.applydate, a.paycodename, 
			a.timeinseconds, a.wageamount, a.moneyamount, e.homelaborlevelnm2
		FROM 	dbo.vp_totals a inner join
				dbo.vp_employeev42 e on a.employeeid = e.employeeid
		WHERE (a.timeinseconds <> 0 or a.moneyamount <> 0) and 
			a.paycodetype <> ''G'' and 
			left(a.laborlevelname4, 2) = ''' + @pResort_Code + ''' and             
			a.applydate between ''' + cast(@pStart_Date as varchar(20)) + ''' and ''' + cast(@pEnd_Date as varchar(20)) + ''''
			+ @Work_Order_sql + ''
*/
			
exec ('	SELECT	a.laborlevelname4, a.laborleveldsc4, e.personnum, e.personfullname, a.applydate, a.paycodename, 
			a.timeinseconds, a.wageamount, a.moneyamount, e.homelaborlevelnm2
		FROM 	dbo.vp_totals a inner join
				dbo.vp_employeev42 e on a.employeeid = e.employeeid inner join
				dbo.laborlevelentry l on a.laborlevelname4 = l.name
		WHERE (a.timeinseconds <> 0 or a.moneyamount <> 0) and 
			a.paycodetype <> ''G'' and 
			left(a.laborlevelname4, 2) = ''' + @pResort_Code + ''' and             
			a.applydate between ''' + @pStart_Date + ''' and ''' + @pEnd_Date + ''''
			+ @Work_Order_sql + 'ORDER BY laborlevelname4, e.personnum, applydate;')
		
end;