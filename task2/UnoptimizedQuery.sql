use cinema_db;
SELECT
    c.id,
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    c.email,
    c.phone,
    (SELECT COUNT(b.id)
     FROM bookings b
     WHERE b.client_id = c.id
     AND MONTH(b.booking_date) = 7
     AND YEAR(b.booking_date) = 2023) AS total_bookings,
    (SELECT SUM(b.price)
     FROM bookings b
     WHERE b.client_id = c.id
     AND MONTH(b.booking_date) = 7
     AND YEAR(b.booking_date) = 2023) AS total_spent,
    (SELECT AVG(b.price)
     FROM bookings b
     WHERE b.client_id = c.id
     AND MONTH(b.booking_date) = 7
     AND YEAR(b.booking_date) = 2023) AS avg_spent,
    (SELECT GROUP_CONCAT(DISTINCT m.title ORDER BY m.title SEPARATOR ', ')
     FROM bookings b
     JOIN movies m ON b.movie_id = m.id
     WHERE b.client_id = c.id
     AND MONTH(b.booking_date) = 7
     AND YEAR(b.booking_date) = 2023) AS movies_watched,
    (SELECT COUNT(DISTINCT b2.client_id)
     FROM bookings b2
     WHERE MONTH(b2.booking_date) = 7
     AND YEAR(b2.booking_date) = 2023
     AND b2.price > 20) AS count_high_spenders
FROM clients c
WHERE c.id IN (
    SELECT DISTINCT b.client_id
    FROM bookings b
    WHERE MONTH(b.booking_date) = 7
    AND YEAR(b.booking_date) = 2023
)
ORDER BY total_spent DESC
LIMIT 10;
