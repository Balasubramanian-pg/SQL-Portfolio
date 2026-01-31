# PostgreSQL Views Database Setup
# Complete schema with tables, constraints, and sample data

## **1. Database Creation**
```sql
-- Create a dedicated database for our examples
CREATE DATABASE ecommerce_demo
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.utf8'
    LC_CTYPE = 'en_US.utf8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

-- Connect to the database
\c ecommerce_demo
```

## **2. Schema Creation**
```sql
-- Create schemas for better organization
CREATE SCHEMA public;  -- Default schema
CREATE SCHEMA reporting;
CREATE SCHEMA staging;
```

## **3. Core Tables Setup**

### **Customers Table**
```sql
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address_line1 VARCHAR(100),
    address_line2 VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50) DEFAULT 'USA',
    join_date DATE NOT NULL DEFAULT CURRENT_DATE,
    is_active BOOLEAN DEFAULT TRUE,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add index for frequently queried columns
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_active ON customers(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_customers_join_date ON customers(join_date);

-- Add trigger for last_updated
CREATE OR REPLACE FUNCTION update_customer_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_updated = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_customer
BEFORE UPDATE ON customers
FOR EACH ROW
EXECUTE FUNCTION update_customer_timestamp();
```
<img width="1919" height="1138" alt="image" src="https://github.com/user-attachments/assets/7f74002e-3c2e-4f60-ae31-728f8b77a057" />

### **Products Table**
```sql
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    description TEXT,
    category_id INTEGER NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    cost DECIMAL(10, 2),
    supplier_id INTEGER,
    sku VARCHAR(50) UNIQUE,
    upc VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_price_positive CHECK (price > 0)
);

CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_active ON products(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_products_price ON products(price);
```
<img width="1919" height="1137" alt="image" src="https://github.com/user-attachments/assets/a787e268-a2a0-47d3-9e91-5e00672e5e70" />

### **Categories Table**
```sql
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL,
    parent_category_id INTEGER REFERENCES categories(category_id),
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Self-referencing index for hierarchy
CREATE INDEX idx_categories_parent ON categories(parent_category_id);
```
<img width="1919" height="1137" alt="image" src="https://github.com/user-attachments/assets/737cab28-ae49-474a-a092-43278410e196" />

### **Suppliers Table**
```sql
CREATE TABLE suppliers (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    contact_name VARCHAR(100),
    contact_email VARCHAR(100),
    contact_phone VARCHAR(20),
    address TEXT,
    lead_time_days INTEGER,
    reliability_score DECIMAL(3,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```
<img width="1919" height="1139" alt="image" src="https://github.com/user-attachments/assets/b66e4a0e-0c36-4586-85a8-1ee44ba43d69" />

### **Orders Table**
```sql
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Pending' CHECK (
        status IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled', 'Returned')
    ),
    amount DECIMAL(10, 2) NOT NULL,
    tax DECIMAL(10, 2),
    shipping_cost DECIMAL(10, 2),
    shipping_address TEXT,
    payment_method VARCHAR(50),
    tracking_number VARCHAR(100),
    notes TEXT,
    CONSTRAINT fk_order_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id) ON DELETE RESTRICT
);

CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_amount ON orders(amount);
```
<img width="1919" height="1138" alt="image" src="https://github.com/user-attachments/assets/5a6fe4c8-7fdc-4811-95a2-a8f0f77e5bf1" />

### **Order Items Table**
```sql
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL,
    discount DECIMAL(10, 2) DEFAULT 0.00,
    tax_rate DECIMAL(5, 2) DEFAULT 0.00,
    CONSTRAINT fk_order_item_order FOREIGN KEY (order_id)
        REFERENCES orders(order_id) ON DELETE CASCADE,
    CONSTRAINT fk_order_item_product FOREIGN KEY (product_id)
        REFERENCES products(product_id) ON DELETE RESTRICT
);

CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
```
<img width="1919" height="1138" alt="image" src="https://github.com/user-attachments/assets/3347ca27-6e22-49d9-82c4-edc007912d68" />

### **Inventory Table**
```sql
CREATE TABLE inventory (
    inventory_id SERIAL PRIMARY KEY,
    product_id INTEGER UNIQUE NOT NULL,
    quantity_in_stock INTEGER NOT NULL DEFAULT 0,
    reorder_threshold INTEGER DEFAULT 10,
    last_restock_date DATE,
    location VARCHAR(50),
    CONSTRAINT fk_inventory_product FOREIGN KEY (product_id)
        REFERENCES products(product_id) ON DELETE CASCADE,
    CONSTRAINT chk_quantity_non_negative CHECK (quantity_in_stock >= 0)
);

CREATE INDEX idx_inventory_quantity ON inventory(quantity_in_stock)
    WHERE quantity_in_stock <= reorder_threshold;
```
<img width="1919" height="1140" alt="image" src="https://github.com/user-attachments/assets/e569ffc1-5f04-4318-8956-b193081dcbbd" />

### **Reviews Table**
```sql
CREATE TABLE reviews (
    review_id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL,
    customer_id INTEGER,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_approved BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_review_product FOREIGN KEY (product_id)
        REFERENCES products(product_id) ON DELETE CASCADE,
    CONSTRAINT fk_review_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id) ON DELETE SET NULL
);

CREATE INDEX idx_reviews_product ON reviews(product_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);
CREATE INDEX idx_reviews_date ON reviews(review_date);
```
<img width="1919" height="1138" alt="image" src="https://github.com/user-attachments/assets/312c8bff-731c-4569-8b9a-a8a92b51c77b" />

