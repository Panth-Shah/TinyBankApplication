CREATE TABLE [dbo].[Address]
(
	[AddressId] INT NOT NULL PRIMARY KEY, 
    [CustomerId] INT NOT NULL, 
    [Address1] NVARCHAR(256) NULL, 
    [Address2] NVARCHAR(256) NULL,
	[Address3] NVARCHAR(256) NULL,
	[City] NVARCHAR(256) NULL,
	[ZipCode] CHAR(10) NULL,
	[StateId] INT NOT NULL,
	[LastUpdate] DATETIME NOT NULL DEFAULT GETDATE(), 
    [CreateDate] DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT [FK_Address_CustomerId] FOREIGN KEY ([CustomerId]) REFERENCES [Customer]([CustomerId]), 
    CONSTRAINT [FK_Address_StateId] FOREIGN KEY ([StateId]) REFERENCES [State]([StateId])
)
