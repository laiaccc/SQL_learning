SELECT SUM(orders.poster_qty) 
FROM orders;

SELECT SUM(orders.standard_qty)
FROM orders;

SELECT SUM(orders.total_amt_usd) total_revenue_usd
FROM orders;

SELECT(orders.standard_amt_usd + orders.gloss_amt_usd) standard_and_gloss_amt_usd
FROM orders;

SELECT SUM(o.standard_amt_usd) / SUM(o.standard_qty) standard_unit_price
FROM orders o;

SELECT MIN(occurred_at) earliest_order
FROM orders;

SELECT occurred_at earliste_order
FROM orders
ORDER BY occurred_at
LIMIT 1;

SELECT MAX(occurred_at) recent_web_event
FROM web_events;

SELECT occurred_at recent_web_event
FROM web_events
ORDER BY occurred_at DESC
LIMIT 1;

SELECT AVG(standard_amt_usd) avg_standard_usd,
AVG(poster_amt_usd) avg_poster_usd,
AVG(gloss_amt_usd) avg_gloss_usd,
AVG(standard_qty) avg_standard_qty,
AVG(poster_qty) avg_poster_qty,
AVG(gloss_qty) avg_poster_qty
FROM orders;

--what is the MEDIAN total_usd spent on all orders?
SELECT *
FROM (SELECT total_amt_usd
         FROM orders
         ORDER BY total_amt_usd
         LIMIT 3457) AS Table1
ORDER BY total_amt_usd DESC
LIMIT 2;

-- 14 quiz
-- 1.
--Which account (by name) placed the earliest order?
--Your solution should have the account name and the date of the order.
SELECT a.name account_name, MIN(o.occurred_at) date
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
ORDER BY date
LIMIT 1;

SELECT a.name, o.occurred_at
FROM accounts a
JOIN orders o
ON a.id = o.account_id
ORDER BY occurred_at
LIMIT 1;

-- 2.
--Find the total sales in usd for each account, 
--Include the total sales for each company's orders in usd and the company name.
SELECT SUM(o.total_amt_usd) total_usd, a.name
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.name;

-- 3.
--Via what channel did the most recent (latest) web_event occur, which account was associated with this web_event? 
--Your query should return only three values - the date, channel, and account name.
SELECT MAX(w.occurred_at) date, w.channel, a.name account_name
FROM web_events w
JOIN accounts a
ON a.id = w.account_id
GROUP BY account_name, w.channel
ORDER BY date DESC
LIMIT 1;

SELECT w.occurred_at, w.channel, a.name
FROM web_events w
JOIN accounts a
ON w.account_id = a.id 
ORDER BY w.occurred_at DESC
LIMIT 1;

-- 4.
-- Find the total number of times each type of channel from the web_events was used. 
-- Your final table should have two columns - the channel and the number of times the channel was used.
SELECT w.channel, COUNT(w.channel)
FROM web_events w
GROUP BY w.channel;

-- 5.
--Who was the primary contact associated with the earliest web_event?
SELECT MIN(w.occurred_at) earliest_date, a.primary_poc
FROM web_events w
JOIN accounts a
ON a.id = w.account_id
GROUP BY a.primary_poc
ORDER BY earliest_date
LIMIT 1;

SELECT a.primary_poc
FROM web_events w
JOIN accounts a
ON a.id = w.account_id
ORDER BY w.occurred_at
LIMIT 1;

-- 6.
-- What was the smallest order placed by each account in terms of total usd. 
-- Provide only two columns - the account name and the total usd. 
-- Order from smallest dollar amounts to largest.
SELECT MIN(o.total_amt_usd) smallest_order_usd, a.name
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.name
ORDER BY smallest_order_usd

-- 7.
--Find the number of sales reps in each region. 
--Your final table should have two columns - the region and the number of sales_reps. 
--Order from fewest reps to most reps.
SELECT COUNT(s.name) num_sales_reps, r.name region
FROM sales_reps s
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
ORDER BY num_sales_reps

--17. Questions: GROUP BY Part II
-- 17.1For each account, determine the average amount of each type of paper they purchased across their orders. 
--Your result should have four columns:
-- one for the account name and
-- one for the average quantity purchased for each of the paper types for each account.
SELECT a.name, 
AVG(o.standard_qty) avg_standard_qty,
AVG(o.poster_qty) avg_poster_qty, 
AVG(o.gloss_qty) avg_gloss_qty
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.name

--17.2
SELECT a.name, 
AVG(o.standard_amt_usd) avg_standard_usd,
AVG(o.poster_amt_usd) avg_poster_usd, 
AVG(o.gloss_amt_usd) avg_gloss_usd
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.name

