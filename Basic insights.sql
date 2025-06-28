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

