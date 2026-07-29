# 错误范例：只有「建议加索引」的 AI 输出（A10 课堂对比用）

> **这是反面教材。** 缺少八步分析、无验证方式、无风险等级。

---

这条 SQL 比较慢，建议在 order_info 表上加索引：

```sql
ALTER TABLE order_info ADD INDEX idx_status_create_time (status, create_time);
```

加完索引应该就好了。

---

## 问题清单（课堂讨论）

| 问题 | 说明 |
|------|------|
| 未走八步 | 直接跳到「加索引」 |
| 无依据 | 未分析 status 区分度、深分页、select * |
| 无验证 | 未要求 EXPLAIN 或慢查询日志 |
| 无风险等级 | 未说明 P0/P1/P2 与业务影响 |
| 表述武断 | 「必须加」「应该就好了」 |
| 无优化 breadth | 仅 1 条建议，未考虑游标分页、字段精简、时间范围 |

## 正确做法

@ `workflows/sql_analysis.md` + 样例 SQL，严格八步输出，参考 `assets/examples/` 下的合格报告结构。
