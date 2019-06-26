-- Katelyn Burke - MySQL Homework - Data Science Bootcamp

USE sakila; 

DESCRIBE actor; 

SHOW COLUMNS FROM actor;

-- 1a. Display the first and last names of all actors from the table actor
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT CONCAT(first_name, ' ', last_name) AS Actor_Name FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, you know only the first name, "Joe."
SELECT * FROM actor WHERE first_name = 'JOE';

-- 2b. Find all actors whose last name contain the letters GEN
SELECT * FROM actor
    WHERE LOCATE('g', last_name)
      AND LOCATE('e', last_name)
      AND LOCATE('n', last_name);
      
-- 2c. Find all actors whose last names contain the letters LI
SELECT * FROM actor
      WHERE LOCATE('l', last_name)
      AND LOCATE('i', last_name)
      ORDER BY last_name, first_name;
      
-- 2d. Using IN, display the country_id and country columns of the following countries
SELECT country_id, country FROM country
where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Create a column in the table actor named description and use the data type BLOB
ALTER TABLE actor 
ADD description blob;

-- 3b. Delete the description column.
ALTER TABLE actor
DROP COLUMN description; 

-- 4a. List the last names of actors, as well as how many actors have that last name
SELECT last_name from actor;

SELECT last_name, count(*)
FROM actor 
group by last_name;

-- 4b. List last names of actors, only for names that are shared by at least two actors
SELECT last_name, count(*)
FROM actor 
group by last_name
having count(*)>2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS
select * from actor;
SET SQL_SAFE_UPDATES=0;
UPDATE actor
SET first_name = REPLACE(first_name, 'GROUCHO', 'HARPO') WHERE last_name='Williams';

-- 4d. In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name= REPLACE(first_name, 'HARPO','GROUCHO');

-- 5a. You cannot locate the schema of the address table. 
SHOW CREATE TABLE address;
select * from address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member.
select * from address;
select * from staff;

SELECT
	staff.first_name,
    staff.last_name,
    staff.address_id, 
    address.address,
    address.district,
    address.city_id,
    address.address_id,
    address.postal_code
FROM
	staff
		JOIN
	address ON staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005
select * from staff;
select * from payment; 

-- totals rung up in August 2005
SELECT
	staff.first_name,
    staff.last_name,
    payment.staff_id,
    payment.amount,
    payment.payment_date
FROM 
	staff
		JOIN
	payment on staff.staff_id = payment.staff_id AND payment.payment_date  LIKE '2005-08%';
    
-- total payment for each staff member
SELECT
	staff.staff_id AS 'Staff Member',
    SUM(payment.amount) AS 'Total Payment'
FROM staff
	INNER JOIN
	payment on staff.staff_id = payment.staff_id
    GROUP BY staff.staff_id;

-- 6c. List each film and the number of actors who are listed for that film.
select * from film_actor;
select * from film;

SELECT
	film.title AS 'Film Title',
    COUNT(film_actor.actor_id) AS 'Number of Actors'
FROM film_actor
	INNER JOIN
    film on film.film_id = film_actor.film_id
    GROUP BY film.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
-- Hunchback Impossible film id = 439
select * from film;
select * from inventory;

SELECT film_id, COUNT(*) as count FROM inventory GROUP BY film_id;

SELECT title,
( SELECT COUNT(*) FROM inventory
WHERE film.film_id = inventory.film_id )
AS 'Copies' from film
WHERE title = 'Hunchback Impossible';
-- 6 copies 

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name.
select * from payment;
select * from customer;

SELECT
	customer.first_name AS 'First Name',
    customer.last_name AS 'Last Name', 
    SUM(payment.amount) AS 'Total Amount Paid'
FROM payment
	JOIN
    customer on customer.customer_id = payment.customer_id
    GROUP BY payment.customer_id
    ORDER BY customer.last_name;
    
-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
-- English Language ID = 1
select * from film;
select * from language;

SELECT title
FROM film WHERE title
LIKE 'K%' OR title LIKE 'Q%'
AND title IN
(
SELECT title
FROM film
WHERE language_id = 1 
);

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select * from film_actor;
select * from actor;
select * from film;
-- Alone Trip film id = 17

SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
SELECT actor_id
FROM film_actor
WHERE film_id = 17
);

-- 7c. You want to run an email marketing campaign in Canada 
select * from customer;
select * from address;
select * from city;
select * from country;

SELECT
	customer.first_name,
    customer.last_name,
    customer.email,
    address.address_id
FROM address
	JOIN
    customer on customer.address_id = address.address_id
    JOIN
    city on city.city_id = address.city_id
    JOIN 
    country on country.country_id = city.country_id
    WHERE country.country = 'Canada';

-- 7d. Identify all movies categorized as family films.
-- Family is category 8 
select * from film;
select * from film_category;
select * from category;

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
));

-- 7e. Display the most frequently rented movies in descending order.
select * from rental;
select * from inventory;
select * from film;

SELECT film.title, COUNT(rental_id) AS 'Number of Rentals'
FROM rental
	JOIN 
    inventory on rental.inventory_id = inventory.inventory_id
	JOIN
    film on inventory.film_id = film.film_id
    GROUP BY film.title
    ORDER BY `Number of Rentals` DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select * from payment;
select * from rental;
select * from inventory;
select * from store;

SELECT
	store.store_id, SUM(amount) AS 'Business in Dollars'
FROM payment
	JOIN
    rental on payment.rental_id = rental.rental_id
    JOIN
    inventory on rental.inventory_id = inventory.inventory_id
    JOIN
    store on inventory.store_id = store.store_id
    GROUP BY store.store_id;
    
-- 7g. Write a query to display for each store its store ID, city, and country.
select * from store;
select * from city;
select * from country;
select * from address;

SELECT store.store_id, city, country
FROM store
	JOIN
    address on store.address_id = address.address_id
    JOIN
    city on address.city_id = city.city_id
    JOIN
    country on city.country_id = country.country_id;

-- 7h. List the top five genres in gross revenue in descending order.
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select * from category;
select * from film_category;
select * from inventory;
select * from payment;
select * from rental; 

SELECT 
	category.name AS 'Genre', SUM(payment.amount) AS 'Gross Revenue'
FROM category
	JOIN
    film_category on category.category_id = film_category.category_id
    JOIN
    inventory on film_category.film_id = inventory.film_id
    JOIN
    rental on inventory.inventory_id = rental.inventory_id
    JOIN
    payment on rental.rental_id = payment.rental_id
    GROUP BY category.name;
	
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue.
-- Use the solution from the problem above to create a view.
CREATE VIEW `revenue_by_genre` AS SELECT
	category.name AS 'Genre', SUM(payment.amount) AS 'Gross Revenue'
FROM category
	JOIN
    film_category on category.category_id = film_category.category_id
    JOIN
    inventory on film_category.film_id = inventory.film_id
    JOIN
    rental on inventory.inventory_id = rental.inventory_id
    JOIN
    payment on rental.rental_id = payment.rental_id
    GROUP BY category.name;

-- 8b. How would you display the view that you created in 8a?
SHOW CREATE VIEW `revenue_by_genre`;
SELECT * FROM `revenue_by_genre`;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW `revenue_by_genre`;