## Synthetic Data Generation

Balanced Tree Sales Dataset (8 Years)

---

## Goal

This section provides **complete SQL scripts** to generate **realistic synthetic data covering 8 years** for all tables in the `balanced_tree` schema.

The generated data supports every business question listed earlier, including:

* Transaction and basket analysis
* Member vs non-member behavior
* Percentile revenue calculations
* Product penetration and product combinations
* Segment and category rollups

The scripts are written for **PostgreSQL** and rely on `generate_series`, randomization, and controlled distributions.

---

## Assumptions (Explicit)

ASSUMPTION

* Date range: `2017-01-01` to `2024-12-31`
* Average transactions per day: 200 to 350
* Average products per transaction: 2 to 4
* Discount applied on approximately 60 percent of line items
* Member transactions account for roughly 55 percent of total transactions

These assumptions are chosen to create realistic analytical behavior, not to simulate a specific real company.

---

## Step 1: Create Schema

```sql
CREATE SCHEMA IF NOT EXISTS balanced_tree;
```

---

## Step 2: Product Master Data

### Insert Product Details

This dataset uses:

* 3 categories
* 6 segments
* 18 products

```sql
INSERT INTO balanced_tree.product_details (product_id, product_name, segment, category)
VALUES
(1,  'Blue Polo Shirt - Mens',       'Mens Apparel',   'Clothing'),
(2,  'Grey Fashion Jacket - Womens', 'Womens Apparel', 'Clothing'),
(3,  'White Tee Shirt - Mens',       'Mens Apparel',   'Clothing'),
(4,  'Black Jeans - Womens',         'Womens Apparel', 'Clothing'),
(5,  'Kids Graphic Tee',             'Kids Apparel',   'Clothing'),
(6,  'Running Shoes - Mens',         'Mens Footwear',  'Footwear'),
(7,  'Sneakers - Womens',            'Womens Footwear','Footwear'),
(8,  'Kids Trainers',                'Kids Footwear',  'Footwear'),
(9,  'Leather Belt',                 'Accessories',    'Accessories'),
(10, 'Baseball Cap',                 'Accessories',    'Accessories'),
(11, 'Wool Scarf',                   'Accessories',    'Accessories'),
(12, 'Formal Shirt - Mens',          'Mens Apparel',   'Clothing'),
(13, 'Dress - Womens',               'Womens Apparel', 'Clothing'),
(14, 'Kids Hoodie',                  'Kids Apparel',   'Clothing'),
(15, 'Flip Flops',                   'Footwear',       'Footwear'),
(16, 'Socks Pack',                   'Accessories',    'Accessories'),
(17, 'Sports Jacket - Mens',         'Mens Apparel',   'Clothing'),
(18, 'Handbag - Womens',             'Accessories',    'Accessories');
```

---

## Step 3: Date Dimension (8 Years)

```sql
INSERT INTO balanced_tree.date_dim
SELECT
    d::DATE AS date_id,
    EXTRACT(YEAR FROM d)::INT,
    EXTRACT(QUARTER FROM d)::INT,
    EXTRACT(MONTH FROM d)::INT,
    TO_CHAR(d, 'Month'),
    EXTRACT(WEEK FROM d)::INT,
    EXTRACT(DOW FROM d)::INT
FROM generate_series(
    '2017-01-01'::DATE,
    '2024-12-31'::DATE,
    INTERVAL '1 day'
) AS d;
```

---

## Step 4: Transactions (8 Years)

### Generate Transactions Per Day

This produces between **200 and 350 transactions per day**.

```sql
INSERT INTO balanced_tree.transactions (txn_id, txn_date, member)
SELECT
    ROW_NUMBER() OVER () AS txn_id,
    d::DATE AS txn_date,
    (RANDOM() < 0.55) AS member
FROM generate_series(
    '2017-01-01'::DATE,
    '2024-12-31'::DATE,
    INTERVAL '1 day'
) d
CROSS JOIN LATERAL generate_series(
    1,
    (200 + FLOOR(RANDOM() * 150))::INT
);
```

---

## Step 5: Sales Line Items

### Generate Line Items Per Transaction

Each transaction contains **1 to 5 distinct products**.

```sql
INSERT INTO balanced_tree.sales (txn_id, prod_id, qty, price, discount)
SELECT
    t.txn_id,
    p.product_id,
    (1 + FLOOR(RANDOM() * 3))::INT AS qty,
    CASE
        WHEN p.category = 'Clothing'    THEN ROUND(30 + RANDOM() * 70, 2)
        WHEN p.category = 'Footwear'    THEN ROUND(50 + RANDOM() * 100, 2)
        ELSE ROUND(10 + RANDOM() * 40, 2)
    END AS price,
    CASE
        WHEN RANDOM() < 0.60 THEN ROUND((5 + RANDOM() * 30), 2)
        ELSE 0
    END AS discount
FROM balanced_tree.transactions t
CROSS JOIN LATERAL (
    SELECT *
    FROM balanced_tree.product_details
    ORDER BY RANDOM()
    LIMIT (1 + FLOOR(RANDOM() * 5))::INT
) p;
```

---

## Step 6: Indexing for Performance

These indexes are critical for percentile queries, joins, and penetration analysis.

```sql
CREATE INDEX idx_sales_txn_id ON balanced_tree.sales (txn_id);
CREATE INDEX idx_sales_prod_id ON balanced_tree.sales (prod_id);
CREATE INDEX idx_transactions_date ON balanced_tree.transactions (txn_date);
CREATE INDEX idx_transactions_member ON balanced_tree.transactions (member);
```

---

## Step 7: Data Validation Checks

### Transaction Count

```sql
SELECT COUNT(*) FROM balanced_tree.transactions;
```

### Sales Line Volume

```sql
SELECT COUNT(*) FROM balanced_tree.sales;
```

### Date Coverage

```sql
SELECT
    MIN(txn_date),
    MAX(txn_date)
FROM balanced_tree.transactions;
```

---

## What This Dataset Enables

With this generated data, you can now:

* Compute revenue percentiles per transaction
* Perform basket analysis across millions of rows
* Measure product penetration accurately
* Compare member vs non-member behavior
* Analyze trends across 8 full years

The dataset behaves like a real retail system, not a toy example.

---

## Next Options

You can now proceed to:

* Write **all analytical SQL answers** against this data
* Add **data quality tests**
* Create **Power BI or Tableau dashboards**
* Simulate **seasonality and promotions**
* Add **slowly changing dimensions** for products

Say the word and we move forward.
