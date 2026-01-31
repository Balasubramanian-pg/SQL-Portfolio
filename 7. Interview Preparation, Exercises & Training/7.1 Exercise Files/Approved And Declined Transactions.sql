-- For PostgreSQL (create enum type first)
CREATE TYPE transaction_state AS ENUM ('approved', 'declined');

-- Create Transactions table
CREATE TABLE Transactions (
    id INT PRIMARY KEY,
    country VARCHAR(50),
    state transaction_state,
    amount INT,
    trans_date DATE
);

-- Create Chargebacks table
CREATE TABLE Chargebacks (
    trans_id INT REFERENCES Transactions(id),
    trans_date DATE
);

-- Insert data into Transactions table
INSERT INTO Transactions (id, country, state, amount, trans_date) VALUES
(101, 'US', 'approved', 1000, '2019-05-18'),
(102, 'US', 'declined', 2000, '2019-05-19'),
(103, 'US', 'approved', 3000, '2019-06-10'),
(104, 'US', 'declined', 4000, '2019-06-13'),
(105, 'US', 'approved', 5000, '2019-06-15');

-- Insert data into Chargebacks table
INSERT INTO Chargebacks (trans_id, trans_date) VALUES
(102, '2019-05-29'),
(101, '2019-06-30'),
(105, '2019-09-18');

WITH MonthlyStats AS (
    -- Approved transactions
    SELECT 
        TO_CHAR(trans_date, 'YYYY-MM') AS month,
        country,
        COUNT(*) AS approved_count,
        SUM(amount) AS approved_amount,
        0 AS chargeback_count,
        0 AS chargeback_amount
    FROM 
        Transactions
    WHERE 
        state = 'approved'
    GROUP BY 
        TO_CHAR(trans_date, 'YYYY-MM'), country
    
    UNION ALL
    
    -- Chargebacks
    SELECT 
        TO_CHAR(c.trans_date, 'YYYY-MM') AS month,
        t.country,
        0 AS approved_count,
        0 AS approved_amount,
        COUNT(*) AS chargeback_count,
        SUM(t.amount) AS chargeback_amount
    FROM 
        Chargebacks c
    JOIN 
        Transactions t ON c.trans_id = t.id
    GROUP BY 
        TO_CHAR(c.trans_date, 'YYYY-MM'), t.country
)
SELECT 
    month,
    country,
    SUM(approved_count) AS approved_count,
    SUM(approved_amount) AS approved_amount,
    SUM(chargeback_count) AS chargeback_count,
    SUM(chargeback_amount) AS chargeback_amount
FROM 
    MonthlyStats
GROUP BY month, country
HAVING 
    SUM(approved_count) > 0 
    OR SUM(approved_amount) > 0 
    OR SUM(chargeback_count) > 0 
    OR SUM(chargeback_amount) > 0
ORDER BY month, country;