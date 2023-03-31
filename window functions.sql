-- 3. quiz
-- create a running total of standard_amt_usd (in the orders table) over order time with no date truncation. 
select standard_amt_usd, occurred_at, sum(standard_amt_usd) over (order by occurred_at) running_total
from orders

-- 5. quiz
-- Still create a running total of standard_amt_usd (in the orders table) over order time, 
-- but this time, date truncate occurred_at by year and partition by that same year-truncated occurred_at variabl.e
select standard_amt_usd,
	   date_trunc('year', occurred_at),
       sum(standard_amt_usd) over (partition by date_trunc('year', occurred_at) order by occurred_at) running_total
from orders;

-- 8. quiz
-- Select the id, account_id, and total variable from the orders table, 
-- then create a column called total_rank that ranks this total amount of paper ordered (from highest to lowest) for each account using a partition. 
select id, account_id, total, 
       rank() over (partition by account_id order by total desc) total_rank
from orders;

-- 14.quiz Aliases
SELECT id,
       account_id,
       DATE_TRUNC('year',occurred_at) AS year,
       DENSE_RANK() OVER main_window AS dense_rank,
       total_amt_usd,
       SUM(total_amt_usd) OVER main_window AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER main_window AS count_total_amt_usd,
       AVG(total_amt_usd) OVER main_window AS avg_total_amt_usd,
       MIN(total_amt_usd) OVER main_window AS min_total_amt_usd,
       MAX(total_amt_usd) OVER main_window AS max_total_amt_usd
FROM orders
WINDOW main_window AS (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at));

-- 17. quiz
-- determine how the current order's total revenue ("total" meaning from sales of all types of paper)
--  compares to the next order's total revenue.
--  In your query results, there should be four columns: occurred_at, total_amt_usd, lead, and lead_difference.
Select occurred_at, total_amt_usd, lead(total_amt_usd) over (order by occurred_at) lead, 
       lead(total_amt_usd) over (order by occurred_at) - total_amt_usd lead_difference
from orders;

-- 21. quiz percentiles
-- 21.1 Use the NTILE functionality to divide the accounts into 4 levels 
-- in terms of the amount of standard_qty for their orders. 
-- Your resulting table should have the account_id, the occurred_at time for each order, 
-- the total amount of standard_qty paper purchased, and one of four levels in a standard_quartile column.
-- my answer:
select account_id, occurred_at, 
    sum(standard_qty) over (partition by account_id order by occurred_at) sum_standard_qty,
    ntile(4) over (order by standard_qty) standard_quartile
from orders
order by account_id;

-- correct answer:
select account_id, occurred_at, standard_qty, 
    ntile(4) over (partition by account_id order by standard_qty) standard_quartile
from orders;


-- 22.2 Use the NTILE functionality to divide the accounts into two levels in terms of the amount of gloss_qty for their orders. 
-- Your resulting table should have the account_id, the occurred_at time for each order,
--  the total amount of gloss_qty paper purchased, and one of two levels in a gloss_half column.
-- my answer:
select account_id, occurred_at,
	   sum(gloss_qty) over (partition by account_id order by occurred_at) total_gloss_qty,
       ntile(2) over (order by gloss_qty) gloss_half
from orders
order by account_id;
-- correct answer:
SELECT account_id,
       occurred_at,
       standard_qty,
       NTILE(4) OVER (PARTITION BY account_id ORDER BY standard_qty) AS standard_quartile
  FROM orders 
 ORDER BY account_id DESC

-- 23.3 Use the NTILE functionality to divide the orders for each account into 100 levels in terms of the amount of total_amt_usd for their orders.
--  Your resulting table should have the account_id, the occurred_at time for each order,
--  the total amount of total_amt_usd paper purchased, and one of 100 levels in a total_percentile column.
-- my answer:
select account_id, occurred_at, 
	sum(total_amt_usd) over (partition by account_id order by occurred_at) sum_amt_usd,
    ntile(100) over (partition by account_id order by total_amt_usd) total_percentile
from orders
order by account_id;

-- correct answer:
SELECT
       account_id,
       occurred_at,
       total_amt_usd,
       NTILE(100) OVER (PARTITION BY account_id ORDER BY total_amt_usd) AS total_percentile
  FROM orders 
 ORDER BY account_id DESC