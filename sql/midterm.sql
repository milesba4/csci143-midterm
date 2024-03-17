/* PROBLEM 1:
 *
 * The Office of Foreign Assets Control (OFAC) is the portion of the US government that enforces international sanctions.
 * OFAC is conducting an investigation of the Pagila company to see if you are complying with sanctions against North Korea.
 * Current sanctions limit the amount of money that can be transferred into or out of North Korea to $5000 per year.
 * (You don't have to read the official sanctions documents, but they're available online at <https://home.treasury.gov/policy-issues/financial-sanctions/sanctions-programs-and-country-information/north-korea-sanctions>.)
 * You have been assigned to assist the OFAC auditors.
 *
 * Write a SQL query that:
 * Computes the total revenue from customers in North Korea.
 *
 * NOTE:
 * All payments in the pagila database occurred in 2022,
 * so there is no need to do a breakdown of revenue per year.
 */

SELECT SUM(amount) FROM 
payment JOIN customer using (customer_id) 
JOIN address using (address_id)
JOIN city using (city_id)
JOIN country using (country_id)
WHERE country = 'North Korea';




/* PROBLEM 2:
 *
 * Management wants to hire a family-friendly actor to do a commercial,
 * and so they want to know which family-friendly actors generate the most revenue.
 *
 * Write a SQL query that:
 * Lists the first and last names of all actors who have appeared in movies in the "Family" category,
 * but that have never appeared in movies in the "Horror" category.
 * For each actor, you should also list the total amount that customers have paid to rent films that the actor has been in.
 * Order the results so that actors generating the most revenue are at the top.
 */

SELECT
    act.first_name,
    act.last_name,
    COALESCE(SUM(pay.amount), 0) AS total_revenue
FROM
    actor act
JOIN
    film_actor fact ON act.actor_id = fact.actor_id
LEFT JOIN
    inventory inv ON fact.film_id = inv.film_id
LEFT JOIN
    rental rent ON inv.inventory_id = rent.inventory_id
LEFT JOIN
    payment pay ON rent.rental_id = pay.rental_id
WHERE
    act.actor_id IN (
        SELECT DISTINCT fact.actor_id
        FROM
            film_actor fact
        JOIN
            film fil ON fact.film_id = fil.film_id
        JOIN
            film_category fcat ON fil.film_id = fcat.film_id
        JOIN
            category cat ON fcat.category_id = cat.category_id
        WHERE
            cat.name = 'Family'
    )
AND
    act.actor_id NOT IN (
        SELECT DISTINCT fact.actor_id
        FROM
            film_actor fact
        JOIN
            film fil ON fact.film_id = fil.film_id
        JOIN
            film_category fcat ON fil.film_id = fcat.film_id
        JOIN
            category cat ON fcat.category_id = cat.category_id
        WHERE
            cat.name = 'Horror'
    )
GROUP BY
    act.first_name, act.last_name
ORDER BY
    total_revenue DESC;



/* PROBLEM 3:
 *
 * You love the acting in AGENT TRUMAN, but you hate the actor RUSSELL BACALL.
 *
 * Write a SQL query that lists all of the actors who starred in AGENT TRUMAN
 * but have never co-starred with RUSSEL BACALL in any movie.
 */

SELECT
    act.first_name,
    act.last_name
FROM
    actor act
JOIN
    film_actor fact ON act.actor_id = fact.actor_id
LEFT JOIN
    inventory inv ON fact.film_id = inv.film_id
LEFT JOIN
    rental rent ON inv.inventory_id = rent.inventory_id
LEFT JOIN
    payment pay ON rent.rental_id = pay.rental_id
WHERE
    act.first_name || ' ' || act.last_name != 'RUSSELL BACALL'
AND
    act.actor_id NOT IN (
        SELECT
            fact2.actor_id
        FROM
            film_actor fact1
        JOIN
            film_actor fact2 ON fact1.film_id = fact2.film_id
        WHERE
            fact1.actor_id = (
                SELECT
                    actor_id
                FROM
                    actor
                WHERE
                    first_name = 'RUSSELL' AND last_name = 'BACALL'
            )
    )
AND
    act.actor_id IN (
        SELECT
            fact.actor_id
        FROM
            film_actor fact
        JOIN
            film fil ON fact.film_id = fil.film_id
        WHERE
            fil.title = 'AGENT TRUMAN'
    )
GROUP BY act.first_name, act.last_name;

/* PROBLEM 4:
 *
 * You want to watch a movie tonight.
 * But you're superstitious,
 * and don't want anything to do with the letter 'F'.
 * List the titles of all movies that:
 * 1) do not have the letter 'F' in their title,
 * 2) have no actors with the letter 'F' in their names (first or last),
 * 3) have never been rented by a customer with the letter 'F' in their names (first or last).
 *
 * NOTE:
 * Your results should not contain any duplicate titles.
 */

SELECT DISTINCT
    fil.title
FROM
    film fil
JOIN
    film_actor fact ON fil.film_id = fact.film_id
JOIN
    actor act ON fact.actor_id = act.actor_id
LEFT JOIN
    inventory inv ON fil.film_id = inv.film_id
LEFT JOIN
    rental rent ON inv.inventory_id = rent.inventory_id
LEFT JOIN
    customer cust ON rent.customer_id = cust.customer_id
WHERE
    fil.title NOT LIKE '%F%'
AND
    act.first_name NOT LIKE '%F%' AND act.last_name NOT LIKE '%F%'
AND
    (cust.first_name NOT LIKE '%F%' OR cust.first_name IS NULL) AND (cust.last_name NOT LIKE '%F%' OR cust.last_name IS NULL)
GROUP BY
    fil.title;
