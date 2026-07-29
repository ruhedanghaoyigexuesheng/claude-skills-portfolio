# 回归测试工作流

## Purpose

根据版本改动、历史 Bug、业务链路生成可执行回归清单。

## When to use

版本发布前、hotfix 后、用户说「回归范围」「影响分析」「要测哪些」时。

## 输入

- **必填**：改动说明（见 [`../references/输入契约-回归.md`](../references/输入契约-回归.md)）
- **加载**：[`../references/module-impact-map.md`](../references/module-impact-map.md)
- **加载**：[`../references/业务链路-*.md`](../references/)（按域选择）
- **加载**：[`../references/history-bugs-*.md`](../references/)（按域选择）
- **加载**：[`../references/回归-风险规则.md`](../references/回归-风险规则.md)
- **加载**：[`../references/P0-P3-风险定义.md`](../references/P0-P3-风险定义.md)

## 执行步骤（严格按序）

### Step 1：解析改动

- 提取：直接改动模块、变更类型（修复/优化/新增）
- 缺信息 → 列出待澄清，**禁止猜模块**

### Step 2：影响模块

- 查 [`module-impact-map.md`](../references/module-impact-map.md)，列出上下游影响模块
- 区分「直接改动」与「影响模块」

### Step 3：链路补全

- 沿业务链路（如 [`业务链路-支付.md`](../references/业务链路-支付.md)）检查是否有遗漏模块
- 输出链路级回归范围

### Step 4：历史 Bug

- 按模块 + 关键词匹配 `history-bugs-*.md`
- 无匹配 → 写「建议检索关键词：…」
- **禁止跳过本步骤**

### Step 5：风险分级

- 应用 [`回归-风险规则.md`](../references/回归-风险规则.md) 与 [`P0-P3-风险定义.md`](../references/P0-P3-风险定义.md)
- 为每项标注 P0/P1/P2/P3 与执行优先级（必须/重点/可选）

### Step 6：生成清单

- **必须**加载 [`../outputs/回归测试清单输出格式.md`](../outputs/回归测试清单输出格式.md)
- 输出 Markdown 表格，≥ 实际影响模块数对应的场景行
- 每行含：回归模块、回归场景、触发原因、关联历史 Bug、风险等级、执行优先级、测试建议

### Step 7：人工复核

- 附「人工复核清单」，默认未勾选，由人填写
- AI 不替测试人决定裁剪结果或上线结论

## 禁止

- 跳过历史 Bug 步骤
- 不标风险等级
- 只列模块名不写场景
- 不说明触发原因
- 所有项同一优先级
- 替测试人决定「可以不上线」

---

## 人工复核清单（测试人勾选）

- [ ] 核心链路无遗漏（支付→订单→库存→优惠券→退款，或当前域等价链路）
- [ ] P0 项已全部覆盖
- [ ] 历史 Bug 相关场景已纳入
- [ ] 无过度回归（与本次改动无关的模块已裁剪）
- [ ] 符合当前上线范围与资源（参考 [`release_scope.md`](../assets/samples/release_scope.md)）
- [ ] 需补充专项（性能/安全）已标注
