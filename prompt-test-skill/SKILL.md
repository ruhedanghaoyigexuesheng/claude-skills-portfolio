---
name: lark-workflow-prompt-test
version: 1.0.0
description: "Prompt 测试工作流：对用例生成、Bug 分析等 Prompt 执行稳定性、边界、错误输入、多轮一致性与幻觉风险验证，输出结构化测试报告。当用户提及 Prompt 测试、Prompt 质量验证、测试工作流设计、Prompt 稳定性、幻觉测试时使用。"
metadata:
  requires:
    bins: []
---

# Prompt 测试工作流

**CRITICAL — 开始前 MUST 先用 Read 工具读取 [`workflows/Prompt测试工作流.md`](workflows/Prompt测试工作流.md)，严格按 8 步执行。**

## 适用场景

- "帮我测试这个 Prompt" / "Prompt 稳不稳定" / "验证 Prompt 质量"
- 用例生成 Prompt、Bug 分析 Prompt 上线前的工程化验证
- 团队建立 Prompt 版本规范（v1/v2）与可交接测试报告
- 课堂练习：按 5.6 教程对 Prompt 跑完整测试流程

## 核心原则

Prompt 测试的目的，**不是测试 AI 聪不聪明**，而是测试这个 Prompt 能不能**稳定产出符合测试要求的结果**。

合格验证必须覆盖五类维度：

| 维度 | 验证什么 | 不合格信号 |
|------|----------|------------|
| 稳定性 | 同输入多次，核心字段不漂移 | 有时有边界值，有时没有 |
| 边界输入 | 信息过少/过多时仍清晰 | 需求极短却乱编完整方案 |
| 错误输入 | 识别矛盾，先质疑再生成 | 顺着错误需求硬写用例 |
| 多轮一致 | 后续轮次遵守前面规则 | 第二轮忘掉输出格式 |
| 幻觉风险 | 证据不足时克制下结论 | 日志一行就断定根因 |

## 工作流概览

```
明确目标 → 设计样本 → 稳定性×3 → 边界 → 错误 → 多轮 → 幻觉 → 测试报告
```

| 步骤 | 名称 | 样本 | 参考 |
|------|------|------|------|
| 1 | 明确 Prompt 目标 | 评估表 6 项 | [`prompts/待测Prompt-用例生成.md`](prompts/待测Prompt-用例生成.md) 顶部 |
| 2 | 正常样本质量 | `samples/01-正常-登录需求.md` | — |
| 3 | 稳定性测试 | 01 × 3 次 | [`references/稳定性检查清单.md`](references/稳定性检查清单.md) |
| 4 | 边界输入 | 02、03 | [`references/测试维度说明.md`](references/测试维度说明.md) |
| 5 | 错误输入 | 04、06 | [`references/常见错误对照.md`](references/常见错误对照.md) |
| 6 | 多轮一致性 | 同一对话两轮 | [`assets/samples/sample_multiturn_script.md`](assets/samples/sample_multiturn_script.md) |
| 7 | 幻觉风险 | 05 + logs | [`references/幻觉测试四步法.md`](references/幻觉测试四步法.md) |
| 8 | 输出报告 | — | [`outputs/Prompt测试报告输出格式.md`](outputs/Prompt测试报告输出格式.md) |

## 执行步骤

1. **检查目标**：打开待测 Prompt，确认顶部「测试目标评估表」6 项已填写；2 项以上答不上来 → 先改 Prompt，禁止开测
2. **执行工作流**：按 [`workflows/Prompt测试工作流.md`](workflows/Prompt测试工作流.md) 步骤 1～8 严格顺序执行
3. **保存运行记录**：每次运行写入 `records/`，稳定性测试至少 3 次/样本，使用 [`records/运行记录模板.md`](records/运行记录模板.md)
4. **输出报告**：最终输出 **必须** 符合 [`outputs/Prompt测试报告输出格式.md`](outputs/Prompt测试报告输出格式.md)
5. **版本管理**：不通过时另存 `prompts/待测Prompt-v2.md`，不改原文件名

## 禁止

- 只测一次就判定通过
- 只测正常输入，跳过边界/错误/幻觉
- 稳定性少于 3 次
- 凭感觉评价，不填结构化报告
- 多轮测试在同一轮混跑（稳定性必须新开对话）
- 替测试人决定「可以上线 Skill」

## 附件与样例

| 编号 | 文件 | 用途 |
|------|------|------|
| A1 | [`prompts/待测Prompt-用例生成.md`](prompts/待测Prompt-用例生成.md) | 主案例：用例生成 Prompt |
| A2 | [`prompts/待测Prompt-Bug分析.md`](prompts/待测Prompt-Bug分析.md) | 完整案例：Bug 分析 Prompt |
| A3 | [`samples/01-正常-登录需求.md`](samples/01-正常-登录需求.md) | 稳定性 + 正常样本 |
| A4 | [`assets/samples/sample_prd_login.md`](assets/samples/sample_prd_login.md) | 正常 PRD 片段 |
| A5 | [`assets/samples/sample_bug_ticket.md`](assets/samples/sample_bug_ticket.md) | Bug 分析案例输入 |
| A6 | [`assets/logs/`](assets/logs/) | 幻觉测试日志片段 |
| A7 | [`assets/templates/team_output_columns.md`](assets/templates/team_output_columns.md) | 团队输出列名模板 |
| A8 | [`system/test_assistant_system.md`](system/test_assistant_system.md) | System 联调文件 |
| A9 | [`assets/samples/sample_multiturn_script.md`](assets/samples/sample_multiturn_script.md) | 多轮对话脚本 |
| A10 | [`assets/samples/bad_output_stability_drift.md`](assets/samples/bad_output_stability_drift.md) | 劣质输出对比 |
| A11 | [`assets/samples/good_output_stability.md`](assets/samples/good_output_stability.md) | 优秀输出对比 |
| A12 | [`reports/Prompt测试报告模板.md`](reports/Prompt测试报告模板.md) | 报告填写模板 |
| A13 | [`workflows/Prompt测试工作流.md`](workflows/Prompt测试工作流.md) | 工作流定义 |
| A14 | [`assets/samples/sample_test_report.md`](assets/samples/sample_test_report.md) | 历史报告样例对照 |

## 与其他工作流衔接

| 工作流 | 何时用 | 产出 |
|--------|--------|------|
| **Prompt 测试（本 Skill）** | **Prompt 上线前** | **质量报告 + v2 建议** |
| Bug 分析 | 已有缺陷要定位 | 根因方向、回归范围 |
| 回归测试 | 版本发布前 | 测什么、先测什么 |

典型串联：**本工作流验证 Prompt** → 通过后集成 Skill → Bug 分析 / 用例生成进入日常流程

## 快速启动

```
@workflows/Prompt测试工作流.md
@prompts/待测Prompt-用例生成.md
@samples/01-正常-登录需求.md

请按工作流对当前 Prompt 执行完整测试，并把报告写入 reports/。
```

**验收标准**：报告含 5 样本结果、稳定性 3 次对比、问题清单 + 严重度、通过/不通过结论。
