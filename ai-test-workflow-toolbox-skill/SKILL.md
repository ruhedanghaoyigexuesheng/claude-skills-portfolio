---
name: lark-workflow-ai-test-toolbox
version: 1.0.0
description: "AI 测试工作流工具箱：整合 Bug 分析、日志排查、SQL 分析、回归测试、Prompt 测试五类助手，含统一入口、风险等级与人工复核规则，支持多助手联动实战。当用户提及 AI 测试工具箱、测试工作流工具箱、Bug+日志+SQL 联动分析、综合测试助手时使用。"
metadata:
  requires:
    bins: []
---

# AI 测试工作流工具箱

> **CRITICAL — 开始前 MUST 读取 `system/AI测试工作台总规则.md`。**

## 这是什么

将 5 个职责清晰的小助手整合为统一工具箱：

```
Bug 分析 + 日志排查 + SQL 分析 + 回归测试 + Prompt 测试
+ 统一 system 规则 + 统一 outputs + 联动工作流
```

**价值**：清晰入口 + 固定流程 + 统一输出，而非零散 Prompt。

## 任务路由（选一个入口，只执行对应 workflow）

| 用户意图 | 入口 | 工作流 | Prompt |
|----------|------|--------|--------|
| 分析 Bug、缺陷排查、回归范围 | Bug 分析 | [`workflows/Bug分析工作流.md`](workflows/Bug分析工作流.md) | [`prompts/Bug分析助手Prompt.md`](prompts/Bug分析助手Prompt.md) |
| 分析日志、traceId、报错排查 | 日志排查 | [`workflows/日志排查工作流.md`](workflows/日志排查工作流.md) | [`prompts/日志排查助手Prompt.md`](prompts/日志排查助手Prompt.md) |
| 慢查询、SQL 风险、索引 | SQL 分析 | [`workflows/SQL分析工作流.md`](workflows/SQL分析工作流.md) | [`prompts/SQL分析助手Prompt.md`](prompts/SQL分析助手Prompt.md) |
| 版本回归、发布测什么 | 回归测试 | [`workflows/回归测试工作流.md`](workflows/回归测试工作流.md) | [`prompts/回归测试助手Prompt.md`](prompts/回归测试助手Prompt.md) |
| Prompt 质量、稳定性、幻觉 | Prompt 测试 | [`workflows/Prompt测试工作流.md`](workflows/Prompt测试工作流.md) | [`prompts/Prompt测试助手Prompt.md`](prompts/Prompt测试助手Prompt.md) |
| 多助手联动（Bug+日志+SQL+回归） | 联动 | [`workflows/联动工作流.md`](workflows/联动工作流.md) | 按顺序调用各助手 Prompt |

## 统一规则（全局必遵）

| 文件 | 用途 |
|------|------|
| [`system/AI测试工作台总规则.md`](system/AI测试工作台总规则.md) | 总规则 |
| [`system/风险等级规则.md`](system/风险等级规则.md) | P0–P3 统一定义 |
| [`system/人工复核规则.md`](system/人工复核规则.md) | 输出文末 checklist |

## 业务资产（必须加载）

| 文件 | 助手 |
|------|------|
| [`assets/历史Bug库.md`](assets/历史Bug库.md) | Bug 分析 |
| [`assets/日志规律库.md`](assets/日志规律库.md) | 日志排查 |
| [`assets/SQL风险库.md`](assets/SQL风险库.md) | SQL 分析 |
| [`assets/回归规则库.md`](assets/回归规则库.md) | 回归测试 |
| [`assets/Prompt测试案例库.md`](assets/Prompt测试案例库.md) | Prompt 测试 |

## 输入模板

| 文件 | 助手 |
|------|------|
| [`templates/bug_input.yaml`](templates/bug_input.yaml) | Bug 分析 |
| [`templates/log_input.yaml`](templates/log_input.yaml) | 日志排查 |
| [`templates/sql_input.yaml`](templates/sql_input.yaml) | SQL 分析 |
| [`templates/release_change.md`](templates/release_change.md) | 回归测试 |
| [`templates/prompt_test_plan.md`](templates/prompt_test_plan.md) | Prompt 测试 |

