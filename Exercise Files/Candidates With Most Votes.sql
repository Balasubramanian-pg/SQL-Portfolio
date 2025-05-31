-- Create the Candidate table
CREATE TABLE Candidate (
    id INT PRIMARY KEY,
    name VARCHAR(50)
);

-- Create the Vote table
CREATE TABLE Vote (
    id INT PRIMARY KEY,
    candidateId INT,
    FOREIGN KEY (candidateId) REFERENCES Candidate(id)
);

-- Insert candidate data
INSERT INTO Candidate (id, name) VALUES
(1, 'A'),
(2, 'B'),
(3, 'C'),
(4, 'D'),
(5, 'E');

-- Insert vote data
INSERT INTO Vote (id, candidateId) VALUES
(1, 2),
(2, 4),
(3, 3),
(4, 2),
(5, 5);

SELECT c.name
FROM Candidate C
JOIN 
(SELECT candidateID, COUNT(*) AS Votes
FROM Vote
GROUP BY candidateID
ORDER BY Votes DESC
LIMIT 1)
V ON c.id = v.candidateId
