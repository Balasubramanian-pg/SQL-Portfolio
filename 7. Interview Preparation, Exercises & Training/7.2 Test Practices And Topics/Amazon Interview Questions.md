Okay, let's break down these SQL questions. I'll create a plausible schema that should cover most of these scenarios and then address each question individually.

**Plausible E-commerce Database Schema**

```sql
-- Customers Table
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255) UNIQUE,
    region_id INT,
    city VARCHAR(100),
    join_date DATE,
    is_prime BOOLEAN DEFAULT FALSE,
    referrer_id INT NULL -- Self-reference or link to another customer
);

-- Regions Table
CREATE TABLE Regions (
    region_id INT PRIMARY KEY,
    name VARCHAR(100) UNIQUE
);

-- Categories Table
CREATE TABLE Categories (
    category_id INT PRIMARY KEY,
    name VARCHAR(100) UNIQUE
);

-- Sellers Table
CREATE TABLE Sellers (
    seller_id INT PRIMARY KEY,
    name VARCHAR(255)
);

-- Suppliers Table
CREATE TABLE Suppliers (
    supplier_id INT PRIMARY KEY,
    name VARCHAR(255)
);

-- Products Table
CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    name VARCHAR(255),
    category_id INT,
    seller_id INT,
    supplier_id INT, -- Assuming product directly linked to one supplier for simplicity
    current_price DECIMAL(10, 2),
    FOREIGN KEY (category_id) REFERENCES Categories(category_id),
    FOREIGN KEY (seller_id) REFERENCES Sellers(seller_id),
    FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id)
);

-- ProductPriceHistory Table (for Q16)
CREATE TABLE ProductPriceHistory (
    history_id INT PRIMARY KEY AUTO_INCREMENT, -- Or use a composite key
    product_id INT,
    price DECIMAL(10, 2),
    effective_date DATE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- Orders Table
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date TIMESTAMP,
    status VARCHAR(50), -- e.g., 'Completed', 'Shipped', 'Delivered', 'Returned'
    shipped_date TIMESTAMP NULL,
    delivery_date TIMESTAMP NULL,
    total_amount DECIMAL(12, 2), -- Can be calculated or stored
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- OrderItems Table
CREATE TABLE OrderItems (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    price_per_unit DECIMAL(10, 2), -- Price at the time of order
    discount_amount DECIMAL(10, 2) DEFAULT 0.00,
    returned_quantity INT DEFAULT 0, -- Specific for Q6
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- Reviews Table
CREATE TABLE Reviews (
    review_id INT PRIMARY KEY,
    product_id INT,
    customer_id INT,
    rating INT, -- Assuming 1 to 5 stars
    review_date DATE,
    review_text TEXT NULL,
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Referrals Table (for Q11)
CREATE TABLE Referrals (
    referral_id INT PRIMARY KEY,
    referrer_customer_id INT, -- The customer who referred
    referred_customer_id INT UNIQUE, -- The customer who was referred (assuming one referral per new customer)
    referral_date DATE,
    FOREIGN KEY (referrer_customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (referred_customer_id) REFERENCES Customers(customer_id)
);

-- DeliveryIssues Table (for Q8)
CREATE TABLE DeliveryIssues (
    issue_id INT PRIMARY KEY,
    order_id INT UNIQUE, -- Assuming one reported issue per order for simplicity
    issue_type VARCHAR(100), -- e.g., 'Late Delivery', 'Damaged Item', 'Lost Package'
    report_date DATE,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

-- SearchImpressions Table (for Q20)
CREATE TABLE SearchImpressions (
    impression_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    customer_id INT NULL, -- Can be null if user is not logged in
    impression_timestamp TIMESTAMP,
    search_query VARCHAR(255) NULL,
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- CartEvents Table (for Q15 - Simplified)
CREATE TABLE CartEvents (
   event_id INT PRIMARY KEY AUTO_INCREMENT,
   session_id VARCHAR(255), -- To track a user session
   customer_id INT NULL,
   product_id INT,
   event_type VARCHAR(20), -- 'add', 'remove', 'checkout_start', 'purchase_attempt'
   event_timestamp TIMESTAMP,
   FOREIGN KEY (product_id) REFERENCES Products(product_id),
   FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- NPS_Surveys Table (for Q18)
CREATE TABLE NPS_Surveys (
    survey_id INT PRIMARY KEY,
    customer_id INT,
    score INT, -- 0-10
    survey_date DATE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);
```


Now, let's answer each question:

**1. Retrieve the top 5 products that experienced the highest sales growth in the last quarter compared to the previous quarter.**

*   **Schema:** `Orders`, `OrderItems`, `Products`
*   **Approach:**
    1.  Define the date ranges for the 'last quarter' and the 'previous quarter'.
    2.  Calculate total sales revenue for each product within the last quarter.
    3.  Calculate total sales revenue for each product within the previous quarter.
    4.  Join these results by product ID. Use COALESCE to handle products with sales in only one quarter (treat missing quarter sales as 0).
    5.  Calculate the growth (last quarter sales - previous quarter sales).
    6.  Order by growth in descending order and limit to 5.
