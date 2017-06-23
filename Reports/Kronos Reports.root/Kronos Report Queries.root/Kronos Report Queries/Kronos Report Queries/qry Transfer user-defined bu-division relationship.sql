INSERT INTO [TKCSDB].[dbo].[itw_bu_hierarchy]
           ([laborlevelentryid]
           ,[divisionid]
           ,[resort_code]
           ,[resort_name]
           ,[division_code]
           ,[division_name]
           ,[bu_code]
           ,[bu_desc]
           ,[personnum]
           ,[create_date])

           select 
           laborlevelentryid, 
           r.division_id, 
           resort, 
           (select distinct resort_name from itw_bu_hierarchy where resort_code = r.resort),
           code,
           description,
           (select name from laborlevelentry l where l.laborlevelentryid = r.laborlevelentryid),
           (select description from laborlevelentry l where l.laborlevelentryid = r.laborlevelentryid),
           r.personnum,
           getdate()
           from itw_division_bu_rel r inner join itw_division d
           on r.division_id = d.division_id
           where r.personnum > 1
GO


