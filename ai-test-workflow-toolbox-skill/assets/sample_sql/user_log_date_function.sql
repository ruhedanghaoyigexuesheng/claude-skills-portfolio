-- A1-3：日志表函数包裹索引字段
-- 业务：运营后台按日查用户行为；user_log 2 亿+ 行
SELECT * FROM user_log
WHERE date(create_time) = '2026-05-20';