*   **Code:** (Using PostgreSQL/MySQL date functions; adjust syntax if needed)
    ```sql
    WITH LastQuarterSales AS (
        SELECT
            oi.product_id,
            SUM(oi.quantity * oi.price_per_unit) AS total_sales
        FROM OrderItems oi
        JOIN Orders o ON oi.order_id = o.order_id
        WHERE o.order_date >= date_trunc('quarter', CURRENT_DATE) - INTERVAL '3 months' -- Start of last quarter
          AND o.order_date < date_trunc('quarter', CURRENT_DATE)                    -- End of last quarter (start of current)
        GROUP BY oi.product_id
    ),
    PreviousQuarterSales AS (
        SELECT
            oi.product_id,
            SUM(oi.quantity * oi.price_per_unit) AS total_sales
        FROM OrderItems oi
        JOIN Orders o ON oi.order_id = o.order_id
        WHERE o.order_date >= date_trunc('quarter', CURRENT_DATE) - INTERVAL '6 months' -- Start of previous quarter
          AND o.order_date < date_trunc('quarter', CURRENT_DATE) - INTERVAL '3 months' -- End of previous quarter
        GROUP BY oi.product_id
    )
    SELECT
        p.product_id,
        p.name,
        COALESCE(lqs.total_sales, 0) AS last_quarter_sales,
        COALESCE(pqs.total_sales, 0) AS previous_quarter_sales,
        (COALESCE(lqs.total_sales, 0) - COALESCE(pqs.total_sales, 0)) AS sales_growth
    FROM Products p
    LEFT JOIN LastQuarterSales lqs ON p.product_id = lqs.product_id
    LEFT JOIN PreviousQuarterSales pqs ON p.product_id = pqs.product_id
    WHERE COALESCE(lqs.total_sales, 0) > 0 OR COALESCE(pqs.total_sales, 0) > 0 -- Only include products with sales in at least one period
    ORDER BY sales_growth DESC
    LIMIT 5;
    ```
*   **Explanation:** Two CTEs calculate sales per product for the last and previous quarters based on the current date. These are joined with the `Products` table. `COALESCE` ensures that if a product had no sales in a quarter, its sales are treated as 0. The difference (growth) is calculated, ordered, and the top 5 are selected.

**2. Calculate the month-over-month growth rate in revenue for each product category.**

*   **Schema:** `Orders`, `OrderItems`, `Products`, `Categories`
*   **Approach:**
    1.  Calculate the total monthly revenue for each product category.
    2.  Use the `LAG()` window function to get the previous month's revenue for each category.
    3.  Calculate the growth rate: `(current_revenue - previous_revenue) / previous_revenue`. Handle division by zero or null previous revenue.
*   **Code:**
    ```sql
    WITH MonthlyCategoryRevenue AS (
        SELECT
            c.category_id,
            c.name AS category_name,
            date_trunc('month', o.order_date) AS sales_month,
            SUM(oi.quantity * oi.price_per_unit) AS monthly_revenue
        FROM OrderItems oi
        JOIN Orders o ON oi.order_id = o.order_id
        JOIN Products p ON oi.product_id = p.product_id
        JOIN Categories c ON p.category_id = c.category_id
        GROUP BY c.category_id, c.name, sales_month
    ),
    LaggedRevenue AS (
        SELECT
            category_id,
            category_name,
            sales_month,
            monthly_revenue,
            LAG(monthly_revenue, 1, 0) OVER (PARTITION BY category_id ORDER BY sales_month) AS previous_month_revenue -- Default to 0 if no prev month
        FROM MonthlyCategoryRevenue
    )
    SELECT
        category_name,
        to_char(sales_month, 'YYYY-MM') AS sales_month_str, -- Format for readability
        monthly_revenue,
        previous_month_revenue,
        CASE
            WHEN previous_month_revenue IS NULL OR previous_month_revenue = 0 THEN NULL -- Or 0% or specific indicator
            ELSE ROUND(((monthly_revenue - previous_month_revenue) / previous_month_revenue) * 100.0, 2)
        END AS mom_growth_rate_percent
    FROM LaggedRevenue
    ORDER BY category_name, sales_month;
    ```
*   **Explanation:** The first CTE aggregates revenue by category and month. The second CTE uses `LAG()` partitioned by category and ordered by month to find the revenue from the preceding month. The final SELECT calculates the percentage growth, handling cases where the previous month had no revenue.

**3. Identify customers who made repeat purchases within the last 90 days.**

*   **Schema:** `Orders`
*   **Approach:**
    1.  Filter orders placed within the last 90 days.
    2.  Group the filtered orders by `customer_id`.
    3.  Count the number of orders for each customer in that period.
    4.  Select customers having a count greater than 1.
*   **Code:**
    ```sql
    SELECT
        c.customer_id,
        c.name,
        c.email,
        COUNT(o.order_id) AS purchase_count_last_90_days
    FROM Customers c
    JOIN Orders o ON c.customer_id = o.customer_id
    WHERE o.order_date >= CURRENT_DATE - INTERVAL '90 days'
      AND o.status != 'Returned' -- Optional: Exclude fully returned orders if needed
    GROUP BY c.customer_id, c.name, c.email
    HAVING COUNT(o.order_id) > 1
    ORDER BY purchase_count_last_90_days DESC;
    ```
*   **Explanation:** This query joins `Customers` and `Orders`, filters orders within the last 90 days, groups by customer, and uses the `HAVING` clause to keep only those customers with more than one order in the period.

**4. List all products with an average rating below 3 stars, along with the total number of reviews.**

*   **Schema:** `Products`, `Reviews`
*   **Approach:**
    1.  Join `Products` and `Reviews` tables.
    2.  Group by product ID and name.
    3.  Calculate the average rating (`AVG(rating)`) and the total count of reviews (`COUNT(review_id)`) for each product.
    4.  Filter the results using `HAVING` to include only products where the average rating is less than 3.
