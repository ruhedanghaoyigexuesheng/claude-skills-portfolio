# Bug 分析工作流

> 工具箱路径：`ai-test-workflow-toolbox-skill/workflows/Bug分析工作流.md`
> 执行前加载：`system/AI测试工作台总规则.md`、`assets/历史Bug库.md`

## 适用场景

- 用户提供 Bug 描述，需要结构化分析报告
- 需要推荐日志/SQL 排查方向，而非直接猜根因

## 必须引用

| 文件 | 用途 |
|------|------|
| `references/bug-analysis/bug-input-template.md` | 输入校验 |
| `references/bug-analysis/bug-analysis-workflow.md` | 八步详细规则 |
| `references/bug-analysis/module-map.md` | 模块映射 |
| `references/bug-analysis/log-keywords.md` | 日志关键词 |
| `references/bug-analysis/sql-snippets.md` | SQL 片段 |
| `references/bug-analysis/history-bugs.md` | 历史 Bug |
| `references/bug-analysis/risk-levels.md` | 风险等级 |
| `assets/历史Bug库.md` | **必须加载** |
| `system/风险等级规则.md` | 统一 P0–P3 |
| `outputs/Bug分析输出格式.md` | 输出模板 |

## 执行步骤（禁止跳步）

```
提取现象 → 影响模块 → 可能原因 → 推荐日志/SQL → 关联历史Bug → 回归范围 → 风险等级 → 人工复核
```

| 步骤 | 名称 | 参考 |
|------|------|------|
| ① | 校验输入 | `templates/bug_input.yaml`、`references/bug-analysis/bug-input-template.md` |
| ② | 提取问题现象 | 只写事实，禁止「可能」「应该是」 |
| ③ | 判断影响模块 | `references/bug-analysis/module-map.md` |
| ④ | 推荐日志方向 | `references/bug-analysis/log-keywords.md`、`assets/日志规律库.md` |
| ⑤ | 推荐 SQL 方向 | `references/bug-analysis/sql-snippets.md` |
| ⑥ | 关联历史 Bug | `assets/历史Bug库.md` |
| ⑦ | 输出回归范围 | 必测 / 建议测 / 抽测 |
| ⑧ | 判断风险等级 | `system/风险等级规则.md` |
| ⑨ | 人工复核 | `system/人工复核规则.md` |

## 输出

必须符合 `outputs/Bug分析输出格式.md`。

## 案例

- 输入模板：`templates/bug_input.yaml`
- 完整报告：`examples/bug-analysis/payment-order-mismatch-report.md`
- 日志样例：`examples/bug-analysis/sample-error.log`

## 禁止

- 无日志/无数据时断言根因
- 跳过现象直接给修复方案
- 回归范围仅写「相关功能」
