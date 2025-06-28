# Financial-Database-Insights-Using-SQL
A real-world SQL project exploring a relational banking dataset using MySQL. Includes ER modeling, data cleaning, analytical queries, and insights on customer behavior, loans, and transactions.

## Project Overview
This project demonstrates the implementation of a  Financial Database Insights using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.


![image](https://github.com/user-attachments/assets/6a42b9ae-7402-4200-ac95-cd48db294098)

## Objective
The objective of this project is to explore and analyze a real-world financial (banking) relational database using SQL. This includes:

- Designing a clear ER (Entity-Relationship) model

- Database Setup by Creating and populating the database with tables for account, card, district, client, loan, trans, disp, order.

- Cleaning and structuring data with foreign key constraints

- Writing SQL queries to extract insights on customers, accounts, transactions, loans, and defaults

- Identifying patterns in financial behavior such as withdrawal frequency, loan default rates, and account activity

- Practicing advanced SQL techniques like CTEs, aggregations, window functions, and multi-step query logic

## `Project Structure`

###  Database ER daigram 

![ER Daigram](https://github.com/user-attachments/assets/2fb64637-3b2c-4d92-b88b-09ff6ce228b9)


###  Database Setup
- **Database Creation** : Created a database named `finance`.
- **Table Creation** : Created tables for account, card, district, client, loan, trans, disp, order.


```sql
CREATE DATABASE IF NOT EXISTS Finance;

USE Finance;



CREATE TABLE account (
	account_id  INTEGER PRIMARY KEY,
	district_id  INTEGER,
	fee_frequency VARCHAR(30),
	created_date DATE
    -- FOREIGN KEY (district_id) REFERENCES  district(district_id)
);

CREATE TABLE card (
    card_id INT PRIMARY KEY,
    disp_id INT,
    card_type VARCHAR(20),   -- e.g., classic, gold
    issued_date DATE
    -- FOREIGN KEY (disp_id) REFERENCES disp(disp_id)
);

CREATE TABLE district (
	district_id INT PRIMARY KEY,
    district_name VARCHAR(100),
    region VARCHAR(100),
    inhabitants INT,
    with_inhabitants_lt_500 INT,
	with_inhabitants_500_1999 INT,
    with_inhabitants_2000_9999 INT,
    with_inhabitants_gt_10000 INT,
    num_cities INT,
    urban_ratio_percent FLOAT,
    avg_salary_czk FLOAT,
    unemploy_rate_95 FLOAT,
    unemploy_rate_96 FLOAT,
    entrepreneurs_per_1000 FLOAT,
    num_crimes INT,
    num_solved_crimes INT
);

CREATE TABLE client (
	client_id INT PRIMARY KEY,
    gender CHAR(1),
    birth_date DATE,
    district_id INT
    -- FOREIGN KEY (district_id) REFERENCES district(district_id)
);

CREATE TABLE disp (
	disp_id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT,
    account_id INT,
    disp_type ENUM('OWNER','DISPONENT')
    -- FOREIGN KEY (client_id) REFERENCES client(client_id),
    -- FOREIGN KEY (account_id) REFERENCES account(account_id)
);


CREATE TABLE orders (
	order_id INT PRIMARY KEY,
    account_id INT,
    bank_to VARCHAR(20),
    account_to INT,
	amount FLOAT,
    payment_type VARCHAR(20)  -- k_symbol,transaction purpose
    -- FOREIGN KEY (account_id) REFERENCES account(account_id)
);

CREATE TABLE loan (
	loan_id INT PRIMARY KEY,
    account_id INT,
    loan_date DATE,
    amount FLOAT,
    duration INT,  -- in months
    payments FLOAT,  -- monthly payment (emi)
    loan_status CHAR(1)
    -- FOREIGN KEY (account_id) REFERENCES account(account_id)
);

CREATE TABLE trans (
	 trans_id INT PRIMARY KEY,
     account_id INT,
     trans_date DATE,
     trans_type VARCHAR(20),
     processing_method VARCHAR(50),  -- operation
     amount FLOAT,
     balance FLOAT,
     payment_type VARCHAR(20), -- k_symbol
     bank_code VARCHAR(20),
     target_account INT
     -- FOREIGN KEY (account_id) REFERENCES account(account_id)
);
---


### Updating

```sql
use finance;
set sql_safe_updates = 0;
UPDATE orders
SET payment_type = CASE
    WHEN payment_type = 'SIPO' THEN 'Household Bills'
    WHEN payment_type = 'LEASING' THEN 'Leasing Payment'
    WHEN payment_type = 'POJISTNE' THEN 'Insurance Payment'
    WHEN payment_type = 'UVER' THEN 'Loan payment'
    WHEN payment_type = '' AND payment_type IS NULL THEN 'No detail'
    ELSE payment_type
END;


UPDATE account
SET fee_frequency = CASE
    WHEN fee_frequency = 'POPLATEK MESICNE' THEN 'Monthly Fee'
    WHEN fee_frequency = 'POPLATEK TYDNE' THEN 'Weekly Fee'
    WHEN fee_frequency = 'POPLATEK PO OBRATU' THEN 'Fee Per Transaction'
    ELSE fee_frequency
END;

UPDATE trans
SET trans_type = CASE
    WHEN trans_type = 'PRIJEM' THEN 'Credit'
    WHEN trans_type = 'VYDAJ' THEN 'Withdrawal'
    WHEN trans_type = 'VYBER' THEN 'Cash Withdrawal'
    ELSE trans_type
END;

UPDATE trans
SET payment_type = CASE
    WHEN payment_type = 'SIPO' THEN 'Household Bills'
    WHEN payment_type = 'SLUZBY' THEN 'Services'
    WHEN payment_type = 'UVER' THEN 'Loan Repayment'
    WHEN payment_type = 'POJISTNE' THEN 'Insurance'
    WHEN payment_type = 'DUCHOD' THEN 'Pension'
    ELSE payment_type
END;


UPDATE trans
SET trans_type = 'Withdrawal'
WHERE trans_type = 'Cash Withdrawal';
 
ALTER TABLE trans
DROP COLUMN processing_method;


UPDATE trans
SET payment_type = 'No Detail'
WHERE payment_type = '' OR payment_type IS NULL;

---

### Updating Constraints

```sql
-- For 'orders' table
ALTER TABLE orders
ADD CONSTRAINT fk_orders_account
FOREIGN KEY (account_id) REFERENCES account(account_id);

-- For 'loan' table
ALTER TABLE loan
ADD CONSTRAINT fk_loan_account
FOREIGN KEY (account_id) REFERENCES account(account_id);

-- For 'trans' table
ALTER TABLE trans
ADD CONSTRAINT fk_trans_account
FOREIGN KEY (account_id) REFERENCES account(account_id);

ALTER TABLE card
ADD CONSTRAINT fk_card_disp
FOREIGN KEY (disp_id) REFERENCES disp(disp_id);

ALTER TABLE client
ADD CONSTRAINT fk_clint_district
FOREIGN KEY (district_id) REFERENCES district(district_id);

ALTER TABLE disp
ADD CONSTRAINT fk_disp_client
FOREIGN KEY (client_id) REFERENCES client(client_id),
ADD CONSTRAINT fk_disp_account
FOREIGN KEY (account_id) REFERENCES account(account_id);

ALTER TABLE account
ADD CONSTRAINT fk_account_district
FOREIGN KEY (district_id) REFERENCES district(district_id);

DELETE FROM card
WHERE disp_id NOT IN (
    SELECT disp_id FROM disp
);

DELETE FROM loan
WHERE account_id NOT IN (
    SELECT account_id FROM account
);
---
