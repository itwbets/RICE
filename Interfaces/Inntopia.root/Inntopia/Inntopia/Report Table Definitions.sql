use INTERFACE
go

IF OBJECT_ID('INNTOPIA.CUSTOMERPAYMENTSADJUSTMENTS_TRANSACTION') IS NOT NULL
	DROP TABLE INNTOPIA.CUSTOMERPAYMENTSADJUSTMENTS_TRANSACTION
GO

CREATE TABLE INNTOPIA.CUSTOMERPAYMENTSADJUSTMENTS_TRANSACTION
(
    CustomerPaymentsAdjustments_TransactionID INT IDENTITY(1,1) CONSTRAINT PK_CustomerPaymentsAdjustments_Transaction PRIMARY KEY,
	XPK_Transaction                bigint NOT NULL,
    TransactionID                  int,
    TransactionDate                datetime,
    TransactionType                varchar(100),
    TransactionTypeCode            tinyint,
    PaymentType                    varchar(100),
    PaymentTypeCode                smallint,
    CurrencyCode                   varchar(3),
    Total                          decimal(18,9),
    Applied                        decimal(18,9),
    Balance                        decimal(18,9),
    ChannelID                      int,
    Channel                        varchar(150),
    CustomerID                     int,
    CustomerName                   nvarchar(100),
    TransferSupplierID             int,
    TransferSupplier               varchar(150),
    MerchantAccount                varchar(20),
    CreditCardType                 varchar(2),
    CreditCardNumberMasked         varchar(22),
    CreditCardAppprovalCode        varchar(16),
    CreditCardChargeTimeStamp      datetime,
    ItineraryID                    int,
    RSysSupplierId                 int,
    AcctgCategory                  varchar(50),
    AcctgCategoryDescription       varchar(50),
    AcctgCategory2                 varchar(50),
    AcctgCategory2Description      varchar(50),
    LastModifyTimeStamp            datetime,
    RecordTimeStamp                datetime,
	ACCOUNT_STRING VARCHAR(150),
	INTERFACE_CODE CHAR(10),
	BATCH_ID	INT,
	GL_DATE DATE,
	START_TIME DATETIME DEFAULT (GETDATE())
)
GO

CREATE index IX_CustomerPaymentsAdjustments_Transaction ON INNTOPIA.CUSTOMERPAYMENTSADJUSTMENTS_TRANSACTION (XPK_Transaction)
GO



IF OBJECT_ID('INNTOPIA.CUSTOMERPAYMENTSADJUSTMENTS_ALLOCATION') IS NOT NULL
	DROP TABLE INNTOPIA.CUSTOMERPAYMENTSADJUSTMENTS_ALLOCATION
GO

CREATE TABLE INNTOPIA.CUSTOMERPAYMENTSADJUSTMENTS_ALLOCATION
(
    CustomerPaymentsAdjustments_AllocationID INT IDENTITY(1,1) CONSTRAINT PK_CustomerPaymentsAdjustments_Allocation PRIMARY KEY,
	XPK_Allocation             bigint NOT NULL,
    FK_Transaction             bigint,
    SupplierID                 int,
    SupplierName               varchar(150),
    AppliedAmount              decimal(18,9),
    TransactionDate           datetime,
    DueDate                    datetime,
    DepositScheduleID          int,
    DepositItemID              tinyint,
    TotalAmount                decimal(18,9),
    Balance                   decimal(18,9),
    TransactionID             int,
    RSysSupplierId            int,
    AcctgCategory             varchar(50),
    AcctgCategoryDescription  varchar(50),
    AcctgCategory2             varchar(50),
    AcctgCategory2Description varchar(50),
	INTERFACE_CODE CHAR(10),
	BATCH_ID	INT,
	GL_DATE DATE,
	START_TIME DATETIME DEFAULT (GETDATE())
)
GO
CREATE INDEX IX_CustomerPaymentsAdjustments_Allocation ON INNTOPIA.CustomerPaymentsAdjustments_Allocation (XPK_Allocation);
GO


IF OBJECT_ID('INNTOPIA.CUSTOMERBILLINGS_TRANSACTION') IS NOT NULL
	DROP TABLE INNTOPIA.CUSTOMERBILLINGS_TRANSACTION
