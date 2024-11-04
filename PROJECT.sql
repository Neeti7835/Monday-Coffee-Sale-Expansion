-- MONDAY COFFEE --
Easy-Medium Questions

1. How many people in each city are estimated to consume coffee, given that 25% of the population does?

SELECT 
	city_name,
    ROUND((population*0.25)/100000, 2) AS COFFEE_CONSUMERS_IN_MILLIONS,
	city_rank
	FROM city
ORDER BY 2 DESC

2. What is the total revenue generated from coffee sales across all cities in last qtr of 2023?
	
select 
	ci.city_name,
	SUM(s.total) as total_revenue
	from sales as s
	JOIN customers AS c
	ON s.customer_id = c.customer_id
	JOIN city as ci
	ON c.city_id = ci.city_id
WHERE
     EXTRACT(YEAR from s.sale_date) = 2023
     AND
     EXTRACT(QUARTER from s.sale_date) = 4
GROUP BY 1
ORDER BY 2 DESC

 3. How many units of each coffee product have been sold?

SELECT 
	p.product_name,
	COUNT(s.sale_id) as total_sale
	FROM products as p
LEFT JOIN
	sales as s
    ON p.product_id = s.product_id
group by 1
order by 2 desc

4. What is the average sales amount per customer in each city?
	
select 
	ci.city_name,
	SUM(s.total) as total_revenue,
	COUNT(DISTINCt s.customer_id) as no_of_customer,
	ROUND(
        	SUM(s.total)::numeric   
        	/COUNT(DISTINCt s.customer_id)::numeric   
           , 2) as avg_sale_per_cust
	
from sales as s
JOIN customers AS c
ON s.customer_id = c.customer_id
JOIN city as ci
ON c.city_id = ci.city_id
GROUP BY 1
ORDER BY 2 DESC

5. --city population and coffe consumers(25%)--
   --Provide a list of cities along with their populaions and estimated coffee consumers.--
   --return city name, total current customers, estimated coffee consumers(25%)--

WITH city_table as	
(
	SELECT 
     city_name,
       ROUND((population * 0.25/1000000), 2) as coffee_consumers_in_millions
	FROM city
),
customer_table	
AS	
(
	SELECT
	ci.city_name,
	COUNT(DISTINCT c.customer_id ) as unique_customers 
    FROM sales as s
	JOIN customers as c
   ON s.customer_id = c.customer_id
	JOIN city as ci
   ON ci.city_id = c.city_id	
   GROUP by 1
)
	SELECT 
	city_table.city_name,
    city_table.coffee_consumers_in_millions,
    customer_table.unique_customers
	FROM city_table
JOIN customer_table
ON  city_table.city_name = customer_table.city_name 
ORDER BY 2 DESC

6. What are the top 3 selling products in each city based on sales volume?

SELECt *
	FROM -- table 
(
	SELECT 
	ci.city_name,
	p.product_name,
	COUNT(s.sale_id) as selling_roduct,
	DENSE_RANK() OVER(PARTITION BY ci.city_name ORDER BY COUNT(s.sale_id) DESC) as rank
 	from products as p	
JOIN sales as s
ON s.product_id = p.product_id
JOIN customers as c
ON c.customer_id = s.customer_id
JOIN city as ci
ON ci.city_id = c.city_id	
GROUP BY 1, 2
--ORDER BY 1, 3 desc--
) as t1
WHERE rank <= 3

7. How many unique customers are there in each city who have purchased coffee products?

    SELECT 
       ci.city_name,
	   COUNT(DISTINCT s.customer_id) as unique_ux
    FROM city as ci
  LEFT JOIN customers as c
   ON c.city_id = ci.city_id
   JOIN sales as s
   ON s.customer_id = c.customer_id
   JOIN products as p
   ON p.product_id = s.product_id
WHERE
     p.product_id IN(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14)
GROUP BY 1

8. Find each city and their average sale per customer and avg rent per customer

