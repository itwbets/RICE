declare @startdate date, @enddate date, @InterfaceCode char(10), @resort_code char(2);
set @startdate = dateadd(d, -1, getdate());
set @enddate = @startdate;
set @resort_code = 'RT'
set @InterfaceCode = @resort_code + 'INN__JDE';

select coalesce(cpa.CreditCardType, cpa.PaymentType, cpa.TransferSupplier) PaymentMethod,  
sum(cpa.Total)*-1 CPATotal, 
cpa.account_string Account
from inntopia.CUSTOMERPAYMENTSADJUSTMENTS_TRANSACTION cpa
left outer join dbo.INNTOPIA_ACCOUNT_LKP ial
	on cpa.PaymentTypeCode = ial.PAYMENTTYPECODE
	and ial.INTERFACECODE = cpa.INTERFACE_CODE
where GL_DATE between @startdate and @enddate
and INTERFACE_CODE like @resort_code + 'INN__JDE'
group by cpa.PaymentTypeCode, cpa.PaymentType, cpa.CreditCardType, cpa.TransferSupplier, cpa.account_string;