declare @itineraryid int;
set @itineraryid = 10703469;

select cpaaa.GL_DATE, cpaaa.SupplierID, cpaaa.SupplierName, sum(cpaaa.AppliedAmount) * -1 CPAAAmount, cpaaa.AcctgCategory2, left(cpaaa.INTERFACE_CODE, 2) Resort
from inntopia.CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_ALLOCATION cpaaa
right join inntopia.CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_TRANSACTION cpaat
on cpaaa.FK_Transaction = cpaat.XPK_Transaction
where cpaat.ItineraryID = @itineraryid
and cpaaa.SupplierID <> 0
group by cpaaa.GL_DATE, SupplierID, SupplierName, cpaaa.AcctgCategory2, cpaaa.INTERFACE_CODE;