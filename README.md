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
```


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
```


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
```

### basic questions
```sql
-- 1. Count total clients per district
SELECT district_id, count(*) as no_of_clients FROM finance.client
GROUP BY district_id;

-- 2. List all accounts opened in the year 1997
SELECT * FROM account
WHERE YEAR(created_date) = 1997;

-- 3. Show number of cards issued per card type
SELECT card_type, COUNT(*) no_of_cards FROM card
GROUP BY card_type;

-- 4. Find the average loan amount by loan status
SELECT loan_status, avg(amount) FROM loan GROUP BY loan_status;

-- 5. List top 5 districts with highest average salary
SELECT district_id,district_name,avg_salary_czk FROM district ORDER BY avg_salary_czk DESC LIMIT 5;
```

### intermediate questions
```sql
-- 1. Total number of clients with a loan
SELECT DISTINCT(count(*)) FROM client c
JOIN disp d ON c.client_id = d.client_id
JOIN account a ON a.account_id = d.account_id
JOIN loan l ON a.account_id = l.account_id;

-- 2. Average monthly transaction amount per account
SELECT DATE_FORMAT(trans_date, '%Y-%m') AS month,
       ROUND(AVG(amount)) AS avg_monthly_trans
FROM trans
GROUP BY DATE_FORMAT(trans_date, '%Y-%m')
ORDER BY month;


-- 3. Identify accounts with more withdrawals than credits
SELECT account_id, trans_type, total_trans FROM (SELECT *,count(*) total_trans,
RANK() OVER(partition by account_id order by count(*) desc) as 'rnk'
FROM trans
GROUP BY account_id,trans_type) t
WHERE rnk = 1 and trans_type = 'Withdrawal';

WITH trans_summary AS (
  SELECT account_id,
         SUM(CASE WHEN trans_type = 'Credit' THEN 1 ELSE 0 END) AS credits,
         SUM(CASE WHEN trans_type = 'Withdrawal' THEN 1 ELSE 0 END) AS withdrawals
  FROM trans
  GROUP BY account_id
)
SELECT account_id
FROM trans_summary
WHERE withdrawals > credits;


-- 4. Loan default rate per district
-- here A = not default, B = default
WITH tbl AS (
  SELECT a.district_id,
         COUNT(*) AS total_default_per_district
  FROM loan l
  JOIN account a ON l.account_id = a.account_id
  WHERE l.loan_status <> 'A'
  GROUP BY a.district_id
),
total_loans AS (
  SELECT a.district_id,
         COUNT(*) AS total_loans
  FROM loan l
  JOIN account a ON l.account_id = a.account_id
  GROUP BY a.district_id
)
SELECT t.district_id,
       ROUND((t.total_default_per_district * 100.0) / l.total_loans, 2) AS default_rate
FROM tbl t
JOIN total_loans l ON t.district_id = l.district_id;


-- 5. Total transactions and total amount per payment_type
SELECT payment_type,count(*) total_trans,
ROUND(SUM(amount), 2) AS total_amount
 FROM trans
group by payment_type;
```

### advance insights
```sql
-- 1. Find the percentage of accounts per district that have received at least one loan? 
WITH ttl_acc AS (SELECT district_id, COUNT(DISTINCT account_id) total_acc FROM account
GROUP BY district_id),
loan_iis_tbl AS
(SELECT a.district_id, count(DISTINCT a.account_id) loan_issued FROM account a
JOIN loan l ON l.account_id = a.account_id
group by a.district_id)

SELECT t1.district_id, ROUND((loan_issued*100)/total_acc,2) as loan_percentage FROM ttl_acc t1
JOIN loan_iis_tbl t2 ON t1.district_id = t2.district_id;


-- 2. Detect potentially risky loans (high loan amount, low repayment capacity)
SELECT 
    l.loan_id,
    l.amount AS loan_amount,
    d.client_id,
    dt.avg_salary_czk
FROM loan l
JOIN account a ON l.account_id = a.account_id
JOIN disp d ON d.account_id = a.account_id AND d.disp_type = 'OWNER'
JOIN client c ON d.client_id = c.client_id
JOIN district dt ON a.district_id = dt.district_id
WHERE l.amount > 200000         -- high loan amount threshold
  AND dt.avg_salary_czk < 9000;    -- low repayment capacity


