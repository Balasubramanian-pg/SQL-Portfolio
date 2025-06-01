-- Create Books table
CREATE TABLE Books (
    book_id INT PRIMARY KEY,
    name VARCHAR(100),
    available_from DATE
);

-- Create Orders table
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    book_id INT,
    quantity INT,
    dispatch_date DATE,
    FOREIGN KEY (book_id) REFERENCES Books(book_id)
);

-- Insert data into Books table
INSERT INTO Books (book_id, name, available_from) VALUES
(1, 'Kalila And Demna', '2010-01-01'),
(2, '28 Letters', '2012-05-12'),
(3, 'The Hobbit', '2019-06-10'),
(4, '13 Reasons Why', '2019-06-01'),
(5, 'The Hunger Games', '2008-09-21');

-- Insert data into Orders table
INSERT INTO Orders (order_id, book_id, quantity, dispatch_date) VALUES
(1, 1, 2, '2018-07-26'),
(2, 1, 1, '2018-11-05'),
(3, 3, 8, '2019-06-11'),
(4, 4, 6, '2019-06-05'),
(5, 4, 5, '2019-06-20'),
(6, 5, 9, '2009-02-02'),
(7, 5, 8, '2010-04-13');

--We need to find out books that sold less than 10 copies in the last year 
--(from 2018-06-23 to 2019-06-23) and have been available for at least 1 month (since before 2019-05-23)


SELECT b.book_id,b.name
FROM Books b
LEFT JOIN Orders o ON b.book_id = o.book_id 
AND o.dispatch_date BETWEEN '2018-06-23' AND '2019-06-23'
WHERE b.available_from < '2019-05-23'
GROUP BY b.book_id
HAVING COALESCE(SUM(o.quantity),0) < 10;