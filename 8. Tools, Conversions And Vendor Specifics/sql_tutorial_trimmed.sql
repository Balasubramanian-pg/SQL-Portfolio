-- ============================================================
-- SQL FOR DATA ANALYSTS — TRIMMED TUTORIAL
-- BigQuery Syntax
-- Dataset: orders, order_items
--
-- Replace `your_project.your_dataset` with your actual
-- BigQuery project and dataset name before running.
-- ============================================================


-- ============================================================
-- SECTION 1: SELECT, FROM, AS (Aliases)
-- ============================================================
-- SELECT picks the columns you want to see.
-- FROM tells SQL which table to read from.
-- AS lets you rename a column in the output — called an alias.
-- Aliases make your results easier to read and are required
-- when you create calculated columns.

SELECT
    order_id,
    first_name,
    last_name,
    first_name AS name,              -- alias: rename a column
    order_date,
    status,
    discount_pct AS discount         -- alias: shorter name
FROM `your_project.your_dataset.orders`;


-- ============================================================
-- SECTION 2: WHERE — Filtering rows
-- ============================================================
-- WHERE filters rows before they are returned.
-- Common operators: =, !=, >, <, >=, <=
-- Combine multiple conditions with AND / OR.
-- Use parentheses to control the order of evaluation with OR.

SELECT order_id, customer_id, status, discount_pct, order_date
FROM `your_project.your_dataset.orders`
WHERE status = 'completed'           -- AND: both conditions must be true
  AND discount_pct > 0
   OR status = 'refunded';           -- OR: either condition is enough


-- ============================================================
-- SECTION 3: IN / NOT IN
-- ============================================================
-- IN is a cleaner way to filter against a list of values.
-- It replaces multiple OR conditions.
-- NOT IN excludes those values.
-- Both work with strings, numbers, and dates.

SELECT order_id, first_name, segment, status, discount_pct
FROM `your_project.your_dataset.orders`
WHERE status IN ('cancelled', 'refunded')        -- match any value in the list
  AND discount_pct NOT IN (10, 15, 20);          -- exclude these specific values


-- ============================================================
-- SECTION 4: BETWEEN
-- ============================================================
-- BETWEEN filters values within a range (inclusive on both ends).
-- Works with numbers, dates, and strings.
-- Equivalent to: col >= lower AND col <= upper.

SELECT order_id, customer_id, order_date, discount_pct
FROM `your_project.your_dataset.orders`
WHERE order_date BETWEEN '2024-01-01' AND '2024-06-30'  -- date range
  AND discount_pct BETWEEN 5 AND 15;                     -- numeric range


-- ============================================================
-- SECTION 5: LIKE — Pattern matching
-- ============================================================
-- LIKE searches for a pattern inside a text column.
-- % matches any sequence of characters (before, after, or both).
-- _ matches exactly one character.
-- Use LIKE when you don't know the exact value.

SELECT DISTINCT customer_id, first_name, last_name, email, city
FROM `your_project.your_dataset.orders`
WHERE email LIKE '%email.com'     -- ends with 'email.com'
   OR city  LIKE 'New%'           -- starts with 'New'
   OR last_name LIKE '%son';      -- ends with 'son'


-- ============================================================
-- SECTION 6: ORDER BY + LIMIT
-- ============================================================
-- ORDER BY sorts the results.
-- ASC = smallest to largest (default). DESC = largest to smallest.
-- Sort by multiple columns by separating them with a comma.
-- LIMIT caps rows returned — use it for top/bottom N or previewing data.

SELECT order_id, first_name, segment, order_date, discount_pct
FROM `your_project.your_dataset.orders`
WHERE discount_pct IS NOT NULL
ORDER BY segment ASC,          -- primary sort: segment alphabetically
         discount_pct DESC     -- secondary sort: highest discount first
LIMIT 20;


-- ============================================================
-- SECTION 7: DISTINCT — Remove duplicates
-- ============================================================
-- DISTINCT returns only unique values — it removes duplicate rows.
-- Apply it to multiple columns to get unique combinations.
-- Inside COUNT(), it counts only unique values.

SELECT
    COUNT(DISTINCT customer_id) AS unique_customers,  -- count unique values
    COUNT(DISTINCT country)     AS unique_countries
FROM `your_project.your_dataset.orders`;

SELECT DISTINCT country, segment   -- unique combinations of two columns
FROM `your_project.your_dataset.orders`
ORDER BY country, segment;


