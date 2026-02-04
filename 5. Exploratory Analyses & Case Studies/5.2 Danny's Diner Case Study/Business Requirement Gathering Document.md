## **Clique Bait Analysis: Questions and Answers**
by balasubramanyan18@gmail.com

This document breaks down a comprehensive analysis of the Clique Bait dataset, covering entity relationships, digital user behavior, product funnels, and marketing campaigns.

### **1. Entity Relationship Diagram (ERD)**

**Task:** Create an ERD for all the Clique Bait datasets based on the DDL schema.

**Explanation of Schema and Relationships:**

Based on the queries provided, we can infer the following table structures and their relationships. This ERD describes how the different data tables connect to form a cohesive database.

*   **Entities (Tables):**
    *   `users`: Stores user and cookie information.
    *   `events`: The main transactional table, recording every event that occurs during a visit.
    *   `event_identifier`: A lookup table to describe event types.
    *   `page_hierarchy`: A lookup table to describe page details, including product information.
    *   `campaign_identifier`: A lookup table for marketing campaign details and dates.

*   **Relationships:**
    *   **`users` --< `events`**: A one-to-many relationship. One `user_id` can have multiple `cookie_id`s, and each `cookie_id` can be associated with many events. The link is `users.cookie_id` -> `events.cookie_id`.
    *   **`event_identifier` >-- `events`**: A one-to-many relationship. Each `event_type` in `event_identifier` can appear many times in the `events` table. The link is `event_identifier.event_type` -> `events.event_type`.
    *   **`page_hierarchy` >-- `events`**: A one-to-many relationship. Each `page_id` in `page_hierarchy` can be visited multiple times, generating multiple events. The link is `page_hierarchy.page_id` -> `events.page_id`.
    *   **`campaign_identifier` <> `events`**: A conditional relationship based on a date range. A visit (identified by its start time in the `events` table) is linked to a campaign if its `event_time` falls between the campaign's `start_date` and `end_date`. There isn't a direct foreign key.

**Conceptual ERD:**

*   **`users`**
    *   `user_id` (Primary Key)
    *   `cookie_id`
    *   `start_date`
*   **`events`**
    *   `visit_id`
    *   `cookie_id` (Foreign Key to `users`)
    *   `page_id` (Foreign Key to `page_hierarchy`)
    *   `event_type` (Foreign Key to `event_identifier`)
    *   `sequence_number`
    *   `event_time`
*   **`event_identifier`**
    *   `event_type` (Primary Key)
    *   `event_name`
*   **`page_hierarchy`**
    *   `page_id` (Primary Key)
    *   `page_name`
    *   `product_category`
    *   `product_id`
*   **`campaign_identifier`**
    *   `campaign_id`
    *   `campaign_name`
    *   `start_date`
    *   `end_date`

### **2. Digital Analysis**

#### **1. How many users are there?**

**Query:**
```sql
SELECT
  COUNT(DISTINCT user_id) AS n_users
FROM
  clique_bait.users;
```
**Results:**
| n_users |
| :--- |
| 500 |

**Explanation:**
This query counts the total number of unique users in the database. It selects the `user_id` column from the `users` table and uses `COUNT(DISTINCT ...)` to ensure that each user is counted only once, even if they appear multiple times with different cookies. The result shows there are 500 unique users.

#### **2. How many cookies does each user have on average?**

**Query:**
```sql
WITH get_all_cookies AS (
  SELECT
    user_id,
    COUNT(DISTINCT cookie_id) AS n_cookies
  FROM
    clique_bait.users
  GROUP BY
    user_id
)
SELECT
  ROUND(AVG(n_cookies), 2) AS avg_cookies
FROM
  get_all_cookies;

-- Alternative, more concise query:
SELECT 
    ROUND(AVG(count(DISTINCT cookie_id)) OVER (), 2) AS avg_cookies
FROM clique_bait.users
GROUP BY user_id
LIMIT 1;
```
**Results:**
| avg_cookies |
| :--- |
| 3.56 |

