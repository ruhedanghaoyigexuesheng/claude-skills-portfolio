# 项目历史日志规律库

> 每次线上事故复盘，将「日志特征 → 根因 → 修复」追加到本表，AI 会越用越准。

| 日志特征 | 常见原因 | 建议先看 |
|----------|----------|----------|
| connection refused | 下游未启动、地址错误、网络不通 | 服务健康检查、注册中心 |
| duplicate key | 重复提交、幂等失败、MQ 重复消费 | 订单号生成、消费位点 |
| lock wait timeout | 事务未释放、并发更新同一行 | 锁等待、事务日志 |
| Redis timeout | 连接池耗尽、Redis 阻塞、网络抖动 | Redis 监控、慢命令 |
| Read timed out / SocketTimeoutException | 下游慢、慢 SQL、超时配置过短 | 下游接口耗时、连接池、超时参数 |
| MQ consumer error / retry exhausted | 消费逻辑异常、消息堆积、死信 | 消费组 lag、死信队列 |
| update order status failed | 状态机冲突、并发更新、回调重复 | 订单状态流转、支付回调幂等 |
| ERROR order failed（无细节） | 证据不足，需补充 traceId 与上下文 | 禁止猜根因，先补采集 |

## 匹配输出格式

```yaml
matched_pattern: 唯一键冲突
high_frequency_causes:
  - 重复创建订单
  - 重复消费消息
  - 幂等校验缺失
checks:
  - 订单号生成逻辑
  - MQ 消费记录
  - 接口重复提交日志
```

## 维护说明

- 新增规律时保留「日志特征」为可 grep 的短语
- 注明环境差异（测试 vs 生产）若适用
- 无匹配时 workflow 应输出：「无历史匹配，建议将本案入库」
