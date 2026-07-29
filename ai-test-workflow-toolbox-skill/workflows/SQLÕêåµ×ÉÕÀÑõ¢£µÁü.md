# SQL 分析工作流

> 工具箱路径：`ai-test-workflow-toolbox-skill/workflows/SQL分析工作流.md`
> 执行前加载：`system/AI测试工作台总规则.md`、`assets/SQL风险库.md`

## 适用场景

- 用户提供待分析 SQL（可脱敏）
- 接口慢、慢查询、日志排查定位到 SQL 后继续分析

## 必须引用

| 文件 | 用途 |
|------|------|
| `references/sql-analysis/sql_input_contract.yaml` | 输入契约 |
| `references/sql-analysis/sql_risk_signals.md` | Step 1 **必须** |
| `references/sql-analysis/table_ddl.md` | 索引/join |
| `references/sql-analysis/table_data_volume.md` | 扫描行数 |
| `references/sql-analysis/risk_levels.md` | P0–P2 |
| `references/sql-analysis/sql_incident_patterns.md` | 历史事故 |
| `assets/SQL风险库.md` | **必须加载** |
| `outputs/SQL分析输出格式.md` | 输出模板 |

## 必填输入

见 `templates/sql_input.yaml` 或 `references/sql-analysis/sql_input_contract.yaml`。

## 执行步骤（8 步，禁止跳步）

| 步骤 | 名称 |
|------|------|
| 1 | SQL 风险识别（对照高危信号） |
| 2 | WHERE 条件分析 |
| 3 | 索引判断（建议验证，不写死） |
| 4 | 慢查询判断 |
| 5 | JOIN 风险 |
| 6 | ORDER BY 风险 |
| 7 | 性能风险输出（P0/P1/P2） |
| 8 | 优化建议（≥3 条，含 explain 验证） |

## 输出

必须符合 `outputs/SQL分析输出格式.md`（8 节与 8 步一一对应）。

## 案例

- 样例 SQL：`assets/sample_sql/order_list_slow.sql` 等 5 个
- 完整报告：`examples/sql-analysis/order_list_slow_report.md`
- EXPLAIN 样例：`examples/sql-analysis/explain_*.txt`

## 禁止

- 无表结构/explain 时猜测根因
- 一见慢就说「必须加索引 xxx」
