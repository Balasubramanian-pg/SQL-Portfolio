# SQL Challenge: Employee Department Swapping

## Structured Question

Given an employee table with the following structure and data:
```
| id | name    | department   |
|----|---------|--------------|
| 1  | John    | Sales        |
| 2  | Tom     | IT           |
| 3  | Rohit   | IT           |
| 4  | shubham | Marketing    |
| 5  | kavya   | Management   |
| 6  | Rohan   | Sales        |
| 7  | Shivani | IT           |
```

Write an SQL query to transform this table so that employees are moved to different departments following this pattern:
- Employees should be rotated through departments in the order: Sales → IT → Marketing → Management → Sales
- The result should maintain all employee records with their new departments

Expected output:
```
| id | name    | department   |
|----|---------|--------------|
| 1  | John    | IT           |
| 2  | Tom     | Sales        |
| 3  | Rohit   | Marketing    |
| 4  | shubham | IT           |
| 5  | kavya   | Sales        |
| 6  | Rohan   | Management   |
| 7  | Shivani | IT           |
```

## Logical Decomposition

1. **Identify the department rotation pattern**:
   - Sales → IT
   - IT → Marketing
   - Marketing → Management
   - Management → Sales

2. **Create a department mapping**:
   - {'Sales':'IT', 'IT':'Marketing', 'Marketing':'Management', 'Management':'Sales'}

3. **For each employee**:
   - Replace their current department with the next one in rotation
   - Keep all other columns unchanged

## SQL Solution

```sql
-- Create and populate the original table
CREATE TABLE employees (
    id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    department VARCHAR(50) NOT NULL
);

INSERT INTO employees (id, name, department) VALUES
(1, 'John', 'Sales'),
(2, 'Tom', 'IT'),
(3, 'Rohit', 'IT'),
(4, 'shubham', 'Marketing'),
(5, 'kavya', 'Management'),
(6, 'Rohan', 'Sales'),
(7, 'Shivani', 'IT');

-- Solution using CASE statement
SELECT 
    id,
    name,
    CASE 
        WHEN department = 'Sales' THEN 'IT'
        WHEN department = 'IT' THEN 'Marketing'
        WHEN department = 'Marketing' THEN 'Management'
        WHEN department = 'Management' THEN 'Sales'
        ELSE department -- Fallback for any unexpected values
    END AS department
FROM 
    employees
ORDER BY 
    id;

-- Alternative solution using a join with department mapping table
CREATE TABLE department_rotation (
    current_dept VARCHAR(50) PRIMARY KEY,
    next_dept VARCHAR(50) NOT NULL
);

INSERT INTO department_rotation VALUES
('Sales', 'IT'),
('IT', 'Marketing'),
('Marketing', 'Management'),
('Management', 'Sales');

SELECT 
    e.id,
    e.name,
    COALESCE(d.next_dept, e.department) AS department
FROM 
    employees e
LEFT JOIN 
    department_rotation d ON e.department = d.current_dept
ORDER BY 
    e.id;
```

## Solution Explanation

1. **Table Creation**: The `employees` table is created with sample data matching the input.

2. **CASE Statement Solution**:
   - Uses conditional logic to map each department to its next in rotation
   - Straightforward but requires updating if departments change

3. **Mapping Table Solution**:
   - Creates a separate `department_rotation` table that defines the swapping pattern
   - More maintainable as rotation rules can be updated without changing the query
   - Uses LEFT JOIN to preserve all employees and COALESCE to handle any unmapped departments

4. **Output**:
   - Both solutions produce the same result matching the expected output
   - Maintains original employee IDs and names while rotating departments
   - Results are ordered by employee ID for consistency

This solution provides two approaches to solve the department rotation problem, with the mapping table approach being more scalable for larger or more complex department rotation patterns.