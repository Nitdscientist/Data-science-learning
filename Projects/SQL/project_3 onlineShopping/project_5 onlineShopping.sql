Use OnlineShopping -- select Database which we have to use


-----------------------------------------------------------------------------------------------------------------
-- query the address, starttime and endtime of the servicepoints in the same city as userid 5  
SELECT * FROM ServicePoint

SELECT *
FROM Address
where userid=5

SELECT streetaddr,starttime,endtime
FROM ServicePoint
WHERE ServicePoint.city IN 
(SELECT Address.city
FROM Address
WHERE userid=5);

-------------------------------------------------------------------------------------------------------------
-- query the information of laptops
SELECT *
FROM Product
WHERE type='laptop';

-----------------------------------------------------------------------------------------------------------------
-- query the total quantity of products from store with storeid 8 in the shopping cart

select *
from Save_to_Shopping_Cart

select * 
from Product

SELECT SUM(quantity) AS totalQuantity
FROM Save_to_Shopping_Cart
WHERE Save_to_Shopping_Cart.pid IN (SELECT Product.pid FROM Product WHERE sid=8);

----------------------------------------------------------------------------------------------------------------------
-- query the name and address of orders delivered on 2017-02-17

select *
from Address

select *
from Deliver_To

SELECT name, streetaddr, city
FROM Address
WHERE addrid IN (SELECT addrid FROM Deliver_To WHERE TimeDelivered = '2017-02-17');

--------------------------------------------------------------------------------------------------------------------------

 -- query the comments of product 1,2,3,4,5,6,7,8 

 SELECT *
 FROM Comments
 WHERE pid IN (1, 2, 3, 4, 5, 6, 7, 8); 

-- ------------------------------------------- -----------
-- Data Modification

-- Insert the user id of sellers whose name starts with A into buyer

Select * from Users -- for check
select * from Buyer -- for check

INSERT INTO buyer
SELECT * FROM seller
WHERE userid IN (SELECT userid FROM users WHERE name LIKE 'A%');

---------------------------------------------------------------------------------------------------------------------------
-- Update the payment state of orders to unpaid which created after year 2017 and with total amount greater than 50.

select * from Orders --for check

UPDATE Orders
SET paymentState = 'Unpaid'
WHERE creationTime > '2017-01-01' AND totalAmount > 50;

--------------------------------------------------------------------------------------------------------------------------
-- Update the name and contact phone number of address where the provice is Quebec and city is montreal.

select * from Address                       -- for check
where province='Quebec' AND city='Montreal' --for check

UPDATE address
SET name = 'Rahul', contactPhoneNumber ='12345678'
WHERE province = 'Quebec' AND city = 'Montreal';

------------------------------------------------------------------------------------------------------------------------------
-- Delete the store which opened before year 2017

select * from Store                 -- for check
select * from save_to_shopping_cart -- for check

DELETE FROM save_to_shopping_cart
WHERE addTime < '2017-01-01';

-- -----------------------------------------------------------------------------------------------------------------
-- Views 
--------------------------------------------------------------------------------------------------------------------

-- Create view of all products whose price above average price.

select * from Product  -- for check

CREATE VIEW Products_Above_Average_Price AS
SELECT pid, name, price 
FROM Product
WHERE price > (SELECT AVG(price) FROM Product);

--check now
select * from products_above_average_price


--------------------------------------------------------------------------
-- Update the view

UPDATE Products_Above_Average_Price
SET price = 1
WHERE name = 'GoPro HERO5';

--check now
select * from Product  -- for check

----------------------------------------------------------------------------------------------------------------------
-- Create view of all products sales in 2016.
select * from OrderItem -- for check
select * from contain   -- for check
select * from Payment   -- for check

CREATE VIEW Product_Sales_For_2016 AS
SELECT pid, name, price
FROM Product
WHERE pid IN (SELECT pid FROM OrderItem WHERE itemid IN 
              (SELECT itemid FROM Contain WHERE orderNumber IN
               (SELECT orderNumber FROM Payment WHERE payTime > '2016-01-01' AND payTime < '2016-12-31')
              )
             );

-- check now
SELECT * FROM product_sales_for_2016;

------------------------------------------------------------------------------------------------------------------
-- Update the view
UPDATE product_sales_for_2016
SET price = 2
WHERE name = 'GoPro HERO5';

-- check now
select * from Product

-- ------------------------------------------- -------------------------------------------------------------
-- Check Constraints
---------------------------------------------------------------------------------------------------------------
-- Check whether the products saved to the shopping cart after the year 2017 has quantities of smaller than 10.

select * from Save_to_Shopping_Cart -- for check

DROP TABLE Save_to_Shopping_Cart;
CREATE TABLE Save_to_Shopping_Cart
(
    userid INT NOT NULL
    ,pid INT NOT NULL
    ,addTime DATE
    ,quantity INT
    ,PRIMARY KEY (userid,pid)
    ,FOREIGN KEY(userid) REFERENCES Buyer(userid)
    ,FOREIGN KEY(pid) REFERENCES Product(pid)
    ,CHECK (quantity <= 10 OR addTime > '2017-01-01')
);

INSERT INTO Save_to_Shopping_Cart VALUES(18,67890123,'2016-11-23',9);
INSERT INTO Save_to_Shopping_Cart VALUES(24,67890123,'2017-02-22',8);
INSERT INTO Save_to_Shopping_Cart VALUES(5,56789012,'2016-10-17',11); -- error due to constraints.

-------------------------------------------------------------------------------------------------------------------------------
-- Check whether the ordered item has 0 to 10 quantities

select * from OrderItem
select * from Contain

DROP VIEW Product_Sales_For_2016; -- If create this view before we need to drop it first
DROP TABLE Contain;
CREATE TABLE Contain
(
    orderNumber INT NOT NULL
    ,itemid INT NOT NULL
    ,quantity INT CHECK(quantity > 0 AND quantity <= 10)
    ,PRIMARY KEY (orderNumber,itemid)
    ,FOREIGN KEY(orderNumber) REFERENCES Orders(orderNumber)
    ,FOREIGN KEY(itemid) REFERENCES OrderItem(itemid)
);

INSERT INTO Contain VALUES (76023921,23543245,11); -- error due to constraints
INSERT INTO Contain VALUES (23924831,65738929,8);