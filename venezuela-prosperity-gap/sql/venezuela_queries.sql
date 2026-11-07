-- =====================================================================
-- Prosperity Gap in Venezuela (1981-2006) vs. Latin America
-- SQL queries (SQLite)
--
-- Tables
--   prosperity_gap       one row per country and year (171 countries)
--   regional_aggregates  World Bank regional aggregates (e.g. LCN = Latin America & Caribbean)
--
-- Columns: country_code, country, year, prosperity_gap,
--          comparability_spell, distribution_type
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. What does Venezuela's data look like?
-- Concepts: SELECT, WHERE, ORDER BY
-- ---------------------------------------------------------------------
SELECT year, prosperity_gap, comparability_spell, distribution_type
FROM prosperity_gap
WHERE country_code = 'VEN'
ORDER BY year;


-- ---------------------------------------------------------------------
-- 2. Summary of Venezuela's series
-- Concepts: aggregate functions (COUNT, MIN, MAX, AVG), ROUND
-- ---------------------------------------------------------------------
SELECT
    COUNT(*)                       AS observations,
    MIN(year)                      AS first_year,
    MAX(year)                      AS last_year,
    ROUND(MIN(prosperity_gap), 2)  AS lowest_gap,
    ROUND(MAX(prosperity_gap), 2)  AS highest_gap,
    ROUND(AVG(prosperity_gap), 2)  AS average_gap
FROM prosperity_gap
WHERE country_code = 'VEN';


-- ---------------------------------------------------------------------
-- 3. In which year was Venezuela's gap the largest?
-- Concepts: ORDER BY ... DESC, LIMIT
-- ---------------------------------------------------------------------
SELECT year, ROUND(prosperity_gap, 2) AS prosperity_gap
FROM prosperity_gap
WHERE country_code = 'VEN'
ORDER BY prosperity_gap DESC
LIMIT 1;


-- ---------------------------------------------------------------------
-- 4. How much did the gap change between one observation and the next?
-- Concepts: window function LAG
-- Note: years are not consecutive, so this compares each observation with
-- the previous available one. Changes that cross comparability spells
-- (1987 -> 1989 and 1999 -> 2001) should be read with caution.
-- ---------------------------------------------------------------------
SELECT
    year,
    ROUND(prosperity_gap, 2) AS prosperity_gap,
    ROUND(LAG(prosperity_gap) OVER (ORDER BY year), 2) AS previous_value,
    ROUND((prosperity_gap / LAG(prosperity_gap) OVER (ORDER BY year) - 1) * 100, 1) AS pct_change
FROM prosperity_gap
WHERE country_code = 'VEN'
ORDER BY year;


-- ---------------------------------------------------------------------
-- 5. Venezuela compared with the Latin America & Caribbean average
-- Concepts: JOIN between two tables
-- ---------------------------------------------------------------------
SELECT
    v.year,
    ROUND(v.prosperity_gap, 2)                    AS venezuela,
    ROUND(r.prosperity_gap, 2)                    AS lac_average,
    ROUND(v.prosperity_gap - r.prosperity_gap, 2) AS difference
FROM prosperity_gap AS v
JOIN regional_aggregates AS r
    ON r.year = v.year
   AND r.country_code = 'LCN'
WHERE v.country_code = 'VEN'
ORDER BY v.year;


-- ---------------------------------------------------------------------
-- 6. Where was Venezuela in 2003, the year of its peak?
-- Concepts: window function RANK, IN
-- ---------------------------------------------------------------------
SELECT
    RANK() OVER (ORDER BY prosperity_gap DESC) AS position,
    country,
    ROUND(prosperity_gap, 2)                   AS prosperity_gap
FROM prosperity_gap
WHERE year = 2003
  AND country_code IN ('BOL','BRA','CHL','COL','CRI','DOM','ECU','SLV','GTM',
                       'HND','MEX','NIC','PAN','PRY','PER','URY','VEN')
ORDER BY position;


-- ---------------------------------------------------------------------
-- 7. Average gap by country, 1995-2006
-- Concepts: GROUP BY, HAVING, RANK over an aggregate
-- Only countries with at least 3 observations in the period are kept.
-- ---------------------------------------------------------------------
SELECT
    RANK() OVER (ORDER BY AVG(prosperity_gap) DESC) AS position,
    country,
    ROUND(AVG(prosperity_gap), 1) AS average_gap,
    COUNT(*)                      AS observations
FROM prosperity_gap
WHERE year BETWEEN 1995 AND 2006
  AND country_code IN ('BOL','BRA','CHL','COL','CRI','DOM','ECU','SLV','GTM',
                       'HND','MEX','NIC','PAN','PRY','PER','URY','VEN')
GROUP BY country
HAVING COUNT(*) >= 3
ORDER BY position;
