-- Clean up existing tables if they exist
DROP TABLE IF EXISTS ORDERS;
DROP TABLE IF EXISTS CATALOG;

-- Create ORDERS table
CREATE TABLE ORDERS (
    order_id INTEGER PRIMARY KEY,
    item VARCHAR(255),
    units INTEGER,
    order_date DATE
);

-- Create CATALOG table
CREATE TABLE CATALOG (
    marketplace_id INTEGER,
    item VARCHAR(255),
    product_group VARCHAR(20),
    has_bullet_points CHAR(1),
    has_customer_reviews CHAR(1),
    PRIMARY KEY (item, marketplace_id)
);

-- Insert sample data into ORDERS
INSERT INTO ORDERS (order_id, item, units, order_date) VALUES
(9021, 'A22', 1, '2021-02-01'),
(8763, 'T14', 1, '2021-01-14'),
(4321, 'C13', 2, '2020-11-17'),
(6757, 'A22', 3, '2020-12-07'),
(3008, 'H59', 1, '2021-01-08'),
(2190, 'Q30', 0, '2021-01-29'),
(3741, 'P12', 1, '2021-01-03');

-- Insert sample data into CATALOG
INSERT INTO CATALOG (marketplace_id, item, product_group, has_bullet_points, has_customer_reviews) VALUES
(1, 'A22', 'books', 'Y', 'Y'),
(1, 'T14', 'electronics', 'Y', 'N'),
(3, 'B20', 'books', NULL, 'N'),
(1, 'C13', 'games', NULL, 'N'),
(1, 'Q72', 'games', 'N', 'Y'),
(4, 'A22', 'electronics', 'Y', 'Y'),
(1, 'T87', 'music', 'N', 'Y'),
(3, 'A22', 'books', 'Y', 'Y'),
(1, 'H59', 'books', NULL, 'N'),
(1, 'Q30', 'games', 'Y', 'Y'),
(1, 'P12', 'toys', NULL, 'Y');

-- Query to find product groups with no sales in the US
SELECT DISTINCT c.product_group
FROM CATALOG c
WHERE c.marketplace_id = 1
  AND c.product_group NOT IN (
      SELECT DISTINCT c2.product_group
      FROM ORDERS o
      JOIN CATALOG c2 ON o.item = c2.item
      WHERE c2.marketplace_id = 1
  )
ORDER BY c.product_group;


SELECT o.item, COUNT(*) AS number_of_times_sold_in_first_order
FROM ORDERS o
WHERE o.marketplace_id = 1  -- US marketplace
    AND EXTRACT(YEAR FROM o.order_date) = 2021 -- Orders in 2021
    AND (o.customer_id, o.order_date) IN (  -- Check if it's a customer's first order in 2021
        SELECT customer_id, MIN(order_date)
        FROM ORDERS
        WHERE marketplace_id = 1 AND EXTRACT(YEAR FROM order_date) = 2021
        GROUP BY customer_id
    )
GROUP BY o.item
ORDER BY number_of_times_sold_in_first_order DESC
LIMIT 10;