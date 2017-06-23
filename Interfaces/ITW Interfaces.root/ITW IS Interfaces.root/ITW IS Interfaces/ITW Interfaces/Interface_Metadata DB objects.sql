USE [Interface_Metadata]
GO

ALTER TABLE [admin].[InterfaceConfiguration] DROP CONSTRAINT [DF_InterfaceConfiguration_create_date]
GO
ALTER TABLE [admin].[InterfaceConfiguration] DROP CONSTRAINT [DF_InterfaceConfiguration_update_date]
GO
ALTER TABLE [admin].[InterfaceConfiguration] DROP CONSTRAINT [DF_InterfaceConfiguration_updated_by_user]
GO
ALTER TABLE [audit].[ExecutionLog] DROP CONSTRAINT [DF_ExecutionLog_TypeID]
GO
ALTER TABLE [audit].[ErrorLog] DROP CONSTRAINT [DF_ErrorLog_create_date]
GO
ALTER TABLE [audit].[ErrorLog] DROP CONSTRAINT [DF_ErrorLog_updated_by_user]
GO
ALTER TABLE [admin].[Configuration] DROP CONSTRAINT [DF_Configuration_create_date]
GO
ALTER TABLE [admin].[Configuration] DROP CONSTRAINT [DF_Configuration_update_date]
GO
ALTER TABLE [admin].[Configuration] DROP CONSTRAINT [DF_Configuration_updated_by_user]
GO
ALTER TABLE [audit].[CommandLog] DROP CONSTRAINT [DF_ETL_CommandLog_LogTime]
GO
ALTER TABLE [audit].[StatisticLog] DROP CONSTRAINT [DF_ETL_StatisticLog_LogTime]
GO
/****** Object:  StoredProcedure [audit].[stp_Get_Package_Summary]    Script Date: 03/23/2011 09:56:00 ******/
DROP PROCEDURE [audit].[stp_Get_Package_Summary]
GO
/****** Object:  StoredProcedure [audit].[stp_KART_Load_Status]    Script Date: 03/23/2011 09:56:00 ******/
DROP PROCEDURE [audit].[stp_KART_Load_Status]
GO
/****** Object:  UserDefinedFunction [audit].[tf_Progress]    Script Date: 03/23/2011 09:56:00 ******/
DROP FUNCTION [audit].[tf_Progress]
GO
/****** Object:  StoredProcedure [audit].[stp_Get_Packages_Error_Details]    Script Date: 03/23/2011 09:56:00 ******/
DROP PROCEDURE [audit].[stp_Get_Packages_Error_Details]
GO
/****** Object:  StoredProcedure [audit].[stp_Get_Packages_with_Errors]    Script Date: 03/23/2011 09:56:00 ******/
DROP PROCEDURE [audit].[stp_Get_Packages_with_Errors]
GO
/****** Object:  StoredProcedure [audit].[stp_Get_Packages_with_Errors_Default]    Script Date: 03/23/2011 09:56:00 ******/
DROP PROCEDURE [audit].[stp_Get_Packages_with_Errors_Default]
GO
/****** Object:  UserDefinedFunction [audit].[tf_GetExecutionLogTree]    Script Date: 03/23/2011 09:56:00 ******/
DROP FUNCTION [audit].[tf_GetExecutionLogTree]
GO
/****** Object:  StoredProcedure [util].[stp_ExecuteSQL]    Script Date: 03/23/2011 09:56:00 ******/
DROP PROCEDURE [util].[stp_ExecuteSQL]
GO
/****** Object:  StoredProcedure [admin].[up_ClearLogs]    Script Date: 03/23/2011 09:56:00 ******/
DROP PROCEDURE [admin].[up_ClearLogs]
GO
/****** Object:  StoredProcedure [audit].[up_Event_Package_OnCount]    Script Date: 03/23/2011 09:56:00 ******/
DROP PROCEDURE [audit].[up_Event_Package_OnCount]
GO
/****** Object:  StoredProcedure [audit].[stp_KART_Load_Status_Log_Details]    Script Date: 03/23/2011 09:56:00 ******/
DROP PROCEDURE [audit].[stp_KART_Load_Status_Log_Details]
GO
/****** Object:  StoredProcedure [audit].[stp_Get_Packages]    Script Date: 03/23/2011 09:56:00 ******/
DROP PROCEDURE [audit].[stp_Get_Packages]
GO
/****** Object:  StoredProcedure [audit].[stp_Get_Packages_Default]    Script Date: 03/23/2011 09:56:00 ******/
DROP PROCEDURE [audit].[stp_Get_Packages_Default]
GO
/****** Object:  StoredProcedure [audit].[stp_Event_Package_OnBegin]    Script Date: 03/23/2011 09:56:00 ******/
DROP PROCEDURE [audit].[stp_Event_Package_OnBegin]
GO
/****** Object:  StoredProcedure [audit].[stp_Event_Package_OnCommand]    Script Date: 03/23/2011 09:56:00 ******/
DROP PROCEDURE [audit].[stp_Event_Package_OnCommand]
GO
/****** Object:  StoredProcedure [audit].[stp_Event_Package_OnCount]    Script Date: 03/23/2011 09:56:00 ******/
DROP PROCEDURE [audit].[stp_Event_Package_OnCount]
GO
/****** Object:  StoredProcedure [audit].[stp_Event_Package_OnEnd]    Script Date: 03/23/2011 09:56:00 ******/
DROP PROCEDURE [audit].[stp_Event_Package_OnEnd]
GO
/****** Object:  StoredProcedure [audit].[stp_Event_Package_OnError]    Script Date: 03/23/2011 09:56:00 ******/
DROP PROCEDURE [audit].[stp_Event_Package_OnError]
GO
/****** Object:  UserDefinedFunction [audit].[sf_GetExecutionLogRoot]    Script Date: 03/23/2011 09:55:59 ******/
DROP FUNCTION [audit].[sf_GetExecutionLogRoot]
GO
/****** Object:  UserDefinedFunction [util].[sf_JdeToDate]    Script Date: 03/23/2011 09:55:59 ******/
DROP FUNCTION [util].[sf_JdeToDate]
GO
/****** Object:  Table [audit].[StatisticLog]    Script Date: 03/23/2011 09:55:59 ******/
DROP TABLE [audit].[StatisticLog]
GO
/****** Object:  Table [audit].[CommandLog]    Script Date: 03/23/2011 09:55:59 ******/
DROP TABLE [audit].[CommandLog]
GO
/****** Object:  Table [admin].[Configuration]    Script Date: 03/23/2011 09:55:59 ******/
DROP TABLE [admin].[Configuration]
GO
/****** Object:  Table [audit].[ErrorLog]    Script Date: 03/23/2011 09:55:59 ******/
DROP TABLE [audit].[ErrorLog]
GO
/****** Object:  Table [audit].[ExecutionLog]    Script Date: 03/23/2011 09:55:59 ******/
DROP TABLE [audit].[ExecutionLog]
GO

DROP TABLE [admin].[InterfaceProperty]
go

