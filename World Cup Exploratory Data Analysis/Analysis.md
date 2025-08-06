### **The Problem Statement**

A team's success isn't an accident. It's a system. Our problem is that we only see the output (the score), not the inputs that create it (the performance metrics). We need to reverse-engineer the "win" by breaking down every goal scored. Who are the assets? Who are the liabilities? What's the highest-leverage action a team can take? We're not here to be sports analysts; we're here to be strategists who use data to get an unfair advantage.

The final score tells you who won, but the data tells you *how* they won. And if you know *how*, you can replicate it. Or, even better, you can exploit your opponent's weaknesses. This isn't about stats; it's about finding the asymmetrical opportunities that win games.

---

### **Analysis Approach Note (The Game Plan)**

Our approach is simple and brutal. We use SQL as a scalpel to dissect this `Goals` table. We're looking for patterns, dependencies, and weaknesses.

1.  **Identify Key Assets:** Who are the players and teams that consistently deliver? These are your high-performers.
2.  **Expose Liabilities:** Which teams are weak defensively? Who relies on a single player? Who makes unforced errors (like Own Goals)?
3.  **Find the Playbook:** What *type* of action leads to the most goals? Is it set pieces? Is it open play? We find the most effective, repeatable process for scoring.

This isn't an academic exercise. Every query is a question designed to give us a lever to pull. Now, let's execute.

---

### **The Execution: 15 SQL Queries to Win**

Here’s the playbook. Each query is a specific move to expose a weakness or identify a strength.

**Query 1: The 10,000-Foot View. How big is the game we're playing?**
*   **Question:** How many total goals are we even analyzing?

```sql
SELECT
  COUNT(ID) AS TotalGoals
FROM Goals;
```

**Query 2: The Alpha Scorers. Who are the killers?**
*   **Question:** Which players are the real offensive assets? List the top goal scorers.

```sql
SELECT
  Scorer,
  COUNT(ID) AS GoalsScored
FROM Goals
WHERE Type <> 'Own' -- An own goal isn't a credit to the scorer.
GROUP BY
  Scorer
ORDER BY
  GoalsScored DESC;
```

**Query 3: The Offensive Powerhouses. Which teams have the most firepower?**
*   **Question:** Which teams have the best offensive machine?

```sql
SELECT
  ScoringTeam,
  COUNT(ID) AS GoalsFor
FROM Goals
GROUP BY
  ScoringTeam
ORDER BY
  GoalsFor DESC;
```

**Query 4: The Leaky Buckets. Which teams have the worst defense?**
*   **Question:** Who is letting the most goals in? This is where you find who to attack.

```sql
SELECT
  Team,
  SUM(GoalsConceded) AS TotalGoalsConceded
FROM (
  SELECT Home AS Team, COUNT(*) AS GoalsConceded FROM Goals WHERE Home <> ScoringTeam GROUP BY Home
  UNION ALL
  SELECT Away AS Team, COUNT(*) AS GoalsConceded FROM Goals WHERE Away <> ScoringTeam GROUP BY Away
) AS Conceded
GROUP BY Team
ORDER BY TotalGoalsConceded DESC;
```

**Query 5: The Playbook Breakdown. What's the most effective way to score?**
*   **Question:** What type of goal is the highest leverage? Inside the box, freekicks, or penalties?

```sql
SELECT
  Type,
  COUNT(ID) AS NumberOfGoals,
  CAST(COUNT(ID) * 100.0 / (SELECT COUNT(*) FROM Goals) AS DECIMAL(5,2)) AS PercentageOfTotal
FROM Goals
GROUP BY
  Type
ORDER BY
  NumberOfGoals DESC;
```

**Query 6: Home-Field Advantage. Is it real or a myth?**
*   **Question:** Do teams score more when they are at home? Where's the leverage?

```sql
SELECT
  CASE
    WHEN Home = ScoringTeam THEN 'Home Goal'
    ELSE 'Away Goal'
  END AS Location,
  COUNT(ID) AS GoalCount
FROM Goals
GROUP BY
  Location;
```

**Query 7: The Unforced Errors. Who is shooting themselves in the foot?**
*   **Question:** Which teams scored own goals? This is the ultimate liability.

```sql
SELECT
  -- The team that conceded the own goal
  CASE
    WHEN Home = ScoringTeam THEN Away
    ELSE Home
  END AS ConcedingTeam,
  Scorer, -- The player credited with the own goal
  ID
FROM Goals
WHERE
  Type = 'Own';
```

**Query 8: High-Pressure Performance. Who delivers when it matters most?**
*   **Question:** Who are the designated penalty takers and do they deliver?

```sql
SELECT
  Scorer,
  ScoringTeam
FROM Goals
WHERE
  Type = 'Penalty';
```

