declare @itineraryid int;
set @itineraryid = 10761102;

select gl_date, ItineraryID, CustomerName, AcctgCategory2,  
sum(Total) CBTotal,
left(INTERFACE_CODE, 2) Resort
from inntopia.CUSTOMERBILLINGS_TRANSACTION
where ItineraryID = @itineraryid
group by gl_date, ItineraryID, CustomerName, AcctgCategory2, INTERFACE_CODE;