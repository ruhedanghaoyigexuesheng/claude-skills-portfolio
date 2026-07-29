# Bug 分析报告

---

## 1. 输入摘要

| 字段 | 内容 |
|------|------|
| **Bug 标题** | 支付成功但订单仍显示未支付 |
| **环境** | 生产，App 3.2.0 |
| **业务 ID** | order_id=ORD***123 |
| **复现步骤** | 下单 → 微信支付成功 → 返回订单页 |
| **实际结果** | 订单状态「待支付」 |
| **预期结果** | 订单状态「已支付」 |
| **接口信息** | 支付回调返回 `payStatus=SUCCESS` |
| **日志片段** | `order-service ERROR update status failed traceId=abc123` |

**输入校验**：必填字段齐全，可进入八步分析。

---

## 2. 问题现象

- 用户在微信渠道完成支付，第三方支付返回成功
- 支付回调接口响应 `payStatus=SUCCESS`
- 订单 `ORD***123` 在订单详情页仍展示「待支付」
- 用户端展示与预期「已支付」不一致
- 存在「支付态 SUCCESS」与「订单态 待支付」的状态不一致
- `order-service` 出现 ERROR 日志：`update status failed`，traceId=`abc123`
- 问题发生在生产环境（App 3.2.0）

---

## 3. 影响模块

| 优先级 | 模块/服务 | 关联原因 |
|--------|-----------|----------|
| **P0** | 支付服务 | 回调接收、签名校验、支付结果转发 |
| **P0** | 订单服务 | 日志已证实 `update status failed`，状态更新环节异常 |
| **P0** | MQ/消息 | 支付成功 → 订单更新的异步链路 |
| **P1** | 库存 | 支付成功后库存确认/扣减 |
| **P1** | 优惠券 | 核销或回退 |
| **P1** | 对账/流水 | 支付流水与订单状态一致性 |

---

## 4. 日志排查建议

**优先用 traceId=`abc123` 串联全链路日志。**

| 优先级 | 服务/路径 | 关键词 | 关注点 |
|--------|-----------|--------|--------|
| **P0** | order-service | `update status`, `update status failed`, `traceId=abc123` | 更新失败的具体异常类型、from/to 状态 |
| **P0** | payment-service | `callback`, `notify`, `payStatus=SUCCESS` | 回调是否完整处理、是否发出 MQ |
| **P0** | mq-consumer | `consume`, `retry`, `consume failed`, `order.pay.success` | MQ 是否消费失败、重试是否耗尽 |
| **P1** | order-service | `OptimisticLockException`, `version conflict` | 是否存在并发更新冲突 |
| **P1** | mq-consumer | `Connection timeout`, `order-service` | 消费端调用订单服务是否超时 |
| **P1** | payment-service | `transaction rollback`, `duplicate callback` | 是否回滚或重复回调 |

**建议排查顺序**：

1. 用 `traceId=abc123` 在 order-service 查完整 ERROR 堆栈
2. 向前追溯 payment-service 同 orderId 的 callback 日志
3. 查 mq-consumer 对该 orderId 的消费与重试记录

---

## 5. SQL 排查建议

> 生产库只读、脱敏，执行前需 DBA/研发确认。

```sql
-- 1. 查订单当前状态（验证状态不一致）
SELECT order_id, pay_status, order_status, version, updated_at, created_at
FROM order_info
WHERE order_id = 'ORD***123';

-- 2. 查支付流水（验证支付侧是否 SUCCESS）
SELECT pay_id, trade_no, pay_status, callback_time, created_at
FROM pay_record
WHERE order_id = 'ORD***123'
ORDER BY created_at DESC;

-- 3. 查 MQ 消费记录
SELECT *
FROM mq_consume_log
WHERE biz_id = 'ORD***123'
ORDER BY created_at DESC
LIMIT 20;

-- 4. 查近期同类异常（评估影响面）
SELECT order_id, pay_status, order_status, updated_at
FROM order_info
WHERE pay_status = 'PAID'
  AND order_status = 'UNPAID'
  AND updated_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
ORDER BY updated_at DESC
LIMIT 100;
```

