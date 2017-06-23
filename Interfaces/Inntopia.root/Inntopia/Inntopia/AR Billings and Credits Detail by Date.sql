DECLARE @enddate       DATE,  
        @resort_code   CHAR(2); 

SET @enddate = Eomonth(Dateadd(m, -1, Getdate())); 
SET @resort_code = 'RT';  

SELECT 
       billedname,
       billedid,
       rsyssupplierid,
	   itineraryid, 
       customername, 
       transactiondate,  
       totalbilled - taxes TaxableAmount, 
       totalbilled Total, 
       taxes Taxes 
FROM   inntopia.accountsreceivablebillingscredits_transaction
WHERE  gl_date = @enddate 
       AND interface_code = @resort_code + 'INNARJDE'
ORDER  BY BilledName, 
          itineraryid 