/****** Object:  UserDefinedFunction [util].[fSafeDivide]    Script Date: 03/23/2011 09:55:59 ******/
DROP FUNCTION [util].[fSafeDivide]
GO
/****** Object:  Table [admin].[InterfaceConfiguration]    Script Date: 03/23/2011 09:55:59 ******/
DROP TABLE [admin].[InterfaceConfiguration]
GO
/****** Object:  UserDefinedFunction [util].[sf_DateToJde]    Script Date: 03/23/2011 09:55:59 ******/
DROP FUNCTION [util].[sf_DateToJde]
GO
/****** Object:  Table [dbo].[sysssislog]    Script Date: 03/23/2011 09:55:59 ******/
DROP TABLE [dbo].[sysssislog]
GO
/****** Object:  Schema [admin]    Script Date: 03/23/2011 09:55:58 ******/
DROP SCHEMA [admin]
GO
/****** Object:  Schema [audit]    Script Date: 03/23/2011 09:55:58 ******/
DROP SCHEMA [audit]
GO
/****** Object:  Schema [util]    Script Date: 03/23/2011 09:55:58 ******/
DROP SCHEMA [util]
GO

--End of Drops, now let's start building!

/****** Object:  Schema [util]    Script Date: 03/23/2011 09:30:24 ******/
CREATE SCHEMA [util] AUTHORIZATION [dbo]
GO
/****** Object:  Schema [audit]    Script Date: 03/23/2011 09:30:24 ******/
CREATE SCHEMA [audit] AUTHORIZATION [dbo]
GO
/****** Object:  Schema [admin]    Script Date: 03/23/2011 09:30:24 ******/
CREATE SCHEMA [admin] AUTHORIZATION [dbo]
GO


/****** Object:  Table [dbo].[sysssislog]    Script Date: 03/23/2011 09:30:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sysssislog](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[event] [sysname] NOT NULL,
	[computer] [nvarchar](128) NOT NULL,
	[operator] [nvarchar](128) NOT NULL,
	[source] [nvarchar](1024) NOT NULL,
	[sourceid] [uniqueidentifier] NOT NULL,
	[executionid] [uniqueidentifier] NOT NULL,
	[starttime] [datetime] NOT NULL,
	[endtime] [datetime] NOT NULL,
	[datacode] [int] NOT NULL,
	[databytes] [image] NULL,
	[message] [nvarchar](2048) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [admin].[InterfaceConfiguration]    Script Date: 03/23/2011 09:30:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [admin].[InterfaceConfiguration](
	[InterfaceID] [int] IDENTITY(1,1) NOT NULL,
	[InterfaceCode] [char](10) NOT NULL,
	[Description] [varchar](250) NOT NULL,
	[UNCRootFilePath] [varchar](256) NULL,
	[EmailRecipients] [varchar](500) NULL,
	[SendEmail] [bit] NULL,
	[ErrorEmailRecipients] [varchar](500) NULL,
	[DateLastRan] [datetime] NULL,
	[CompanyCode] [int] NULL,
	[CurrencyCode] [char](3) NULL,
	[create_date] [datetime] NOT NULL,
	[update_date] [datetime] NOT NULL,
	[updated_by_user] [varchar](128) NOT NULL,
 CONSTRAINT [PK_InterfaceConfiguration] PRIMARY KEY CLUSTERED 
(
	[InterfaceID] ASC
)WITH (PAD_INDEX  = ON, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

CREATE TABLE [admin].[InterfaceProperty](
	[InterfaceID] [int] NOT NULL,
	[PropertyName] [varchar](50) NOT NULL,
	[PropertyValue] [varchar](4000) NOT NULL,
	[create_date] [datetime] NOT NULL,
	[update_date] [datetime] NOT NULL,
	[updated_by_user] [varchar](128) NOT NULL,
 CONSTRAINT [PK_InterfaceProperty] PRIMARY KEY CLUSTERED 
(
	[InterfaceID] ASC,
	[PropertyName] ASC
)WITH (PAD_INDEX  = ON, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [admin].[InterfaceProperty] ADD  CONSTRAINT [DF_InterfaceProperty_create_date]  DEFAULT (getdate()) FOR [create_date]
GO
ALTER TABLE [admin].[InterfaceProperty] ADD  CONSTRAINT [DF_InterfaceProperty_update_date]  DEFAULT (getdate()) FOR [update_date]
GO
ALTER TABLE [admin].[InterfaceProperty] ADD  CONSTRAINT [DF_InterfaceProperty_updated_by_user]  DEFAULT (suser_sname()) FOR [updated_by_user]
GO

/****** Object:  Table [audit].[ExecutionLog]    Script Date: 03/23/2011 09:30:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [audit].[ExecutionLog](
	[LogID] [int] IDENTITY(1,1) NOT NULL,
	[ParentLogID] [int] NULL,
	[InterfaceID] [int] NOT NULL,
	[Description] [varchar](100) NULL,
	[PackageName] [varchar](100) NOT NULL,
	[PackageGuid] [uniqueidentifier] NOT NULL,
	[PackageVersion] [varchar](20) NOT NULL,
	[MachineName] [varchar](50) NOT NULL,
	[ExecutionGuid] [uniqueidentifier] NOT NULL,
	[Operator] [varchar](50) NOT NULL,
	[StartTime] [datetime] NOT NULL,
	[EndTime] [datetime] NULL,
	[Status] [tinyint] NOT NULL,
	[FailureTask] [varchar](64) NULL,
	[ErrorMessage] [varchar](4000) NULL,
	[BatchNumber] [varchar](20) SPARSE  NULL,
	[ReferenceDate] [datetime] SPARSE  NULL,
	[InputFile] [varchar](256) SPARSE  NULL,
	[ExportFile] [varchar](256) SPARSE  NULL,
	[Debits] [decimal](16, 2) SPARSE  NULL,
	[Credits] [decimal](16, 2) SPARSE  NULL,
	[ReferenceNumber] [varchar](30) SPARSE  NULL,
	[InterfaceResultColumns] [xml] COLUMN_SET FOR ALL_SPARSE_COLUMNS  NULL,
 CONSTRAINT [PK_ExecutionLog] PRIMARY KEY CLUSTERED 
(
	[LogID] ASC
)WITH (PAD_INDEX  = ON, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO

/****** Object:  Table [audit].[ErrorLog]    Script Date: 03/23/2011 09:30:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [audit].[ErrorLog](
	[LogID] [int] NOT NULL,
	[Package_Name] [varchar](250) NOT NULL,
	[Parent_Task_Name] [varchar](250) NOT NULL,
	[Source_Name] [varchar](250) NOT NULL,
	[Target_Name] [varchar](250) NOT NULL,
	[Lookup_Task_Name] [varchar](250) NULL,
	[Lookup_Table_Name] [varchar](250) NULL,
	[Lookup_Key_Columns] [varchar](1000) NULL,
	[Source_Key_Columns] [varchar](1000) NULL,
	[Source_Key_Values] [varchar](1000) NULL,
	[SQL_Query] [varchar](max) NULL,
	[Error_Message] [varchar](max) NULL,
	[create_date] [datetime] NOT NULL,
	[updated_by_user] [varchar](128) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO

/****** Object:  Table [admin].[Configuration]    Script Date: 03/23/2011 09:30:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [admin].[Configuration](
	[ConfigurationFilter] [nvarchar](255) NOT NULL,
	[ConfiguredValue] [nvarchar](255) NULL,
	[PackagePath] [nvarchar](255) NOT NULL,
	[ConfiguredValueType] [nvarchar](20) NOT NULL,
	[create_date] [datetime] NOT NULL,
	[update_date] [datetime] NOT NULL,
	[updated_by_user] [varchar](128) NOT NULL,
 CONSTRAINT [PK_Configuration] PRIMARY KEY CLUSTERED 
(
	[ConfigurationFilter] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO

/****** Object:  Table [audit].[CommandLog]    Script Date: 03/23/2011 09:30:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [audit].[CommandLog](
	[LogID] [int] NOT NULL,
	[CommandID] [int] IDENTITY(1,1) NOT NULL,
	[Key] [varchar](50) NULL,
	[Type] [varchar](50) NULL,
	[Value] [varchar](max) NULL,
	[LogTime] [datetime] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
CREATE CLUSTERED INDEX [CIX_CommandLog] ON [audit].[CommandLog] 
(
	[LogID] ASC,
	[CommandID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

/****** Object:  Table [audit].[StatisticLog]    Script Date: 03/23/2011 09:30:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [audit].[StatisticLog](
	[LogID] [int] NOT NULL,
	[ComponentName] [varchar](50) NOT NULL,
	[Rows] [int] NULL,
	[TimeMS] [int] NULL,
	[MinRowsPerSec] [int] NULL,
	[MeanRowsPerSec]  AS (case when isnull([TimeMS],(0))=(0) then NULL else CONVERT([int],([Rows]*(1000.0))/[TimeMS],(0)) end) PERSISTED,
	[MaxRowsPerSec] [int] NULL,
	[LogTime] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [CIX_StatisticLog] ON [audit].[StatisticLog] 
(
	[LogID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

/****** Object:  Default [DF_InterfaceConfiguration_create_date]    Script Date: 03/23/2011 09:30:26 ******/
ALTER TABLE [admin].[InterfaceConfiguration] ADD  CONSTRAINT [DF_InterfaceConfiguration_create_date]  DEFAULT (getdate()) FOR [create_date]
GO
/****** Object:  Default [DF_InterfaceConfiguration_update_date]    Script Date: 03/23/2011 09:30:26 ******/
ALTER TABLE [admin].[InterfaceConfiguration] ADD  CONSTRAINT [DF_InterfaceConfiguration_update_date]  DEFAULT (getdate()) FOR [update_date]
GO
/****** Object:  Default [DF_InterfaceConfiguration_updated_by_user]    Script Date: 03/23/2011 09:30:26 ******/
ALTER TABLE [admin].[InterfaceConfiguration] ADD  CONSTRAINT [DF_InterfaceConfiguration_updated_by_user]  DEFAULT (suser_sname()) FOR [updated_by_user]
GO
/****** Object:  Default [DF_ExecutionLog_TypeID]    Script Date: 03/23/2011 09:30:26 ******/
ALTER TABLE [audit].[ExecutionLog] ADD  CONSTRAINT [DF_ExecutionLog_TypeID]  DEFAULT ((1)) FOR [InterfaceID]
GO
/****** Object:  Default [DF_ErrorLog_create_date]    Script Date: 03/23/2011 09:30:26 ******/
ALTER TABLE [audit].[ErrorLog] ADD  CONSTRAINT [DF_ErrorLog_create_date]  DEFAULT (getdate()) FOR [create_date]
GO
/****** Object:  Default [DF_ErrorLog_updated_by_user]    Script Date: 03/23/2011 09:30:26 ******/
ALTER TABLE [audit].[ErrorLog] ADD  CONSTRAINT [DF_ErrorLog_updated_by_user]  DEFAULT (suser_sname()) FOR [updated_by_user]
GO
/****** Object:  Default [DF_Configuration_create_date]    Script Date: 03/23/2011 09:30:26 ******/
ALTER TABLE [admin].[Configuration] ADD  CONSTRAINT [DF_Configuration_create_date]  DEFAULT (getdate()) FOR [create_date]
GO
/****** Object:  Default [DF_Configuration_update_date]    Script Date: 03/23/2011 09:30:26 ******/
ALTER TABLE [admin].[Configuration] ADD  CONSTRAINT [DF_Configuration_update_date]  DEFAULT (getdate()) FOR [update_date]
GO
/****** Object:  Default [DF_Configuration_updated_by_user]    Script Date: 03/23/2011 09:30:26 ******/
ALTER TABLE [admin].[Configuration] ADD  CONSTRAINT [DF_Configuration_updated_by_user]  DEFAULT (suser_sname()) FOR [updated_by_user]
GO
/****** Object:  Default [DF_ETL_CommandLog_LogTime]    Script Date: 03/23/2011 09:30:26 ******/
ALTER TABLE [audit].[CommandLog] ADD  CONSTRAINT [DF_ETL_CommandLog_LogTime]  DEFAULT (getdate()) FOR [LogTime]
GO
/****** Object:  Default [DF_ETL_StatisticLog_LogTime]    Script Date: 03/23/2011 09:30:26 ******/
ALTER TABLE [audit].[StatisticLog] ADD  CONSTRAINT [DF_ETL_StatisticLog_LogTime]  DEFAULT (getdate()) FOR [LogTime]
GO