WITH city_table as	
(
	select 
	ci.city_name,
	SUM(s.total) as total_revenue,
	COUNT(DISTINCt s.customer_id) as total_cx,
	ROUND(
        	SUM(s.total)::numeric   
        	/COUNT(DISTINCt s.customer_id)::numeric   
           , 2) as avg_sale_per_cust
	
from sales as s
JOIN customers AS c
ON s.customer_id = c.customer_id
JOIN city as ci
ON c.city_id = ci.city_id
GROUP BY 1
ORDER BY 2 DESC
),
city_rent	
AS	
(
	SELECT 
      city_name,
      estimated_rent
 FROM city     
)
   select
         cr.city_name,
         cr.estimated_rent,
         ct.avg_sale_per_cust,
         ct.total_cx,   
	    ROUND(cr.estimated_rent/ct.total_cx, 2) as avg_rent_per_cust
   FROM city_table as ct
JOIN city_rent as cr
ON cr.city_name = ct.city_name

9. Calculate the percentage growth (or decline) in sales over different time periods (monthly) by city.

WITH month_sales AS
(	
	SELECT 
	       city_name,
	       EXTRACT(MONTH FROM s.sale_date) as month,
	       EXTRACT(YEAR FROM s.sale_date) as year,
	       SUM(s.total) as total_sale
          FROM  sales as s
       JOIN customers as c
   ON s.customer_id = c.customer_id
   JOIN city as ci
   ON ci.city_id = c.city_id
  GROUP BY 1, 2, 3
 ORDER BY 1, 3, 2
),  
growth_ratio
AS	
 (
       	SELECT    
             city_name,
             month,
              year,
              total_sale as current_sales,
	        LAG(total_sale, 1) OVER(PARTITION BY city_name ORDER BY year, month) as last_month_sale 
         FROM month_sales
)
     SELECT
	       city_name,
             month,
              year,
	        current_sales,
	        last_month_sale,
     ROUND((current_sales-last_month_sale)::numeric/last_month_sale::numeric, 2) as growth_ratio
	FROM growth_ratio
	        WHERE last_month_sale IS NOT NULL

	
10. Identify top 3 city based on highest sales, return city name, 
	total sale, total rent, total customers, estimated coffee consumer	

WITH city_table as	
(
	select 
	ci.city_name,
	SUM(s.total) as total_revenue,
	COUNT(DISTINCt s.customer_id) as total_cx,
	ROUND(
        	SUM(s.total)::numeric   
        	/COUNT(DISTINCt s.customer_id)::numeric   
           , 2) as avg_sale_per_cust
	
from sales as s
JOIN customers AS c
ON s.customer_id = c.customer_id
JOIN city as ci
ON c.city_id = ci.city_id
GROUP BY 1
ORDER BY 2 DESC
),
city_rent	
AS	
(
	SELECT 
      city_name,
      estimated_rent,
	ROUND((population*0.25)/1000000, 2) as estimated_coffee_consumers_in_millions
 FROM city     
)
   select
         cr.city_name,
         cr.estimated_rent as total_rent,
         ct.avg_sale_per_cust,
         ct.total_cx,   
	     total_revenue,
	     estimated_coffee_consumers_in_millions,
	    ROUND(cr.estimated_rent/ct.total_cx, 2) as avg_rent_per_cust
   FROM city_table as ct
JOIN city_rent as cr
ON cr.city_name = ct.city_name
ORDER BY 5 DESC


/*
--RECOMENDATIONS--
City 1. Pune
     1. avg_rent_per_cust is very less
     2. Highest total_revenue
     3. avg_sale_per_cust is also high

City 2. Delhi
     1. highest estmated_coffee_consumers_in_millions which is 7.75M
     2. avg_rent_per_cust is 330(less than 500)
     3. Highest total_cx is 68

City 3. Jaipur
     1. Highest total_cx is 69
     2. avg_rent_per_cust is vey less 156
     3. avg_sale_per_cust is btter which is  11.6k























	
         




















