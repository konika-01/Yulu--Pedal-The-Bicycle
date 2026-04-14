
use yulu;                                              -- use yulu database

select * from yulu.bike_share_yr_0;                    -- check all the data from yulu.bike_share_yr_0

select * from yulu.bike_share_yr_1;                    -- check all the data from yulu.bike_share_yr_1

DESCRIBE yulu.bike_share_yr_0;                         -- check columns and dataype from yulu.bike_share_yr_0

DESCRIBE yulu.bike_share_yr_1;                         -- check columns and dataype from yulu.bike_share_yr_1
-- OR 
SHOW COLUMNS FROM yulu.bike_share_yr_0;                -- check columns from yulu.bike_share_yr_0
SHOW COLUMNS FROM yulu.bike_share_yr_1;                -- check columns from yulu.bike_share_yr_1

-- creating a stored procedure :
DROP PROCEDURE IF EXISTS yulushare_2021;               -- Dropping if any previous stored procedure of similar name created.
SHOW PROCEDURE STATUS LIKE 'yulushare_2021';           -- checking the status of stored procedure


SELECT COUNT(*) AS null_count                          -- Check for NULL values in yulu.bike_share_yr_1
FROM yulu.bike_share_yr_1
WHERE dteday IS NULL
   OR season IS NULL
   OR yr IS NULL
   OR mnth IS NULL
   OR hr IS NULL
   OR holiday IS NULL
   OR weekday IS NULL
   OR workingday IS NULL
   OR weathersit IS NULL
   OR temp IS NULL
   OR atemp IS NULL
   OR hum IS NULL
   OR windspeed IS NULL
   OR rider_type IS NULL
   OR riders IS NULL;
    
CREATE TABLE yulu.cost (                              -- creating a new cost Table
    yr INT PRIMARY KEY NOT NULL,                      -- primary key and Not null are the constraints
    price DECIMAL(10, 2) NOT NULL,            
    COGS DECIMAL(10, 2) NOT NULL);
    
 /*Constraints are rules applied to table columns 
 to enforce data integrity and consistency.*/

insert into cost(yr,price, COGS)                      -- insert the values to new table named "cost"
values (0,3.99,1.24),                                 -- COGS stands for cost of Goods sold.
    	(1,4.99,1.56);
        
select * from yulu.cost;                              -- check the details of the cost table after inserting values to it.

DESCRIBE yulu.cost;                                   -- check datatypes of cost table



/* DELIMITER changes the statement delimiter in SQL
 to define complex commands like triggers or procedures.*/
 
 
 
DELIMITER $$                                        -- creating stored procedure to avoid repetitive task.
create procedure yulushare_2021 ()                  -- Delimiter supported by MYSQL workbench &&,//,$$
BEGIN
SELECT * FROM yulu.bike_share_yr_0;
END$$
DELIMITER ;                                         -- END with default Delimiter(;) to avoid confusion.

call yulushare_2021()                               -- check new created stored procedure by calling it.

DELIMITER //                                        -- using // Delimiter to avoid confusion
CREATE PROCEDURE yulushare_2022 ()
BEGIN
    SELECT * FROM yulu.bike_share_yr_1;
END//
DELIMITER ;                                         -- complete stored procedure syntax with default Delimiter(;)

call yulushare_2022();                              -- check new created stored procedure by calling it.


DELIMITER &&                                        -- creating stored procedure for cost table. 
CREATE PROCEDURE cost ()
BEGIN
    SELECT * FROM yulu.cost;
END&&                                               -- using $$ delimiter to avoid confusion
DELIMITER ;                                         -- Ending with default(;) Delimiter
call cost();                                        --  calling stored procedure cost.

-- creating a Backup Table with DELETE Trigger :

create table backup_yulushare_2021 
AS select * from yulu.bike_share_yr_0 where 1=0; 


     /* condition 1=0 will make a copy 
     of the original Table, without any values
	 with same structure and data types*/

create table backup_yulushare_2022 AS 
select * from yulu.bike_share_yr_1 where 1=0;

-- Creating a Delete Trigger for yulu.bike_share_yr_0