/****** Object:  UserDefinedFunction [util].[sf_DateToJde]    Script Date: 03/23/2011 09:30:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [util].[sf_DateToJde]
	(@Date as datetime)
returns int
as
/* =============================================
 Author:		Matt Fraser
 Create date: 	7/19/2008
 Parameters:	@Date			datetime
 Returns:		int
 Purpose:		Convert a convensional date to a JDE Julian date.
 Description:	This function takes a convensional date  and converts it to a
				JDE Julian date.  A JDE Julian date consist of two parts:
				the number of years since 1900 and the day number of the year.
				For example, 108001 would be January 1, 2008.  99182 would be
				July 1, 1999.
 Example:		select util.sf_DateToJde(getdate())
 Revisions:		MF 7/19/2008 1.0 Created
 ============================================= */
BEGIN
	DECLARE @century char(1);

	SELECT @century = CASE 
		WHEN (year(@Date) < 2000) THEN ''
		ELSE '1'
	end;

	return (
	select  @century +
	  substring(convert(varchar,datepart(year,@Date)),3,2) +  right('00' +
	  convert(varchar,datediff(day,convert(datetime,convert(varchar,datepart(year,@Date)) + '-01-01'), @Date)+1), 3) as JdeDate
	);
end;
GO

/****** Object:  UserDefinedFunction [util].[fSafeDivide]    Script Date: 03/23/2011 09:30:26 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [util].[fSafeDivide] (@numerator decimal(38,6), @denominator decimal(38,6), @undefined decimal(38,6))  
RETURNS decimal(38,6) AS  
/* =============================================
 Author:		Matt Fraser
 Create date: 	9/9/2008
 Parameters:	@numerator	- the numerator (number to be divided)
				@denominator	- the denominator (the number that will do the dividing)
				@undefined	- value to return if @denominator is 0
 Returns:		DECIMAL(38,6)
 Purpose:		Handle potential division by 0 problems when dividing two numbers
 Description:	Takes a numerator and a denominator and divides them after ensuring that the denominator is not 0.
				If it is, returns the undefined value instead.
 Example:		select util.fSafeDivide(6,1,0) 
 Revisions:		1.0	MF	Converted from KART2000
 ============================================= */

BEGIN 

	declare @result decimal(38,6);

	if @denominator = 0.0
	begin
		set @result = @undefined;
	end;
	else
	begin
		set @result = @numerator/@denominator;
	end;
	
	return @result
	
END
GO

/****** Object:  UserDefinedFunction [util].[sf_JdeToDate]    Script Date: 03/23/2011 09:30:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [util].[sf_JdeToDate]
	(@JdeDate as int)
returns datetime
as

/* =============================================
 Author:		Matt Fraser
 Create date: 	7/19/2008
 Parameters:	@JdeDate			int
 Returns:		datetime
 Purpose:		Convert a JDE Julian date to a convensional date.
 Description:	This function takes a JDE Julian date and converts it to a more 
				convensional date format.  A JDE Julian date consist of two parts:
				the number of years since 1900 and the day number of the year.
				For example, 108001 would be January 1, 2008.  99182 would be
				July 1, 1999.
 Example:
 Revisions:	MF 7/19/2008 1.0 Created
 ============================================= */
