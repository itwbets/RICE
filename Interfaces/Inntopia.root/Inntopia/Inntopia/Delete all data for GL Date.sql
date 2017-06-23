declare @gldate date;
set @gldate = '12/12/2015';

delete a
from inntopia.CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_ALLOCATION a inner join 
inntopia.CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_TRANSACTION t
on a.FK_Transaction = t.XPK_Transaction
where t.GL_DATE = @gldate;

delete t
from inntopia.CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_TRANSACTION t
where t.GL_DATE = @gldate;

delete a
from inntopia.CUSTOMERPAYMENTSADJUSTMENTS_ALLOCATION a inner join 
inntopia.CUSTOMERPAYMENTSADJUSTMENTS_TRANSACTION t
on a.FK_Transaction = t.XPK_Transaction
where t.GL_DATE = @gldate;

delete t
from inntopia.CUSTOMERPAYMENTSADJUSTMENTS_TRANSACTION t
where t.GL_DATE = @gldate;

delete t
from inntopia.CUSTOMERBILLINGS_TRANSACTION t
where t.GL_DATE = @gldate;