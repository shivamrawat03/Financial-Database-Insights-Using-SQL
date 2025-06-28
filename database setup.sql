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

CREATE TABLE card (
	card_id INT PRIMARY KEY,
    disp_id INT,
    card_type VARCHAR(20),
    issued_date DATE
    -- FOREIGN KEY (disp_id) REFERENCES disp(disp_id)
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
    

