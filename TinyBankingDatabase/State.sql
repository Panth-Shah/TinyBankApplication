﻿CREATE TABLE [dbo].[State]
(
	[StateId] TINYINT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	[AddressId] TINYINT NOT NULL,
    [Name] NVARCHAR(256) NOT NULL, 
    [Abbreviation] CHAR(2) NOT NULL, 
    [LastUpdate] DATETIME NOT NULL DEFAULT GETDATE(), 
    [CreateDate] DATETIME NOT NULL DEFAULT GETDATE(), 
    CONSTRAINT [FK_State_AddressId] FOREIGN KEY ([AddressId]) REFERENCES [Address]([AddressId])
);
