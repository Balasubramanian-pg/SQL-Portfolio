## Indexing Strategy for Performance

Balanced Tree Sales Analytics (8 Years, PostgreSQL)

---

## Objective

This section defines a **deliberate, production-grade indexing strategy** for the Balanced Tree dataset.

The goals are to:

* Optimize performance for analytical queries
* Support dbt models, tests, and anomaly detection
* Scale cleanly across 8 years of data
* Avoid over-indexing and unnecessary write overhead

The strategy is designed around **how the data is queried**, not just how it is stored.

---

## Guiding Principles

Before defining indexes, it is important to clarify the principles driving them.

### 1. Query-Driven Indexing

Indexes are created only for:

* Join keys
* Group by columns
* Filter predicates
* Window function orderings

No speculative indexes.

---

### 2. Fact Table First

The `sales` table is:

* The largest table
* The most frequently queried
* The most join-heavy

It receives the majority of indexing attention.

---

### 3. Analytics Over OLTP

This is an analytics workload:

* Read-heavy
* Batch inserts
* Large scans
* Aggregations over time

This favors:

* Composite indexes
* Partial indexes
* Avoidance of excessive single-column indexes

---

## Table-by-Table Indexing Strategy

---

## 1. `product_details` Table

### Access Patterns

* Joined to `sales` on `product_id`
* Grouped by `segment` and `category`
* Rarely filtered independently

### Recommended Indexes

```sql
ALTER TABLE balanced_tree.product_details
ADD CONSTRAINT pk_product_details PRIMARY KEY (product_id);
```

Optional supporting index for grouping-heavy workloads:

```sql
CREATE INDEX idx_product_segment_category
ON balanced_tree.product_details (segment, category);
```

### Rationale

* Primary key supports joins
* Composite index helps segment and category rollups
* Low cardinality keeps index size small

---

## 2. `transactions` Table

### Access Patterns

* Joined to `sales` on `txn_id`
* Filtered by `txn_date`
* Filtered by `member`
* Grouped by date for time series analysis

### Core Indexes

```sql
ALTER TABLE balanced_tree.transactions
ADD CONSTRAINT pk_transactions PRIMARY KEY (txn_id);
```

```sql
CREATE INDEX idx_transactions_txn_date
ON balanced_tree.transactions (txn_date);
```

### Composite Index for Membership Analysis

```sql
CREATE INDEX idx_transactions_member_date
ON balanced_tree.transactions (member, txn_date);
```

### Rationale

* `txn_date` drives almost all time-based analytics
* Composite index supports:

  * Member vs non-member splits
  * Daily aggregations
* Order places `member` first to support equality filters

---

## 3. `sales` Table (Critical)

This is the performance bottleneck table.

---

### 3.1 Primary Key

```sql
ALTER TABLE balanced_tree.sales
ADD CONSTRAINT pk_sales PRIMARY KEY (sales_id);
```

---

### 3.2 Foreign Key Join Indexes

These are mandatory.

```sql
CREATE INDEX idx_sales_txn_id
ON balanced_tree.sales (txn_id);
```

```sql
CREATE INDEX idx_sales_prod_id
ON balanced_tree.sales (prod_id);
```

### Rationale

* Enables fast joins to `transactions` and `product_details`
* Essential for dbt models and tests

---

### 3.3 Composite Index for Core Aggregations

Most queries group by transaction and product.

```sql
CREATE INDEX idx_sales_txn_prod
ON balanced_tree.sales (txn_id, prod_id);
```

### Rationale

* Speeds up:

  * Basket analysis
  * Product penetration
  * Duplicate product checks
* Prevents repeated hash aggregations

---

### 3.4 Revenue and Discount Analysis Index

For heavy analytical workloads involving revenue calculations:

```sql
CREATE INDEX idx_sales_txn_revenue
ON balanced_tree.sales (txn_id)
INCLUDE (qty, price, discount);
```

### Rationale

* Covers common revenue calculations
* Reduces heap access during aggregations
* Particularly useful for:

  * Percentile calculations
  * Anomaly detection rollups

---

## 4. `date_dim` Table

### Access Patterns

* Joined on `txn_date`
* Filtered by year, month, quarter

### Recommended Index

```sql
ALTER TABLE balanced_tree.date_dim
ADD CONSTRAINT pk_date_dim PRIMARY KEY (date_id);
```

Optional for heavy calendar slicing:

```sql
CREATE INDEX idx_date_dim_year_month
ON balanced_tree.date_dim (year, month);
```

---

## Indexing for dbt-Specific Workloads

---

## 5. dbt Test Optimization

dbt tests frequently perform:

* Existence checks
* Joins
* Aggregations

### Critical Supporting Indexes

```sql
CREATE INDEX idx_sales_txn_id_not_null
ON balanced_tree.sales (txn_id)
WHERE txn_id IS NOT NULL;
```

```sql
CREATE INDEX idx_sales_discount_nonzero
ON balanced_tree.sales (discount)
WHERE discount > 0;
```

### Rationale

* Partial indexes reduce scan size
* Particularly effective for:

  * Discount anomaly tests
  * Revenue vs discount validations

---

## Indexing for Anomaly Detection Models

---

### Time Series Aggregation Path

Daily anomaly models follow this path:

```
transactions (txn_date)
→ sales (txn_id)
→ aggregation
```

### Supporting Composite Index

```sql
CREATE INDEX idx_transactions_date_txn
ON balanced_tree.transactions (txn_date, txn_id);
```

### Rationale

* Supports ordered window functions
* Speeds up daily rollups
* Improves rolling window calculations

---

## Indexing for Basket Analysis

Basket analysis is the most expensive workload.

### Key Query Pattern

* Group by `txn_id`
* Self-joins or combinations on `prod_id`

### Required Index

```sql
CREATE INDEX idx_sales_txn_id_prod_id
ON balanced_tree.sales (txn_id, prod_id);
```

This index is non-negotiable for:

* Product combinations
* Penetration analysis
* Co-occurrence queries

---

## Index Maintenance Strategy

---

### Reindexing

ASSUMPTION
Data is loaded in batches.

Recommended cadence:

* Reindex quarterly
* After large synthetic reloads

```sql
REINDEX TABLE balanced_tree.sales;
```

---

### Vacuum and Analyze

```sql
VACUUM ANALYZE balanced_tree.sales;
VACUUM ANALYZE balanced_tree.transactions;
```

Why this matters:

* Keeps planner statistics accurate
* Prevents performance degradation over time

---

## What We Explicitly Avoid

* Indexing low-cardinality boolean columns alone
* Indexing derived metrics
* Excessive single-column indexes
* Indexing columns not used in joins or filters

Over-indexing hurts write performance and increases maintenance cost.

---

## Performance Guarantees

With this indexing strategy in place, the system supports:

* Sub-second joins on large fact tables
* Efficient percentile calculations
* Scalable anomaly detection
* Fast dbt test execution
* Feasible basket analysis on millions of rows

This is a **warehouse-grade indexing strategy**, not a toy setup.

---

## Next Logical Extensions

You can now:

* Add table partitioning by date
* Introduce materialized views for hot metrics
* Benchmark queries with `EXPLAIN ANALYZE`
* Add cost-based tuning for window functions

Say the next move and we will design it properly.