*   **Code:**
    ```sql
    SELECT
        p.product_id,
        p.name,
        COUNT(r.review_id) AS total_reviews,
        AVG(r.rating) AS average_rating
    FROM Products p
    JOIN Reviews r ON p.product_id = r.product_id
    GROUP BY p.product_id, p.name
    HAVING AVG(r.rating) < 3.0
    ORDER BY average_rating ASC, total_reviews DESC;
    ```
*   **Explanation:** The query aggregates review data per product, calculating the count and average rating. The `HAVING` clause filters these aggregated results to show only products with an average rating below 3.

**5. Find the top 3 sellers in each product category based on their revenue contribution.**

*   **Schema:** `Sellers`, `Products`, `OrderItems`, `Orders`, `Categories`
*   **Approach:**
    1.  Calculate the total revenue generated by each seller within each product category.
    2.  Use a window function (`RANK()` or `DENSE_RANK()`) partitioned by category and ordered by revenue (descending) to assign a rank to each seller within their category.
    3.  Filter the results to keep only sellers with a rank of 1, 2, or 3.
*   **Code:**
    ```sql
    WITH SellerCategoryRevenue AS (
        SELECT
            s.seller_id,
            s.name AS seller_name,
            c.category_id,
            c.name AS category_name,
            SUM(oi.quantity * oi.price_per_unit) AS total_revenue
        FROM OrderItems oi
        JOIN Orders o ON oi.order_id = o.order_id
        JOIN Products p ON oi.product_id = p.product_id
        JOIN Sellers s ON p.seller_id = s.seller_id
        JOIN Categories c ON p.category_id = c.category_id
        -- Optional: Filter for a specific time period if needed
        -- WHERE o.order_date >= ... AND o.order_date < ...
        GROUP BY s.seller_id, s.name, c.category_id, c.name
    ),
    RankedSellers AS (
        SELECT
            seller_id,
            seller_name,
            category_id,
            category_name,
            total_revenue,
            RANK() OVER (PARTITION BY category_id ORDER BY total_revenue DESC) as revenue_rank
        FROM SellerCategoryRevenue
    )
    SELECT
        seller_name,
        category_name,
        total_revenue,
        revenue_rank
    FROM RankedSellers
    WHERE revenue_rank <= 3
    ORDER BY category_name, revenue_rank;
    ```
*   **Explanation:** The first CTE calculates total revenue per seller per category. The second CTE assigns a rank to each seller within each category based on that revenue. The final SELECT filters for the top 3 ranks in each category.

**6. Calculate the return rate (number of returned items / total items sold) for each seller.**

*   **Schema:** `Sellers`, `Products`, `OrderItems`
*   **Approach:**
    1.  Aggregate `OrderItems` data, grouping by seller.
    2.  Calculate the sum of `quantity` (total items sold) for each seller.
    3.  Calculate the sum of `returned_quantity` (total items returned) for each seller. (Assuming `returned_quantity` column exists in `OrderItems` or derived from `Orders.status`).
    4.  Calculate the return rate: `sum(returned_quantity) / sum(quantity)`. Handle potential division by zero.
*   **Code:** (Assuming `returned_quantity` in `OrderItems`)
    ```sql
    SELECT
        s.seller_id,
        s.name AS seller_name,
        SUM(oi.quantity) AS total_items_sold,
        SUM(oi.returned_quantity) AS total_items_returned,
        CASE
            WHEN SUM(oi.quantity) = 0 THEN 0.0
            ELSE ROUND((SUM(oi.returned_quantity)::DECIMAL / SUM(oi.quantity)) * 100.0, 2) -- Use ::DECIMAL or CAST for accurate division
        END AS return_rate_percent
    FROM OrderItems oi
    JOIN Products p ON oi.product_id = p.product_id
    JOIN Sellers s ON p.seller_id = s.seller_id
    -- Optional: Filter by order status or date if needed
    GROUP BY s.seller_id, s.name
    ORDER BY return_rate_percent DESC;
    ```
*   **Explanation:** This query joins `OrderItems` through `Products` to `Sellers`. It then aggregates the total quantity sold and the total quantity returned for each seller. Finally, it calculates the return rate as a percentage, ensuring correct decimal division and handling cases where a seller sold zero items.

**7. Identify regions where the sales volume has declined by more than 20% compared to the previous month.**

*   **Schema:** `Regions`, `Customers`, `Orders`
*   **Approach:**
    1.  Calculate the total monthly sales volume (e.g., number of orders or total revenue) for each region.
    2.  Use `LAG()` to get the previous month's sales volume for each region.
    3.  Calculate the percentage decline: `(previous_volume - current_volume) / previous_volume`.
    4.  Filter for the most recent month available and select regions where the decline exceeds 20%.
*   **Code:** (Using sales count as volume)
    ```sql
    WITH MonthlyRegionSales AS (
        SELECT
            r.region_id,
            r.name AS region_name,
            date_trunc('month', o.order_date) AS sales_month,
            COUNT(o.order_id) AS monthly_sales_count -- Or SUM(o.total_amount) for revenue
        FROM Orders o
        JOIN Customers cu ON o.customer_id = cu.customer_id
        JOIN Regions r ON cu.region_id = r.region_id
        GROUP BY r.region_id, r.name, sales_month
    ),
    LaggedRegionSales AS (
        SELECT
            region_id,
            region_name,
            sales_month,
            monthly_sales_count,
            LAG(monthly_sales_count, 1, 0) OVER (PARTITION BY region_id ORDER BY sales_month) AS previous_month_sales_count
        FROM MonthlyRegionSales
    )
    SELECT
        region_name,
        to_char(sales_month, 'YYYY-MM') AS sales_month_str,
        monthly_sales_count,
        previous_month_sales_count,
        ROUND(((previous_month_sales_count - monthly_sales_count)::DECIMAL / previous_month_sales_count) * 100.0, 2) AS decline_percent
    FROM LaggedRegionSales
    WHERE sales_month = (SELECT MAX(sales_month) FROM LaggedRegionSales) -- Focus on the last month with data
      AND previous_month_sales_count > 0 -- Avoid division by zero
      AND ((previous_month_sales_count - monthly_sales_count)::DECIMAL / previous_month_sales_count) > 0.20 -- Decline > 20%
    ORDER BY decline_percent DESC;
    ```