## **4. Sample Data Insertion**

### **Insert Categories**
```sql
INSERT INTO categories (category_name, parent_category_id, description) VALUES
('Electronics', NULL, 'Electronic devices and accessories'),
('Computers', (SELECT category_id FROM categories WHERE category_name = 'Electronics'), 'Computers and peripherals'),
('Laptops', (SELECT category_id FROM categories WHERE category_name = 'Computers'), 'Portable computers'),
('Desktops', (SELECT category_id FROM categories WHERE category_name = 'Computers'), 'Desktop computers'),
('Smartphones', (SELECT category_id FROM categories WHERE category_name = 'Electronics'), 'Mobile phones'),
('Home & Kitchen', NULL, 'Home appliances and kitchenware'),
('Furniture', NULL, 'Home and office furniture'),
('Clothing', NULL, 'Apparel and accessories'),
('Men', (SELECT category_id FROM categories WHERE category_name = 'Clothing'), 'Men''s clothing'),
('Women', (SELECT category_id FROM categories WHERE category_name = 'Clothing'), 'Women''s clothing');
```
<img width="1919" height="1139" alt="image" src="https://github.com/user-attachments/assets/3cddacc6-590a-425c-8b5b-60f7a91551fe" />

### **Insert Suppliers**
```sql
INSERT INTO suppliers (supplier_name, contact_name, contact_email, contact_phone, address, lead_time_days, reliability_score) VALUES
('TechSupplies Inc.', 'John Smith', 'john@techsupplies.com', '555-123-4567', '123 Tech Park, Silicon Valley, CA', 3, 4.8),
('HomeGoods Co.', 'Sarah Johnson', 'sarah@homegoods.com', '555-234-5678', '456 Main St, Chicago, IL', 5, 4.5),
('FashionDistributors', 'Michael Brown', 'michael@fashiondist.com', '555-345-6789', '789 Fashion Ave, New York, NY', 7, 4.2),
('ElectroParts', 'David Wilson', 'david@electroparts.com', '555-456-7890', '321 Industrial Rd, Detroit, MI', 2, 4.9),
('KitchenPro', 'Lisa Chen', 'lisa@kitchenpro.com', '555-567-8901', '654 Culinary Blvd, Portland, OR', 4, 4.7);
```
<img width="1919" height="1142" alt="image" src="https://github.com/user-attachments/assets/aec68c73-8305-4d97-b4e8-5e01ed876d0a" />

### **Insert Products**
```sql
-- Get category IDs first
SELECT category_id, category_name FROM categories;

-- Insert products
INSERT INTO products (product_name, description, category_id, price, cost, supplier_id, sku, upc, is_active) VALUES
('Premium Laptop', '15" laptop with 16GB RAM, 512GB SSD', (SELECT category_id FROM categories WHERE category_name = 'Laptops'), 999.99, 750.00, (SELECT supplier_id FROM suppliers WHERE supplier_name = 'TechSupplies Inc.'), 'LP-1001', '890123456789', TRUE),
('Smartphone X', 'Latest smartphone with 128GB storage', (SELECT category_id FROM categories WHERE category_name = 'Smartphones'), 799.99, 600.00, (SELECT supplier_id FROM suppliers WHERE supplier_name = 'TechSupplies Inc.'), 'SP-2001', '890123456790', TRUE),
('Desk Chair', 'Ergonomic office chair', (SELECT category_id FROM categories WHERE category_name = 'Furniture'), 199.99, 120.00, (SELECT supplier_id FROM suppliers WHERE supplier_name = 'HomeGoods Co.'), 'FC-3001', '890123456791', TRUE),
('Coffee Maker', 'Programmable 12-cup coffee maker', (SELECT category_id FROM categories WHERE category_name = 'Home & Kitchen'), 89.99, 50.00, (SELECT supplier_id FROM suppliers WHERE supplier_name = 'HomeGoods Co.'), 'CM-4001', '890123456792', TRUE),
('Men''s T-Shirt', 'Cotton crew neck t-shirt', (SELECT category_id FROM categories WHERE category_name = 'Men'), 19.99, 8.00, (SELECT supplier_id FROM suppliers WHERE supplier_name = 'FashionDistributors'), 'MT-5001', '890123456793', TRUE),
('Wireless Headphones', 'Noise-cancelling wireless headphones', (SELECT category_id FROM categories WHERE category_name = 'Electronics'), 149.99, 90.00, (SELECT supplier_id FROM suppliers WHERE supplier_name = 'ElectroParts'), 'WH-6001', '890123456794', TRUE),
('Blender', 'High-speed blender with 64oz jar', (SELECT category_id FROM categories WHERE category_name = 'Home & Kitchen'), 79.99, 45.00, (SELECT supplier_id FROM suppliers WHERE supplier_name = 'KitchenPro'), 'BL-7001', '890123456795', TRUE),
('Women''s Dress', 'Elegant evening dress', (SELECT category_id FROM categories WHERE category_name = 'Women'), 89.99, 40.00, (SELECT supplier_id FROM suppliers WHERE supplier_name = 'FashionDistributors'), 'WD-8001', '890123456796', TRUE),
('Gaming Desktop', 'High-performance gaming PC', (SELECT category_id FROM categories WHERE category_name = 'Desktops'), 1499.99, 1100.00, (SELECT supplier_id FROM suppliers WHERE supplier_name = 'TechSupplies Inc.'), 'GD-9001', '890123456797', TRUE),
('Standing Desk', 'Adjustable height standing desk', (SELECT category_id FROM categories WHERE category_name = 'Furniture'), 349.99, 220.00, (SELECT supplier_id FROM suppliers WHERE supplier_name = 'HomeGoods Co.'), 'SD-1001', '890123456798', TRUE);
```
<img width="1919" height="1138" alt="image" src="https://github.com/user-attachments/assets/0fd83d05-113d-4652-a1fd-8ccb95163bfc" />

