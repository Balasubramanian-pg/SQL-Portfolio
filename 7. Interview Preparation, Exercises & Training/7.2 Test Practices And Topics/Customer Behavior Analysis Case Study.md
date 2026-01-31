# **Marketing Analytics Case Study: DVD Rental Co. Customer Email Campaign**  

---

## **1.0 Overview**  

### **Business Task**  
The **Leadership Team** has been asked to support the **Customer Analytics Team** at **DVD Rental Co.** in generating data points for their **first-ever customer email campaign**.  

### **Business Deliverables**  
The **Marketing Team** has shared a draft email with **7 key data points** to personalize the campaign.  

| **Data Points** | **Email Item** | **What We Need to Find** | **Flag to Marketing Team** |
|----------------|---------------|-------------------------|--------------------------|
| 1 & 4 | **Top 2 Categories** | Identify top 2 categories per customer based on rental history. | - |
| 2 & 5 | **Individual Customer Insights** | For **1st category**: Total films watched, average comparison, percentile. <br> For **2nd category**: Total films watched & proportion (%) of films watched. | - |
| 3 & 6 | **Category Film Recommendations** | Recommend **3 most popular films** in each top category that the customer **has not watched**. | Flag if no recommendations exist. |
| 7, 8 | **Favourite Actor Recommendation** | Identify **favourite actor** with **3 film recommendations** (not already watched). | Flag if no recommendations exist. |

---

## **2.0 Entity Relationship Diagram (ERD)**  
*(Visual representation of database tables and relationships)*  

### **Key Tables**:
- `rental` (customer rentals)
- `inventory` (films in stock)
- `film` (film details)
- `film_category` (links films to categories)
- `category` (film genres)
- `actor` & `film_actor` (actor details and film associations)

---

## **3.0 Data Exploration**  

### **3.1 Validating Data with Hypotheses**  

#### **Hypothesis 1**:  
*"The number of unique `inventory_id` records will be equal in `rental` and `inventory` tables."*  

✅ **Test**:  
```sql
SELECT COUNT(DISTINCT inventory_id) FROM dvd_rentals.rental; -- 4,580
SELECT COUNT(inventory_id) FROM dvd_rentals.inventory; -- 4,581
```
**Finding**:  
- **1 extra `inventory_id` in `inventory` table** → A film was never rented.  

---

#### **Hypothesis 2**:  
*"There are multiple rentals per `inventory_id` in the `rental` table."*  

✅ **Test**:  
```sql
WITH inventory_cte AS (
  SELECT inventory_id, COUNT(*) AS inventory_id_count
  FROM dvd_rentals.rental
  GROUP BY inventory_id
)
SELECT inventory_id_count, COUNT(*) AS inventory_id_grouping
FROM inventory_cte
GROUP BY inventory_id_count
ORDER BY inventory_id_count;
```
**Finding**:  
- Some films have **multiple rentals** (e.g., 1 film had 4 rentals).  

---

#### **Hypothesis 3**:  
*"There are multiple `inventory_id` records per `film_id` in the `inventory` table."*  

✅ **Test**:  
```sql
WITH inventory_grouped AS (
  SELECT film_id, COUNT(*) AS inventory_records_count
  FROM dvd_rentals.inventory
  GROUP BY film_id
)
SELECT inventory_records_count, COUNT(*)
FROM inventory_grouped
GROUP BY inventory_records_count
ORDER BY inventory_records_count;
```
**Finding**:  
- Some films have **multiple copies** (e.g., 1 film has 8 inventory copies).  

---

### **3.2 Foreign Key Overlap Analysis**  

#### **Rental vs. Inventory Tables**  
- **1 `inventory_id` exists in `inventory` but not in `rental`** → Never rented.  

#### **Inventory vs. Film Tables**  
- **1,000 films** in `film` table.  
- **958 films** have inventory records.  
- **42 films** are not in stock.  

---

## **4.0 Joining Tables for Analysis**  

### **Step 1: Create `joint_table` (Combining Rental, Film, and Category Data)**  
```sql
DROP TABLE IF EXISTS joint_table;
CREATE TEMP TABLE joint_table AS
SELECT
  r.customer_id,
  i.film_id,
  f.title,
  fc.category_id,
  c.name AS category_name,
  r.rental_date
FROM dvd_rentals.rental AS r
JOIN dvd_rentals.inventory AS i ON r.inventory_id = i.inventory_id
JOIN dvd_rentals.film AS f ON i.film_id = f.film_id
JOIN dvd_rentals.film_category AS fc ON f.film_id = fc.film_id
JOIN dvd_rentals.category AS c ON fc.category_id = c.category_id;
```

---

### **Step 2: Calculate `category_rental_counts` (Films Watched per Category per Customer)**  
```sql
DROP TABLE IF EXISTS category_rental_counts;
CREATE TEMP TABLE category_rental_counts AS
SELECT 
  customer_id, 
  category_name, 
  COUNT(*) AS rental_count,
  MAX(rental_date) AS latest_rental_date
FROM joint_table
GROUP BY customer_id, category_name;
```

---

### **Step 3: Compute `customer_total_rentals` (Total Films Watched per Customer)**  
```sql
DROP TABLE IF EXISTS customer_total_rentals;
CREATE TEMP TABLE customer_total_rentals AS
SELECT
  customer_id,
  SUM(rental_count) AS total_rental_count
FROM category_rental_counts
GROUP BY customer_id;
```

---

### **Step 4: Calculate `average_category_rental_counts` (Avg Rentals per Category)**  
```sql
DROP TABLE IF EXISTS average_category_rental_counts;
CREATE TEMP TABLE average_category_rental_counts AS
SELECT
  category_name,
  FLOOR(AVG(rental_count)) AS avg_rental_count
FROM category_rental_counts
GROUP BY category_name;
```

---

### **Step 5: Compute `customer_category_percentiles` (Customer Ranking in Each Category)**  
```sql
DROP TABLE IF EXISTS customer_category_percentiles;
CREATE TEMP TABLE customer_category_percentiles AS
SELECT 
  customer_id, 
  category_name,
  CEILING(100 * PERCENT_RANK() OVER (PARTITION BY category_name ORDER BY rental_count DESC)) as percentile
FROM category_rental_counts;
```

---

### **Step 6: Join All Temporary Tables for Final Insights**  
```sql
DROP TABLE IF EXISTS customer_category_joint_table;
CREATE TEMP TABLE customer_category_joint_table AS
SELECT
  t1.customer_id,
  t1.category_name,
  t1.rental_count,
  t2.total_rental_count,
  t3.avg_rental_count,
  t4.percentile
FROM category_rental_counts AS t1
JOIN customer_total_rentals AS t2 ON t1.customer_id = t2.customer_id
JOIN average_category_rental_counts AS t3 ON t1.category_name = t3.category_name
JOIN customer_category_percentiles AS t4 ON t1.customer_id = t4.customer_id AND t1.category_name = t4.category_name;
```

---

## **✅ Key Learning Outcomes**  
1. **Data Validation** – Confirmed hypotheses about inventory and rental behavior.  
2. **Customer Segmentation** – Identified top categories per customer.  
3. **Personalized Recommendations** – Generated film and actor recommendations.  
4. **Performance Metrics** – Calculated percentiles and averages for benchmarking.  

---

### **Next Steps**  
- **Generate email content** using the final dataset.  
- **Flag customers** with missing recommendations.  
- **Automate the process** for future campaigns.  

🚀 **This structured approach ensures data-driven, personalized customer engagement!**
