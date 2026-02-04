**Case Study #1: Danny's Diner Solutions**

### 1. Total Amount Spent by Each Customer
```sql
SELECT 
  s.customer_id, 
  SUM(price) AS total_sales
FROM dbo.sales AS s
JOIN dbo.menu AS m
  ON s.product_id = m.product_id
GROUP BY customer_id;
```
- **Approach:** Join sales and menu to calculate total spending per customer.

### 2. Number of Visits per Customer
```sql
SELECT 
  customer_id, 
  COUNT(DISTINCT(order_date)) AS visit_count
FROM dbo.sales
GROUP BY customer_id;
```
- **Approach:** Count distinct order dates for each customer.

### 3. First Item Purchased by Each Customer
```sql
WITH ordered_sales_cte AS (
  SELECT 
    customer_id, 
    order_date, 
    product_name,
    DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rank
  FROM dbo.sales AS s
  JOIN dbo.menu AS m
    ON s.product_id = m.product_id
)
SELECT 
  customer_id, 
  product_name
FROM ordered_sales_cte
WHERE rank = 1
GROUP BY customer_id, product_name;
```
- **Approach:** Use DENSE_RANK to find the first order(s) and handle ties.

### 4. Most Purchased Item
```sql
SELECT 
  TOP 1 (COUNT(s.product_id)) AS most_purchased, 
  product_name
FROM dbo.sales AS s
JOIN dbo.menu AS m
  ON s.product_id = m.product_id
GROUP BY s.product_id, product_name
ORDER BY most_purchased DESC;
```
- **Approach:** Count product occurrences and select the top item.

### 5. Most Popular Item per Customer
```sql
WITH fav_item_cte AS (
  SELECT 
    s.customer_id, 
    m.product_name, 
    COUNT(m.product_id) AS order_count,
    DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(s.customer_id) DESC) AS rank
  FROM dbo.menu AS m
  JOIN dbo.sales AS s
    ON m.product_id = s.product_id
  GROUP BY s.customer_id, m.product_name
)
SELECT 
  customer_id, 
  product_name, 
  order_count
FROM fav_item_cte 
WHERE rank = 1;
```
- **Approach:** Rank items by purchase count per customer and select top.

### 6. First Purchase After Membership
```sql
WITH member_sales_cte AS (
  SELECT 
    s.customer_id, 
    m.join_date, 
    s.order_date, 
    s.product_id,
    DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rank
  FROM sales AS s
  JOIN members AS m
    ON s.customer_id = m.customer_id
  WHERE s.order_date >= m.join_date
)
SELECT 
  s.customer_id, 
  s.order_date, 
  m2.product_name 
FROM member_sales_cte AS s
JOIN menu AS m2
  ON s.product_id = m2.product_id
WHERE rank = 1;
```
- **Approach:** Filter post-membership orders and select the earliest.

### 7. Last Purchase Before Membership
```sql
WITH prior_member_purchased_cte AS (
  SELECT 
    s.customer_id, 
    m.join_date, 
    s.order_date, 
    s.product_id,
    DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC)  AS rank
  FROM sales AS s
  JOIN members AS m
    ON s.customer_id = m.customer_id
  WHERE s.order_date < m.join_date
)
SELECT 
  s.customer_id, 
  s.order_date, 
  m2.product_name 
FROM prior_member_purchased_cte AS s
JOIN menu AS m2
  ON s.product_id = m2.product_id
WHERE rank = 1;
```
- **Approach:** Rank pre-membership orders in reverse and select the latest.

### 8. Total Spent Before Membership
```sql
SELECT 
  s.customer_id, 
  COUNT(DISTINCT s.product_id) AS unique_menu_item, 
  SUM(mm.price) AS total_sales
FROM sales AS s
JOIN members AS m
  ON s.customer_id = m.customer_id
JOIN menu AS mm
  ON s.product_id = mm.product_id
WHERE s.order_date < m.join_date
GROUP BY s.customer_id;
```
- **Approach:** Aggregate sales and products before membership.

### 9. Points Calculation
```sql
WITH price_points_cte AS (
  SELECT 
    *, 
    CASE 
      WHEN product_name = 'sushi' THEN price * 20
      ELSE price * 10 
    END AS points
  FROM menu
)
SELECT 
  s.customer_id, 
  SUM(p.points) AS total_points
FROM price_points_cte AS p
JOIN sales AS s
  ON p.product_id = s.product_id
GROUP BY s.customer_id;
```
- **Approach:** Apply points rules using CASE and sum per customer.

### 10. Points with Membership Promo
```sql
WITH dates_cte AS (
  SELECT 
    *, 
    DATEADD(DAY, 6, join_date) AS valid_date, 
    EOMONTH('2021-01-31') AS last_date
  FROM members AS m
)
SELECT 
  d.customer_id, 
  SUM( 
    CASE 
      WHEN m.product_name = 'sushi' THEN 20 * m.price
      WHEN s.order_date BETWEEN d.join_date AND d.valid_date THEN 20 * m.price
      ELSE 10 * m.price 
    END) AS total_points
FROM dates_cte AS d
JOIN sales AS s
  ON d.customer_id = s.customer_id
JOIN menu AS m
  ON s.product_id = m.product_id
WHERE s.order_date <= d.last_date
GROUP BY d.customer_id;
```
- **Approach:** Calculate points with promotional periods and aggregate.

### Bonus: Member Status and Ranking
```sql
-- Join All The Things
SELECT 
  s.customer_id, 
  s.order_date, 
  m.product_name, 
  m.price,
  CASE 
    WHEN mm.join_date > s.order_date THEN 'N'
    WHEN mm.join_date <= s.order_date THEN 'Y'
    ELSE 'N' 
  END AS member
FROM sales AS s
LEFT JOIN menu AS m
  ON s.product_id = m.product_id
LEFT JOIN members AS mm
  ON s.customer_id = mm.customer_id
ORDER BY s.customer_id, s.order_date;

-- Rank All The Things
WITH summary_cte AS (
  SELECT 
    s.customer_id, 
    s.order_date, 
    m.product_name, 
    m.price,
    CASE 
      WHEN mm.join_date > s.order_date THEN 'N'
      WHEN mm.join_date <= s.order_date THEN 'Y'
      ELSE 'N'
    END AS member
  FROM sales AS s
  LEFT JOIN menu AS m
    ON s.product_id = m.product_id
  LEFT JOIN members AS mm
    ON s.customer_id = mm.customer_id
)
SELECT 
  *,
  CASE 
    WHEN member = 'N' THEN NULL
    ELSE RANK() OVER(PARTITION BY customer_id, member ORDER BY order_date) 
  END AS ranking
FROM summary_cte;
```

**Explanation:**
- **Member Status:** Determines if the customer was a member at the time of order.
- **Ranking:** Ranks orders chronologically only for members, using `RANK()` partitioned by customer and membership status.