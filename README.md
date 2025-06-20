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

  <pre> CREATE DATABASE IF NOT EXISTS Finance;

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
    card_type VARCHAR(20),   -- e.g., classic, gold
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

CREATE TABLE card (
	card_id INT PRIMARY KEY,
    disp_id INT,
    card_type VARCHAR(20),
    issued_date DATE
);

CREATE TABLE orders (
	order_id INT PRIMARY KEY,
    account_id INT,
    bank_to VARCHAR(20),
    account_to INT,
	amount FLOAT,
    payment_type VARCHAR(20)  -- k_symbol,transaction purpose
);

CREATE TABLE loan (
	loan_id INT PRIMARY KEY,
    account_id INT,
    loan_date DATE,
    amount FLOAT,
    duration INT,  -- in months
    payments FLOAT,  -- monthly payment (emi)
    loan_status CHAR(1)
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
);
     </pre>