begin
	declare @vDate datetime;

	set @vDate = dateadd(
			day,convert(int,reverse(substring(reverse(@JdeDate),1,3)))-1,
			convert(datetime,
				case when reverse(substring(reverse(@JdeDate),6,len(@JdeDate))) = '' 
					then '19' + reverse(substring(reverse(@JdeDate),4,2))
      					 when reverse(substring(reverse(@JdeDate),6,len(@JdeDate))) = '1' 
					then '20' + reverse(substring(reverse(@JdeDate),4,2)) end + '-01-01'))
	return @vDate;
end;
GO

/****** Object:  UserDefinedFunction [audit].[sf_GetExecutionLogRoot]    Script Date: 03/23/2011 09:30:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [audit].[sf_GetExecutionLogRoot](@logID int)
returns int
with returns null on null input,
execute as caller
as
/* =============================================
 Author:		G Dickinson
 Create date: 	October 31, 2005
 Parameters:	@logID			int
 Returns:
 Purpose:		Getting the details for a particular log ID and all child processes.
 Description:	This function returns the root of the execution log tree that the specified 
				node belongs to.
 Example:
 Revisions:	GD October 31, 2005 1.0 Authored
 ============================================= */
begin
	declare @rootID int;

	--Derive result using a CTE as the table is self-referencing
	with graph as (
		--select the anchor (specified) node
		select LogID, ParentLogID from audit.ExecutionLog where LogID = @logID
		union all
		--select the parent node
		select node.LogID, node.ParentLogID from audit.ExecutionLog as node
		inner join graph as leaf on (node.LogID = leaf.ParentLogID)
	)
	select @rootID = LogID from graph where ParentLogID is null;
	
	--Return result
	return isnull(@rootID, @logID);
end; --function
GO

/****** Object:  StoredProcedure [audit].[stp_Event_Package_OnError]    Script Date: 03/23/2011 09:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [audit].[stp_Event_Package_OnError]
	 @logID		int
	,@failureTask		varchar(64) = null
	,@message	varchar(max) = null,	--optional, for custom failures
	@BatchNumber varchar(20) =  NULL,
	@ReferenceDate datetime =  NULL,
	@InputFile varchar(256) =  NULL,
	@ExportFile varchar(256) =  NULL,
	@Debits decimal(16, 2) =  NULL,
	@Credits decimal(16, 2) =  NULL,
	@ReferenceNumber varchar(30) = NULL
with execute as caller
as
/* =============================================
 Author:		G Dickinson (project REAL)
 Create date:	May 25, 2005
 Parameters:	@logID				int
				,@failureTask varchar(64)
				,@message	varchar(max) = null	--optional, for custom failures
 Purpose:		Updates log entry to the audit.StatisticLog table.
 Description:	This stored procedure updates an existing entry in the custom event-log table. It flags the
				execution run as complete.
				Status = 0: Running (Incomplete)
				Status = 1: Complete
				Status = 2: Failed
 Example:		exec audit.up_Event_Package_OnError 1, 'Failed'
				select * from audit.ExecutionLog where LogID = 1
 Revisions:		GD May 25, 2005	1.0	Authored
				MF 3/10/2011	2.0  Implemented in Interface_metadata database.  Fixed to use sysssislog database.
				MF	3/17/2011	3.0	Added interface runtime columns
 =============================================*/
begin
	set nocount on;
	
	declare
		 @packageName		varchar(64)
		,@executionGuid		uniqueidentifier;

	select 
		 @packageName = upper(PackageName)
		,@executionGuid = ExecutionGuid
	from audit.ExecutionLog
	where LogID = @logID;

	IF @failureTask IS NULL
	begin
		select top 1 @failureTask = source
		from dbo.sysssislog
		where executionid = @executionGuid
			and (upper(event) = 'ONERROR')
			and upper(source) <> @packageName
		order by endtime desc;
	end;

	update audit.ExecutionLog set
		 EndTime = getdate()
		,Status = 2	--Failed
		,FailureTask = @failureTask
		,ErrorMessage = @message
		,BatchNumber = @BatchNumber,
		 ReferenceDate = @ReferenceDate,
		 InputFile = @InputFile,
		 ExportFile = @ExportFile,
		 Debits = @Debits,
		 Credits = @Credits,
		 ReferenceNumber = @ReferenceNumber
	where
		LogID = @logID;

	set nocount off;
end; --proc
GO

/****** Object:  StoredProcedure [audit].[stp_Event_Package_OnEnd]    Script Date: 03/23/2011 09:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [audit].[stp_Event_Package_OnEnd]
	@logID				int,
	@BatchNumber varchar(20) =  NULL,
	@ReferenceDate datetime =  NULL,
	@InputFile varchar(256) =  NULL,
	@ExportFile varchar(256) =  NULL,
	@Debits decimal(16, 2) =  NULL,
	@Credits decimal(16, 2) =  NULL,
	@ReferenceNumber varchar(30) = NULL
with execute as caller
as
/* =============================================
 Author:		G Dickinson (project REAL)
 Create date:	May 25, 2005
 Parameters:	@logID				int
 Purpose:		Updates log entry to the audit.StatisticLog table.
 Description:	This stored procedure updates an existing entry in the custom event-log table. It flags the
				execution run as complete.
				Status = 0: Running (Incomplete)
				Status = 1: Complete
				Status = 2: Failed
 Example:		declare @logID int
				set @logID = 0
				exec audit.up_Event_Package_OnEnd @logID
				select * from audit.ExecutionLog where LogID = @logID
 Revisions:		GD May 25, 2005	1.0	Authored
				MF	3/17/2011	2.0	Added interface runtime columns
 =============================================*/
begin
	set nocount on;

	update audit.ExecutionLog set
		 EndTime = getdate(), --Note: This should NOT be @logicalDate
		 BatchNumber = @BatchNumber,
		 ReferenceDate = @ReferenceDate,
		 InputFile = @InputFile,
		 ExportFile = @ExportFile,
		 Debits = @Debits,
		 Credits = @Credits,
		 ReferenceNumber = @ReferenceNumber
		,Status = case
			when Status = 0 then 1	--Complete
			else Status
		end --case
	where 
		LogID = @logID;

	set nocount off;
end; --proc
GO

/****** Object:  StoredProcedure [audit].[stp_Event_Package_OnCount]    Script Date: 03/23/2011 09:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [audit].[stp_Event_Package_OnCount]
	 @logID				int
	,@ComponentName		varchar(50)
	,@Rows				int
	,@TimeMS			int
	,@MinRowsPerSec		int = null
	,@MaxRowsPerSec		int = NULL
with execute as caller
as

/* =============================================
 Author:		G Dickinson (project REAL)
 Create date:	May 25, 2005
 Parameters:	@logID				int
		,@ComponentName		varchar(50)
		,@Rows				int
		,@TimeMS			int
		,@MinRowsPerSec		int = null
		,@MaxRowsPerSec		int = null
 Purpose:		Log entry to the audit.StatisticLog table.
 Description:	This stored procedure logs an entry to the custom RowCount-log table.
 Example:		exec audit.up_Event_Package_OnCount 0, 'Test', 100, 1000, 5, 50
				select * from audit.StatisticLog where LogID = 0
 Revisions:	GD August 10, 2005	1.0	Authored
			GD July 14, 2005	1.1 - Implemented NULLs instead of 0's for invalid fields
									- Added @Mean logic
			GD August 09, 2005	1.2 - Removed @Median, @Mode logic as it proved un-useful
 =============================================*/
