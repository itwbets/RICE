declare @itineraryid int;
set @itineraryid = 10703469;

with 

cpa (GLDate, ItineraryID, TransactionID, CustomerName, PaymentMethod, Account, Total, Sort)
as
(select GL_DATE, ItineraryID, TransactionID, CustomerName, coalesce(cpa.CreditCardType, cpa.PaymentType) PaymentMethod, cpa.account_string Account, sum(Total)*-1, 1 Sort
from inntopia.CUSTOMERPAYMENTSADJUSTMENTS_TRANSACTION cpa 
group by GL_DATE, ItineraryID, TransactionID, CustomerName, coalesce(cpa.CreditCardType, cpa.PaymentType), cpa.account_string),

cb (GLDate, ItineraryID, TransactionID, CustomerName, AcctgCategory, Total)
as
(select GL_DATE, ItineraryID, TransactionID, CustomerName, AcctgCategory, sum(Total) 
from inntopia.CUSTOMERBILLINGS_TRANSACTION c
group by GL_DATE, ItineraryID, TransactionID, CustomerName, AcctgCategory),

cpaa (GLDate, ItineraryID, TransactionIDTrans, TransactionIDAlloc, CustomerName, SupplierID, SupplierName, AcctgCategory2, Total, Sort)
as
(select cpaat.GL_DATE, cpaat.ItineraryID, cpaat.TransactionID, cpaaa.TransactionID, CustomerName, cpaaa.SupplierID, cpaaa.SupplierName, cpaaa.AcctgCategory2, sum(cpaaa.AppliedAmount), RANK() OVER (partition by cpaat.transactionid ORDER BY cpaaa.transactionid) Sort
from inntopia.CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_TRANSACTION  cpaat
inner join inntopia.CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_ALLOCATION cpaaa
	on cpaat.XPK_Transaction = cpaaa.FK_Transaction
group by cpaat.GL_DATE, cpaat.ItineraryID, cpaat.TransactionID, cpaaa.TransactionID, CustomerName, cpaaa.SupplierID, cpaaa.SupplierName, cpaaa.AcctgCategory2)

select coalesce(cpa.GLDate, cb.gldate, cpaa.gldate) GLDate, 
coalesce(cpa.CustomerName, cb.CustomerName, cpaa.CustomerName) CustomerName, isnull(cpa.PaymentMethod, '') PaymentMethod, isnull(cpa.Total, 0) CPATotal, isnull(cpa.Account, '') CPAAccount, 
isnull(cb.Total, 0) RTPCBTotal, isnull(cb.AcctgCategory, '') RTPCBAcctgCategory, 
isnull(cpaa.SupplierID, 0) SupplierID, isnull(cpaa.SupplierName,'') SupplierName, isnull(cpaa.Total, 0) CPAATotal, isnull(cpaa.AcctgCategory2, '') CPAAAccount, 
isnull(cpa.Total, 0) - isnull(cb.Total, 0) DiffCPA_CB, isnull(cpa.Total, 0) - isnull(cpaa.Total, 0) DiffCPA_CPAA
from cpa 
full outer join cpaa
	on cpaa.ItineraryID = cpa.ItineraryID
	and cpaa.GLDate = cpa.GLDate
	and cpaa.TransactionIDTrans = cpa.TransactionID
	and cpaa.Sort = cpa.Sort
full outer join cb
	on cpaa.ItineraryID = cb.ItineraryID
	and cpaa.GLDate = cb.GLDate
	and cpaa.TransactionIDAlloc = cb.TransactionID
where coalesce(cpa.ItineraryID, cb.itineraryid, cpaa.itineraryid) = @itineraryid
