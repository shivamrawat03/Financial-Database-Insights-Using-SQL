-- 	1. Total number of clients with a loan
SELECT DISTINCT(count(*)) FROM client c
JOIN disp d ON c.client_id = d.client_id
JOIN account a ON a.account_id = d.account_id
JOIN loan l ON a.account_id = l.account_id;

-- 	2. Average monthly transaction amount per account
SELECT DATE_FORMAT(trans_date, '%Y-%m') AS month,
       ROUND(AVG(amount)) AS avg_monthly_trans
FROM trans
GROUP BY DATE_FORMAT(trans_date, '%Y-%m')
ORDER BY month;


-- 	3. Identify accounts with more withdrawals than credits
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


-- 	4. Loan default rate per district
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


-- 	5. Total transactions and total amount per payment_type
SELECT payment_type,count(*) total_trans,
ROUND(SUM(amount), 2) AS total_amount
 FROM trans
group by payment_type;

