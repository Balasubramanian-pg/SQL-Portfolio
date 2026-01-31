-- Create Events table
CREATE TABLE Events (
    business_id INT,
    event_type VARCHAR(50),
    occurrences INT,
    PRIMARY KEY (business_id, event_type)
);

-- Insert sample data
INSERT INTO Events (business_id, event_type, occurrences) VALUES
(1, 'reviews', 7),
(3, 'reviews', 3),
(1, 'ads', 11),
(2, 'ads', 7),
(3, 'ads', 6),
(1, 'page views', 3),
(2, 'page views', 12);

-- Solution query
WITH EventAverages AS (
    SELECT 
        event_type,
        AVG(occurrences) AS avg_occurrences
    FROM 
        Events
    GROUP BY 
        event_type
),
BusinessActiveEvents AS (
    SELECT 
        e.business_id,
        e.event_type,
        COUNT(*) OVER (PARTITION BY e.business_id) AS active_event_count
    FROM 
        Events e
    JOIN 
        EventAverages a ON e.event_type = a.event_type
    WHERE 
        e.occurrences > a.avg_occurrences
)
SELECT DISTINCT
    business_id
FROM 
    BusinessActiveEvents
WHERE 
    active_event_count > 1
ORDER BY 
    business_id;