GO

CREATE TABLE INNTOPIA.CUSTOMERBILLINGS_TRANSACTION
(
    CustomerBillings_TransactionID INT IDENTITY(1,1) CONSTRAINT PK_CustomerBillings_Transaction PRIMARY KEY,
	XPK_Transaction           bigint NOT NULL,
    TransactionID             int,
    TransactionDate           datetime,
    TransactionType           varchar(100),
    TransactionTypeCode       tinyint,
    CurrencyCode              varchar(3),
    Total                     decimal(18,9),
    Applied                   decimal(18,9),
    Balance                   decimal(18,9),
    Price                     decimal(18,9),
    Fees                      decimal(18,9),
    Taxes                     decimal(18,9),
    NetPrice                  decimal(18,9),
    NetFees                   decimal(18,9),
    NetTaxes                  decimal(18,9),
    DueDate                   datetime,
    ChannelID                 int,
    Channel                   varchar(150),
    CustomerID                int,
    CustomerName              nvarchar(100),
    SupplierID                int,
    Supplier                  varchar(150),
    SupplierCategoryCode      smallint,
    SupplierCategory          varchar(255),
    ItineraryID               int,
    PackageID                 int,
    PackageName               varchar(100),
    DepositScheduleID         int,
    DepositScheduleItemID     tinyint,
    DepositNotRefundableFlag  bit,
    HoldFlag                  bit,
    SupplierRateCurrency      varchar(3),
    ExchangeRate              decimal(18,9),
    RSysSupplierId            int,
    AcctgCategory             varchar(50),
    AcctgCategoryDescription  varchar(50),
    AcctgCategory2            varchar(50),
    AcctgCategory2Description varchar(50),
    LastModifyTimeStamp       datetime,
    RecordTimeStamp           datetime,
	INTERFACE_CODE CHAR(10),
	BATCH_ID	INT,
	GL_DATE DATE,
	START_TIME DATETIME DEFAULT (GETDATE())
)
GO

CREATE INDEX IX_CustomerBillings_Transaction ON INNTOPIA.CustomerBillings_Transaction (XPK_Transaction);
GO


IF OBJECT_ID('INNTOPIA.CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_TRANSACTION') IS NOT NULL
	DROP TABLE INNTOPIA.CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_TRANSACTION
GO

CREATE TABLE INNTOPIA.CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_TRANSACTION
(
    CustomerPaymentsAdjustmentsApplied_TransactionID INT IDENTITY(1,1) CONSTRAINT PK_CustomerPaymentsAdjustmentsApplied_Transaction PRIMARY KEY,
	XPK_Transaction                       bigint NOT NULL,
    TransactionID                         int,
    TransactionDate                       datetime,
    TransactionType                       varchar(100),
    TransactionTypeCode                   tinyint,
    PaymentType                           varchar(100),
    PaymentTypeCode                       smallint,
    CurrencyCode                          varchar(3),
    AppliedTotal                          decimal(18,9),
    Total                                 decimal(18,9),
    ChannelID                             int,
    Channel                               varchar(150),
    CustomerID                            int,
    CustomerName                          nvarchar(100),
    MerchantAccount                       varchar(20),
    CreditCardType                        varchar(2),
    CreditCardNumberMasked                varchar(22),
    CreditCardAppprovalCode               varchar(16),
    CreditCardChargeTimeStamp             datetime,
    TransferSupplierID                    int,
    TransferSupplier                      varchar(150),
    ItineraryID                           int,
    RSysSupplierId                        int,
    AcctgCategory                         varchar(50),
    AcctgCategory2Description             varchar(50),
    AcctgCategory2                        varchar(50),
    AcctgCategoryDescription              varchar(50),
    RecordTimeStamp                       datetime,
    LastModifyTimeStamp                   datetime,
	PostTransDate bit,
	INTERFACE_CODE CHAR(10),
	BATCH_ID	INT,
	GL_DATE DATE,
	START_TIME DATETIME DEFAULT (GETDATE())
)
GO

CREATE INDEX IX_CustomerPaymentsAdjustmentsApplied_Transaction ON INNTOPIA.CustomerPaymentsAdjustmentsApplied_Transaction (XPK_Transaction);
GO


