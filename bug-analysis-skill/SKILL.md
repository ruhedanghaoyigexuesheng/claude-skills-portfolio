---
name: bug-analysis-workflow
version: 1.0.0
description: >-
  按八步工作流分析 Bug，输出结构化排查报告（现象、模块、日志、SQL、历史关联、回归范围、风险等级）。
  输入不完整时先追问。当用户需要分析 Bug、缺陷排查、拆 Bug、推荐排查方向或输出回归范围时使用。
  触发词：分析 Bug、Bug 分析、缺陷分析、排查方向、回归范围、拆 Bug。
---

# Bug 分析工作流

> **CRITICAL — 执行前 MUST 先用 Read 工具读取 `references/` 下全部参考文件。**

## 适用场景

- 用户提供 Bug 描述，需要结构化分析报告
- 需要推荐日志/SQL 排查方向，而非直接猜根因
- 需要关联历史 Bug、输出回归范围与风险等级
- 输入过于简略（如「订单有问题」）时，先追问补齐

## 执行顺序（必须逐步输出，禁止跳步）

1. **校验输入**：对照 [`references/bug-input-template.md`](references/bug-input-template.md)，缺项则列出待补充问题
2. **问题现象**：仅事实，列表输出（规则见 [`references/bug-analysis-workflow.md`](references/bug-analysis-workflow.md) Step 2）
3. **影响模块**：结合 [`references/module-map.md`](references/module-map.md)，列出服务/模块
4. **日志方向**：参考 [`references/log-keywords.md`](references/log-keywords.md)，表格输出（优先级、服务、关键词、关注点）
5. **SQL 方向**：参考 [`references/sql-snippets.md`](references/sql-snippets.md)，给出可改参数的 SELECT（标注只读）
6. **历史 Bug**：匹配 [`references/history-bugs.md`](references/history-bugs.md)，标注相似度
7. **回归范围**：必测 / 建议测 / 抽测 三级
8. **风险等级**：参考 [`references/risk-levels.md`](references/risk-levels.md)，P0–P3 + 1–2 句理由
9. **人工复核清单**：供测试打勾

详细规则见 [`references/bug-analysis-workflow.md`](references/bug-analysis-workflow.md)。

## 输出格式（固定）

```markdown
# Bug 分析报告

## 1. 输入摘要
## 2. 问题现象
## 3. 影响模块
## 4. 日志排查建议
## 5. SQL 排查建议
## 6. 历史 Bug 关联
## 7. 回归范围
## 8. 风险等级
## 9. 待验证假设（若有）
## 10. 人工复核清单
```

## 禁止行为

- 无日志/无数据时断言根因
- 跳过现象直接给「修复方案」
- 回归范围仅写「相关功能」等模糊表述
- 现象描述中出现「可能」「应该是」「大概」（应改写为事实或标注「待验证假设」）

## 参考样例

- 输入与期望输出对照：[`examples/payment-order-mismatch-report.md`](examples/payment-order-mismatch-report.md)
- 日志样例：[`examples/sample-error.log`](examples/sample-error.log)

## 场景速查

| 场景 | 重点模块 | 日志关键词 | 风险参考 |
|------|----------|------------|----------|
| 支付成功订单未支付 | 支付、订单、MQ | callback, update failed | P0/P1 |
| 库存超卖 | 库存、订单、购物车 | stock, oversell, lock | P0 |
| 登录 Token 失效 | 登录、鉴权、网关 | token, 401, refresh | P1 |
| 接口超时 | 网关、下游、DB | timeout, pool exhausted | P1/P2 |
