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
		@RetryCount bit = 0;

RETRY:
	BEGIN TRY
		BEGIN TRANSACTION
			BEGIN
				SELECT @FromAccountBalance = A.CurrentAccountBalance
				FROM [dbo].[Account] A
				WITH(XLOCK, ROWLOCK)
				WHERE A.AccountId = @MoveFromAccountId

				SELECT @ToAccountBalance = A.CurrentAccountBalance
				FROM [dbo].[Account] A
				WITH(XLOCK, ROWLOCK)
				WHERE A.AccountId = @MoveToAccountId
			END
			IF @FromAccountBalance - @AmountRequested >= 0
				BEGIN
					UPDATE [dbo].[Account]
					SET CurrentAccountBalance = CurrentAccountBalance - @AmountRequested
					WHERE AccountId = @MoveFromAccountId

					UPDATE [dbo].[Account]
					SET CurrentAccountBalance = CurrentAccountBalance + @AmountRequested
					WHERE AccountId = @MoveToAccountId

					COMMIT TRANSACTION
					RAISERROR ('Fund Trasfer Success', 10, 1);
				END
			ELSE
			BEGIN
				--Raise Failed Message upon rollback
				RAISERROR ('Fund Trasfer Failed', 10, 1);
				IF @@TRANCOUNT > 0 
					ROLLBACK TRANSACTION
			END
	END TRY
	BEGIN CATCH
		PRINT '-------Rollback Transaction-------'
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
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
GO