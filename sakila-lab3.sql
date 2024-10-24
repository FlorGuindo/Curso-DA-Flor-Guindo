USE sakila;

-- 1 List the number of films per category.

SELECT c.name AS category_name, COUNT(f.film_id) AS film_count
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN film f ON fc.film_id = f.film_id
GROUP BY c.category_id
ORDER BY film_count DESC;

-- 2 Retrieve the store ID, city, and country for each store.

SELECT s.store_id, ci.city, co.country
FROM store s
JOIN address a on s.address_id = a.address_id
JOIN city ci on a.city_id = ci.city_id
JOIN country co on ci.country_id = co.country_id
GROUP BY s.store_id;

-- 3. Calculate the total revenue generated by each store in dollars.
SELECT *
FROM payment;
SELECT *
FROM customer;

SELECT s.store_id, SUM(p.amount) AS 'Total Revenue'
FROM store s
JOIN customer c on c.store_id = s.store_id
JOIN payment p on p.customer_id = c.customer_id
GROUP BY s.store_id;

-- 4. Determine the average running time of films for each category.
SELECT c.name AS category_name, AVG(f.length) AS 'duracion media'
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN film f ON fc.film_id = f.film_id
GROUP BY c.category_id;
-- 5. Identify the film categories with the longest average running time.
SELECT c.name AS category_name, AVG(f.length) AS duracion
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN film f ON fc.film_id = f.film_id
GROUP BY c.category_id
ORDER BY duracion DESC;
-- 6. Display the top 10 most frequently rented movies in descending order.
-- rental invetory film
SELECT f.title as Title, COUNT(r.rental_id) as 'Veces alquiladas'
FROM film f
JOIN inventory i ON i.film_id = f.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
GROUP BY f.film_id
ORDER BY COUNT(i.inventory_id) DESC
LIMIT 10;
-- 7. Determine if "Academy Dinosaur" can be rented from Store 1.
SELECT
  CASE
    WHEN i.inventory_id IS NOT NULL THEN 'Available'
    ELSE 'NOT available'
  END AS availability
FROM film f
LEFT JOIN inventory i ON f.film_id = i.film_id AND i.store_id = 1
WHERE f.title = 'Academy Dinosaur';
-- 8 Provide a list of all distinct film titles, along with their availability status in the inventory. Include a column indicating whether each title is 'Available' or 'NOT available.' Note that there are 42 titles that are not in the inventory, and this information can be obtained using a CASE statement combined with IFNULL."
SELECT 
DISTINCT f.title,
	CASE
		WHEN i.inventory_id IS NOT NULL THEN 'Available'
		ELSE 'NOT available'
	END AS availability
from film f
LEFT JOIN inventory i ON f.film_id = i.film_id;