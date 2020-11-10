CREATE TABLE [dbo].[CustomerAccount]
(
	[Id] TINYINT NOT NULL IDENTITY(1,1) PRIMARY KEY, 
    [CustomerId] TINYINT NOT NULL, 
    [AccountId] TINYINT NOT NULL, 
	[LastUpdate] DATETIME NOT NULL DEFAULT GETDATE(), 
    [CreateDate] DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT [FK_CustomerAccount_CustomerId] FOREIGN KEY ([CustomerId]) REFERENCES [Customer]([CustomerId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_CustomerAccount_AccountId] FOREIGN KEY ([AccountId]) REFERENCES [Account]([AccountId]) ON DELETE CASCADE
);
