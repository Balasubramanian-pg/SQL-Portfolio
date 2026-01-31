-- Create the Employee table
CREATE TABLE Employee (
    id INT,
    company VARCHAR(1),
    salary INT
);

-- Insert the sample data
INSERT INTO Employee (id, company, salary) VALUES
(1, 'A', 2341),
(2, 'A', 341),
(3, 'A', 15),
(4, 'A', 15314),
(5, 'A', 451),
(6, 'A', 513),
(7, 'B', 15),
(8, 'B', 13),
(9, 'B', 1154),
(10, 'B', 1345),
(11, 'B', 1221),
(12, 'B', 234),
(13, 'C', 2345),
(14, 'C', 2645),
(15, 'C', 2645),
(16, 'C', 2652),
(17, 'C', 65);



WITH t AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY company
            ORDER BY salary ASC, id ASC  -- Tie-breaker added
        ) AS rk,
        COUNT(id) OVER (PARTITION BY company) AS n
    FROM Employee
)
SELECT
    id,
    company,
    salary
FROM t
WHERE
    (n % 2 = 0 AND rk BETWEEN n/2 AND n/2 + 1)
    OR (n % 2 = 1 AND rk = (n+1)/2);