**预期对比**：`pay_record.pay_status=SUCCESS` 且 `order_info.order_status=UNPAID` → 确认支付态与订单态不一致。

---

## 6. 历史 Bug 关联

| 相似度 | Bug ID | 描述 | 匹配依据 |
|--------|--------|------|----------|
| **高相似** | BUG-2024-088 | MQ 消费失败导致订单未更新 | 标签：支付成功、订单未更新、MQ；日志特征：`update order failed` / `update status failed` |
| **中相似** | BUG-2023-041 | 支付回调重复，幂等未拦住 | 同属支付回调链路；需排除重复回调 |
| **中相似** | BUG-2024-012 | 库存超卖，乐观锁冲突 | 若日志含 `OptimisticLockException`，需排查并发更新 |
| **低相似** | BUG-2024-055 | 接口超时、连接池耗尽 | 若 mq-consumer 出现 `Connection timeout` 则关联 |

---

## 7. 回归范围

### 必测（P0 链路）

- 支付下单全流程（微信渠道）
- 支付回调接收与处理
- 订单状态查询（列表 + 详情）
- 支付成功后订单状态由「待支付」→「已支付」
- MQ 消费失败后的重试与补偿

### 建议测（关联模块）

- 库存扣减/确认（支付成功后）
- 优惠券核销
- 支付流水写入与查询
- 并发场景下同一订单多次回调/更新
- App 3.2.0 版本回归

### 抽测（低关联）

- 退款流程（状态回退）
- 对账任务
- 其他支付渠道（支付宝等）

---

## 8. 风险等级

**等级：P1**（若生产大面积出现或涉及资金对账不一致，升级为 **P0**）

**理由**：

- 核心交易链路出现「支付成功但订单未支付」的状态不一致
- 用户已付款却无法完成交易，直接影响业务闭环
- 生产环境已有 ERROR 日志证实 order-service 更新失败
- 需 24 小时内修复并验证；若 SQL 第 4 条查出大量同类订单，应立即升级为 P0 并阻断发布

---

## 9. 待验证假设

> 以下仅为排查方向，**不能作为已确认根因**（当前仅有一条 order-service ERROR 日志）。

| # | 待验证假设 | 验证方式 |
|---|-----------|----------|
| 1 | MQ 消费失败，订单状态未更新 | 查 `mq_consume_log` + mq-consumer 日志 |
| 2 | order-service 更新时乐观锁冲突（version conflict） | 查 traceId=abc123 完整堆栈 + order_info.version |
| 3 | mq-consumer 调用 order-service 超时 | 查 mq-consumer 日志是否含 `Connection timeout` |
| 4 | 支付回调重复到达，幂等未正确处理 | 查 pay_callback_log 是否有多条同 orderId 记录 |
| 5 | 仅个别订单偶发 vs 批量异常 | 执行 SQL 第 4 条评估影响面 |

---

## 10. 人工复核清单

- [x] 输入信息完整
- [x] 现象描述无推测性语句
- [x] 影响模块无遗漏
- [x] 日志关键词已按优先级排序
- [x] SQL 可改 order_id 直接执行
- [x] 历史 Bug 关联合理
- [x] 回归范围分三级（必测/建议测/抽测）
- [x] 风险等级有理由支撑
- [ ] **待研发确认**：traceId=abc123 完整日志与 SQL 查询结果
- [ ] **待验证**：根因（当前仅完成现象收敛，未断言根因）

---

**下一步建议**：把 `traceId=abc123` 的完整 ERROR 堆栈，以及上述 SQL 1–3 的查询结果发给研发，可快速缩小到「MQ 消费失败」或「乐观锁冲突」等具体环节。