begin
	set nocount on;

	--Insert the record
	insert into audit.StatisticLog(
		LogID, ComponentName, Rows, TimeMS, MinRowsPerSec, MaxRowsPerSec
	) values (
		isnull(@logID, 0), @ComponentName, @Rows, @TimeMS, @MinRowsPerSec, @MaxRowsPerSec
	);

	set nocount off;
end; --proc
GO

/****** Object:  StoredProcedure [audit].[stp_Event_Package_OnCommand]    Script Date: 03/23/2011 09:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create procedure [audit].[stp_Event_Package_OnCommand]
	 @Key				varchar(50)
	,@Type				varchar(50)
	,@Value				varchar(max)
	,@logID				int
with execute as caller
as

/* =============================================
 Author:		G Dickinson (project REAL)
 Create date:	August 10, 2005
 Parameters:	@Key		varchar(50)
		,@Type		varchar(50)
		,@Value		varchar(max)
		,@logID		int
 Purpose:		Log SQL command to CommandLog table
 Description:	This stored procedure logs a command entry in the custom event-log table. A command is termed
				as any large SQL or XMLA statement that the ETL performs. It is useful for debugging purposes to know
				the exact text of the statement.
 Example:		exec audit.up_Event_Package_OnCommand 'Create Table', 'SQL', '...sql code...', 0
				select * from audit.CommandLog where LogID = 0
 Revisions:	GD August 10, 2005	1.0	Authored
 =============================================*/
begin
	set nocount on;

	--Insert the log record
	insert into audit.CommandLog(
		 LogID
		,[Key]
		,[Type]
		,[Value]
    ) values (
		 isnull(@logID, 0)
		,@Key
		,@Type
		,@Value
	);

	set nocount off;
end; --proc
GO

/****** Object:  StoredProcedure [audit].[stp_Event_Package_OnBegin]    Script Date: 03/23/2011 09:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [audit].[stp_Event_Package_OnBegin]
	 @ParentLogID		int
	,@InterfaceCode		char(10) = null
	,@Description		varchar(100) = null
	,@PackageName		varchar(100)
	,@PackageGuid		uniqueidentifier
	,@PackageVersion	varchar(20)
	,@MachineName		varchar(50)
	,@ExecutionGuid		uniqueidentifier
	,@operator			varchar(30)
	,@logID				int = null output
with execute as caller
as

/* =============================================
 Author:		G Dickinson (project REAL)
 Create date: May 25, 2005
 Parameters:	@ParentLogID		int
		,@InterfaceID		char(10) = null
		,@Description		varchar(100) = null
		,@PackageName		varchar(100)
		,@PackageGuid		uniqueidentifier
		,@PackageVersion	varchar(20)
		,@MachineName		varchar(50)
		,@ExecutionGuid		uniqueidentifier
		,@operator			varchar(30)
		,@logID				int = null output
 Purpose:		Log package start.
 Description:	This stored procedure logs a starting event to the custom event-log table, audit.ExecutionLog
 Example:		declare @logID int
			exec audit.stp_Event_Package_OnBegin 
			 0, 2, 'Description'
			,'PackageName' ,'00000000-0000-0000-0000-000000000000'
			,'MachineName', '00000000-0000-0000-0000-000000000000'
			,'2004-01-01', null, @logID output
		select * from audit.ExecutionLog where LogID = @logID
 Revisions:	GD May 25, 2005	1.0	Authored
			GD August 10, 2005	1.1	Coalesce @logicalDate, @operator, commenting
			MF	3/10/2011	2.0	Implemented in Interface_Metadata database.  Modified from KART version.
			MF	3/15/2011	2.1	Changed from TypeID to InterfaceID
			MF	3/17/2011	2.2	Removed DateLastRan.  Added PackageVersion.
			MF	3/21/2011	2.3	Changed InterfaceID to be InterfaceCode.  Added lookup for InterfaceID
			MF	3/22/2011	2.5	Changed so that if Description is null, set to InterfaceCode instead of PackageName
 =============================================*/
begin
	set nocount on;

	declare @InterfaceID int;
	
	--Set InterfaceID to 1 (Unknown interface) if not specified, otherwise lookup interface
	select @InterfaceID = InterfaceID from admin.InterfaceConfiguration where InterfaceCode = @InterfaceCode;
	
	if @InterfaceID is null set @InterfaceID = 1;

	--Coalesce @operator
	set @operator = nullif(ltrim(rtrim(@operator)), '');
	set @operator = isnull(@operator, suser_sname());

	--Root-level nodes should have a null parent
	if @ParentLogID <= 0 set @ParentLogID = null;

	--Root-level nodes should not have a null Description
	set @Description = nullif(ltrim(rtrim(@Description)), '');
	if @Description is null and @ParentLogID is null set @Description = @InterfaceCode;
	
	--Insert the log record
	insert into audit.ExecutionLog(
		 ParentLogID
		,Description
		,PackageName
		,PackageGuid
		,PackageVersion
		,MachineName
		,ExecutionGuid
		,Operator
		,StartTime
		,EndTime
		,Status
		,FailureTask
		,interfaceid
	) values (
		 @ParentLogID
		,@Description
		,@PackageName
		,@PackageGuid
		,@PackageVersion
		,@MachineName
		,@ExecutionGuid
		,@operator
		,getdate() --Note: This should NOT be @logicalDate
		,null
		,0	--InProcess
		,null
		,@InterfaceID
	);
	set @logID = scope_identity();

	set nocount off;
end; --proc
GO

/****** Object:  StoredProcedure [audit].[stp_Get_Packages_Default]    Script Date: 03/23/2011 09:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [audit].[stp_Get_Packages_Default]
	@pInterfaceID int
as
/* =============================================
-- Author:		Matt Fraser
-- Create date: 1/23/2009
-- Parameters:	None
-- Purpose:		Return most recently run package with no parent package.
	Description:	Returns the logid for the most recently run "top level" package.  This package
					is identified by looking for packages with no parent package and returning the 
					first one when sorted in descending order by time.  
					The	parameter allows the list returned to be filtered to either only packages
					run in the SCD or Truncate/Reload run modes or to include all records.
-- Example:		audit.stp_Get_Package_Summary 1237
-- Revisions:	MF	1/23/2009	1.0 Created
				MF	1/29/2009	1.1 Added @pPackageTypeID parameter to filter list to appropriate package type
				MF	3/15/2011	1.2	Changed from TypeID to InterfaceID
-- =============================================*/
begin
	set nocount on;
	
	select top (1) LogID
	from audit.ExecutionLog
	where ParentLogID is null
	and interfaceid = @pInterfaceID
	order by StartTime desc

	set nocount off;
end;
GO

/****** Object:  StoredProcedure [audit].[stp_Get_Packages]    Script Date: 03/23/2011 09:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [audit].[stp_Get_Packages]
	@pInterfaceID int
as
/* =============================================
-- Author:		Matt Fraser
-- Create date: 1/23/2009
-- Parameters:	None
-- Purpose:		Return a list of all packages with no parent package.
	Description:	Lists the package details for all "top level" packages.  These packages
					are identified by looking for packages with no parent package.  The
					parameter allows the list returned to be filtered to either only packages
					run in the SCD or Truncate/Reload run modes or to include all records.
-- Example:		audit.stp_Get_Package_Summary 1237
-- Revisions:	MF	1/23/2009	1.0 Created
				MF	1/29/2009	1.1 Added @pPackageTypeID parameter to filter list to appropriate package type
				MF	3/15/2011	1.2	Changed from TypeID to InterfaceID
				MF	3/18/2011	1.3	Removed DateLastRan column.
-- =============================================*/
begin
	set nocount on;
	select LogID, PackageName, starttime, endtime, operator, machinename, ExecutionGuid, 
	[Status], FailureTask, ErrorMessage, PackageName + ' (' + CAST(starttime as varchar(30)) + ')' as label
	from audit.ExecutionLog
	where ParentLogID is null
	and interfaceid = @pInterfaceID
	order by StartTime desc;

	set nocount off;
