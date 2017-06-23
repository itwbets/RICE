SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[itw_bu_hierarchy](
	[laborlevelentryid] [int] NULL,
	[divisionid] [int] NULL,
	[resort_code] [varchar](20) NULL,
	[resort_name] [varchar](100) NULL,
	[company_code] [varchar](20) NULL,
	[company_name] [varchar](100) NULL,
	[division_code] [varchar](20) NULL,
	[division_name] [varchar](100) NULL,
	[bu_code] [varchar](50) NOT NULL,
	[bu_desc] [varchar](100) NULL,
	[personnum] [varchar](15) NULL,
	[create_date] [datetime] NOT NULL)

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[itw_bu_hierarchy] ADD  CONSTRAINT [DF_itw_bu_hierarchy_create_date]  DEFAULT (getdate()) FOR [create_date]
GO


CREATE CLUSTERED INDEX [UK_itw_bu_hierarchy] ON [dbo].[itw_bu_hierarchy] 
(
	[personnum] ASC,
	[laborlevelentryid] ASC,
	[divisionid] ASC
)
GO


CREATE NONCLUSTERED INDEX [IX_itw_bu_hierarchy_personum_divisionid] ON [dbo].[itw_bu_hierarchy] 
(
	[personnum] ASC,
	[divisionid] ASC
)
GO


CREATE NONCLUSTERED INDEX [IX_itw_bu_hierarchy_laborlevelentryid] ON [dbo].[itw_bu_hierarchy] 
(
	[laborlevelentryid] ASC
)
GO
