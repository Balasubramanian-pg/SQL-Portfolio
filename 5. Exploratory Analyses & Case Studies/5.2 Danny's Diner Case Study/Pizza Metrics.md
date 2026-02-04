**Step-by-Step Explanation and SQL Query Corrections:**

### A. Pizza Metrics

1. **How many pizzas were ordered?**
   - **Issue:** Using `COUNT(DISTINCT order_id)` counts orders, not pizzas.
   - **Fix:** Count all rows as each represents a pizza.
   ```sql
   SELECT COUNT(*) AS no_of_pizzas_ordered
   FROM #customer_orders;
   ```

2. **How many unique customer orders were made?**
   - **Clarification:** Assuming "unique orders per customer."
   ```sql
   SELECT customer_id, COUNT(DISTINCT order_id) AS unique_orders
   FROM #customer_orders
   GROUP BY customer_id;
   ```

3. **Successful orders per runner:**
   - **Issue:** Missing `GROUP BY runner_id`.
   ```sql
   SELECT runner_id, COUNT(order_id) AS successful_orders
   FROM #runner_orders
   WHERE distance != 0
   GROUP BY runner_id;
   ```

4. **Pizza types delivered:**
   - **Enhancement:** Include pizza name.
   ```sql
   SELECT p.pizza_name, COUNT(c.pizza_id) AS delivered_count
   FROM #customer_orders c
   JOIN #runner_orders r ON c.order_id = r.order_id
   JOIN pizza_names p ON c.pizza_id = p.pizza_id
   WHERE r.distance != 0
   GROUP BY p.pizza_name;
   ```

5. **Vegetarian/Meatlovers per customer:**
   - **Correct as is.**

6. **Max pizzas in a single order:**
   - **Correct as is.**

7. **Pizzas with changes vs. no changes:**
   - **Fix:** Adjust conditions based on data structure (assuming ' ' for none):
   ```sql
   SELECT customer_id,
       SUM(CASE WHEN exclusions <> ' ' OR extras <> ' ' THEN 1 ELSE 0 END) AS with_changes,
       SUM(CASE WHEN exclusions = ' ' AND extras = ' ' THEN 1 ELSE 0 END) AS no_changes
   FROM #customer_orders c
   JOIN #runner_orders r ON c.order_id = r.order_id
   WHERE r.distance != 0
   GROUP BY customer_id;
   ```

8. **Pizzas with both exclusions and extras:**
   - **Fix:** Simplify query.
   ```sql
   SELECT COUNT(*) AS pizzas_with_both
   FROM #customer_orders c
   JOIN #runner_orders r ON c.order_id = r.order_id
   WHERE r.distance != 0
     AND c.exclusions <> ' ' 
     AND c.extras <> ' ';
   ```

9. **Pizzas ordered per hour:**
   - **Correct as is.**

10. **Orders per day of the week:**
    - **Fix:** Use `WEEKDAY` to get day name.
    ```sql
    SELECT DATENAME(WEEKDAY, order_time) AS day_of_week, 
           COUNT(*) AS total_pizzas_ordered
    FROM #customer_orders
    GROUP BY DATENAME(WEEKDAY, order_time);
    ```

**Summary of Corrections:**
- **Q1, Q3, Q7, Q8, Q10** required logic adjustments.
- **Q4, Q7, Q10** improved clarity or fixed date handling.
- Assumed `#customer_orders` uses ' ' for empty exclusions/extras. Adjust if using `NULL` (use `IS NULL` or `IS NOT NULL`).