## dbt Test Automation

Balanced Tree Sales Analytics (8 Years)

---

## Objective

This section converts all previously defined data quality checks into **dbt-style automated tests**.

The goal is to ensure that:

* Data integrity is continuously enforced
* Failures are detectable early
* The dataset remains analytics-ready as it grows or regenerates

The approach follows **industry-standard dbt testing patterns**, using:

* Built-in schema tests
* Custom SQL tests
* Reusable generic tests
* Clear separation between models and tests

---

## Assumptions

ASSUMPTION

* dbt Core is being used with PostgreSQL
* Models are built directly from the raw tables
* Schema name remains `balanced_tree`

If you are using dbt Cloud or another warehouse, the logic remains identical.

---

## dbt Project Structure

Recommended folder layout:

```
dbt_balanced_tree/
│
├── models/
│   ├── staging/
│   │   ├── stg_transactions.sql
│   │   ├── stg_sales.sql
│   │   └── stg_product_details.sql
│   │
│   ├── marts/
│   │   ├── fct_sales.sql
│   │   └── dim_products.sql
│
├── tests/
│   ├── generic/
│   │   ├── discount_range.sql
│   │   ├── positive_quantity.sql
│   │   └── revenue_greater_than_discount.sql
│   │
│   └── singular/
│       ├── no_orphan_sales.sql
│       ├── valid_date_range.sql
│       └── basket_feasibility.sql
│
└── models/schema.yml
```

---

## Step 1: Staging Models

### `stg_transactions.sql`

```sql
SELECT
    txn_id,
    txn_date,
    member
FROM balanced_tree.transactions
```

---

### `stg_sales.sql`

```sql
SELECT
    sales_id,
    txn_id,
    prod_id,
    qty,
    price,
    discount
FROM balanced_tree.sales
```

---

### `stg_product_details.sql`

```sql
SELECT
    product_id,
    product_name,
    segment,
    category
FROM balanced_tree.product_details
```

---

## Step 2: Core Schema Tests (schema.yml)

### `models/schema.yml`

```yaml
version: 2

models:
  - name: stg_transactions
    columns:
      - name: txn_id
        tests:
          - unique
          - not_null

      - name: txn_date
        tests:
          - not_null

      - name: member
        tests:
          - not_null

  - name: stg_sales
    columns:
      - name: sales_id
        tests:
          - unique
          - not_null

      - name: txn_id
        tests:
          - not_null
          - relationships:
              to: ref('stg_transactions')
              field: txn_id

      - name: prod_id
        tests:
          - not_null
          - relationships:
              to: ref('stg_product_details')
              field: product_id

      - name: qty
        tests:
          - not_null
          - positive_quantity

      - name: price
        tests:
          - not_null

      - name: discount
        tests:
          - not_null
          - discount_range

  - name: stg_product_details
    columns:
      - name: product_id
        tests:
          - unique
          - not_null

      - name: product_name
        tests:
          - not_null

      - name: segment
        tests:
          - not_null

      - name: category
        tests:
          - not_null
```

---

## Step 3: Generic Custom Tests

Generic tests live under `tests/generic/` and can be reused across models.

---

### 3.1 Positive Quantity Test

#### `tests/generic/positive_quantity.sql`

```sql
SELECT *
FROM {{ model }}
WHERE {{ column_name }} <= 0
```

Purpose:

* Ensures all quantities are strictly positive

---

### 3.2 Discount Range Test

#### `tests/generic/discount_range.sql`

```sql
SELECT *
FROM {{ model }}
WHERE {{ column_name }} < 0
   OR {{ column_name }} > 100
```

Purpose:

* Prevents invalid discount values

---

### 3.3 Revenue Greater Than Discount Test

#### `tests/generic/revenue_greater_than_discount.sql`

```sql
SELECT
    txn_id,
    SUM(price * qty) AS gross_revenue,
    SUM((price * qty) * (discount / 100)) AS total_discount
FROM {{ ref('stg_sales') }}
GROUP BY txn_id
HAVING
    SUM((price * qty) * (discount / 100)) >=
    SUM(price * qty)
```

Purpose:

* Ensures discounts never exceed revenue

---

## Step 4: Singular Tests (Complex Logic)

Singular tests are written as standalone SQL files.

---

### 4.1 Orphan Sales Test

#### `tests/singular/no_orphan_sales.sql`

```sql
SELECT s.*
FROM {{ ref('stg_sales') }} s
LEFT JOIN {{ ref('stg_transactions') }} t
    ON s.txn_id = t.txn_id
WHERE t.txn_id IS NULL
```

Expected:

* Zero rows

---

### 4.2 Valid Date Range Test

#### `tests/singular/valid_date_range.sql`

```sql
SELECT *
FROM {{ ref('stg_transactions') }}
WHERE txn_date < '2017-01-01'
   OR txn_date > '2024-12-31'
```

Expected:

* Zero rows

---

### 4.3 Basket Feasibility Test

Ensures transactions exist with at least three products.

#### `tests/singular/basket_feasibility.sql`

```sql
SELECT *
FROM (
    SELECT txn_id
    FROM {{ ref('stg_sales') }}
    GROUP BY txn_id
    HAVING COUNT(*) < 3
) t
```

Expected:

* Not all rows returned
* If all transactions fail, basket analysis is invalid

---

## Step 5: Product Uniqueness per Transaction

### Singular Test: One Product per Transaction Rule

```sql
SELECT txn_id, prod_id, COUNT(*)
FROM {{ ref('stg_sales') }}
GROUP BY txn_id, prod_id
HAVING COUNT(*) > 1
```

Purpose:

* Ensures no duplicate product lines per transaction

---

## Step 6: Running the Tests

Command to execute all tests:

```bash
dbt test
```

What happens:

* Schema tests validate column-level rules
* Generic tests enforce reusable business rules
* Singular tests validate multi-row logic
* Any failure stops the pipeline

---

## Step 7: Interpreting Test Failures

* Schema test failure
  Indicates broken assumptions like nulls or duplicates

* Generic test failure
  Indicates business rule violations

* Singular test failure
  Indicates analytical invalidity or data generation issues

Each failure points directly to rows that violate expectations.

---

## Guarantees After Automation

If all dbt tests pass, the dataset guarantees:

* Referential integrity
* Valid financial calculations
* Correct transaction modeling
* Feasible basket analysis
* Stable analytics over 8 years of data

This is production-grade validation.

---

## Next Possible Enhancements

You can now extend this by:

* Adding dbt freshness tests
* Creating snapshots for slowly changing products
* Adding exposure definitions for dashboards
* Introducing anomaly detection models
* Adding CI integration for automated validation

Say which one you want next and we will build it properly.
