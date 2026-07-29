# 常用排查 SQL

> **注意**：生产库只读、脱敏。SQL 仅作方向参考，执行前需 DBA/研发确认。

## 订单未更新场景

```sql
-- 1. 查订单当前状态
SELECT order_id, pay_status, order_status, updated_at
FROM order_info
WHERE order_id = '替换为实际ID';

-- 2. 查支付流水
SELECT pay_id, trade_no, pay_status, callback_time
FROM pay_record
WHERE order_id = '替换为实际ID';

-- 3. 查 MQ 消费或补偿记录（表名按实际库调整）
SELECT *
FROM mq_consume_log
WHERE biz_id = '替换为实际ID'
ORDER BY created_at DESC
LIMIT 20;
```

## 重复扣款 / 幂等场景

```sql
-- 查同一订单的支付记录数
SELECT order_id, COUNT(*) AS pay_count, GROUP_CONCAT(pay_id) AS pay_ids
FROM pay_record
WHERE order_id = '替换为实际ID'
GROUP BY order_id;

-- 查回调记录
SELECT *
FROM pay_callback_log
WHERE order_id = '替换为实际ID'
ORDER BY created_at DESC;
```

## 库存超卖场景

```sql
-- 查库存快照
SELECT sku_id, stock_qty, locked_qty, available_qty, updated_at
FROM stock_info
WHERE sku_id = '替换为实际SKU';

-- 查订单占用库存
SELECT order_id, sku_id, qty, status
FROM order_item
WHERE sku_id = '替换为实际SKU'
  AND status IN ('pending', 'paid')
ORDER BY created_at DESC
LIMIT 50;
```

## Token / 用户状态场景

```sql
-- 查用户 Token 状态（表名按实际库调整）
SELECT user_id, token, expire_at, refresh_token, updated_at
FROM user_token
WHERE user_id = '替换为实际用户ID'
ORDER BY updated_at DESC
LIMIT 5;
```

## 慢 SQL / 超时排查

```sql
-- 查近期异常订单（状态不一致）
SELECT order_id, pay_status, order_status, created_at, updated_at
FROM order_info
WHERE pay_status = 'PAID'
  AND order_status = 'UNPAID'
  AND updated_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
ORDER BY updated_at DESC
LIMIT 100;
```
