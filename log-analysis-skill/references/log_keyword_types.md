# 日志关键词类型与提取规则

## 目标

从噪音中提取「信号」，先不解释原因。输出 YAML 结构化结果。

## 关键词类型清单

| 类型 | 示例 | 提取要点 |
|------|------|----------|
| 错误级别 | ERROR、WARN、FATAL | 取最高严重级别 |
| 异常关键词 | timeout、exception、failed、refused、denied | 保留原始异常类名 |
| 服务名称 | order-service、payment-service、inventory-service | 区分 source / downstream |
| 链路标识 | traceId、requestId、spanId | 保留完整 ID 值 |
| 接口路径 | /api/order/create | 若有则提取 |
| 时间信息 | 发生时间、耗时、时间窗口 | 与 occurred_at 交叉校验 |

## 输出格式

```yaml
level: ERROR
source_service: order-service
downstream_service: inventory-service
exception_keywords:
  - SocketTimeoutException
  - Read timed out
trace_id: abc123
preliminary_direction: 订单服务调用库存服务读取超时
```

## 规则

1. **只提取，不推断根因**：`preliminary_direction` 仅描述日志字面可见的方向
2. **保留原文**：异常类名、服务名与日志一致，不翻译不缩写
3. **多服务并存**：用 `source_service` / `downstream_service` 区分调用方与被调方
4. **无 traceId**：字段留空并在后续 Step 7 标记缺失