*   **Explanation:** Calculates monthly sales counts per region, uses `LAG` to get the previous month's count, calculates the decline percentage, and filters for regions where this decline is > 20% in the most recent month processed.

**8. Determine the most common delivery issues reported by customers in the last 6 months.**

*   **Schema:** `DeliveryIssues`
*   **Approach:**
    1.  Filter `DeliveryIssues` for reports within the last 6 months.
    2.  Group by `issue_type`.
    3.  Count the occurrences of each issue type.
    4.  Order the results by count in descending order.
*   **Code:**
    ```sql
    SELECT
        issue_type,
        COUNT(*) AS frequency
    FROM DeliveryIssues
    WHERE report_date >= CURRENT_DATE - INTERVAL '6 months'
    GROUP BY issue_type
    ORDER BY frequency DESC;
    -- Optional: Add LIMIT 1 for only the single most common issue
    -- LIMIT 1;
    ```
*   **Explanation:** Filters the `DeliveryIssues` table for the specified period, groups by the type of issue, counts how many times each type appears, and orders them to show the most frequent first.

**9. Retrieve the top 5 cities contributing the highest revenue for the “Electronics” category.**

*   **Schema:** `Customers`, `Orders`, `OrderItems`, `Products`, `Categories`
*   **Approach:**
    1.  Join tables to link orders and items back to customer city and product category.
    2.  Filter `OrderItems` for products belonging to the 'Electronics' category.
    3.  Calculate the total revenue (`quantity * price_per_unit`) for these items.
    4.  Group the results by city.
    5.  Sum the revenue for each city.
    6.  Order cities by total revenue in descending order and limit to 5.
*   **Code:**
    ```sql
    SELECT
        cu.city,
        SUM(oi.quantity * oi.price_per_unit) AS total_electronics_revenue
    FROM OrderItems oi
    JOIN Orders o ON oi.order_id = o.order_id
    JOIN Products p ON oi.product_id = p.product_id
    JOIN Categories c ON p.category_id = c.category_id
    JOIN Customers cu ON o.customer_id = cu.customer_id
    WHERE c.name = 'Electronics' -- Case-sensitive, adjust if needed
      -- Optional: Add date filter if necessary
      -- AND o.order_date >= ... AND o.order_date < ...
    GROUP BY cu.city
    ORDER BY total_electronics_revenue DESC
    LIMIT 5;
    ```
*   **Explanation:** This query joins all necessary tables, filters for 'Electronics' category items, aggregates the revenue by customer city, and then selects the top 5 cities based on this aggregated revenue.

**10. Calculate the customer retention rate for the last 12 months.**

*   **Schema:** `Orders`
*   **Approach:** (Using a common definition: Customers active in period N who were also active in period N-1)
    1.  Define the 'current period' (last 12 months) and the 'previous period' (months -24 to -13).
    2.  Identify distinct customers who made a purchase in the previous period.
    3.  Identify distinct customers who made a purchase in the current period.
    4.  Find the number of customers present in *both* sets (retained customers).
    5.  Calculate Rate = (Retained Customers / Customers in Previous Period) * 100.
*   **Code:**
    ```sql
    WITH PreviousPeriodCustomers AS (
        SELECT DISTINCT customer_id
        FROM Orders
        WHERE order_date >= CURRENT_DATE - INTERVAL '24 months'
          AND order_date < CURRENT_DATE - INTERVAL '12 months'
    ),
    CurrentPeriodCustomers AS (
        SELECT DISTINCT customer_id
        FROM Orders
        WHERE order_date >= CURRENT_DATE - INTERVAL '12 months'
          AND order_date < CURRENT_DATE -- Up to today
    ),
    RetainedCustomers AS (
        SELECT customer_id
        FROM PreviousPeriodCustomers
        INTERSECT -- Or use INNER JOIN
        SELECT customer_id
        FROM CurrentPeriodCustomers
    )
    SELECT
        (SELECT COUNT(*) FROM PreviousPeriodCustomers) AS previous_period_active_customers,
        (SELECT COUNT(*) FROM RetainedCustomers) AS retained_customers,
        CASE
            WHEN (SELECT COUNT(*) FROM PreviousPeriodCustomers) = 0 THEN 0.0
            ELSE ROUND(
                (SELECT COUNT(*) FROM RetainedCustomers)::DECIMAL * 100.0 /
                (SELECT COUNT(*) FROM PreviousPeriodCustomers), 2
            )
        END AS retention_rate_percent;
    ```
*   **Explanation:** Defines CTEs for customers active in the previous 12-month block and the most recent 12-month block. `INTERSECT` finds customers active in both periods. The final SELECT calculates the counts and the retention rate percentage.

**11. Find all users who have referred at least 3 other users through the referral program.**

