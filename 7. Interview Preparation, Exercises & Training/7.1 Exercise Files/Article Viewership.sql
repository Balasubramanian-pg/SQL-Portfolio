-- Create Views table
CREATE TABLE Views (
    article_id INT,
    author_id INT,
    viewer_id INT,
    view_date DATE
);

-- Insert sample data
INSERT INTO Views (article_id, author_id, viewer_id, view_date) VALUES
(1, 3, 5, '2019-08-01'),
(3, 4, 5, '2019-08-01'),
(1, 3, 6, '2019-08-02'),
(2, 7, 7, '2019-08-01'),
(2, 7, 6, '2019-08-02'),
(4, 7, 1, '2019-07-22'),
(3, 4, 4, '2019-07-21'),
(3, 4, 4, '2019-07-21');

--## Problem Analysis
--From the Views table, we need to:
--1. Group records by viewer_id and view_date
--2. Count distinct articles viewed in each group
--3. Filter for viewers who viewed more than one article
--4. Return these viewer IDs in ascending order

SELECT viewer_id AS id
FROM Views
GROUP BY viewer_id,view_date
HAVING COUNT(DISTINCT article_id) > 1
ORDER BY viewer_id