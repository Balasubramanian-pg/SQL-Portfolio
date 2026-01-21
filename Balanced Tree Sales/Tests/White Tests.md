## Data Quality Tests

Balanced Tree Sales Analytics Dataset (8 Years)

---

## Purpose of Data Quality Testing

Data quality tests ensure that the synthetic dataset is:

* Internally consistent
* Logically valid
* Analytically trustworthy
* Fit for answering all business questions defined earlier

These tests are written as **SQL validation queries**.
Each test includes:

* What it checks
* Why it matters
* The expected outcome
* The SQL used to validate it

A dataset that passes these checks behaves like a real production dataset.

---

## Testing Strategy Overview

The tests are grouped into five layers:

1. Schema and structural integrity
2. Referential integrity
3. Data completeness and null checks
4. Business rule validation
5. Analytical sanity checks

This mirrors how data quality is typically enforced in data warehouses.

---

## 1. Schema and Structural Integrity Tests

### 1.1 Primary Key Uniqueness

#### Test: `product_details.product_id` must be unique

```sql
SELECT product_id, COUNT(*)
FROM balanced_tree.product_details
GROUP BY product_id
HAVING COUNT(*) > 1;
```

Expected result:

* No rows returned

Why this matters:

* Duplicate product IDs break joins and inflate metrics

---

#### Test: `transactions.txn_id` must be unique

```sql
SELECT txn_id, COUNT(*)
FROM balanced_tree.transactions
GROUP BY txn_id
HAVING COUNT(*) > 1;
```

Expected result:

* No rows returned

---

#### Test: `sales.sales_id` must be unique

```sql
SELECT sales_id, COUNT(*)
FROM balanced_tree.sales
GROUP BY sales_id
HAVING COUNT(*) > 1;
```

Expected result:

* No rows returned

---

## 2. Referential Integrity Tests

### 2.1 Orphaned Sales Records

#### Test: Every sales row must map to a valid transaction

```sql
SELECT s.txn_id
FROM balanced_tree.sales s
LEFT JOIN balanced_tree.transactions t
    ON s.txn_id = t.txn_id
WHERE t.txn_id IS NULL;
```

Expected result:

* No rows returned

Why this matters:

* Orphaned rows inflate revenue and quantity metrics

---

#### Test: Every sales row must map to a valid product

```sql
SELECT s.prod_id
FROM balanced_tree.sales s
LEFT JOIN balanced_tree.product_details p
    ON s.prod_id = p.product_id
WHERE p.product_id IS NULL;
```

Expected result:

* No rows returned

---

## 3. Data Completeness and Null Checks

### 3.1 Null Value Validation

#### Test: Critical fields must never be NULL

```sql
SELECT *
FROM balanced_tree.sales
WHERE txn_id IS NULL
   OR prod_id IS NULL
   OR qty IS NULL
   OR price IS NULL
   OR discount IS NULL;
```

Expected result:

* No rows returned

---

```sql
SELECT *
FROM balanced_tree.transactions
WHERE txn_date IS NULL
   OR member IS NULL;
```

Expected result:

* No rows returned

---

```sql
SELECT *
FROM balanced_tree.product_details
WHERE product_name IS NULL
   OR segment IS NULL
   OR category IS NULL;
```

Expected result:

* No rows returned

Why this matters:

* Nulls in these fields break aggregations and comparisons

---

## 4. Business Rule Validation

### 4.1 Quantity Rules

#### Test: Quantities must be positive

```sql
SELECT *
FROM balanced_tree.sales
WHERE qty <= 0;
```

Expected result:

* No rows returned

---

### 4.2 Pricing Rules

#### Test: Prices must be non-negative

```sql
SELECT *
FROM balanced_tree.sales
WHERE price < 0;
```

Expected result:

* No rows returned

---

### 4.3 Discount Rules

#### Test: Discounts must be between 0 and 100 percent

```sql
SELECT *
FROM balanced_tree.sales
WHERE discount < 0
   OR discount > 100;
```

Expected result:

* No rows returned

Why this matters:

* Invalid discounts distort revenue and discount calculations

---

### 4.4 Transaction Line Item Uniqueness

ASSUMPTION
A product should appear **at most once per transaction**.

