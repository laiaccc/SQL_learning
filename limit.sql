''' limit '''
SELECT occurred_at, account_id, channel FROM web_events
LIMIT 15;

SELECT id, occurred_at, total_amt_usd FROM orders
ORDER BY occurred_at
LIMIT 10;

SELECT id, occurred_at, total_amt_usd FROM orders
ORDER BY total_amt_usd DESC
LIMIT 5;

SELECT id, occurred_at, total_amt_usd FROM orders
ORDER BY total_amt_usd
LIMIT 20;

''' order by'''
SELECT id, account_id, total_amt_usd FROM orders
ORDER BY account_id, total_amt_usd DESC;

SELECT id, account_id, total_amt_usd FROM orders
ORDER BY total_amt_usd DESC, account_id;

''' where '''
SELECT * FROM orders
WHERE gloss_amt_usd >= 1000
LIMIT 5;

SELECT * FROM orders
WHERE total_amt_usd < 500
LIMIT 10;

SELECT name, website, primary_poc FROM accounts
WHERE name = 'Exxon Mobil'    /*大部分sql环境单双引号都可以*/

'''as'''
SELECT id, account_id, standard_amt_usd/standard_qty AS unit_price
FROM orders
LIMIT 10;

SELECT id, account_id, poster_amt_usd / total_amt_usd AS poster_percentage
FROM orders
LIMIT 10;

'''like'''
SELECT * FROM accounts
WHERE name LIKE 'C%';  --All the companies whose names start with 'C'.

SELECT * FROM accounts
WHERE name LIKE '%one%'; --All companies whose names contain the string 'one' somewhere in the name.

SELECT * FROM accounts
WHERE name LIKE '%s'; --All companies whose names end with 's'.

'''in'''
SELECT name, primary_poc, sales_rep_id FROM accounts
WHERE name IN ('Walmart', 'Target', 'Nordstrom');

SELECT * FROM web_events
WHERE channel IN ('organic', 'adwords')

'''NOT'''
SELECT name, primary_poc, sales_rep_id FROM accounts
WHERE name NOT IN ('Walmart', 'Target', 'Nordstrom');

SELECT * FROM web_events
WHERE channel NOT IN ('organic', 'adwords');

SELECT * FROM accounts
WHERE name NOT LIKE ('C%');

SELECT * FROM accounts
WHERE name NOT LIKE ('%one%');

SELECT * FROM accounts
WHERE name NOT LIKE ('%s');

'''AND / BETWEEN'''
SELECT * FROM orders
WHERE standard_qty > 1000 AND poster_qty = 0 AND gloss_qty = 0;

SELECT * FROM accounts
WHERE name NOT LIKE 'C%' AND name NOT LIKE '%s';

SELECT occurred_at, gloss_qty FROM orders
WHERE gloss_qty BETWEEN 24 AND 29; -- BETWEEN is inclusive, so this query means WHERE gloss_qty >= 24 AND gloss_qty <= 29

'''OR'''
SELECT * FROM web_events
WHERE channel IN ('organic', 'adwords') AND occurred_at BETWEEN '2016-01-01' AND '2017-01-01'
ORDER BY occurred_at DESC;

SELECT id FROM orders
WHERE gloss_qty > 4000 OR poster_qty > 4000;

SELECT * FROM orders 
WHERE standard_qty = 0 AND (gloss_qty > 1000 OR poster_qty > 1000);

SELECT * FROM accounts 
WHERE (name LIKE 'C%' OR name LIKE 'W%')
	AND ((primary_poc LIKE '%ana%' OR primary_poc LIKE '%Ana%' )
    AND primary_poc NOT LIKE 'ena')