DELIMITER $$ 
CREATE TRIGGER before_delete_bike_share_year_0              -- we have two options Create/Replace to start syntax of Trigger.
BEFORE DELETE ON yulu.bike_share_yr_0                       -- This ensure before Delete event occurs if saves data in backup Table.
FOR EACH ROW                                                -- stored procedure are of two types rows and columns
BEGIN                                                       -- we are using Row wise stored Procedure
    INSERT INTO backup_yulushare_2021
    VALUES (OLD.yr, OLD.workingday, OLD.windspeed, OLD.weekday, OLD.weathersit, 
    OLD.temp, OLD.season, OLD.mnth, OLD.hum, OLD.hr, OLD.holiday, OLD.dteday, OLD.atemp);
    
END $$                                                      -- using && Delimiter to avoid confusion
DELIMITER ;                                                 -- using Default(;) delimiter to complete syntax.


-- Trigger for bike_share_year_1

DELIMITER $$                                                 -- using $$ Delimiter to avoid confusion.
CREATE TRIGGER before_delete_bike_share_year_1               -- Deleted data stored before Delete event occurs
BEFORE DELETE ON yulu.bike_share_yr_1
FOR EACH ROW                                                 -- Row wise Trigger
BEGIN
    INSERT INTO backup_yulushare_2022                        -- Before Delete event oocurs, deleted data will be stored in backup_yulu_share_2022
    VALUES (OLD.weekday, OLD.workingday, OLD.weathersit, 
    OLD.temp, OLD.atemp, OLD.hum, OLD.windspeed, OLD.rider_type, OLD.riders);
END$$                                                        -- using $$ delimiter to complete syntax.
											

-- Data Cleaning steps :

-- checking for duplicates 

SELECT yr, workingday, windspeed, weekday, weathersit, temp, season, riders,
 rider_type, mnth, hum, hr, holiday, dteday, atemp,
    COUNT(*) AS count
FROM bike_share_yr_0
GROUP BY yr, workingday, windspeed, weekday, weathersit, temp, season, riders, 
rider_type, mnth, hum, hr, holiday, dteday, atemp
HAVING COUNT(*) > 1;                                        
-- Results shows There are NO duplicates.

SHOW COLUMNS FROM yulu.bike_share_yr_0;                       -- check the columns names of the data

-- check for missing values.

select sum( Case when yr IS NULL then 1 else 0 END) AS missing_year,
	   sum( Case when workingday IS NULL then 1 else 0 END )  AS missing_workingday,
       sum( Case when windspeed IS NULL then 1 else 0 END) as missing_windspeed,
       sum( Case when weekday IS NULL then 1 else 0 END) AS missing_weekday,
       sum( Case when weathersit IS NULL then 1 else 0 end) AS missing_weathersit,
       sum( Case when temp IS NULL then 1 else 0 END ) as missing_temp,
       sum( Case when season IS NULL then 1 else 0 END ) AS missing_season,
       sum( Case when riders IS NULL then 1 else 0 END ) AS missing_riders,
       sum( Case when rider_type IS NULL then 1 else 0 END) AS missing_ridertype,
       sum( Case when mnth IS NULL then 1 ELSE 0 END) AS missing_mnth,
       sum( Case when hum IS Null then 1 else 0 END ) AS missing_hum,
       sum( Case when hr IS NULL then 1 else 0 END ) AS missinghr,
       sum( Case when holiday IS NULL then 1 else 0 END) AS mssing_holiday,
       sum( Case when dteday IS NULL then 1 else 0 END ) AS missing_dteday,
       sum( Case when atemp IS NULL then 1 else 0 END) AS missing_atemp from yulu.bike_share_yr_0;

-- Results shows There are No Missing Values.

-- Standarization Convert dteday from 'YYYY-MM-DD' text to DATE type

call yulushare_2021()                                       -- calling stored procedure to validate data.
SET SQL_SAFE_UPDATES = 0;                                   -- disable safe mode so that we can make changes.

ALTER TABLE bike_share_yr_0 ADD COLUMN dteday_date DATE;    -- Adding new DATE column 

UPDATE bike_share_yr_0 -- updating it
SET dteday_date = STR_TO_DATE(dteday, '%d-%m-%Y');          -- converting into standarize date format of year-month-day

ALTER TABLE bike_share_yr_0 DROP COLUMN dteday;             -- removing old date column

CALL yulushare_2021();                                      -- calling stored procedure to validate Data.

