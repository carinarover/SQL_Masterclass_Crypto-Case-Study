-- Step 9 - Buy and Hold Analysis
-- Meet Leah - she is our mentor who will take the buy and hold strategy otherwise known as the "HODL strategy" or hold on for dear life!
-- She is risk averse and just wants to leave her initial investment alone because she believes her original holdings will grow over time with low risk.

-- Leah's Transaction History
--  1. She purchases 50 BTC and 50 ETH on Jan 1st 2017
--  2. She holds onto all of her portfolio and does not sell anything (HODL)
--  3. She also does not purchase any additional quantity of either crypto
--  4. By August 29th 2021 (the last date of our price data) - we can assess her individual performance
--  Remember that we are simplifying our problem at the moment so Leah's records will actually be different in the final trading.transactions dataset!

-- The Data: For this simplified scenario - we first need to create a new temp table called leah_hodl_strategy using the code below:
CREATE TABLE leah_hodl_strategy AS
SELECT * FROM trading.transactions
WHERE member_id = 'c20ad4'
AND txn_date = '2017-01-01'
AND quantity = 50;

SELECT * FROM leah_hodl_strategy;

-- Required Metrics: For this basic scenario - we wish to calculate the following metrics:
-- 1. The initial value of her original 50 BTC and 50 ETH purchases
-- 2. The dollar amount of fees she paid for those 2 transactions
-- 3. The final value of her portfolio on August 29th 2021
-- 4. The profitability by dividing her final value by initial value

-- Question 1 & 2
-- We can calculate the first 2 questions using a single query
-- 1. The initial value of her original 50 BTC and 50 ETH purchases
-- 2. The dollar amount of fees she paid for those 2 transactions
SELECT
  SUM(transactions.quantity * prices.price) AS initial_value,
  SUM(transactions.quantity * prices.price * transactions.percentage_fee / 100) AS fees
FROM leah_hodl_strategy AS transactions
INNER JOIN trading.prices
  ON transactions.ticker = prices.ticker
  AND transactions.txn_date = prices.market_date;
  
-- Question 3: The final value of her portfolio on August 29th 2021
SELECT
  SUM(transactions.quantity * prices.price) AS final_value
FROM leah_hodl_strategy AS transactions
INNER JOIN trading.prices
  ON transactions.ticker = prices.ticker
WHERE prices.market_date = '2021-08-29';

-- Question 4: Calculate the profitability by dividing Leah's final value by initial value
WITH cte_portfolio_values AS (
  SELECT
    -- initial metrics
    SUM(transactions.quantity * initial.price) AS initial_value,
    SUM(transactions.quantity * initial.price * transactions.percentage_fee / 100) AS fees,
    -- final value
    SUM(transactions.quantity * final.price) AS final_value
  FROM leah_hodl_strategy AS transactions
  INNER JOIN trading.prices AS initial
    ON transactions.ticker = initial.ticker
    AND transactions.txn_date = initial.market_date
  INNER JOIN trading.prices AS final
    ON transactions.ticker = final.ticker
  WHERE final.market_date = '2021-08-29'
)
SELECT
  initial_value,
  fees,
  final_value,
  final_value / initial_value AS profitability
FROM cte_portfolio_values;
