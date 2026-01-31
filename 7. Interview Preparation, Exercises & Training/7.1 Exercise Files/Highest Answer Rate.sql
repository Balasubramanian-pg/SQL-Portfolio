-- Create table with VARCHAR and check constraint
CREATE TABLE SurveyLog (
    id INT,
    action VARCHAR(10) CHECK (action IN ('show', 'answer', 'skip')),
    question_id INT,
    answer_id INT NULL,
    q_num INT,
    timestamp INT
);

INSERT INTO SurveyLog (id, action, question_id, answer_id, q_num, timestamp) VALUES
(5, 'show', 285, NULL, 1, 123),
(5, 'answer', 285, 124124, 1, 124),
(5, 'show', 369, NULL, 2, 125),
(5, 'skip', 369, NULL, 2, 126);

WITH AnswerStats AS (
    SELECT 
        question_id,
        COUNT(CASE WHEN action = 'answer' THEN 1 END) AS answer_count,
        COUNT(CASE WHEN action = 'show' THEN 1 END) AS show_count
    FROM 
        SurveyLog
    GROUP BY 
        question_id
)
SELECT 
    question_id AS survey_log
FROM 
    AnswerStats
ORDER BY 
    (answer_count::FLOAT / NULLIF(show_count, 0)) DESC NULLS LAST,
    question_id ASC
LIMIT 1;