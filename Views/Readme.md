# PostgreSQL Views: Complete Guide

## **Table of Contents**
1. [What Are Views?](#what-are-views)
2. [Basic View Creation](#basic-view-creation)
3. [Advanced View Types](#advanced-view-types)
4. [Modifying Views](#modifying-views)
5. [View Information & Metadata](#view-metadata)
6. [Materialized Views](#materialized-views)
7. [Performance Considerations](#performance)
8. [Security with Views](#security)
9. [Common Use Cases](#use-cases)
10. [Troubleshooting](#troubleshooting)

## **1. What Are Views?**
A view is a **virtual table** based on the result set of a SQL query. Views:
- Don't store data physically (except materialized views)
- Always show current data from underlying tables
- Can simplify complex queries
- Provide security by restricting access to specific columns/rows

```sql
-- Conceptual representation
/*
Original Tables:    [Customers] → [Orders] → [Products]
View:               [Customer_Order_Summary]
*/
```

## Create the Customer Table
```sql
CREATE TABLE customers (
    customer_id   SERIAL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email         VARCHAR(150) UNIQUE NOT NULL,
    join_date     DATE NOT NULL,
    is_active     BOOLEAN DEFAULT TRUE
);
```

That way, your `active_customers` view will work straight away.

## **2. Basic View Creation**

### **Simple View**
```sql
-- Create a view showing active customers
CREATE VIEW active_customers AS
SELECT
    customer_id,
    customer_name,
    email,
    join_date
FROM
    customers
WHERE
    is_active = TRUE
ORDER BY
    join_date DESC;

-- Use the view
SELECT * FROM active_customers;
```

### **View with Joins**
```sql
-- Create a customer orders view
CREATE VIEW customer_order_summary AS
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders,
    SUM(o.amount) AS total_spent,
    MAX(o.order_date) AS last_order_date
FROM
    customers c
LEFT JOIN
    orders o ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id, c.customer_name;
```

### **View with Parameters (PostgreSQL 9.2+)**
```sql
-- Create a function that acts like a parameterized view
CREATE FUNCTION get_customer_orders(p_customer_id INT)
RETURNS TABLE (
    order_id INT,
    order_date DATE,
    amount NUMERIC,
    status VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        o.order_id,
        o.order_date,
        o.amount,
        o.status
    FROM
        orders o
    WHERE
        o.customer_id = p_customer_id
    ORDER BY
        o.order_date DESC;
END;
$$ LANGUAGE plpgsql;

-- Call the function
SELECT * FROM get_customer_orders(123);
```

---
## **3. Advanced View Types**

### **Recursive View**
```sql
-- Organizational hierarchy view
CREATE RECURSIVE VIEW employee_hierarchy AS
-- Base case: top-level employees
SELECT
    employee_id,
    name,
    manager_id,
    1 AS level,
    ARRAY[name] AS path
FROM
    employees
WHERE
    manager_id IS NULL

UNION ALL

-- Recursive case: subordinates
SELECT
    e.employee_id,
    e.name,
    e.manager_id,
    eh.level + 1,
    eh.path || e.name
FROM
    employees e
JOIN
    employee_hierarchy eh ON e.manager_id = eh.employee_id;
```

### **Updatable View**
```sql
-- Create an updatable view (must meet specific criteria)
CREATE VIEW product_inventory AS
SELECT
    product_id,
    product_name,
    quantity_in_stock,
    price
FROM
    products
WHERE
    discontinued = FALSE
WITH CHECK OPTION;  -- Ensures modifications conform to view definition

-- Update through the view
UPDATE product_inventory
SET price = price * 1.1
WHERE
    quantity_in_stock < 100;
```

### **View with Window Functions**
```sql
-- Customer ranking by total spending
CREATE VIEW customer_ranking AS
SELECT
    customer_id,
    customer_name,
    SUM(amount) AS total_spent,
    RANK() OVER (ORDER BY SUM(amount) DESC) AS spending_rank
FROM
    customers c
JOIN
    orders o ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id, c.customer_name;
```

---
## **4. Modifying Views**

### **Replace a View**
```sql
-- Completely replace an existing view
CREATE OR REPLACE VIEW customer_order_summary AS
SELECT
    c.customer_id,
    c.customer_name,
    c.email,
    COUNT(o.order_id) AS total_orders,
    SUM(o.amount) AS total_spent,
    MAX(o.order_date) AS last_order_date,
    AVG(o.amount) AS avg_order_value
FROM
    customers c
LEFT JOIN
    orders o ON c.customer_id = o.customer_id
WHERE
    o.order_date > CURRENT_DATE - INTERVAL '1 year'
GROUP BY
    c.customer_id, c.customer_name, c.email;
```

### **Add Comments**
```sql
COMMENT ON VIEW customer_order_summary IS
'Shows customer order summary for the past year including total orders,
total spending, last order date, and average order value. Updated 2023-11-15';
```

### **Rename a View**
```sql
ALTER VIEW customer_order_summary RENAME TO customer_order_stats;
```

### **Drop a View**
```sql
DROP VIEW IF EXISTS old_view_name;
```

---
## **5. View Information & Metadata**

### **List All Views**
```sql
-- Method 1: Using information_schema
SELECT
    table_schema,
    table_name,
    view_definition
FROM
    information_schema.views
WHERE
    table_schema NOT IN ('pg_catalog', 'information_schema')
ORDER BY
    table_schema, table_name;

-- Method 2: Using pg_class
SELECT
    n.nspname AS schema_name,
    c.relname AS view_name,
    pg_get_viewdef(c.oid) AS definition
FROM
    pg_class c
JOIN
    pg_namespace n ON c.relnamespace = n.oid
WHERE
    c.relkind = 'v'  -- 'v' for views
    AND n.nspname NOT LIKE 'pg_%'
ORDER BY
    n.nspname, c.relname;
```

### **View Dependencies**
```sql
-- Find tables used by a view
SELECT
    dependent_ns.nspname AS view_schema,
    dependent_view.relname AS view_name,
    source_ns.nspname AS table_schema,
    source_table.relname AS table_name
FROM
    pg_depend d
JOIN
    pg_rewrite r ON d.objid = r.oid
JOIN
    pg_class dependent_view ON d.objid = dependent_view.oid
JOIN
    pg_namespace dependent_ns ON dependent_ns.oid = dependent_view.relnamespace
JOIN
    pg_class source_table ON d.refobjid = source_table.oid
JOIN
    pg_namespace source_ns ON source_ns.oid = source_table.relnamespace
WHERE
    d.deptype = 'n'  -- normal dependency
    AND d.classid = 'pg_rewrite'::regclass
    AND dependent_view.relname = 'your_view_name';
```

### **View Definition**
```sql
-- Get the SQL definition of a view
SELECT
    pg_get_viewdef('public.customer_order_summary'::regclass, true);

-- Alternative with more details
SELECT
    viewname AS view_name,
    definition AS view_definition,
    check_option AS is_updatable
FROM
    pg_views
WHERE
    schemaname = 'public'
    AND viewname = 'customer_order_summary';
```

---
## **6. Materialized Views**

### **Create Materialized View**
```sql
-- Creates a physical copy of the data
CREATE MATERIALIZED VIEW monthly_sales_report AS
SELECT
    DATE_TRUNC('month', order_date) AS month,
    product_category,
    SUM(quantity) AS total_units,
    SUM(amount) AS total_sales,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM
    orders o
JOIN
    order_items oi ON o.order_id = oi.order_id
JOIN
    products p ON oi.product_id = p.product_id
GROUP BY
    DATE_TRUNC('month', order_date), product_category;

-- Add indexes for performance
CREATE INDEX idx_monthly_sales_month ON monthly_sales_report(month);
CREATE INDEX idx_monthly_sales_category ON monthly_sales_report(product_category);
```

### **Refresh Materialized View**
```sql
-- Complete refresh (recalculates all data)
REFRESH MATERIALIZED VIEW monthly_sales_report;

-- Concurrent refresh (allows queries during refresh)
REFRESH MATERIALIZED VIEW CONCURRENTLY monthly_sales_report;
```

### **Automate Refresh**
```sql
-- Create a function to refresh
CREATE FUNCTION refresh_materialized_views()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY monthly_sales_report;
    -- Add other materialized views here
END;
$$ LANGUAGE plpgsql;

-- Schedule with pg_cron (if installed)
SELECT cron.schedule(
    'refresh-mviews',
    '0 3 * * *',  -- Every day at 3 AM
    'SELECT refresh_materialized_views()'
);
```

---
## **7. Performance Considerations**

### **View Performance Tips**
```sql
-- 1. Add appropriate indexes to underlying tables
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);

-- 2. Use WITH (NOEXPAND) hint for complex views (PostgreSQL 14+)
CREATE VIEW complex_view AS
WITH (noexpand)
SELECT /* complex query */ FROM large_table;

-- 3. Analyze views for the query planner
ANALYZE customer_order_summary;

-- 4. Check view performance
EXPLAIN ANALYZE SELECT * FROM customer_order_summary WHERE total_orders > 10;
```

### **View vs Materialized View**
| Feature               | Regular View               | Materialized View           |
|-----------------------|----------------------------|-----------------------------|
| Storage               | No physical storage        | Stores data physically      |
| Data Freshness        | Always current             | Requires refresh            |
| Query Performance     | Slower (runs query each time) | Faster (pre-computed)      |
| Storage Requirements  | None                       | Requires disk space         |
| Best For              | Frequently changing data   | Static or periodically updated data |

---
## **8. Security with Views**

### **Row-Level Security**
```sql
-- Create a view that enforces row-level security
CREATE VIEW my_orders AS
SELECT * FROM orders
WHERE customer_id = current_setting('app.current_user_id')::integer;

-- Set the user context
SET app.current_user_id = 123;
SELECT * FROM my_orders;
```

### **Column-Level Security**
```sql
-- View that excludes sensitive columns
CREATE VIEW public_customer_data AS
SELECT
    customer_id,
    customer_name,
    email,
    -- Exclude phone_number and credit_card
    join_date,
    last_purchase_date
FROM
    customers;
```

### **Grant Permissions**
```sql
-- Grant select on view while restricting base table access
GRANT SELECT ON customer_order_summary TO reporting_user;
REVOKE ALL ON customers, orders FROM reporting_user;
```

---
## **9. Common Use Cases**

### **Simplify Complex Queries**
```sql
-- Instead of writing this complex query repeatedly:
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS order_count,
    SUM(o.amount) AS total_spent,
    AVG(o.amount) AS avg_order,
    MAX(o.order_date) AS last_order
FROM
    customers c
LEFT JOIN
    orders o ON c.customer_id = o.customer_id
WHERE
    o.order_date > CURRENT_DATE - INTERVAL '90 days'
GROUP BY
    c.customer_id, c.customer_name;

-- You can just use:
SELECT * FROM recent_customer_activity;
```

### **Data Abstraction**
```sql
-- Hide complex table structure
CREATE VIEW product_catalog AS
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    p.price,
    COALESCE(i.quantity, 0) AS in_stock,
    p.rating
FROM
    products p
JOIN
    categories c ON p.category_id = c.category_id
LEFT JOIN
    inventory i ON p.product_id = i.product_id
WHERE
    p.is_active = TRUE;
```

### **Backward Compatibility**
```sql
-- When schema changes, views can maintain old interface
CREATE VIEW legacy_customer_view AS
SELECT
    customer_id AS id,          -- old column name
    customer_name AS name,      -- old column name
    email,
    phone AS telephone,         -- old column name
    address_line1 AS address    -- old column name
FROM
    customers;
```

### **Data Aggregation**
```sql
-- Pre-aggregated data for dashboards
CREATE VIEW sales_dashboard AS
SELECT
    DATE_TRUNC('day', order_date) AS day,
    COUNT(DISTINCT customer_id) AS new_customers,
    SUM(amount) AS total_sales,
    COUNT(order_id) AS total_orders,
    SUM(amount)/COUNT(order_id) AS avg_order_value
FROM
    orders
GROUP BY
    DATE_TRUNC('day', order_date);
```

---
## **10. Troubleshooting**

### **Common Issues & Solutions**

**Problem 1: "cannot insert into view"**
```sql
-- Solution: Create the view with WITH CHECK OPTION
CREATE OR REPLACE VIEW updatable_customers AS
SELECT * FROM customers WHERE is_active = TRUE
WITH CHECK OPTION;

-- Or use INSTEAD OF triggers
CREATE OR REPLACE FUNCTION customers_view_insert()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO customers (customer_id, name, email)
    VALUES (NEW.customer_id, NEW.name, NEW.email);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER customers_view_insert_trigger
INSTEAD OF INSERT ON updatable_customers
FOR EACH ROW EXECUTE FUNCTION customers_view_insert();
```

**Problem 2: View is slow**
```sql
-- Solution: Check the execution plan
EXPLAIN ANALYZE SELECT * FROM your_slow_view;

-- Common fixes:
-- 1. Add indexes to underlying tables
-- 2. Consider materialized view if data doesn't need to be real-time
-- 3. Simplify the view definition
```

**Problem 3: "relation does not exist"**
```sql
-- Solution: Check schema qualification
SELECT * FROM information_schema.views
WHERE table_name = 'your_view';

-- If needed, schema-qualify your view name
SELECT * FROM public.your_view;
```

**Problem 4: Circular view references**
```sql
-- Solution: Restructure your views to avoid circular dependencies
/*
BAD:
View A references View B
View B references View A

GOOD:
View A references Table X
View B references Table X
*/
```

---
## **Best Practices**

1. **Naming Conventions**
   ```sql
   -- Prefix views for clarity
   CREATE VIEW vw_customer_summary AS ...
   CREATE VIEW rpt_monthly_sales AS ...  -- for reporting views
   ```

2. **Document Your Views**
   ```sql
   COMMENT ON VIEW customer_order_summary IS
   'Provides summary of customer orders including count, total spend,
   and last order date. Used by sales team for customer analysis.
   Last updated: 2023-11-15';
   ```

3. **Version Control**
   ```sql
   -- Store view definitions in version control
   -- Example directory structure:
   /*
   /sql
     /views
       /current
         v_customer_summary.sql
       /archive
         v_customer_summary_20231001.sql
   */
   ```

4. **Testing Views**
   ```sql
   -- Create test cases for views
   BEGIN;
   -- Setup test data
   INSERT INTO customers VALUES (...);
   INSERT INTO orders VALUES (...);

   -- Test view output
   SELECT * FROM customer_order_summary WHERE customer_id = 999;

   -- Verify counts
   SELECT
     (SELECT COUNT(*) FROM customer_order_summary) AS view_count,
     (SELECT COUNT(DISTINCT customer_id) FROM orders) AS expected_count;
   ROLLBACK;
   ```

5. **Dependency Management**
   ```sql
   -- Check view dependencies before making schema changes
   SELECT * FROM pg_depend
   WHERE refobjid = 'your_table'::regclass;
   ```

6. **Avoid SELECT * in Views**
   ```sql
   -- Bad: Column changes in base table break the view
   CREATE VIEW bad_view AS SELECT * FROM customers;

   -- Good: Explicit column list
   CREATE VIEW good_view AS
   SELECT
       customer_id,
       customer_name,
       email
   FROM
       customers;
   ```

---
## **Complete Example: E-commerce Views**

```sql
-- 1. Customer summary view
CREATE OR REPLACE VIEW vw_customer_summary AS
SELECT
    c.customer_id,
    c.customer_name,
    c.email,
    c.join_date,
    COUNT(o.order_id) AS total_orders,
    SUM(o.amount) AS lifetime_value,
    MAX(o.order_date) AS last_order_date,
    EXTRACT(DAY FROM (CURRENT_DATE - MAX(o.order_date))) AS days_since_last_order
FROM
    customers c
LEFT JOIN
    orders o ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id;

-- 2. Product performance view
CREATE OR REPLACE VIEW vw_product_performance AS
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    COUNT(oi.order_item_id) AS units_sold,
    SUM(oi.quantity * oi.unit_price) AS revenue,
    SUM(oi.quantity) AS total_quantity,
    AVG(r.rating) AS avg_rating
FROM
    products p
JOIN
    categories c ON p.category_id = c.category_id
LEFT JOIN
    order_items oi ON p.product_id = oi.product_id
LEFT JOIN
    reviews r ON p.product_id = r.product_id
GROUP BY
    p.product_id, p.product_name, c.category_name;

-- 3. Daily sales view
CREATE OR REPLACE VIEW vw_daily_sales AS
SELECT
    DATE_TRUNC('day', o.order_date) AS sale_date,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(o.amount) AS total_sales,
    SUM(oi.quantity) AS total_items,
    COUNT(DISTINCT o.customer_id) AS customer_count
FROM
    orders o
JOIN
    order_items oi ON o.order_id = oi.order_id
GROUP BY
    DATE_TRUNC('day', o.order_date);

-- 4. Inventory alert view
CREATE OR REPLACE VIEW vw_low_inventory AS
SELECT
    p.product_id,
    p.product_name,
    i.quantity_in_stock,
    i.reorder_threshold,
    s.supplier_name,
    s.lead_time_days
FROM
    products p
JOIN
    inventory i ON p.product_id = i.product_id
JOIN
    suppliers s ON p.supplier_id = s.supplier_id
WHERE
    i.quantity_in_stock <= i.reorder_threshold
ORDER BY
    i.quantity_in_stock;
```

---
## **View Management Scripts**

### **Generate CREATE VIEW Statements for All Views**
```sql
SELECT
    format(
        'CREATE OR REPLACE VIEW %I.%I AS %s;',
        n.nspname,
        c.relname,
        pg_get_viewdef(c.oid, true)
    ) AS create_view_statement
FROM
    pg_class c
JOIN
    pg_namespace n ON c.relnamespace = n.oid
WHERE
    c.relkind = 'v'
    AND n.nspname NOT IN ('pg_catalog', 'information_schema');
```

### **Find Unused Views**
```sql
SELECT
    n.nspname AS schema_name,
    c.relname AS view_name,
    pg_stat_user_views.seq_scan,
    pg_stat_user_views.seq_tup_read,
    pg_stat_user_views.last_seq_scan
FROM
    pg_class c
JOIN
    pg_namespace n ON c.relnamespace = n.oid
LEFT JOIN
    pg_stat_user_views ON c.oid = pg_stat_user_views.relid
WHERE
    c.relkind = 'v'
    AND n.nspname NOT IN ('pg_catalog', 'information_schema')
    AND (pg_stat_user_views.seq_scan IS NULL OR pg_stat_user_views.seq_scan = 0)
ORDER BY
    n.nspname, c.relname;
```

---
### **Final Notes**
- Views are **not** a performance optimization by themselves (they're query shortcuts)
- Materialized views **are** a performance optimization but require maintenance
- Always test view performance with realistic data volumes
- Consider using **pg_stat_statements** to monitor view usage:
  ```sql
  CREATE EXTENSION pg_stat_statements;
  SELECT query, calls, total_time FROM pg_stat_statements
  WHERE query LIKE '%FROM your_view%';
  ```

### **Next Steps**
1. **Experiment**: Create views for your most common queries
2. **Analyze**: Use EXPLAIN to understand view performance
3. **Document**: Add comments to all production views
4. **Automate**: Set up refresh schedules for materialized views
5. **Secure**: Review view permissions as part of your security audit