end;
GO

/****** Object:  StoredProcedure [audit].[stp_KART_Load_Status_Log_Details]    Script Date: 03/23/2011 09:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [audit].[stp_KART_Load_Status_Log_Details]
	@pLogID int
as
/* =============================================
-- Author:		Matt Fraser
-- Create date: 1/23/2009
-- Parameters:	None
-- Purpose:		Return low level run details a package with the entered run ID.
	Description:	This procedure will typically be used to diagnose errors encountered
					when a package runs.
-- Example:		audit.stp_Get_Package_Summary 1237
-- Revisions:	MF	1/23/2009	1.0 Created
				MF	2/5/2009	1.1	Added logid to output
-- =============================================*/
begin
	set nocount on;
	
	select source, event, FailureTask, ErrorMessage, message, s.operator, MachineName, id, e.LogID
	from audit.ExecutionLog e inner join dbo.sysssislog s
	on e.ExecutionGuid = s.executionid
	where LogID = @pLogID
	order by id;
	
	set nocount off;
end;
GO

/****** Object:  StoredProcedure [audit].[up_Event_Package_OnCount]    Script Date: 03/23/2011 09:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [audit].[up_Event_Package_OnCount]
	 @logID				int
	,@ComponentName		varchar(50)
	,@Rows				int
	,@TimeMS			int
	,@MinRowsPerSec		int = null
	,@MaxRowsPerSec		int = NULL
with execute as caller
as

/* =============================================
 Author:		G Dickinson (project REAL)
 Create date:	May 25, 2005
 Parameters:	@logID				int
		,@ComponentName		varchar(50)
		,@Rows				int
		,@TimeMS			int
		,@MinRowsPerSec		int = null
		,@MaxRowsPerSec		int = null
 Purpose:		Log entry to the audit.StatisticLog table.
 Description:	This stored procedure logs an entry to the custom RowCount-log table.
 Example:		exec audit.up_Event_Package_OnCount 0, 'Test', 100, 1000, 5, 50
				select * from audit.StatisticLog where LogID = 0
 Revisions:	GD August 10, 2005	1.0	Authored
			GD July 14, 2005	1.1 - Implemented NULLs instead of 0's for invalid fields
									- Added @Mean logic
			GD August 09, 2005	1.2 - Removed @Median, @Mode logic as it proved un-useful
 =============================================*/
begin
	set nocount on;

	--Insert the record
	insert into audit.StatisticLog(
		LogID, ComponentName, Rows, TimeMS, MinRowsPerSec, MaxRowsPerSec
	) values (
		isnull(@logID, 0), @ComponentName, @Rows, @TimeMS, @MinRowsPerSec, @MaxRowsPerSec
	);

	set nocount off;
end; --proc
GO

/****** Object:  StoredProcedure [admin].[up_ClearLogs]    Script Date: 03/23/2011 09:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [admin].[up_ClearLogs]
with execute as caller
as
/* =============================================
-- Author:		?? (project REAL)
-- Create date: ??
-- Parameters:	None
-- Purpose:		Delete all data from all log tables.
	Description:	This stored procedure truncates all 5 log tables.
				SHOULD NOT BE RUN IN PRODUCTION.
-- Example:		admin.up_ClearLogs
-- Revisions:	?? 1.0 Authored
				MF	1.1	Changed sysdtslog90 table to sysssislog table for SQL Server 2008
-- =============================================*/
begin
	set nocount on;

	truncate table audit.CommandLog;
	truncate table audit.ExecutionLog;
	truncate table audit.ProcessLog;
	truncate table audit.StatisticLog;
	truncate table dbo.sysssislog;

	set nocount off;
end --proc
GO

/****** Object:  Trigger [TR_Configuration_update]    Script Date: 03/23/2011 09:30:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [admin].[TR_Configuration_update] 
   ON  [admin].[Configuration] 
   FOR UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
IF NOT UPDATE(update_date) 
 
        UPDATE [admin].[configuration]  
            SET update_date = GETDATE(),
            updated_by_user = suser_sname()
            -- convenient, self-join and 
            -- against the inserted table 
            FROM  [admin].[configuration]  source
            INNER JOIN inserted i 
            ON source.ConfigurationFilter = i.ConfigurationFilter
    

END
GO

/****** Object:  StoredProcedure [util].[stp_ExecuteSQL]    Script Date: 03/23/2011 09:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [util].[stp_ExecuteSQL]
	 @key		varchar(50)
	,@sql		varchar(max)
	,@logID		int
	,@debug		bit = 0		--Debug mode?
with execute as caller
as
/* =============================================
 Author:		??
 Create date:	??
 Parameters:	
				 @key		varchar(50)  --Type of action being performed
				,@sql		varchar(max) --SQL statement to be executed
				,@logID		int			 --LogID of the package issuing the command
				,@debug		bit = 0
 Purpose:		Adds entry to the audit.CommandLog table and then executes SQL command.
 Description:	This stored procedure is auto-created by SSIS when logging is first configured using
				the SQL Server logging provider. The only change we have made is to neaten it up a little.
 Example:		exec util.up_ExecuteSQL 'Test', 'select', 0, 1
 Revisions:		
 =============================================*/
begin
	set nocount on;

	if @debug = 1 
	begin
		print '--' + @key;
		print (@sql);
	END 
	ELSE 
	begin
		--Write the statement to the log first so we can monitor it (with nolock)
		exec audit.stp_Event_Package_OnCommand
			 @Key	= @key
			,@Type	= 'SQL'
			,@Value	= @sql
			,@logID	= @logID;
		--Execute the statement
		exec (@sql);
	end; --if

	set nocount off;
end; --proc
GO

/****** Object:  UserDefinedFunction [audit].[tf_GetExecutionLogTree]    Script Date: 03/23/2011 09:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [audit].[tf_GetExecutionLogTree](
	 @logID			int
	,@fromRoot		bit = 0
) 
returns table
--with execute as caller
as

/* =============================================
 Author:		G Dickinson
 Create date: 	October 31, 2005
 Parameters:	@logID			int
				,@fromRoot		bit = 0
 Returns:
 Purpose:		Getting the details for a particular log ID and all child processes.
 Description:	This function returns the execution log tree that the specified node belongs to,
				either the subtree starting from the node, or the whole tree from the root.
 Example:
 Revisions:	GD October 31, 2005 1.0 Authored
			MF	7/24/2008	1.1	
			MF	8/25/2008	1.2	Added sort column to allow the ordering of data so that parent 
							and child packages are sorted next to each other.
			MF	1/24/2009	1.3	Added milliseconds instead to output.
			MF	1/27/2009	1.4 Removed seconds as they were redundant with milliseconds column
								Added loadgroup column for grouping in report
 ============================================= */

