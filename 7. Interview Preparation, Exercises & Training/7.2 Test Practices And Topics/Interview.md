To solve the problem of identifying the top 10 items bought by customers during their first purchase in 2021 within the US, we can follow these steps:

1. **Filter Relevant Orders**: Select orders from the US (marketplace_id = 1) placed in 2021 with positive units sold.
2. **Identify First Purchases**: For each customer, determine their first order in 2021 using a window function.
3. **Aggregate Results**: Count how many times each item was part of these first purchases and return the top 10 items.

### SQL Query
```sql
WITH first_orders_2021 AS (
    SELECT 
        customer_id,
        item,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id 
            ORDER BY order_date
        ) AS row_num
    FROM ORDERS
    WHERE marketplace_id = 1
        AND order_date >= '2021-01-01' 
        AND order_date < '2022-01-01'
        AND units > 0
)
SELECT 
    item,
    COUNT(*) AS number_of_times_sold_in_first_order
FROM first_orders_2021
WHERE row_num = 1
GROUP BY item
ORDER BY number_of_times_sold_in_first_order DESC
LIMIT 10;
```

### Explanation
1. **CTE `first_orders_2021`**:
   - Filters orders to include only US sales from 2021 with units sold greater than 0.
   - Uses `ROW_NUMBER()` to assign a row number to each customer's orders, ordered by date. The first order (row_num = 1) is the earliest purchase in 2021.

2. **Main Query**:
   - Selects items from the first orders where `row_num = 1`.
   - Groups by item and counts occurrences to determine how many times each item was sold as a first purchase.
   - Orders the results by the count in descending order and limits to the top 10 items.

This approach efficiently identifies the required items and their counts, ensuring accurate results based on the problem's criteria.