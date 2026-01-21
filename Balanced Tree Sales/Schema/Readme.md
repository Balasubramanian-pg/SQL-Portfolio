## Database Schema Design

Balanced Tree Sales Analytics (8 Years of Data)

## Overview

This section defines the database schema required to support all questions in:

* High Level Sales Analysis
* Transaction Analysis
* Product Analysis

The schema is designed to:

* Support **8 years of historical data**
* Be **analytically friendly**
* Reflect **realistic retail transaction modeling**
* Scale cleanly for large volumes of transactions

The design follows a classic **fact–dimension model** with one central fact table and supporting dimension tables.

## Time Horizon

### Data Coverage

ASSUMPTION
The dataset spans **8 full calendar years**.

Example range:

* Start date: `2017-01-01`
* End date: `2024-12-31`

This range supports:

* Trend analysis
* Percentile calculations
* Product penetration analysis
* Basket analysis across time

Dates are stored at **transaction level granularity**.

## Schema Name

```sql
CREATE SCHEMA IF NOT EXISTS balanced_tree;
```

All tables live under this schema.

## Table 1: `product_details`

### Purpose

Stores descriptive attributes for each product.
Used for:

* Product analysis
* Segment and category rollups
* Revenue splits

### Schema

```sql
CREATE TABLE balanced_tree.product_details (
    product_id      INTEGER PRIMARY KEY,
    product_name    VARCHAR(100) NOT NULL,
    segment         VARCHAR(50) NOT NULL,
    category        VARCHAR(50) NOT NULL
);
```

### Design Notes

* `product_id` is stable and reused across all years
* `segment` and `category` enable hierarchical analysis
* Product attributes are assumed to be slowly changing and static for simplicity

## Table 2: `transactions`

### Purpose

Represents a **single customer transaction**.
Used for:

* Transaction counts
* Member vs non-member analysis
* Revenue per transaction
* Basket size calculations

### Schema

```sql
CREATE TABLE balanced_tree.transactions (
    txn_id          BIGINT PRIMARY KEY,
    txn_date        DATE NOT NULL,
    member          BOOLEAN NOT NULL
);
```

### Design Notes

* One row per transaction
* `member` allows clean separation of member vs non-member behavior
* `txn_date` supports time-based analysis across 8 years

## Table 3: `sales`

### Purpose

Fact table containing **line-item level sales data**.
This is the core table for nearly all calculations.

### Schema

```sql
CREATE TABLE balanced_tree.sales (
    sales_id        BIGSERIAL PRIMARY KEY,
    txn_id          BIGINT NOT NULL,
    prod_id         INTEGER NOT NULL,
    qty             INTEGER NOT NULL CHECK (qty > 0),
    price           NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    discount        NUMERIC(5,2) NOT NULL CHECK (discount >= 0),

    CONSTRAINT fk_sales_transaction
        FOREIGN KEY (txn_id)
        REFERENCES balanced_tree.transactions (txn_id),

    CONSTRAINT fk_sales_product
        FOREIGN KEY (prod_id)
        REFERENCES balanced_tree.product_details (product_id)
);
```

### Design Notes

* Each row represents **one product in one transaction**
* Supports:

  * Revenue calculations
  * Discount calculations
  * Basket analysis
  * Product penetration
* `discount` is stored as a percentage value (for example `10` = 10%)

## Optional Table: `date_dim` (Recommended)

### Purpose

Improves time-based analytics and reporting flexibility.

### Schema

```sql
CREATE TABLE balanced_tree.date_dim (
    date_id         DATE PRIMARY KEY,
    year            INTEGER NOT NULL,
    quarter         INTEGER NOT NULL,
    month           INTEGER NOT NULL,
    month_name      VARCHAR(20) NOT NULL,
    week_of_year    INTEGER NOT NULL,
    day_of_week     INTEGER NOT NULL
);
```

### Design Notes

* Precomputed date attributes simplify queries
* Especially useful for 8-year trend analysis
* Can be populated once for the full date range

## Relationship Diagram (Conceptual)

* `product_details.product_id` → `sales.prod_id`
* `transactions.txn_id` → `sales.txn_id`
* `transactions.txn_date` → `date_dim.date_id`

This forms a clean star schema optimized for analytics.

## Data Volume Expectations (8 Years)

ASSUMPTION
Typical retail-like volumes.

Estimated scale:

* Transactions: 300k to 800k
* Sales rows: 1.5M to 3M
* Products: 50 to 200
* Categories: 5 to 10
* Segments: 10 to 20

These volumes are sufficient to:

* Make percentile calculations meaningful
* Surface realistic basket combinations
* Stress test analytical queries

## Why This Schema Works for All Questions

This design fully supports:

* Total quantity, revenue, and discount calculations
* Transaction counts and averages
* Percentile revenue per transaction
* Member vs non-member splits
* Product, segment, and category rollups
* Revenue percentage splits
* Product penetration calculations
* Multi-product basket analysis

All required metrics can be derived cleanly without schema changes.


## Next Logical Step

If you want, the next step can be:

* SQL scripts to **generate realistic synthetic data for 8 years**
* Indexing strategy for performance
* Validation queries to confirm data integrity
* Sample ER diagram explanation for interviews

Tell me which direction you want to go next.