return
(
	--Derive result using a CTE as the table is self-referencing
	with graph as (
		--select the anchor (specified) node
		select *, 0 as Depth, convert(varchar(400),cast(logid AS varchar(10)) + packagename) sort, cast(logid AS varchar(100)) loadgroup 
		from audit.ExecutionLog
		where LogID = case @fromRoot
			when 1 then audit.sf_GetExecutionLogRoot(@logID)
			else @logID
		end --case
		--select the child nodes
		union all
		select leaf.*, Depth + 1, convert(varchar(400),rtrim(sort)+ '|' + convert(varchar(25),leaf.starttime, 121) + leaf.packagename),convert(varchar(100),rtrim(loadgroup)+ '|' +  cast(leaf.logid AS varchar(10)))
		from audit.ExecutionLog as leaf
		inner join graph as node on (node.LogID = leaf.ParentLogID)
	)
	select
		 *
		,datediff(ms, StartTime, EndTime) as milliseconds
	from graph
); --function
GO

/****** Object:  StoredProcedure [audit].[stp_Get_Packages_with_Errors_Default]    Script Date: 03/23/2011 09:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [audit].[stp_Get_Packages_with_Errors_Default]
	@pInterfaceID int
as
/* =============================================
-- Author:		Matt Fraser
-- Create date: 9/11/2009
-- Parameters:	@pUseSCD	- Include all packages (1), T/R mode (0) or SCD mode (-1)
				@pPackageTypeID	- The package type ID
-- Purpose:		Return the most recently package with no parent package which has at least one record
				in the audit.ErrorLog table.
	Description:	Returns the logID for the most recently run package with any sort of an error.
-- Example:		audit.stp_Get_Packages_with_Errors_Default 1,1
-- Revisions:	MF	9/11/2009	1.0 Created
				MF	3/15/2011	1.2	Changed from TypeID to InterfaceID
-- =============================================*/
begin
	set nocount on;
	
	declare @temp table(logid int);
	
	insert into @temp
	select distinct logid from audit.ErrorLog;
	
	select LogID
	from audit.ExecutionLog
	where ParentLogID is null
	and interfaceid = @pInterfaceID
	and LogID in (select distinct audit.sf_GetExecutionLogRoot (logid) from @temp)
	
	union
	
	select 0
	order by logid desc;

	set nocount off;
end;
GO

/****** Object:  StoredProcedure [audit].[stp_Get_Packages_with_Errors]    Script Date: 03/23/2011 09:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [audit].[stp_Get_Packages_with_Errors]
	@pInterfaceID int
as
/* =============================================
-- Author:		Matt Fraser
-- Create date: 9/11/2009
-- Parameters:	@pUseSCD	- Include all packages (1), T/R mode (0) or SCD mode (-1)
				@pPackageTypeID	- The package type ID
-- Purpose:		Return a list of all packages with no parent package which have at least one record
				in the audit.ErrorLog table.
	Description:	Lists the package details for all "top level" packages which have records in the
					audit.errorlog table.  These packages are identified by looking for packages with 
					no parent package.  The parameter allows the list returned to be filtered to 
					either only packages run in the SCD or Truncate/Reload run modes or to include 
					all records.
-- Example:		audit.stp_Get_Packages_with_Errors 1,1
-- Revisions:	MF	9/11/2009	1.0 Created
				MF	9/15/2009	1.1	Added time to package name to help identify it from other runs of
									the package with the same name.
				MF	3/15/2011	1.2	Changed from TypeID to InterfaceID
-- =============================================*/
begin
	set nocount on;
	
	select LogID, PackageName + ' (' + CAST(starttime as varchar(30)) + ')' as label
	from audit.ExecutionLog
	where ParentLogID is null
	and interfaceid = @pInterfaceID
	and LogID in (select audit.sf_GetExecutionLogRoot (logid) from audit.ErrorLog)
	
	union
	
	select 0, 'All'
	order by logid desc;

	set nocount off;
end;
GO

/****** Object:  StoredProcedure [audit].[stp_Get_Packages_Error_Details]    Script Date: 03/23/2011 09:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [audit].[stp_Get_Packages_Error_Details]
	@pPackageLogID int
as
/* =============================================
-- Author:		Matt Fraser
-- Create date: 9/11/2009
-- Parameters:	@pPackageLogID	- The logID of the parent package
-- Purpose:		Return the details of all errors in the children in the chosen package execution.
	Description:	Lists the the details of all of the errors for the selected "parent" package
					and any child packages it may have.
-- Example:		audit.stp_Get_Packages_Error_Details 1234
-- Revisions:	MF	9/11/2009	1.0 Created
-- =============================================*/
begin
	set nocount on;
	
	if @pPackageLogID <> 0
	begin
		SELECT 
			[Package_Name]
			,[Parent_Task_Name]
			,[Source_Name]
			,[Target_Name]
			,[Lookup_Task_Name]
			,[Lookup_Table_Name]
			,[Lookup_Key_Columns]
			,[Source_Key_Columns]
			,[Source_Key_Values]
			,[SQL_Query]
			,[Error_Message]
			,cast(create_date as DATE) as daterun
			, COUNT(*) as errorcount
		FROM [audit].[ErrorLog] e inner join [audit].[tf_GetExecutionLogTree](@pPackageLogID,1) t
			on e.LogID = t.logid
		group by [Package_Name]
			,[Parent_Task_Name]
			,[Source_Name]
			,[Target_Name]
			,[Lookup_Task_Name]
			,[Lookup_Table_Name]
			,[Lookup_Key_Columns]
			,[Source_Key_Columns]
			,[Source_Key_Values]
			,[SQL_Query]
			,[Error_Message]
			,cast(create_date as DATE);
	end;
	else
	begin
		--Return all packages in table
		SELECT 
			[Package_Name]
			,[Parent_Task_Name]
			,[Source_Name]
			,[Target_Name]
			,[Lookup_Task_Name]
			,[Lookup_Table_Name]
			,[Lookup_Key_Columns]
			,[Source_Key_Columns]
			,[Source_Key_Values]
			,[SQL_Query]
			,[Error_Message]
			,cast(create_date as DATE) as daterun
			, COUNT(*) as errorcount
		FROM [audit].[ErrorLog]
		group by [Package_Name]
			,[Parent_Task_Name]
			,[Source_Name]
			,[Target_Name]
			,[Lookup_Task_Name]
			,[Lookup_Table_Name]
			,[Lookup_Key_Columns]
			,[Source_Key_Columns]
			,[Source_Key_Values]
			,[SQL_Query]
			,[Error_Message]
			,cast(create_date as DATE);
	end;

	set nocount off;
end;
GO

/****** Object:  UserDefinedFunction [audit].[tf_Progress]    Script Date: 03/23/2011 09:30:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [audit].[tf_Progress]()
returns table
--with execute as caller
as
/* =============================================
 Author:		??
 Create date: 	??
 Parameters:	None
 Returns:
 Purpose:		Getting the status of processes.
 Description:	This function returns the status of processes.
 Example:		select * from audit.uf_Progress()
 Revisions:		MF	7/24/2008	1.1	Changed LogicalDate to DateLastRan.  Added UseSCD column.
				MF	8/25/2008	1.2 Added sort and depth columns to enable better sorting and reporting
				MF	8/26/2008	1.3	Added runid column
								Added STAT Inserted to component names to be included
								Changed to select DISTICT rows
				MF	9/4/2008	1.4	Fixed display of T/R and SCD to be correct
				MF	10/27/2008	1.5	Added useSCD column.  Added seconds column.
				MF	1/24/2009	1.6	Added milliseconds to output.
				MF	1/27/2009	1.7	Removed seconds from output as they were redundant with milliseconds
									Removed minrps, meanrps, maxrps from output
									Added loadgroup column for grouping in report
									Changed OverallRps calc to use milliseconds and be divided by 1000.0
									Removed filter for Componentname, so now any component is valid
									Adjusted time to show hours as well as minutes and seconds
				MF	1/29/2009	1.8	Added TypeID column
				MF	3/15/2011	1.9	Changed TypeID to InterfaceID
				MF	3/17/2011	1.10	Removed DateLastRan column
 ============================================= */