### **Update Products with Inventory**
```sql
-- Set initial inventory for products
INSERT INTO inventory (product_id, quantity_in_stock, reorder_threshold, last_restock_date, location) VALUES
((SELECT product_id FROM products WHERE sku = 'LP-1001'), 50, 10, CURRENT_DATE - INTERVAL '7 days', 'Warehouse A'),
((SELECT product_id FROM products WHERE sku = 'SP-2001'), 30, 5, CURRENT_DATE - INTERVAL '3 days', 'Warehouse B'),
((SELECT product_id FROM products WHERE sku = 'FC-3001'), 25, 5, CURRENT_DATE - INTERVAL '14 days', 'Warehouse C'),
((SELECT product_id FROM products WHERE sku = 'CM-4001'), 40, 8, CURRENT_DATE - INTERVAL '5 days', 'Warehouse A'),
((SELECT product_id FROM products WHERE sku = 'MT-5001'), 100, 20, CURRENT_DATE - INTERVAL '2 days', 'Warehouse B'),
((SELECT product_id FROM products WHERE sku = 'WH-6001'), 20, 5, CURRENT_DATE - INTERVAL '10 days', 'Warehouse C'),
((SELECT product_id FROM products WHERE sku = 'BL-7001'), 15, 3, CURRENT_DATE - INTERVAL '8 days', 'Warehouse A'),
((SELECT product_id FROM products WHERE sku = 'WD-8001'), 35, 7, CURRENT_DATE - INTERVAL '4 days', 'Warehouse B'),
((SELECT product_id FROM products WHERE sku = 'GD-9001'), 8, 2, CURRENT_DATE - INTERVAL '15 days', 'Warehouse C'),
((SELECT product_id FROM products WHERE sku = 'SD-1001'), 12, 3, CURRENT_DATE - INTERVAL '6 days', 'Warehouse A');
```
<img width="1919" height="1140" alt="image" src="https://github.com/user-attachments/assets/796a5634-32af-4696-b9d6-3d7e67b7a5fa" />

### **Insert Customers**
```sql
INSERT INTO customers (customer_name, email, phone, address_line1, address_line2, city, state, postal_code, country, join_date) VALUES
('John Doe', 'john.doe@example.com', '555-111-2222', '123 Main St', 'Apt 4B', 'New York', 'NY', '10001', 'USA', CURRENT_DATE - INTERVAL '2 years'),
('Jane Smith', 'jane.smith@example.com', '555-222-3333', '456 Oak Ave', '', 'Los Angeles', 'CA', '90001', 'USA', CURRENT_DATE - INTERVAL '1 year 6 months'),
('Robert Johnson', 'robert.j@example.com', '555-333-4444', '789 Pine Rd', '', 'Chicago', 'IL', '60601', 'USA', CURRENT_DATE - INTERVAL '3 years'),
('Emily Davis', 'emily.d@example.com', '555-444-5555', '321 Elm St', 'Suite 100', 'Houston', 'TX', '77001', 'USA', CURRENT_DATE - INTERVAL '1 year'),
('Michael Brown', 'michael.b@example.com', '555-555-6666', '654 Maple Dr', '', 'Phoenix', 'AZ', '85001', 'USA', CURRENT_DATE - INTERVAL '2 years 3 months'),
('Sarah Wilson', 'sarah.w@example.com', '555-666-7777', '987 Cedar Ln', 'Unit 20', 'Philadelphia', 'PA', '19101', 'USA', CURRENT_DATE - INTERVAL '8 months'),
('David Taylor', 'david.t@example.com', '555-777-8888', '135 Birch Blvd', '', 'San Antonio', 'TX', '78201', 'USA', CURRENT_DATE - INTERVAL '1 year 2 months'),
('Jessica Anderson', 'jessica.a@example.com', '555-888-9999', '246 Spruce St', 'Apt 3C', 'San Diego', 'CA', '92101', 'USA', CURRENT_DATE - INTERVAL '4 years'),
('Thomas Martinez', 'thomas.m@example.com', '555-999-0000', '369 Willow Way', '', 'Dallas', 'TX', '75201', 'USA', CURRENT_DATE - INTERVAL '1 year 9 months'),
('Lisa Robinson', 'lisa.r@example.com', '555-000-1111', '753 Redwood Cir', '', 'San Jose', 'CA', '95101', 'USA', CURRENT_DATE - INTERVAL '2 years 6 months');
```