Alter table  bike_share_yr_0 
change column dteday_date dteday DATE;                      -- Rename the column


-- Normalize Text Datatype column "Rider_Type" by converting all rider_type values to lowercase
call yulushare_2021()                                       -- call stored procedure to validate normalized data.


-- Convert all rider_type values to lowercase
UPDATE bike_share_yr_0
SET rider_type = LOWER(rider_type);                         -- Updating values to lowercase



-- TRIM WHITESPACES
update yulu.bike_share_yr_0                                -- remove any extra space using Trim Function.
set rider_type=trim(rider_type);

-- TRIM is a function in SQL that removes leading and trailing spaces or specified characters from a string.


SET sql_safe_updates = 1;                                  -- Enable safe mode again 


-- Cleaning data for yulu_bike_share_yr_1, same steps to be followed.


SHOW COLUMNS FROM yulu.bike_share_yr_1;                     -- check columns for yulu.bike_share_yr_1


describe yulu.bike_share_yr_1;                              -- check columns and data type for yulu.bike_share_yr_1


-- check for missing values.

SELECT *
FROM yulu.bike_share_yr_1
WHERE yr IS NULL OR workingday IS NULL OR windspeed IS NULL OR weekday IS NULL OR weathersit IS NULL
   OR temp IS NULL OR season IS NULL OR riders IS NULL OR rider_type IS NULL OR mnth IS NULL
   OR hum IS NULL OR hr IS NULL OR holiday IS NULL OR dteday IS NULL OR atemp IS NULL;
       
-- Result shows that there are no missing value from yulu.bike_share_yr_2


-- checking for duplicates 

SELECT yr, workingday, windspeed,weekday, weathersit,temp, season, riders, rider_type,
 mnth, hum, hr, holiday, dteday, atemp,
COUNT(*) AS count FROM bike_share_yr_1
GROUP BY yr, workingday, windspeed, weekday, weathersit, temp,
 season, riders, rider_type, mnth, hum, hr, holiday, dteday, atemp
HAVING COUNT(*) > 1;

-- Results shows that there are no duplicates.

describe  yulu.bike_share_yr_1      
/* after checking data type 
we found date column is in text,
we will standardize convert into DATE datatype */


set sql_safe_updates=0;                                  -- Disable safe mode to make changes in the Table.
 
-- Convert DD-MM-YYYY to YYYY-MM-DD AS YYY-MM-DD is the standard date format for mysqlworkbench.

UPDATE yulu.bike_share_yr_1                              -- updating Date column to standard form.
SET dteday = Str_to_date(dteday, '%d-%m-%Y');            -- using str_to_date to standarize date format

/*STR_TO_DATE function in MySQL converts a string representation
 of a date into a DATE data type, according to a specified format.*/

ALTER TABLE yulu.bike_share_yr_1                         -- changing datatype of column dteday from text to DATE          
MODIFY dteday DATE;

describe  yulu.bike_share_yr_1 ;                         --  validate datatype change is made for dteday column
call yulushare_2022                                      --  calling stored procedure to check format of date column

update yulu.bike_share_yr_1                              --  remove whitespaces and standarize column by converting it to lowercase
set rider_type= lower(trim(rider_type));

SELECT DISTINCT rider_type                               --  Validate the data 
FROM yulu.bike_share_yr_1;

SET sql_safe_updates = 1;                                -- Enable safe mode again 

-- Step 1 :-- Merging data 

CREATE TEMPORARY TABLE yulu.BikeShare AS                  -- creating Temporary Table 
SELECT 
    season, yr, mnth, hr, holiday, weekday, workingday, weathersit, temp, atemp, hum, windspeed, 
    rider_type, riders, dteday
FROM yulu.bike_share_yr_0
UNION ALL                                                 -- using union ALL since there are no duplicates.
SELECT                                                    -- if there are duplicates we use Union to elimate such values
    season, yr, mnth, hr, holiday, weekday, 
    workingday, weathersit, temp, atemp, 
    hum, windspeed, rider_type,
    riders, dteday
FROM yulu.bike_share_yr_1;
select * from yulu.BikeShare;                            -- Temporary Table is Made.


-- Step 2: Join the combined data with the cost table and make a permanent table for Data Analysis

