SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Shah, Panth
-- Create date: November, 09 2020
-- Description:	Balance Transfer SQL Procedure
-- =============================================
--2.1 Write SQL, that will move $X from account number #1 to account #2. Assume that account #1 has at least X dollars.  
--2.2 Change the SQL code to ensure that balance will never be < 0 and only do transfer if it is possible. Make sure the code is thread-safe and efficient. 
----Do not use constraints unless you see no other way

CREATE PROCEDURE AccountBalanceTransfer
	@CustomerId INT NOT NULL,
	@MoveFromAccountId INT NOT NULL,
	@MoveToAccountId INT NOT NULL,
	@AmountRequested DECIMAL NOT NULL
AS

DECLARE @FromAccountBalance decimal,
		@ToAccountBalance decimal,
		@RetryCount bit;

DECLARE @CustomerAccountInformation TABLE
	(
		Row# INT NOT NULL identity(1,1) PRIMARY KEY,
		CustomerId INT NOT NULL,
		AccountId INT NOT NULL,
		CurrentAccountBalance DECIMAL NOT NULL,
		IsActive BIT NOT NULL
	)

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO @CustomerAccountInformation
	SELECT C.CustomerId, A.AccountId, A.CurrentAccountBalance, A.Active 
	FROM [dbo].[Customer] C INNER JOIN
	[dbo].[CustomerAccount] CA ON C.CustomerId = CA.CustomerId
	INNER JOIN [dbo].[Account] A ON CA.AccountId = A.AccountId

	SELECT @FromAccountBalance = A.CurrentAccountBalance 
		FROM @CustomerAccountInformation A WHERE AccountId = @MoveFromAccountId
END

RETRY:
IF @FromAccountBalance - @AmountRequested >= 0
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY
			--Deposite money to Account 2
			UPDATE @CustomerAccountInformation
			SET CurrentAccountBalance = CurrentAccountBalance + @AmountRequested
			WHERE AccountId = @MoveToAccountId

			--Withdraw money from Account 1
			UPDATE @CustomerAccountInformation
			SET CurrentAccountBalance = CurrentAccountBalance - @AmountRequested
			WHERE AccountId = @MoveFromAccountId

			--Update Account table with changes in CurrentAccountBalance
			--Q: How is this Merge Thread Safe?
			--Ans: Merge is an atomic DML, meaning that either all changes are commited or all changed are rolled back.
			-------In contrast to multi-statement conditional INSERT/UPDATE method, no explicite transaction is reuqired for Merge.
			-------However, we still will be needing HOLDLOCK to prevent duplicate keys in case of high concurrency.
			MERGE [dbo].[Account] WITH (HOLDLOCK) AS A
				USING @CustomerAccountInformation AS CA
			ON (CA.AccountId = A.AccountId)
			WHEN MATCHED
				THEN UPDATE SET
					A.CurrentAccountBalance = CA.CurrentAccountBalance,
					A.LastUpdate = GETDATE();

			COMMIT TRANSACTION
			--Raise Success Message upon completion
			RAISERROR ('Fund Trasfer Successful', 10, 1);
			RETURN 0;
		END TRY
		BEGIN CATCH
			PRINT '-------Rollback Transaction-------'
			IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
			--If Deadlock, try to resolve it 5 times before completely failing
			IF ERROR_NUMBER() = 1205
			BEGIN
				SET @RetryCount = @RetryCount + 1
			END
			IF @RetryCount <= 5
			BEGIN
				GOTO RETRY
			END
			ELSE
			BEGIN
				--Raise Error Message upon failure
				DECLARE @ErrMsg AS NVARCHAR(4000) = '',
					@ErrSeverity AS INT = 0,
					@ErrState AS INT = 0;

				SELECT @ErrMsg = ERROR_MESSAGE(), 
						@ErrSeverity = ERROR_SEVERITY(), 
						@ErrState = ERROR_STATE();

				RAISERROR (@ErrMsg, @ErrSeverity, @ErrState);
				PRINT 'Deadlock not resolved after 5 attempts'
			END
		END CATCH
	END
GO
 