### **Insert Orders**
```sql
-- Helper function to generate random dates within a range
CREATE OR REPLACE FUNCTION random_date(between DATE, AND DATE)
RETURNS DATE AS $$
SELECT between + (AND - between) * random()::DATE;
$$ LANGUAGE SQL;

-- Insert orders for customers
INSERT INTO orders (customer_id, order_date, status, amount, tax, shipping_cost, shipping_address, payment_method) VALUES
-- John Doe's orders
((SELECT customer_id FROM customers WHERE email = 'john.doe@example.com'), random_date('2023-01-01', '2023-12-31'), 'Delivered', 999.99, 79.99, 15.00, '123 Main St, New York, NY 10001', 'Credit Card'),
((SELECT customer_id FROM customers WHERE email = 'john.doe@example.com'), random_date('2023-01-01', '2023-12-31'), 'Delivered', 149.99, 11.99, 10.00, '123 Main St, New York, NY 10001', 'PayPal'),
((SELECT customer_id FROM customers WHERE email = 'john.doe@example.com'), random_date('2023-01-01', '2023-12-31'), 'Delivered', 89.99, 7.19, 8.00, '123 Main St, New York, NY 10001', 'Credit Card'),

-- Jane Smith's orders
((SELECT customer_id FROM customers WHERE email = 'jane.smith@example.com'), random_date('2023-01-01', '2023-12-31'), 'Delivered', 199.99, 15.99, 12.00, '456 Oak Ave, Los Angeles, CA 90001', 'Credit Card'),
((SELECT customer_id FROM customers WHERE email = 'jane.smith@example.com'), random_date('2023-01-01', '2023-12-31'), 'Shipped', 349.99, 27.99, 20.00, '456 Oak Ave, Los Angeles, CA 90001', 'Credit Card'),
((SELECT customer_id FROM customers WHERE email = 'jane.smith@example.com'), random_date('2023-01-01', '2023-12-31'), 'Delivered', 79.99, 6.39, 7.00, '456 Oak Ave, Los Angeles, CA 90001', 'Debit Card'),

-- Robert Johnson's orders
((SELECT customer_id FROM customers WHERE email = 'robert.j@example.com'), random_date('2023-01-01', '2023-12-31'), 'Delivered', 1499.99, 119.99, 30.00, '789 Pine Rd, Chicago, IL 60601', 'Credit Card'),
((SELECT customer_id FROM customers WHERE email = 'robert.j@example.com'), random_date('2023-01-01', '2023-12-31'), 'Delivered', 19.99, 1.59, 5.00, '789 Pine Rd, Chicago, IL 60601', 'PayPal'),

-- Emily Davis's orders
((SELECT customer_id FROM customers WHERE email = 'emily.d@example.com'), random_date('2023-01-01', '2023-12-31'), 'Delivered', 79.99, 6.39, 7.00, '321 Elm St, Houston, TX 77001', 'Credit Card'),
((SELECT customer_id FROM customers WHERE email = 'emily.d@example.com'), random_date('2023-01-01', '2023-12-31'), 'Processing', 149.99, 11.99, 10.00, '321 Elm St, Houston, TX 77001', 'Credit Card'),

-- Michael Brown's orders
((SELECT customer_id FROM customers WHERE email = 'michael.b@example.com'), random_date('2023-01-01', '2023-12-31'), 'Delivered', 89.99, 7.19, 8.00, '654 Maple Dr, Phoenix, AZ 85001', 'Debit Card'),
((SELECT customer_id FROM customers WHERE email = 'michael.b@example.com'), random_date('2023-01-01', '2023-12-31'), 'Delivered', 349.99, 27.99, 20.00, '654 Maple Dr, Phoenix, AZ 85001', 'Credit Card'),
((SELECT customer_id FROM customers WHERE email = 'michael.b@example.com'), random_date('2023-01-01', '2023-12-31'), 'Cancelled', 19.99, 1.59, 5.00, '654 Maple Dr, Phoenix, AZ 85001', 'PayPal');
```

### **Insert Order Items**
```sql
-- Helper function to get random product
CREATE OR REPLACE FUNCTION get_random_product()
RETURNS INTEGER AS $$
SELECT product_id FROM products
ORDER BY random() LIMIT 1;
$$ LANGUAGE SQL;

-- Insert order items for each order
-- First get all order IDs
WITH order_ids AS (
    SELECT order_id FROM orders
)
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount)
SELECT
    o.order_id,
    (SELECT product_id FROM products ORDER BY random() LIMIT 1),
    FLOOR(random() * 3 + 1) AS quantity,  -- 1-3 items
    (SELECT price FROM products WHERE product_id = (SELECT product_id FROM products ORDER BY random() LIMIT 1)),
    (random() * 5)::DECIMAL(10,2)  -- Random discount up to $5
FROM
    order_ids o
-- Join with products to get actual prices
ON CONFLICT DO NOTHING;

-- Update with correct prices based on product_id
UPDATE order_items oi
SET unit_price = p.price
FROM products p
WHERE oi.product_id = p.product_id;

-- Update order amounts based on order items
UPDATE orders o
SET amount = (
    SELECT COALESCE(SUM(oi.quantity * (oi.unit_price - oi.discount)), 0)
    FROM order_items oi
    WHERE oi.order_id = o.order_id
),
tax = (amount * 0.08)::DECIMAL(10,2),  -- Assuming 8% tax
shipping_cost = CASE
    WHEN amount > 500 THEN 0
    WHEN amount > 200 THEN 10
    WHEN amount > 100 THEN 15
    ELSE 20
END
WHERE order_id IN (SELECT order_id FROM orders);
```
<img width="1919" height="1137" alt="image" src="https://github.com/user-attachments/assets/d18f3998-f0a8-4b3b-8bdd-87a326f37620" />

