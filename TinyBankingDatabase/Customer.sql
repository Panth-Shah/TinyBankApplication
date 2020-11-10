﻿CREATE TABLE [dbo].[Customer]
(
	[CustomerId] INT NOT NULL PRIMARY KEY, 
    [CustomerFirstName] NVARCHAR(256) NOT NULL,
	[CustomerMiddleName] NVARCHAR(50) NULL,
    [CustomerLastName] NVARCHAR(256) NULL, 
	[PhoneNumber] CHAR(10) NULL,
	[FaxNumber] CHAR(10) NULL,
	[EmailAddress] NVARCHAR(50) NULL,
    [CreateDate] DATETIME NOT NULL DEFAULT GETDATE(), 
    [LastUpdate] DATETIME NOT NULL DEFAULT GETDATE()
);
