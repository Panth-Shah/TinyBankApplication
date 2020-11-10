-- =============================================
-- Author:		Shah, Panth
-- Create date: November, 09 2020
-- Description:	Add Customer Address
-- =============================================
USE [BankingDatabase]
GO
--3.2: Show all Customers with all their addresses, multiple rows per customer is fine

SELECT * FROM [dbo].[Customer] C
INNER JOIN [dbo].[Address] AD ON C.CustomerId = AD.CustomerId
GO

--3.3: Show all customers, with their address, even that do not have an address
SELECT * FROM [dbo].[Customer] C
LEFT JOIN [dbo].[Address] AD ON C.CustomerId = AD.CustomerId
GO

--3.4 Delete a particular address for a particular customer
DELETE FROM [dbo].[Address]
	WHERE CustomerId = (SELECT CustomerId FROM [dbo].[Customer] WHERE CustomerFirstName = 'Alex');
GO
