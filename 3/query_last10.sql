SELECT 
    o.executed_at::date,
    o.operation_type,
    t.name,
    i.ticker,
    o.quantity,
    o.price_per_unit,
    i.currency_code
FROM 
    orders o
JOIN 
    instruments i ON o.instrument_id = i.id
JOIN 
    instrument_types t ON i.type_id = t.id
WHERE 
    o.user_id = 1 
    AND o.status = 'EXECUTED'
ORDER BY 
    o.executed_at DESC
LIMIT 10;