CREATE TABLE yulu.yuluData AS                              -- creating a permanent Table for Data Analysis
SELECT 
    b.season, b.yr, b.mnth, b.hr,
    b.holiday, b.weekday, b.workingday,
    b.weathersit, b.temp, b.atemp, b.hum,
    b.windspeed, b.rider_type, b.riders,
    b.dteday, c.price, c.COGS
FROM yulu.BikeShare b                                      -- We take Alias b for Yulu.Bikeshare
LEFT JOIN yulu.cost c ON b.yr = c.yr;                      -- left join with cost table (Alias C)
 
select * from yuluData;                                    -- Validate the data 

ALTER TABLE yuluData ADD Id INT AUTO_INCREMENT PRIMARY KEY; -- Adding Primary Key column ID, since it has no Pk. so we added ID as PK.

Describe yuluData                                            -- Vaidate Data

-- Adding new column of Revenue and profit in the table yuluData.

Alter table yuluData                                       -- Alter Table YuluData to ADD 2 new columns
Add column revenue decimal(10,2),                          -- Add revenue column with decimal DataType                   
Add Column profit Decimal(10,2);                           -- Add Profit Colum with Decimal DataType

-- Update revenue and profit columns with Values.

set sql_safe_updates=0                                     -- Disable safe mode to edit the data

update yulu.yuluData                                       -- update the new column made with values
set 
revenue= price*riders,                                     -- Revenue = price multiply by quantity(riders)
profit= revenue-COGS;                                      -- Profit = Revenue minus cost of Goods sold.


DELIMITER &&                                               -- using && Delimiter to Avoid Confusion 
CREATE PROCEDURE yulu ()                                   -- stored procedure for yuluData table. 
BEGIN
    SELECT * FROM yulu.yuluData;
END &&                                                     -- ending procedure syntax with &&
DELIMITER ;                                                -- completing syntax with default(;) Delimiter

call yulu;                                                 -- calling stored Procedure Yulu

Create table backup_yulus AS 
select * from yulu.yuluData where 1=0;                     -- Creating Backup Table for YuluData 
     /* condition WHERE 1=0 will make a copy 
     of the original Table, without any values
	 with same structure and data types*/

DELIMITER $$                                                -- creating Before Delete Trigger to store delete data in backup table.
CREATE TRIGGER before_delete_yuluData                       -- creating a Trigger for final Data that is YuluData
BEFORE DELETE ON yulu.yuluData                              -- using before out of two options that is before and After
FOR EACH ROW                                                -- using for Row Wise
BEGIN 
    INSERT INTO backup_yulus                                -- Before Delete event occurs deleted valued will be stored in backup_yulus.
    VALUES (OLD.season, OLD.yr, OLD.mnth, 
    OLD.hr, OLD.holiday, 
    OLD.weekday, OLD.workingday, OLD.weathersit,
    OLD.hum, OLD.temp, OLD.windspeed, OLD.dteday, 
    OLD.atemp,OLD.rider_type, OLD.riders, OLD.price,
    OLD.COGS,OLD.revenue, OLD.profit);
END $$                                                       -- END with && Delimiter
DELIMITER ;                                                  -- completing with Default(;) Delimiter

call yulu;                                                   -- calling stored procedure Yulu

-- DATA IS CLEANED.

-- Analysis :


-- Question 1  find out Total Revenue, Total profit, Average profit, Average Revenue for each hour of the day ?

-- solution :

SELECT hr AS Hour, sum(revenue) AS Total_Revenue , sum(profit) AS Total_profit,
AVG (revenue) AS Average_revenue, avg(profit) as average_profit  from yulu.yuludata
group by hr
order by Total_profit Desc;

/*The most profitable hours of day are between 17:00 (5pm) and 19:00 (7pm) 
The Least profitable hours are early in the morning between 3:00am and 5:00 am 
since the demand is low */





-- Question number 2 What is the total revenue and profit and average revenue and average profit for each season?

SELECT DISTINCT
       season,
       SUM(revenue) OVER (PARTITION BY season) AS Total_Revenue,
       SUM(profit) OVER (PARTITION BY season) AS Total_Profit,
       AVG(revenue) OVER (PARTITION BY season) AS Average_Revenue,
       AVG(profit) OVER (PARTITION BY season) AS Average_Profit
