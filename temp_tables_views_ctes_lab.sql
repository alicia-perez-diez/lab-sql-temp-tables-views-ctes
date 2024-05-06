USE sakila;

-- Step 1: Create a View
-- create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

DROP VIEW rental_summary_view;
CREATE VIEW rental_summary_view AS
SELECT c.customer_id AS customer_id, CONCAT(c.first_name, " ", c.last_name) AS customer_name, c.email AS email, COUNT(r.rental_id) AS rental_count
FROM customer AS c
JOIN rental AS r
ON c.customer_id = r.customer_id
GROUP BY customer_id;

SELECT * FROM rental_summary_view;

-- Create a Temporary Table that calculates the total amount paid by each customer (total_paid).
-- The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.

CREATE TEMPORARY TABLE payments_table AS
SELECT
	c.customer_id,
    c.customer_name,
    c.email,
    c.rental_count,
    SUM(p.amount) AS amount_paid 
FROM rental_summary_view AS c
LEFT JOIN payment AS p
ON c.customer_id = p.customer_id
GROUP BY c.customer_id;

SELECT * FROM payments_table;

-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
-- The CTE should include the customer's name, email address, rental count, and total amount paid.

WITH customer_payment_summary AS(
SELECT
	c.customer_name,
    c.email,
    c.rental_count,
    t.amount_paid
FROM rental_summary_view AS c
JOIN payments_table AS t
ON c.customer_id = t.customer_id
)
SELECT * FROM customer_payment_summary;

-- using the CTE, create the query to generate the final customer summary report
-- which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.

WITH customer_payment_summary AS (
	SELECT
		c.customer_name,
        c.email,
        c.rental_count,
        t.amount_paid,
        (t.amount_paid/c.rental_count) AS average_payment_per_rental
FROM rental_summary_view AS c
JOIN payments_table AS t
ON c.customer_id = t.customer_id
)
SELECT
	customer_name,
    email,
    rental_count,
    amount_paid,
    average_payment_per_rental
FROM customer_payment_summary;