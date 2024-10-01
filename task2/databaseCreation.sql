CREATE DATABASE cinema_db;
USE cinema_db;

CREATE TABLE clients (
    id VARCHAR(36) PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(20),
    membership_status ENUM('regular', 'vip')
);

CREATE TABLE movies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255),
    genre VARCHAR(50),
    description TEXT,
    release_year INT
);

CREATE TABLE bookings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    booking_date DATETIME,
    client_id VARCHAR(36),
    movie_id INT,
    seat_number VARCHAR(10),
    price DECIMAL(10, 2),
    FOREIGN KEY (client_id) REFERENCES clients(id),
    FOREIGN KEY (movie_id) REFERENCES movies(id)
);
