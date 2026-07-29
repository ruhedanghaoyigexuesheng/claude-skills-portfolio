# 历史 SQL 事故模式

> 用于 Step 1/7 对照历史规律。无匹配时写「无历史匹配，建议将本案入库」。

## 模式 1：订单列表深分页超时

| 字段 | 内容 |
|------|------|
| 典型 SQL | `SELECT * FROM order_info WHERE status=1 ORDER BY create_time DESC LIMIT N, 20`（N 很大） |
| 根因 | status 区分度低 + filesort + 深分页跳过大量行 |
| 表现 | 列表页翻到后面超时，DB CPU 尖刺 |
| 验证 | EXPLAIN 看 rows、Extra 含 Using filesort |
| 修复方向 | 游标分页、时间范围过滤、字段精简、联合索引验证 |

## 模式 2：日志表函数包裹索引字段

| 字段 | 内容 |
|------|------|
| 典型 SQL | `SELECT * FROM user_log WHERE date(create_time) = '2026-05-20'` |
| 根因 | date() 导致 idx_create_time 失效，2 亿行全扫 |
| 表现 | 运营后台查询卡死 |
| 验证 | EXPLAIN type=ALL 或 rows 极大 |
| 修复方向 | 改为范围查询 `create_time >= ? AND create_time < ?` |

## 模式 3：大表 join 未先过滤

| 字段 | 内容 |
|------|------|
| 典型 SQL | `order_info LEFT JOIN user_info ON ... WHERE o.status=1`（status=1 占 35%） |
| 根因 | 驱动表结果集过大再 join |
| 表现 | 接口响应 5s+ |
| 验证 | EXPLAIN 看 join 顺序与 rows |
| 修复方向 | 先加 user_id/时间范围缩小 o，再 join |

## 模式 4：支付对账慢 SQL

| 字段 | 内容 |
|------|------|
| 典型 SQL | `SELECT * FROM pay_record WHERE create_time BETWEEN ? AND ?`（无其他条件） |
| 根因 | 时间范围过大 + select * |
| 表现 | 对账任务跑不完 |
| 验证 | 慢查询日志 + 扫描行数 |
| 修复方向 | 缩小时间窗、只查必要字段、确认 idx_create_time |

## 模式 5：误更新无 where

| 字段 | 内容 |
|------|------|
| 典型 SQL | `UPDATE order_info SET status = 3` |
| 根因 | 脚本/代码遗漏 where |
| 表现 | 全表状态被改，P0 事故 |
| 验证 | binlog / 影响行数 |
| 修复方向 | 流程规范 + 预发验证，非纯 SQL 调优 |