**Explanation:**
This query calculates the average number of cookies per user.
1.  The `WITH` clause creates a temporary table `get_all_cookies` which first groups the `users` table by `user_id` and counts the number of unique `cookie_id`s for each user.
2.  The final `SELECT` statement then calculates the average (`AVG`) of these counts.
3.  `ROUND(..., 2)` formats the result to two decimal places.
On average, each user has approximately 3.56 cookies.


#### **3. What is the unique number of visits by all users per month?**

**Query:**
```sql
WITH get_all_visits AS (
  SELECT
    cookie_id,
    COUNT(DISTINCT visit_id) AS n_visits,
    EXTRACT('month' FROM event_time) AS visited_month
  FROM
    clique_bait.events
  GROUP BY
    cookie_id,
    visited_month
)
SELECT
  visited_month,
  SUM(n_visits) AS total_visits
FROM
  get_all_visits
GROUP BY
  visited_month
ORDER BY
  visited_month;
```
**Results:**
| visited_month | total_visits |
| :--- | :--- |
| 1.0 | 876 |
| 2.0 | 1488 |
| 3.0 | 916 |
| 4.0 | 248 |
| 5.0 | 36 |

**Explanation:**
This query aggregates the total number of unique user visits for each month.
1.  The `WITH` clause first extracts the month from `event_time` using `EXTRACT('month' FROM ...)`. It then counts the number of distinct `visit_id`s for each `cookie_id` within each month.
2.  The outer query then takes these monthly counts and sums them up (`SUM(n_visits)`) grouped by `visited_month` to get the total visits across all users for each month. The busiest month was February (Month 2).

#### **4. What is the number of events for each event type?**

**Query:**
```sql
SELECT
  e.event_type,
  ei.event_name,
  COUNT(e.event_type) AS n_events
FROM
  clique_bait.events AS e
  JOIN clique_bait.event_identifier AS ei ON e.event_type = ei.event_type
GROUP BY
  e.event_type,
  ei.event_name
ORDER BY
  e.event_type;
```
**Results:**
| event_type | event_name | n_events |
| :--- | :--- | :--- |
| 1 | Page View | 20928 |
| 2 | Add to Cart | 8451 |
| 3 | Purchase | 1777 |
| 4 | Ad Impression | 876 |
| 5 | Ad Click | 702 |

**Explanation:**
This query counts the occurrences of each type of event. It joins the `events` table with the `event_identifier` lookup table on `event_type` to retrieve the readable `event_name`. It then groups the results by both event type and name and counts the total number of events (`COUNT(e.event_type)`) in each group. 'Page View' is the most common event.

#### **5. What is the percentage of visits which have a purchase event?**

**Query:**
```sql
SELECT
  ROUND(
    100 * SUM(
      CASE WHEN event_type = 3 THEN 1 ELSE 0 END
    ) :: NUMERIC / COUNT(DISTINCT visit_id),
    2
  ) AS purchase_percentage
FROM
  clique_bait.events;
```
**Results:**
| purchase_percentage |
| :--- |
| 49.86 |

**Explanation:**
This query calculates the percentage of visits that resulted in a purchase.
1.  `SUM(CASE WHEN event_type = 3 THEN 1 ELSE 0 END)` counts the total number of purchase events.
2.  `COUNT(DISTINCT visit_id)` counts the total number of unique visits.
3.  The purchase count is divided by the total visit count and multiplied by 100 to get the percentage.
4.  The `::NUMERIC` cast is used to ensure the division results in a decimal value rather than an integer.
Almost half (49.86%) of all visits include a purchase event.

#### **6. What is the percentage of visits which view the checkout page but do not have a purchase event?**

**Query:**
```sql
WITH get_counts AS (
  SELECT
    visit_id,
    -- flag as visit_id having visited checkout page and had page view event.
    SUM(
      CASE WHEN page_id = 12 AND event_type = 1 THEN 1 ELSE 0 END
    ) AS checked_out,
    -- flag as visit_id having made a purchase.
    SUM(
      CASE WHEN event_type = 3 THEN 1 ELSE 0 END
    ) AS purchased
  FROM
    clique_bait.events
  GROUP BY
    visit_id
)
SELECT
  -- Subtract percentage that did visit and purchase from 100%
  ROUND(
    100 * (1 - SUM(purchased) :: NUMERIC / SUM(checked_out)),
    2
  ) AS visit_percentage
FROM
  get_counts;
```
**Results:**
| visit_percentage |
| :--- |
| 15.50 |

