-- Creating the Database
CREATE database swiggy;

USE swiggy;
DROP TABLE IF EXISTS swigg;
CREATE table swigg (
					          State VARCHAR(150),
                    City VARCHAR(150),
                    Order_Date DATE,
                    Restaurant_Name VARCHAR(150), 
                    Location VARCHAR(150),
                    Category VARCHAR(150),
                    Dish_Name VARCHAR(150),
                    Price_INR DECIMAL (5,2) ,
                    Rating DECIMAL (3,2),
                    Rating_Count INT
					);
ALTER TABLE swigg
MODIFY Price_INR DECIMAL (8,2);
ALTER TABLE swigg
MODIFY Dish_Name VARCHAR(300);

TRUNCATE table Swigg;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/swiggy_data.csv'
INTO TABLE swigg
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(State, City, Order_Date, Restaurant_Name, Location, Category, Dish_Name, Price_INR, Rating, Rating_Count);



-- DATA VALIDATION AND CLEANING

SELECT * from swigg
WHERE Location IS Null;

SELECT 
    SUM(CASE WHEN state IS NULL THEN 1 ELSE 0 END) AS null_state,
    SUM( CASE WHEN location IS NULL THEN 1 ELSE 0 END) AS null_location,
    SUM( CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM( CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS null_rating
    FROM swigg;
    
-- Detect fields containing blank values that may cause inaccurate analysis.
SELECT *
FROM swigg
WHERE state='' OR city ='' OR Restaurant_name='';


-- Find duplicate rows using grouping on all business-critical columns.
SELECT State ,City, Order_Date ,Restaurant_Name,Location ,Category,Dish_Name, Price_INR ,Rating ,Rating_Count, COUNT(*) AS CNT FROM swigg
GROUP BY State ,City, Order_Date ,Restaurant_Name,Location ,Category,Dish_Name, Price_INR ,Rating ,Rating_Count
HAVING COUNT(*)>1;

-- Delete Duplicates
-- WITH CTE AS (
-- 	SELECT *,row_number()
--     OVER(PARTITION BY State ,City, Order_Date ,Restaurant_Name,Location ,Category,Dish_Name, Price_INR ,Rating ,Rating_Count  ORDER BY (SELECT NULL))
--     AS rn
-- from swigg
SET SQL_SAFE_UPDATES = 1;
ALTER TABLE swigg
ADD COLUMN row_id BIGINT AUTO_INCREMENT PRIMARY KEY;

-- DELETE FROM CTE WHERE rn>1
DELETE FROM swigg
WHERE row_id IN (SELECT row_id
FROM (
SELECT row_id, ROW_NUMBER() OVER (
							PARTITION BY State ,City, Order_Date ,Restaurant_Name,Location ,Category,Dish_Name, Price_INR ,Rating ,Rating_Count 
                            order by order_date ) AS rn
from swigg
)t
WHERE rn>1);

-- Using CTE
WITH missing_ratings AS (
    SELECT *
    FROM swigg
    WHERE Rating IS NULL OR Rating_Count IS NULL
)
SELECT *
FROM missing_ratings;