-- ============================================================
-- SECTION 8: GROUP BY + Aggregate Functions
-- ============================================================
-- GROUP BY groups rows that share a value so you can aggregate them.
-- Aggregate functions: COUNT, SUM, AVG, MIN, MAX.
-- Every column in SELECT must either be in GROUP BY
-- or wrapped in an aggregate function.

SELECT
    category,
    COUNT(*)                             AS total_line_items,  -- count rows
    SUM(quantity)                        AS total_units,        -- sum values
    ROUND(SUM(quantity * unit_price), 2) AS total_revenue,     -- calculated sum
    ROUND(AVG(unit_price), 2)            AS avg_unit_price,    -- average
    MIN(unit_price)                      AS cheapest,          -- minimum
    MAX(unit_price)                      AS most_expensive     -- maximum
FROM `your_project.your_dataset.order_items`
GROUP BY category
ORDER BY total_revenue DESC;


-- ============================================================
-- SECTION 9: HAVING — Filtering after GROUP BY
-- ============================================================
-- WHERE filters rows BEFORE grouping.
-- HAVING filters groups AFTER aggregation.
-- You can use both in the same query: WHERE first, HAVING second.
-- Rule: if your filter references an aggregate function, use HAVING.

SELECT
    country,
    COUNT(*) AS completed_orders,
    ROUND(AVG(discount_pct), 1) AS avg_discount
FROM `your_project.your_dataset.orders`
WHERE status = 'completed'          -- filters rows BEFORE grouping
GROUP BY country
HAVING COUNT(*) > 5                 -- filters groups AFTER aggregation
ORDER BY completed_orders DESC;


-- ============================================================
-- SECTION 10: CASE WHEN — Conditional logic
-- ============================================================
-- CASE WHEN lets you add if/else logic inside a query.
-- It creates a new column based on conditions.
-- Always close with END, optionally alias with AS.
-- You can use CASE WHEN inside GROUP BY for grouped summaries.

SELECT
    CASE
        WHEN discount_pct IS NULL OR discount_pct = 0 THEN 'No Discount'
        WHEN discount_pct <= 10                       THEN 'Low'
        WHEN discount_pct <= 15                       THEN 'Mid'
        ELSE                                               'High'
    END                AS discount_tier,  -- multi-condition CASE
    CASE segment
        WHEN 'Premium'  THEN 'High Value'
        WHEN 'Standard' THEN 'Mid Value'
        ELSE                 'Entry Level'
    END                AS value_label,    -- shorthand CASE on a single column
    COUNT(*)           AS order_count
FROM `your_project.your_dataset.orders`
GROUP BY discount_tier, value_label
ORDER BY order_count DESC;


-- ============================================================
-- SECTION 11: IS NULL / COALESCE — Handling missing values
-- ============================================================
-- NULL means a value is missing or unknown.
-- IS NULL / IS NOT NULL check for missing values.
-- You cannot use = NULL — it always returns nothing.
-- COALESCE returns the first non-NULL value from a list.

SELECT
    customer_id,
    first_name,
    email,
    COALESCE(email, 'no-email@unknown.com')  AS email_clean,    -- replace NULL with default
    discount_pct,
    COALESCE(discount_pct, 0)               AS discount_clean   -- replace NULL with 0
FROM `your_project.your_dataset.orders`
WHERE email IS NULL                -- filter: only rows missing email
   OR discount_pct IS NULL;        -- OR also missing discount


-- ============================================================
-- SECTION 12: CAST + SAFE_CAST — Type conversion
-- ============================================================
-- CAST converts a value from one data type to another.
-- SAFE_CAST is BigQuery-specific: returns NULL instead of crashing
-- on a bad conversion. Always prefer SAFE_CAST when data quality
-- is uncertain.

SELECT
    order_id,
    order_date,
    CAST(order_date AS STRING)          AS order_date_text,  -- DATE → STRING
    discount_pct,
    CAST(discount_pct AS INT64)         AS discount_int,     -- FLOAT → INT
    SAFE_CAST(discount_pct AS INT64)    AS discount_safe     -- safe version: NULL on error
FROM `your_project.your_dataset.orders`
WHERE discount_pct IS NOT NULL
LIMIT 20;


-- ============================================================
-- SECTION 13: String Functions — UPPER, LOWER, CONCAT, TRIM
-- ============================================================
-- String functions let you clean and reshape text data.
-- UPPER / LOWER: standardise case.
-- CONCAT: join multiple strings together.
-- TRIM: remove leading and trailing spaces.
-- LENGTH: count characters in a string.