### **Insert Reviews**
```sql
-- Insert product reviews
INSERT INTO reviews (product_id, customer_id, rating, review_text, review_date, is_approved) VALUES
-- Reviews for Premium Laptop
((SELECT product_id FROM products WHERE sku = 'LP-1001'), (SELECT customer_id FROM customers WHERE email = 'john.doe@example.com'), 5, 'Excellent laptop! Very fast and great battery life.', CURRENT_DATE - INTERVAL '10 days', TRUE),
((SELECT product_id FROM products WHERE sku = 'LP-1001'), (SELECT customer_id FROM customers WHERE email = 'robert.j@example.com'), 4, 'Great performance but a bit heavy.', CURRENT_DATE - INTERVAL '15 days', TRUE),
((SELECT product_id FROM products WHERE sku = 'LP-1001'), (SELECT customer_id FROM customers WHERE email = 'emily.d@example.com'), 5, 'Perfect for my work needs. Highly recommend!', CURRENT_DATE - INTERVAL '20 days', TRUE),

-- Reviews for Smartphone X
((SELECT product_id FROM products WHERE sku = 'SP-2001'), (SELECT customer_id FROM customers WHERE email = 'jane.smith@example.com'), 5, 'Best phone I''ve ever had!', CURRENT_DATE - INTERVAL '5 days', TRUE),
((SELECT product_id FROM products WHERE sku = 'SP-2001'), (SELECT customer_id FROM customers WHERE email = 'michael.b@example.com'), 3, 'Good phone but battery could be better.', CURRENT_DATE - INTERVAL '12 days', TRUE),

-- Reviews for Desk Chair
((SELECT product_id FROM products WHERE sku = 'FC-3001'), (SELECT customer_id FROM customers WHERE email = 'john.doe@example.com'), 4, 'Comfortable chair for long work days.', CURRENT_DATE - INTERVAL '8 days', TRUE),
((SELECT product_id FROM products WHERE sku = 'FC-3001'), (SELECT customer_id FROM customers WHERE email = 'sarah.w@example.com'), 5, 'Changed my home office setup completely!', CURRENT_DATE - INTERVAL '25 days', TRUE),

-- Reviews for Coffee Maker
((SELECT product_id FROM products WHERE sku = 'CM-4001'), (SELECT customer_id FROM customers WHERE email = 'jane.smith@example.com'), 4, 'Makes great coffee but a bit noisy.', CURRENT_DATE - INTERVAL '3 days', TRUE),
((SELECT product_id FROM products WHERE sku = 'CM-4001'), (SELECT customer_id FROM customers WHERE email = 'david.t@example.com'), 5, 'Perfect for my morning routine!', CURRENT_DATE - INTERVAL '18 days', TRUE),

-- Reviews for Wireless Headphones
((SELECT product_id FROM products WHERE sku = 'WH-6001'), (SELECT customer_id FROM customers WHERE email = 'robert.j@example.com'), 5, 'Amazing sound quality and comfort!', CURRENT_DATE - INTERVAL '2 days', TRUE),
((SELECT product_id FROM products WHERE sku = 'WH-6001'), (SELECT customer_id FROM customers WHERE email = 'thomas.m@example.com'), 4, 'Great for travel. Noise cancellation works well.', CURRENT_DATE - INTERVAL '10 days', TRUE);
```
<img width="1919" height="1137" alt="image" src="https://github.com/user-attachments/assets/3e41d410-0410-4b9f-9fc2-d32b0f3be2d7" />

## **5. Data Verification**

### **Check Table Counts**
```sql
SELECT
    'customers' AS table_name,
    COUNT(*) AS row_count FROM customers
UNION ALL
SELECT
    'products', COUNT(*) FROM products
UNION ALL
SELECT
    'categories', COUNT(*) FROM categories
UNION ALL
SELECT
    'suppliers', COUNT(*) FROM suppliers
UNION ALL
SELECT
    'orders', COUNT(*) FROM orders
UNION ALL
SELECT
    'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT
    'inventory', COUNT(*) FROM inventory
UNION ALL
SELECT
    'reviews', COUNT(*) FROM reviews;
```
<img width="1919" height="1138" alt="image" src="https://github.com/user-attachments/assets/5ebac9f2-2003-4a64-bb1e-6d117f3436c3" />

### **Verify Relationships**
```sql
-- Check for orphaned order items
SELECT oi.order_item_id
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Check for orders with no items
SELECT o.order_id
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
WHERE oi.order_item_id IS NULL AND o.status != 'Cancelled';
```
<img width="1919" height="1139" alt="image" src="https://github.com/user-attachments/assets/7e37599e-9510-4900-84d7-7ad2b7b9d7fa" />

### **Check Inventory Levels**
```sql
-- Find products that need restocking
SELECT
    p.product_id,
    p.product_name,
    i.quantity_in_stock,
    i.reorder_threshold,
    (i.quantity_in_stock - i.reorder_threshold) AS below_threshold_by
FROM
    products p
JOIN
    inventory i ON p.product_id = i.product_id
WHERE
    i.quantity_in_stock <= i.reorder_threshold
ORDER BY
    below_threshold_by ASC;
```
<img width="1919" height="1134" alt="image" src="https://github.com/user-attachments/assets/c6647c1e-dff0-4fe5-9e1e-4917f78ae366" />

