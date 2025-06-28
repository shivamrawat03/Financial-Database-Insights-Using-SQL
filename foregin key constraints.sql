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