-- Step 6 - Planning Ahead for Data Analysis
-- Planning Ahead

-- Create a Base Table
-- First let's create a portfolio quantity base table which summarizes our data with the required data first.

-- Step 1: Create a base table that has each mentor's name, region and end of year total quantity for each ticker
DROP TABLE IF EXISTS temp_portfolio_base;
CREATE TABLE temp_portfolio_base AS
WITH cte_joined_data AS (
  SELECT
    members.first_name,
    members.region,
    transactions.txn_date,
    transactions.ticker,
    CASE
      WHEN transactions.txn_type = 'SELL' THEN -transactions.quantity
      ELSE transactions.quantity
    END AS adjusted_quantity
  FROM trading.transactions
  INNER JOIN trading.members
    ON transactions.member_id = members.member_id
  WHERE transactions.txn_date <= '2020-12-31'
)
SELECT first_name, region,
  timestamp(date '2020-12-31' + interval '12' MONTH - interval '1' DAY) AS year_end,
  ticker,
  SUM(adjusted_quantity) AS yearly_quantity
FROM cte_joined_data
GROUP BY first_name, region, year_end, ticker;

-- Step 2: Let's take a look at our base table now to see what data we have to play with - to keep things simple, let's take a look at Abe's data from our 
-- new temp table temp_portfolio_base
-- Inspect the year_end, ticker and yearly_quantity values from our new temp table temp_portfolio_base for Mentor Abe only. Sort the output with ordered BTC 
-- values followed by ETH values
SELECT year_end, ticker, yearly_quantity
FROM temp_portfolio_base
WHERE first_name = 'Abe'
ORDER BY ticker, year_end;

-- Step 3
SELECT
  year_end,
  ticker,
  yearly_quantity,
  /* this is a multi-line comment!
     for this case we don't actually need first_name
     but we include it anyway to prepare for the next query! */
  SUM(yearly_quantity) OVER (
    PARTITION BY first_name, ticker
    ORDER BY year_end
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS cumulative_quantity
FROM temp_portfolio_base
WHERE first_name = 'Abe'
ORDER BY ticker, year_end;

-- Step 4
-- add a column called cumulative_quantity
ALTER TABLE temp_portfolio_base
ADD cumulative_quantity NUMERIC;

-- update new column with data
UPDATE temp_portfolio_base
SET cumulative_quantity = (
  SELECT
      SUM(yearly_quantity) OVER (
    PARTITION BY first_name, ticker
    ORDER BY year_end
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  )
);
