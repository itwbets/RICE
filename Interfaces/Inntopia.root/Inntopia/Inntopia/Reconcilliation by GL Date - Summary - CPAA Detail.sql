declare @startdate date, @enddate date, @InterfaceCode char(10), @resort_code char(2);
set @startdate = dateadd(d, -1, getdate());
set @enddate = @startdate;
set @resort_code = 'RT'
set @InterfaceCode = @resort_code + 'INN__JDE';


select cpaaa.SupplierID, cpaaa.SupplierName, sum(cpaaa.AppliedAmount) * -1 CPAAAmount, cpaaa.AcctgCategory2
from inntopia.CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_ALLOCATION cpaaa
where cpaaa.GL_DATE between @startdate and @enddate
and cpaaa.INTERFACE_CODE like @resort_code + 'INN__JDE'
and cpaaa.SupplierID <> 0
group by SupplierID, SupplierName, cpaaa.AcctgCategory2;