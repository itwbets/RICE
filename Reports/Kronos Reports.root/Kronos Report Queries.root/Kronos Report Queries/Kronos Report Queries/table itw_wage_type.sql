SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[itw_wage_type](
	[wage_type_id] [int] IDENTITY(1,1) NOT NULL,
	[wage_type_code] [varchar](250) NOT NULL,
	[wage_type_name] [varchar](50) NOT NULL,
	[sort_order] [int] NOT NULL,
	[create_date] [datetime] NOT NULL,
	[update_date] [datetime] NOT NULL,
	[updated_by_user] [varchar](128) NOT NULL,
 CONSTRAINT [PK_itw_wage_type] PRIMARY KEY CLUSTERED 
(
	[wage_type_id] ASC
))

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[itw_wage_type] ADD  CONSTRAINT [DF_itw_wage_type_create_date]  DEFAULT (getdate()) FOR [create_date]
GO

ALTER TABLE [dbo].[itw_wage_type] ADD  CONSTRAINT [DF_itw_wage_type_update_date]  DEFAULT (getdate()) FOR [update_date]
GO

ALTER TABLE [dbo].[itw_wage_type] ADD  CONSTRAINT [DF_itw_wage_type_updated_by_user]  DEFAULT (suser_sname()) FOR [updated_by_user]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[TR_itw_wage_type]
   ON  [dbo].[itw_wage_type]
   AFTER INSERT, UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	IF NOT UPDATE(update_date)
	UPDATE dbo.itw_wage_type SET update_date = GETDATE() 
		FROM inserted i INNER JOIN dbo.itw_wage_type s
		ON i.wage_type_id = s.wage_type_id;
END;

GO


