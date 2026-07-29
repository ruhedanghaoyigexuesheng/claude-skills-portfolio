# Bug 单（脱敏样例）

> 用于 Bug 分析 Prompt 完整案例（教程第十一节）。可 @ 引用配合 prompts/待测Prompt-Bug分析.md。

## Bug 标题

支付成功但订单状态仍显示未支付

## 环境信息

- 环境：生产
- 版本：App 3.2.0 / order-service build 20240612
- 订单号：ORD***789（脱敏）

## 复现步骤

1. 用户提交订单 order_id=ORD***789
2. 选择微信支付并完成支付
3. 支付渠道返回成功
4. 返回 App 订单详情页

## 实际结果

- 订单状态仍显示「待支付」
- 用户端与后台状态一致，均为未支付

## 预期结果

- 支付成功后订单状态应更新为「已支付」
- 用户端展示「已支付」

## 接口信息

- 支付回调：`POST /api/pay/callback/wechat`
- 回调响应：`{ "code": 0, "payStatus": "SUCCESS", "orderId": "ORD***789" }`

## 日志片段

```
2024-06-15 14:32:01.123 ERROR [order-service] traceId=abc123def456
  updateOrderStatus failed orderId=ORD***789 targetStatus=PAID
  cause: OptimisticLockException version mismatch
```

## 附件

- 截图：订单详情页显示待支付
- traceId：abc123def456
