# 版本改动说明 — 回归测试输入

## 版本
v2.3.1

## 改动摘要
优化支付回调逻辑：调整 MQ 消费重试策略，修改订单状态更新时序。

## 直接改动模块
- payment-service（支付回调处理）
- order-service（订单状态更新）
- mq-consumer（支付结果消息消费）

## 关联说明
- 涉及支付成功 → 订单状态流转链路
- 可能影响库存扣减、优惠券核销时序

## 参考样例
完整案例见 `examples/regression-test/sample_release_payment_callback.md`