**Explanation:**
This query calculates the percentage of visits where a user went to the checkout page but did not complete a purchase.
1.  The `get_counts` CTE groups all events by `visit_id`. For each visit, it creates two flags:
    *   `checked_out`: A count of how many times the checkout page (`page_id = 12`) was viewed.
    *   `purchased`: A count of how many times a purchase event (`event_type = 3`) occurred.
2.  The outer query calculates `SUM(purchased) / SUM(checked_out)`, which is the proportion of visits that reached checkout *and* made a purchase.
3.  Subtracting this proportion from 1 and multiplying by 100 gives the percentage of visits that reached checkout but were abandoned. 15.50% of visits that reach the checkout page do not result in a purchase.

#### **7. What are the top 3 pages by number of views?**

**Query:**
```sql
SELECT
  e.page_id,
  ph.page_name,
  COUNT(e.page_id) AS n_page
FROM
  clique_bait.events AS e
  JOIN clique_bait.page_hierarchy AS ph ON e.page_id = ph.page_id
WHERE
  e.event_type = 1
GROUP BY
  e.page_id,
  ph.page_name
ORDER BY
  n_page DESC
LIMIT
  3;
```
**Results:**
| page_id | page_name | n_page |
| :--- | :--- | :--- |
| 2 | All Products | 3174 |
| 12 | Checkout | 2103 |
| 1 | Home Page | 1782 |

**Explanation:**
This is a standard "Top N" query to find the most viewed pages.
1.  It joins `events` and `page_hierarchy` to get page names.
2.  The `WHERE e.event_type = 1` clause filters for 'Page View' events only.
3.  It groups by page and counts the views for each.
4.  `ORDER BY n_page DESC` sorts the pages from most to least viewed.
5.  `LIMIT 3` restricts the output to the top three results.

#### **8. Which product categories contribute the most to page views and cart adds?**
*Note: The original question asked for `age_band` and `demographic`, but the provided query analyzes `product_category`. The explanation below follows the provided query.*

**Query:**
```sql
SELECT
  ph.product_category,
  SUM(
    CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END
  ) AS page_views,
  SUM(
    CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END
  ) AS add_to_cart
FROM
  clique_bait.page_hierarchy AS ph
  JOIN clique_bait.events AS e ON e.page_id = ph.page_id
WHERE
  ph.product_category IS NOT NULL
GROUP BY
  ph.product_category
ORDER BY
  page_views DESC;
```
**Results:**
| product_category | page_views | add_to_cart |
| :--- | :--- | :--- |
| Shellfish | 6204 | 3792 |
| Fish | 4633 | 2789 |
| Luxury | 3032 | 1870 |

**Explanation:**
This query aggregates key metrics for each product category.
1.  It joins `page_hierarchy` and `events` and filters for rows where a `product_category` exists.
2.  It uses conditional aggregation (`SUM(CASE WHEN ...)`):
    *   It counts `page_views` by summing 1 for each event of type 1.
    *   It counts `add_to_cart` by summing 1 for each event of type 2.
3.  The results are grouped by `product_category` to show the total counts for each, with Shellfish being the most popular category.

#### **9. What are the top 3 products by purchases?**

**Query:**
```sql
WITH get_purchases AS (
  SELECT
    visit_id
  FROM
    clique_bait.events
  WHERE
    event_type = 3
)
SELECT
  ph.page_name,
  SUM(
    CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END
  ) AS top_3_purchased
FROM
  clique_bait.page_hierarchy AS ph
  JOIN clique_bait.events AS e ON e.page_id = ph.page_id
  JOIN get_purchases AS gp ON e.visit_id = gp.visit_id
WHERE
  ph.product_category IS NOT NULL
GROUP BY
  ph.page_name
ORDER BY
  top_3_purchased DESC
LIMIT
  3;
```
**Results:**
| page_name | top_3_purchased |
| :--- | :--- |
| Lobster | 754 |
| Oyster | 726 |
| Crab | 719 |