## 输出格式

| 文件 |
|------|
| [`outputs/Bug分析输出格式.md`](outputs/Bug分析输出格式.md) |
| [`outputs/日志排查输出格式.md`](outputs/日志排查输出格式.md) |
| [`outputs/SQL分析输出格式.md`](outputs/SQL分析输出格式.md) |
| [`outputs/回归测试清单输出格式.md`](outputs/回归测试清单输出格式.md) |
| [`outputs/Prompt测试报告输出格式.md`](outputs/Prompt测试报告输出格式.md) |

## 案例目录（按助手区分，保留单课全部案例）

| 目录 | 内容 |
|------|------|
| [`examples/bug-analysis/`](examples/bug-analysis/) | 支付订单不一致报告、样例日志 |
| [`examples/log-analysis/`](examples/log-analysis/) | 锁超时完整报告 |
| [`examples/sql-analysis/`](examples/sql-analysis/) | 慢查询报告、EXPLAIN 样例 |
| [`examples/regression-test/`](examples/regression-test/) | 支付回调/订单取消发布案例 |
| [`examples/prompt-test/`](examples/prompt-test/) | 01–07 测试样本 + 稳定性对比 |
| [`examples/联动案例-支付成功订单未支付.md`](examples/联动案例-支付成功订单未支付.md) | 联动实战交付样例 |

## 详细参考（按子目录）

```
references/
├── bug-analysis/      # 八步规则、模块映射、历史 Bug
├── log-analysis/      # 关键词、异常类型、调用链
├── sql-analysis/      # 高危信号、DDL、输入契约
├── regression-test/   # 业务链路、影响映射、历史 Bug
└── prompt-test/       # 稳定性、幻觉、边界测试
```

## 快速启动

**单助手 — Bug 分析：**

```
@workflows/Bug分析工作流.md
@prompts/Bug分析助手Prompt.md
@templates/bug_input.yaml
@assets/历史Bug库.md

请按工作流输出 Bug 分析报告。
```

**联动实战：**

```
@workflows/联动工作流.md
@examples/联动案例-支付成功订单未支付.md

请按联动顺序执行 Bug → 日志 → SQL → 回归 四步（可选第 5 步 Prompt 测试）。
```

## 与单课 Skill 关系

本工具箱 **集成** 以下来源（已 copy 并统一路径）：

| 原 Skill | 工具箱位置 |
|----------|------------|
| `skills/bug-analysis-skill` | `references/bug-analysis/` + `examples/bug-analysis/` |
| `skills/log-analysis-skill` | `references/log-analysis/` + `assets/sample_logs/` |
| `skills/sql-analysis-skill` | `references/sql-analysis/` + `assets/sample_sql/` |
| `skills/regression-test-skill` | `references/regression-test/` + `examples/regression-test/` |
| `skills/prompt-test-skill` | `references/prompt-test/` + `examples/prompt-test/` |

单课 workflow 更新时，同步更新工具箱对应目录。

## 验收 checklist

- [ ] 5 个工作流（`workflows/`）
- [ ] 5 个助手 Prompt（`prompts/*助手Prompt.md`）
- [ ] 5 个输出格式（`outputs/`）
- [ ] 3 个 system 规则
- [ ] 5 类 assets 汇总库
- [ ] 1 个联动案例（`examples/联动案例-*.md`）
- [ ] SKILL.md 总入口可路由

## 常见错误

| 错误 | 修复 |
|------|------|
| 5 个助手塞进一个 Prompt | 拆文件 + 本 SKILL 路由 |
| 无统一风险等级 | 强制引用 `system/风险等级规则.md` |
| 联动时跳步 | 遵循 `workflows/联动工作流.md` 顺序 |
| assets 为空 | 每库 ≥3 条，见 `assets/*.md` |
| 无人工复核 | 每份输出末尾加 checklist |
