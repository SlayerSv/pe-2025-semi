SELECT 
    o.id AS order_id,
    o.created_at,
    o.customer_name,
    p.name AS product_name,
    oi.quantity,
    oi.price AS price_per_unit,
    (oi.quantity * oi.price) AS total_line_cost
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id
WHERE 
    p.name = 'Сдобная булка' 
    AND o.created_at >= '2023-10-25 00:00:00' 
    AND o.created_at <= '2023-10-25 23:59:59';