--17.3
--Determine the number of times a particular channel was used in the web_events table for each sales rep. 
--three columns - the name of the sales rep, the channel, and the number of occurrences. 
--Order your table with the highest number of occurrences first.
SELECT s.name, w.channel, COUNT(w.channel) num_occurrences
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
GROUP BY w.channel, s.name
ORDER BY num_occurrences DESC

--17.4
--Determine the number of times a particular channel was used in the web_events table for each region.
--  three columns - the region name, the channel, and the number of occurrences. 
-- Order your table with the highest number of occurrences first.
SELECT r.name, w.channel, COUNT(w.channel) num_occurrences
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region r
ON r.id = s.region_id
GROUP BY w.channel, r.name
ORDER BY num_occurrences DESC;

--20. 
--20.1 Use DISTINCT to test if there are any accounts associated with more than one region
SELECT DISTINCT a.id account_id, r.id region_id
FROM accounts a
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region r
ON s.region_id = r.id
ORDER BY account_id;

-- 20.2 Have any sales reps worked on more than one account?
SELECT DISTINCT s.id sales_rep_id, a.id account_id
FROM sales_reps s
JOIN accounts a
ON s.id = a.sales_rep_id
ORDER BY sales_rep_id;

--CORRECT ANSWER
SELECT s.id, s.name, COUNT(*) num_accounts
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.id, s.name
ORDER BY num_accounts;


-- 23 quiz
-- 23.1 How many of the sales reps have more than 5 accounts that they manage?
SELECT COUNT(*) FROM 
(SELECT s.id, s.name, COUNT(a.id) num_accounts
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
GROUP BY s.id, s.name) AS table1
WHERE table1.num_accounts > 5

-- 23.2 How many accounts have more than 20 orders?
SELECT COUNT(*) FROM
(SELECT a.id, a.name, COUNT(o.id) num_orders
FROM accounts a
JOIN orders o
ON o.account_id = a.id
GROUP BY a.id, a.name
HAVING COUNT(o.id) > 20) AS table1;

-- 23.3 Which account has the most orders?
SELECT a.id, a.name, COUNT(o.id) num_orders
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY num_orders DESC
LIMIT 1;

-- 23.4 Which accounts spent more than 30,000 usd total across all orders?
SELECT a.id, a.name, SUM(o.total_amt_usd) total
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
HAVING SUM(o.total_amt_usd) > 30000

-- 23.5 Which accounts spent less than 1,000 usd total across all orders?
SELECT a.id, a.name, SUM(o.total_amt_usd) total
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
HAVING SUM(o.total_amt_usd) < 1000

-- 23.6 Which account has spent the most with us?
SELECT a.id, a.name, SUM(o.total_amt_usd) total
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY total DESC
LIMIT 1;

--23.7 Which account has spent the least with us?
SELECT a.id, a.name, SUM(o.total_amt_usd) total
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY total
LIMIT 1;

--23.8 Which accounts used facebook as a channel to contact customers more than 6 times?
SELECT a.id, a.name, w.channel, COUNT(w.channel) channel_times
FROM accounts a
JOIN web_events w
ON w.account_id = a.id
WHERE w.channel = 'facebook'
GROUP BY a.id, a.name, w.channel
HAVING COUNT(w.channel) > 6;

-- OR
SELECT a.id, a.name, w.channel, COUNT(*) use_of_channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY a.id, a.name, w.channel
HAVING COUNT(*) > 6 AND w.channel = 'facebook'
ORDER BY use_of_channel;

--23.9 Which account used facebook most as a channel?
SELECT a.id, a.name, w.channel, COUNT(w.channel) channel_times
FROM accounts a
JOIN web_events w
ON w.account_id = a.id
WHERE w.channel = 'facebook'
GROUP BY a.id, a.name, w.channel
ORDER BY channel_times DESC
LIMIT 1;

--23.10 Which channel was most frequently used by most accounts?
SELECT w.channel, COUNT(a.id) num_accounts
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
GROUP BY w.channel
ORDER by num_accounts DESC
LIMIT 1;

--CORRECT ANSWER
SELECT a.id, a.name, w.channel, COUNT(*) use_of_channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY a.id, a.name, w.channel
ORDER BY use_of_channel DESC
LIMIT 10;

--27. Questions: Working With DATEs
-- 27.1 Find the sales in terms of total dollars for all orders in each year, 
-- ordered from greatest to least. Do you notice any trends in the yearly sales totals?
SELECT DATE_PART('year', occurred_at) years, 
SUM(total_amt_usd) total_sales
FROM orders 
GROUP BY 1
ORDER BY 2 DESC
-- sale values increased from 2014 to 2016, there is only one-month data in 2013/2017

