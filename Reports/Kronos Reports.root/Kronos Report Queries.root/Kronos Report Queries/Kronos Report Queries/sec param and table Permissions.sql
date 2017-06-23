
GRANT DELETE, INSERT, SELECT, UPDATE ON [dbo].[itw_bu_hierarchy] TO [DBA_KronosSupport] AS [dbo]
GO

GRANT DELETE, INSERT, SELECT, UPDATE ON [dbo].[itw_wage_type] TO [DBA_KronosSupport] AS [dbo]
GO

GRANT EXECUTE ON stp_itw_int_cleanup_itw_bu_hierarchy TO [DBA_KronosSupport] AS [dbo]
GO

GRANT EXECUTE ON stp_itw_param_Get_BUs TO [DBA_KronosSupport] AS [dbo]
GO

GRANT EXECUTE ON stp_itw_param_Get_Divisions TO [DBA_KronosSupport] AS [dbo]
GO

GRANT EXECUTE ON stp_itw_param_Get_High_Level_Job_Steps TO [DBA_KronosSupport] AS [dbo]
GO

GRANT EXECUTE ON stp_itw_param_Get_Jobs TO [DBA_KronosSupport] AS [dbo]
GO

GRANT EXECUTE ON stp_itw_param_Get_Labour_Levels TO [DBA_KronosSupport] AS [dbo]
GO

GRANT EXECUTE ON stp_itw_param_Get_Wage_Types TO [DBA_KronosSupport] AS [dbo]
GO
