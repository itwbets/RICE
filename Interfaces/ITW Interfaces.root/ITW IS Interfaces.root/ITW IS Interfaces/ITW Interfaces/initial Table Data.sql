USE [Interface_Metadata]
GO

INSERT into [admin].[InterfaceConfiguration] ([InterfaceCode], [Description], [UNCRootFilePath], [EmailRecipients], [SendEmail], [ErrorEmailRecipients], [DateLastRan], [CompanyCode], [CurrencyCode]) 
VALUES 
(N'XXXXXXXXXX', N'Unknown Interface', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(N'IWKROTIJDE', N'Intrawest - Kronos Time to JDE', N'', N'interfaces@intrawest.com', 1, N'interfaces@intrawest.com', NULL, NULL, NULL)


INSERT [admin].[Configuration] ([ConfigurationFilter], [ConfiguredValue], [PackagePath], [ConfiguredValueType]) 
VALUES (N'Connections - Active Directory', N'Data Source=srv-van-dc01;Provider=ADsDSOObject;User ID=idirectory\Srv_ad;password=c7E25ie$S;', N'\Package.Connections[Active Directory].Properties[ConnectionString]', N'String'),
(N'Connections - ERPWEBAdmin', N'Data Source=sql05\prd;Initial Catalog=ERPWEBAdmin;Provider=SQLOLEDB.1;User ID=EWUser;password=pebbles;Persist Security Info=True;Auto Translate=False;', N'\Package.Connections[SQL01.ERPWEBAdmin].Properties[ConnectionString]', N'String'),
(N'Connections - JDE', N'Data Source=DEVDATA;User ID=infdev;password=zh3now34;Provider=MSDAORA.1;Persist Security Info=True;', N'\Package.Connections[JDE].Properties[ConnectionString]', N'String'),
(N'Connections - JDE (Attunity)', N'SERVER=DEVDATA;USERNAME=infdev;PASSWORD=zh3now34;ORACLEHOME=;ORACLEHOME64=;WINAUTH=0', N'\Package.Connections[JDE (Attunity)].Properties[ConnectionString]', N'String'),
(N'Connections - KART', N'Data Source=srv-ilab-krtdev;Integrated Security=SSPI;Connect Timeout=30;', N'\Package.Connections[KART].Properties[ConnectionString]', N'String'),
(N'Connections - KART_DW_Fin_Budget', N'Data Source=srv-ilab-krtdev;Initial Catalog=KART_DW_Fin_Budget;Provider=SQLOLEDB.1;Integrated Security=SSPI;Auto Translate=False;', N'\Package.Connections[KART DW Fin Budget].Properties[ConnectionString]', N'String'),
(N'Connections - KART_DW_Fin_Load', N'Data Source=srv-ilab-krtdev;Initial Catalog=KART_DW_Fin_Load;Provider=SQLOLEDB.1;Integrated Security=SSPI;Auto Translate=False;Application Name=SSIS-Load KPI-BU ids-{B055932D-4044-4A25-B39C-501B63DCF104}KART Transform;', N'\Package.Connections[KART DW Fin Load].Properties[ConnectionString]', N'String'),
(N'Connections - KART_DW_Fin_View', N'Data Source=srv-ilab-krtdev;Initial Catalog=KART_DW_Fin_View;Provider=SQLOLEDB.1;Integrated Security=SSPI;Auto Translate=False;', N'\Package.Connections[KART DW Fin View].Properties[ConnectionString]', N'String'),
(N'Connections - KART_Metadata .NET', N'Data Source=wsvan-126;Initial Catalog=Interface_Metadata;Provider=SQLOLEDB.1;Integrated Security=SSPI;Auto Translate=False;', N'\Package.Connections[Interface Metadata .NET].Properties[ConnectionString]', N'String'),
(N'Connections - KART_Staging', N'Data Source=srv-ilab-krtdev;Initial Catalog=KART_Staging;Provider=SQLOLEDB.1;Integrated Security=SSPI;Auto Translate=False;', N'\Package.Connections[KART Staging].Properties[ConnectionString]', N'String'),
(N'Connections - KART_Transform', N'Data Source=srv-ilab-krtdev;Initial Catalog=KART_Transform;Provider=SQLOLEDB.1;Integrated Security=SSPI;Auto Translate=False;', N'\Package.Connections[KART Transform].Properties[ConnectionString]', N'String'),
(N'Connections - Kronos', N'Data Source=sql11\itsm;User ID=kronosinterfaces;password=T1medInterfaces;Initial Catalog=TKCSReports;Provider=SQLOLEDB.1;Application Name=SSIS-KroTIJde-{d2fee6a6-fd99-410a-89dc-1d13fda3364f}Kronos;', N'\Package.Connections[Kronos].Properties[ConnectionString]', N'String'),
(N'Connections - SMTP', N'SmtpServer=smtp-relay.idirectory.itw;UseWindowsAuthentication=False;EnableSsl=False;', N'\Package.Connections[SMTP Connection Manager].Properties[ConnectionString]', N'String'),
(N'Connections - SVRDB', N'Data Source=sql05\prd;User ID=svr;password=Bordeau07$;Initial Catalog=SVRDB;Provider=SQLOLEDB.1;Persist Security Info=True;Auto Translate=False;', N'\Package.Connections[SVRDB].Properties[ConnectionString]', N'String'),
(N'EmailErrorAddress', N'interfaces@intrawest.com', N'\Package.Variables[User::g_strEmailGeneralErrorAddress].Properties[Value]', N'String'),
(N'EmailFromAddress', N'interfaces@intrawest.com', N'\Package.Variables[User::g_strEmailFromAddress].Properties[Value]', N'String'),
(N'EmailGeneralToAddress', N'interfaces@intrawest.com', N'\Package.Variables[User::g_strEmailGeneralToAddress].Properties[Value]', N'String'),
(N'Environment', N'Development', N'\Package.Variables[User::g_strEnvironment].Properties[Value]', N'String')