**Explanation:**
This query identifies the top 3 most purchased products. The logic is to count how many times a product was added to a cart during a visit that ultimately resulted in a purchase.
1.  The `get_purchases` CTE creates a list of all `visit_id`s where a purchase event occurred.
2.  The main query joins `events` and `page_hierarchy` with this `get_purchases` list. This effectively filters for events that are part of a purchasing journey.
3.  It then counts the "Add to Cart" events (`event_type = 2`) within these successful visits.
4.  The final result is grouped by product `page_name` and ordered to show the top 3 products.

### **3. Product Funnel Analysis**

#### **Task 1: Create a detailed product performance table.**

**Query:**
```sql
DROP TABLE IF EXISTS product_info;
CREATE TEMP TABLE product_info AS (
  WITH product_viewed AS (
    SELECT
      ph.page_id,
      SUM(CASE WHEN event_type = 1 THEN 1 ELSE 0 END) AS n_page_views,
      SUM(CASE WHEN event_type = 2 THEN 1 ELSE 0 END) AS n_added_to_cart
    FROM clique_bait.page_hierarchy AS ph
    JOIN clique_bait.events AS e ON ph.page_id = e.page_id
    WHERE ph.product_id IS NOT NULL
    GROUP BY ph.page_id
  ),
  product_purchased AS (
    SELECT
      e.page_id,
      SUM(CASE WHEN event_type = 2 THEN 1 ELSE 0 END) AS purchased_from_cart
    FROM clique_bait.events AS e
    WHERE e.product_id IS NOT NULL
      AND EXISTS (
        SELECT 1 FROM clique_bait.events AS e2
        WHERE e2.event_type = 3 AND e.visit_id = e2.visit_id
      )
    GROUP BY e.page_id
  ),
  product_abandoned AS (
    SELECT
      e.page_id,
      SUM(CASE WHEN event_type = 2 THEN 1 ELSE 0 END) AS abandoned_in_cart
    FROM clique_bait.events AS e
    WHERE e.product_id IS NOT NULL
      AND NOT EXISTS (
        SELECT 1 FROM clique_bait.events AS e2
        WHERE e2.event_type = 3 AND e.visit_id = e2.visit_id
      )
    GROUP BY e.page_id
  )
  SELECT
    ph.page_id,
    ph.page_name,
    ph.product_category,
    pv.n_page_views,
    pv.n_added_to_cart,
    pp.purchased_from_cart,
    pa.abandoned_in_cart
  FROM clique_bait.page_hierarchy AS ph
  LEFT JOIN product_viewed AS pv ON pv.page_id = ph.page_id
  LEFT JOIN product_purchased AS pp ON pp.page_id = ph.page_id
  LEFT JOIN product_abandoned AS pa ON pa.page_id = ph.page_id
  WHERE ph.product_id IS NOT NULL
);
SELECT * FROM product_info;
```

**Explanation:**
This query creates a temporary table `product_info` that summarizes the entire sales funnel for each product.
1.  **`product_viewed` CTE:** Counts total page views and cart adds for each product.
2.  **`product_purchased` CTE:** Counts cart adds that occurred during a visit that was eventually completed with a purchase. It uses `EXISTS` to check for a purchase event (`event_type = 3`) within the same `visit_id`.
3.  **`product_abandoned` CTE:** Counts cart adds where the visit was *not* completed with a purchase. It uses `NOT EXISTS` to find visits without a purchase event.
4.  **Final `SELECT`:** Joins these CTEs with the `page_hierarchy` table to combine all the metrics (views, adds, purchases, abandonments) for each product into a single, comprehensive table.
   
#### **Task 2: Create a product category performance table.**

**Query:**
```sql
DROP TABLE IF EXISTS category_info;
CREATE TEMP TABLE category_info AS (
  SELECT
    product_category,
    SUM(n_page_views) AS total_page_view,
    SUM(n_added_to_cart) AS total_added_to_cart,
    SUM(purchased_from_cart) AS total_purchased,
    SUM(abandoned_in_cart) AS total_abandoned
  FROM
    product_info
  GROUP BY
    product_category
);
SELECT * FROM category_info;
```
**Results:**
| product_category | total_page_view | total_added_to_cart | total_purchased | total_abandoned |
| :--- | :--- | :--- | :--- | :--- |
| Luxury | 3032 | 1870 | 1404 | 466 |
| Shellfish | 6204 | 3792 | 2898 | 894 |
| Fish | 4633 | 2789 | 2115 | 674 |

