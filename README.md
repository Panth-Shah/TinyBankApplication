# TinyBankApplication

Design Tiny Bank Application

1) Design database
Design a database to store a person’s bank account holding, for a very tiny, imaginary bank
This is the information that must be stored: 
•	Person’s Name (string) 
•	Account Numbers (integer) 
•	Account balances (ie amount of money in the account)

2) Write SQL 
Pseudo code or actual SQL is possible for this. SQL Preferred but exact syntax not important. 
  2.1 ) Write SQL, that will move $X from account number #1 to account #2. Assume that account #1 has at least X dollars.  
  2.2) Change the SQL code to ensure that balance will never be < 0 and only do transfer if it is possible. Make sure the code is thread-safe and efficient. 
       Explain how this code is thread-safe
       
3) Add customer address
  3.1) Add table that stores 0 or more addresses for a customer.  
  Write SQL to: 
  3.2) show all customers with all their addresses, multiple rows per customer is fine 
  3.3) show all customers, with their addresses, even those that do not have an address 
  3.4) delete a particular address for a particular customer 

4) Design an API
  Design a REST api for this imaginary bank you created.
  You can do this anyway you like; you can send a simple text based specification of the API, actual .NET code, or pseudo code. If you do not believe REST is the right style, feel free to do it differently with a justification. Here is an example of acceptable style and level of detail: https://petstore.swagger.io/#/
