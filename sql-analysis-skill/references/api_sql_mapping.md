# 接口与 SQL 映射表

> 用于关联 api_name 与典型 SQL，便于 Step 7 影响范围分析。实际项目请替换为团队真实映射。

| API | 业务场景 | 典型 SQL / Mapper | 核心表 | 备注 |
|-----|----------|-------------------|--------|------|
| GET /api/orders | 订单列表 | order_list_slow.sql | order_info | 高频，易深分页 |
| GET /api/orders/{id} | 订单详情 | `SELECT * FROM order_info WHERE id = ?` | order_info | 主键查，通常安全 |
| POST /api/order/create | 创建订单 | INSERT order_info + order_item | order_info, order_item | 写操作 |
| GET /api/user/profile | 用户资料 | `SELECT * FROM user_info WHERE id = ?` | user_info | 主键查 |
| GET /api/admin/user-logs | 用户日志查询 | `WHERE date(create_time) = ?` | user_log | 高风险写法 |
| GET /api/orders/export | 订单导出 | 大范围 SELECT + JOIN | order_info, user_info | 离线/低 QPS |
| POST /api/pay/callback | 支付回调 | UPDATE order_info SET status WHERE order_no = ? | order_info, pay_record | 需索引 order_no |

## 使用方式

1. 输入契约填写 `api_name` 后，在此表查找典型 SQL 模式
2. 若无映射，在 Step 7「影响范围」中标注「待补充 API-SQL 映射」
3. 与 `assets/sample_sql/` 样例文件交叉引用
