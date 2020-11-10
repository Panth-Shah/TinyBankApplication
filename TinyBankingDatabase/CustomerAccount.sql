﻿CREATE TABLE [dbo].[CustomerAccount]
(
	[Id] TINYINT NOT NULL PRIMARY KEY IDENTITY, 
    [CustomerId] TINYINT NOT NULL, 
    [AccountId] TINYINT NOT NULL, 
	[LastUpdate] DATETIME NOT NULL DEFAULT GETDATE(), 
    [CreateDate] DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT [FK_CustomerAccount_CustomerId] FOREIGN KEY ([CustomerId]) REFERENCES [Customer]([CustomerId]), 
    CONSTRAINT [FK_CustomerAccount_AccountId] FOREIGN KEY ([AccountId]) REFERENCES [Account]([AccountId])
);
