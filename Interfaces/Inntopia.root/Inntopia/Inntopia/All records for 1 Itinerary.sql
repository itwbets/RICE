declare @itineraryid int;
set @itineraryid = 10703469
;


select *
from inntopia.CUSTOMERPAYMENTSADJUSTMENTS_TRANSACTION cpa 
where ItineraryID = @itineraryid
order by TransactionID

select *
from inntopia.CUSTOMERBILLINGS_TRANSACTION c
where ItineraryID = @itineraryid
order by TransactionID

select cpaaa.TransactionID, *
from inntopia.CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_TRANSACTION  cpaat
inner join inntopia.CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_ALLOCATION cpaaa
	on cpaat.XPK_Transaction = cpaaa.FK_Transaction
where ItineraryID = @itineraryid
order by cpaat.TransactionID
