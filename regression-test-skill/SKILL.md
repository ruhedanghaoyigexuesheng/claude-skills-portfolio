---
name: regression-test-workflow
version: 1.0.0
description: >-
  根据版本改动、历史 Bug、业务链路生成可执行回归测试清单（7 步工作流）。
  当用户提及版本改动、回归范围、影响分析、发布前测试范围、hotfix 后测什么时使用。
  触发词：回归测试、回归范围、影响分析、Release Note、发布前测什么。
metadata:
  requires:
    bins: []
---

# 回归测试工作流

> **CRITICAL — 执行前 MUST 先用 Read 工具读取 [`workflows/regression_testing.md`](workflows/regression_testing.md)，并加载其中标注的 references 文件。**

## 适用场景

- "这次改动要回归哪些模块" / "帮我做回归范围分析" / "发布前要测什么"
- "根据 Release Note 生成回归清单" / "hotfix 后影响范围"
- 版本发布前、hotfix 后、用户说「回归范围」「影响分析」「要测哪些」时

## 核心原则

回归不是「全量重测一遍」，而是 **根据改动精准识别影响范围**。合格输出必须说明：

- **为什么**这些模块要回归
- **哪些**是高风险（P0/P1）
- **哪些**需人工确认或裁剪

AI **不能**只说「测这些就够了」，也 **不能**替测试人决定「可以不上线」。

## 工作流概览

```
改动输入 → 解析直接改动模块 → 识别上下游影响 → 业务链路补全
    → 关联历史 Bug → 标记风险等级 → 输出回归清单 → 人工复核
```

| 步骤 | 名称 | 产出 | 参考文件 |
|------|------|------|----------|
| 1 | 解析改动输入 | 直接改动模块列表 | [`references/输入契约-回归.md`](references/输入契约-回归.md) |
| 2 | 识别上下游影响 | 影响模块清单 | [`references/module-impact-map.md`](references/module-impact-map.md) |
| 3 | 业务链路补全 | 链路级回归范围 | [`references/业务链路-支付.md`](references/业务链路-支付.md) 等 |
| 4 | 关联历史 Bug | Top N 必回归场景 | [`references/history-bugs-*.md`](references/) |
| 5 | 标记风险等级 | P0/P1/P2/P3 + 优先级 | [`references/回归-风险规则.md`](references/回归-风险规则.md) |
| 6 | 输出回归清单 | 可执行表格 | [`outputs/回归测试清单输出格式.md`](outputs/回归测试清单输出格式.md) |
| 7 | 人工复核 | 裁剪/补充 checkbox | 工作流末尾复核清单 |

## 执行规则

当用户要求做回归范围分析、生成回归清单时：

1. 读取本 Skill
2. **严格按** [`workflows/regression_testing.md`](workflows/regression_testing.md) 执行，不得跳步
3. 根据改动域加载对应的 `references/` 与 `assets/samples/` 文件
4. 最终输出 **必须** 符合 [`outputs/回归测试清单输出格式.md`](outputs/回归测试清单输出格式.md)

## 目录结构

```
regression-test-skill/
├── SKILL.md
├── workflows/
│   └── regression_testing.md
├── references/
│   ├── 输入契约-回归.md
│   ├── module-impact-map.md
│   ├── 业务链路-支付.md
│   ├── 业务链路-订单.md
│   ├── history-bugs-payment.md
│   ├── history-bugs-order.md
│   ├── P0-P3-风险定义.md
│   └── 回归-风险规则.md
├── outputs/
│   └── 回归测试清单输出格式.md
├── assets/
│   ├── samples/              # 版本说明、CSV 等
│   └── templates/            # 清单空白模板
```

## 执行步骤

1. **检查输入**：对照 [`references/输入契约-回归.md`](references/输入契约-回归.md)，缺信息则列出「待澄清项」，**禁止编造模块**
2. **执行工作流**：按 [`workflows/regression_testing.md`](workflows/regression_testing.md) 步骤 1～7 严格顺序执行
3. **加载参考资料**：根据改动域加载对应的 `references/` 与 `assets/samples/` 文件
4. **输出清单**：最终输出 **必须** 符合 [`outputs/回归测试清单输出格式.md`](outputs/回归测试清单输出格式.md)
5. **附复核清单**：输出末尾附「人工复核清单」，默认未勾选，由测试人填写

## 禁止

- 跳过历史 Bug 步骤
- 不标风险等级
- 只列模块名不写场景
- 不说明触发原因
- 所有项同一优先级
- 改动输入模糊时编造模块
- 替测试人决定「可以不上线」

## 附件与样例

| 编号 | 文件 | 用途 |
|------|------|------|
| A1 | [`assets/samples/sample_release_payment_callback.md`](assets/samples/sample_release_payment_callback.md) | 主案例输入（支付回调） |
| A2 | [`references/history-bugs-payment.md`](references/history-bugs-payment.md) | 支付域历史 Bug |
| A3 | [`references/业务链路-支付.md`](references/业务链路-支付.md) | 支付链路补全 |
| A4 | [`references/module-impact-map.md`](references/module-impact-map.md) | 模块影响映射 |
| A5 | [`references/P0-P3-风险定义.md`](references/P0-P3-风险定义.md) | 风险等级对齐 |
| A6 | [`assets/templates/regression_scope_template.md`](assets/templates/regression_scope_template.md) | 清单模板 |
| A7 | [`outputs/回归测试清单输出格式.md`](outputs/回归测试清单输出格式.md) | 输出格式规范 |
| A8 | [`assets/samples/release_scope.md`](assets/samples/release_scope.md) | 发布范围与裁剪 |

## 与其他工作流衔接

| 工作流 | 何时用 | 产出 |
|--------|--------|------|
| Bug 分析 | 已有缺陷要定位 | 根因、日志/SQL 方向 |
| 日志排查 | 有日志要收敛 | 异常关键词、排查建议 |
| **回归（本 Skill）** | **版本发布前** | **测什么、先测什么** |

典型串联：Bug 分析 → 修复 → **本工作流生成回归清单** → 执行用例

## 快速启动示例

在 IDE 中引用参考资料并粘贴版本说明：

```
@references/history-bugs-payment.md @references/业务链路-支付.md
@assets/samples/sample_release_payment_callback.md
请按 workflows/regression_testing.md 输出回归测试清单。
```

**验收标准**：输出含表格、P0 标记、触发原因、至少 3 条历史 Bug 关联。