-- 27.2 Which month did Parch & Posey have the greatest sales in terms of total dollars? 
-- Are all months evenly represented by the dataset?
SELECT DATE_PART('month', occurred_at) months, 
SUM(total_amt_usd) total_sales,
COUNT(id) order_count
FROM orders 
GROUP BY 1
ORDER BY 2 DESC, 3 DESC;

-- In order for this to be 'fair', 
-- we should remove the sales from 2013 and 2017. For the same reasons as discussed above.
SELECT DATE_PART('month', occurred_at) ord_month, SUM(total_amt_usd) total_spent
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY 1
ORDER BY 2 DESC; 

-- 27.3 Which year did Parch & Posey have the greatest sales in terms of total number of orders? 
-- Are all years evenly represented by the dataset?
SELECT DATE_PART('year', occurred_at) years,
SUM(total) total_qty
FROM orders 
GROUP BY 1
ORDER BY 2 DESC;

--CORRECT ANSWER
SELECT DATE_PART('year', occurred_at) ord_year,  COUNT(*) total_sales
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

-- 27.4 Which month did Parch & Posey have the greatest sales in terms of total number of orders? 
-- Are all months evenly represented by the dataset?
SELECT DATE_PART('month', occurred_at) months,
SUM(total) total_qty
FROM orders 
GROUP BY 1
ORDER BY 2 DESC;

--CORRECT ANSWERS
SELECT DATE_PART('month', occurred_at) ord_month, COUNT(*) total_sales
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY 1
ORDER BY 2 DESC; 
-- December still has the most sales, 
-- but interestingly, November has the second most sales (but not the most dollar sales. 
-- To make a fair comparison from one month to another 2017 and 2013 data were removed.

-- 27.5 In which month of which year did Walmart spend the most on gloss paper in terms of dollars?
SELECT DATE_PART('year', o.occurred_at) years,
DATE_TRUNC('month', o.occurred_at) months,
a.name,
MAX(o.gloss_amt_usd) max_gloss_spent
FROM orders o
JOIN accounts a
ON a.id = o.account_id
WHERE a.name = 'Walmart'
GROUP BY 1,2,3
ORDER BY 1 DESC, 4 DESC;

--CORRECT ANSWER
SELECT DATE_TRUNC('month', o.occurred_at) ord_date, SUM(o.gloss_amt_usd) tot_spent
FROM orders o 
JOIN accounts a
ON a.id = o.account_id
WHERE a.name = 'Walmart'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 31. quiz
-- 31.1 
SELECT account_id, total_amt_usd, 
CASE WHEN total_amt_usd > 3000 THEN 'Large'
ELSE 'Small' END AS order_level
FROM orders

--31.2
SELECT COUNT(*) num_orders,
CASE WHEN total >= 2000 THEN 'greater_than_2000'
WHEN total>=1000 AND total < 2000 THEN 'between_1000_2000'
ELSE 'less_than_1000' END AS qty_level
FROM orders
GROUP BY 2

--31.3
SELECT a.name, SUM(o.total_amt_usd) total_sales,
CASE WHEN SUM(o.total_amt_usd) > 200000 THEN 'great'
WHEN SUM(o.total_amt_usd) BETWEEN 100000 AND 200000 THEN 'medium'
ELSE 'small' END AS client_level
FROM orders o 
JOIN accounts a
ON o.account_id = a.id
GROUP BY a.name
ORDER BY 2 DESC

--31.4
SELECT a.name, SUM(o.total_amt_usd) total_sales,
CASE WHEN SUM(o.total_amt_usd) > 200000 THEN 'great'
WHEN SUM(o.total_amt_usd) BETWEEN 100000 AND 200000 THEN 'medium'
ELSE 'small' END AS client_level
FROM orders o 
JOIN accounts a
ON o.account_id = a.id
WHERE o.occurred_at BETWEEN '2016-01-01' AND '2018-01-01'
GROUP BY a.name
ORDER BY 2 DESC

--31.5
SELECT s.name, COUNT(o.id) num_orders, 
CASE WHEN COUNT(o.id) > 200 THEN 'top'
ELSE 'not' END AS rep_level
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
GROUP BY 1
ORDER BY 2 DESC

--31.6
SELECT s.name, COUNT(o.id) num_orders, 
SUM(o.total_amt_usd) total_sales,
CASE WHEN COUNT(o.id) > 200 
OR SUM(total_amt_usd) > 750000
THEN 'top'
WHEN COUNT(o.id) BETWEEN 150 AND 200 
OR SUM(total_amt_usd) BETWEEN 500000 AND 750000
THEN 'middle'
ELSE 'low' END AS rep_level
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
GROUP BY 1
ORDER BY 3 DESC