select a.name account_name, a.primary_poc, s.name sales_rep_name
from accounts a
left join sales_reps s
on a.sales_rep_id = s.id and a.primary_poc < s.name;

-- 9.quiz
-- change the interval to 1 day to find those web events that occurred after, but not more than 1 day after, another web event
-- add a column for the channel variable in both instances of the table in your query
SELECT w1.id AS id1, 
w1.account_id AS account_id1,
w1.channel AS channel1, 
w1.occurred_at AS occurred_at1,
w2.id AS id2, 
w2.account_id AS account_id2,
w2.channel AS channel2,
w2.occurred_at AS occurred_at2
FROM web_events w1
LEFT JOIN web_events w2
ON w1.account_id = w2.account_id
AND w1.occurred_at < w2.occurred_at
AND w1.occurred_at + INTERVAL '1 day' >= w2.occurred_at
ORDER BY w1.account_id, w1.occurred_at;

-- 12.quiz
WITH double_accounts AS (
  SELECT *
  FROM accounts 

  UNION ALL
  
  SELECT *
  FROM accounts

)

SELECT name,
       COUNT(*) AS name_count
 FROM double_accounts 
GROUP BY 1
ORDER BY 2 DESC

-- 18. joining subquires 
--  Show the number of orders, the number of sales representive, and the number of web events on a daily basis.
-- Slow way: join all three tables
SELECT  DATE_TRUNC('day', o.occurred_at) AS day,
        COUNT(DISTINCT o.id) AS num_orders,
        COUNT(DISTINCT a.sales_rep_id) AS num_sales_reps,
        COUNT(DISTINCT w.id) AS num_web_events
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN web_events w
ON o.account_id = w.account_id
AND DATE_TRUNC('day', o.occurred_at) = DATE_TRUNC('day', w.occurred_at)
GROUP BY 1;

--Smarter way: joining subqueries
-- subqueire 1: num of orders and num of sales reps on each day
WITH sub1 AS (SELECT DATE_TRUNC('day', o.occurred_at) AS day,
	   COUNT(o.id) num_orders,
       COUNT(a.sales_rep_id) num_sales_reps
FROM orders o
RIGHT JOIN accounts a
ON o.account_id = a.id
GROUP BY 1),

-- subquery 2: num of web events on each day
sub2 AS (SELECT DATE_TRUNC('day', w.occurred_at) AS day,
       COUNT(w.id) num_web_events
FROM web_events w
GROUP BY 1)

-- join subqueries
SELECT COALESCE(sub1.day, sub2.day) AS day, -- if sub1.day is null, use sub2.day
       COALESCE(sub1.num_orders, 0) AS num_orders,
       COALESCE(sub1.num_sales_reps, 0) AS num_sales_reps,
       COALESCE(sub2.num_web_events, 0) AS num_web_events
FROM sub1
FULL JOIN sub2 -- full join: return all rows from both tables, ensure that all days are included in the result set
ON sub1.day = sub2.day
ORDER BY 1;