**Explanation:**
This query aggregates the data from the `product_info` table to a higher level. It groups the detailed product data by `product_category` and sums up the views, cart adds, purchases, and abandonments to provide a category-level overview of the sales funnel.

#### **1. Which product had the most views, cart adds and purchases?**

**Query:**
```sql
WITH rankings AS (
  SELECT
    page_name,
    RANK() OVER (ORDER BY n_page_views DESC) AS most_page_views,
    RANK() OVER (ORDER BY n_added_to_cart DESC) AS most_cart_adds,
    RANK() OVER (ORDER BY purchased_from_cart DESC) AS most_purchased
  FROM
    product_info
)
SELECT page_name, 'Most Viewed' AS metric FROM rankings WHERE most_page_views = 1
UNION
SELECT page_name, 'Most Added to Cart' AS metric FROM rankings WHERE most_cart_adds = 1
UNION
SELECT page_name, 'Most Purchased' AS metric FROM rankings WHERE most_purchased = 1;
```
**Results:**
| page_name | metric |
| :--- | :--- |
| Oyster | Most Viewed |
| Lobster | Most Added to Cart |
| Lobster | Most Purchased |

**Explanation:**
This query uses the `RANK()` window function to identify the top product for three different metrics.
1.  The `rankings` CTE calculates a rank for each product based on its page views, cart adds, and purchases. `RANK() OVER (ORDER BY ... DESC)` assigns a rank of 1 to the product with the highest value.
2.  The final query uses `UNION` to combine three separate `SELECT` statements, each pulling the product with a rank of 1 for one of the metrics.

#### **2. Which product was most likely to be abandoned?**

**Explanation:**
The initial interpretation of "most abandoned" could mean the product with the highest absolute number of abandoned carts. However, "most *likely* to be abandoned" is a question of probability, meaning the product with the highest *rate* of abandonment after being added to the cart.

**Query (for highest abandonment *rate*):**
```sql
SELECT
  page_name,
  ROUND(
    100 * abandoned_in_cart :: NUMERIC / n_added_to_cart, 2
  ) AS abandoned_ratio
FROM
  product_info
ORDER BY
  abandoned_ratio DESC
LIMIT
  1;
```
**Results:**
| page_name | abandoned_ratio |
| :--- | :--- |
| Russian Caviar | 26.32 |

**Explanation:**
This query correctly identifies the product most *likely* to be abandoned. It calculates the abandonment ratio for each product by dividing the number of abandoned carts (`abandoned_in_cart`) by the total number of times it was added to a cart (`n_added_to_cart`). The product with the highest ratio, Russian Caviar, is the one a customer is most likely to remove or leave behind after considering it.

#### **3. Which product had the highest view-to-purchase percentage?**

**Query:**
```sql
SELECT
  page_name,
  ROUND(
    100 * purchased_from_cart :: NUMERIC / n_page_views,
    2
  ) AS purchased_views_ratio
FROM
  product_info
ORDER BY
  purchased_views_ratio DESC
LIMIT
  1;
```
**Results:**
| page_name | purchased_views_ratio |
| :--- | :--- |
| Lobster | 48.74 |

**Explanation:**
This query calculates the conversion rate from a page view to a final purchase. For each product, it divides the total number of purchases (`purchased_from_cart`) by the total number of page views (`n_page_views`) and orders the results to find the highest ratio. Lobster is the most effective product at converting an initial view into a sale.

#### **4. What is the average conversion rate from view to cart add?**

**Query:**
```sql
SELECT
  ROUND(
    AVG(100 * n_added_to_cart :: NUMERIC / n_page_views),
    2
  ) AS views_added_ratio
FROM
  product_info;
```
**Results:**
| views_added_ratio |
| :--- |
| 60.95 |

**Explanation:**
This query calculates the average "view-to-cart" conversion rate across all products. For each product, it first calculates the ratio of cart adds to page views. Then, it uses `AVG()` to find the average of these individual product ratios. On average, about 61% of page views lead to the item being added to the cart.

