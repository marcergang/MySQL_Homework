USE sakila;

#1a. Display the first and last names of all actors from the table .
SELECT * FROM actor;

#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column 
SELECT CONCAT(first_name, ' ', last_name) AS combined_name FROM actor;

#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
#What is one query would you use to obtain this information?
SELECT * FROM actor
WHERE first_name = 'Joe';

#2b. Find all actors whose last name contain the letters GEN
SELECT * FROM actor
WHERE last_name LIKE '%GEN%';

#2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name FROM actor
WHERE last_name LIKE '%LI%';

#2d. Using IN, display the  country_id and  country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

# 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` 
#named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor
ADD COLUMN description BLOB;

# 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor
DROP COLUMN description;

#4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) AS 'Total Last Name'
FROM actor
GROUP BY last_name;

#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) AS 'Total Last Name'
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) > 2;

#4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

#4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all!
#In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO';

#5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
describe address;

# 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT * FROM staff;
SELECT * FROM address;
SELECT staff.first_name, staff.last_name, address.address
FROM staff
INNER JOIN address ON
staff.address_id=address.address_id;

#6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT *
FROM staff AS st
INNER JOIN (
	SELECT staff_id, payment_date, 
	SUM(amount) AS sum_amount
	FROM payment AS py
    WHERE payment_date LIKE '2005-08%'
	GROUP BY staff_id) py
ON st.staff_id=py.staff_id;

#6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT f.film_id, f.title, COUNT(fa.actor_id) AS actor_count
FROM film AS f
INNER JOIN film_actor AS fa
ON f.film_id = fa.film_id
GROUP BY f.film_id;

 #6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
 SELECT i.film_id, f.title, COUNT(i.film_id) AS film_count
 FROM inventory AS i
 INNER JOIN film as f
 ON i.film_id = f.film_id
 WHERE title = 'Hunchback Impossible';
 
# 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name
SELECT c.customer_id, c.last_name, COUNT(p.amount) AS total_paid
FROM customer AS c
INNER JOIN payment AS p
ON c.customer_id = p.customer_id
GROUP BY customer_id
ORDER BY last_name DESC;

#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
#films starting with the letters `K` and `Q` have also soared in popularity. 
#Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT *
FROM language AS l
INNER JOIN (
	SELECT language_id, title
	FROM film AS f
    WHERE title LIKE 'K%' OR title LIKE 'Q%') f
ON l.language_id=f.language_id;

#7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
  SELECT actor_id
  FROM film_actor
  WHERE film_id IN
  (
   SELECT film_id
   FROM film
   WHERE title = 'Alone Trip'
  )
);

#7c. You want to run an email marketing campaign in Canada, 
#for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT email
FROM customer
WHERE address_id IN
  (
   SELECT address_id
   FROM address
   WHERE city_id IN
   (
     SELECT city_id
     FROM city
     WHERE country_id IN
     (
       SELECT country_id
       FROM country
       WHERE country = 'Canada'
  ))
);

#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
#Identify all movies categorized as _family_ films
SELECT title
FROM film
WHERE film_id IN
(
  SELECT film_id
  FROM film_category
  WHERE category_id IN
  (
   SELECT category_id
   FROM category
   WHERE name = 'Family'
  )
);

#7e. Display the most frequently rented movies in descending order
SELECT f.title, COUNT(r.inventory_id) AS rental_total
FROM film AS f
INNER JOIN inventory AS i
ON f.film_id = i.film_id
INNER JOIN rental AS r
ON i.inventory_id = r.inventory_id
GROUP BY title
ORDER BY rental_total DESC;

#7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, SUM(p.amount) AS total_amount
FROM store AS s
INNER JOIN staff AS st
ON s.store_id = st.store_id
INNER JOIN payment AS p
ON p.staff_id = st.staff_id
GROUP BY store_id;

#7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, c.city, cn.country
FROM store AS s
INNER JOIN address AS a
ON s.address_id = a.address_id
INNER JOIN city AS c
ON a.city_id = c.city_id
INNER JOIN country AS cn
ON c.country_id = cn.country_id
GROUP BY store_id;

#7h. List the top five genres in gross revenue in descending order. 
#(**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT cat.name, SUM(p.amount) AS total_amount
FROM category AS cat
INNER JOIN film_category AS fc
ON cat.category_id = fc.category_id
INNER JOIN inventory AS i
ON fc.film_id = i.film_id
INNER JOIN rental AS r
ON i.inventory_id = r.rental_id
INNER JOIN payment AS p
ON r.rental_id = p.rental_id
GROUP BY name
ORDER BY total_amount DESC LIMIT 5;

# 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
# Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five AS 
SELECT cat.name, SUM(p.amount) AS total_amount
FROM category AS cat
INNER JOIN film_category AS fc
ON cat.category_id = fc.category_id
INNER JOIN inventory AS i
ON fc.film_id = i.film_id
INNER JOIN rental AS r
ON i.inventory_id = r.rental_id
INNER JOIN payment AS p
ON r.rental_id = p.rental_id
GROUP BY name
ORDER BY total_amount DESC LIMIT 5;

#8b. How would you display the view that you created in 8a?
SELECT * FROM top_five;

#8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_five;








