-- 1. Find the percentage of accounts per district that have received at least one loan? 
WITH ttl_acc AS (SELECT district_id, COUNT(DISTINCT account_id) total_acc FROM account
GROUP BY district_id),
loan_iis_tbl AS
(SELECT a.district_id, count(DISTINCT a.account_id) loan_issued FROM account a
JOIN loan l ON l.account_id = a.account_id
group by a.district_id)

SELECT t1.district_id, ROUND((loan_issued*100)/total_acc,2) as loan_percentage FROM ttl_acc t1
JOIN loan_iis_tbl t2 ON t1.district_id = t2.district_id;


-- 	2. Detect potentially risky loans (high loan amount, low repayment capacity)
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


