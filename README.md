# Financial-Database-Insights-Using-SQL
A real-world SQL project exploring a relational banking dataset using MySQL. Includes ER modeling, data cleaning, analytical queries, and insights on customer behavior, loans, and transactions.

## Project Overview
This project demonstrates the implementation of a Financial Database Insights system using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase practical skills in database design, manipulation, and data analysis.


![image](https://github.com/user-attachments/assets/6a42b9ae-7402-4200-ac95-cd48db294098)

## Objective
The objective of this project is to explore and analyze a real-world financial (banking) relational database using SQL. This includes:

- Designing a clear ER (Entity-Relationship) model.
- Creating and populating a database with realistic banking-related tables.
- Cleaning and structuring data with appropriate foreign key constraints.
- Writing SQL queries to extract insights on customers, accounts, transactions, loans, and defaults.
- Identifying patterns in financial behavior such as withdrawal frequency, loan default rates, and account activity.
- Practicing advanced SQL techniques like CTEs, aggregations, window functions, and multi-step query logic.

## `Project Structure`

### 1. Database ER daigram 

![ER Daigram](https://github.com/user-attachments/assets/2fb64637-3b2c-4d92-b88b-09ff6ce228b9)


### 2. Database Setup

- **Database Creation**: A database named `finance` was created.
- **Table Creation**: Tables for `account`, `card`, `district`, `client`, `loan`, `trans`, `disp`, and `orders` were created, each reflecting real-world banking schema.

```sql
CREATE DATABASE IF NOT EXISTS Finance;
CREATE DATABASE IF NOT EXISTS Finance;
USE Finance;

CREATE TABLE account (
    account_id  INTEGER PRIMARY KEY,
    district_id  INTEGER,
    fee_frequency VARCHAR(30),
    created_date DATE
);

CREATE TABLE card (
    card_id INT PRIMARY KEY,
    disp_id INT,
    card_type VARCHAR(20),
    issued_date DATE
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
);

CREATE TABLE disp (
    disp_id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT,
    account_id INT,
    disp_type ENUM('OWNER','DISPONENT')
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    account_id INT,
    bank_to VARCHAR(20),
    account_to INT,
    amount FLOAT,
    payment_type VARCHAR(20)
);

CREATE TABLE loan (
    loan_id INT PRIMARY KEY,
    account_id INT,
    loan_date DATE,
    amount FLOAT,
    duration INT,
    payments FLOAT,
    loan_status CHAR(1)
);

CREATE TABLE trans (
    trans_id INT PRIMARY KEY,
    account_id INT,
    trans_date DATE,
    trans_type VARCHAR(20),
    processing_method VARCHAR(50),
    amount FLOAT,
    balance FLOAT,
    payment_type VARCHAR(20),
    bank_code VARCHAR(20),
    target_account INT
);
```


### 3. Data Cleaning

Performed several data standardizations and value replacements to make the dataset more readable and analysis-ready.

#### Task: Standardize Payment Type and Fee Frequency Descriptions

```sql
SET sql_safe_updates = 0;

UPDATE orders
SET payment_type = CASE
    WHEN payment_type = 'SIPO' THEN 'Household Bills'
    WHEN payment_type = 'LEASING' THEN 'Leasing Payment'
    WHEN payment_type = 'POJISTNE' THEN 'Insurance Payment'
    WHEN payment_type = 'UVER' THEN 'Loan Payment'
    WHEN payment_type = '' OR payment_type IS NULL THEN 'No Detail'
    ELSE payment_type
END;

UPDATE account
SET fee_frequency = CASE
    WHEN fee_frequency = 'POPLATEK MESICNE' THEN 'Monthly Fee'
    WHEN fee_frequency = 'POPLATEK TYDNE' THEN 'Weekly Fee'
    WHEN fee_frequency = 'POPLATEK PO OBRATU' THEN 'Fee Per Transaction'
    ELSE fee_frequency
END;
```

#### Task: Normalize Transaction Types

```sql
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

-- Merge "Cash Withdrawal" under "Withdrawal"
UPDATE trans
SET trans_type = 'Withdrawal'
WHERE trans_type = 'Cash Withdrawal';

-- Remove unused column
ALTER TABLE trans
DROP COLUMN processing_method;

-- Fill missing payment_type
UPDATE trans
SET payment_type = 'No Detail'
WHERE payment_type = '' OR payment_type IS NULL;
```


### 4. Foreign Key Constraints

```sql
ALTER TABLE orders
ADD CONSTRAINT fk_orders_account
FOREIGN KEY (account_id) REFERENCES account(account_id);

ALTER TABLE loan
ADD CONSTRAINT fk_loan_account
FOREIGN KEY (account_id) REFERENCES account(account_id);

ALTER TABLE trans
ADD CONSTRAINT fk_trans_account
FOREIGN KEY (account_id) REFERENCES account(account_id);

ALTER TABLE card
ADD CONSTRAINT fk_card_disp
FOREIGN KEY (disp_id) REFERENCES disp(disp_id);

ALTER TABLE client
ADD CONSTRAINT fk_client_district
FOREIGN KEY (district_id) REFERENCES district(district_id);

ALTER TABLE disp
ADD CONSTRAINT fk_disp_client
FOREIGN KEY (client_id) REFERENCES client(client_id),
ADD CONSTRAINT fk_disp_account
FOREIGN KEY (account_id) REFERENCES account(account_id);

ALTER TABLE account
ADD CONSTRAINT fk_account_district
FOREIGN KEY (district_id) REFERENCES district(district_id);
```

Unnecessary foreign key violations were also cleaned up:

```sql
DELETE FROM card
WHERE disp_id NOT IN (SELECT disp_id FROM disp);

DELETE FROM loan
WHERE account_id NOT IN (SELECT account_id FROM account);
```


### 🔹 Basic Insights

**Task 1: Count Total Clients per District**  \
Retrieve the number of clients registered in each district.

```sql
SELECT district_id, COUNT(*) AS no_of_clients
FROM finance.client
GROUP BY district_id;
```

**Task 2: Accounts Opened in 1997**  \
List all accounts that were created during the year 1997.

```sql
SELECT *
FROM account
WHERE YEAR(created_date) = 1997;
```

**Task 3: Number of Cards Issued by Type**  \
Display the total number of cards issued, grouped by card type.

```sql
SELECT card_type, COUNT(*) AS no_of_cards
FROM card
GROUP BY card_type;
```

**Task 4: Average Loan Amount by Status**  \
Show the average loan amount for each loan status category.

```sql
SELECT loan_status, AVG(amount) AS avg_loan_amount
FROM loan
GROUP BY loan_status;
```

**Task 5: Top 5 Districts by Average Salary**  \
Identify the top five districts with the highest average salary.

```sql
SELECT district_id, district_name, avg_salary_czk
FROM district
ORDER BY avg_salary_czk DESC
LIMIT 5;
```

### 🔹 Intermediate Insights

**Task 6: Count Clients with Loans**  
Calculate the total number of unique clients who have taken at least one loan.
```sql
SELECT COUNT(DISTINCT c.client_id) AS clients_with_loans
FROM client c
JOIN disp d ON c.client_id = d.client_id
JOIN account a ON a.account_id = d.account_id
JOIN loan l ON a.account_id = l.account_id;
```

**Task 7: Monthly Average Transaction Amount**  
Determine the average transaction amount per month across all accounts.
```sql
SELECT DATE_FORMAT(trans_date, '%Y-%m') AS month,
       ROUND(AVG(amount)) AS avg_monthly_trans
FROM trans
GROUP BY DATE_FORMAT(trans_date, '%Y-%m')
ORDER BY month;
```

**Task 8: Identify Accounts with More Withdrawals than Credits**  
Find accounts where the number of withdrawals exceeds the number of credits.
```sql
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
```

**Task 9: Loan Default Rate by District**  
Compute the percentage of defaulted loans for each district.
```sql
WITH defaults AS (
  SELECT a.district_id,
         COUNT(*) AS defaulted_loans
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
       ROUND((d.defaulted_loans * 100.0) / t.total_loans, 2) AS default_rate
FROM total_loans t
JOIN defaults d ON t.district_id = d.district_id;
```

**Task 10: Transaction Summary by Payment Type**  
Show the total number of transactions and transaction amount by each payment type.
```sql
SELECT payment_type,
       COUNT(*) AS total_trans,
       ROUND(SUM(amount), 2) AS total_amount
FROM trans
GROUP BY payment_type;
```


### 🔹 Advanced Insights

**Task 11: Loan Access Rate by District**\
Find the percentage of accounts in each district that have been issued at least one loan.

```sql
WITH ttl_acc AS (
    SELECT district_id, COUNT(DISTINCT account_id) AS total_acc
    FROM account
    GROUP BY district_id
),
loan_issued_tbl AS (
    SELECT a.district_id, COUNT(DISTINCT a.account_id) AS loan_issued
    FROM account a
    JOIN loan l ON l.account_id = a.account_id
    GROUP BY a.district_id
)
SELECT t1.district_id,
       ROUND((loan_issued * 100.0) / total_acc, 2) AS loan_percentage
FROM ttl_acc t1
JOIN loan_issued_tbl t2 ON t1.district_id = t2.district_id;
```

**Task 12: Detect Risky Loans (Low Repayment Capacity)**\
Identify loans where the loan amount is high, and the borrower comes from a district with low average income.

```sql
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
WHERE l.amount > 200000
  AND dt.avg_salary_czk < 9000;
```

**Task 13: Top Clients by Total Withdrawals**\
Find clients who have withdrawn the most total money across all transactions.

```sql
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
```

**Task 14: Monthly Loan Issuance Trend**\
Analyze the volume and average amount of loans issued per month.

```sql
SELECT DATE_FORMAT(loan_date, '%Y-%m') AS month,
       COUNT(*) AS loans_issued,
       ROUND(AVG(amount), 2) AS avg_loan_amount
FROM loan
GROUP BY DATE_FORMAT(loan_date, '%Y-%m')
ORDER BY month;
```

**Task 15: Transaction Volume Per Capita by District**\
Identify districts with the highest transaction volume per person.

```sql
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
```

**Task 16: Increasing Monthly Withdrawal Pattern**\
Detect customers whose withdrawal frequency is increasing month over month.

```sql
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
```

**Task 17: Withdrawal Seasonality**\
Identify the months with the highest withdrawal activity.

```sql
SELECT MONTHNAME(trans_date) AS month,
       COUNT(*) AS num_withdrawals
FROM trans
WHERE trans_type = 'Withdrawal'
GROUP BY MONTH(trans_date), MONTHNAME(trans_date)
ORDER BY num_withdrawals DESC;
```

**Task 18: High Balance Accounts Without Loans**\
List top accounts with the highest positive balance that have never taken any loan.

```sql
SELECT t.account_id,
       MAX(t.balance) AS max_balance
FROM trans t
WHERE t.account_id NOT IN (SELECT account_id FROM loan)
GROUP BY t.account_id
ORDER BY max_balance DESC
LIMIT 10;
```

**Task 19: Latest Balance of Accounts Without Loans**\
Show the most recent balance for accounts that do not have any loan.

```sql
WITH rnk_balance AS (
  SELECT account_id,
         trans_date,
         balance,
         RANK() OVER (PARTITION BY account_id ORDER BY trans_date DESC) AS rnk
  FROM trans
)
SELECT *
FROM rnk_balance
WHERE rnk = 1 AND account_id NOT IN (SELECT DISTINCT account_id FROM loan);
```

**Task 20: Accounts With Cards But No Transactions**\
Find accounts where a card was issued but no transaction has ever occurred.

```sql
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
```

**Task 21: Delay Between Account Opening and Loan Issuance**\
Calculate the average time (in days) between account creation and when a loan was issued.

```sql
SELECT ROUND(AVG(DATEDIFF(l.loan_date, a.created_date))) AS avg_days_until_loan
FROM loan l
JOIN account a ON l.account_id = a.account_id
WHERE l.loan_date > a.created_date;
```

