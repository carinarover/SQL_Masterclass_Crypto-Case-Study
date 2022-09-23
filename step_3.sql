-- Step 3 - Daily Prices (data exploration)
SELECT * FROM trading.prices LIMIT 5;
-- Example Bitcoin price data:
SELECT * FROM trading.prices WHERE ticker = 'BTC' LIMIT 5;
-- Example Ethereum price data:
SELECT * FROM trading.prices WHERE ticker = 'ETH' LIMIT 5;

-- Question 1: How many total records do we have in the trading.prices table?
SELECT COUNT(*) FROM trading.prices;
-- or
SELECT COUNT(*) AS total_records
FROM trading.prices;

-- Question 2: How many records are there per ticker value?
SELECT ticker,
COUNT(*) AS records_ticket
FROM trading.prices
GROUP BY ticker;

-- Question 3: What is the minimum and maximum market_date values?
SELECT
  MIN(market_date) AS min_date,
  MAX(market_date) AS max_date
FROM trading.prices;

-- Question 4: Are there differences in the minimum and maximum market_date values for each ticker?
SELECT
  ticker,
  MIN(market_date) AS min_date,
  MAX(market_date) AS max_date
FROM trading.prices
GROUP BY ticker;

-- Question 5: What is the average of the price column for Bitcoin records during the year 2020?
SELECT AVG(price) 
FROM trading.prices
WHERE ticker = 'BTC' AND market_date BETWEEN '2020-01-01' AND '2020-12-31';

-- Question 6: What is the monthly average of the price column for Ethereum in 2020? Sort the output in chronological order and also round the 
-- average price value to 2 decimal places
SELECT
  EXTRACT(MONTH FROM, market_date) AS month_start,
  ROUND(AVG(price)::NUMERIC, 2) AS average_eth_price
FROM trading.prices
WHERE EXTRACT(YEAR FROM market_date) = 2020
  AND ticker = 'ETH'
GROUP BY month_start
ORDER BY month_start;

SELECT EXTRACT(MONTH FROM market_date) AS month_start,
ROUND(AVG(price), 2) AS average_eth_price 
FROM trading.prices
WHERE EXTRACT(YEAR FROM market_date) = 2020
  AND ticker = 'ETH'
GROUP BY month_start
ORDER BY month_start;

-- PostgreSQL
SELECT
  DATE_TRUNC('MON', market_date) AS month_start,
  -- need to cast approx. floats to exact numeric types for round!
  ROUND(AVG(price)::NUMERIC, 2) AS average_eth_price
FROM trading.prices
WHERE EXTRACT(YEAR FROM market_date) = 2020
  AND ticker = 'ETH'
GROUP BY month_start
ORDER BY month_start;

-- Question 7: Are there any duplicate market_date values for any ticker value in our table?
SELECT ticker,
  COUNT(market_date) AS total_count,
  COUNT(DISTINCT market_date) AS unique_count
FROM trading.prices
GROUP BY ticker;

-- Question 8: How many days from the trading.prices table exist where the high price of Bitcoin is over $30,000?
SELECT COUNT(*) AS row_count
FROM trading.prices
WHERE ticker = 'BTC' AND high > 30000;

-- Question 9: How many "breakout" days were there in 2020 where the price column is greater than the open column for each ticker?
SELECT ticker,
  SUM(CASE WHEN price > open THEN 1 ELSE 0 END) AS breakout_days
FROM trading.prices
WHERE EXTRACT(YEAR FROM market_date) = '2020-01-01'
GROUP BY ticker;
-- PostgreSQL
SELECT
  ticker,
  SUM(CASE WHEN price > open THEN 1 ELSE 0 END) AS breakout_days
FROM trading.prices
WHERE DATE_TRUNC('YEAR', market_date) = '2020-01-01'
GROUP BY ticker;

-- Question 10: How many "non_breakout" days were there in 2020 where the price column is less than the open column for each ticker?
SELECT ticker,
  SUM(CASE WHEN price < open THEN 1 ELSE 0 END) AS non_breakout_days
FROM trading.prices
WHERE EXTRACT(YEAR FROM market_date) = '2020-01-01'
GROUP BY ticker;
-- or
SELECT
  ticker,
  SUM(CASE WHEN price < open THEN 1 ELSE 0 END) AS non_breakout_days
FROM trading.prices
-- this another way to specify the year
WHERE market_date >= '2020-01-01' AND market_date <= '2020-12-31'
GROUP BY ticker;

-- Question 11: What percentage of days in 2020 were breakout days vs non-breakout days? Round the percentages to 2 decimal places
SELECT ticker,
  ROUND(SUM(CASE WHEN price > open THEN 1 ELSE 0 END) / COUNT(*), 2) AS breakout_percentage,
  ROUND(SUM(CASE WHEN price < open THEN 1 ELSE 0 END) / COUNT(*), 2) AS non_breakout_percentage
FROM trading.prices
WHERE market_date >= '2020-01-01' AND market_date <= '2020-12-31'
GROUP BY ticker;
-- PostgreSQL
SELECT
  ticker,
  ROUND(
    SUM(CASE WHEN price > open THEN 1 ELSE 0 END)
      / COUNT(*)::NUMERIC,
    2
  ) AS breakout_percentage,
  ROUND(
    SUM(CASE WHEN price < open THEN 1 ELSE 0 END)
      / COUNT(*)::NUMERIC,
    2
  ) AS non_breakout_percentage
FROM trading.prices
WHERE market_date >= '2020-01-01' AND market_date <= '2020-12-31'
GROUP BY ticker;