SELECT
    customer_id,
    CONCAT(
        UPPER(TRIM(first_name)), ' ',
        UPPER(TRIM(last_name))
    )                              AS full_name_upper,  -- CONCAT + UPPER + TRIM combined
    LOWER(TRIM(email))             AS email_clean,      -- LOWER + TRIM
    city,
    LENGTH(city)                   AS city_name_length  -- number of characters
FROM `your_project.your_dataset.orders`
WHERE email IS NOT NULL
ORDER BY full_name_upper;


-- ============================================================
-- SECTION 14: Date Functions — DATE_DIFF, DATE_TRUNC, EXTRACT, DATE_ADD
-- ============================================================
-- DATE_DIFF: number of days/months/years between two dates.
-- DATE_TRUNC: round a date down to the start of a period (month, year…).
-- EXTRACT: pull out a single part of a date (year, month, day of week…).
-- DATE_ADD: add an interval to a date.

SELECT
    order_id,
    order_date,
    DATE_DIFF(CURRENT_DATE(), order_date, DAY)  AS days_since_order, -- days between dates
    DATE_TRUNC(order_date, MONTH)               AS order_month,      -- first day of month
    EXTRACT(YEAR  FROM order_date)              AS order_year,       -- extract year
    EXTRACT(MONTH FROM order_date)              AS order_month_num,  -- extract month number
    DATE_ADD(order_date, INTERVAL 30 DAY)       AS estimated_delivery -- add 30 days
FROM `your_project.your_dataset.orders`
ORDER BY order_date DESC
LIMIT 20;


-- ============================================================
-- SECTION 15: INNER JOIN
-- ============================================================
-- JOIN combines rows from two tables based on a shared key.
-- INNER JOIN returns only rows that have a match in BOTH tables.
-- Rows without a match on either side are dropped.
-- Alias your tables (AS o, AS oi) to keep the query readable.

SELECT
    o.order_id,
    o.first_name,
    o.last_name,
    o.order_date,
    o.status,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS order_total  -- aggregate after join
FROM `your_project.your_dataset.orders`           AS o
INNER JOIN `your_project.your_dataset.order_items` AS oi
    ON o.order_id = oi.order_id
GROUP BY o.order_id, o.first_name, o.last_name, o.order_date, o.status
ORDER BY order_total DESC
LIMIT 20;


-- ============================================================
-- SECTION 16: LEFT JOIN
-- ============================================================
-- LEFT JOIN returns ALL rows from the left table,
-- plus matching rows from the right table.
-- If there is no match, the right-table columns are NULL.
-- Filtering WHERE right_table.col IS NULL finds unmatched rows.

-- All orders with their items — unmatched orders show NULL on right side.
-- Then filter to find orders with no items at all.
SELECT
    o.order_id,
    o.status,
    o.order_date,
    oi.product_name,                -- NULL when no matching item exists
    oi.quantity
FROM `your_project.your_dataset.orders`           AS o
LEFT JOIN `your_project.your_dataset.order_items` AS oi
    ON o.order_id = oi.order_id
WHERE oi.order_item_id IS NULL;     -- keep only orders with NO items


-- ============================================================
-- SECTION 17: UNION ALL
-- ============================================================
-- UNION ALL stacks the results of two queries on top of each other.
-- Both queries must return the same number of columns
-- with compatible data types.
-- UNION ALL keeps duplicates. UNION removes them (slower — avoid unless needed).
-- Common use case: combining data from different time periods or sources.

SELECT
    order_id,
    customer_id,
    order_date,
    status,
    '2023' AS order_year            -- label to identify the source
FROM `your_project.your_dataset.orders`
WHERE order_date BETWEEN '2023-01-01' AND '2023-12-31'

UNION ALL

SELECT
    order_id,
    customer_id,
    order_date,
    status,
    '2024' AS order_year
FROM `your_project.your_dataset.orders`
WHERE order_date BETWEEN '2024-01-01' AND '2024-12-31';


-- ============================================================
-- SECTION 18: Subqueries
-- ============================================================
-- A subquery is a query nested inside another query.
-- You can place it in WHERE (to filter), FROM (as a derived table),
-- or SELECT (as a scalar value).
-- Use subqueries when you need the result of one query
-- to drive another.

SELECT
    order_id,
    customer_id,
    first_name,
    order_date,
    status
FROM `your_project.your_dataset.orders`
WHERE customer_id IN (              -- subquery in WHERE: filter using another query
    SELECT DISTINCT customer_id
    FROM `your_project.your_dataset.orders`
    WHERE segment = 'Premium'       -- inner query finds all Premium customer IDs
);


