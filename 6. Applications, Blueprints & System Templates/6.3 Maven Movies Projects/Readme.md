To transition from a simple transactional database to a structured **Data Warehouse (DWH)**, we need to move from a Normalized (OLTP) structure to a **Dimensional Model (Star Schema)**. This allows the Business Analyst's requirements (like Lifetime Value and Replacement Costs) to be queried with high performance.

Below is the architectural blueprint and the SQL implementation to construct the `maven_analytics_dw` environment.

---

## 1. Data Warehouse Architecture: The Star Schema

For this project, we utilize a **Star Schema**. This centralizes "Facts" (quantitative data like payments and rentals) and surrounds them with "Dimensions" (descriptive data like geography, film details, and customer profiles).

---

## 2. Environment Setup

First, we establish the dedicated warehouse environment.

```sql
CREATE DATABASE maven_analytics_dw;
USE maven_analytics_dw;

```

---

## 3. Dimension Tables (The "Who, What, Where")

These tables store the descriptive attributes requested by the business (addresses, film ratings, and categories).

```sql
-- Geography Dimension: Consolidates Address, City, and Country
CREATE TABLE dim_location (
    location_key INT PRIMARY KEY AUTO_INCREMENT,
    address VARCHAR(255),
    district VARCHAR(50),
    city VARCHAR(50),
    country VARCHAR(50)
);

-- Film Dimension: Consolidates Film, Category, and Award status
CREATE TABLE dim_film (
    film_key INT PRIMARY KEY AUTO_INCREMENT,
    film_id INT,
    title VARCHAR(255),
    rating VARCHAR(10),
    category VARCHAR(50),
    replacement_cost DECIMAL(10,2),
    rental_rate DECIMAL(10,2),
    award_tier INT -- Number of awards won (1, 2, or 3)
);

-- Customer Dimension: Tracks status and loyalty metadata
CREATE TABLE dim_customer (
    customer_key INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    full_name VARCHAR(255),
    email VARCHAR(100),
    active_status BOOLEAN,
    location_key INT,
    FOREIGN KEY (location_key) REFERENCES dim_location(location_key)
);

```

---

## 4. Fact Tables (The "How Much")

These tables store the measurable metrics: payments, rental counts, and inventory instances.

```sql
-- Inventory Fact: Supports inventory counts and valuation requests
CREATE TABLE fact_inventory (
    inventory_id INT PRIMARY KEY,
    film_key INT,
    store_id INT,
    valuation_at_capture DECIMAL(10,2),
    FOREIGN KEY (film_key) REFERENCES dim_film(film_key)
);

-- Transaction Fact: Supports Payment Average, Max, and LTV requests
CREATE TABLE fact_transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_key INT,
    film_key INT,
    store_id INT,
    payment_amount DECIMAL(10,2),
    rental_date DATETIME,
    FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key),
    FOREIGN KEY (film_key) REFERENCES dim_film(film_key)
);

```

---

## 5. Stakeholder & Organizational Tables

As these are standalone entities not tied to the rental transaction flow, they are stored as reference tables.

```sql
-- Board & Investor Registry
CREATE TABLE stakeholder_registry (
    stakeholder_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    position_type ENUM('Advisor', 'Investor'),
    associated_company VARCHAR(255) NULL
);

```

---

## 6. ETL Logic (Conceptual Logic)

To populate this warehouse from the `mavenmovies` source, the following logic is applied:

1. **Flattening:** Join `address` + `city` + `country` into a single `dim_location` to simplify management's "full address" requirement.
2. **Aggregation:** Calculate the `award_tier` by counting distinct awards per actor in the source `actor_award` table before loading into `dim_film`.
3. **Snapshotting:** The `fact_inventory` table should take a snapshot of current replacement costs to track how asset value changes over time.

To complete the transition from a business requirement to a functioning analytical system, we must perform the **ETL (Extract, Transform, Load)** process. This moves the data from the raw, normalized `mavenmovies` tables into the high-performance `maven_analytics_dw` tables we just defined.

