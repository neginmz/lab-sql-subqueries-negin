use sakila;
--  Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system
SELECT 
    film_id,
    title,
    (
        SELECT COUNT(*) 
        FROM inventory 
        WHERE film_id = (
            SELECT film_id 
            FROM film 
            WHERE title = 'Hunchback Impossible'
        )
    ) AS copies_in_inventory
FROM 
    film
WHERE 
    title = 'Hunchback Impossible';
-- List all films whose length is longer than the average length of all the films in the Sakila database.
SELECT 
    film_id, 
    title, 
    length
FROM 
    film
WHERE 
    length > (SELECT AVG(length) FROM film);
   -- Use a subquery to display all actors who appear in the film "Alone Trip". 
    
    SELECT
    actor_id,
    first_name,
    last_name
FROM
    actor
WHERE
    actor_id IN (
        SELECT
            actor_id
        FROM
            film_actor
        JOIN
            film ON film_actor.film_id = film.film_id
        WHERE
            film.title = 'Alone Trip'
    );

-- Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films
SELECT 
    film.film_id,
    title
FROM 
    film
JOIN 
    film_category ON film.film_id = film_category.film_id
JOIN 
    category ON film_category.category_id = category.category_id
WHERE 
    category.name = 'Family';
  -- Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the relevant tables and their primary and foreign keys.
  SELECT 
    first_name,
    last_name,
    email
FROM 
    customer
JOIN 
    address ON customer.address_id = address.address_id
JOIN 
    city ON address.city_id = city.city_id
JOIN 
    country ON city.country_id = country.country_id
WHERE 
    country.country = 'Canada';
    -- second approach
    SELECT 
    first_name,
    last_name,
    email
FROM 
    customer
WHERE 
    address_id IN (
        SELECT 
            address_id
        FROM 
            address
        WHERE 
            city_id IN (
                SELECT 
                    city_id
                FROM 
                    city
                WHERE 
                    country_id IN (
                        SELECT 
                            country_id
                        FROM 
                            country
                        WHERE 
                            country = 'Canada'
                    )
            )
    );
-- Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number of films. First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.
SELECT
    film.film_id,
    film.title
FROM
    film
JOIN
    film_actor ON film.film_id = film_actor.film_id
WHERE
    film_actor.actor_id = (
        SELECT
            actor_id
        FROM
            film_actor
        GROUP BY
            actor_id
        ORDER BY
            COUNT(*) DESC
        LIMIT 1
    );

-- Find the films rented by the most profitable customer in the Sakila database. You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments
SELECT 
    film.film_id,
    film.title
FROM 
    film
JOIN 
    inventory ON film.film_id = inventory.film_id
JOIN 
    rental ON inventory.inventory_id = rental.inventory_id
JOIN 
    payment ON rental.customer_id = payment.customer_id
WHERE 
    rental.customer_id = (
        SELECT 
            customer_id
        FROM 
            payment
        GROUP BY 
            customer_id
        ORDER BY 
            SUM(amount) DESC
        LIMIT 1
    )
    group by film_id;
-- Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. You can use subqueries to accomplish this.
SELECT
    customer.customer_id,
    SUM(payment.amount) AS total_amount_spent
FROM
    customer
JOIN
    payment ON customer.customer_id = payment.customer_id
GROUP BY
    customer.customer_id
HAVING
    total_amount_spent > (
        SELECT
            AVG(avg_payments)
        FROM
            (SELECT
                customer_id,
                SUM(amount) AS avg_payments
            FROM
                payment
            GROUP BY
                customer_id) AS avg_payment_subquery
    );
