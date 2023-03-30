-- 3 quiz
-- 3.1
SELECT RIGHT(website,3) as extension, COUNT(*)
FROM accounts
GROUP BY 1;

-- 3.2
SELECT LEFT(name, 1) as firt_letter, COUNT(*)
FROM accounts
GROUP BY 1;

-- 3.3
-- Use the accounts table and a CASE statement to create two groups: 
-- one group of company names that start with a number and 
-- a second group of those company names that start with a letter.
-- What proportion of company names start with a letter?
WITH first_letter AS (SELECT name, 
    CASE WHEN LEFT(name, 1) IN ('0','1','2','3','4','5','6','7','8','9') 
    THEN 'starts with number' ELSE 'starts with letter' END AS group_name
FROM accounts)

SELECT group_name, COUNT(*)
FROM first_letter
GROUP BY 1;

-- 3.4
-- Consider vowels as a, e, i, o, and u. 
-- What proportion of company names start with a vowel, and what percent start with anything else?
WITH first_letter AS (SELECT name, 
    CASE WHEN LEFT(LOWER(name), 1) IN ('a', 'e', 'i', 'o', 'u') 
    THEN 'vowel' ELSE 'others' END AS group_name
FROM accounts)

SELECT group_name, COUNT(*)
FROM first_letter
GROUP BY 1;

-- 6. quiz
-- 6.1
SELECT LEFT(primary_poc, POSITION(' ' IN primary_poc)-1) as first_name,
	   RIGHT(primary_poc, LENGTH(primary_poc)-POSITION(' ' IN primary_poc)) as last_name
FROM accounts

-- 6.2
SELECT LEFT(name, POSITION(' ' IN name)-1) as first_name,
	   RIGHT(name, LENGTH(name)-STRPOS(name, ' ')) as last_name
FROM sales_reps;   

-- 9.quiz
-- 9.1
SELECT CONCAT(
    LEFT(LOWER(primary_poc), STRPOS(LOWER(primary_poc), ' ')-1), '.',
    RIGHT(LOWER(primary_poc), LENGTH(LOWER(primary_poc))-POSITION(' ' IN primary_poc)),
    '@', LOWER(name), '.com') as email
FROM accounts;

-- 9.2
SELECT CONCAT(
    LEFT(LOWER(primary_poc), STRPOS(LOWER(primary_poc), ' ')-1), '.',
    RIGHT(LOWER(primary_poc), LENGTH(LOWER(primary_poc))-POSITION(' ' IN primary_poc)),
    '@',
    LOWER(REPLACE(name, ' ', '')), 
    '.com') as email
FROM accounts;

-- 9.3
-- The first password will be the first letter of the primary_poc's first name (lowercase),
-- then the last letter of their first name (lowercase), 
-- the first letter of their last name (lowercase), 
-- the last letter of their last name (lowercase), 
-- the number of letters in their first name,
-- the number of letters in their last name, 
-- and then the name of the company they are working with, all capitalized with no spaces.
WITH primary_poc_table as(
        SELECT LEFT(primary_poc, STRPOS(primary_poc, ' ')-1) AS first_name,
            RIGHT(primary_poc, LENGTH(primary_poc)-STRPOS(primary_poc, ' ')) AS last_name, 
            name as account_name
        FROM accounts)

SELECT LEFT(LOWER(first_name), 1) || RIGHT(LOWER(first_name), 1) || 
    LEFT(LOWER(last_name), 1) || RIGHT(LOWER(last_name), 1) || 
    LENGTH(first_name) || LENGTH(last_name) || UPPER(REPLACE(account_name, ' ', '')) AS init_password
FROM primary_poc_table

-- 12.quiz
SELECT date
FROM sf_crime_data
LIMIT 10;

SELECT (SUBSTR(date, 7, 4) || '-' || SUBSTR(date, 1, 2) || '-' || SUBSTR(date, 4, 2))::date
FROM sf_crime_data

-- 15.quiz
--15.1
SELECT *
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

-- 15.2
SELECT COALESCE(o.id, a.id) filled_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id, o.*
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

-- 15.3
SELECT COALESCE(o.account_id, a.id) filled_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id, o.*
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

-- 15.4
WITH t1 AS (
  SELECT *
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL)

SELECT COALESCE(standard_qty, 0) standard_qty, 
COALESCE(gloss_qty, 0) gloss_qty, 
COALESCE(poster_qty, 0) poster_qty, 
COALESCE(standard_amt_usd, 0) standard_amt_usd,
COALESCE(gloss_amt_usd, 0) gloss_amt_usd,
COALESCE(poster_amt_usd, 0) poster_amt_usd
FROM t1;

-- 15.5
SELECT COUNT(a.id) account_num, COUNT(o.id) order_num
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id;

-- 15.6
SELECT COALESCE(standard_qty, 0) standard_qty, 
COALESCE(gloss_qty, 0) gloss_qty, 
COALESCE(poster_qty, 0) poster_qty, 
COALESCE(standard_amt_usd, 0) standard_amt_usd,
COALESCE(gloss_amt_usd, 0) gloss_amt_usd,
COALESCE(poster_amt_usd, 0) poster_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id