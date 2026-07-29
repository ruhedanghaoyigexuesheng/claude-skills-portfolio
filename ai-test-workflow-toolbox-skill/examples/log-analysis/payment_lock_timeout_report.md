# 日志排查报告 — 支付更新订单锁等待超时（日志排查示例）

> 对应日志：`assets/sample_logs/payment_lock_timeout.log`

## 1. 异常摘要

支付服务更新订单状态失败，数据库报 `lock wait timeout exceeded`（traceId=p987）。

## 2. 异常类型

数据库锁等待超时

## 3. 调用链

支付回调 → 支付服务更新订单状态 → 订单库（异常节点：行锁等待超时）

## 4. 疑似模块

- 业务：支付回调、订单状态更新
- 服务：payment-service、order-service（若订单更新在订单侧）
- 数据：订单表、支付流水表

## 5. 建议查看的日志

| 优先级 | 服务 | traceId | 时间窗 / 关键词 |
|--------|------|---------|-----------------|
| P0 | payment-service | p987 | 回调入口、update order status |
| P0 | order-service | p987 | 同 traceId 订单更新链路 |
| P1 | 订单库 slow/lock log | — | 16:33:05–16:33:15 |

## 6. 建议检查的接口 / SQL / 数据

- 订单表当前行锁与 `innodb_trx` / `innodb_locks`（只读）
- 同一订单号是否存在并发更新或重复回调
- 支付回调幂等键与消费记录

## 7. 建议验证步骤

1. 按订单号查是否重复支付回调
2. 对比 p987 各服务 span 耗时，定位锁等待发生点
3. 复现：并发回调 + 订单状态流转场景

## 8. 历史规律匹配

匹配 `lock wait timeout`：并发更新订单状态、事务未释放、索引不合理。

## 9. 风险等级

**P1** — 支付与订单状态一致性受影响，可能导致用户已付但订单未更新。

## 10. 缺失信息

- 订单号
- traceId 完整链路日志（除 payment-service 外）
- SQL 执行日志与并发请求记录

---

## 结构化附录（YAML）

```yaml
keywords:
  - payment-service
  - update order status failed
  - lock wait timeout exceeded
  - traceId=p987
exception_type: 数据库锁等待超时
call_chain_guess: 支付回调 → 更新订单状态 → 订单库
suspected_modules: [支付回调, 订单状态更新, 订单数据库]
history_match: 并发更新订单状态、事务未释放、索引不合理
suggestions:
  - 查订单表锁等待与 innodb 状态
  - 查支付回调是否重复触发
  - 查事务提交与回滚日志
missing_info:
  - 订单号
  - traceId 完整链路日志
  - SQL 执行日志
  - 并发请求记录
risk: P1（支付与订单状态一致性）
```
