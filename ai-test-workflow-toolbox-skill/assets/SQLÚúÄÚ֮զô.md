# SQL 风险库（工具箱汇总）

> **必须加载**。详细信号见 `references/sql-analysis/sql_risk_signals.md` 与 `references/sql-analysis/sql_incident_patterns.md`。

## 慢 SQL 模式（≥5 条）

| 模式 | 风险 | 说明 |
|------|------|------|
| SELECT * | P1 | 返回字段过多，增加 IO |
| 无 where / 无索引 where | P0 | 大表全表扫描 |
| like '%关键词%' | P1 | 前缀通配，索引失效 |
| limit 100000, 20 深分页 | P0 | 需扫描并丢弃大量行 |
| 函数包裹索引字段 date(create_time) | P1 | 索引失效 |
| 大表 join 大表且无过滤 | P0 | 超大中间结果 |
| order by 不在索引 + 深分页 | P0 | filesort + 深分页叠加 |
| update/delete 无 where | P0 | 误操作 / 锁表 |

## 验证要求

- 无 explain / 数据量时禁止断言「必须加索引 xxx」
- 优化建议须含 explain 或慢查询日志验证方式