### 1. Loading the Dimensions

We start with dimensions because the Fact tables (transactions) rely on these for foreign key relationships.

```sql
-- Populating Geography Dimension
INSERT INTO dim_location (address, district, city, country)
SELECT 
    a.address, 
    a.district, 
    ci.city, 
    co.country
FROM mavenmovies.address a
JOIN mavenmovies.city ci ON a.city_id = ci.city_id
JOIN mavenmovies.country co ON ci.country_id = co.country_id;

-- Populating Film Dimension
-- Includes the "Award Tier" logic requested in Requirement #8
INSERT INTO dim_film (film_id, title, rating, category, replacement_cost, rental_rate, award_tier)
SELECT 
    f.film_id, 
    f.title, 
    f.rating, 
    cat.name, 
    f.replacement_cost, 
    f.rental_rate,
    (SELECT COUNT(DISTINCT award_name) FROM mavenmovies.actor_award aa 
     JOIN mavenmovies.film_actor fa ON aa.actor_id = fa.actor_id 
     WHERE fa.film_id = f.film_id) as award_tier
FROM mavenmovies.film f
JOIN mavenmovies.film_category fc ON f.film_id = fc.film_id
JOIN mavenmovies.category cat ON fc.category_id = cat.category_id;

```

---

### 2. Loading the Customer Master

This link merges the customer profile with the new location keys generated in the previous step.

```sql
INSERT INTO dim_customer (customer_id, full_name, email, active_status, location_key)
SELECT 
    c.customer_id, 
    CONCAT(c.first_name, ' ', c.last_name), 
    c.email, 
    c.active,
    l.location_key
FROM mavenmovies.customer c
JOIN dim_location l ON c.address_id = (SELECT address_id FROM mavenmovies.address WHERE address = l.address LIMIT 1);

```

---

### 3. Populating the Fact Tables (The Analytics Core)

This is where we consolidate the metrics for **Lifetime Value** and **Inventory Valuation**.

```sql
-- Populating Transaction Facts
INSERT INTO fact_transactions (customer_key, film_key, store_id, payment_amount, rental_date)
SELECT 
    dc.customer_key, 
    df.film_key, 
    r.store_id, 
    p.amount, 
    r.rental_date
FROM mavenmovies.payment p
JOIN mavenmovies.rental r ON p.rental_id = r.rental_id
JOIN dim_customer dc ON r.customer_id = dc.customer_id
JOIN mavenmovies.inventory i ON r.inventory_id = i.inventory_id
JOIN dim_film df ON i.film_id = df.film_id;

-- Populating Inventory Facts
INSERT INTO fact_inventory (inventory_id, film_key, store_id, valuation_at_capture)
SELECT 
    i.inventory_id, 
    df.film_key, 
    i.store_id, 
    df.replacement_cost
FROM mavenmovies.inventory i
JOIN dim_film df ON i.film_id = df.film_id;

```

---

### 4. Stakeholder Registry Migration

Finally, we consolidate the independent lists of advisors and investors into the Unified Registry.

```sql
INSERT INTO stakeholder_registry (first_name, last_name, position_type, associated_company)
SELECT first_name, last_name, 'Advisor', NULL FROM mavenmovies.advisor
UNION ALL
SELECT first_name, last_name, 'Investor', company_name FROM mavenmovies.investor;

```

---

### Summary of the New System

By moving the data into this structure:

* **Performance:** Complex queries (like "Average replacement cost by category per store") now run significantly faster because the joins are pre-calculated or simplified.
* **Clarity:** The Business Analyst can now query `dim_customer` and find "Full Address" in one table, rather than joining four separate tables.
* **Integrity:** The `award_tier` logic is baked into the `dim_film` table, ensuring consistent reporting across the organization.

**Next Step:** Would you like me to write a sample "Executive Dashboard" query using this new Data Warehouse to show you how much simpler the SQL becomes?
