SELECT channel, 
AVG(count) avg_daily_count
FROM 
(SELECT DATE_TRUNC('day', occurred_at) ord_date,
                  channel,
                  COUNT(*)
FROM web_events
GROUP BY 1, 2) as sub
GROUP BY 1


SELECT *
FROM orders
WHERE DATE_TRUNC('month', occurred_at) =
(SELECT MIN(DATE_TRUNC('month', occurred_at)) ord_month FROM orders);

SELECT AVG(standard_qty) avg_standard_qty,
       AVG(gloss_qty) avg_gloss_qty,
       AVG(poster_qty) avg_poster_qty
FROM orders
WHERE DATE_TRUNC('month', occurred_at) =
(SELECT MIN(DATE_TRUNC('month', occurred_at)) ord_month FROM orders) AS sub;

SELECT SUM(total_amt_usd)
FROM orders
WHERE DATE_TRUNC('month', occurred_at) =
(SELECT MIN(DATE_TRUNC('month', occurred_at)) ord_month FROM orders) AS sub;

-- 9. quiz
--9.1 Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.
SELECT t3.sales_rep, t2.region, t2.largest_sales
FROM (SELECT t1.region, MAX(t1.total_sales) largest_sales
     FROM (SELECT s.name sales_rep, r.name region, SUM(o.total_amt_usd) total_sales
            FROM sales_reps s
            JOIN region r
            ON s.region_id = r.id
            JOIN accounts a
            ON a.sales_rep_id = s.id 
            JOIN orders o
            ON o.account_id = a.id 
            GROUP BY 1,2) as t1
     GROUP BY t1.region) as t2
JOIN (SELECT s.name sales_rep, r.name region, SUM(o.total_amt_usd) total_sales
            FROM sales_reps s
            JOIN region r
            ON s.region_id = r.id
            JOIN accounts a
            ON a.sales_rep_id = s.id 
            JOIN orders o
            ON o.account_id = a.id 
            GROUP BY 1,2) as t3
ON t3.total_sales = t2.largest_sales

--9.2 For the region with the largest (sum) of sales total_amt_usd, 
--how many total (count) orders were placed?
SELECT r.name, SUM(o.total_amt_usd) total_sales_usd, COUNT(o.id) order_count
FROM region r
JOIN sales_reps s 
ON r.id = s.region_id
JOIN accounts a 
ON s.id = a.sales_rep_id
JOIN orders o
ON o.account_id = a.id 
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

--9.3 How many accounts had more total purchases than the account name 
-- which has bought the most standard_qty paper throughout their lifetime as a customer?

-- t1: the total qty of standard paper bought by each customer
-- t1: also the total purchased qty of each customer
SELECT a.name, SUM(o.standard_qty) total_standard_qty, SUM(o.total) total_purchases
FROM accounts a 
JOIN orders o 
ON a.id = o.account_id
GROUP BY 1
ORDER BY 2 DESC

-- t2: the purchases of the account with max qty of purchased standard paper
SELECT a.name, SUM(o.standard_qty) total_standard_qty, SUM(o.total) total_purchases
FROM accounts a 
JOIN orders o 
ON a.id = o.account_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;


-- how many accounts had more purchases than the one with t2?
-- select t1.count(*) where t1.total_purchases > t2.total_piurchases
SELECT COUNT(*)
FROM (SELECT a.name, SUM(o.total) total_purchases
     FROM accounts a 
     JOIN orders o 
     ON a.id = o.account_id
     GROUP BY 1) as t1
WHERE t1.total_purchases > (SELECT total_purchases FROM
       (SELECT a.name, SUM(o.standard_qty) total_standard_qty, SUM(o.total) total_purchases
          FROM accounts a 
          JOIN orders o 
          ON a.id = o.account_id
          GROUP BY 1
          ORDER BY 2 DESC
          LIMIT 1) as t2);
               

-- 9.4 For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, 
-- how many web_events did they have for each channel?
SELECT a.name, w.channel, COUNT(*)
FROM web_events w
JOIN accounts a 
ON a.id = w.account_id
WHERE a.name = (SELECT customer_name FROM(
                                   SELECT a.name customer_name, SUM(o.total_amt_usd) total_spent
                                   FROM accounts a 
                                   JOIN orders o
                                   ON a.id = o.account_id
                                   JOIN web_events w
                                   ON w.account_id = a.id
                                   GROUP BY 1
                                   ORDER BY 2 DESC
                                   LIMIT 1) as t1)