#### **5. What is the average conversion rate from cart add to purchase?**

**Query:**
```sql
SELECT
  ROUND(
    AVG(
      100 * purchased_from_cart :: NUMERIC / n_added_to_cart
    ),
    2
  ) AS added_purchased_ratio
FROM
  product_info;
```
**Results:**
| added_purchased_ratio |
| :--- |
| 75.93 |

**Explanation:**
This query calculates the average "cart-to-purchase" conversion rate across all products. For each product, it calculates the ratio of successful purchases to cart adds. Then, it uses `AVG()` to find the average of these ratios. On average, nearly 76% of items added to a cart are successfully purchased.

### **4. Campaigns Analysis**

**Task:** Generate a table that has 1 single row for every unique `visit_id` record, summarizing the visit's activities and linking it to a marketing campaign.

**Query:**
```sql
DROP TABLE IF EXISTS campaign_analysis;
CREATE TEMP TABLE campaign_analysis AS (
  WITH purchase_check AS (
    SELECT
      visit_id,
      CASE WHEN SUM(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) >= 1 THEN TRUE ELSE FALSE END AS purchase_flag
    FROM clique_bait.events
    GROUP BY visit_id
  ),
  get_cart_items AS (
    SELECT
      e.visit_id,
      STRING_AGG(ph.page_name, ', ' ORDER BY e.sequence_number) AS cart_items
    FROM clique_bait.events AS e
    JOIN clique_bait.page_hierarchy AS ph ON ph.page_id = e.page_id
    WHERE e.event_type = 2
    GROUP BY e.visit_id
  )
  SELECT
    e.visit_id,
    u.user_id,
    MIN(e.event_time) AS visit_start_time,
    SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS page_views,
    SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS cart_adds,
    pc.purchase_flag,
    ci.campaign_name,
    SUM(CASE WHEN e.event_type = 4 THEN 1 ELSE 0 END) AS ad_impressions,
    SUM(CASE WHEN e.event_type = 5 THEN 1 ELSE 0 END) AS ad_clicks,
    COALESCE(gci.cart_items, '') AS cart_products
  FROM clique_bait.events AS e
  JOIN clique_bait.users AS u ON u.cookie_id = e.cookie_id
  JOIN purchase_check AS pc ON pc.visit_id = e.visit_id
  LEFT JOIN clique_bait.campaign_identifier AS ci ON MIN(e.event_time) BETWEEN ci.start_date AND ci.end_date
  LEFT JOIN get_cart_items AS gci ON gci.visit_id = e.visit_id
  GROUP BY
    e.visit_id, u.user_id, pc.purchase_flag, ci.campaign_name, gci.cart_items
  ORDER BY
    u.user_id, visit_start_time
);
SELECT * FROM campaign_analysis LIMIT 12;
```

**Explanation:**
This powerful query creates a complete summary table for each visit.
1.  **`purchase_check` CTE:** Creates a boolean flag (`purchase_flag`) for each `visit_id` to indicate if a purchase occurred during that visit.
2.  **`get_cart_items` CTE:** For each visit with cart activity, this creates a comma-separated list of the product names added to the cart, ordered by the sequence they were added (`STRING_AGG`).
3.  **Main Query:**
    *   It aggregates the `events` table by `visit_id`.
    *   **Joins:** It connects `events` to `users` (to get `user_id`), to `purchase_check` (to get the purchase flag), and to `get_cart_items` (to get the list of cart items).
    *   **Campaign Join:** It uses a `LEFT JOIN` to `campaign_identifier`, matching the visit's start time (`MIN(event_time)`) to a campaign's date range. A `LEFT JOIN` is used because not all visits will fall within a campaign period.
    *   **Aggregations:** It uses `MIN` to find the visit start time and conditional `SUM` to count page views, cart adds, ad impressions, and ad clicks for each visit.
    *   **Cart Products:** `COALESCE` is used to display an empty string instead of `NULL` for visits with no items added to the cart.
The final table provides a 360-degree view of each visit, perfect for analyzing user behavior and campaign effectiveness.