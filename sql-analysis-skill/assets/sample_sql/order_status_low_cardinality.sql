-- A1-4：低区分度 where + order by（无深分页）
-- 业务：待处理订单全量拉取；status=1 约占 35%
SELECT order_no, status, create_time
FROM order_info
WHERE status = 1
ORDER BY create_time DESC;
