---
name: sql-analysis-workflow
version: 1.0.0
description: >-
  按八步工作流对 SQL 做结构化第一轮性能风险识别，输出 P0/P1/P2 风险等级与可验证优化建议。
  证据不足时输出待补充信息清单，禁止无依据断言「必须加索引」。
  当用户要求分析 SQL、慢查询、索引、explain、数据库性能风险时使用。
  触发词：分析 SQL、慢查询、索引、explain、SQL 风险、全表扫描、深分页。
---

# SQL 分析工作流

> **CRITICAL — 执行前 MUST 先用 Read 工具读取 `workflows/sql_analysis.md`，并加载其中标注「必须引用」的 references 文件。**

## 适用场景

- 用户提供待分析 SQL（可脱敏）
- 接口慢、页面卡顿、偶发超时，怀疑 SQL 性能问题
- 需要输出可和开发沟通的结构化结论，而非空泛「建议加索引」
- 日志排查定位到慢 SQL 后，继续 @ 本 workflow 做 SQL 层分析

## 执行规则

当用户要求分析 SQL、慢查询、索引、explain 时：

1. 读取本 Skill
2. 要求用户按 [`references/sql_input_contract.yaml`](references/sql_input_contract.yaml) 补全上下文（或从对话中提取等价字段）
3. **严格按** [`workflows/sql_analysis.md`](workflows/sql_analysis.md) 八步执行，不得跳步
4. 输出必须符合 [`outputs/SQL分析输出格式.md`](outputs/SQL分析输出格式.md)

## 目录结构

```
sql-analysis-skill/
├── SKILL.md
├── workflows/
│   └── sql_analysis.md
├── outputs/
│   └── SQL分析输出格式.md
├── references/
│   ├── sql_input_contract.yaml
│   ├── sql_risk_signals.md
│   ├── sql_incident_patterns.md
│   ├── table_data_volume.md
│   ├── table_ddl.md
│   ├── risk_levels.md
│   └── api_sql_mapping.md
└── assets/
    ├── sample_sql/           # 样例 SQL
    ├── sample_logs/          # 慢查询日志样例
    └── examples/             # EXPLAIN 结果、完整/错误报告样例
```

## 禁止行为

- 无表结构 / 数据量 / explain 时猜测根因
- 跳过验证方式直接给优化结论
- 一见慢就说「必须加索引 xxx」
- 只看 SQL 能否查出数据，不走八步性能检查

## 与其他 Skill 衔接

- **日志排查**：`log-analysis-skill` 定位到慢 SQL 后，@ 本 workflow 继续分析
- **Bug 分析**：第八步优化建议可对齐团队缺陷单字段
