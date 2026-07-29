# 核心服务调用链路

## 订单创建

```
用户请求 → 网关 → 订单服务 → 库存服务 → 库存数据库
```

**典型异常节点**：`order-service call inventory-service timeout`

**可能原因（需证据支撑）**：

- 库存服务响应慢
- 库存数据库慢查询
- 网络连接异常
- 订单服务超时配置过短

## 支付回调

```
支付渠道 → 网关 → 支付服务 → 订单服务 → 订单数据库
                              ↘ MQ 通知
```

**典型异常节点**：`payment-service update order status failed`

## 库存扣减

```
订单服务 → 库存服务 → Redis 缓存 → 库存数据库
```

## 调用链分析输出模板

```yaml
entry: 订单创建接口
upstream: 网关
current: 订单服务
downstream: 库存服务
failure_node: 订单服务 → 库存服务 调用
preliminary: 库存服务或库存数据层存在响应超时风险
```

## 使用规则

1. 根据日志中的服务名选择最接近的链路模板
2. `failure_node` 只标注日志能证明的环节
3. 跨链路场景（如支付回调改订单）合并相关链路描述
