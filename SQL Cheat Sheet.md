Below is a cheat sheet highlighting some of the most important SQL functions along with their uses and small examples:

---

### Aggregate Functions

- **COUNT()**  
  **Use:** Returns the number of rows in a dataset.  
  **Example:**  
  ```sql
  SELECT COUNT(*) AS total_orders
  FROM orders;
  ```

- **SUM()**  
  **Use:** Calculates the total sum of a numeric column.  
  **Example:**  
  ```sql
  SELECT SUM(amount) AS total_sales
  FROM sales;
  ```

- **AVG()**  
  **Use:** Computes the average of a numeric column.  
  **Example:**  
  ```sql
  SELECT AVG(salary) AS average_salary
  FROM employees;
  ```

- **MIN()**  
  **Use:** Retrieves the minimum value in a column.  
  **Example:**  
  ```sql
  SELECT MIN(price) AS lowest_price
  FROM products;
  ```

- **MAX()**  
  **Use:** Retrieves the maximum value in a column.  
  **Example:**  
  ```sql
  SELECT MAX(price) AS highest_price
  FROM products;
  ```

---

### String Functions

- **CONCAT()**  
  **Use:** Combines two or more strings into one.  
  **Example:**  
  ```sql
  SELECT CONCAT(first_name, ' ', last_name) AS full_name
  FROM employees;
  ```

- **SUBSTRING()**  
  **Use:** Extracts a portion of a string.  
  **Example:**  
  ```sql
  SELECT SUBSTRING('Hello SQL', 1, 5) AS greeting;  -- returns 'Hello'
  ```

- **UPPER() / LOWER()**  
  **Use:** Converts a string to uppercase or lowercase.  
  **Example:**  
  ```sql
  SELECT UPPER('hello') AS shout, LOWER('WORLD') AS whisper;
  ```

- **LENGTH() / LEN()**  
  **Use:** Returns the length of a string (use `LEN()` in SQL Server).  
  **Example:**  
  ```sql
  SELECT LENGTH('Hello') AS str_length;  -- returns 5
  ```

- **TRIM()**  
  **Use:** Removes leading and trailing spaces from a string.  
  **Example:**  
  ```sql
  SELECT TRIM('  spaced out  ') AS trimmed;
  ```

---

### Date Functions

- **NOW() / CURRENT_TIMESTAMP**  
  **Use:** Returns the current date and time.  
  **Example:**  
  ```sql
  SELECT NOW() AS current_datetime;
  ```

- **CURDATE()**  
  **Use:** Returns the current date (commonly used in MySQL).  
  **Example:**  
  ```sql
  SELECT CURDATE() AS today;
  ```

- **DATEADD()**  
  **Use:** Adds a specified time interval to a date (syntax varies by SQL dialect; SQL Server example).  
  **Example:**  
  ```sql
  SELECT DATEADD(day, 7, GETDATE()) AS next_week;
  ```

- **DATEDIFF()**  
  **Use:** Calculates the difference between two dates.  
  **Example:**  
  ```sql
  SELECT DATEDIFF('2025-01-01', '2024-12-25') AS days_difference;
  ```

---

### Conditional and Conversion Functions

- **COALESCE()**  
  **Use:** Returns the first non-null value in a list.  
  **Example:**  
  ```sql
  SELECT COALESCE(NULL, 'default') AS result;  -- returns 'default'
  ```

- **IFNULL()** (MySQL)  
  **Use:** Returns an alternative value if a given expression is NULL.  
  **Example:**  
  ```sql
  SELECT IFNULL(discount, 0) AS discount_value
  FROM orders;
  ```

- **CASE**  
  **Use:** Provides conditional logic within queries.  
  **Example:**  
  ```sql
  SELECT 
    product_name,
    CASE 
      WHEN stock = 0 THEN 'Out of Stock'
      ELSE 'In Stock'
    END AS availability
  FROM products;
  ```

---

### Mathematical Functions

- **ROUND()**  
  **Use:** Rounds a numeric value to a specified number of decimal places.  
  **Example:**  
  ```sql
  SELECT ROUND(123.456, 2) AS rounded_value;  -- returns 123.46
  ```

- **ABS()**  
  **Use:** Returns the absolute (non-negative) value of a number.  
  **Example:**  
  ```sql
  SELECT ABS(-10) AS absolute_value;  -- returns 10
  ```

