CREATE TABLE [dbo].[Account]
(
	[AccountId] INT NOT NULL PRIMARY KEY, 
    [AccountNumber] INT NOT NULL, 
    [CurrentAccountBalance] DECIMAL(19, 4) NOT NULL, 
	[Active] BIT NOT NULL DEFAULT 1,
    [AccountTypeId] TINYINT NULL, 
	[AccountStatusId] TINYINT NULL,
	[LastUpdate] DATETIME NOT NULL DEFAULT GETDATE(), 
    [CreateDate] DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT [FK_AccountInformation_AccountType_Id] FOREIGN KEY ([AccountTypeId]) REFERENCES AccountType([AccountTypeId]), 
    CONSTRAINT [FK_Account_AccountStatusId] FOREIGN KEY ([AccountStatusId]) REFERENCES [AccountStatus]([AccountStatusId])
);
