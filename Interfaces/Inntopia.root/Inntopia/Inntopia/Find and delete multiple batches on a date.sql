select INTERFACE_CODE, GL_DATE, count(distinct batch_id)
from inntopia.CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_ALLOCATION
group by INTERFACE_CODE, GL_DATE
having count(distinct batch_id)> 1

select *
from inntopia.CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_ALLOCATION 
where GL_DATE = '1/13/2016'
order by BATCH_ID, TransactionID

/*
delete 
--select *
from inntopia.CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_ALLOCATION
where batch_id in (61435,
61559)
*/