```sql
SELECT txn_id, prod_id, COUNT(*)
FROM balanced_tree.sales
GROUP BY txn_id, prod_id
HAVING COUNT(*) > 1;
```

Expected result:

* No rows returned

---

## 5. Temporal Consistency Tests (8-Year Coverage)

### 5.1 Transaction Date Range Validation

```sql
SELECT
    MIN(txn_date) AS min_date,
    MAX(txn_date) AS max_date
FROM balanced_tree.transactions;
```

Expected result:

* `2017-01-01` to `2024-12-31`

---

### 5.2 Date Dimension Coverage

```sql
SELECT COUNT(*)
FROM balanced_tree.date_dim;
```

Expected result:

* 2,922 rows (8 years including leap years)

If this differs:

* I cannot verify this without executing the query
* Validate leap year handling

---

### 5.3 Missing Dates in Date Dimension

```sql
SELECT t.txn_date
FROM balanced_tree.transactions t
LEFT JOIN balanced_tree.date_dim d
    ON t.txn_date = d.date_id
WHERE d.date_id IS NULL;
```

Expected result:

* No rows returned

---

## 6. Analytical Sanity Checks

These tests validate that the data “behaves” realistically.

---

### 6.1 Revenue and Discount Relationship

#### Test: Total discounts should be less than total gross revenue

```sql
SELECT
    SUM(price * qty) AS gross_revenue,
    SUM((price * qty) * (discount / 100)) AS total_discount
FROM balanced_tree.sales;
```

Expected result:

* `total_discount < gross_revenue`

If not:

* Discount logic is broken

---

### 6.2 Member vs Non-Member Split

```sql
SELECT
    member,
    COUNT(*) AS transaction_count
FROM balanced_tree.transactions
GROUP BY member;
```

Expected result:

* Roughly 50–60 percent member transactions

If outside this range:

* Generation logic should be reviewed

---

### 6.3 Average Products Per Transaction

```sql
SELECT
    AVG(product_count) AS avg_products_per_transaction
FROM (
    SELECT txn_id, COUNT(*) AS product_count
    FROM balanced_tree.sales
    GROUP BY txn_id
) t;
```

Expected result:

* Between 2 and 4 products per transaction

---

### 6.4 Revenue Per Transaction Distribution

```sql
SELECT
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY txn_revenue) AS p25,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY txn_revenue) AS p50,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY txn_revenue) AS p75
FROM (
    SELECT
        s.txn_id,
        SUM(s.price * s.qty) AS txn_revenue
    FROM balanced_tree.sales s
    GROUP BY s.txn_id
) r;
```

Expected result:

* p25 < p50 < p75
* Values should increase logically

---

## 7. Product Penetration Validation

#### Test: Penetration values must be between 0 and 100 percent

```sql
SELECT
    prod_id,
    COUNT(DISTINCT txn_id) * 100.0 /
    (SELECT COUNT(*) FROM balanced_tree.transactions) AS penetration_pct
FROM balanced_tree.sales
GROUP BY prod_id
HAVING
    COUNT(DISTINCT txn_id) * 100.0 /
    (SELECT COUNT(*) FROM balanced_tree.transactions) > 100;
```

Expected result:

* No rows returned

---

## 8. Basket Analysis Sanity Check

#### Test: Transactions must contain multiple products for combinations to exist

```sql
SELECT
    COUNT(*) AS multi_product_transactions
FROM (
    SELECT txn_id
    FROM balanced_tree.sales
    GROUP BY txn_id
    HAVING COUNT(*) >= 3
) t;
```

Expected result:

* Non-zero count

Why this matters:

* Validates feasibility of combination analysis

---

## 9. Summary of Quality Guarantees

If all tests pass, the dataset guarantees:

* Referential integrity across all tables
* Valid financial calculations
* Realistic customer behavior
* Reliable percentile and penetration metrics
* Trustworthy basket analysis results

This is the standard expected of analytics-ready data.

---

## Next Logical Steps

You can now:

* Automate these checks as dbt-style tests
* Add anomaly detection over time
* Build dashboards on top of validated data
* Introduce slowly changing dimensions
* Add seasonality and promotions

Say which one you want next and we will go deep.
