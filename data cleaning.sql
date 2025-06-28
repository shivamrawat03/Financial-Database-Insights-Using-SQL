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

-- UPDATE trans
-- SET processing_method = CASE
-- 	WHEN processing_method = 'VKLAD' THEN 'Deposit'
--     WHEN processing_method = 'PREVOD Z UCTU' THEN 'Transfer In'
--     WHEN processing_method = 'PREVOD NA UCET' THEN 'Transfer Out'
--     WHEN processing_method = 'VYBER' THEN 'Withdrawal'
--     ELSE processing_method
-- END;
 

UPDATE trans
SET trans_type = 'Withdrawal'
WHERE trans_type = 'Cash Withdrawal';
 
ALTER TABLE trans
DROP COLUMN processing_method;


UPDATE trans
SET payment_type = 'No Detail'
WHERE payment_type = '' OR payment_type IS NULL;

