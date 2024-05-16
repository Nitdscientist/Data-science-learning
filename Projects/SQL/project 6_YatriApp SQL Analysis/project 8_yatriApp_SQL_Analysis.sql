use Yatri

select * from trips;

select * from trips_details4;

select * from loc;

select * from duration;

select * from payment;


--1. total trips

select count(distinct tripid) as total_trips from trips_details4;


--2. total drivers

select * from trips;

select count(distinct driverid) as total_driver from trips;

-- 3. total earnings

select sum(fare) as total_earning from trips;

-- 4. total Completed trips

select * from trips_details4;
select sum(end_ride) as total_completed_trips from trips_details4;

--5. total searches

select sum(searches) as total_searches,sum(searches_got_estimate) as total_searches_got_estimate,
sum(searches_for_quotes) as total_searches_for_quotes,sum(searches_got_quotes) as total_searches_got_quotes,
sum(customer_not_cancelled) as total_customer_not_cancelled,sum(driver_not_cancelled) as total_driver_not_cancelled,
sum(otp_entered) as total_otp_entered,sum(end_ride) as total_end_ride
from trips_details4;

select * from trips;
select * from trips_details4;


--6. total driver cancelled

select count(tripid)-sum(driver_not_cancelled) as total_driver_cancelled from trips_details4

--7. cancelled bookings by customer

select count(tripid)-sum(customer_not_cancelled) as total_customer_cancelled from trips_details4

--8. average distance per trip

select sum(distance)/count(*) as avg_distance_per_trip from trips;


--9. average fare per trip

select sum(fare)/count(*) as avg_fare_per_trip from trips;

--10. distance travelled

select * from trips;
select * from trips_details4;

select sum(distance) as total_distance_travelled from trips


--11. which is the most used payment method 

select * from payment

select top 1 method,count(method) as cnt from 
(select a.faremethod,b.method from trips a inner join payment b
on a.faremethod=b.id) as c
group by method
order by cnt desc

-- 12. The highest payment was made through which instrument

select top 1 method,sum(fare) as total_fare from 
(select a.faremethod,a.fare,b.method from trips a inner join payment b
on a.faremethod=b.id) as c
group by method
order by total_fare desc

-- 13. which two locations had the most trips

select * from trips
select * from loc


select * from
(select *,DENSE_RANK() over(order by cnt desc) as rnk from -- we use dense rank instead of top becuase other location may be same no. of trips
(select assembly1_from,assembly1_to,count(tripid) as cnt from
(SELECT a.*, b1.assembly1 as assembly1_from, b2.assembly1 as assembly1_to
FROM (
    SELECT tripid,loc_from, loc_to
    FROM trips ) AS a
INNER JOIN loc AS b1
ON a.loc_from = b1.id
INNER JOIN loc AS b2 
ON a.loc_to = b2.id) as c
group by assembly1_from,assembly1_to) as d) as e where rnk=1
--order by cnt desc


--14. top 5 earning drivers

select * from trips
select * from trips_details4

select * from
(select *,DENSE_RANK() over(order by total_earning desc) as rnk from -- we use dense rank instead of top becuase other driver may be earn same.
(select driverid,sum(fare) as total_earning from trips
group by driverid) as a) as b where rnk<6
--order by total_earning desc

--15. which duration had more trips

select * from trips
select * from duration

select * from
(select *,DENSE_RANK() over(order by cnt desc) as rnk from
(select duration ,count(duration) as cnt from 
(select a.duration as duration_a,b.duration from trips a inner join duration b
on a.duration=b.id) as c
group by duration) as d) as e where rnk=1
--order by cnt desc


-- 16. which driver , customer pair had more orders
select * from trips
select * from trips_details4

select * from
(select *, rank() over(order by cnt desc) as rnk from
(select driverid,custid,count(distinct tripid) as cnt from trips
group by driverid,custid ) as a) as b where rnk=1


-- 17. search to estimate rate

select * from trips_details4

select sum(searches_got_estimate)*100.0/sum(searches) from trips_details4

-- 18. estimate to search for quote rates

select sum(searches_for_quotes)*100.0/sum(searches) from trips_details4

-- 19. quote acceptance rate

select sum(searches_got_quotes)*100.0/sum(searches) from trips_details4

-- 20. quote to booking rate

select sum(customer_not_cancelled)*100.0/sum(searches) from trips_details4

-- 21. booking cancellation rate

select 100-sum(customer_not_cancelled)*100.0/sum(searches) from trips_details4

-- 22. which area got highest trips in which duration
select * from
(select *, rank() over(order by cnt desc) as rnk from
(select loc_from,loc_to,count(tripid) as cnt,duration from trips
group by  loc_from,loc_to,duration) as a) as b where rnk=1
--order by cnt desc


-- 23. which area got the highest fares, cancellations,trips

select * from
(select *,rank() over(order by fare desc) as rnk from
(select loc_from,sum(fare) as fare from trips
group by loc_from) as a) as b where rnk=1


--cencel by driver
select * from
(select *,rank() over(order by total_cancellation desc) as rnk from
(select loc_from,count(tripid)-sum(driver_not_cancelled) as total_cancellation from trips_details4
group by loc_from) as a) as b where rnk=1

--cancel by customer

select * from 
(select *,rank() over(order by total_cancellation desc) as rnk from
(select loc_from,count(tripid)-sum(customer_not_cancelled) as total_cancellation from trips_details4
group by loc_from) as a) as b where rnk=1

--for trips
select * from
(select *, rank() over(order by cnt desc) as rnk from
(select loc_from,loc_to,count(tripid) as cnt from trips
group by  loc_from,loc_to) as a) as b where rnk=1
--order by cnt desc



-- 24. which duration got the highest trips and fares

select * from
(select *, rank() over(order by cnt_trip desc, total_fare desc) as rnk from
(select duration,count(tripid) as cnt_trip,sum(fare) as total_fare from trips
group by  duration) as a) as b where rnk=1
