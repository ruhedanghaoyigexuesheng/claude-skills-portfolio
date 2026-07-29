-- 课堂练习：join + 深分页（课件第八节必做）
SELECT * FROM order_info o
LEFT JOIN user_info u ON o.user_id = u.id
WHERE o.status = 1
ORDER BY o.create_time DESC
LIMIT 50000, 20;