---

This cheat sheet covers key functions you'll frequently use in SQL. Each function can be further customized based on your specific database system and requirements. Happy querying!



Below is an advanced SQL cheat sheet covering additional features beyond basic functions. This guide includes essential SQL concepts with brief explanations and small examples:

---

## 1. Joins  
**Purpose:** Combine rows from two or more tables based on a related column.

- **INNER JOIN** – Returns rows with matching values in both tables.
  ```sql
  SELECT a.column1, b.column2
  FROM tableA a
  INNER JOIN tableB b ON a.common_field = b.common_field;
  ```

- **LEFT JOIN** – Returns all rows from the left table, and the matched rows from the right table.
  ```sql
  SELECT a.column1, b.column2
  FROM tableA a
  LEFT JOIN tableB b ON a.common_field = b.common_field;
  ```

- **RIGHT JOIN** – Returns all rows from the right table, and the matched rows from the left table.
  ```sql
  SELECT a.column1, b.column2
  FROM tableA a
  RIGHT JOIN tableB b ON a.common_field = b.common_field;
  ```

- **FULL OUTER JOIN** – Returns rows when there is a match in one of the tables.
  ```sql
  SELECT a.column1, b.column2
  FROM tableA a
  FULL OUTER JOIN tableB b ON a.common_field = b.common_field;
  ```

---

## 2. Subqueries  
**Purpose:** Use a query inside another query to further refine your data.

- **Example:**
  ```sql
  SELECT employee_name
  FROM employees
  WHERE department_id IN (
      SELECT department_id
      FROM departments
      WHERE location = 'NY'
  );
  ```

---

## 3. Common Table Expressions (CTE)  
**Purpose:** Create a temporary result set that can be referenced within a SELECT, INSERT, UPDATE, or DELETE statement.

- **Example:**
  ```sql
  WITH SalesCTE AS (
      SELECT salesperson, SUM(sales) AS total_sales
      FROM sales
      GROUP BY salesperson
  )
  SELECT *
  FROM SalesCTE
  WHERE total_sales > 10000;
  ```

---

## 4. Window Functions  
**Purpose:** Perform calculations across a set of rows related to the current row, without collapsing the result set.

- **Example (Ranking Salaries):**
  ```sql
  SELECT employee_name, salary,
         RANK() OVER (ORDER BY salary DESC) AS salary_rank
  FROM employees;
  ```

---

## 5. Views  
**Purpose:** Create virtual tables based on the result of a SELECT query. Views simplify complex queries and can provide a layer of security.

- **Example:**
  ```sql
  CREATE VIEW ActiveCustomers AS
  SELECT customer_id, customer_name
  FROM customers
  WHERE active = 1;
  ```

---

## 6. Indexes  
**Purpose:** Improve query performance by creating pointers to data in a table.

- **Example:**
  ```sql
  CREATE INDEX idx_customer_name
  ON customers(customer_name);
  ```

---

## 7. Stored Procedures & Functions  
**Purpose:** Encapsulate a series of SQL statements for reuse. Procedures perform actions, while functions return a value.

- **Stored Procedure Example:**
  ```sql
  CREATE PROCEDURE GetEmployeeByDept (@dept_id INT)
  AS
  BEGIN
      SELECT employee_name, salary
      FROM employees
      WHERE department_id = @dept_id;
  END;
  ```
- **Function Example (SQL Server):**
  ```sql
  CREATE FUNCTION dbo.GetFullName (@first NVARCHAR(50), @last NVARCHAR(50))
  RETURNS NVARCHAR(101)
  AS
  BEGIN
      RETURN CONCAT(@first, ' ', @last);
  END;
  ```

---

## 8. Triggers  
**Purpose:** Automatically execute SQL code in response to certain events on a table, such as INSERT, UPDATE, or DELETE operations.

- **Example:**
  ```sql
  CREATE TRIGGER trg_AfterInsert
  ON orders
  AFTER INSERT
  AS
  BEGIN
      PRINT 'A new order has been inserted.';
  END;
  ```

---

## 9. Transactions  
**Purpose:** Ensure a sequence of SQL statements are executed as a single unit, maintaining data integrity.

- **Example:**
  ```sql
  BEGIN TRANSACTION;
      UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
      UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
  COMMIT;
  ```

