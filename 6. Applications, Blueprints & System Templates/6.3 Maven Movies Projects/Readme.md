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

