-- Drop tables if they exist (for easy re-running)
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS loans;

-- Create loans table
CREATE TABLE loans (
    loan_id INT PRIMARY KEY,
    customer_id INT,
    loan_amount INT,
    due_date DATE
);

-- Create payments table
CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    loan_id INT,
    amount_paid INT,
    payment_date DATE,
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
);

-- Insert data into loans table
INSERT INTO loans (loan_id, customer_id, loan_amount, due_date) VALUES
(1, 101, 1000, '2023-01-15'),
(2, 102, 500, '2023-02-10'),
(3, 103, 2000, '2023-03-01'),
(4, 104, 750, '2023-01-20');

-- Insert data into payments table
INSERT INTO payments (payment_id, loan_id, amount_paid, payment_date) VALUES
(1001, 1, 500, '2023-01-10'),
(1002, 1, 500, '2023-01-14'),
(1003, 2, 200, '2023-02-05'),
(1004, 2, 300, '2023-02-15'),
(1005, 3, 1000, '2023-02-20'),
(1006, 4, 750, '2023-01-25');

-- Add a loan with no payments to test edge case
INSERT INTO loans (loan_id, customer_id, loan_amount, due_date) VALUES
(5, 105, 100, '2023-04-01');


WITH LoanPaymentSummary AS (
    SELECT
        l.loan_id,
        l.loan_amount,
        l.due_date,
        COALESCE(SUM(p.amount_paid), 0) AS total_amount_paid_overall,
        COALESCE(SUM(CASE
                         WHEN p.payment_date <= l.due_date THEN p.amount_paid
                         ELSE 0
                     END), 0) AS total_amount_paid_on_time
    FROM
        loans l
    LEFT JOIN
        payments p ON l.loan_id = p.loan_id
    GROUP BY
        l.loan_id, l.loan_amount, l.due_date
)
SELECT
    lps.loan_id,
    lps.loan_amount,
    lps.due_date,
    CASE
        WHEN lps.total_amount_paid_overall >= lps.loan_amount THEN 1
        ELSE 0
    END AS fully_paid_flag,
    CASE
        WHEN lps.total_amount_paid_overall >= lps.loan_amount AND lps.total_amount_paid_on_time >= lps.loan_amount THEN 1
        ELSE 0
    END AS on_time_flag
FROM
    LoanPaymentSummary lps
ORDER BY
    lps.loan_id;