-- 3.  Clients with the Highest Total amount Withdrawals
WITH withdrawals AS (
  SELECT account_id, SUM(amount) AS total_withdrawn
  FROM trans
  WHERE trans_type = 'Withdrawal'
  GROUP BY account_id
),
client_map AS (
  SELECT d.client_id, d.account_id
  FROM disp d
  WHERE disp_type = 'OWNER'
)
SELECT c.client_id, w.total_withdrawn
FROM withdrawals w
JOIN client_map c ON w.account_id = c.account_id
ORDER BY total_withdrawn DESC
LIMIT 10;


-- 4. Monthly Loan Issuance Trend
SELECT DATE_FORMAT(loan_date, '%Y-%m') AS month,
       COUNT(*) AS loans_issued,
       ROUND(AVG(amount), 2) AS avg_loan_amount
FROM loan
GROUP BY DATE_FORMAT(loan_date, '%Y-%m')
ORDER BY month;


-- 5. Districts With Highest Transaction Volume Per Capita
WITH txn_sum AS (
  SELECT a.district_id, SUM(t.amount) AS total_amount
  FROM trans t
  JOIN account a ON a.account_id = t.account_id
  GROUP BY a.district_id
)
SELECT d.district_name,
       ts.total_amount,
       d.inhabitants,
       ROUND(ts.total_amount / d.inhabitants, 2) AS per_capita_transaction
FROM txn_sum ts
JOIN district d ON ts.district_id = d.district_id
ORDER BY per_capita_transaction DESC
LIMIT 5;

-- 6. Detect Customers With Increasing Withdrawal Frequency Month-over-Month
WITH monthly_withdrawals AS (
  SELECT account_id,
         DATE_FORMAT(trans_date, '%Y-%m') AS txn_month,
         COUNT(*) AS withdrawals
  FROM trans
  WHERE trans_type = 'Withdrawal'
  GROUP BY account_id, txn_month
),
growth_check AS (
  SELECT account_id, txn_month, withdrawals,
         LAG(withdrawals) OVER (PARTITION BY account_id ORDER BY txn_month) AS prev_withdrawals
  FROM monthly_withdrawals
)
SELECT *
FROM growth_check
WHERE prev_withdrawals IS NOT NULL AND withdrawals > prev_withdrawals;


-- 7. Seasonality of Withdrawals (Which Month Has Highest?)
SELECT MONTHNAME(trans_date) AS month,
       COUNT(*) AS num_withdrawals
FROM trans
WHERE trans_type = 'Withdrawal'
GROUP BY MONTH(trans_date), MONTHNAME(trans_date)
ORDER BY num_withdrawals DESC;


-- 8. Accounts With the Largest Positive Balance Without Any Loan
SELECT t.account_id,
       MAX(t.balance) AS max_balance
FROM trans t
WHERE t.account_id NOT IN (SELECT account_id FROM loan)
GROUP BY t.account_id
ORDER BY max_balance DESC
LIMIT 10;

-- 9. Show accounts without loans and their most recent balance
with rnk_balance as (
select account_id,trans_date,balance, rank() over(partition by account_id order by trans_date desc) as rnk from trans
order by trans_date desc
)
select * from rnk_balance r
where rnk = 1 and account_id not in (select distinct(account_id) from loan);


-- 10. Accounts With Cards But No Transactions
WITH card_accounts AS (
  SELECT DISTINCT d.account_id
  FROM card c
  JOIN disp d ON c.disp_id = d.disp_id
),
active_accounts AS (
  SELECT DISTINCT account_id
  FROM trans
)
SELECT ca.account_id
FROM card_accounts ca
LEFT JOIN active_accounts aa ON ca.account_id = aa.account_id
WHERE aa.account_id IS NULL;


-- 11. Average Delay Between Account Opening and Loan Issuance
SELECT ROUND(AVG(DATEDIFF(l.loan_date, a.created_date)), 0) AS avg_days_until_loan
FROM loan l
JOIN account a ON l.account_id = a.account_id
WHERE l.loan_date > a.created_date;
```
