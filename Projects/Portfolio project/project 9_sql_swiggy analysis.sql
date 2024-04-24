USE OnlineFood


--1. Find customers who have never ordered

select * from Users
select * from orders

select name from Users 
where user_id not in (select user_id from orders)


--2. Average Price/dish

select * from food
select * from menu


select a.f_id,b.f_name,avg(a.price) as Avg_price from menu a inner join food b
on a.f_id=b.f_id
group by a.f_id,b.f_name
order by Avg_price desc


--3. Find the top restaurant in terms of the number of orders for a given month

select * from orders
select * from Restaurant

select * from
(select r_id,r_name,month_name,cnt,rank() over (order by cnt desc) as rnk from 

(select a.*,b.r_name from 
(select r_id,datename(month,date) as month_name,count(order_id) as cnt
from orders
group by r_id,datename(month,date)) as a inner join Restaurant b on a.r_id=b.r_id) as c 
where month_name='july') as d where rnk=1


--4. restaurants with monthly sales greater than x 

select * from 
(select a.r_id,b.r_name,datename(month,a.date) as month_name,sum(a.amount) as total_amt from orders a inner join Restaurant b
on a.r_id=b.r_id
group by a.r_id,b.r_name,datename(month,a.date)) as c
where month_name='june' and total_amt> 500


--5. Show all orders with order details for a particular customer in a particular date range

select * from orders
select * from order_details
select * from users
select * from food


select g.*,h.name from
(select e.*,f.f_name from
(select c.*,d.f_id from

(select a.user_id,a.order_id,b.r_name from orders a
inner join Restaurant b on a.r_id=b.r_id 
where user_id=(select user_id from users where name like 'Ankit') and date>'2022-06-10' and date<'2022-07-10') as c
inner join order_details d
on c.order_id=d.order_id ) as e
inner join food f on e.f_id=f.f_id) as g 
inner join users h on g.user_id=h.user_id

------------or-----------

select a.order_id,a.user_id,b.name,a.r_id,c.r_name,d.f_id,f_name
from orders a
inner join Users b
on a.user_id=b.user_id
inner join Restaurant c
on a.r_id=c.r_id
inner join order_details d
on a.order_id=d.order_id
inner join food e
on d.f_id=e.f_id
where name like 'Ankit' and date>'2022-06-10' and date<'2022-07-10' order by order_id


--6. Find restaurants with max repeated customers 

select * from Restaurant
select * from orders


select top 1  b.r_id,b.r_name,count(*) as loyal_customer from
(select r_id,user_id, count(user_id) as visit from orders
group by r_id,user_id
having count(user_id)>1) as a 
inner join Restaurant b
on a.r_id=b.r_id
group by b.r_id,b.r_name
order by loyal_customer desc 


--7. Month over month revenue growth of swiggy


WITH sales AS (
  SELECT DATENAME(month, date) AS month_name, SUM(amount) AS revenue
  FROM orders
  GROUP BY DATENAME(month, date)
)
SELECT 
  month_name,
  CASE 
    WHEN previous_month_revenue = 0 THEN NULL -- Avoid division by zero
    ELSE ((revenue - previous_month_revenue) / previous_month_revenue) * 100 
  END AS growth_perc
FROM (
  SELECT 
    month_name,
    revenue,
    LAG(revenue, 1) OVER (ORDER BY 
      CASE 
        WHEN month_name = 'May' THEN 1
        WHEN month_name = 'June' THEN 2
        WHEN month_name = 'July' THEN 3
      END
    ) AS previous_month_revenue
  FROM sales
) AS t;


--8. Customer - favorite food

select * from orders
select * from food
select * from order_details
select * from Users

select * from(
select e.*,rank() over (partition by name order by cnt desc) as rnk from(
select name,f_name,count(f_name) as cnt
from orders a
inner join order_details b
on a.order_id=b.order_id
inner join food c
on b.f_id=c.f_id
inner join Users d
on a.user_id=d.user_id
group by f_name,name) as e) as f where rnk=1


--9. Find the most loyal customers for all restaurant

select * from Restaurant
select * from orders
select * from Users


select  b.r_id,b.r_name,c.name,count(*) as loyal_customer from
(select r_id,user_id, count(user_id) as visit from orders
group by r_id,user_id
having count(user_id)>1) as a 
inner join Restaurant b
on a.r_id=b.r_id
inner join users c
on a.user_id=c.user_id
group by b.r_id,b.r_name,c.name
order by loyal_customer desc 


--10. Month over month revenue growth of a restaurant

WITH sales AS (
  SELECT a.r_id,a.r_name,DATENAME(month, b.date) AS month_name, SUM(b.amount) AS revenue
  FROM Restaurant a
  inner join orders b
  on a.r_id=b.r_id
  GROUP BY DATENAME(month, b.date),a.r_id,a.r_name
)
SELECT 
  r_id,month_name,
  CASE 
    WHEN previous_month_revenue = 0 THEN NULL -- Avoid division by zero
    ELSE ((revenue - previous_month_revenue) / previous_month_revenue) * 100 
  END AS growth_perc
FROM (
  SELECT 
    r_id,month_name,
    revenue,
    LAG(revenue, 1) OVER (ORDER BY 
      CASE 
        WHEN month_name = 'May' THEN 1
        WHEN month_name = 'June' THEN 2
        WHEN month_name = 'July' THEN 3
      END
    ) AS previous_month_revenue
  FROM sales
) AS t;