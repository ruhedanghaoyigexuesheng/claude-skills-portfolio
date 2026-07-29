# 常见日志关键词

## 支付类

| 场景 | 关键词 | 关注点 |
|------|--------|--------|
| 支付回调 | `callback`, `notify`, `callback success` | 回调是否收到、签名校验 |
| 订单更新 | `update order`, `update status`, `update order failed` | 更新是否执行、失败原因 |
| MQ 消费 | `mq consume`, `consume failed`, `retry`, `mq send failed` | 消费失败、重试堆积 |
| 事务回滚 | `transaction rollback`, `rollback` | 是否触发回滚 |
| 幂等 | `duplicate`, `idempotent`, `repeat request` | 重复请求拦截 |

推荐检索路径：

```
payment callback / order update / mq consume / transaction rollback
```

## 库存类

| 场景 | 关键词 | 关注点 |
|------|--------|--------|
| 库存扣减 | `stock deduct`, `stock insufficient` | 扣减是否成功 |
| 超卖 | `oversell`, `negative stock` | 是否出现负库存 |
| 锁 | `lock timeout`, `lock failed`, `redis lock` | 分布式锁是否生效 |

## 鉴权类

| 场景 | 关键词 | 关注点 |
|------|--------|--------|
| Token | `token expired`, `token invalid`, `401` | Token 状态 |
| 刷新 | `refresh token`, `refresh failed` | 刷新机制 |
| 权限 | `permission denied`, `403` | 权限校验 |

## 性能/超时类

| 场景 | 关键词 | 关注点 |
|------|--------|--------|
| 超时 | `timeout`, `read timeout`, `connect timeout` | 超时环节 |
| 连接 | `connection refused`, `connection reset` | 连接问题 |
| 连接池 | `pool exhausted`, `pool timeout` | 池资源耗尽 |
| 慢查询 | `slow sql`, `query timeout` | SQL 性能 |

## 输出格式

分析时按以下表格输出，优先级 P0 最先排查：

```markdown
| 优先级 | 服务/路径 | 关键词 | 关注点 |
|--------|-----------|--------|--------|
```
