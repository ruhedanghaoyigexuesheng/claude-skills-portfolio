-- A1-5：前缀模糊查询
-- 业务：订单号搜索；like 前缀通配导致索引失效
SELECT * FROM order_info
WHERE order_no LIKE '%20260520%'
LIMIT 50;