## **6. Create the Views from the Documentation**

Now that we have all the tables populated, let's create the views from the original documentation:

```sql
-- Customer summary view
CREATE OR REPLACE VIEW vw_customer_summary AS
SELECT
    c.customer_id,
    c.customer_name,
    c.email,
    c.join_date,
    COUNT(o.order_id) AS total_orders,
    SUM(o.amount) AS lifetime_value,
    MAX(o.order_date) AS last_order_date,
    EXTRACT(DAY FROM (CURRENT_DATE - MAX(o.order_date))) AS days_since_last_order
FROM
    customers c
LEFT JOIN
    orders o ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id;

-- Product performance view
CREATE OR REPLACE VIEW vw_product_performance AS
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    COUNT(oi.order_item_id) AS units_sold,
    SUM(oi.quantity * oi.unit_price) AS revenue,
    SUM(oi.quantity) AS total_quantity,
    AVG(r.rating) AS avg_rating
FROM
    products p
JOIN
    categories c ON p.category_id = c.category_id
LEFT JOIN
    order_items oi ON p.product_id = oi.product_id
LEFT JOIN
    reviews r ON p.product_id = r.product_id
GROUP BY
    p.product_id, p.product_name, c.category_name;

-- Daily sales view
CREATE OR REPLACE VIEW vw_daily_sales AS
SELECT
    DATE_TRUNC('day', o.order_date) AS sale_date,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(o.amount) AS total_sales,
    SUM(oi.quantity) AS total_items,
    COUNT(DISTINCT o.customer_id) AS customer_count
FROM
    orders o
JOIN
    order_items oi ON o.order_id = oi.order_id
GROUP BY
    DATE_TRUNC('day', o.order_date);

-- Low inventory view
CREATE OR REPLACE VIEW vw_low_inventory AS
SELECT
    p.product_id,
    p.product_name,
    i.quantity_in_stock,
    i.reorder_threshold,
    s.supplier_name,
    s.lead_time_days
FROM
    products p
JOIN
    inventory i ON p.product_id = i.product_id
JOIN
    suppliers s ON p.supplier_id = s.supplier_id
WHERE
    i.quantity_in_stock <= i.reorder_threshold
ORDER BY
    i.quantity_in_stock;

-- Customer order summary (from original documentation)
CREATE OR REPLACE VIEW customer_order_summary AS
SELECT
    c.customer_id,
    c.customer_name,
    c.email,
    COUNT(o.order_id) AS total_orders,
    SUM(o.amount) AS total_spent,
    MAX(o.order_date) AS last_order_date,
    AVG(o.amount) AS avg_order_value
FROM
    customers c
LEFT JOIN
    orders o ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id, c.customer_name, c.email;

-- Recent customer activity view
CREATE OR REPLACE VIEW recent_customer_activity AS
SELECT
    c.customer_id,
    c.customer_name,
    c.email,
    COUNT(o.order_id) AS order_count,
    SUM(o.amount) AS total_spent,
    MAX(o.order_date) AS last_order_date,
    AVG(o.amount) AS avg_order_value
FROM
    customers c
LEFT JOIN
    orders o ON c.customer_id = o.customer_id
WHERE
    o.order_date > CURRENT_DATE - INTERVAL '90 days'
    OR o.order_id IS NULL
GROUP BY
    c.customer_id, c.customer_name, c.email;

-- Product catalog view
CREATE OR REPLACE VIEW product_catalog AS
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    p.price,
    COALESCE(i.quantity_in_stock, 0) AS in_stock,
    p.rating
FROM
    products p
JOIN
    categories c ON p.category_id = c.category_id
LEFT JOIN
    inventory i ON p.product_id = i.product_id
WHERE
    p.is_active = TRUE;

-- Legacy customer view
CREATE OR REPLACE VIEW legacy_customer_view AS
SELECT
    customer_id AS id,
    customer_name AS name,
    email,
    phone AS telephone,
    address_line1 AS address
FROM
    customers;
```

## **7. Verification Queries**

Let's verify that our views work correctly:

```sql
-- Test customer summary view
SELECT * FROM vw_customer_summary LIMIT 5;

-- Test product performance view
SELECT * FROM vw_product_performance ORDER BY revenue DESC LIMIT 5;

-- Test daily sales view
SELECT * FROM vw_daily_sales ORDER BY sale_date DESC LIMIT 7;

-- Test low inventory view
SELECT * FROM vw_low_inventory;

-- Test customer order summary
SELECT * FROM customer_order_summary LIMIT 3;

-- Test recent customer activity
SELECT * FROM recent_customer_activity WHERE order_count > 0 LIMIT 3;

-- Test product catalog
SELECT * FROM product_catalog WHERE in_stock > 0 LIMIT 5;

-- Test legacy view
SELECT * FROM legacy_customer_view LIMIT 2;
```

## **8. Cleanup Script (Optional)**

If you need to start over:

