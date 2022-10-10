-- Step 2 - Exploring The Members Data (data exploration)
-- We can see that there are 3 columns and 14 rows in this dataset:
SELECT * FROM trading.members;

-- Question 1: Show only the top 5 rows from the trading.members table
SELECT * FROM trading.members LIMIT 5;

-- Question 2: Sort all the rows in the table by first_name in alphabetical order and show the top 3 rows
SELECT * FROM trading.members
ORDER BY first_name
LIMIT 3;

-- Question 3: Which records from trading.members are from the United States region?
SELECT * FROM trading.members
WHERE region = 'United States';

-- Question 4: Select only the member_id and first_name columns for members who are not from Australia
SELECT member_id, first_name FROM trading.members
WHERE region != 'Australia';

-- Question 5: Return the unique region values from the trading.members table and sort the output by reverse alphabetical order
SELECT DISTINCT region FROM trading.members
ORDER BY region DESC;

-- Question 6: How many mentors are there from Australia or the United States?
SELECT COUNT(*) AS mentor_count
FROM trading.members
WHERE region IN ('Australia', 'United States');

-- Question 7: How many mentors are not from Australia or the United States?
SELECT COUNT(*) AS mentor_count
FROM trading.members
WHERE region NOT IN ('Australia', 'United States');

-- Question 8: How many mentors are there per region? Sort the output by regions with the most mentors to the least
SELECT region, COUNT(*) AS mentor_count
FROM trading.members
GROUP BY region
ORDER BY mentor_count DESC;

-- Question 9: How many US mentors and non US mentors are there?
SELECT CASE
    WHEN region != 'United States' THEN 'Non US'
    ELSE region
  END AS mentor_region,
  COUNT(*) AS mentor_count
FROM trading.members
GROUP BY mentor_region
ORDER BY mentor_count DESC;

-- Question 10: How many mentors have a first name starting with a letter before 'E'?
SELECT COUNT(*) AS mentor_count
FROM trading.members
WHERE LEFT(first_name, 1) < 'E';

-- Best practice is to always apply WHERE filters on specific partitions where possible to narrow down the amount of data that must be 
-- scanned - reducing your query costs and speeding up your query execution!
-- != or <> for "not equals" You can use both != or <> in WHERE filters to exclude records.
