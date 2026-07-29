-- 案例：订单列表慢查询（课件第六节跟做案例）
-- 业务：订单列表；表 500 万行；现象：接口超时
SELECT * FROM order_info
WHERE status = 1
ORDER BY create_time DESC
LIMIT 100000, 20;
