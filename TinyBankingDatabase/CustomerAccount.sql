CREATE TABLE [dbo].[CustomerAccount]
(
	[Id] INT NOT NULL PRIMARY KEY, 
    [CustomerId] INT NOT NULL, 
    [AccountId] INT NOT NULL, 
	[LastUpdate] DATETIME NOT NULL DEFAULT GETDATE(), 
    [CreateDate] DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT [FK_CustomerAccount_CustomerId] FOREIGN KEY ([CustomerId]) REFERENCES [Customer]([CustomerId]), 
    CONSTRAINT [FK_CustomerAccount_AccountId] FOREIGN KEY ([AccountId]) REFERENCES [Account]([AccountId])
);
