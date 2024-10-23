-- LEVEL 1
SELECT *
FROM sessions;
SELECT *
FROM chargers;
-- Question 1: Number of users with sessions
SELECT COUNT(DISTINCT user_id) as 'Number of users with sessions'
FROM sessions;
-- Question 2: Number of chargers used by user with id 1
SELECT COUNT(charger_id) as 'Number of chargers used by user with id 1'
FROM sessions
WHERE user_id = 1;
-- LEVEL 2
-- Question 3: Number of sessions per charger type (AC/DC):
SELECT COUNT(s.id) as 'Number of sessions', c.type
FROM sessions s
JOIN chargers c ON s.charger_id = c.id
GROUP BY c.type;
-- Question 4: Chargers being used by more than one user
SELECT s.charger_id, COUNT(DISTINCT s.user_id) as 'Quantity of users'
FROM sessions s
GROUP BY s.charger_id
HAVING COUNT(DISTINCT s.user_id) > 1
ORDER BY COUNT(DISTINCT s.user_id) DESC;
-- Question 5: Average session time per charger
SELECT charger_id, AVG(julianday(end_time) - julianday(start_time))*24 as 'Average session time per charger'
FROM sessions
GROUP BY charger_id
ORDER BY AVG(julianday(end_time) - julianday(start_time))*24 DESC;
-- LEVEL 3
-- Question 6: Full username of users that have used more than one charger in one day (NOTE: for date only consider start_time)

SELECT DISTINCT u.name || ' ' || u.surname AS full_name
FROM users u
JOIN sessions s ON u.id = s.user_id
GROUP BY DATE(s.start_time), u.id
HAVING COUNT(DISTINCT s.charger_id) > 1
ORDER BY full_name;

-- Question 7: Top 3 chargers with longer sessions

SELECT charger_id, ROUND(MAX((julianday(end_time) - julianday(start_time)) * 24), 2) AS max_session_duration_hours
FROM sessions
GROUP BY charger_id
ORDER BY max_session_duration_hours DESC
LIMIT 3;

-- Question 8: Average number of users per charger (per charger in general, not per charger_id specifically)

SELECT AVG(user_count) AS 'Average number of users per charger'
FROM (SELECT s.charger_id, COUNT(DISTINCT u.id) AS user_count
FROM sessions s
JOIN users u ON s.user_id = u.id
GROUP BY s.charger_id);

-- Question 9: Top 3 users with more chargers being used

SELECT s.user_id, COUNT(DISTINCT s.charger_id) AS chargers_used
FROM sessions s
GROUP BY s.user_id
ORDER BY chargers_used DESC
LIMIT 3;

-- LEVEL 4

-- Question 10: Number of users that have used only AC chargers, DC chargers or both

WITH UserChargerTypes AS (
    SELECT user_id,
           COUNT(DISTINCT CASE WHEN c.type = 'AC' THEN 1 END) AS ac_count,
           COUNT(DISTINCT CASE WHEN c.type = 'DC' THEN 1 END) AS dc_count
    FROM sessions s
    JOIN chargers c ON s.charger_id = c.id
    GROUP BY user_id
)
SELECT
    SUM(CASE WHEN ac_count > 0 AND dc_count = 0 THEN 1 ELSE 0 END) AS only_ac,
    SUM(CASE WHEN dc_count > 0 AND ac_count = 0 THEN 1 ELSE 0 END) AS only_dc,
    SUM(CASE WHEN ac_count > 0 AND dc_count > 0 THEN 1 ELSE 0 END) AS both
FROM UserChargerTypes;

-- Question 11: Monthly average number of users per charger

SELECT charger_id, AVG(user_count) AS 'Monthly average number of users per charger', mes
FROM (SELECT STRFTIME('%Y-%m',s.start_time) AS mes, s.charger_id, COUNT(DISTINCT u.id) AS user_count
FROM sessions s
JOIN users u ON s.user_id = u.id
GROUP BY mes, s.charger_id)
GROUP BY charger_id
ORDER BY charger_id;

-- Question 12: Top 3 users per charger (for each charger, number of sessions)
SELECT charger_id, session_count, user_id, rank
FROM (SELECT charger_id, user_id, COUNT(*) AS session_count, ROW_NUMBER() OVER (PARTITION BY charger_id ORDER BY COUNT (*) DESC) AS rank
FROM sessions
GROUP BY charger_id, user_id)
WHERE rank <=3;

-- LEVEL 5

-- Question 13: Top 3 users with longest sessions per month (consider the month of start_time)

WITH 
UserSessionDurations AS (
    SELECT 
        user_id, 
        STRFTIME('%Y-%m', start_time) AS mes, 
        ROUND((julianday(end_time) - julianday(start_time)) * 24, 2) AS duration_hours
    FROM sessions
),
RankedSessions AS (
    SELECT 
        user_id, 
        mes, 
        duration_hours,
        RANK() OVER (PARTITION BY mes ORDER BY duration_hours DESC) AS rank
    FROM UserSessionDurations
)

SELECT 
    user_id, 
    mes, 
    duration_hours,
    rank
FROM RankedSessions
WHERE rank <= 3
ORDER BY mes, rank;

-- Question 14. Average time between sessions for each charger for each month (consider the month of start_time)

WITH 
cargas AS (
    SELECT 
        charger_id,
        start_time,
        RANK() OVER (PARTITION BY charger_id ORDER BY start_time ASC) AS ranking
    FROM sessions
),
diferencias AS (
    SELECT
        charger_id,
        start_time,
        LAG(start_time) OVER (PARTITION BY charger_id ORDER BY ranking) AS carga_previa
    FROM cargas
)
SELECT 
    charger_id,
    STRFTIME('%Y-%m', start_time) AS mes,
    ROUND(AVG((julianday(start_time) - julianday(carga_previa)) * 24), 2) AS 'Average time between sessions'
FROM diferencias
WHERE carga_previa IS NOT NULL
GROUP BY mes, charger_id
ORDER BY mes, charger_id;