*   **Schema:** `Referrals`, `Customers`
*   **Approach:**
    1.  Group the `Referrals` table by the `referrer_customer_id`.
    2.  Count the number of distinct `referred_customer_id` for each referrer.
    3.  Filter the groups using `HAVING` to keep only those referrers with a count of 3 or more.
    4.  Join with the `Customers` table to get referrer details.
*   **Code:**
    ```sql
    SELECT
        c.customer_id AS referrer_id,
        c.name AS referrer_name,
        c.email AS referrer_email,
        COUNT(r.referred_customer_id) AS total_referrals
    FROM Referrals r
    JOIN Customers c ON r.referrer_customer_id = c.customer_id
    GROUP BY c.customer_id, c.name, c.email
    HAVING COUNT(r.referred_customer_id) >= 3
    ORDER BY total_referrals DESC;
    ```
*   **Explanation:** Groups the referrals by the referring customer, counts the number of successful referrals for each, and filters using `HAVING` to show only those who referred 3 or more people. Joins to `Customers` to display names/emails.

**12. Write an SQL query to determine the average delivery time per region.**

*   **Schema:** `Orders`, `Customers`, `Regions`
*   **Approach:**
    1.  Join `Orders`, `Customers`, and `Regions`.
    2.  Filter for orders that have been delivered (`delivery_date` is not null and potentially `order_date` is not null). Also ensure `delivery_date` is after `order_date`.
    3.  Calculate the delivery time for each order (difference between `delivery_date` and `order_date` or `shipped_date`). Using `order_date` measures total time, using `shipped_date` measures shipping time. Let's use `order_date`.
    4.  Group by region ID and name.
    5.  Calculate the average delivery time per region. The exact function depends on the SQL dialect (`AVG(DATE_DIFF(...))`, `AVG(delivery_date - order_date)`, etc.).
*   **Code:** (Using PostgreSQL syntax for interval averaging)
    ```sql
    SELECT
        r.region_id,
        r.name AS region_name,
        AVG(o.delivery_date - o.order_date) AS avg_delivery_time_interval -- Returns an interval type
        -- For days as number (adjust based on DB):
        -- AVG(EXTRACT(EPOCH FROM (o.delivery_date - o.order_date)) / 86400.0) AS avg_delivery_days
    FROM Orders o
    JOIN Customers cu ON o.customer_id = cu.customer_id
    JOIN Regions r ON cu.region_id = r.region_id
    WHERE o.delivery_date IS NOT NULL
      AND o.order_date IS NOT NULL
      AND o.delivery_date >= o.order_date -- Ensure valid data
      AND o.status = 'Delivered' -- Or filter based on status if available and reliable
    GROUP BY r.region_id, r.name
    ORDER BY region_name;
    ```
*   **Explanation:** Filters for completed deliveries with valid dates, joins tables to get region information, calculates the time difference for each order, and then averages this difference per region. The exact way to calculate and average time differences varies slightly between SQL databases.

**13. Identify customers who made purchases from 3 or more different product categories in a single month.**

*   **Schema:** `Orders`, `OrderItems`, `Products`, `Categories`, `Customers`
*   **Approach:**
    1.  Join tables to link customers to the categories of products they purchased.
    2.  Extract the year and month from the `order_date`.
    3.  Group by customer ID, year, and month.
    4.  Count the number of *distinct* `category_id` within each group.
    5.  Filter using `HAVING` to keep groups where the distinct category count is 3 or more.
    6.  Select the distinct customer IDs (or names/emails) from the filtered results.
*   **Code:**
    ```sql
    WITH MonthlyCustomerCategories AS (
        SELECT
            o.customer_id,
            date_trunc('month', o.order_date) AS purchase_month,
            p.category_id
        FROM Orders o
        JOIN OrderItems oi ON o.order_id = oi.order_id
        JOIN Products p ON oi.product_id = p.product_id
        -- Optional: Filter for completed orders if necessary
        -- WHERE o.status != 'Returned'
        GROUP BY o.customer_id, purchase_month, p.category_id -- Ensure unique category per customer per month
    ),
    CustomerCategoryCounts AS (
       SELECT
           customer_id,
           purchase_month,
           COUNT(category_id) AS distinct_category_count -- Already distinct due to previous GROUP BY
       FROM MonthlyCustomerCategories
       GROUP BY customer_id, purchase_month
    )
    SELECT DISTINCT -- Select unique customers who met the criteria in any month
        cu.customer_id,
        cu.name,
        cu.email
    FROM CustomerCategoryCounts ccc
    JOIN Customers cu ON ccc.customer_id = cu.customer_id
    WHERE ccc.distinct_category_count >= 3
    ORDER BY cu.customer_id;
    ```
*   **Explanation:** The first CTE identifies the distinct categories purchased by each customer each month. The second CTE counts these distinct categories per customer per month. The final query selects the details of customers who had a count of 3 or more in at least one month.

**14. Calculate the contribution of Prime members to the total revenue in the last year.**

*   **Schema:** `Customers`, `Orders`, `OrderItems`
*   **Approach:**
    1.  Calculate the total revenue from all orders in the last year.
    2.  Calculate the total revenue from orders placed by Prime members (`is_prime = TRUE`) in the last year.
    3.  Calculate the contribution percentage: `(Prime Revenue / Total Revenue) * 100`.
