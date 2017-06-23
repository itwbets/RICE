declare @itineraryid int, @InterfaceCode char(10), @resort_code char(2);
set @itineraryid =  10942562;

select cpa.gl_date, 
coalesce(cpa.CreditCardType, cpa.PaymentType) PaymentMethod,  
sum(cpa.Total)*-1 CPATotal, 
cpa.account_string Account,
left(cpa.INTERFACE_CODE, 2) Resort
from inntopia.CUSTOMERPAYMENTSADJUSTMENTS_TRANSACTION cpa
left outer join dbo.INNTOPIA_ACCOUNT_LKP ial
	on cpa.PaymentTypeCode = ial.PAYMENTTYPECODE
	and ial.INTERFACECODE like @resort_code + 'INN__JDE'
where cpa.ItineraryID = @itineraryid
group by cpa.gl_date, cpa.PaymentTypeCode, cpa.PaymentType, cpa.CreditCardType, cpa.account_string, cpa.INTERFACE_CODE;