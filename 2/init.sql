-- Создание таблиц
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(10, 2)
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP,
    customer_name VARCHAR(100)
);

CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(id),
    product_id INT REFERENCES products(id),
    quantity INT,
    price DECIMAL(10, 2)
);

-- Наполнение данными
INSERT INTO products (name, price) VALUES ('Сдобная булка', 150.00), ('Кофе', 200.00);
INSERT INTO orders (created_at, customer_name) VALUES 
('2023-10-25 10:00:00', 'Иван'),
('2023-10-25 14:30:00', 'Мария'),
('2023-10-26 09:00:00', 'Петр'); -- Другой день

INSERT INTO order_items (order_id, product_id, quantity, price) VALUES 
(1, 1, 2, 150.00), -- 2 булки Ивану
(1, 2, 1, 200.00),
(2, 1, 1, 150.00), -- 1 булка Марии
(3, 1, 5, 150.00);