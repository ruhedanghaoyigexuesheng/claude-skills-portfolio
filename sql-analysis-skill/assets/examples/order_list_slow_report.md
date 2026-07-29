# SQL 分析报告样例 — order_list_slow.sql

> 合格输出参考（课件 6.3 自检要点）

## 1. SQL 风险识别

| 信号 | 命中 | 说明 |
|------|------|------|
| select * | 是 | 返回全部字段，IO 与传输开销大 |
| 低区分度 where status=1 | 是 | 约占 35%，约 175 万行 |
| order by create_time | 是 | 与 where 组合可能 filesort |
| 深分页 limit 100000,20 | 是 | 需跳过 10 万行后取 20 行 |

## 2. where 条件分析

- 有 where，但 `status=1` 区分度低，500 万表中约 175 万行满足条件
- 无 user_id、时间范围等进一步过滤，扫描范围过大
- 无函数包裹，但单靠 status 难以缩小到可接受 rows

## 3. 索引判断

- 可能使用 `idx_status`，但无法覆盖 `order by create_time`
- 建议验证联合索引 `(status, create_time)` 或 `(user_id, status, create_time)` 是否更符合查询模式
- **不写死必须加索引**，需 EXPLAIN 对比

## 4. 慢查询判断

- Rows_examined 可达百万级（见慢查询样例：250 万 examined）
- select * 放大返回与缓冲
- 高 QPS 下可能导致 DB CPU 升高、接口 P99 超时

## 5. join 风险

不适用（单表查询）

## 6. order by 风险

- `ORDER BY create_time DESC` 与 `idx_status` 不匹配，Extra 可能出现 Using filesort
- 排序前数据量约 175 万行，成本高
- 与深分页叠加：先排序/扫描再跳过 10 万行

## 7. 性能风险

| 字段 | 内容 |
|------|------|
| 风险类型 | 慢查询 |
| 风险原因 | status 低区分度 + order by filesort + 深分页 limit 100000,20 |
| 影响范围 | GET /api/orders 订单列表 |
| 可能表现 | 列表后页加载超时、慢查询 >5s、DB CPU 尖刺 |
| 验证方式 | EXPLAIN（关注 rows、Using filesort）+ 慢查询日志 Query_time/Rows_examined |
| 风险等级 | P1（核心接口，视 QPS 可升 P0） |

## 8. 优化建议

1. **字段精简**：列表只查 order_no、status、create_time、total_amount 等必要字段，避免 select *
2. **缩小范围**：增加 create_time 时间窗或 user_id 条件，降低排序前 rows
3. **深分页改游标**：用 `WHERE create_time < ? ORDER BY create_time DESC LIMIT 20` 替代大 offset
4. **索引验证**：与开发/DBA 在测试库 EXPLAIN 对比 `(status, create_time)` 与现有 idx_status
5. **监控**：对接口 P99 与慢查询平台持续观察优化后 Query_time

---

**历史规律匹配**：命中 `references/sql_incident_patterns.md` 模式 1（订单列表深分页超时）
