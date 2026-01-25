CREATE OR REPLACE PROCEDURE register_order(
    p_user_id INT,
    p_ticker VARCHAR,
    p_op_type operation_type_enum,
    p_qty INT,
    p_price DECIMAL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_inst_id INT;
    v_market_price DECIMAL;
    v_portfolio_qty INT;
    v_ticker VARCHAR;
BEGIN
    -- 1. Получаем ID инструмента и его РЫНОЧНУЮ цену из базы
    -- (В реальности цену обновляет отдельный сервис фоном)
    SELECT id, current_market_price, ticker 
    INTO v_inst_id, v_market_price, v_ticker
    FROM instruments 
    WHERE ticker = p_ticker;

    -- Если инструмента нет
    IF v_inst_id IS NULL THEN
        RAISE EXCEPTION 'Инструмент % не найден', p_ticker;
    END IF;

    -- 2. ВАЛИДАЦИЯ ЦЕНЫ (Техническая ошибка > 20%)
    -- Если цена сделки отличается от рыночной более чем на 20%
    IF ABS(p_price - v_market_price) / v_market_price > 0.20 THEN
        RAISE EXCEPTION 'Wrong price! Price: %, Market price: %. Difference is more than 20%%.', p_price, v_market_price;
    END IF;

    -- 3. ВАЛИДАЦИЯ БАЛАНСА (Только для продажи)
    IF p_op_type = 'SELL' THEN
        -- Блокируем строку (FOR UPDATE), чтобы избежать состояния гонки
        SELECT quantity INTO v_portfolio_qty 
        FROM portfolio_positions 
        WHERE user_id = p_user_id AND instrument_id = v_inst_id
        FOR UPDATE;
        
        IF COALESCE(v_portfolio_qty, 0) < p_qty THEN
             RAISE EXCEPTION 'Not enough for sale. Have: %, Need: %', COALESCE(v_portfolio_qty, 0), p_qty;
        END IF;
    END IF;

    -- 4. РЕГИСТРАЦИЯ ЗАЯВКИ (Если проверки пройдены)
    INSERT INTO orders (
        user_id, instrument_id, operation_type, status, 
        quantity, price_per_unit, created_at
    ) VALUES (
        p_user_id, v_inst_id, p_op_type, 'ACTIVE', 
        p_qty, p_price, NOW()
    );
    
    -- Вывод сообщения для демонстрации
    RAISE NOTICE 'Created: % (% items). Price: %', p_ticker, p_qty, (p_qty * p_price);
    
    -- Транзакция фиксируется автоматически при успешном завершении процедуры
END;
$$;