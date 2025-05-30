-- Create the employees table
CREATE TABLE deeznutz (
    emp_id INT PRIMARY KEY,
    salary INT,
    dept VARCHAR(50)
);

-- Insert sample data
INSERT INTO deeznutz (emp_id, salary, dept) VALUES
(1, 70000, 'Sales'),
(2, 80000, 'Sales'),
(3, 80000, 'Sales'),
(4, 90000, 'Sales'),
(5, 55000, 'IT'),
(6, 65000, 'IT'),
(7, 65000, 'IT'),
(8, 50000, 'Marketing'),
(9, 55000, 'Marketing'),
(10, 55000, 'HR');


SELECT emp_id, dept
FROM(
SELECT emp_id, salary, dept,
DENSE_RANK() OVER(PARTITION BY dept ORDER BY salary DESC) AS salary_rank
FROM deeznutz) ranked_Salaries
WHERE salary_rank = 2
ORDER BY emp_id ASC


--Another method using common table expressions

WITH ranked_salaries AS 
	(SELECT emp_id, dept, salary,
	DENSE_RANK() OVER(PARTITION BY dept ORDER BY salary DESC) AS Sal_rank
	FROM deeznutz)  

SELECT emp_id, dept
FROM ranked_salaries
WHERE Sal_rank = 2
ORDER BY emp_id ASC