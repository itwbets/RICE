declare @startdate date, @enddate date, @InterfaceCode char(10), @resort_code char(2);
set @startdate = dateadd(d, -1, getdate());
set @enddate = @startdate;
set @resort_code = 'RT';
set @InterfaceCode = @resort_code + 'INN__JDE';

select
(select sum(Total) * -1 from inntopia.CUSTOMERPAYMENTSADJUSTMENTS_TRANSACTION cpa where cpa.GL_DATE between @startdate and @enddate and cpa.INTERFACE_CODE like @resort_code + 'INN__JDE') CPATotal,
(select sum(Total) from inntopia.CUSTOMERBILLINGS_TRANSACTION cb2 where cb2.GL_DATE between @startdate and @enddate and cb2.INTERFACE_CODE like @resort_code + 'INN__JDE') RTPCBTotal,
(select max(AcctgCategory2) from inntopia.CUSTOMERBILLINGS_TRANSACTION cb3 where cb3.GL_DATE between @startdate and @enddate and cb3.INTERFACE_CODE like @resort_code + 'INN__JDE') RTPCBAcctgCategory,
(select sum(cpaaa.AppliedAmount) * -1 from inntopia.CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_ALLOCATION cpaaa where cpaaa.GL_DATE between @startdate and @enddate and cpaaa.INTERFACE_CODE like @resort_code + 'INN__JDE' and cpaaa.SupplierID <> 0) AATotal
