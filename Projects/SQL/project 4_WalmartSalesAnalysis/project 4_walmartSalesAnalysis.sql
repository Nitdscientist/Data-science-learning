use salesDataWalmart

select * from WalmartSalesData

--------------------------------Feature Engineering------------------------------------------------------------------

-------time_of_day

select time
from WalmartSalesData;

SELECT time,
    CASE 
        WHEN CAST(time AS TIME) BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning' -- time cast because time format along with date
        WHEN CAST(time AS TIME) BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day
FROM WalmartSalesData;

ALTER TABLE WalmartSalesData
add time_of_day VARCHAR(20);

UPDATE WalmartSalesData
set time_of_day=CASE 
        WHEN CAST(time AS TIME) BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning' -- time cast because time format along with date
        WHEN CAST(time AS TIME) BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END

 select * from WalmartSalesData --for check
----------------------------------------------------------------------------------------------------------------------

-------------day_name

select date,
      DATENAME(WEEKDAY,date) as day_name
from WalmartSalesData

ALTER TABLE WalmartSalesData
add day_name VARCHAR(20)

UPDATE WalmartSalesData 
set day_name=  DATENAME(WEEKDAY,date)

 select * from WalmartSalesData --for check

 ------------------------------------------------------------------------------------------------------------------------------
 -----------month_name

 select date,
 DATENAME(month,date) as month_name
 from WalmartSalesData

 ALTER TABLE walmartSalesData add month_name VARCHAR(15)

 UPDATE WalmartSalesData
 set month_name= DATENAME(month,date)

 select * from WalmartSalesData --for check

 --------------------------------------------------------------------------------------------------------------------------
-----------------------------------------Business Question & Answer--------------------------------------------------------

--------Generic Question------------

-- How much unique cities does the data have?
select distinct city from WalmartSalesData

select count(distinct city ) as count_unique_city from WalmartSalesData

-- In which city is each branch
select distinct city,branch from WalmartSalesData

-----------product Question----------

--1. How many unique product lines does the data have?

select distinct Product_line from WalmartSalesData

select count(distinct Product_line ) as count_unique_productline from WalmartSalesData

--2. What is the most common payment method?

select Payment,count(payment) as count_payment
from WalmartSalesData
group by Payment
order by count_payment desc

--3. What is the most selling product line?

select product_line,count(product_line) as count_product_line
from WalmartSalesData
group by Product_line
order by count_product_line desc

--4. What is the total revenue by month?
 select month_name,sum(Total) as total_revenue
 from WalmartSalesData
 group by month_name
 order by total_revenue desc

 -- 5. What month had the largest COGS?

 select month_name,sum(cogs) as total_cogs
 from WalmartSalesData
 group by month_name
 order by total_cogs desc

 --6. What product line had the largest revenue?

 select Product_line,sum(Total) as total_revenue
 from WalmartSalesData
 group by Product_line
 order by total_revenue desc

 --7. What is the city with the largest revenue?

 select city,branch,sum(Total) as total_revenue
 from WalmartSalesData
 group by city,branch
 order by total_revenue desc


 -- 8. What product line had the largest VAT?

 select Product_line,avg(Tax_5) as total_VAT
 from WalmartSalesData
 group by Product_line
 order by total_VAT desc


 --9. Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
 
 select * from walmartsalesdata


 SELECT 
    product_line,
    CASE 
        WHEN CAST(SUM(CAST(quantity AS INT)) AS INT) > (SELECT AVG(CAST(quantity AS INT)) FROM walmartsalesdata) THEN 'good'
        ELSE 'bad'
    END AS product_status
FROM walmartsalesdata
GROUP BY product_line;

ALTER TABLE walmartsalesdata 
add product_status VARCHAR(20)

UPDATE walmartsalesdata
set product_status=CASE 
        WHEN CAST(quantity AS INT) > (SELECT AVG(CAST(quantity AS INT)) FROM walmartsalesdata) THEN 'good'
        ELSE 'bad'
    END


 --10. Which branch sold more products than average product sold?

 select avg(cast(quantity as INT))
 from walmartsalesdata


 select branch,sum(cast(quantity as INT)) as avg_sold
 from walmartsalesdata
 group by branch
having sum(cast(quantity as INT))> (select avg(cast(quantity as INT)) from walmartsalesdata)


 --11. What is the most common product line by gender?

 select gender,product_line,count(product_line) as count_product
 from walmartsalesdata
 group by product_line,gender
 order by gender, count_product desc

 --12. What is the average rating of each product line?

 select product_line,avg(rating) as avg_rating
 from walmartsalesdata
 group by product_line
 order by avg_rating desc

 ----------------------------- Sales------------------------------

 --1. Number of sales made in each time of the day per weekday

 select * from walmartsalesdata


  select day_name,time_of_day,count(cast(quantity as int)) as num_of_sales
 from walmartsalesdata
 group by day_name,time_of_day
 order by day_name


 --2. Which of the customer types brings the most revenue?

  select * from walmartsalesdata

  select customer_type,sum(total) as revenue
  from walmartsalesdata
  group by customer_type
  order by revenue desc

 --3. Which city has the largest tax percent/ VAT (Value Added Tax)?

  select * from walmartsalesdata

  select city,avg(tax_5) as VAT
  from walmartsalesdata
  group by city
  order by VAT desc

 --4. Which customer type pays the most in VAT?

 
  select customer_type,avg(tax_5) as VAT
  from walmartsalesdata
  group by customer_type
  order by VAT desc

 ------------------------------ customers-----------------------------

  select * from walmartsalesdata

 --1. How many unique customer types does the data have?

  select distinct customer_type from walmartsalesdata

  select count(distinct customer_type) as unique_customer from walmartsalesdata


 --2. How many unique payment methods does the data have?

 select distinct payment from walmartsalesdata

 select count(distinct payment) as unique_pay_method from walmartsalesdata

 --3. What is the most common customer type?

 select customer_type,count(customer_type) as count_customer_type
 from walmartsalesdata
 group by customer_type


 --4. Which customer type buys the most?

   select * from walmartsalesdata

   select customer_type,sum(cast(quantity as int)) as buy_qty
   from walmartsalesdata
   group by customer_type
   order by buy_qty desc

 --5. What is the gender of most of the customers?
 
   select gender,count(customer_type) as count_cust
   from walmartsalesdata
   group by gender
   order by count_cust desc


 --6. What is the gender distribution per branch?

   select branch,gender,count(gender) as count_gender
   from walmartsalesdata
   group by branch,gender
   order by branch

   --------------or-----------
   select gender,count(gender) as count_gender
   from walmartsalesdata
   where branch='C' -- we can check for all branch
   group by gender
   order by count_gender DESC


 --7. Which time of the day do customers give most ratings?
   
   select * from walmartsalesdata

   select time_of_day,avg(rating) as avg_rating
   from walmartsalesdata
   group by time_of_day
   order by avg_rating desc


 --8. Which time of the day do customers give most ratings per branch?

  select time_of_day,branch,avg(rating) as avg_rating
   from walmartsalesdata
   group by time_of_day,branch
   order by avg_rating desc


 --9. Which day fo the week has the best avg ratings?

   select day_name,avg(rating) as avg_rating
   from walmartsalesdata
   group by day_name
   order by avg_rating desc


 --10. Which day of the week has the best average ratings per branch?

  select day_name,branch,avg(rating) as avg_rating
   from walmartsalesdata
   group by day_name,branch
   order by avg_rating desc
