use cinema_db;
CREATE INDEX idx_booking_date ON bookings (booking_date);
CREATE INDEX idx_client_id ON bookings (client_id);
CREATE INDEX idx_movie_id ON bookings (movie_id);
CREATE INDEX idx_price ON bookings (price);

WITH client_spending AS (
    SELECT
        b.client_id,
        COUNT(b.id) AS total_bookings,
        SUM(b.price) AS total_spent,
        AVG(b.price) AS avg_spent,
        GROUP_CONCAT(DISTINCT m.title ORDER BY m.title SEPARATOR ', ') AS movies_watched
    FROM bookings b
    JOIN movies m ON b.movie_id = m.id
    WHERE MONTH(b.booking_date) = 7 AND YEAR(b.booking_date) = 2023
    GROUP BY b.client_id
),
high_spenders AS (
    SELECT
        client_id
    FROM bookings b
    WHERE MONTH(b.booking_date) = 7 AND YEAR(b.booking_date) = 2023
    AND b.price > 20
    GROUP BY client_id
)
SELECT
    c.id,
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    c.email,
    c.phone,
    cs.total_bookings,
    cs.total_spent,
    cs.avg_spent,
    cs.movies_watched,
    (SELECT COUNT(DISTINCT hs.client_id) FROM high_spenders hs) AS count_high_spenders
FROM clients c
JOIN client_spending cs ON c.id = cs.client_id
ORDER BY cs.total_spent DESC
LIMIT 10;