return(
	with cte as (
		SELECT 
			 f.LogID 
			,f.ParentLogID
			,space(f.depth * 4) + f.PackageName as 'PackageName'
			,f.StartTime
			,f.EndTime
			,f.milliseconds
			,CONVERT(varchar(6), (f.milliseconds / 1000) / (3600) % 24) + ':' 
			+ RIGHT('0' + CONVERT(varchar(2), ((f.milliseconds / 1000) % 3600) / 60), 2) + ':' 
			+ RIGHT('0' + CONVERT(varchar(2), (f.milliseconds / 1000) % 60), 2) as 'Time'
			,case f.Status
				when 1 then 'OK'
				when 2 then 'Failed'
				else 'Processing'
			end as 'Status'
			,f.sort
			,f.loadgroup
			,f.depth
			,t.logid as runid
			,t.interfaceid
		from audit.ExecutionLog t
		cross apply audit.tf_GetExecutionLogTree(t.LogID, 0) f
		where t.ParentLogID is NULL
	)
	select distinct
		 c.LogID 
		,c.ParentLogID
		,c.PackageName
		,c.StartTime
		,c.EndTime
		,c.Status
		,s.ComponentName
		,s.Rows
		,c.[Time]
		,c.milliseconds
		,case when nullif(c.milliseconds/1000.0, 0) is null then null else s.Rows / (c.milliseconds / 1000.0) end as 'OverallRps'
		,c.sort
		,c.loadgroup
		,c.depth
		,c.runid
		,c.interfaceid
	from
		cte c
	left join 
		audit.StatisticLog s on c.LogID = s.LogID
)
GO

/****** Object:  StoredProcedure [audit].[stp_KART_Load_Status]    Script Date: 03/23/2011 09:30:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [audit].[stp_KART_Load_Status]
	@pRunID int
as
/* =============================================
-- Author:		Matt Fraser
-- Create date: 1/23/2009
-- Parameters:	None
-- Purpose:		Return package run details for all packages with the same package run ID.
	Description:	Lists the package details for all packages with the same package run ID
					which is the log ID of the top level parent package.
					The base of this query is the table function tf_Progress created by the
					ProjectREAL team.  That function was modified to suit our needs.
					The data returned includes the basic package run information as well as
					statistics comparing the current run to past runs.
					To compare to past package runs, the package is matched based on package
					name, component name and run mode.
-- Example:		audit.stp_Get_Package_Summary 1237
-- Revisions:	MF	3/10/2011	1.0 Created
				MF	3/15/2011	1.2	Changed from TypeID to InterfaceID.  Removed references to UseSCD and RunMode.
				MF	3/18/2011	1.3	Removed DateLastRan.
-- =============================================*/
begin
	set nocount on;
	
	/*This is the number of days back in history to look for determining averages when running in SCD mode.
	When running in T/R mode, look back 5 times further as this mode is only run once per week.*/
	declare @WindowDayLength int;
	
	set @WindowDayLength = 14;
	
	SELECT LogID, ParentLogID, p.PackageName,  StartTime, EndTime, [Status], p.ComponentName, [Rows], [Time], 
	p.milliseconds, OverallRps, depth, 
	avgrows, avgms, avgoverallrps, runid, p.interfaceid
	,CONVERT(varchar(6), (avgms / 1000) / (3600) % 24) + ':' 
			+ RIGHT('0' + CONVERT(varchar(2), ((avgms / 1000) % 3600) / 60), 2) + ':' 
			+ RIGHT('0' + CONVERT(varchar(2), (avgms / 1000) % 60), 2) as 'AvgTime'
	FROM [audit].[tf_Progress]() p left outer join
	(select packagename, componentname, interfaceid,
	avg(rows) avgrows, avg(datediff(ms, StartTime, EndTime)) avgms, util.fsafedivide(avg(rows) * 1.0 , avg(datediff(ms, StartTime, EndTime)) * 1000.0, 0) avgoverallrps
	from [audit].executionlog e left outer join [audit].statisticlog s
		on e.logid = s.logid
	where datediff(d, starttime, getdate()) <=   5 * @WindowDayLength 
		and e.status = 1
	group by packagename, componentname, interfaceid) t1
		on ltrim(p.packagename) = t1.packagename
			and (p.ComponentName  = t1.ComponentName
			or (p.ComponentName is null
			and t1.ComponentName is null))
			and p.interfaceid = t1.interfaceid
	where runid = @pRunID
	order by runid desc, sort, 
		case t1.componentname  
			when 'STAT Source' then 10 
			when 'STAT Temp' then 20 
			when 'STAT Updated' then 30 
			when 'STAT Inserted' then 40 
			when 'STAT Destination' then 50
			else 60
			end;

	set nocount off;
end;
GO

/****** Object:  StoredProcedure [audit].[stp_Get_Package_Summary]    Script Date: 03/23/2011 09:30:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [audit].[stp_Get_Package_Summary]
	@pRunID int
as
/* =============================================
-- Author:		Matt Fraser
-- Create date: 1/23/2009
-- Parameters:	@pRunID int	The log id of the overall parent package.
-- Purpose:		Return a list of all sub packages of the parent package.
	Description:	Lists the package details for all depth 1 packages of the parent
					package with the @pRunID parameter.
-- Example:		audit.stp_Get_Package_Summary 1237
-- Revisions:	MF	1/23/2009	1.0 Created
				MF	3/15/2011	1.1	Changed from TypeID to InterfaceID.  Removed reference to UseSCD
-- =============================================*/
begin
	set nocount on;
	
	/*This is the number of days back in history to look for determining averages when running in SCD mode.
	When running in T/R mode, look back 5 times further as this mode is only run once per week.*/
	declare @WindowDayLength int;
	
	set @WindowDayLength = 14;
	
	SELECT p.PackageName, StartTime, EndTime, [Status], [Time], p.milliseconds/1000.000 secs, avgms/1000.000 avgsecs, depth, runid, CONVERT(varchar(6), (avgms / 1000) / (3600) % 24) + ':' 
			+ RIGHT('0' + CONVERT(varchar(2), ((avgms / 1000) % 3600) / 60), 2) + ':' 
			+ RIGHT('0' + CONVERT(varchar(2), (avgms / 1000) % 60), 2) as 'AvgTime'
	FROM [audit].[tf_Progress]() p left outer join
	(select packagename, componentname,  
	avg(rows) avgrows, avg(datediff(ms, StartTime, EndTime)) avgms, avg(rows) * 1.0 / avg(datediff(ms, StartTime, EndTime)) * 1000 avgoverallrps
	from [audit].executionlog e left outer join [audit].statisticlog s
		on e.logid = s.logid
	where datediff(d, starttime, getdate()) <=  5 * @WindowDayLength
		and e.status = 1
	group by packagename, componentname) t1
		on ltrim(p.packagename) = t1.packagename
			and (p.ComponentName = t1.ComponentName
			or (p.ComponentName is null
			and t1.ComponentName is null))
	where runid = @pRunID
		and depth = 1
	order by runid desc, sort, 
		case t1.componentname  
			when 'STAT Source' then 10 
			when 'STAT Temp' then 20 
			when 'STAT Updated' then 30 
			when 'STAT Inserted' then 40 
			when 'STAT Destination' then 50
			else 60
			end;

	set nocount off;
end;
GO