*   **Code:**
    ```sql
    WITH RevenueLastYear AS (
        SELECT
            SUM(oi.quantity * oi.price_per_unit) AS total_revenue,
            SUM(CASE WHEN cu.is_prime = TRUE THEN oi.quantity * oi.price_per_unit ELSE 0 END) AS prime_revenue
        FROM OrderItems oi
        JOIN Orders o ON oi.order_id = o.order_id
        JOIN Customers cu ON o.customer_id = cu.customer_id
        WHERE o.order_date >= CURRENT_DATE - INTERVAL '1 year'
          AND o.order_date < CURRENT_DATE
    )
    SELECT
        total_revenue,
        prime_revenue,
        CASE
            WHEN total_revenue = 0 THEN 0.0
            ELSE ROUND((prime_revenue / total_revenue) * 100.0, 2)
        END AS prime_contribution_percent
    FROM RevenueLastYear;
    ```
*   **Explanation:** Calculates total revenue and prime member revenue within the last year using conditional aggregation (`SUM(CASE WHEN...)`). The final SELECT displays these values and calculates the prime contribution percentage.

**15. Retrieve the top 10 products with the highest cart abandonment rate.**

*   **Schema:** `CartEvents`, `OrderItems`, `Products` (This is complex and depends heavily on how cart events vs actual purchases are tracked. Using a proxy approach: Adds vs Purchases).
*   **Approach (Proxy: Adds vs Purchases):**
    1.  Count the number of times each product was added to a cart (e.g., `event_type = 'add'`) within a recent period.
    2.  Count the number of times each product was actually purchased (`OrderItems`) within the same period.
    3.  Join these counts by product ID.
    4.  Calculate abandonment rate: `(Adds - Purchases) / Adds`. Handle division by zero and cases where purchases > adds (data issue).
    5.  Order by rate descending and limit to 10.
*   **Code:** (Assuming `CartEvents` tracks adds and `OrderItems` tracks purchases)
    ```sql
    WITH ProductAdds AS (
        SELECT
            product_id,
            COUNT(*) as add_count
        FROM CartEvents
        WHERE event_type = 'add'
          AND event_timestamp >= CURRENT_DATE - INTERVAL '30 days' -- Example timeframe
        GROUP BY product_id
    ),
    ProductPurchases AS (
        SELECT
            oi.product_id,
            SUM(oi.quantity) as purchase_count -- Or COUNT(DISTINCT oi.order_id) if counting orders
        FROM OrderItems oi
        JOIN Orders o ON oi.order_id = o.order_id
        WHERE o.order_date >= CURRENT_DATE - INTERVAL '30 days' -- Match timeframe
        GROUP BY oi.product_id
    )
    SELECT
        p.product_id,
        p.name,
        COALESCE(pa.add_count, 0) AS adds,
        COALESCE(pp.purchase_count, 0) AS purchases,
        CASE
            WHEN COALESCE(pa.add_count, 0) = 0 THEN 0.0 -- No adds, no abandonment rate
            WHEN COALESCE(pa.add_count, 0) < COALESCE(pp.purchase_count, 0) THEN 0.0 -- Data issue? Treat as 0%
            ELSE ROUND(
                    (COALESCE(pa.add_count, 0) - COALESCE(pp.purchase_count, 0))::DECIMAL * 100.0
                    / COALESCE(pa.add_count, 0) , 2
                 )
        END AS abandonment_rate_percent
    FROM Products p
    LEFT JOIN ProductAdds pa ON p.product_id = pa.product_id
    LEFT JOIN ProductPurchases pp ON p.product_id = pp.product_id
    WHERE COALESCE(pa.add_count, 0) > 0 -- Only consider products actually added to cart
    ORDER BY abandonment_rate_percent DESC
    LIMIT 10;
    ```
*   **Explanation:** Counts product additions from `CartEvents` and product purchases from `OrderItems` within a recent period. It then calculates an abandonment rate proxy based on these counts, orders the products, and takes the top 10. `COALESCE` handles products added but not purchased, or purchased without a recorded 'add' event (depending on tracking reliability).

**16/ Identify suppliers whose products have experienced the highest price fluctuation in the past 6 months.**

*   **Schema:** `Suppliers`, `Products`, `ProductPriceHistory`
*   **Approach:**
    1.  Filter `ProductPriceHistory` for the last 6 months.
    2.  For each product, calculate a measure of price fluctuation (e.g., Standard Deviation, or (Max Price - Min Price) / Min Price). Let's use Standard Deviation.
    3.  Join with `Products` and `Suppliers` to link fluctuation to suppliers.
    4.  Group by supplier.
    5.  Calculate an aggregate fluctuation metric per supplier (e.g., average or maximum standard deviation across their products). Let's use Average Standard Deviation.
    6.  Order suppliers by this aggregate metric descending.
*   **Code:**
    ```sql
    WITH ProductFluctuation AS (
        SELECT
            product_id,
            STDDEV_SAMP(price) AS price_stddev -- Or STDDEV_POP, or (MAX(price)-MIN(price))/MIN(price)
        FROM ProductPriceHistory
        WHERE effective_date >= CURRENT_DATE - INTERVAL '6 months'
          -- AND effective_date < CURRENT_DATE -- If needed
        GROUP BY product_id
        HAVING COUNT(DISTINCT price) > 1 -- Only include products where price actually changed
    )
    SELECT
        s.supplier_id,
        s.name AS supplier_name,
        AVG(pf.price_stddev) AS avg_product_price_stddev
        -- Alternative: MAX(pf.price_stddev) AS max_product_price_stddev
    FROM ProductFluctuation pf
    JOIN Products p ON pf.product_id = p.product_id
    JOIN Suppliers s ON p.supplier_id = s.supplier_id
    WHERE pf.price_stddev IS NOT NULL AND pf.price_stddev > 0 -- Exclude products with no variance
    GROUP BY s.supplier_id, s.name
    ORDER BY avg_product_price_stddev DESC
    LIMIT 10; -- Example: Top 10 suppliers
    ```