---

## 10. Set Operations  
**Purpose:** Combine results from multiple SELECT queries.

- **UNION** – Combines results and removes duplicates.
  ```sql
  SELECT column_name FROM tableA
  UNION
  SELECT column_name FROM tableB;
  ```
- **INTERSECT** – Returns only the common records.
  ```sql
  SELECT column_name FROM tableA
  INTERSECT
  SELECT column_name FROM tableB;
  ```
- **EXCEPT (or MINUS)** – Returns records from the first query that aren’t in the second.
  ```sql
  SELECT column_name FROM tableA
  EXCEPT
  SELECT column_name FROM tableB;
  ```

---

This advanced cheat sheet covers a broad range of SQL features to help you manage and manipulate data more effectively. Each section provides a quick reference to the purpose of the feature along with a concise example to illustrate its use. Enjoy exploring these powerful SQL capabilities!



Below is a cheat sheet featuring additional advanced SQL features to further enhance your querying capabilities:

---

## 1. Recursive Common Table Expressions (CTEs)
**Purpose:** Query hierarchical or recursive data such as organizational charts or folder structures.

**Example (SQL Server / PostgreSQL):**
```sql
WITH EmployeeHierarchy AS (
    SELECT employee_id, manager_id, employee_name
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL
    SELECT e.employee_id, e.manager_id, e.employee_name
    FROM employees e
    INNER JOIN EmployeeHierarchy eh ON e.manager_id = eh.employee_id
)
SELECT * FROM EmployeeHierarchy;
```
*This recursive CTE starts with top-level employees and then recursively joins to retrieve all subordinate employees.*

---

## 2. Pivoting Data
**Purpose:** Transform row data into columns for a more intuitive summary or report.

**Example (SQL Server using PIVOT):**
```sql
SELECT *
FROM (
    SELECT year, month, sales
    FROM SalesData
) AS SourceTable
PIVOT (
    SUM(sales)
    FOR month IN ([Jan], [Feb], [Mar])
) AS PivotTable;
```
*This query converts monthly sales rows into columns for January, February, and March.*

---

## 3. Dynamic SQL
**Purpose:** Build and execute SQL queries dynamically at runtime, which is useful when table names or conditions vary.

**Example (SQL Server):**
```sql
DECLARE @sql NVARCHAR(4000);
DECLARE @TableName NVARCHAR(100) = 'Orders';
SET @sql = 'SELECT * FROM ' + QUOTENAME(@TableName);
EXEC sp_executesql @sql;
```
*This example constructs a SQL statement using a variable for the table name and executes it safely.*

---

## 4. Temporary Tables and Table Variables
**Purpose:** Store intermediate results temporarily during complex query processing.

**Example (Temporary Table in MySQL):**
```sql
CREATE TEMPORARY TABLE TempSales (
    sale_id INT,
    sale_amount DECIMAL(10,2)
);

INSERT INTO TempSales (sale_id, sale_amount) VALUES (1, 100.00);
SELECT * FROM TempSales;
```
*Temporary tables exist only for the duration of your session, allowing you to break down complex operations.*

---

## 5. JSON Functions
**Purpose:** Parse, query, and generate JSON data directly within your SQL queries.

**Example (MySQL):**
```sql
SELECT JSON_EXTRACT(json_column, '$.name') AS name
FROM json_table;
```
*This extracts the `name` field from a JSON column, making it easier to work with JSON data stored in your database.*

---

## 6. Spatial Data Functions
**Purpose:** Work with geographic and geometric data for applications like mapping or spatial analysis.

**Example (PostGIS for PostgreSQL):**
```sql
SELECT ST_AsText(geom) AS geometry
FROM spatial_table;
```
*This converts spatial geometry data into a human-readable text format.*

---

## 7. Query Hints and Optimization
**Purpose:** Influence the query optimizer's behavior to improve performance in specific scenarios.

**Example (SQL Server):**
```sql
SELECT * 
FROM Orders WITH (NOLOCK)
WHERE order_date > '2024-01-01';
```
*The `NOLOCK` hint can help reduce locking contention by reading uncommitted data (use with caution).*

---

## 8. Grouping Sets, ROLLUP, and CUBE
**Purpose:** Perform multi-level aggregations to produce summary reports with subtotals and grand totals.

