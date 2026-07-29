# 异常类型映射表

## 目标

从「看到错误」升级到「判断错误类别」，并给出常见排查方向。

| 类别 | 典型关键词 | 常见排查方向 |
|------|------------|--------------|
| 系统异常 | NullPointerException、IndexOutOfBounds | 空指针、数组越界、代码分支 |
| 网络异常 | timeout、connection refused、reset | 下游慢、网络、连接池 |
| 数据库异常 | deadlock、lock wait timeout、duplicate key | 锁、索引、幂等、慢 SQL |
| 缓存异常 | Redis timeout、cache miss、pool exhausted | Redis、连接池、热点 key |
| MQ 异常 | send failed、consumer error、retry | 消费重复、堆积、死信 |
| 权限异常 | 401、403、permission denied | 鉴权、角色、Token |
| 业务异常 | 库存不足、订单状态非法 | 业务规则、状态机 |

## 输出格式

```yaml
exception_type: 数据库唯一键冲突
common_causes:
  - 重复提交
  - 幂等控制不足
  - MQ 重复消费
suggested_checks:
  - 请求是否重复
  - 唯一索引字段
  - MQ 消费记录
```

## 归类规则

1. 一条日志可命中多个关键词，选**最具体**的类别（如 `duplicate key` → 数据库，而非系统异常）
2. `timeout` 需结合上下文：服务间调用 → 网络异常；Redis → 缓存异常
3. 无法归类时标注「待确认」，不强行归入系统异常
