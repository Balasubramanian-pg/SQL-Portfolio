## A. High Level Sales Analysis

**1a. What was the total quantity sold for all products?**

* **Purpose:**  This query aims to find the overall number of products sold across all transactions. It gives a general sense of the total sales volume.
* **SQL Code:**

```sql
SELECT
	sum(qty) AS total_product_quantity
FROM balanced_tree.sales;
```

* `SELECT sum(qty)`: This selects the sum of the `qty` (quantity) column. The `sum()` function is an aggregate function that calculates the total of all values in the specified column.
* `AS total_product_quantity`: This renames the resulting sum column to `total_product_quantity` for better readability in the output.
* `FROM balanced_tree.sales`: This specifies that we are querying data from the `sales` table within the `balanced_tree` schema.

>[!Tip]
>**Results Interpretation:** The result `45216` means that a total of 45,216 products were sold across all transactions in the dataset.

**1b. What was the total quantity sold for EACH product?**

* **Purpose:**  This query goes a step further than 1a by breaking down the total quantity sold by individual product names. This helps identify which products are selling in higher volumes.
* **SQL Code:**

```sql
SELECT
	pd.product_name,
	sum(s.qty) AS total_quantity
FROM
	balanced_tree.sales AS s
JOIN
	balanced_tree.product_details AS pd ON pd.product_id = s.prod_id
GROUP BY
	pd.product_name
ORDER BY
	total_quantity DESC;
```

* `SELECT pd.product_name, sum(s.qty) AS total_quantity`:  We select the `product_name` from the `product_details` table and calculate the sum of `qty` from the `sales` table, aliasing it as `total_quantity`.
* `FROM balanced_tree.sales AS s JOIN balanced_tree.product_details AS pd ON pd.product_id = s.prod_id`:
* `FROM balanced_tree.sales AS s`: We start by selecting from the `sales` table and give it an alias `s` for brevity.
* `JOIN balanced_tree.product_details AS pd ON pd.product_id = s.prod_id`: We perform a `JOIN` operation with the `product_details` table (aliased as `pd`). The `ON` clause specifies the join condition: we link rows where `pd.product_id` matches `s.prod_id`. This is how we connect sales data with product information.
* `GROUP BY pd.product_name`: This is crucial. We use `GROUP BY` to group the results by `product_name`. This means the `sum(s.qty)` will be calculated for each distinct `product_name`.
* `ORDER BY total_quantity DESC`:  Finally, we `ORDER BY` the `total_quantity` in descending order (`DESC`) so that the products with the highest total quantities sold appear at the top.

>[!Tip]
>**Results Interpretation:** The results show a list of product names along with their respective `total_quantity` sold, ordered from highest to lowest quantity. For example, "Grey Fashion Jacket - Womens" was the top-selling product in terms of quantity, with 3876 units sold.

**2a. What is the total generated revenue for all products before discounts?**

* **Purpose:**  This query calculates the total revenue generated from all sales *before* any discounts are applied. This represents the gross revenue.
* **SQL Code:**

```sql
SELECT
	sum(price * qty) AS gross_revenue
FROM balanced_tree.sales;
```

* `SELECT sum(price * qty) AS gross_revenue`: We calculate the revenue for each sale by multiplying `price` and `qty`. Then, we use `sum()` to add up all these individual revenues to get the total gross revenue. We alias this sum as `gross_revenue`.
* `FROM balanced_tree.sales`: We are querying the `sales` table.

>[!Note]
>**Results Interpretation:** The result `1289453` indicates that the total gross revenue generated from all sales, before discounts, is $1,289,453.

**2b. What is the total generated revenue for EACH product before discounts?**

* **Purpose:**  Similar to 1b, this query breaks down the gross revenue by individual product names, showing which products are contributing the most to the total revenue before discounts.
* **SQL Code:**

```sql
SELECT
	pd.product_name,
	sum(s.price * s.qty) AS total_gross_revenue
FROM
	balanced_tree.sales AS s
JOIN
	balanced_tree.product_details AS pd ON pd.product_id = s.prod_id
GROUP BY
	pd.product_name
ORDER BY
	total_gross_revenue desc;
```

* This query structure is very similar to 1b. The key difference is in the `SELECT` clause: `sum(s.price * s.qty) AS total_gross_revenue`. Instead of just summing the `qty`, we are now summing the product of `price` and `qty` to calculate revenue for each sale, and then aggregating these revenues per product.
* The `FROM`, `JOIN`, `GROUP BY`, and `ORDER BY` clauses function exactly as explained in 1b.

>[!Note]
>**Results Interpretation:** The output lists product names and their corresponding `total_gross_revenue`, ordered from highest to lowest revenue. "Blue Polo Shirt - Mens" generated the highest gross revenue at $217,683.

**3a. What was the total discount amount for all products?**

* **Purpose:** This query calculates the total amount of discounts given across all sales. This helps understand the total value of discounts offered.
* **SQL Code:**

```sql
SELECT
	round(sum((price * qty) * (discount::NUMERIC / 100)), 2) AS total_discounts
FROM balanced_tree.sales;
```

    * `SELECT round(sum((price * qty) * (discount::NUMERIC / 100)), 2) AS total_discounts`:
        * `(price * qty)`: Calculates the gross revenue for each sale.
        * `(discount::NUMERIC / 100)`: Converts the `discount` (which might be stored as text or integer) to a numeric type, divides it by 100 to get the discount rate as a decimal (e.g., 10% becomes 0.10). `::NUMERIC` is a type casting operator.
        * `(price * qty) * (discount::NUMERIC / 100)`: Calculates the discount amount for each sale by multiplying the gross revenue by the discount rate.
        * `sum(...)`: Sums up all the individual discount amounts to get the total discount.
        * `round(..., 2)`: Rounds the final total discount value to 2 decimal places for currency representation.
        * `AS total_discounts`: Renames the resulting sum column.
    * `FROM balanced_tree.sales`:  Queries the `sales` table.

* **Results Interpretation:** The result `156229.14` indicates that the total discount amount given across all sales is $156,229.14.

**3b. What is the total discount for EACH product?**

* **Purpose:** This query breaks down the total discount amount by individual product names. It also includes the total item revenue for context. This helps see which products have the highest discount amounts applied.
* **SQL Code:**

```sql
SELECT
	pd.product_name,
	sum(s.price * s.qty) AS total_item_revenue,
	round(sum((s.price * s.qty) * (s.discount::NUMERIC / 100)), 2) AS total_item_discounts
FROM
	balanced_tree.sales AS s
JOIN
	balanced_tree.product_details AS pd ON pd.product_id = s.prod_id
GROUP BY
	pd.product_name
ORDER BY
	total_item_revenue desc;
```

* This query is similar to 2b in structure, but now we are selecting two aggregated values:
* `sum(s.price * s.qty) AS total_item_revenue`:  Calculates the total revenue per product (as in 2b).
* `round(sum((s.price * s.qty) * (s.discount::NUMERIC / 100)), 2) AS total_item_discounts`: Calculates the total discount per product, using the same discount calculation logic as in 3a, but now aggregated per product due to the `GROUP BY` clause.
* `FROM`, `JOIN`, `GROUP BY`, and `ORDER BY` clauses work as previously explained in 1b and 2b.

>[!Tip]
>**Results Interpretation:** The results list product names, their `total_item_revenue`, and `total_item_discounts`, ordered by `total_item_revenue`.  For example, for "Blue Polo Shirt - Mens," the total revenue was $217,683, and the total discount applied was $26,819.07. This helps understand the discount impact on revenue for each product.
