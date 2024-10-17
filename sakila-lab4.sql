USE sakila;

-- 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system

SELECT f.title AS Title, COUNT(i.film_id) AS 'Numero de copias'
FROM film f
JOIN inventory i ON i.film_id = f.film_id
WHERE f.title LIKE 'Hunchback Impossible'
GROUP BY f.title;

SELECT f.title AS Title, 
       (SELECT COUNT(i.inventory_id)
        FROM inventory i
        WHERE i.film_id = f.film_id) AS Copies
FROM film f
WHERE f.title = 'Hunchback Impossible';

-- 2. List all films whose length is longer than the average length of all the films in the Sakila database.
SELECT AVG(length)
FROM film;

SELECT title AS Title, length
FROM film
WHERE length > (SELECT AVG(length) FROM film)
ORDER BY length DESC;

-- 3. Use a subquery to display all actors who appear in the film "Alone Trip"
SELECT CONCAT(a.first_name, ' ' ,a.last_name) AS 'Actores de Alone Trip'
FROM actor a
JOIN film_actor fa ON fa.actor_id = a.actor_id
JOIN film f ON f.film_id = fa.film_id
WHERE f.title = 'Alone Trip';

SELECT f.film_id 
FROM film f 
WHERE f.title = 'Alone Trip';

SELECT CONCAT(a.first_name, ' ' ,a.last_name) AS 'Actores de Alone Trip'
FROM actor a
JOIN film_actor fa ON fa.actor_id = a.actor_id
WHERE fa.film_id = (SELECT f.film_id 
                    FROM film f 
                    WHERE f.title = 'Alone Trip');

-- 4. Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.
SELECT *
FROM category;

SELECT c.category_id
FROM category c
WHERE c.name = 'Family';

SELECT f.title AS 'Peliculas familiares'
FROM film f
JOIN film_category fc ON fc.film_id = f.film_id
WHERE fc.category_id = (SELECT c.category_id
						FROM category c
						WHERE c.name = 'Family');

SELECT f.title AS 'Peliculas familiares'
FROM film f
JOIN film_category fc ON fc.film_id = f.film_id
JOIN category c ON c.category_id = fc.category_id
WHERE c.name = 'Family';

-- 5 Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the relevant tables and their primary and foreign keys.
SELECT *
FROM country;

SELECT CONCAT(cu.first_name, ' ', cu.last_name) AS 'Nombres', cu.email
FROM customer cu
JOIN address a ON a.address_id = cu.address_id
JOIN city ci ON ci.city_id = a.city_id
JOIN country co ON co.country_id = ci.country_id
WHERE co.country = 'Canada';

-- 6. Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number of films. First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.

SELECT a.actor_id, COUNT(fa.film_id)
FROM actor a
JOIN film_actor fa ON fa.actor_id = a.actor_id
GROUP BY a.actor_id
ORDER BY COUNT(fa.film_id) DESC
LIMIT 1;

SELECT f.title AS 'Peliculas con el actor mas prolific'
FROM film f
JOIN film_actor fa ON fa.film_id = f.film_id
WHERE fa.actor_id = (
    SELECT a.actor_id
    FROM actor a
    JOIN film_actor fa ON fa.actor_id = a.actor_id
    GROUP BY a.actor_id
    ORDER BY COUNT(fa.film_id) DESC
    LIMIT 1);
    
-- 7.Find the films rented by the most profitable customer in the Sakila database. You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.

SELECT cu.customer_id
FROM customer cu
JOIN payment p ON p.customer_id = cu.customer_id
GROUP BY cu.customer_id
ORDER BY SUM(p.amount) DESC
LIMIT 1;

SELECT DISTINCT f.title AS 'Peliculas alquiladas por el cliente mas frecuente'
FROM film f
JOIN inventory i ON i.film_id = f.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
JOIN payment p ON p.rental_id = r.rental_id
JOIN customer cu ON cu.customer_id = p.customer_id
WHERE cu.customer_id = (
	SELECT cu.customer_id
	FROM customer cu
	JOIN payment p ON p.customer_id = cu.customer_id
	GROUP BY cu.customer_id
	ORDER BY SUM(p.amount) DESC
	LIMIT 1);
    
-- 8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. You can use subqueries to accomplish this.
SELECT customer_id, SUM(amount) AS gasto_total_cliente
FROM payment
GROUP BY customer_id;

SELECT AVG(gasto_total_cliente) AS promedio_gastado
FROM (
    SELECT customer_id, SUM(amount) AS gasto_total_cliente
    FROM payment
    GROUP BY customer_id
) AS gasto_cliente;

SELECT customer_id, SUM(amount) AS gasto_total_cliente
FROM payment
GROUP BY customer_id
HAVING gasto_total_cliente > (SELECT AVG(gasto_total_cliente) 
    FROM (
        SELECT customer_id, SUM(amount) AS gasto_total_cliente
        FROM payment
        GROUP BY customer_id
    ) AS total_por_cliente
);

