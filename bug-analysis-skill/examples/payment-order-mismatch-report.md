# Bug 分析报告（样例）

> 综合案例：支付成功但订单未支付（端到端）

---

## 1. 输入摘要

| 字段 | 内容 |
|------|------|
| 标题 | 支付成功但订单仍显示未支付 |
| 环境 | 生产，App 3.2.0，order_id=ORD***123 |
| 复现步骤 | 下单 → 微信支付成功 → 回订单页 |
| 实际结果 | 状态「待支付」 |
| 预期结果 | 「已支付」 |
| 接口 | 回调返回 payStatus=SUCCESS |
| 日志 | order-service ERROR update status failed traceId=abc123 |

---

## 2. 问题现象

- 第三方支付渠道（微信）返回支付成功
- 支付回调接口响应 payStatus=SUCCESS
- 订单表状态字段仍为「待支付」
- 用户端订单详情页展示「待支付」，与后台状态一致
- 存在「支付态 vs 订单态」不一致
- order-service 日志出现 `update status failed`（traceId=abc123）

---

## 3. 影响模块

| 优先级 | 模块 | 关联原因 |
|--------|------|----------|
| P0 | 支付服务 | 回调接收与转发 |
| P0 | 订单服务 | 状态更新失败（日志已证实） |
| P0 | MQ/消息 | 支付→订单异步链路 |
| P1 | 库存 | 支付成功后库存确认 |
| P1 | 优惠券 | 核销/回退 |
| P1 | 对账/流水 | 支付流水与订单一致性 |

---

## 4. 日志排查建议

| 优先级 | 服务/路径 | 关键词 | 关注点 |
|--------|-----------|--------|--------|
| P0 | order-service | update status, update order failed | 更新失败原因（已有 ERROR） |
| P0 | payment-service | callback, notify, callback success | 回调是否完整处理 |
| P0 | mq-consumer | consume, retry, mq consume error | MQ 消费是否失败 |
| P1 | payment-service | transaction rollback | 是否触发回滚 |

**建议操作**：用 traceId=abc123 串联 order-service、payment-service、mq-consumer 全链路日志。

---

## 5. SQL 排查建议

> 生产库只读、脱敏，执行前需 DBA/研发确认。

```sql
-- 1. 查订单当前状态
SELECT order_id, pay_status, order_status, updated_at
FROM order_info
WHERE order_id = 'ORD***123';

-- 2. 查支付流水
SELECT pay_id, trade_no, pay_status, callback_time
FROM pay_record
WHERE order_id = 'ORD***123';

-- 3. 查 MQ 消费记录
SELECT *
FROM mq_consume_log
WHERE biz_id = 'ORD***123'
ORDER BY created_at DESC
LIMIT 20;
```

**预期对比**：pay_record.pay_status=SUCCESS 但 order_info.order_status=UNPAID → 确认状态不一致。

---

## 6. 历史 Bug 关联

- **[高相似] BUG-2024-088**：MQ 消费失败导致订单未更新（标签：支付成功、订单未更新、MQ；日志特征：update order failed, mq consume error）
- **[中相似] BUG-2023-041**：支付回调重复，幂等未拦住（标签：支付回调重复）

---

## 7. 回归范围

### 必测（P0 链路）

- 支付下单全流程
- 支付回调处理
- 订单状态查询（列表 + 详情）
- 支付成功后订单状态变更

### 建议测（关联模块）

- 库存扣减/确认
- 优惠券核销
- 支付流水记录
- MQ 消费重试机制

### 抽测（低关联）

- 退款流程（状态回退）
- 对账任务

---

## 8. 风险等级

**等级**：P1（倾向 P0 若生产大面积出现）

**理由**：核心交易链路状态不一致，用户支付成功但无法完成交易；已有 ERROR 日志证实 order-service 更新失败，需 24h 内修复验证。若影响用户量大或涉及资金对账，应升级为 P0。

---

## 9. 待验证假设

- [待验证] MQ 消费失败是否为根因（需查 mq_consume_log）
- [待验证] 支付回调是否完整到达 order-service（需查 payment-service 日志）
- [待验证] 是否存在事务回滚导致状态未提交

---

## 10. 人工复核清单

- [x] 输入信息完整
- [x] 现象描述无推测性语句
- [x] 影响模块无遗漏
- [x] 日志关键词已按优先级排序
- [x] SQL 可改参数执行
- [x] 历史 Bug 关联合理
- [x] 回归范围分三级
- [x] 风险等级有理由支撑
