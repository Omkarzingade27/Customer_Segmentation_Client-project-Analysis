show databases;
USE project_shopping_trends;
show tables;
describe shopping_trends_dataset;
describe shopping_table;
select * from shopping_table;

# Category-wise Discount Analysis
# 1) Identify the product categories where discounts should be applied. Provide your reasoning.
SELECT Category,
		COUNT(*) AS total_orders,
        AVG(Purchase_Amount_USD) AS avg_amount,
        SUM(CASE WHEN Discount_Applied = 'Yes' THEN 1 ELSE 0 END)/COUNT(*) AS discount_rate
FROM shopping_table
GROUP BY Category 
ORDER BY total_orders DESC;

# 2)	Identify card spending based on age and explore the impact of seasons and locations.
# Card Spending by Age
SELECT Age,
       SUM(Purchase_Amount_USD) AS card_spend
FROM shopping_table
WHERE Payment_Method LIKE '%Card%'
GROUP BY Age
ORDER BY Age; 

# Season & Location Impact
SELECT Season, Location,
       SUM(Purchase_Amount_USD) AS total_spend
FROM shopping_table
GROUP BY Season, Location
ORDER BY total_spend DESC;

# EDA + insights
-- 1. Count rows & columns
SELECT COUNT(*) AS total_rows FROM shopping_table;

-- 2. Column list (MySQL)
SHOW COLUMNS FROM shopping_table;

-- 3. Missing values count per column (approx)
SELECT
  SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS age_null,
  SUM(CASE WHEN Gender IS NULL THEN 1 ELSE 0 END) AS gender_null,
  SUM(CASE WHEN Purchase_Amount_USD IS NULL THEN 1 ELSE 0 END) AS amount_null,
  SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS category_null,
  SUM(CASE WHEN Discount_Applied IS NULL THEN 1 ELSE 0 END) AS discount_null
FROM shopping_table;

# 4 B. Category-level summary
SELECT
  Category,
  COUNT(*) AS tx_count,
  SUM(Purchase_Amount_USD) AS total_revenue,
  AVG(Purchase_Amount_USD) AS avg_amount,
  SUM(CASE WHEN Discount_Applied = 'Yes' THEN 1 ELSE 0 END)/COUNT(*) AS discount_rate,
  SUM(CASE WHEN Promo_Code_Used ='Yes' THEN 1 ELSE 0 END)/COUNT(*) AS promo_rate
FROM shopping_table
GROUP BY Category
ORDER BY total_revenue DESC;

# 5 C. Top N items and categories
SELECT Item_Purchased, Category,
       COUNT(*) AS tx_count,
       SUM(Purchase_Amount_USD) AS revenue
FROM shopping_table
GROUP BY Item_Purchased, Category
ORDER BY revenue DESC
LIMIT 20;

# 6 D. Discount effectiveness (compare avg amount with/without discount)
SELECT
  Discount_Applied,
  COUNT(*) AS tx_count,
  AVG(Purchase_Amount_USD) AS avg_amount,
  SUM(Purchase_Amount_USD) AS total_revenue
FROM shopping_table
GROUP BY Discount_Applied;

# 7 E. Card spending by age group (create age-bins on-the-fly)
SELECT
  CASE
    WHEN Age < 18 THEN '<18'
    WHEN Age BETWEEN 18 AND 24 THEN '18-24'
    WHEN Age BETWEEN 25 AND 34 THEN '25-34'
    WHEN Age BETWEEN 35 AND 49 THEN '35-49'
    WHEN Age BETWEEN 50 AND 64 THEN '50-64'
    ELSE '65+' END AS age_group,
  COUNT(*) AS tx_count,
  SUM(Purchase_Amount_USD) AS total_spent,
  AVG(Purchase_Amount_USD) AS avg_spent
FROM shopping_table
WHERE Payment_Method LIKE '%Card%'
GROUP BY age_group
ORDER BY age_group;

# 8 F. Season × Location pivot (top combinations)
SELECT Season, Location,
       COUNT(*) AS tx_count,
       SUM(Purchase_Amount_USD) AS total_spend
FROM shopping_table
GROUP BY Season, Location
ORDER BY total_spend DESC
LIMIT 50;

# 9 G. Per-customer aggregated summary (RFM style + promo/discount behaviour)
SELECT Customer_ID,
       COUNT(*) AS tx_count,
       SUM(Purchase_Amount_USD) AS total_spent,
       AVG(Purchase_Amount_USD) AS avg_spent,
       SUM(CASE WHEN Discount_Applied = 'Yes' THEN 1 ELSE 0 END)/COUNT(*) AS discount_rate,
       SUM(CASE WHEN Promo_Code_Used = 'Yes' THEN 1 ELSE 0 END)/COUNT(*) AS promo_rate,
       MAX(Season) AS last_known_season,
       MAX(Location) AS top_location
FROM shopping_table
GROUP BY Customer_ID;

# 10 H. Subscription impact (subscribers vs non-subscribers)
SELECT Subscription_Status,
       COUNT(*) AS tx_count,
       SUM(Purchase_Amount_USD) AS total_spend,
       AVG(Purchase_Amount_USD) AS avg_spend
FROM shopping_table
GROUP BY Subscription_Status;

# 11. I. Payment method distribution
SELECT Payment_Method,
       COUNT(*) AS tx_count,
       SUM(Purchase_Amount_USD) AS total_spend,
       AVG(Purchase_Amount_USD) AS avg_spend
FROM shopping_table
GROUP BY Payment_Method
ORDER BY tx_count DESC;

# 12 J. Export subset for Python (recommended columns)
SELECT Customer_ID, Age, Gender, Item_Purchased, Category,
       Purchase_Amount_USD, Location, Size, Color, Season,
       Review_Rating, Subscription_Status, Payment_Method, Shipping_Type,
       Discount_Applied, Promo_Code_Used, Previous_Purchases,
       Preferred_Payment_Method, Frequency_of_Purchases
FROM shopping_table
INTO OUTFILE '/var/lib/mysql-files/shopping_export.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n';