-- ============================================================
-- SECTION 19: CTEs — WITH clause
-- ============================================================
-- A CTE (Common Table Expression) is a named subquery defined
-- at the top of the query using WITH.
-- CTEs make complex queries easier to read and debug —
-- think of them as temporary named tables.
-- Chain multiple CTEs by separating them with a comma.

WITH order_totals AS (              -- first CTE: compute total per order
    SELECT
        order_id,
        ROUND(SUM(quantity * unit_price), 2) AS order_total
    FROM `your_project.your_dataset.order_items`
    GROUP BY order_id
),
avg_total AS (                      -- second CTE: compute the average of those totals
    SELECT AVG(order_total) AS avg_order_value
    FROM order_totals
)
SELECT
    ot.order_id,
    o.first_name,
    o.segment,
    ot.order_total,
    ROUND(at.avg_order_value, 2) AS avg_order_value
FROM order_totals AS ot
INNER JOIN avg_total AS at ON TRUE
INNER JOIN `your_project.your_dataset.orders` AS o ON o.order_id = ot.order_id
WHERE ot.order_total > at.avg_order_value   -- filter using the CTE result
ORDER BY ot.order_total DESC;


-- ============================================================
-- SECTION 20: Window Functions — ROW_NUMBER, RANK
-- ============================================================
-- Window functions perform a calculation across a set of rows
-- related to the current row — without collapsing rows like GROUP BY.
-- OVER() defines the window. PARTITION BY splits into groups.
-- ROW_NUMBER: always unique. RANK: ties share the same rank (with gaps after).

WITH product_sales AS (
    SELECT
        category,
        product_name,
        SUM(quantity) AS total_units
    FROM `your_project.your_dataset.order_items`
    GROUP BY category, product_name
)
SELECT
    category,
    product_name,
    total_units,
    ROW_NUMBER() OVER (PARTITION BY category ORDER BY total_units DESC) AS row_num,  -- always unique
    RANK()       OVER (PARTITION BY category ORDER BY total_units DESC) AS rank_num  -- ties share rank
FROM product_sales
ORDER BY category, rank_num;


-- ============================================================
-- SECTION 21: Window Functions — LAG / LEAD
-- ============================================================
-- LAG lets you look at a previous row's value within the window.
-- LEAD lets you look at the next row's value.
-- Very useful for comparing a value to the prior period
-- (e.g. month-over-month revenue change).

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC(o.order_date, MONTH)             AS order_month,
        ROUND(SUM(oi.quantity * oi.unit_price), 2)  AS revenue
    FROM `your_project.your_dataset.orders`           AS o
    INNER JOIN `your_project.your_dataset.order_items` AS oi
        ON o.order_id = oi.order_id
    WHERE o.status = 'completed'
    GROUP BY order_month
)
SELECT
    order_month,
    revenue,
    LAG(revenue, 1) OVER (ORDER BY order_month)  AS prev_month_revenue,
    ROUND(
        revenue - LAG(revenue, 1) OVER (ORDER BY order_month),
    2) AS revenue_change
FROM monthly_revenue
ORDER BY order_month;


-- ============================================================
-- SECTION 22: Window Functions — Running Total with SUM OVER
-- ============================================================
-- SUM() OVER() calculates a cumulative (running) total.
-- ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
-- means "sum everything from the first row up to and including this row".
-- Great for cumulative revenue, running balances, and progress tracking.

WITH daily_revenue AS (
    SELECT
        o.order_date,
        ROUND(SUM(oi.quantity * oi.unit_price), 2) AS daily_revenue
    FROM `your_project.your_dataset.orders`           AS o
    INNER JOIN `your_project.your_dataset.order_items` AS oi
        ON o.order_id = oi.order_id
    WHERE o.status = 'completed'
    GROUP BY o.order_date
)
SELECT
    order_date,
    daily_revenue,
    ROUND(
        SUM(daily_revenue) OVER (
            ORDER BY order_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ),
    2) AS cumulative_revenue
FROM daily_revenue
ORDER BY order_date;


-- ============================================================
-- SECTION 23: QUALIFY — Filter on Window Function results
-- ============================================================
-- QUALIFY is BigQuery-specific (also in Snowflake).
-- It filters rows AFTER window functions have been computed.
-- Without QUALIFY, you would need a subquery or CTE just to filter
-- on a window function result. QUALIFY makes it one clean query.
-- Most common use: get the latest (or top N) row per group.

SELECT
    order_id,
    customer_id,
    first_name,
    last_name,
    order_date,
    status
FROM `your_project.your_dataset.orders`
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY customer_id
    ORDER BY order_date DESC    -- most recent order per customer
) = 1;