**Example (ROLLUP in MySQL):**
```sql
SELECT department, COUNT(*) AS employee_count
FROM employees
GROUP BY department WITH ROLLUP;
```
*This query returns a row for each department along with an extra row that shows the overall total count.*

---

Below is a further advanced SQL cheat sheet highlighting additional powerful SQL techniques and features:

---

## 9. Advanced Window Functions  
**Purpose:** Retrieve values from rows before or after the current row without collapsing the result set.

- **LEAD() and LAG()**  
  **Example:**
  ```sql
  SELECT
      employee_name,
      salary,
      LAG(salary, 1) OVER (ORDER BY salary) AS previous_salary,
      LEAD(salary, 1) OVER (ORDER BY salary) AS next_salary
  FROM employees;
  ```
  *This returns the previous and next salary relative to each employee's salary.*

- **FIRST_VALUE() and LAST_VALUE()**  
  **Example:**
  ```sql
  SELECT
      employee_name,
      salary,
      FIRST_VALUE(salary) OVER (ORDER BY salary DESC) AS highest_salary,
      LAST_VALUE(salary) OVER (ORDER BY salary DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS lowest_salary
  FROM employees;
  ```
  *These functions fetch the first and last values in a window, respectively.*

---

## 10. Full-Text Search  
**Purpose:** Perform efficient text searches on large text columns.

- **Example (SQL Server):**
  ```sql
  SELECT *
  FROM articles
  WHERE CONTAINS(content, 'database');
  ```
  *This query searches for the term "database" within the `content` column.*

---

## 11. Table Partitioning  
**Purpose:** Divide large tables into smaller, more manageable pieces to improve performance and maintenance.

- **Example (MySQL Range Partitioning):**
  ```sql
  CREATE TABLE orders (
      order_id INT,
      order_date DATE,
      amount DECIMAL(10,2)
  )
  PARTITION BY RANGE (YEAR(order_date)) (
      PARTITION p2019 VALUES LESS THAN (2020),
      PARTITION p2020 VALUES LESS THAN (2021),
      PARTITION p2021 VALUES LESS THAN (2022)
  );
  ```
  *This partitions the `orders` table by year, making queries on specific date ranges more efficient.*

---

## 12. Materialized Views  
**Purpose:** Store the result of a query physically to speed up retrieval for complex or resource-intensive queries.

- **Example (Oracle):**
  ```sql
  CREATE MATERIALIZED VIEW sales_summary AS
  SELECT salesperson, SUM(sales) AS total_sales
  FROM sales
  GROUP BY salesperson;
  ```
  *Materialized views can be refreshed periodically to provide up-to-date aggregated data.*

---

## 13. Error Handling with TRY/CATCH  
**Purpose:** Capture and handle errors in SQL code, especially within stored procedures.

- **Example (SQL Server):**
  ```sql
  BEGIN TRY
      -- Statements that might cause an error
      UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
  END TRY
  BEGIN CATCH
      PRINT 'An error occurred: ' + ERROR_MESSAGE();
  END CATCH;
  ```
  *This structure catches errors and provides a mechanism to handle them gracefully.*

---

## 14. Hierarchical Queries (Oracle CONNECT BY)  
**Purpose:** Retrieve and display hierarchical data (e.g., organizational structures).

- **Example (Oracle):**
  ```sql
  SELECT employee_id, employee_name, manager_id
  FROM employees
  START WITH manager_id IS NULL
  CONNECT BY PRIOR employee_id = manager_id;
  ```
  *This query builds an organizational hierarchy starting from top-level employees (with no manager).*

---

## 15. Optimizing Index Usage and Maintenance  
**Purpose:** Enhance query performance by creating, analyzing, and maintaining indexes.

- **Creating a Composite Index:**
  ```sql
  CREATE INDEX idx_customer_order ON orders(customer_id, order_date);
  ```
  *A composite index can speed up queries filtering on both `customer_id` and `order_date`.*

- **Rebuilding an Index (SQL Server):**
  ```sql
  ALTER INDEX idx_customer_order ON orders REBUILD;
  ```
  *Regular index maintenance (like rebuilding) ensures optimal performance.*

---

These advanced techniques extend the power of SQL, enabling you to handle complex data scenarios, optimize performance, and build more robust applications. Happy querying!
