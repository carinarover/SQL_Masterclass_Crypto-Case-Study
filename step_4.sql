-- Step 4 - Transactions Table (data exploration)
-- In our third trading.transactions database table we have each BUY or SELL transaction for a specific ticker performed by each member
-- You can inspect the most recent 10 transactions by member_id = 'c4ca42'
SELECT * FROM trading.transactions
WHERE member_id = 'c4ca42'
ORDER BY txn_time DESC
LIMIT 10;