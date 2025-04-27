-- Create Database called OnlineShoppingDB
CREATE DATABASE OnlineShoppingDB;
USE OnlineShoppingDB;

-- Add foreign key constraints to join the 5 tables 
ALTER TABLE Orders
ADD FOREIGN KEY (Customer_ID) REFERENCES Customers (Customer_ID);

ALTER TABLE Payments
ADD FOREIGN KEY (Order_ID) REFERENCES Orders (Order_ID);

ALTER TABLE Order_items
ADD FOREIGN KEY (Order_ID) REFERENCES Orders (Order_ID);

ALTER TABLE Order_items
ADD FOREIGN KEY (Product_ID) REFERENCES Products (Product_ID);

--Question 2: Write a query that returns the names and countries of customers who made orders with a total amount between £500 and £1000
SELECT DISTINCT c.name, c.country
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Order_items oi ON o.order_id = oi.order_id
WHERE oi.total_amount BETWEEN 500 AND 1000;

--Question 3: Get the total amount paid by customers belonging 
--to UK who bought AT LEAST three products in an order.

SELECT SUM(TotalAmount) AS TotalSpentByUKCustomers
FROM (
    SELECT oi.order_id, SUM(oi.quantity) AS total_products, SUM(oi.Total_price) AS TotalAmount
    FROM order_items oi
    JOIN Orders o ON oi.order_id = o.order_id
    JOIN Customers c ON o.customer_id = c.customer_id
    WHERE c.country = 'UK'
    GROUP BY oi.order_id
    HAVING SUM(oi.quantity) >= 3
) AS filtered_orders;

--Question 3: Get the total amount paid by customers belonging 
--to UK who bought MORE THAN three products in an order.

SELECT SUM(TotalAmount) AS TotalSpentByUKCustomers
FROM (
    SELECT oi.order_id, SUM(oi.quantity) AS total_products, SUM(oi.Total_price) AS TotalAmount
    FROM order_items oi
    JOIN Orders o ON oi.order_id = o.order_id
    JOIN Customers c ON o.customer_id = c.customer_id
    WHERE c.country = 'UK'
    GROUP BY oi.order_id
    HAVING SUM(oi.quantity) > 3
) AS filtered_orders;

--Question 4: Get the highest and second highest amount_paid from UK or Australia – this is calculated after applying VAT as 12.2% multiplied by the amount_paid. 
--Some of the results are not integer values; round the result to the nearest integer value.

SELECT DISTINCT TOP 2 ROUND(p.Amount_paid * 1.122, 0) AS Amount_paid_with_VAT
FROM Payments p 
JOIN Orders o ON p.order_id = o.order_id
JOIN Customers c ON o.customer_id = c.customer_id
WHERE c.country IN ('UK', 'Australia')
ORDER BY Amount_paid_with_VAT DESC;

--Question 5: Get a list of the distinct product_name and the total quantity purchased for each product called as total_quantity. Sort by total_quantity.

SELECT p.product_name, SUM(oi.quantity) AS total_quantity
FROM Products p
JOIN Order_items oi ON p.product_id=oi.product_id
GROUP BY p.product_name
ORDER BY total_quantity;


--Question 6: Write a stored procedure for the query given as: 
--Update the amount_paid of customers who purchased either laptop or smartphone as products and amount_paid>=£17000 of all orders to the discount of 5%.

CREATE PROCEDURE ApplyHighValueDiscount
AS
BEGIN
    UPDATE p
    SET p.Amount_paid = p.Amount_paid * 0.95
    FROM Payments p
    JOIN Orders o ON p.order_id = o.order_id
    JOIN Order_items oi ON o.order_id = oi.order_id
	WHERE p.Amount_paid >= 17000 
		AND oi.product_id IN (1, 2);
END;

EXEC ApplyHighValueDiscount;

--Question 7: write at least five queries of your own. Use of all of the following at least once:
	--Nested query including use of EXISTS or IN
	--Joins
	--System functions
	--Use of GROUP BY, HAVING and ORDER BY clauses

--Order the customers' countries from those containing most customers to those containing fewest customers 
SELECT c.country, COUNT(c.Customer_id) AS number_of_customers FROM Customers c 
GROUP BY c.country 
ORDER BY number_of_customers DESC;

--Order the items from best-selling to worst-selling 
SELECT p.product_name, COALESCE(SUM(oi.quantity), 0) AS TotalQuantity 
FROM Products p
LEFT JOIN Order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY TotalQuantity DESC;

--Identify the names of repeat customers (that is, customers who have placed more than one order) 
--Sort by number of orders from highest to lowest 
SELECT c.name, COUNT(o.order_id) AS NumberOfOrders
FROM (Orders o
INNER JOIN Customers c ON o.customer_id = c.customer_id)
GROUP BY name
HAVING COUNT(o.order_id) > 1
ORDER BY NumberOfOrders DESC;

--Retrieve all customers that do not have any orders in the Orders table. 
SELECT c.name FROM Customers c 
WHERE NOT EXISTS (SELECT 1 FROM Orders o WHERE c.customer_id=o.customer_id);

--Identify the 5 customers who have purchased the most items
SELECT TOP 5 c.name, SUM(oi.quantity) AS TotalQuantity 
FROM Customers c 
JOIN Orders o ON c.customer_id=o.customer_id
JOIN Order_items oi ON o.order_id=oi.order_id
GROUP BY c.name
ORDER BY TotalQuantity DESC; 