```sql
-- Drop all views first (they depend on tables)
DROP VIEW IF EXISTS vw_customer_summary;
DROP VIEW IF EXISTS vw_product_performance;
DROP VIEW IF EXISTS vw_daily_sales;
DROP VIEW IF EXISTS vw_low_inventory;
DROP VIEW IF EXISTS customer_order_summary;
DROP VIEW IF EXISTS recent_customer_activity;
DROP VIEW IF EXISTS product_catalog;
DROP VIEW IF EXISTS legacy_customer_view;

-- Drop tables in reverse dependency order
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS inventory;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS suppliers;

-- Drop helper function
DROP FUNCTION IF EXISTS random_date(DATE, DATE);
DROP FUNCTION IF EXISTS get_random_product();
```

## **9. Database Maintenance**

Set up some basic maintenance:

```sql
-- Create a function to update statistics
CREATE OR REPLACE FUNCTION update_database_stats()
RETURNS VOID AS $$
BEGIN
    ANALYZE customers;
    ANALYZE products;
    ANALYZE orders;
    ANALYZE order_items;
    ANALYZE inventory;
    ANALYZE reviews;
    ANALYZE categories;
    ANALYZE suppliers;
END;
$$ LANGUAGE plpgsql;

-- Create a function to check data integrity
CREATE OR REPLACE FUNCTION check_data_integrity()
RETURNS TABLE (
    check_name VARCHAR,
    issue_count INTEGER,
    details TEXT
) AS $$
BEGIN
    RETURN QUERY
    -- Check for orders with no items
    SELECT
        'Orders with no items' AS check_name,
        COUNT(*) AS issue_count,
        'Orders that exist but have no line items' AS details
    FROM
        orders o
    LEFT JOIN
        order_items oi ON o.order_id = oi.order_id
    WHERE
        oi.order_item_id IS NULL
        AND o.status != 'Cancelled'

    UNION ALL

    -- Check for orphaned order items
    SELECT
        'Orphaned order items' AS check_name,
        COUNT(*) AS issue_count,
        'Order items that reference non-existent orders' AS details
    FROM
        order_items oi
    LEFT JOIN
        orders o ON oi.order_id = o.order_id
    WHERE
        o.order_id IS NULL

    UNION ALL

    -- Check for negative inventory
    SELECT
        'Negative inventory' AS check_name,
        COUNT(*) AS issue_count,
        'Products with negative quantity in stock' AS details
    FROM
        inventory
    WHERE
        quantity_in_stock < 0

    UNION ALL

    -- Check for products with no category
    SELECT
        'Products with no category' AS check_name,
        COUNT(*) AS issue_count,
        'Products that don''t belong to any category' AS details
    FROM
        products
    WHERE
        category_id NOT IN (SELECT category_id FROM categories);

    -- Add more checks as needed
END;
$$ LANGUAGE plpgsql;

-- Run integrity check
SELECT * FROM check_data_integrity();
```

## **10. Sample Queries Using Views**

Here are some example queries that demonstrate how to use the views:

```sql
-- 1. Find high-value customers
SELECT
    customer_id,
    customer_name,
    total_orders,
    lifetime_value
FROM
    vw_customer_summary
WHERE
    lifetime_value > 1000
ORDER BY
    lifetime_value DESC;

-- 2. Product performance analysis
SELECT
    product_name,
    category_name,
    units_sold,
    revenue,
    (revenue / NULLIF(units_sold, 0)) AS avg_price_per_unit
FROM
    vw_product_performance
WHERE
    units_sold > 0
ORDER BY
    revenue DESC
LIMIT 10;

-- 3. Sales trend analysis
SELECT
    sale_date,
    order_count,
    total_sales,
    (total_sales / NULLIF(order_count, 0)) AS avg_order_value,
    LAG(total_sales, 1) OVER (ORDER BY sale_date) AS prev_day_sales,
    total_sales - LAG(total_sales, 1) OVER (ORDER BY sale_date) AS day_over_day_change
FROM
    vw_daily_sales
ORDER BY
    sale_date DESC
LIMIT 30;

-- 4. Inventory management
SELECT
    product_name,
    quantity_in_stock,
    reorder_threshold,
    (quantity_in_stock - reorder_threshold) AS stock_buffer,
    supplier_name,
    lead_time_days
FROM
    vw_low_inventory
ORDER BY
    stock_buffer ASC;

-- 5. Customer segmentation
WITH customer_segments AS (
    SELECT
        customer_id,
        customer_name,
        total_spent,
        CASE
            WHEN total_spent > 1000 THEN 'Platinum'
            WHEN total_spent > 500 THEN 'Gold'
            WHEN total_spent > 200 THEN 'Silver'
            ELSE 'Bronze'
        END AS customer_segment
    FROM
        customer_order_summary
)
SELECT
    customer_segment,
    COUNT(*) AS customer_count,
    AVG(total_spent) AS avg_spend,
    MIN(total_spent) AS min_spend,
    MAX(total_spent) AS max_spend
FROM
    customer_segments
GROUP BY
    customer_segment
ORDER BY
    MIN(total_spent);

-- 6. Product catalog with inventory status
SELECT
    product_id,
    product_name,
    category_name,
    price,
    in_stock,
    CASE
        WHEN in_stock > 50 THEN 'In Stock'
        WHEN in_stock > 10 THEN 'Limited Stock'
        WHEN in_stock > 0 THEN 'Low Stock'
        ELSE 'Out of Stock'
    END AS stock_status
FROM
    product_catalog
ORDER BY
    in_stock;
```

## **11. Performance Optimization**

Let's add some indexes to optimize our views:

