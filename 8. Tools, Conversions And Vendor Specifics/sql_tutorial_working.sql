-- ============================================================
-- SQL FOR DATA ANALYSTS — WORKING FILE
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


-- ============================================================
-- SECTION 2: WHERE — Filtering rows
-- ============================================================
-- WHERE filters rows before they are returned.
-- Common operators: =, !=, >, <, >=, <=
-- Combine multiple conditions with AND / OR.
-- Use parentheses to control the order of evaluation with OR.


-- ============================================================
-- SECTION 3: IN / NOT IN
-- ============================================================
-- IN is a cleaner way to filter against a list of values.
-- It replaces multiple OR conditions.
-- NOT IN excludes those values.
-- Both work with strings, numbers, and dates.


-- ============================================================
-- SECTION 4: BETWEEN
-- ============================================================
-- BETWEEN filters values within a range (inclusive on both ends).
-- Works with numbers, dates, and strings.
-- Equivalent to: col >= lower AND col <= upper.


-- ============================================================
-- SECTION 5: LIKE — Pattern matching
-- ============================================================
-- LIKE searches for a pattern inside a text column.
-- % matches any sequence of characters (before, after, or both).
-- _ matches exactly one character.
-- Use LIKE when you don't know the exact value.


-- ============================================================
-- SECTION 6: ORDER BY + LIMIT
-- ============================================================
-- ORDER BY sorts the results.
-- ASC = smallest to largest (default). DESC = largest to smallest.
-- Sort by multiple columns by separating them with a comma.
-- LIMIT caps rows returned — use it for top/bottom N or previewing data.


-- ============================================================
-- SECTION 7: DISTINCT — Remove duplicates
-- ============================================================
-- DISTINCT returns only unique values — it removes duplicate rows.
-- Apply it to multiple columns to get unique combinations.
-- Inside COUNT(), it counts only unique values.


-- ============================================================
-- SECTION 8: GROUP BY + Aggregate Functions
-- ============================================================
-- GROUP BY groups rows that share a value so you can aggregate them.
-- Aggregate functions: COUNT, SUM, AVG, MIN, MAX.
-- Every column in SELECT must either be in GROUP BY
-- or wrapped in an aggregate function.


-- ============================================================
-- SECTION 9: HAVING — Filtering after GROUP BY
-- ============================================================
-- WHERE filters rows BEFORE grouping.
-- HAVING filters groups AFTER aggregation.
-- You can use both in the same query: WHERE first, HAVING second.
-- Rule: if your filter references an aggregate function, use HAVING.


-- ============================================================
-- SECTION 10: CASE WHEN — Conditional logic
-- ============================================================
-- CASE WHEN lets you add if/else logic inside a query.
-- It creates a new column based on conditions.
-- Always close with END, optionally alias with AS.
-- You can use CASE WHEN inside GROUP BY for grouped summaries.


-- ============================================================
-- SECTION 11: IS NULL / COALESCE — Handling missing values
-- ============================================================
-- NULL means a value is missing or unknown.
-- IS NULL / IS NOT NULL check for missing values.
-- You cannot use = NULL — it always returns nothing.
-- COALESCE returns the first non-NULL value from a list.


-- ============================================================
-- SECTION 12: CAST + SAFE_CAST — Type conversion
-- ============================================================
-- CAST converts a value from one data type to another.
-- SAFE_CAST is BigQuery-specific: returns NULL instead of crashing
-- on a bad conversion. Always prefer SAFE_CAST when data quality
-- is uncertain.


-- ============================================================
-- SECTION 13: String Functions — UPPER, LOWER, CONCAT, TRIM
-- ============================================================
-- String functions let you clean and reshape text data.
-- UPPER / LOWER: standardise case.
-- CONCAT: join multiple strings together.
-- TRIM: remove leading and trailing spaces.
-- LENGTH: count characters in a string.


-- ============================================================
-- SECTION 14: Date Functions — DATE_DIFF, DATE_TRUNC, EXTRACT, DATE_ADD
-- ============================================================
-- DATE_DIFF: number of days/months/years between two dates.
-- DATE_TRUNC: round a date down to the start of a period (month, year…).
-- EXTRACT: pull out a single part of a date (year, month, day of week…).
-- DATE_ADD: add an interval to a date.


-- ============================================================
-- SECTION 15: INNER JOIN
-- ============================================================
-- JOIN combines rows from two tables based on a shared key.
-- INNER JOIN returns only rows that have a match in BOTH tables.
-- Rows without a match on either side are dropped.
-- Alias your tables (AS o, AS oi) to keep the query readable.


-- ============================================================
-- SECTION 16: LEFT JOIN
-- ============================================================
-- LEFT JOIN returns ALL rows from the left table,
-- plus matching rows from the right table.
-- If there is no match, the right-table columns are NULL.
-- Filtering WHERE right_table.col IS NULL finds unmatched rows.


-- ============================================================
-- SECTION 17: UNION ALL
-- ============================================================
-- UNION ALL stacks the results of two queries on top of each other.
-- Both queries must return the same number of columns
-- with compatible data types.
-- UNION ALL keeps duplicates. UNION removes them (slower — avoid unless needed).
-- Common use case: combining data from different time periods or sources.


-- ============================================================
-- SECTION 18: Subqueries
-- ============================================================
-- A subquery is a query nested inside another query.
-- You can place it in WHERE (to filter), FROM (as a derived table),
-- or SELECT (as a scalar value).
-- Use subqueries when you need the result of one query
-- to drive another.


-- ============================================================
-- SECTION 19: CTEs — WITH clause
-- ============================================================
-- A CTE (Common Table Expression) is a named subquery defined
-- at the top of the query using WITH.
-- CTEs make complex queries easier to read and debug —
-- think of them as temporary named tables.
-- Chain multiple CTEs by separating them with a comma.


-- ============================================================
-- SECTION 20: Window Functions — ROW_NUMBER, RANK
-- ============================================================
-- Window functions perform a calculation across a set of rows
-- related to the current row — without collapsing rows like GROUP BY.
-- OVER() defines the window. PARTITION BY splits into groups.
-- ROW_NUMBER: always unique. RANK: ties share the same rank (with gaps after).


-- ============================================================
-- SECTION 21: Window Functions — LAG / LEAD
-- ============================================================
-- LAG lets you look at a previous row's value within the window.
-- LEAD lets you look at the next row's value.
-- Very useful for comparing a value to the prior period
-- (e.g. month-over-month revenue change).


-- ============================================================
-- SECTION 22: Window Functions — Running Total with SUM OVER
-- ============================================================
-- SUM() OVER() calculates a cumulative (running) total.
-- ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
-- means "sum everything from the first row up to and including this row".
-- Great for cumulative revenue, running balances, and progress tracking.


-- ============================================================
-- SECTION 23: QUALIFY — Filter on Window Function results
-- ============================================================
-- QUALIFY is BigQuery-specific (also in Snowflake).
-- It filters rows AFTER window functions have been computed.
-- Without QUALIFY, you would need a subquery or CTE just to filter
-- on a window function result. QUALIFY makes it one clean query.
-- Most common use: get the latest (or top N) row per group.
