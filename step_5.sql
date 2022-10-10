-- Step 5 - Let the Data Analysis Begin!
-- We wish to analyse our overall portfolio performance and also each member's performance based off all the data we have in our 3 tables.

-- Analyse the Ranges

-- Question 1: What is the earliest and latest date of transactions for all members?
SELECT
  MIN(txn_date) AS earliest_date,
  MAX(txn_date) AS latest_date
FROM trading.transactions;

-- Question 2: What is the range of market_date values available in the prices data?
SELECT
  MIN(market_date) AS earliest_date,
  MAX(market_date) AS latest_date
FROM trading.prices;

-- Joining our Datasets
-- Now that we now our date ranges are from January 2017 through to almost the end of August 2021 for both our prices and transactions datasets 
-- we can now get started on joining these two tables together!

-- Question 3: Which top 3 mentors have the most Bitcoin quantity as of the 29th of August?
SELECT members.first_name,
  SUM(
    CASE
      WHEN transactions.txn_type = 'BUY'  THEN transactions.quantity
      WHEN transactions.txn_type = 'SELL' THEN -transactions.quantity
    END
  ) AS total_quantity
FROM trading.transactions
INNER JOIN trading.members
  ON transactions.member_id = members.member_id
WHERE ticker = 'BTC'
GROUP BY members.first_name
ORDER BY total_quantity DESC
LIMIT 3;

-- Calculating Portfolio Value
-- Now let's combine all 3 tables together using only strictly INNER JOIN so we can utilise all of our datasets together.

-- Question 4:
-- What is total value of all Ethereum portfolios for each region at the end date of our analysis? Order the output by descending portfolio value
WITH cte_latest_price AS (
  SELECT ticker, price
  FROM trading.prices
  WHERE ticker = 'ETH'
  AND market_date = '2021-08-29'
)
SELECT members.region,
  SUM(
    CASE
      WHEN transactions.txn_type = 'BUY'  THEN transactions.quantity
      WHEN transactions.txn_type = 'SELL' THEN -transactions.quantity
    END
  ) * cte_latest_price.price AS ethereum_value,
  AVG(
    CASE
      WHEN transactions.txn_type = 'BUY'  THEN transactions.quantity
      WHEN transactions.txn_type = 'SELL' THEN -transactions.quantity
    END
  ) * cte_latest_price.price AS avg_ethereum_value
FROM trading.transactions
INNER JOIN cte_latest_price
  ON transactions.ticker = cte_latest_price.ticker
INNER JOIN trading.members
  ON transactions.member_id = members.member_id
WHERE transactions.ticker = 'ETH'
GROUP BY members.region, cte_latest_price.price
ORDER BY avg_ethereum_value DESC;

-- Question 5: What is the average value of each Ethereum portfolio in each region? Sort this output in descending order
WITH cte_latest_price AS (
  SELECT ticker, price
  FROM trading.prices
  WHERE ticker = 'ETH'
  AND market_date = '2021-08-29'
)
SELECT members.region,
  AVG(
    CASE
      WHEN transactions.txn_type = 'BUY'  THEN transactions.quantity
      WHEN transactions.txn_type = 'SELL' THEN -transactions.quantity
    END
  ) * cte_latest_price.price AS avg_ethereum_value
FROM trading.transactions
INNER JOIN cte_latest_price
  ON transactions.ticker = cte_latest_price.ticker
INNER JOIN trading.members
  ON transactions.member_id = members.member_id
WHERE transactions.ticker = 'ETH'
GROUP BY members.region, cte_latest_price.price
ORDER BY avg_ethereum_value DESC;

-- Let's try again - this time we will calculate the total sum of portfolio value and then manually divide it by the total number of mentors in each region!
WITH cte_latest_price AS (
  SELECT
    ticker,
    price
  FROM trading.prices
  WHERE ticker = 'ETH'
  AND market_date = '2021-08-29'
),
cte_calculations AS (
SELECT
  members.region,
  SUM(
    CASE
      WHEN transactions.txn_type = 'BUY'  THEN transactions.quantity
      WHEN transactions.txn_type = 'SELL' THEN -transactions.quantity
    END
  ) * cte_latest_price.price AS ethereum_value,
  COUNT(DISTINCT members.member_id) AS mentor_count
FROM trading.transactions
INNER JOIN cte_latest_price
  ON transactions.ticker = cte_latest_price.ticker
INNER JOIN trading.members
  ON transactions.member_id = members.member_id
WHERE transactions.ticker = 'ETH'
GROUP BY members.region, cte_latest_price.price
)
-- final output
SELECT
  *,
  ethereum_value / mentor_count AS avg_ethereum_value
FROM cte_calculations
ORDER BY avg_ethereum_value DESC;