IF OBJECT_ID('INNTOPIA.CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_ALLOCATION') IS NOT NULL
	DROP TABLE INNTOPIA.CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_ALLOCATION
GO

CREATE TABLE INNTOPIA.CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_ALLOCATION
(
    CustomerPaymentsAdjustmentsApplied_AllocationID INT IDENTITY(1,1) CONSTRAINT PK_CustomerPaymentsAdjustmentsApplied_Allocation PRIMARY KEY,
	XPK_Allocation                  bigint NOT NULL,
    FK_Transaction                  bigint,
    SupplierID                      int,
    SupplierName                    varchar(150),
    AppliedAmount                   decimal(18,9),
    AppliedDate                     datetime,
    TransactionDate           datetime,
    DueDate                         datetime,
    DepositScheduleID               int,
    DepositItemID                   tinyint,
    TotalAmount                     decimal(18,9),
    Balance                         decimal(18,9),
    TransactionID             int,
    RSysSupplierId            int,
    AcctgCategory             varchar(50),
    AcctgCategoryDescription  varchar(50),
    AcctgCategory2            varchar(50),
    AcctgCategory2Description varchar(50),
	INTERFACE_CODE CHAR(10),
	BATCH_ID	INT,
	GL_DATE DATE,
	START_TIME DATETIME DEFAULT (GETDATE())
)
GO

CREATE INDEX IX_CustomerPaymentsAdjustmentsApplied_Allocation ON INNTOPIA.CustomerPaymentsAdjustmentsApplied_Allocation (XPK_Allocation);
GO



IF OBJECT_ID('INNTOPIA.ACCOUNTSRECEIVABLEBILLINGSCREDITS_TRANSACTION') IS NOT NULL
	DROP TABLE INNTOPIA.ACCOUNTSRECEIVABLEBILLINGSCREDITS_TRANSACTION
GO

CREATE TABLE INNTOPIA.ACCOUNTSRECEIVABLEBILLINGSCREDITS_TRANSACTION
(
    AccountsReceivableBillingsCredits_TransactionID INT IDENTITY(1,1) CONSTRAINT PK_AccountsReceivableBillingsCredits_Transaction PRIMARY KEY,
	XPK_Transaction           bigint NOT NULL,
    TransactionID	int,
	BilledID	int,
	BIlledName	varchar(150),
	SupplierID	int,
	SupplierName	varchar(150),
	TransactionDate	smalldatetime,
	DueDate	smalldatetime,
	TransactionTypeCode	tinyint,
	TransactionType	varchar(100),
	BillingTypeCode	tinyint,
	BillingType	varchar(100),
	Currency	varchar(3),
	BookingCurrency	varchar(3),
	ExchangeRate	decimal(9,5),
	CommissionableBase	smallmoney,
	CommissionableFees	smallmoney,
	CommissionableTotal	smallmoney,
	BaseCommission	smallmoney,
	Taxes	smallmoney,
	TotalBilled	smallmoney,
	Applied	smallmoney,
	UnappliedBalance	smallmoney,
	ItineraryID	int,
	ChannelID	int,
	Channel 	varchar(150),
	SupplierCategoryCode	smallint,
	SupplierCategory	varchar(255),
	CustomerID	int,
	CustomerName	nvarchar(100),
	BIlledItemCount	tinyint,
	ArrivalDate	smalldatetime,
	DepartureDate	smalldatetime,
	RecordTimeStamp	datetime,
	LastModifyTimeStamp	datetime,
	RSysSupplierId	Int,
	AcctgCategory	varchar(50),
	AcctgCategoryDescription	varchar(50),
	AcctgCategory2	varchar(50),
	AcctgCategory2Description	varchar(50),
	INTERFACE_CODE CHAR(10),
	BATCH_ID	INT,
	GL_DATE DATE,
	START_TIME DATETIME DEFAULT (GETDATE())
)
GO

CREATE INDEX IX_AccountsReceivableBillingsCredits_Transaction ON INNTOPIA.AccountsReceivableBillingsCredits_Transaction (XPK_Transaction);
GO
