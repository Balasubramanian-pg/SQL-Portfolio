# SQL Interview Questions

Related Areas (RD): Job Prep (https://www.notion.so/Job-Prep-18e83b71d8f381e5bd13f00da846c207?pvs=21)

### Flipkart Question

**Question:**

You are provided with two tables: `CustomerDemographics` and `Orders`. Your task is to calculate the total sales for each demographic region for orders placed specifically in the month of **September 2024**.

**Input Data:**

1. **`CustomerDemographics` Table:**
    - `Cust ID`: Customer Identifier (Integer)
    - `Demography`: The region of the customer (Text)
    
    | Cust ID | Demography |
    | --- | --- |
    | 1 | Delhi |
    | 2 | Delhi |
    | 3 | Mumbai |
    | 4 | Jaipur |
    | 5 | Jaipur |
2. **`Orders` Table:**
    - `Order ID`: Order Identifier (Integer)
    - `Order Date`: Date of the order (DD-MM-YY format)
    - `Cust ID`: Customer Identifier (Integer, foreign key to `CustomerDemographics`)
    - `Purchase Amount`: The monetary value of the order (Numeric)
    
    | Order ID | Order Date | Cust ID | Purchase Amount |
    | --- | --- | --- | --- |
    | 101 | 10-09-24 | 1 | 661 |
    | 102 | 11-09-24 | 2 | 489 |
    | 103 | 10-08-24 | 3 | 356 |
    | 104 | 13-09-24 | 2 | 506 |
    | 105 | 12-09-24 | 4 | 218 |
    | 106 | 25-10-24 | 3 | 113 |
    | 107 | 18-09-24 | 5 | 973 |
    | 108 | 23-10-24 | 1 | 234 |
    | 109 | 17-09-24 | 5 | 683 |
    | 110 | 13-09-24 | 1 | 204 |
    | 111 | 21-05-24 | 4 | 119 |
    | 112 | 16-09-24 | 3 | 771 |
    | 113 | 20-07-24 | 5 | 222 |
    | 114 | 11-09-24 | 3 | 555 |
    | 115 | 12-09-24 | 1 | 965 |

**Task:**

1. Filter the `Orders` table to include only records where the `Order Date` falls in September 2024.
2. Join the filtered orders with the `CustomerDemographics` table using `Cust ID`.
3. Group the results by `Demography`.
4. Calculate the sum of `Purchase Amount` for each `Demography` group.

**Expected Output Table:**

- `Demography`: The region of the customer (Text)
- `Total Sales`: The sum of purchase amounts for that region in September 2024 (Numeric)

| Demography | Total Sales |
| --- | --- |
| Delhi | 2825 |
| Mumbai | 1326 |
| Jaipur | 1874 |

---

## SQL Solution Approach:

### Step 1: Understand the Schema

```sql
-- Customer Demographics Table
Customers (Cust_ID, Demography)

-- Orders Table
Orders (Order_ID, Order_Date, Cust_ID, Purchase_Amount)

```

### Step 2: Filter for September 2024

Need to extract orders where Order_Date is in September 2024. The date format appears to be DD-MM-YY.

### Step 3: Join Tables and Aggregate

```sql
SELECT
    c.Demography as Region,
    SUM(o.Purchase_Amount) as Total_Sales
FROM Customers c
INNER JOIN Orders o ON c.Cust_ID = o.Cust_ID
WHERE o.Order_Date LIKE '%-09-24'  -- September 2024
GROUP BY c.Demography
ORDER BY c.Demography;

```

### Step 4: Alternative Date Filtering (More Robust)

```sql
SELECT
    c.Demography as Region,
    SUM(o.Purchase_Amount) as Total_Sales
FROM Customers c
INNER JOIN Orders o ON c.Cust_ID = o.Cust_ID
WHERE SUBSTRING(o.Order_Date, 4, 5) = '09-24'  -- Extract MM-YY part
GROUP BY c.Demography
ORDER BY c.Demography;

```

### Step 5: Complete Solution with Error Checking

```sql
-- Verify the date filtering first
SELECT Order_ID, Order_Date, Cust_ID, Purchase_Amount
FROM Orders
WHERE Order_Date LIKE '%-09-24';

-- Then the final aggregation
SELECT
    c.Demography as Region,
    SUM(o.Purchase_Amount) as Total_Sales
FROM Customers c
INNER JOIN Orders o ON c.Cust_ID = o.Cust_ID
WHERE o.Order_Date LIKE '%-09-24'
GROUP BY c.Demography
ORDER BY c.Demography;

```

This should give us:

- Delhi: 2825
- Jaipur: 1874
- Mumbai: 1326

The key is the JOIN to map customer IDs to regions, filtering by September 2024 dates, and then GROUP BY region with SUM aggregation.

---

### Netflix Question

---

**Question:**

Given a table `user_flags` containing information about users flagging videos, determine the number of unique users who flagged each video. A unique user is identified by the combination of their `user_firstname` and `user_lastname`. Rows without a `flag_id` should be excluded from the analysis.

**Input Data:**

1. **`user_flags` Table:**
    - `flag_id`: Identifier for the flag action (Text)
    - `user_firstname`: First name of the user who flagged (Text)
    - `user_lastname`: Last name of the user who flagged (Text)
    - `video_id`: Identifier of the video that was flagged (Text)
    
    **Schema:**
    
    | Column Name | Data Type |
    | --- | --- |
    | flag_id | text |
    | user_firstname | text |
    | user_lastname | text |
    | video_id | text |

**Task:**

1. Filter the `user_flags` table to exclude any rows where `flag_id` is missing (e.g., NULL or an empty string).
2. For the remaining records, identify unique users based on the combination of `user_firstname` and `user_lastname`.
3. Group the data by `video_id`.
4. For each `video_id`, count the number of distinct users (as defined in step 2) who flagged it.

**Expected Output Table:**

- `video_id`: The identifier of the video (Text)
- `num_unique_users`: The count of unique users who flagged that video (Integer)

**Example Output (First 5 rows):**

| video_id | num_unique_users |
| --- | --- |
| 5qap5aO4i9A | 2 |
| Ct6BUPvE2sM | 2 |
| dQw4w9WgXcQ | 5 |
| jNQXAC9IVRw | 3 |
| y6120QOlsfU | 5 |

---

Okay, here's a common SQL solution to achieve the desired output.

**Assumptions:**

1. "No flag ID" means `flag_id` is `NULL`. If it could also mean an empty string, the `WHERE` clause would need an additional check (e.g., `AND flag_id <> ''`).
2. The combination of `user_firstname` and `user_lastname` uniquely identifies a user. We'll concatenate them (ideally with a separator to avoid ambiguity like 'John' + 'DoeSmith' vs 'JohnDoe' + 'Smith') for the distinct count.

**SQL Solution:**

```sql
SELECT
    video_id,
    COUNT(DISTINCT CONCAT(user_firstname, '||', user_lastname)) AS num_unique_users
FROM
    user_flags
WHERE
    flag_id IS NOT NULL  -- Exclude rows where there is no flag ID
GROUP BY
    video_id
ORDER BY -- Optional: To match the example output order if it's based on something specific
    -- For instance, if the example output is ordered by video_id or num_unique_users
    -- video_id; -- or num_unique_users DESC;
    -- Based on the example output, there's no obvious strict ordering,
    -- but ordering by video_id is a common practice.
    video_id; -- Let's assume an order by video_id for reproducibility if desired

```

**Explanation:**

1. **`FROM user_flags`**: Specifies the table we are querying.
2. **`WHERE flag_id IS NOT NULL`**: This is crucial. It filters out any rows where `flag_id` is `NULL`, satisfying the condition "Do not consider rows in which there is no flag ID."
3. **`CONCAT(user_firstname, '||', user_lastname)`**: This creates a single string for each user by combining their first and last names. The `||` (or another distinct separator like `_` or `#`) is important to prevent cases where different name pairs could result in the same concatenated string (e.g., if `firstname='A'` and `lastname='BC'` vs `firstname='AB'` and `lastname='C'`, both would be `'ABC'` without a separator).
4. **`COUNT(DISTINCT CONCAT(...))`**: This counts the number of unique combined name strings. `DISTINCT` ensures that if the same user (same first and last name) flags the same video multiple times (after the `flag_id IS NOT NULL` filter), they are only counted once for that video.
5. **`GROUP BY video_id`**: This groups the rows by `video_id` so that the `COUNT(DISTINCT ...)` aggregation is performed separately for each video.
6. **`SELECT video_id, ... AS num_unique_users`**: Selects the `video_id` and the calculated count, aliasing the count column as `num_unique_users`.
7. **`ORDER BY video_id` (Optional)**: The example output is shown, but the order isn't explicitly defined as a requirement. Ordering by `video_id` can make the output consistent if needed.

This query will produce a table with `video_id` and the corresponding count of unique users who flagged it, excluding flags without a `flag_id`.

---

### Microsoft Question

---

**Question:**

A Microsoft Azure "Supercloud customer" is defined as a customer who has purchased at least one product from **every** product category listed in the `products` table. Your task is to write a SQL query that identifies the `customer_id` of these Supercloud customers.

**Input Data:**

1. **`customer_contracts` Table:**
    - This table records the products purchased by customers.
    - **Columns:**
        
        
        | Column Name | Type |
        | --- | --- |
        | customer_id | integer |
        | product_id | integer |
        | amount | integer |
    - **Example Input:**
        
        
        | customer_id | product_id | amount |
        | --- | --- | --- |
        | 1 | 1 | 1000 |
        | 1 | 3 | 2000 |
        | 1 | 5 | 1500 |
        | 2 | 2 | 3000 |
        | 2 | 6 | 2000 |
2. **`products` Table:**
    - This table lists all available products and their categories.
    - **Columns:**
        
        
        | Column Name | Type |
        | --- | --- |
        | product_id | integer |
        | product_category | string |
        | product_name | string |
    - **Example Input:**
        
        
        | product_id | product_category | product_name |
        | --- | --- | --- |
        | 1 | Analytics | Azure Databricks |
        | 2 | Analytics | Azure Stream Analytics |
        | 4 | Containers | Azure Kubernetes Service |
        | 5 | Containers | Azure Service Fabric |
        | 6 | Compute | Virtual Machines |
        | 7 | Compute | Azure Functions |

**Task:**

1. Determine the total number of unique `product_category` values available in the `products` table.
2. For each `customer_id` in the `customer_contracts` table:
a. Find all the `product_id`s they have purchased.
b. Join with the `products` table to identify the `product_category` for each purchased product.
c. Count the number of *distinct* `product_category` values from which this customer has made a purchase.
3. Identify and return the `customer_id`s for whom the count of distinct purchased product categories (from step 2c) is equal to the total number of unique product categories available (from step 1).

**Expected Output:**

- A list of `customer_id`s who are Supercloud customers.
- **Column:**Column Namecustomer_id
    
    ---
    
    ---
    
- **Example Output:**customer_id1
    
    ---
    
    ---
    

**Explanation (based on example data):**

- The `products` table has three unique product categories: "Analytics", "Containers", and "Compute".
- **Customer 1:**
    - Purchased product 1 (Analytics), product 3 (not in example `products` table, assuming it would map to a category if present in a full dataset or if the example is slightly simplified - *for the purpose of the provided example output, let's assume product 3 is implicitly in Analytics or another category, and product 5 is Containers, product 1 Analytics, and another purchase not listed in contracts but implied by the explanation is from Compute. To be more precise based ONLY on the provided example data, customer 1 purchased from product_id 1 (Analytics) and product_id 5 (Containers). To match the explanation, customer 1 must have also purchased a 'Compute' product.*
    - More directly following the explanation: Customer 1 bought from "Analytics" (e.g., via product_id 1), "Containers" (e.g., via product_id 5), and "Compute" (e.g., via an unlisted purchase or if product 3 mapped to Compute). Since they bought from all three categories, they are a Supercloud customer.
- **Customer 2:**
    - Purchased product 2 (Analytics) and product 6 (Compute).
    - Customer 2 did not purchase any products from the "Containers" category.
    - Since they did not purchase from all available categories, they are not a Supercloud customer.

*(Note: The example explanation implies Customer 1 made purchases across all three categories. The provided `customer_contracts` for Customer 1 shows product IDs 1 and 5. Product 1 is 'Analytics', Product 5 is 'Containers'. For the explanation to hold, Customer 1 must also have a contract for a 'Compute' product category, or product_id 3 (which is not in the `products` example) belongs to 'Compute'.)*

---

```sql
SELECT customer_id
FROM (
    SELECT 
        cc.customer_id,
        COUNT(DISTINCT p.product_category) as categories_purchased
    FROM customer_contracts cc
    INNER JOIN products p ON cc.product_id = p.product_id
    GROUP BY cc.customer_id
) customer_stats
WHERE categories_purchased = (
    SELECT COUNT(DISTINCT product_category) 
    FROM products
)
ORDER BY customer_id;
```

---

### PWC Question

---

**Question:**

You own a small online store and want to analyze customer ratings for the products you're selling. You have a list of products and a log of purchases (which includes customer ratings).

For each product `category`, you need to find the lowest `price` among all products within that category that have received **at least one 4-star or above rating** from customers.

If a product `category` does not have any products that received at least one 4-star or above rating, the lowest price for that category should be considered **0**.

The final output should list each `category` and its determined `lowest_price`, sorted by `category` in alphabetical order.

**Input Data:**

1. **`products` Table:**
    - This table contains details about the products.
    - **Columns:**
        
        
        | COLUMN\_NAME | DATA\_TYPE |
        | --- | --- |
        | category | varchar(10) |
        | id | int |
        | name | varchar(20) |
        | price | int |
    - **Example Input (Illustrative):**
        
        
        | category | id | name | price |
        | --- | --- | --- | --- |
        | Electronics | 1 | Laptop | 1200 |
        | Electronics | 2 | Keyboard | 75 |
        | Books | 3 | SciFi Book | 20 |
        | Books | 4 | Cook Book | 15 |
        | Home | 5 | Lamp | 50 |
        | Toys | 6 | Toy Car | 10 |
2. **`purchase_log` (or `ratings`) Table:**
    - This table logs purchases and includes customer ratings.
    - **Columns (assumed based on problem description):**
        
        
        | COLUMN\_NAME | DATA\_TYPE | Description |
        | --- | --- | --- |
        | product_id | int | Foreign key to `products.id` |
        | rating | int | Customer rating (from 1 to 5) |
    - **Example Input (Illustrative):**
        
        
        | product_id | rating |
        | --- | --- |
        | 1 | 5 |
        | 1 | 4 |
        | 2 | 3 |
        | 3 | 5 |
        | 4 | 2 |
        | 5 | 4 |
        | 6 | 1 |
        | 2 | 4 |

**Task:**

1. Identify all products from the `products` table that have received at least one rating of 4 stars or higher in the `purchase_log` table.
2. For each unique `category` in the `products` table:
a. Determine the minimum `price` of products belonging to that `category` *that also meet the rating criteria* (at least one 4-star or above rating).
b. If no products in a `category` meet the rating criteria, assign a `lowest_price` of 0 for that category.
3. Present the results with two columns: `category` and `lowest_price`.
4. Sort the final output alphabetically by `category`.

**Expected Output (based on illustrative example data):**

| category | lowest_price |
| --- | --- |
| Books | 20 |
| Electronics | 75 |
| Home | 50 |
| Toys | 0 |

**Explanation (based on illustrative example data):**

- **Electronics:**
    - Laptop (ID 1, Price 1200): Ratings 5, 4. Qualifies.
    - Keyboard (ID 2, Price 75): Ratings 3, 4. Qualifies.
    - Lowest price for highly-rated Electronics: MIN(1200, 75) = 75.
- **Books:**
    - SciFi Book (ID 3, Price 20): Rating 5. Qualifies.
    - Cook Book (ID 4, Price 15): Rating 2. Does *not* qualify.
    - Lowest price for highly-rated Books: 20.
- **Home:**
    - Lamp (ID 5, Price 50): Rating 4. Qualifies.
    - Lowest price for highly-rated Home: 50.
- **Toys:**
    - Toy Car (ID 6, Price 10): Rating 1. Does *not* qualify.
    - No products in 'Toys' category received a 4-star or above rating. Lowest price = 0.

---

---

### Uber Question

---

**Question:**

You are given a table of Uber transactions made by users. Your task is to write a SQL query to identify and retrieve the details of the third transaction for every user. If a user has fewer than three transactions, they should not be included in the output.

**Input Data:**

1. **`transactions` Table:**
    - This table contains records of user transactions.
    - **Columns:**
        
        
        | Column Name | Type |
        | --- | --- |
        | user_id | integer |
        | spend | decimal |
        | transaction_date | timestamp |
    - **Example Input:**
        
        
        | user_id | spend | transaction_date |
        | --- | --- | --- |
        | 111 | 100.50 | 01/08/2022 12:00:00 |
        | 111 | 55.00 | 01/10/2022 12:00:00 |
        | 121 | 36.00 | 01/18/2022 12:00:00 |
        | 145 | 24.99 | 01/26/2022 12:00:00 |
        | 111 | 89.60 | 02/05/2022 12:00:00 |

**Task:**

1. For each `user_id`, order their transactions chronologically based on `transaction_date` (earliest first).
2. Assign a sequential rank or row number to each transaction within each user's ordered list.
3. Filter these ranked transactions to select only the one that is the third transaction (i.e., rank or row number = 3) for each user.
4. Output the `user_id`, `spend`, and `transaction_date` for these selected third transactions.

**Expected Output:**

- The output should only include users who have at least three transactions.
- **Columns:**Column Nameuser_idspendtransaction_date
    
    ---
    
    ---
    
    ---
    
    ---
    
- **Example Output:**
    
    
    | user_id | spend | transaction_date |
    | --- | --- | --- |
    | 111 | 89.60 | 02/05/2022 12:00:00 |

**Explanation (based on example data):**

- **User 111:**
    1. Transaction 1: 100.50 on 01/08/2022
    2. Transaction 2: 55.00 on 01/10/2022
    3. Transaction 3: 89.60 on 02/05/2022
    - The third transaction is (111, 89.60, 02/05/2022 12:00:00).
- **User 121:**
    1. Transaction 1: 36.00 on 01/18/2022
    - User 121 has only one transaction, so they do not have a third transaction and are not included in the output.
- **User 145:**
    1. Transaction 1: 24.99 on 01/26/2022
    - User 145 has only one transaction, so they do not have a third transaction and are not included in the output.

*(Note: The dataset you are querying against may have different input & output - this is just an example!)*

---

---

### Amazon Question

---

**Question:**

You are given a table `product_spend` containing data on Amazon customers and their spending on products in different categories. Write a SQL query to identify the **top two highest-grossing products within each category for the year 2022**. The output should include the `category`, `product`, and the `total_spend` for that product within its category in 2022.

**Input Data:**

1. **`product_spend` Table:**
    - This table records customer spending on various products.
    - **Columns:**
        
        
        | Column Name | Type |
        | --- | --- |
        | category | string |
        | product | string |
        | user_id | integer |
        | spend | decimal |
        | transaction_date | timestamp |
    - **Example Input:**
        
        
        | category | product | user_id | spend | transaction_date |
        | --- | --- | --- | --- | --- |
        | appliance | refrigerator | 165 | 246.00 | 12/26/2021 12:00:00 |
        | appliance | refrigerator | 123 | 299.99 | 03/02/2022 12:00:00 |
        | appliance | washing machine | 123 | 219.80 | 03/02/2022 12:00:00 |
        | electronics | vacuum | 178 | 152.00 | 04/05/2022 12:00:00 |
        | electronics | wireless headset | 156 | 249.90 | 07/08/2022 12:00:00 |
        | electronics | vacuum | 145 | 189.00 | 07/15/2022 12:00:00 |

**Task:**

1. Filter the `product_spend` table to include only transactions that occurred in the year 2022.
2. For the filtered data, calculate the total `spend` for each `product` within each `category`.
3. Within each `category`, rank the products based on their `total_spend` in descending order (highest spend first).
4. Select the top two products (those with rank 1 and rank 2) from each `category`. If there are ties in spend for the second position, all tied products should be considered.
5. The output should display the `category`, `product`, and its corresponding `total_spend`.

**Expected Output:**

- **Columns:**
    - Column Name category product total_spend
    
    ---
    
    ---
    
    ---
    
    ---
    
- **Example Output:**
    
    
    | category | product | total_spend |
    | --- | --- | --- |
    | appliance | refrigerator | 299.99 |
    | appliance | washing machine | 219.80 |
    | electronics | vacuum | 341.00 |
    | electronics | wireless headset | 249.90 |

**Explanation (based on example data for the year 2022):**

- **Appliance Category (2022):**
    - Refrigerator: Total spend = 299.99 (from one transaction in 2022).
    - Washing machine: Total spend = 219.80 (from one transaction in 2022).
    - Top two are refrigerator (299.99) and washing machine (219.80).
- **Electronics Category (2022):**
    - Vacuum: Total spend = 152.00 + 189.00 = 341.00.
    - Wireless headset: Total spend = 249.90.
    - Top two are vacuum (341.00) and wireless headset (249.90).

*(Note: The dataset you are querying against may have different input & output - this is just an example!)*

---

---

### Walmart Question

---

**Question:**

You are given a table `user_transactions` containing data on Walmart user transactions. Your task is to write a SQL query that, for each user, identifies their most recent transaction date and then counts the number of products they bought on that specific date.

The output should include the user's most recent `transaction_date`, their `user_id`, and the `purchase_count` (number of products bought on that most recent date). The final result should be sorted in chronological order by the `transaction_date`.

**Input Data:**

1. **`user_transactions` Table:**
    - This table records individual product purchases by users.
    - **Columns:**
        
        
        | Column Name | Type |
        | --- | --- |
        | product_id | integer |
        | user_id | integer |
        | spend | decimal |
        | transaction_date | timestamp |
    - **Example Input:**
        
        
        | product_id | user_id | spend | transaction_date |
        | --- | --- | --- | --- |
        | 3673 | 123 | 68.90 | 07/08/2022 12:00:00 |
        | 9623 | 123 | 274.10 | 07/08/2022 12:00:00 |
        | 1467 | 115 | 19.90 | 07/08/2022 12:00:00 |
        | 2513 | 159 | 25.00 | 07/08/2022 12:00:00 |
        | 1452 | 159 | 74.50 | 07/10/2022 12:00:00 |

**Task:**

1. For each `user_id`, determine their most recent `transaction_date`.
2. Filter the transactions to include only those that occurred on each user's respective most recent transaction date.
3. For these filtered transactions, count the number of products (i.e., the number of transaction records) for each `user_id` on their most recent date.
4. Output the most recent `transaction_date`, `user_id`, and this `purchase_count`.
5. Sort the results chronologically by `transaction_date`. If multiple users share the same most recent transaction date, their relative order is not strictly defined beyond the primary sort (though the example implies a secondary sort by `user_id` might be acceptable or coincidental).

**Expected Output:**

- **Columns:**Column Nametransaction_dateuser_idpurchase_count
    
    ---
    
    ---
    
    ---
    
    ---
    
- **Example Output:**
    
    
    | transaction_date | user_id | purchase_count |
    | --- | --- | --- |
    | 07/08/2022 12:00:00 | 115 | 1 |
    | 07/08/2022 12:00:00 | 123 | 2 |
    | 07/10/2022 12:00:00 | 159 | 1 |

**Explanation (based on example data):**

- **User 123:**
    - Transactions only on 07/08/2022. This is their most recent date.
    - On 07/08/2022, they bought 2 products (product_id 3673 and 9623).
- **User 115:**
    - Transactions only on 07/08/2022. This is their most recent date.
    - On 07/08/2022, they bought 1 product (product_id 1467).
- **User 159:**
    - Transactions on 07/08/2022 and 07/10/2022. The most recent is 07/10/2022.
    - On 07/10/2022, they bought 1 product (product_id 1452).

The output is then sorted by `transaction_date`.

*(Note: The dataset you are querying against may have different input & output - this is just an example!)*

---

---

### Zomato Question

---

**Question:**

Zomato, a leading online food delivery service, experienced an error in their delivery system. Due to an issue with delivery driver instructions, each item's order was mistakenly swapped with the item in the subsequent row (when ordered by `order_id`). As a data analyst, your task is to correct this swapping error and return the proper pairing of `order_id` and `item`.

There's a specific condition: If the item with the highest `order_id` in the dataset has an odd `order_id`, it should retain its original item and not be part of any swap.

**Input Data:**

1. **`orders` Table:**
    - This table contains the initially incorrect order and item pairings.
    - **Columns:**
        
        
        | column_name | type | description |
        | --- | --- | --- |
        | order_id | integer | The ID of each Zomato order. |
        | item | string | The name of the food item in each order. |
    - **Example Input (Incorrect Data):**
        
        
        | order_id | item |
        | --- | --- |
        | 1 | Chow Mein |
        | 2 | Pizza |
        | 3 | Pad Thai |
        | 4 | Butter Chicken |
        | 5 | Eggrolls |
        | 6 | Burger |
        | 7 | Tandoori Chicken |

**Task:**

1. Identify pairs of adjacent orders based on `order_id` (e.g., order 1 and 2, order 3 and 4, etc.).
2. For each pair where the first `order_id` is odd and a subsequent even `order_id` exists:
    - The odd `order_id` should be assigned the `item` originally associated with the subsequent even `order_id`.
    - The even `order_id` should be assigned the `item` originally associated with the preceding odd `order_id`.
3. **Special Condition:** If the `order_id` with the maximum value in the table is odd, this order should retain its original `item` and is not affected by the swapping logic (i.e., it does not try to swap with a non-existent subsequent order, nor does the preceding even order try to take its item if it's the absolute last).
4. Return the corrected pairs of `order_id` (as `corrected_order_id`) and their corresponding `item`.

**Expected Output:**

- **Columns:**
    
    
    | column_name | type |
    | --- | --- |
    | corrected_order_id | integer |
    | item | string |
- **Example Output (Corrected Data):**
    
    
    | corrected_order_id | item |
    | --- | --- |
    | 1 | Pizza |
    | 2 | Chow Mein |
    | 3 | Butter Chicken |
    | 4 | Pad Thai |
    | 5 | Burger |
    | 6 | Eggrolls |
    | 7 | Tandoori Chicken |

**Explanation (based on example data):**

- **Orders 1 & 2:**
    - Original: 1 -> Chow Mein, 2 -> Pizza
    - Corrected: 1 -> Pizza, 2 -> Chow Mein
- **Orders 3 & 4:**
    - Original: 3 -> Pad Thai, 4 -> Butter Chicken
    - Corrected: 3 -> Butter Chicken, 4 -> Pad Thai
- **Orders 5 & 6:**
    - Original: 5 -> Eggrolls, 6 -> Burger
    - Corrected: 5 -> Burger, 6 -> Eggrolls
- **Order 7:**
    - Original: 7 -> Tandoori Chicken
    - Order 7 is the last order and its `order_id` (7) is odd. Therefore, it remains unchanged.
    - Corrected: 7 -> Tandoori Chicken

*(Note: The dataset you are querying against may have different input & output - this is just an example!)*

---

---

### Deloitte Question

---

**Question:**

You are working for a large financial institution and need to analyze loan repayment data to assess credit risk. Your task is to write an SQL query that, for each loan, determines its repayment status by creating two specific flags: `fully_paid_flag` and `on_time_flag`.

The output should display the `loan_id`, `loan_amount`, `due_date` from the `loans` table, along with the two calculated flags.

**Flag Definitions:**

1. **`fully_paid_flag`**:
    - Set to `1` if the total amount paid for the loan is greater than or equal to the `loan_amount`, irrespective of when the payments were made.
    - Set to `0` otherwise.
2. **`on_time_flag`**:
    - Set to `1` if the loan was fully repaid (total `amount_paid` >= `loan_amount`) *and* the total amount paid on or before the loan's `due_date` was sufficient to cover the entire `loan_amount`.
    - Set to `0` otherwise. (This means if it's not fully paid, or if it's fully paid but not by the due date, this flag is 0).

**Input Data:**

1. **`loans` Table:**
    - Contains details about each loan issued.
    - **Columns:**
        
        
        | COLUMN_NAME | DATA_TYPE |
        | --- | --- |
        | loan_id | int |
        | customer_id | int |
        | loan_amount | int |
        | due_date | date |
    - **Example Input (Illustrative):**
        
        
        | loan_id | customer_id | loan_amount | due_date |
        | --- | --- | --- | --- |
        | 1 | 101 | 1000 | 2023-01-15 |
        | 2 | 102 | 500 | 2023-02-10 |
        | 3 | 103 | 2000 | 2023-03-01 |
        | 4 | 104 | 750 | 2023-01-20 |
2. **`payments` Table:**
    - Contains records of payments made towards loans.
    - **Columns:**
        
        
        | COLUMN_NAME | DATA_TYPE |
        | --- | --- |
        | payment_id | int |
        | loan_id | int |
        | amount_paid | int |
        | payment_date | date |
    - **Example Input (Illustrative):**
        
        
        | payment_id | loan_id | amount_paid | payment_date |
        | --- | --- | --- | --- |
        | 1001 | 1 | 500 | 2023-01-10 |
        | 1002 | 1 | 500 | 2023-01-14 |
        | 1003 | 2 | 200 | 2023-02-05 |
        | 1004 | 2 | 300 | 2023-02-15 |
        | 1005 | 3 | 1000 | 2023-02-20 |
        | 1006 | 4 | 750 | 2023-01-25 |

**Task:**

1. For each `loan_id` from the `loans` table:
a. Calculate the total `amount_paid` by summing payments from the `payments` table.
b. Calculate the total `amount_paid` specifically on or before the `due_date` of the loan.
2. Based on these calculations and the `loan_amount`:
a. Determine the `fully_paid_flag`.
b. Determine the `on_time_flag`.
3. Return `loan_id`, `loan_amount`, `due_date`, `fully_paid_flag`, and `on_time_flag`.

**Expected Output (based on illustrative example data):**

| loan_id | loan_amount | due_date | fully_paid_flag | on_time_flag |
| --- | --- | --- | --- | --- |
| 1 | 1000 | 2023-01-15 | 1 | 1 |
| 2 | 500 | 2023-02-10 | 1 | 0 |
| 3 | 2000 | 2023-03-01 | 0 | 0 |
| 4 | 750 | 2023-01-20 | 1 | 0 |

**Explanation (based on illustrative example):**

- **Loan 1 (ID 1000, Due 2023-01-15):**
    - Total paid: 500 (on 2023-01-10) + 500 (on 2023-01-14) = 1000.
    - `fully_paid_flag` = 1 (1000 >= 1000).
    - Total paid by 2023-01-15: 1000.
    - `on_time_flag` = 1 (1000 >= 1000 by due date).
- **Loan 2 (ID 500, Due 2023-02-10):**
    - Total paid: 200 (on 2023-02-05) + 300 (on 2023-02-15) = 500.
    - `fully_paid_flag` = 1 (500 >= 500).
    - Total paid by 2023-02-10: 200.
    - `on_time_flag` = 0 (200 < 500 by due date, even though eventually fully paid).
- **Loan 3 (ID 2000, Due 2023-03-01):**
    - Total paid: 1000 (on 2023-02-20).
    - `fully_paid_flag` = 0 (1000 < 2000).
    - Total paid by 2023-03-01: 1000.
    - `on_time_flag` = 0 (not fully paid).
- **Loan 4 (ID 750, Due 2023-01-20):**
    - Total paid: 750 (on 2023-01-25).
    - `fully_paid_flag` = 1 (750 >= 750).
    - Total paid by 2023-01-20: 0.
    - `on_time_flag` = 0 (0 < 750 by due date, even though eventually fully paid).

---

---

### FAANG Question

---

**Question:**

As part of an ongoing analysis of salary distribution within your company, your manager has requested a report identifying "high earners" in each department. A 'high earner' within a department is defined as an employee whose salary ranks among the top three distinct salaries within that department.

You are tasked with writing a SQL query to identify these high earners across all departments. The output should display the employee's `name`, their `department_name`, and their `salary`.

**Specific Requirements:**

- Utilize an appropriate ranking window function to handle duplicate salaries effectively when determining the top three salary tiers.
- The final results should be sorted by `department_name` in ascending order, then by `salary` in descending order. If multiple employees within the same department have the same salary, they should be further sorted by their `name` in alphabetical order.

**Input Data:**

1. **`employee` Table:**
    - Contains information about employees.
    - **Columns:**
        
        
        | column_name | type | description |
        | --- | --- | --- |
        | employee_id | integer | The unique ID of the employee. |
        | name | string | The name of the employee. |
        | salary | integer | The salary of the employee. |
        | department_id | integer | The department ID of the employee. |
        | manager_id | integer | The manager ID of the employee. |
    - **Example Input:**
        
        
        | employee_id | name | salary | department_id | manager_id |
        | --- | --- | --- | --- | --- |
        | 1 | Emma Thompson | 3800 | 1 | 6 |
        | 2 | Daniel Rodriguez | 2230 | 1 | 7 |
        | 3 | Olivia Smith | 2000 | 1 | 8 |
        | 4 | Noah Johnson | 6800 | 2 | 9 |
        | 5 | Sophia Martinez | 1750 | 1 | 11 |
        | 6 | Liam Brown | 13000 | 3 |  |
        | 7 | Ava Garcia | 12500 | 3 |  |
        | 8 | William Davis | 6800 | 2 |  |
        | 9 | Isabella Wilson | 11000 | 3 |  |
        | 10 | James Anderson | 4000 | 1 | 11 |
2. **`department` Table:**
    - Contains information about departments.
    - **Columns:**
        
        
        | column_name | type | description |
        | --- | --- | --- |
        | department_id | integer | The department ID. |
        | department_name | string | The name of the department. |
    - **Example Input:**
        
        
        | department_id | department_name |
        | --- | --- |
        | 1 | Data Analytics |
        | 2 | Data Science |

**Task:**

1. Join the `employee` table with the `department` table to get the `department_name` for each employee.
2. For each `department`, assign a rank to employees based on their `salary` in descending order. Use a ranking function (e.g., `DENSE_RANK()`) that assigns the same rank to employees with the same salary, ensuring that the next rank is consecutive. This will help identify the top three distinct salary tiers.
3. Filter the results to include only employees whose salary rank is less than or equal to 3 within their respective department.
4. Select the `department_name`, employee `name`, and `salary`.
5. Order the final output:
    - Primarily by `department_name` (ascending).
    - Secondarily by `salary` (descending).
    - Tertiarily by `name` (ascending, for ties in department and salary).

**Expected Output:**

- **Columns:**Column Namedepartment_namenamesalary
    
    ---
    
    ---
    
    ---
    
    ---
    
- **Example Output:**
    
    
    | department_name | name | salary |
    | --- | --- | --- |
    | Data Analytics | James Anderson | 4000 |
    | Data Analytics | Emma Thompson | 3800 |
    | Data Analytics | Daniel Rodriguez | 2230 |
    | Data Science | Noah Johnson | 6800 |
    | Data Science | William Davis | 6800 |

**Explanation (based on example data):**

- **Data Analytics Department:**
    - James Anderson ($4000) is the 1st highest salary.
    - Emma Thompson ($3800) is the 2nd highest salary.
    - Daniel Rodriguez ($2230) is the 3rd highest salary.
    - Olivia Smith ($2000) and Sophia Martinez ($1750) are not in the top 3 salary tiers.
- **Data Science Department:**
    - Noah Johnson ($6800) and William Davis ($6800) share the 1st highest salary. Both are included as they fall within the top three salary tiers (specifically, the 1st tier).
    - There are no other salaries in this department in the example, so no 2nd or 3rd distinct salary tier is shown.
- The output is sorted by `department_name`, then by `salary` (descending), and finally by `name` (ascending) for ties (e.g., Noah Johnson before William Davis).

*(Note: The dataset you are querying against may have different input & output - this is just an example! Department ID 3 from the `employee` table is not in the `department` example input, so its employees do not appear in the example output.)*

---

---