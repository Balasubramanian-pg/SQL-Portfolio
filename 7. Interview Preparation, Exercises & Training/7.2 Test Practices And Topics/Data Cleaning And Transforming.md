# Data Cleaning Process for Pizza Runner Case Study

## Overview
This SQL script performs data cleaning on two key tables (`customer_orders` and `runner_orders`) to prepare the data for analysis in the Pizza Runner case study. The cleaning addresses inconsistent formatting, null values, and data type issues.

## Customer Orders Table Cleaning

```sql
-- Create cleaned customer_orders temp table
SELECT order_id, customer_id, pizza_id, 
CASE
    WHEN exclusions IS null OR exclusions LIKE 'null' THEN ' '
    ELSE exclusions
    END AS exclusions,
CASE
    WHEN extras IS NULL or extras LIKE 'null' THEN ' '
    ELSE extras
    END AS extras,
    order_time
INTO #customer_orders
FROM customer_orders
```

### Cleaning Actions:
1. **Handling null values** in `exclusions` and `extras` columns:
   - Convert both SQL NULL and string 'null' values to empty strings (' ')
   - Preserves actual values when they exist

## Runner Orders Table Cleaning

```sql
-- First examine table structure
exec sp_help runner_orders

-- Create cleaned runner_orders temp table
SELECT order_id, runner_id,  
CASE
    WHEN pickup_time LIKE 'null' THEN ' '
    ELSE pickup_time
    END AS pickup_time,
CASE
    WHEN distance LIKE 'null' THEN ' '
    WHEN distance LIKE '%km' THEN TRIM('km' from distance)
    ELSE distance
    END AS distance,
CASE
    WHEN duration LIKE 'null' THEN ' '
    WHEN duration LIKE '%mins' THEN TRIM('mins' from duration)
    WHEN duration LIKE '%minute' THEN TRIM('minute' from duration)
    WHEN duration LIKE '%minutes' THEN TRIM('minutes' from duration)
    ELSE duration
    END AS duration,
CASE
    WHEN cancellation IS NULL or cancellation LIKE 'null' THEN ' '
    ELSE cancellation
    END AS cancellation
INTO #runner_orders
FROM runner_orders
```

### Cleaning Actions:
1. **Pickup time**:
   - Convert 'null' strings to empty strings (' ')

2. **Distance**:
   - Convert 'null' strings to empty strings
   - Remove 'km' suffix from distance values while preserving the numeric value
   - Handle cases where distance has no units

3. **Duration**:
   - Convert 'null' strings to empty strings
   - Remove various time-related suffixes ('mins', 'minute', 'minutes')
   - Handle cases where duration has no units

4. **Cancellation**:
   - Convert both SQL NULL and string 'null' values to empty strings
   - Preserve actual cancellation reasons when they exist

## Data Type Conversion

```sql
-- Convert cleaned columns to proper data types
ALTER TABLE #runner_orders
ALTER COLUMN pickup_time DATETIME

ALTER TABLE #runner_orders
ALTER COLUMN distance FLOAT

ALTER TABLE #runner_orders
ALTER COLUMN duration INT
```

### Type Conversions:
1. **pickup_time**: Convert to DATETIME for proper time-based analysis
2. **distance**: Convert to FLOAT for numeric calculations
3. **duration**: Convert to INT for numeric calculations

## Key Cleaning Techniques Used:
1. **CASE WHEN statements**: For conditional value transformations
2. **TRIM() function**: To remove unwanted suffixes
3. **LIKE with wildcards (%)**: For pattern matching
4. **ALTER TABLE**: To modify column data types
5. **Temporary tables (# prefix)**: To store cleaned data without affecting original tables

This cleaning process ensures the data is consistent and properly formatted for subsequent analysis in the Pizza Runner case study.
