declare @startdate date, @enddate date, @InterfaceCode char(10), @resort_code char(2);
set @startdate = dateadd(d, -1, getdate());
set @enddate = @startdate;
set @resort_code = 'RT'
set @InterfaceCode = @resort_code + 'INN__JDE';

with 

cpa (ItineraryID, CustomerName, PaymentMethod, Account, Total, Sort)
as
(select ItineraryID, CustomerName, coalesce(cpa.CreditCardType, cpa.PaymentType) PaymentMethod, cpa.account_string Account, sum(Total)*-1, row_number() OVER (partition by cpa.itineraryid order by coalesce(cpa.CreditCardType, cpa.PaymentType))
from inntopia.CUSTOMERPAYMENTSADJUSTMENTS_TRANSACTION cpa 
left outer join dbo.INNTOPIA_ACCOUNT_LKP ial
	on cpa.PaymentTypeCode = ial.PAYMENTTYPECODE
	and ial.INTERFACECODE = cpa.INTERFACE_CODE
where GL_DATE between @startdate and @enddate
and INTERFACE_CODE like @resort_code + 'INN__JDE'
group by ItineraryID, CustomerName, coalesce(cpa.CreditCardType, cpa.PaymentType), cpa.account_string),


cb (ItineraryID, CustomerName, AcctgCategory, Total, Sort)
as
(select ItineraryID, CustomerName, AcctgCategory2, sum(Total), 1
from inntopia.CUSTOMERBILLINGS_TRANSACTION c
where GL_DATE between @startdate and @enddate
and INTERFACE_CODE like @resort_code + 'INN__JDE'
group by ItineraryID, CustomerName, AcctgCategory2),


cpaa (ItineraryID, CustomerName, SupplierID, SupplierName, AcctgCategory2, Total, Sort)
as
(select cpaat.ItineraryID, cpaat.CustomerName, cpaaa.SupplierID, cpaaa.SupplierName, cpaaa.AcctgCategory2, sum(cpaaa.AppliedAmount) * -1, row_number() OVER (partition by cpaat.itineraryid ORDER BY cpaaa.SupplierID) Sort
from inntopia.CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_TRANSACTION  cpaat
inner join inntopia.CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_ALLOCATION cpaaa
	on cpaat.XPK_Transaction = cpaaa.FK_Transaction
where cpaaa.GL_DATE between @startdate and @enddate
and cpaaa.INTERFACE_CODE like @resort_code + 'INN__JDE'
and cpaaa.SupplierID <> 0
group by cpaat.ItineraryID, CustomerName, cpaaa.SupplierID, cpaaa.SupplierName, cpaaa.AcctgCategory2)


select coalesce(cpa.ItineraryID, cb.itineraryid, cpaa.itineraryid) ItineraryID, coalesce(cpa.CustomerName, cb.CustomerName, cpaa.CustomerName) CustomerName, 
cpa.PaymentMethod, isnull(cpa.Total, 0) CPATotal, cpa.Account, 
isnull(cb.Total, 0) CBTotal, cb.AcctgCategory, 
cpaa.SupplierID, cpaa.SupplierName, isnull(cpaa.Total, 0) CPAATotal, cpaa.AcctgCategory2, 
isnull(cpa.Total, 0) - isnull(cb.Total, 0) DiffCPA_CB, isnull(cpa.Total, 0)*-1 - isnull(cpaa.Total, 0) DiffCPA_CPAA
from cpa 
full outer join cb
	on cpa.ItineraryID = cb.ItineraryID
	and cpa.Sort = cb.Sort
full outer join cpaa
	on cpaa.ItineraryID = cpa.ItineraryID
	and cpaa.Sort = cpa.Sort
order by coalesce(cpa.ItineraryID, cb.itineraryid, cpaa.itineraryid), cpaa.SupplierID;