*   **Explanation:** Calculates the standard deviation of prices for each product over the last 6 months using historical price data. It then aggregates this fluctuation metric (using average standard deviation here) at the supplier level and ranks suppliers accordingly.

**17. Write an SQL query to analyze the effect of discounts on sales for a specific product.**

*   **Schema:** `OrderItems`, `Orders`, `Products`
*   **Approach:**
    1.  Filter `OrderItems` for the specific `product_id`.
    2.  Categorize sales into 'Discounted' (`discount_amount > 0`) and 'Non-Discounted' (`discount_amount = 0`).
    3.  Group by this category.
    4.  Calculate key metrics for each group: total quantity sold, number of orders, total revenue, average quantity per order, average selling price (`(SUM(quantity * price_per_unit) - SUM(discount_amount)) / SUM(quantity)`).
*   **Code:** (Replace `:specific_product_id` with the actual ID)
    ```sql
    SELECT
        CASE WHEN oi.discount_amount > 0 THEN 'Discounted' ELSE 'Non-Discounted' END AS discount_status,
        COUNT(DISTINCT oi.order_id) AS number_of_orders,
        SUM(oi.quantity) AS total_quantity_sold,
        SUM(oi.quantity * oi.price_per_unit) AS gross_revenue,
        SUM(oi.discount_amount) AS total_discount_given,
        SUM(oi.quantity * oi.price_per_unit - oi.discount_amount) AS net_revenue,
        AVG(oi.quantity) AS avg_quantity_per_order,
        CASE
            WHEN SUM(oi.quantity) = 0 THEN 0
            ELSE SUM(oi.quantity * oi.price_per_unit - oi.discount_amount) / SUM(oi.quantity)
        END AS avg_net_selling_price
    FROM OrderItems oi
    JOIN Orders o ON oi.order_id = o.order_id
    WHERE oi.product_id = :specific_product_id -- Specify the product ID here
      -- Optional: Add date range filter
      -- AND o.order_date >= ... AND o.order_date < ...
    GROUP BY discount_status;
    ```
*   **Explanation:** This query focuses on a single product ID. It separates the order items for that product into two groups based on whether a discount was applied. It then calculates various sales metrics for each group, allowing comparison to see the impact of discounts (e.g., higher quantity sold but lower average price when discounted).

**18. Determine the Net Promoter Score (NPS) trend over the last year using the Net Promoter Score (NPS).**

*   **Schema:** `NPS_Surveys`
*   **Approach:**
    1.  Filter surveys for the last year.
    2.  Categorize each score: Promoter (9-10), Passive (7-8), Detractor (0-6).
    3.  Group results by a time period (e.g., month or quarter).
    4.  Count the number of Promoters, Passives, and Detractors in each period.
    5.  Calculate NPS for each period: `((Count Promoters - Count Detractors) / Total Responses) * 100`.
*   **Code:** (Grouping by month)
    ```sql
    WITH MonthlyNPSCategories AS (
        SELECT
            date_trunc('month', survey_date) AS survey_month,
            CASE
                WHEN score >= 9 THEN 'Promoter'
                WHEN score >= 7 THEN 'Passive'
                ELSE 'Detractor'
            END AS nps_category
        FROM NPS_Surveys
        WHERE survey_date >= date_trunc('month', CURRENT_DATE) - INTERVAL '1 year'
          AND survey_date < date_trunc('month', CURRENT_DATE) -- Up to start of current month
    ),
    MonthlyNPSCounts AS (
        SELECT
            survey_month,
            COUNT(*) AS total_responses,
            SUM(CASE WHEN nps_category = 'Promoter' THEN 1 ELSE 0 END) AS promoter_count,
            SUM(CASE WHEN nps_category = 'Detractor' THEN 1 ELSE 0 END) AS detractor_count
        FROM MonthlyNPSCategories
        GROUP BY survey_month
    )
    SELECT
        to_char(survey_month, 'YYYY-MM') AS survey_month_str,
        total_responses,
        promoter_count,
        detractor_count,
        CASE
            WHEN total_responses = 0 THEN NULL
            ELSE ROUND(
                    (promoter_count - detractor_count)::DECIMAL * 100.0 / total_responses
                 , 1) -- NPS usually shown with 1 decimal place or none
        END AS nps_score
    FROM MonthlyNPSCounts
    ORDER BY survey_month;
    ```
*   **Explanation:** Categorizes NPS scores from surveys within the last year. Aggregates counts of Promoters and Detractors per month. Calculates the final NPS score for each month based on the standard formula, showing the trend over time.

**19. Calculate the average revenue per customer (ARPU) for each quarter.**

*   **Schema:** `Orders`, `OrderItems`, `Customers`
*   **Approach:**
    1.  Calculate total revenue per quarter.
    2.  Count the number of *distinct* customers who made a purchase in each quarter.
    3.  Divide total revenue by the distinct customer count for each quarter to get ARPU.