FROM yulu.yuludata
ORDER BY Total_Profit;


/*Season 1 (Winter) is characterized by the lowest figures, suggesting it might be a less favorable or less active period.
  Season 2 (spring) shows a significant improvement and suggests a better-performing period.
  Season 3 (Summer) represents the peak performance with the highest revenue and profit.
  Season 4 (fall)   sees a decline from the peak but still performs well compared to Season 1.
  There is spike in profits during summer and early fall*/



-- Question number 3  How does Average revenue ,Average profit ,Total revenue and Total profit differ between rider type?

WITH totals AS (
    SELECT SUM(revenue) AS Total_Revenue,
           SUM(profit) AS Total_Profit
    FROM yuluData
) ,
rider_stats AS (
    SELECT rider_type,
           AVG(revenue) AS Average_Revenue,
           AVG(profit) AS Average_Profit,
           SUM(revenue) AS Total_Revenue,
           SUM(profit) AS Total_Profit
    FROM yuluData
    GROUP BY rider_type
) 
SELECT rs.rider_type,
       rs.Average_Revenue,
       rs.Average_Profit,
       rs.Total_Revenue,
       rs.Total_Profit,
       ROUND((rs.Total_Revenue / t.Total_Revenue) * 100, 2) AS Revenue_Percentage,
       ROUND((rs.Total_Profit / t.Total_Profit) * 100, 2) AS Profit_Percentage
FROM rider_stats AS rs
CROSS JOIN totals AS t
ORDER BY rs.rider_type;

/*The Registered rider_type dominates the market with the share of 81.36%,
whereas casual rider_type only have 18.64 percentage,
Target Market of our customers prefers Registered Riders than casuals*/


-- Question number 4 How does the total revenue and profit vary by month, yearly?

call yulu;

CREATE VIEW monthly_revenue_profit AS
SELECT yr, mnth, SUM(revenue) AS Total_Revenue, SUM(profit) AS Total_Profit
FROM yuluData
GROUP BY yr, mnth order by Total_profit;
select * from yulu.monthly_revenue_profit order by Total_profit desc;


/* Year 2021 shows a consistent increase  in Revenue and profit throughout year 
with highest in the month of July and August
Year 2022 shows highest profit in the month of september followed by August and july. */




-- Question number 5  What is the total revenue and profit based on different weather situations?

-- weathersit values:

-- 1: Clear, Few clouds, Partly cloudy
-- 2: Mist + Cloudy, Mist + Broken clouds
-- 3: Light Snow, Light Rain, Thunderstorm, Scattered clouds
-- 4   heavy rainfall
 call yulu;

 select 
 weathersit, sum(revenue) Total_Revenue,sum(profit) Total_profit 
 from yulu.yuluData group by weathersit;

/* weathersit1 (sunny) has highest Total Revenue
   weathersit2 (cloudy) generates revenue less than sunny condition
   weathersit3 (mist) generates less renvue 
   weathersit4 (Heavy Rain/Snow) sharp drop in revenue */



-- Question number 6   What are the top 5 most profitable hours of the day?

SELECT hr AS hour, SUM(profit) AS total_profit
FROM yuluData
group by hr 
order by total_profit desc 
limit 5;

/* 17:00 (5 PM) is the most profitable hour
   18:00 (6PM) is the second most profitable hour
   8:00pm is the third most profitable hour
   16:00(4pm) is the fourth most profitable hour
   19:00(7pm) is the fifth most profitable hour
   The peak time is between 4pm to 8 pm */
   
   
   

-- Question 7  How does revenue and profit differ on working days versus non-working days?

SELECT workingday AS Working_day,SUM(revenue) AS Total_Revenue, SUM(profit) AS Total_Profit,
    ROUND(SUM(revenue) * 100.0 / SUM(SUM(revenue)) OVER (), 2) AS Revenue_Percentage,
    ROUND(SUM(profit) * 100.0 / SUM(SUM(profit)) OVER (), 2) AS Profit_Percentage
FROM yuluData
GROUP BY workingday 
ORDER BY Total_Profit DESC;

/* Working Day=1 contributed 69.68% of Total Revenue and 69.69% of Total Profit, 
Non Working Day=0 contributed 30.31% of Total Revenue and 30.31% of Total Profit.*/


