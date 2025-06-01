DROP TABLE IF EXISTS Products;
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    Product VARCHAR(255),
    Category VARCHAR(100)
);

INSERT INTO Products (ProductID, Product, Category)
VALUES
    (1, 'Laptop', 'Electronics'),
    (2, 'Smartphone', 'Electronics'),
    (3, 'Tablet', 'Electronics'),
    (9, 'Printer', 'Electronics'),
    (4, 'Headphones', 'Accessories'),
    (5, 'Smartwatch', 'Accessories'),
    (6, 'Keyboard', 'Accessories'),
    (7, 'Mouse', 'Accessories'),
    (8, 'Monitor', 'Accessories');

with cte as(
select *,
ROW_NUMBER() over (order by (SELECT null)) as rn
from Products)

select Product, Category,
(select count(*) from cte) - rn + 1 as ProductID
from cte;

select * from Products;

select (select count(*) from Products) - ProductID + 1 as Products, Product, Category
from Products;

select * from Products;

select Product,Category,
RANK() over (order by ProductID desc) as NewID
from Products