*   **Code:**
    ```sql
    WITH QuarterlyRevenue AS (
        SELECT
            date_trunc('quarter', o.order_date) AS sales_quarter,
            o.customer_id,
            SUM(oi.quantity * oi.price_per_unit) AS revenue
        FROM OrderItems oi
        JOIN Orders o ON oi.order_id = o.order_id
        -- Optional: Filter only 'Completed' orders etc.
        GROUP BY sales_quarter, o.customer_id
    ),
    QuarterlyAggregates AS (
        SELECT
            sales_quarter,
            SUM(revenue) AS total_quarterly_revenue,
            COUNT(DISTINCT customer_id) AS distinct_active_customers
        FROM QuarterlyRevenue
        GROUP BY sales_quarter
    )
    SELECT
        to_char(sales_quarter, 'YYYY-Q') AS quarter_str,
        total_quarterly_revenue,
        distinct_active_customers,
        CASE
            WHEN distinct_active_customers = 0 THEN 0.0
            ELSE ROUND(total_quarterly_revenue / distinct_active_customers, 2)
        END AS arpu
    FROM QuarterlyAggregates
    ORDER BY sales_quarter;
    ```
*   **Explanation:** Calculates revenue per customer per quarter first. Then aggregates total revenue and counts distinct active customers per quarter. Finally, divides revenue by customer count to get ARPU for each quarter.

**20. Identify the products that had a significant increase in search impressions but low conversion rates.**

*   **Schema:** `SearchImpressions`, `OrderItems`, `Products`, `Orders`
*   **Approach:** (Defining "significant increase" and "low conversion" requires thresholds or comparison to averages). Let's compare the last month to the previous month for impressions and calculate the conversion rate for the last month.
    1.  Calculate impressions per product for the last month and the previous month.
    2.  Calculate purchases (e.g., number of orders containing the product) per product for the last month.
    3.  Join these metrics.
    4.  Calculate impression growth rate.
    5.  Calculate conversion rate (Purchases / Impressions) for the last month.
    6.  Filter for products where impression growth > threshold (e.g., 50%) AND conversion rate < threshold (e.g., 1%).
*   **Code:** (Using placeholder thresholds)
    ```sql
    -- Define time periods
    DEFINE last_month_start = date_trunc('month', CURRENT_DATE) - INTERVAL '1 month';
    DEFINE last_month_end = date_trunc('month', CURRENT_DATE);
    DEFINE prev_month_start = date_trunc('month', CURRENT_DATE) - INTERVAL '2 months';
    DEFINE prev_month_end = date_trunc('month', CURRENT_DATE) - INTERVAL '1 month';

    WITH LastMonthImpressions AS (
        SELECT product_id, COUNT(*) as impression_count
        FROM SearchImpressions
        WHERE impression_timestamp >= :last_month_start AND impression_timestamp < :last_month_end
        GROUP BY product_id
    ),
    PrevMonthImpressions AS (
        SELECT product_id, COUNT(*) as impression_count
        FROM SearchImpressions
        WHERE impression_timestamp >= :prev_month_start AND impression_timestamp < :prev_month_end
        GROUP BY product_id
    ),
    LastMonthPurchases AS (
        SELECT oi.product_id, COUNT(DISTINCT oi.order_id) as purchase_count -- Count orders with the product
        FROM OrderItems oi
        JOIN Orders o ON oi.order_id = o.order_id
        WHERE o.order_date >= :last_month_start AND o.order_date < :last_month_end
        GROUP BY oi.product_id
    )
    SELECT
        p.product_id,
        p.name,
        COALESCE(lmi.impression_count, 0) AS last_month_impressions,
        COALESCE(pmi.impression_count, 0) AS prev_month_impressions,
        COALESCE(lmp.purchase_count, 0) AS last_month_purchases,
        -- Impression Growth Rate (%)
        CASE
            WHEN COALESCE(pmi.impression_count, 0) = 0 THEN NULL -- Or handle as infinite growth if last month > 0
            ELSE ROUND(((COALESCE(lmi.impression_count, 0) - COALESCE(pmi.impression_count, 0))::DECIMAL / COALESCE(pmi.impression_count, 0)) * 100.0, 2)
        END AS impression_growth_pct,
        -- Conversion Rate (%) for Last Month
        CASE
            WHEN COALESCE(lmi.impression_count, 0) = 0 THEN 0.0
            ELSE ROUND((COALESCE(lmp.purchase_count, 0)::DECIMAL / COALESCE(lmi.impression_count, 0)) * 100.0, 2)
        END AS conversion_rate_pct
    FROM Products p
    LEFT JOIN LastMonthImpressions lmi ON p.product_id = lmi.product_id
    LEFT JOIN PrevMonthImpressions pmi ON p.product_id = pmi.product_id
    LEFT JOIN LastMonthPurchases lmp ON p.product_id = lmp.product_id
    WHERE
        COALESCE(lmi.impression_count, 0) > 0 -- Must have impressions last month
        AND COALESCE(pmi.impression_count, 0) > 0 -- Must have impressions prev month for growth calc
        -- Filter Condition 1: Significant Impression Growth (e.g., > 50%)
        AND ((COALESCE(lmi.impression_count, 0) - COALESCE(pmi.impression_count, 0))::DECIMAL / COALESCE(pmi.impression_count, 0)) > 0.50
        -- Filter Condition 2: Low Conversion Rate (e.g., < 1%)
        AND (CASE WHEN COALESCE(lmi.impression_count, 0) = 0 THEN 0.0 ELSE (COALESCE(lmp.purchase_count, 0)::DECIMAL / COALESCE(lmi.impression_count, 0)) END) < 0.01
    ORDER BY impression_growth_pct DESC, conversion_rate_pct ASC;

    ```
*   **Explanation:** Calculates impressions for the last two months and purchases for the last month per product. It then calculates the impression growth rate and the conversion rate for the last month. Finally, it filters products that meet both criteria: high impression growth (e.g., >50%) and low conversion rate (e.g., <1%). The specific thresholds (0.50 and 0.01) should be adjusted based on business context. (Note: Date variable syntax depends on the specific SQL client/environment).