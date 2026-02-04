## Danny's Diner Case Study

This document explores customer purchase data at Danny's Diner using MS SQL Server. The data includes three tables:

* **sales**: Stores information about customer orders, including customer ID, order date, and product ID.
* **menu**: Lists menu items with their corresponding ID, name, and price.
* **members**: Tracks customer membership details, including customer ID and join date.

The document is divided into three main sections:

**1. Data Setup:**

* This section outlines the creation of the three tables (`sales`, `menu`, and `members`) with sample data.

**2. Case Study Questions:**

This section presents ten SQL queries analyzing customer behavior and purchase patterns:

1. Total amount spent per customer
2. Number of visits per customer
3. First item purchased by each customer
4. Most purchased menu item
5. Most popular item for each customer
6. First purchase after becoming a member
7. Last purchase before becoming a member
8. Total items and amount spent before membership
9. Points earned based on spending (with bonus points for sushi)
10. Points earned in the first week of membership (double points, excluding sushi)

**3. Bonus Questions:**

This section provides two additional queries:

* **Join All The Things:** Combines data from all tables, including customer ID, order date, product details, price, and membership status.
* **Rank All The Things:** Similar to the previous query, but additionally assigns a ranking number (within customer and membership status groups) based on the order date.

This document serves as a reference for understanding customer behavior at Danny's Diner through the provided sample data and SQL queries.