--  Question 8 How different weather conditions impact revenue and profit.
SELECT weathersit,
       ROUND(AVG(temp), 2) AS Avg_Temperature,
       ROUND(AVG(atemp), 2) AS Avg_Feels_Like_Temp,
       ROUND(AVG(hum), 2) AS Avg_Humidity,
       ROUND(AVG(windspeed), 2) AS Avg_Windspeed,
       SUM(revenue) AS Total_Revenue,
       SUM(profit) AS Total_Profit
FROM yuluData
GROUP BY weathersit
ORDER BY Total_Profit DESC;


/*Weathersit1, with moderate temperature, low humidity, and low windspeed,
 is associated with the highest revenue and profit,It indicates the most favorable condition for the business.
Hot or very humid conditions may deter business performance.*/


 -- Rider Type Revenue and Profit Comparison in Percentage


-- Question 9 what is the Yearly profit comparsion 

WITH yearwise_profit AS (
    SELECT yr,SUM(profit) AS Total_Profit, SUM(revenue) AS Total_Revenue FROM yuluData GROUP BY yr
)
SELECT yr,Total_Profit,Total_Revenue,
LAG(Total_Profit) OVER (ORDER BY yr) AS Prev_Year_Profit,
LAG(Total_Revenue) OVER (ORDER BY yr) AS Prev_Year_Revenue,
ROUND((Total_Profit - LAG(Total_Profit) OVER (ORDER BY yr)) / LAG(Total_Profit) OVER (ORDER BY yr) * 100, 2) 
AS Profit_Increase_Percentage,
ROUND((Total_Revenue - LAG(Total_Revenue) OVER (ORDER BY yr)) / LAG(Total_Revenue) OVER (ORDER BY yr) * 100, 2)
AS Revenue_Increase_Percentage
FROM yearwise_profit;

-- Question 10 what will be Average Profit and Revenue based on Windspeed Buckets
SELECT 
  CASE 
    WHEN windspeed BETWEEN 0 AND 0.2 THEN 'Low'
    WHEN windspeed BETWEEN 0.2 AND 0.5 THEN 'Moderate'
    WHEN windspeed BETWEEN 0.5 AND 0.8 THEN 'High'
    ELSE 'Very High'
  END AS Windspeed_Level,
  COUNT(*) AS Number_of_Records,
  AVG(profit) AS Average_Profit,
  SUM(profit) AS Total_Profit,
  AVG(revenue) AS Average_Revenue
FROM 
  yuluData
GROUP BY 
  Windspeed_Level
ORDER BY 
   Windspeed_Level ;
   
  /*Low Windspeed: The highest number of records and total profit, but the average profit is moderate (380.86). 
    Low wind conditions are favorable but not extremely profitable per ride.
    Moderate Windspeed: Fewer records but a much higher average profit (663.00), 
    showing that moderate wind conditions are optimal for profitability.
    High Windspeed: Low number of records and moderate profit levels (549.79), 
    indicating some resilience in high winds but not a major factor.
    Very High Windspeed: Fewest records and the lowest profit per ride (250.59),
    showing a significant drop in profitability when winds are very strong.*/ 
   
   
   
   
  call yulu

-- Question 11 what are the insights about Average Profit and Revenue based on Temperature Buckets?
SELECT 
  CASE 
    WHEN temp BETWEEN 0 AND 0.2 THEN 'Very Cold'
    WHEN temp BETWEEN 0.2 AND 0.4 THEN 'Cold'
    WHEN temp BETWEEN 0.4 AND 0.6 THEN 'Mild'
    WHEN temp BETWEEN 0.6 AND 0.8 THEN 'Warm'
    ELSE 'Hot'
  END AS Temperature_Level,
  COUNT(*) AS Number_of_Records,
  AVG(profit) AS Average_Profit,
  SUM(profit) AS Total_Profit,
  AVG(revenue) AS Average_Revenue
FROM 
  yuluData
GROUP BY 
  Temperature_Level
ORDER BY 
  Temperature_Level;


