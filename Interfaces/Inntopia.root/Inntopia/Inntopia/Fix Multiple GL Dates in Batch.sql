declare @temp table (
batch_id int,
gl_date date);

declare @batch_id int, @gl_date date;

insert into @temp
select BATCH_ID, max(gl_date)
from inntopia.CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_TRANSACTION
group by BATCH_ID
having count(distinct gl_date) > 1
order by BATCH_ID;

declare batchid cursor fast_forward for
select * from @temp;

open batchid;

fetch next from batchid into @batch_id, @gl_date;

while @@FETCH_STATUS = 0
begin

	update inntopia.CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_TRANSACTION
	set GL_DATE = @gl_date
	where BATCH_ID = @batch_id;

	update inntopia.CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_ALLOCATION
	set GL_DATE = @gl_date
	where BATCH_ID = @batch_id;

	fetch next from batchid into @batch_id, @gl_date;
end;

close batchid;
deallocate batchid;