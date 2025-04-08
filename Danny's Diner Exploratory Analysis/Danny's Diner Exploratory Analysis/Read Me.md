**Step-by-Step Explanation and SQL Solutions for Danny's Diner Case Study**

### **1. Data Setup**
The tables `sales`, `menu`, and `members` are created and populated with sample data. These tables track customer orders, menu items, and membership details.

---

### **2. Case Study Questions**

#### **1. Total Amount Spent by Each Customer**
**Objective:** Calculate the total spending for each customer.  
**Approach:** Join `sales` and `menu` to sum prices grouped by customer.  
**SQL:**
```sql
SELECT 
  s.customer_id, 
  SUM(m.price) AS total_spent
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;
```

#### **2. Number of Visits per Customer**
**Objective:** Count distinct days each customer visited.  
**Approach:** Use `COUNT(DISTINCT order_date)` to avoid counting multiple orders on the same day.  
**SQL:**
```sql
SELECT 
  customer_id, 
  COUNT(DISTINCT order_date) AS visit_count
FROM sales
GROUP BY customer_id;
```

#### **3. First Item Purchased by Each Customer**
**Objective:** Find the first item(s) each customer ordered.  
**Approach:** Use `DENSE_RANK()` to rank orders by date and filter the earliest.  
**SQL:**
```sql
WITH FirstPurchase AS (
  SELECT 
    customer_id, 
    product_name,
    DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY order_date) AS rnk
  FROM sales s
  JOIN menu m ON s.product_id = m.product_id
)
SELECT customer_id, product_name
FROM FirstPurchase
WHERE rnk = 1
GROUP BY customer_id, product_name;
```

#### **4. Most Purchased Menu Item**
**Objective:** Identify the most frequently ordered item.  
**Approach:** Count product occurrences and return the top result.  
**SQL:**
```sql
SELECT TOP 1
  m.product_name,
  COUNT(*) AS total_orders
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY total_orders DESC;
```

#### **5. Most Popular Item per Customer**
**Objective:** Determine each customer's favorite item.  
**Approach:** Rank items by order count per customer using `DENSE_RANK()`.  
**SQL:**
```sql
WITH CustomerFavorites AS (
  SELECT 
    s.customer_id,
    m.product_name,
    COUNT(*) AS order_count,
    DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) AS rnk
  FROM sales s
  JOIN menu m ON s.product_id = m.product_id
  GROUP BY s.customer_id, m.product_name
)
SELECT customer_id, product_name, order_count
FROM CustomerFavorites
WHERE rnk = 1;
```

#### **6. First Purchase After Membership**
**Objective:** Find the first item ordered after joining the membership.  
**Approach:** Filter orders after `join_date` and rank them.  
**SQL:**
```sql
WITH PostMembership AS (
  SELECT 
    s.customer_id, 
    s.order_date, 
    m.product_name,
    DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rnk
  FROM sales s
  JOIN members mem ON s.customer_id = mem.customer_id
  JOIN menu m ON s.product_id = m.product_id
  WHERE s.order_date >= mem.join_date
)
SELECT customer_id, order_date, product_name
FROM PostMembership
WHERE rnk = 1;
```

#### **7. Last Purchase Before Membership**
**Objective:** Identify the last item ordered before joining.  
**Approach:** Filter orders before `join_date` and rank in reverse.  
**SQL:**
```sql
WITH PreMembership AS (
  SELECT 
    s.customer_id, 
    s.order_date, 
    m.product_name,
    DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rnk
  FROM sales s
  JOIN members mem ON s.customer_id = mem.customer_id
  JOIN menu m ON s.product_id = m.product_id
  WHERE s.order_date < mem.join_date
)
SELECT customer_id, order_date, product_name
FROM PreMembership
WHERE rnk = 1;
```

#### **8. Total Items and Spending Before Membership**
**Objective:** Calculate purchases made before joining.  
**Approach:** Sum quantities and prices for pre-membership orders.  
**SQL:**
```sql
SELECT 
  s.customer_id,
  COUNT(*) AS total_items,
  SUM(m.price) AS total_spent
FROM sales s
JOIN members mem ON s.customer_id = mem.customer_id
JOIN menu m ON s.product_id = m.product_id
WHERE s.order_date < mem.join_date
GROUP BY s.customer_id;
```

#### **9. Points Earned with Sushi Bonus**
**Objective:** Calculate points (2x for sushi).  
**Approach:** Use `CASE` to apply multipliers.  
**SQL:**
```sql
SELECT 
  s.customer_id,
  SUM(CASE 
        WHEN m.product_name = 'sushi' THEN m.price * 20 
        ELSE m.price * 10 
      END) AS total_points
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;
```

#### **10. Points in First Membership Week**
**Objective:** Apply double points in the first week.  
**Approach:** Use date logic to identify the promotional period.  
**SQL:**
```sql
WITH MembershipPoints AS (
  SELECT 
    s.customer_id,
    s.order_date,
    mem.join_date,
    m.price,
    CASE 
      WHEN s.order_date BETWEEN mem.join_date AND DATEADD(DAY, 6, mem.join_date) THEN 20
      WHEN m.product_name = 'sushi' THEN 20
      ELSE 10
    END AS points_multiplier
  FROM sales s
  JOIN members mem ON s.customer_id = mem.customer_id
  JOIN menu m ON s.product_id = m.product_id
  WHERE s.order_date <= '2021-01-31'
)
SELECT 
  customer_id,
  SUM(price * points_multiplier) AS total_points
FROM MembershipPoints
GROUP BY customer_id;
```

---

### **3. Bonus Questions**

#### **Join All The Things**
**Objective:** Combine data with membership status.  
**SQL:**
```sql
SELECT 
  s.customer_id,
  s.order_date,
  m.product_name,
  m.price,
  CASE 
    WHEN s.order_date >= mem.join_date THEN 'Y' 
    ELSE 'N' 
  END AS is_member
FROM sales s
LEFT JOIN menu m ON s.product_id = m.product_id
LEFT JOIN members mem ON s.customer_id = mem.customer_id
ORDER BY s.customer_id, s.order_date;
```

#### **Rank All The Things**
**Objective:** Add ranking for member orders.  
**SQL:**
```sql
WITH CombinedData AS (
  SELECT 
    s.customer_id,
    s.order_date,
    m.product_name,
    m.price,
    CASE 
      WHEN s.order_date >= mem.join_date THEN 'Y' 
      ELSE 'N' 
    END AS is_member
  FROM sales s
  LEFT JOIN menu m ON s.product_id = m.product_id
  LEFT JOIN members mem ON s.customer_id = mem.customer_id
)
SELECT 
  *,
  CASE 
    WHEN is_member = 'Y' THEN
      RANK() OVER (PARTITION BY customer_id, is_member ORDER BY order_date)
    ELSE NULL
  END AS ranking
FROM CombinedData
ORDER BY customer_id, order_date;
```

---

### **Key Takeaways**
- **Joins and Aggregation:** Critical for combining data and summarizing metrics.
- **Window Functions:** Essential for ranking and time-based analysis.
- **Conditional Logic:** `CASE` statements handle dynamic calculations like points.
- **Data Filtering:** Proper `WHERE` clauses ensure accurate time windows (e.g., pre/post membership).

This analysis provides actionable insights into customer behavior and membership impact at Danny's Diner.