GROUP BY 1,2 
ORDER BY 3 DESC;

-- 9.5 What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?
SELECT AVG(total_spent)
FROM (SELECT a.name customer_name, SUM(o.total_amt_usd) total_spent
     FROM accounts a 
     JOIN orders o
     ON a.id = o.account_id
     GROUP BY 1
     ORDER BY 2 DESC
     LIMIT 10) as sub

-- 9.6 What is the lifetime average amount spent in terms of total_amt_usd, 
-- including only the companies that spent more per order, on average, than the average of all orders.

--t1: avg spent per order of each company 
SELECT a.name, SUM(o.total_amt_usd) / COUNT(o.id) avg_spent
FROM accounts a 
JOIN orders o
ON a.id = o.account_id
GROUP BY 1
ORDER BY 2 DESC 

--t2 avg spent on each order
SELECT AVG(o.total_amt_usd)
FROM orders o 

-- select companies from t1 where t1.avg_spent > t2
SELECT AVG(avg_spent)
     FROM (SELECT a.name, SUM(o.total_amt_usd) / COUNT(o.id) avg_spent
     FROM accounts a 
     JOIN orders o
     ON a.id = o.account_id
     GROUP BY 1
     HAVING SUM(o.total_amt_usd) / COUNT(o.id) > 
          (SELECT AVG(o.total_amt_usd) FROM orders o)) as sub

-- 13.quiz
-- 13.1 Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.
WITH sales_region_amt AS (
SELECT s.name sales_rep, r.name region, SUM(o.total_amt_usd) total_sales
FROM sales_reps s 
JOIN region r
ON s.region_id = r.id
JOIN accounts a 
ON s.id = a.sales_rep_id
JOIN orders o
ON o.account_id = a.id 
GROUP BY 1, 2),

region_max_sale AS 
(SELECT region, MAX(total_sales)
FROM sales_region_amt
GROUP BY 1) 

SELECT srm.sales_rep, rms.region, rms.max
FROM sales_region_amt srm
JOIN region_max_sale rms
ON srm.total_sales = rms.max

-- 13.2 For the region with the largest sales total_amt_usd, how many total orders were placed?
SELECT r.name, SUM(total_amt_usd) total_sales, COUNT(*) total_orders
FROM region r 
JOIN sales_reps s 
ON r.id = s.region_id
JOIN accounts a 
ON a.sales_rep_id = s.id 
JOIN orders o 
ON o.account_id = a.id 
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1

--13.3 How many accounts had more total purchases than 
--the account name which has bought the most standard_qty paper throughout their lifetime as a customer?
WITH most_standard_buyer AS 
     (SELECT a.name, SUM(standard_qty) total_standard_qty, SUM(total) total_qty
     FROM accounts a
     JOIN orders o 
     ON a.id = o.account_id
     GROUP BY 1
     ORDER BY 2 DESC
     LIMIT 1),

     total_qty_per_accout AS 
     (SELECT a.name, SUM(total) total_qty
     FROM accounts a 
     JOIN orders o 
     ON a.id = o.account_id
     GROUP BY 1)

SELECT COUNT(*)
FROM total_qty_per_accout
WHERE total_qty > (SELECT total_qty FROM most_standard_buyer)


--13.4 For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events did they have for each channel?
WITH top_customer AS
(SELECT a.id, a.name, SUM(total_amt_usd) total_spent
FROM accounts a 
JOIN orders o 
ON a.id = o.account_id
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 1)

SELECT t.name, w.channel, COUNT(*) event_count
FROM top_customer t 
JOIN web_events w 
ON t.id = w.account_id
GROUP BY 1, 2

--13.5 What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?
WITH top10_customer AS
(SELECT a.id, a.name, SUM(total_amt_usd) total_spent
FROM accounts a 
JOIN orders o 
ON a.id = o.account_id
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 10)

SELECT AVG(total_spent)
FROM top10_customer

--13.6 What is the lifetime average amount spent in terms of total_amt_usd, 
--including only the companies that spent more per order, on average, 
--than the average of all orders.

WITH company_avg_spent AS 
     (SELECT a.id, a.name, AVG(total_amt_usd) avg_spent
     FROM accounts a 
     JOIN orders o 
     ON a.id = o.account_id
     GROUP BY 1, 2)

SELECT AVG(avg_spent)
FROM company_avg_spent
WHERE avg_spent > (SELECT AVG(total_amt_usd) FROM orders)

