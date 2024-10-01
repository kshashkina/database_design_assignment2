import mysql.connector
import uuid
from faker import Faker
import random
from datetime import datetime, timedelta

HOST = 'localhost'
USER = 'root'
PASSWORD = '-Nt+ab&AkDL5idx'
DATABASE = 'cinema_db'

connection = mysql.connector.connect(
    host=HOST,
    user=USER,
    password=PASSWORD,
    database=DATABASE
)

cursor = connection.cursor()
fake = Faker()

print("Inserting data into clients table...")
client_insert_query = """
    INSERT INTO clients (id, first_name, last_name, email, phone, membership_status) 
    VALUES (%s, %s, %s, %s, %s, %s)
"""
clients_data = [
    (str(uuid.uuid4()), fake.first_name(), fake.last_name(), fake.email(), fake.phone_number()[:15], random.choice(['regular', 'vip']))
    for _ in range(10000)
]
cursor.executemany(client_insert_query, clients_data)
connection.commit()
print("Data inserted into clients table.")

print("Inserting data into movies table...")
movie_insert_query = """
    INSERT INTO movies (title, genre, description, release_year) 
    VALUES (%s, %s, %s, %s)
"""
genres = ['Action', 'Comedy', 'Drama', 'Horror', 'Sci-Fi', 'Romance']
movies_data = [
    (fake.sentence(nb_words=3), random.choice(genres), fake.text(), random.randint(1990, 2024))
    for _ in range(1000)
]
cursor.executemany(movie_insert_query, movies_data)
connection.commit()
print("Data inserted into movies table.")

print("Inserting data into bookings table...")
booking_insert_query = """
    INSERT INTO bookings (booking_date, client_id, movie_id, seat_number, price) 
    VALUES (%s, %s, %s, %s, %s)
"""
booking_date_start = datetime.now() - timedelta(days=365 * 3)
bookings_data = [
    (booking_date_start + timedelta(days=random.randint(0, 365 * 3)), random.choice(clients_data)[0], random.randint(1, 1000), fake.bothify(text='??##'), round(random.uniform(5.0, 20.0), 2))
    for _ in range(100000)
]
chunk_size = 10000
for i in range(0, len(bookings_data), chunk_size):
    cursor.executemany(booking_insert_query, bookings_data[i:i + chunk_size])
    connection.commit()
    print(f"Inserted {i + chunk_size} rows into bookings table...")

print("Data inserted into bookings table.")

cursor.close()
connection.close()