```sql
-- Indexes for customer_order_summary view
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_order_date ON orders(order_date);

-- Indexes for product_performance view
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_reviews_product_id ON reviews(product_id);

-- Indexes for daily_sales view
CREATE INDEX idx_orders_date_trunc ON orders(DATE_TRUNC('day', order_date));

-- Indexes for low_inventory view
CREATE INDEX idx_inventory_stock_level ON inventory(quantity_in_stock)
    WHERE quantity_in_stock <= reorder_threshold;
```

## **12. View Documentation**

Create a documentation table for your views:

```sql
CREATE TABLE view_documentation (
    view_name VARCHAR(100) PRIMARY KEY,
    description TEXT,
    created_date DATE DEFAULT CURRENT_DATE,
    last_updated DATE,
    purpose TEXT,
    example_query TEXT,
    dependencies TEXT,
    notes TEXT
);

-- Document our views
INSERT INTO view_documentation (view_name, description, purpose, example_query, dependencies) VALUES
('vw_customer_summary', 'Provides a summary of each customer''s order history and spending',
'Customer analysis, segmentation, and marketing targeting',
'SELECT * FROM vw_customer_summary WHERE lifetime_value > 1000 ORDER BY lifetime_value DESC;',
'customers, orders');

INSERT INTO view_documentation (view_name, description, purpose, example_query, dependencies) VALUES
('vw_product_performance', 'Shows sales performance metrics for each product',
'Product management, inventory planning, and sales analysis',
'SELECT * FROM vw_product_performance ORDER BY revenue DESC LIMIT 10;',
'products, categories, order_items, reviews');

INSERT INTO view_documentation (view_name, description, purpose, example_query, dependencies) VALUES
('vw_daily_sales', 'Aggregates sales data by day for trend analysis',
'Sales reporting, trend analysis, and forecasting',
'SELECT * FROM vw_daily_sales ORDER BY sale_date DESC LIMIT 30;',
'orders, order_items');

INSERT INTO view_documentation (view_name, description, purpose, example_query, dependencies) VALUES
('vw_low_inventory', 'Identifies products that need to be restocked',
'Inventory management and procurement planning',
'SELECT * FROM vw_low_inventory ORDER BY quantity_in_stock;',
'products, inventory, suppliers');

INSERT INTO view_documentation (view_name, description, purpose, example_query, dependencies) VALUES
('customer_order_summary', 'Detailed order summary for each customer',
'Customer service, order history lookup',
'SELECT * FROM customer_order_summary WHERE customer_id = 123;',
'customers, orders');

INSERT INTO view_documentation (view_name, description, purpose, example_query, dependencies) VALUES
('recent_customer_activity', 'Shows recent customer order activity (last 90 days)',
'Customer engagement analysis and retention programs',
'SELECT * FROM recent_customer_activity WHERE order_count > 0;',
'customers, orders');

INSERT INTO view_documentation (view_name, description, purpose, example_query, dependencies) VALUES
('product_catalog', 'Catalog of active products with inventory status',
'Product listing for e-commerce frontends',
'SELECT * FROM product_catalog WHERE in_stock > 0;',
'products, categories, inventory');

INSERT INTO view_documentation (view_name, description, purpose, example_query, dependencies) VALUES
('legacy_customer_view', 'Maintains backward compatibility with old systems',
'Support for legacy applications during migration',
'SELECT * FROM legacy_customer_view WHERE id = 123;',
'customers');
```

## **13. View Usage Tracking**

Set up tracking for view usage:

```sql
-- Create a table to track view usage
CREATE TABLE view_usage_stats (
    stat_id SERIAL PRIMARY KEY,
    view_name VARCHAR(100) NOT NULL,
    query_count INTEGER DEFAULT 0,
    last_queried TIMESTAMP,
    avg_execution_time INTERVAL,
    CONSTRAINT fk_view_name FOREIGN KEY (view_name)
        REFERENCES view_documentation(view_name)
);

-- Create a function to log view usage
CREATE OR REPLACE FUNCTION log_view_usage(p_view_name VARCHAR, p_execution_time INTERVAL)
RETURNS VOID AS $$
BEGIN
    INSERT INTO view_usage_stats (view_name, query_count, last_queried, avg_execution_time)
    VALUES (p_view_name, 1, CURRENT_TIMESTAMP, p_execution_time)
    ON CONFLICT (view_name)
    DO UPDATE SET
        query_count = view_usage_stats.query_count + 1,
        last_queried = CURRENT_TIMESTAMP,
        avg_execution_time =
            (view_usage_stats.avg_execution_time * (view_usage_stats.query_count) + p_execution_time) /
            (view_usage_stats.query_count + 1);
END;
$$ LANGUAGE plpgsql;

-- Create a trigger function template (would need to be implemented per view)
-- This is a conceptual example - in practice you'd need to create specific triggers
-- for each view or use a different approach like pg_stat_statements
```

## **Final Notes**

This complete database setup includes:
1. All tables needed for the views documentation
2. Proper constraints and indexes
3. Realistic sample data
4. All the views from the original documentation
5. Verification queries
6. Maintenance scripts
7. Performance optimization
8. Documentation system

The database is now ready for you to:
- Test all the views from the documentation
- Run the example queries
- Experiment with creating new views
- Explore performance characteristics

Would you like me to:
1. Add more sample data for any specific table?
2. Create additional views for specific use cases?
3. Provide more example queries using the views?
4. Add any specific business logic or constraints?
