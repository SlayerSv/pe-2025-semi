-- =============================================
-- 1. Очистка (DROP) старых таблиц
-- =============================================
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS portfolio_positions CASCADE;
DROP TABLE IF EXISTS instruments CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS instrument_types CASCADE;
DROP TABLE IF EXISTS currencies CASCADE;

-- Очистка типов ENUM
DROP TYPE IF EXISTS operation_type_enum CASCADE;
DROP TYPE IF EXISTS order_status_enum CASCADE;

-- =============================================
-- 2. Создание структуры (DDL)
-- =============================================

-- Создаем ENUM типы для фиксированных значений
CREATE TYPE operation_type_enum AS ENUM ('BUY', 'SELL');
CREATE TYPE order_status_enum AS ENUM ('ACTIVE', 'EXECUTED', 'CANCELLED');

-- Справочник валют
CREATE TABLE currencies (
    code CHAR(3) PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

-- Справочник типов инструментов
CREATE TABLE instrument_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL -- Акция, Облигация, Фонд
);

-- Таблица пользователей
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    login VARCHAR(100) NOT NULL UNIQUE,
    full_name VARCHAR(200) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица финансовых инструментов
CREATE TABLE instruments (
    id SERIAL PRIMARY KEY,
    type_id INT REFERENCES instrument_types(id),
    ticker VARCHAR(20) NOT NULL UNIQUE, -- YNDX, SBER
    name VARCHAR(200) NOT NULL,
    currency_code CHAR(3) REFERENCES currencies(code),
    current_market_price DECIMAL(19,4), -- Текущая рыночная цена (важно для валидации)
    last_update_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица портфеля (текущее владение)
CREATE TABLE portfolio_positions (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id),
    instrument_id INT REFERENCES instruments(id),
    quantity INT NOT NULL,
    avg_buy_price DECIMAL(19,4) NOT NULL DEFAULT 0,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Уникальность: у юзера одна запись на один инструмент
    CONSTRAINT uniq_user_instrument UNIQUE (user_id, instrument_id),
    -- БИЗНЕС-ПРАВИЛО: Запрещено иметь отрицательное количество (Short squeeze)
    CONSTRAINT check_positive_qty CHECK (quantity >= 0) 
);

-- Таблица заявок (история и активные)
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id),
    instrument_id INT REFERENCES instruments(id),
    operation_type operation_type_enum NOT NULL,
    status order_status_enum NOT NULL DEFAULT 'ACTIVE',
    quantity INT NOT NULL CHECK (quantity > 0),
    price_per_unit DECIMAL(19,4) NOT NULL,
    total_amount DECIMAL(19,4) GENERATED ALWAYS AS (quantity * price_per_unit) STORED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    executed_at TIMESTAMP
);

-- =============================================
-- 3. Наполнение тестовыми данными (DML)
-- =============================================

-- Валюты
INSERT INTO currencies (code, name) VALUES 
('RUB', 'Российский рубль'),
('USD', 'Доллар США');

-- Типы
INSERT INTO instrument_types (name) VALUES 
('Акция'), ('Облигация'), ('ETF Фонд');

-- Пользователи
INSERT INTO users (login, full_name) VALUES 
('investor_pro', 'Иван Иванович Иванов'); -- ID = 1

-- Инструменты
-- YNDX: Рыночная цена 2500
INSERT INTO instruments (type_id, ticker, name, currency_code, current_market_price) 
VALUES (1, 'YNDX', 'Яндекс', 'RUB', 2500.00); -- ID = 1

-- SBER: Рыночная цена 260
INSERT INTO instruments (type_id, ticker, name, currency_code, current_market_price) 
VALUES (1, 'SBER', 'Сбербанк', 'RUB', 260.00); -- ID = 2

-- GAZP: Рыночная цена 170
INSERT INTO instruments (type_id, ticker, name, currency_code, current_market_price) 
VALUES (1, 'GAZP', 'Газпром', 'RUB', 170.00); -- ID = 3

-- Портфель пользователя (ID 1)
-- У Ивана есть 100 акций Яндекса (купленных по 2400) и 50 акций Сбера (по 250)
-- Газпрома у него НЕТ.
INSERT INTO portfolio_positions (user_id, instrument_id, quantity, avg_buy_price) VALUES
(1, 1, 100, 2400.00),
(1, 2, 50, 250.00);

-- История сделок (для отчета "Последние 10 сделок")
INSERT INTO orders (user_id, instrument_id, operation_type, status, quantity, price_per_unit, executed_at) VALUES
(1, 1, 'BUY', 'EXECUTED', 50, 2300.00, NOW() - INTERVAL '5 days'),
(1, 1, 'BUY', 'EXECUTED', 50, 2500.00, NOW() - INTERVAL '3 days'), -- Средняя стала 2400
(1, 2, 'BUY', 'EXECUTED', 50, 250.00, NOW() - INTERVAL '1 day');