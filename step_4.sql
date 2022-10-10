-- Step 4 - Transactions Table (data exploration)
-- In our third trading.transactions database table we have each BUY or SELL transaction for a specific ticker performed by each member
-- You can inspect the most recent 10 transactions by member_id = 'c4ca42'
SELECT * FROM trading.transactions
WHERE member_id = 'c4ca42'
ORDER BY txn_time DESC
LIMIT 10;

-- Data Dictionary
CREATE TABLE dictionary_transactions(
Name VARCHAR(30),
Description VARCHAR(60)
);

INSERT INTO dictionary_transactions VALUES
('txn_id', 'unique ID for each transaction'),
('member_id', 'member identifier for each trade'),
('ticker', 'the ticker for each trade'),
('txn_date', 'the date for each transaction'),
('txn_type', 'either BUY or SELL'),
('quantity', 'the total quantity for each trade'),
('percentage_fee', '% of total amount charged as fees'),
('txn_time', 'the timestamp for each trade');

SELECT * from dictionary_transactions;

-- Question 1: How many records are there in the trading.transactions table?
SELECT COUNT(*) FROM trading.transactions;

-- Question 2: How many unique transactions are there?
SELECT COUNT(DISTINCT txn_id) FROM trading.transactions;

-- Question 3: How many buy and sell transactions are there for Bitcoin?
SELECT txn_type,
  COUNT(*) AS transaction_count
FROM trading.transactions
WHERE ticker = 'BTC'
GROUP BY txn_type;

-- Question 4: For each year, calculate the following buy and sell metrics for Bitcoin:
-- total transaction count
-- total quantity
-- average quantity per transaction
-- Also round the quantity columns to 2 decimal places.
SELECT 
  EXTRACT(YEAR FROM txn_date) AS txn_year,
  txn_type,
  COUNT(*) AS transaction_count,
  ROUND(SUM(quantity), 2) AS total_quantity,
  ROUND(AVG(quantity), 2) AS average_quantity
FROM trading.transactions
WHERE ticker = 'BTC'
GROUP BY txn_year, txn_type
ORDER BY txn_year, txn_type;

-- Question 5: What was the monthly total quantity purchased and sold for Ethereum in 2020?
SELECT 
  EXTRACT(MONTH FROM txn_date) AS month_calendar,
  SUM(CASE WHEN txn_type = 'BUY' THEN quantity ELSE 0 END) AS buy_quantity,
  SUM(CASE WHEN txn_type = 'SELL' THEN quantity ELSE 0 END) AS sell_quantity
FROM trading.transactions
WHERE txn_date BETWEEN '2020-01-01' AND '2020-12-31'
  AND ticker = 'ETH'
GROUP BY month_calendar;

-- Question 6: Summarise all buy and sell transactions for each member_id by generating 1 row 
-- for each member with the following additional columns:
-- Bitcoin buy quantity
-- Bitcoin sell quantity
-- Ethereum buy quantity
-- Ethereum sell quantity
SELECT 
  member_id,
  SUM(CASE WHEN txn_type = 'BUY' AND ticker = 'BTC' THEN quantity ELSE 0 END) AS btc_buy_quant,
  SUM(CASE WHEN txn_type = 'SELL' AND ticker = 'BTC' THEN quantity ELSE 0 END) AS btc_sell_quant,
  SUM(CASE WHEN txn_type = 'BUY' AND ticker = 'ETH' THEN quantity ELSE 0 END) AS eth_buy_quant,
  SUM(CASE WHEN txn_type = 'SELL' AND ticker = 'ETH' THEN quantity ELSE 0 END) AS eth_sell_quant
FROM trading.transactions
GROUP BY member_id;

-- Question 7: What was the final quantity holding of Bitcoin for each member? Sort the output from the highest BTC holding to lowest
SELECT 
  member_id,
  SUM(CASE WHEN txn_type = 'BUY' THEN quantity 
		   WHEN txn_type = 'SELL' THEN -quantity 
           ELSE 0 END) AS final_btc_holding
FROM trading.transactions
WHERE ticker = 'BTC'
GROUP BY member_id
ORDER BY final_btc_holding DESC;

-- Question 8: Which members have sold less than 500 Bitcoin? Sort the output from the most BTC sold to least
SELECT member_id,
  SUM(quantity) AS btc_sold_quantity
FROM trading.transactions
WHERE ticker = 'BTC' AND txn_type = 'SELL'
GROUP BY member_id
HAVING SUM(quantity) < 500
ORDER BY btc_sold_quantity DESC;

-- Question 9: What is the total Bitcoin quantity for each member_id owns after adding all of the BUY and SELL transactions 
-- from the transactions table? Sort the output by descending total quantity
SELECT member_id,
  SUM(CASE 
	  WHEN txn_type = 'BUY'  THEN quantity
      WHEN txn_type = 'SELL' THEN -quantity
    END ) AS total_quantity
FROM trading.transactions
WHERE ticker = 'BTC'
GROUP BY member_id
ORDER BY total_quantity DESC;

-- Question 10: Which member_id has the highest buy to sell ratio by quantity?
SELECT member_id,
  SUM(CASE WHEN txn_type = 'BUY' THEN quantity ELSE 0 END) /
  SUM(CASE WHEN txn_type = 'SELL' THEN quantity ELSE 0 END) AS buy_to_sell_ratio
FROM trading.transactions
GROUP BY member_id
ORDER BY buy_to_sell_ratio DESC;

-- Question 11: For each member_id - which month had the highest total Ethereum quantity sold`?
WITH cte_ranked AS (
SELECT
  member_id,
  DATE_FORMAT(txn_date, '%Y-%m') AS calendar_month,
  SUM(quantity) AS sold_eth_quantity,
  RANK() OVER (PARTITION BY member_id ORDER BY SUM(quantity) DESC) AS month_rank
FROM trading.transactions
WHERE ticker = 'ETH' AND txn_type = 'SELL'
GROUP BY member_id, calendar_month
)
SELECT
  member_id,
  calendar_month,
  sold_eth_quantity
FROM cte_ranked
WHERE month_rank = 1
ORDER BY sold_eth_quantity DESC;