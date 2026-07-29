# 模块 → 负责人 / 值班（可选）

> 按实际项目填写；未配置时可跳过负责人，仅输出模块名。

| 模块 / 服务 | 业务域 | 负责人 | 值班群 / 备注 |
|-------------|--------|--------|---------------|
| order-service | 订单 | （待填写） | 下单、订单状态 |
| payment-service | 支付 | （待填写） | 支付、回调 |
| inventory-service | 库存 | （待填写） | 库存扣减、预占 |
| 订单数据库 | 数据 | （待填写） | 订单表、状态机 |
| 库存数据库 | 数据 | （待填写） | 库存表、锁 |
| Redis | 中间件 | （待填写） | 缓存、分布式锁 |
| MQ | 中间件 | （待填写） | 异步通知、消费 |

## 模块定位输出参考

```yaml
business_module: 支付回调
related_modules: [订单状态更新]
tech_direction: [数据库更新, MQ 通知]
focus_services: [payment-service, order-service]
focus_tables: [支付流水表, 订单状态表]
```