/*Cold: Has the second-highest number of records, but the average profit is relatively low (283.53),
 indicating that colder days are less profitable overall.
Hot: Fewer records, but with the highest average profit (751.77), 
suggesting that hot days are more profitable per ride.
Mild: This condition has a large number of records, with a moderate average profit (448.65), 
making it a stable contributor to revenue.
Very Cold: Lowest average profit (143.63), 
indicating a significant reduction in profitability during very cold weather.
Warm: The highest total profit (6136006.00) due to both a high number of records and moderate profit levels,
 making it the most significant overall contributor.*/

SELECT 
    CASE 
        WHEN atemp BETWEEN 0.0 AND 0.2 THEN 'Very Cold'
        WHEN atemp BETWEEN 0.2 AND 0.4 THEN 'Cold'
        WHEN atemp BETWEEN 0.4 AND 0.6 THEN 'Mild'
        WHEN atemp BETWEEN 0.6 AND 0.8 THEN 'Warm'
        WHEN atemp BETWEEN 0.8 AND 1.0 THEN 'Hot'
        ELSE 'Unknown'
    END AS Atemp_Level,
    COUNT(*) AS Number_of_Records,
    AVG(profit) AS Average_Profit,
    SUM(profit) AS Total_Profit,
    AVG(revenue) AS Average_Revenue
FROM yuluData
GROUP BY Atemp_Level
ORDER BY Atemp_Level;

/*
Warm and Mild temperatures (0.25 - 0.75 range) seem to have the highest total profits, with Warm being the most profitable.
Cold and Very Cold temperatures correspond to lower profits.
Hot temperatures have high average profits per ride but occur less frequently, likely due to fewer records available.
This suggests that moderate (Warm, Mild) conditions drive better business outcomes,
 possibly because extreme temperatures (Hot or Very Cold) might discourage riding activity.*/

SELECT 
    Hum, 
    AVG(Profit) AS Average_Profit, 
    SUM(Profit) AS Total_Profit, 
    AVG(Revenue) AS Average_Revenue,
    AVG(COGS) AS Average_COGS,
    AVG(Price) AS Average_Price,
    COUNT(*) AS Number_of_Records
FROM 
    YuluData
GROUP BY 
    Hum;


/*Profit:
Total_Profit in yr 0: 4,938,541.37 whereas Total_Profit in yr 1: 10,200,134.16
Profit Increase Percentage: 106.54%
 This substantial increase shows a doubling of profit from the previous year.
Revenue:
Total_Revenue in yr 1: 10,227,384.24 Whereas Total_Revenue in yr 0: 4,959,980.97
Revenue Increase Percentage: 106.20%
High Humidity Impact: From the data, higher humidity levels (e.g., 0.88, 0.86, etc.) seem to be associated with lower average profits, 
lower total profits, and lower average revenues compared to lower humidity levels (e.g., 0.38, 0.44, etc.). 
This could indicate that customers might prefer renting bikes in moderate to low humidity conditions, 
leading to higher profits during these periods.
The growth rate observed (over 100% increase) sets a high benchmark for future performance*
/

-- Recommendation

/*Insights for Improvement:
1. Weather Analysis: Target promotions and discounts on Weathersit 3 & 4 days to minimize 
   the impact of poor weather on revenue.
   
2. Rider Retention: Focus on converting casual riders to registered riders to maximize customer lifetime value,
   by Offering discounts, loyalty rewards, and premium features for registered users could help convert more casual users.
   
3. Hourly Promotions: Offer incentives during low-profit hours, such as late nights, to increase ridership.

4. Peak Hours Optimization: Enhanced availability of bikes, 
   dynamic pricing, or even partnerships with local businesses for after-work commuting could be explored.
   
5. Given the spike in profits during summer and early fall, launching seasonal campaigns could boost revenue. 
   Targeted promotions for tourists or special discounts during high-traffic months
   like July and September could further enhance profitability.
   
6. Focus on Mild to Warm Weather with moderate less humdity: Given that warm and mild conditions are consistently profitable,
   targeting marketing efforts and availability during these conditions could boost overall performance and adapt to Extreme Conditions,
   consider offering promotions or discounts during extreme cold or windy conditions to incentivize ridership,
   as these conditions lead to lower profits also optimize Resource Allocation based on the weather forecast, 
   we can adjust staff and bike availability, reducing them in low-profit conditions
   (e.g., very cold or high winds) and maximizing them during profitable conditions*/
   

use yulu;
