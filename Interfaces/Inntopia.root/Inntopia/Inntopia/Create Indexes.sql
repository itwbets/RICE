USE [INTERFACE]
GO


DROP INDEX IX_CustomerPaymentsAdjustments_Transaction_ItineraryID ON [inntopia].[CUSTOMERPAYMENTSADJUSTMENTS_TRANSACTION]
GO

CREATE NONCLUSTERED INDEX IX_CustomerPaymentsAdjustments_Transaction_ItineraryID
ON [inntopia].[CUSTOMERPAYMENTSADJUSTMENTS_TRANSACTION] ([ItineraryID])
include (CustomerPaymentsAdjustments_TransactionID, gl_date, PaymentTypeCode, PaymentType, CreditCardType, account_string, INTERFACE_CODE, Total)
GO


DROP INDEX IX_CustomerPaymentsAdjustments_GLDate ON [inntopia].[CUSTOMERPAYMENTSADJUSTMENTS_TRANSACTION]
GO

CREATE NONCLUSTERED INDEX IX_CustomerPaymentsAdjustments_GLDate
ON [inntopia].[CUSTOMERPAYMENTSADJUSTMENTS_TRANSACTION] ([GL_DATE],[INTERFACE_CODE])
INCLUDE ([PaymentType],[PaymentTypeCode],[Total],[CustomerName],[CreditCardType],[ItineraryID],[ACCOUNT_STRING])


DROP INDEX IX_CustomerBillings_ItineraryID ON [inntopia].[CUSTOMERBILLINGS_TRANSACTION]
GO

CREATE NONCLUSTERED INDEX IX_CustomerBillings_ItineraryID
ON [inntopia].[CUSTOMERBILLINGS_TRANSACTION] ([ItineraryID])
include (CustomerBillings_TransactionID, gl_date, CustomerName, AcctgCategory2, INTERFACE_CODE, Total)
GO


DROP INDEX IX_Customer_Billings_GLDate ON [inntopia].[CUSTOMERBILLINGS_TRANSACTION]
GO

CREATE NONCLUSTERED INDEX IX_Customer_Billings_GLDate
ON [inntopia].[CUSTOMERBILLINGS_TRANSACTION] ([GL_DATE],[INTERFACE_CODE])
INCLUDE ([Total],[CustomerName],[ItineraryID],[AcctgCategory2])


DROP INDEX IX_CustomerPaymentsAdjustmentsApplied_Allocation_SupplierID ON [inntopia].[CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_ALLOCATION]
GO

CREATE NONCLUSTERED INDEX IX_CustomerPaymentsAdjustmentsApplied_Allocation_SupplierID
ON [inntopia].[CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_ALLOCATION] ([SupplierID])
INCLUDE ([FK_Transaction],[SupplierName],[AppliedAmount],[AcctgCategory2])


DROP INDEX IX_CustomerPaymentsAdjustmentsApplied_Allocation_FK_Transaction ON [inntopia].[CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_ALLOCATION]
GO

CREATE NONCLUSTERED INDEX IX_CustomerPaymentsAdjustmentsApplied_Allocation_FK_Transaction
ON [inntopia].[CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_ALLOCATION] ([FK_Transaction])
INCLUDE ([SupplierID],[SupplierName],[AppliedAmount],[AcctgCategory2])


DROP INDEX IX_CustomerPaymentsAdjustmentsApplied_Transaction_ItineraryID ON [inntopia].[CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_Transaction]
GO

CREATE NONCLUSTERED INDEX [IX_CustomerPaymentsAdjustmentsApplied_Transaction_ItineraryID] ON [inntopia].[CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_TRANSACTION]
([ItineraryID] ASC)
INCLUDE ([GL_DATE],[INTERFACE_CODE], [XPK_Transaction])
GO


DROP INDEX IX_CustomerPaymentsAdjustmentsApplied_Transaction_GLDate ON [inntopia].[CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_Transaction]
GO

CREATE NONCLUSTERED INDEX IX_CustomerPaymentsAdjustmentsApplied_Transaction_GLDate
ON [inntopia].[CUSTOMERPAYMENTSADJUSTMENTSAPPLIED_TRANSACTION] ([GL_DATE],[INTERFACE_CODE])
INCLUDE ([XPK_Transaction])
