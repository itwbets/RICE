declare @itineraryid int;
set @itineraryid = 10659508 ;

with 

cpa (CustomerName, ItineraryID, GLDate)
as
(select CustomerName, ItineraryID, GL_DATE
from inntopia.CUSTOMERPAYMENTSADJUSTMENTS_TRANSACTION),

cb (CustomerName, ItineraryID, GLDate)
as
(select CustomerName , ItineraryID, GL_Date
from inntopia.CUSTOMERBILLINGS_TRANSACTION),

cpaa (CustomerName, ItineraryID, GLDate)
as
(select CustomerName, ItineraryID, cpaat.GL_Date
from inntopia.CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_TRANSACTION  cpaat
inner join inntopia.CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_ALLOCATION cpaaa
	on cpaat.XPK_Transaction = cpaaa.FK_Transaction)

select (select distinct coalesce(cpa.CustomerName, cb.CustomerName, cpaa.CustomerName)
from cpa 
full outer join cpaa
	on cpaa.ItineraryID = cpa.ItineraryID
	and cpaa.GLDate = cpa.GLDate
full outer join cb
	on cpaa.ItineraryID = cb.ItineraryID
	and cpaa.GLDate = cb.GLDate
where coalesce(cpa.ItineraryID, cb.itineraryid, cpaa.itineraryid) = @itineraryid) CustomerName,
(select sum(Total) * -1 from inntopia.CUSTOMERPAYMENTSADJUSTMENTS_TRANSACTION cpa where cpa.ItineraryID = @itineraryid) CPATotal,
(select sum(Total) from inntopia.CUSTOMERBILLINGS_TRANSACTION cb2 where cb2.ItineraryID = @itineraryid) RTPCBTotal,
(select max(AcctgCategory2) from inntopia.CUSTOMERBILLINGS_TRANSACTION cb3 where cb3.ItineraryID = @itineraryid) RTPCBAcctgCategory,
(select sum(cpaaa.AppliedAmount) * -1 
from inntopia.CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_TRANSACTION  cpaat
inner join inntopia.CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_ALLOCATION cpaaa
	on cpaat.XPK_Transaction = cpaaa.FK_Transaction 
	where cpaat.ItineraryID = @itineraryid
	and cpaaa.SupplierID <> 0
	) AATotal