**Query 9: The One-Man Army. Which team is dangerously dependent on one player?**
*   **Question:** Which player has scored the highest percentage of their team's total goals? This exposes a fragile system.

```sql
WITH TeamGoals AS (
  SELECT ScoringTeam, COUNT(*) AS TotalTeamGoals FROM Goals GROUP BY ScoringTeam
),
PlayerGoals AS (
  SELECT Scorer, ScoringTeam, COUNT(*) AS TotalPlayerGoals FROM Goals WHERE Type <> 'Own' GROUP BY Scorer, ScoringTeam
)
SELECT
  p.Scorer,
  p.ScoringTeam,
  p.TotalPlayerGoals,
  t.TotalTeamGoals,
  CAST(p.TotalPlayerGoals * 100.0 / t.TotalTeamGoals AS DECIMAL(5,2)) AS PctOfTeamGoals
FROM PlayerGoals p
JOIN TeamGoals t ON p.ScoringTeam = t.ScoringTeam
ORDER BY
  PctOfTeamGoals DESC;
```

**Query 10: The Blowouts. Which games were completely one-sided?**
*   **Question:** Where was the momentum overwhelming? Identify the matches with the biggest goal difference.

```sql
SELECT
  ID,
  Home,
  Away,
  COUNT(ID) AS TotalGoalsInMatch
FROM Goals
GROUP BY
  ID, Home, Away
ORDER BY
  TotalGoalsInMatch DESC
LIMIT 1;
```

**Query 11: Stage Fright or Prime Time? How does scoring change by stage?**
*   **Question:** Do teams score more or less as the pressure mounts in later stages?

```sql
SELECT
  Stage,
  COUNT(ID) AS NumberOfGoals,
  AVG(GoalsPerMatch) AS AvgGoalsPerMatch
FROM (
    SELECT
        Stage,
        ID,
        COUNT(ID) OVER(PARTITION BY ID) as GoalsPerMatch
    FROM Goals
) AS MatchGoals
GROUP BY Stage
ORDER BY Stage;
```

**Query 12: Russia's Game Plan. Let's do a deep dive on the host.**
*   **Question:** What's the full performance story for Russia? Goals for, goals against, and how.

```sql
SELECT
  'Goals Scored' AS Metric,
  Scorer AS Detail,
  COUNT(*) AS Count
FROM Goals
WHERE ScoringTeam = 'Russia'
GROUP BY Scorer
UNION ALL
SELECT
  'Goals Conceded' AS Metric,
  ScoringTeam AS Detail,
  COUNT(*) AS Count
FROM Goals
WHERE (Home = 'Russia' OR Away = 'Russia') AND ScoringTeam <> 'Russia'
GROUP BY ScoringTeam;
```

**Query 13: The Specialist. Who is Cheryshev?**
*   **Question:** Let's isolate a key asset. How and when did Russia's top scorer, Cheryshev, make his impact?

```sql
SELECT
  ID,
  Stage,
  Type,
  CASE
    WHEN Home = 'Russia' THEN Away
    ELSE Home
  END AS Opponent
FROM Goals
WHERE Scorer = 'Cheryshev';
```

**Query 14: The Predictable Teams. Who has a one-dimensional attack?**
*   **Question:** Which teams only score one type of goal? A predictable opponent is an easy opponent.

```sql
SELECT
  ScoringTeam
FROM Goals
GROUP BY
  ScoringTeam
HAVING
  COUNT(DISTINCT Type) = 1;
```

**Query 15: The Net Goal Difference. The ultimate measure of dominance.**
*   **Question:** What is each team's final goal difference? This is the bottom line.

```sql
WITH GoalsFor AS (
  SELECT ScoringTeam, COUNT(*) AS GF FROM Goals GROUP BY ScoringTeam
),
GoalsAgainst AS (
  SELECT Team, SUM(GoalsConceded) AS GA FROM (
    SELECT Home AS Team, COUNT(*) AS GoalsConceded FROM Goals WHERE Home <> ScoringTeam GROUP BY Home
    UNION ALL
    SELECT Away AS Team, COUNT(*) AS GoalsConceded FROM Goals WHERE Away <> ScoringTeam GROUP BY Away
  ) AS Conceded GROUP BY Team
)
SELECT
  t.Team,
  COALESCE(gf.GF, 0) AS GoalsFor,
  COALESCE(ga.GA, 0) AS GoalsAgainst,
  (COALESCE(gf.GF, 0) - COALESCE(ga.GA, 0)) AS GoalDifference
FROM (SELECT Home AS Team FROM Goals UNION SELECT Away AS Team FROM Goals) AS t
LEFT JOIN GoalsFor gf ON t.Team = gf.ScoringTeam
LEFT JOIN GoalsAgainst ga ON t.Team = ga.Team
ORDER BY GoalDifference DESC;
```
