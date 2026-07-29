# 核心表结构 DDL（含索引）

> 用于 Step 3 索引判断、Step 5 join 分析。生产库以实际 DDL 为准。

## order_info

```sql
CREATE TABLE order_info (
  id           BIGINT PRIMARY KEY AUTO_INCREMENT,
  order_no     VARCHAR(32) NOT NULL,
  user_id      BIGINT NOT NULL,
  status       TINYINT NOT NULL DEFAULT 1 COMMENT '1待支付 2已完成 3已取消',
  total_amount DECIMAL(12,2) NOT NULL,
  create_time  DATETIME NOT NULL,
  update_time  DATETIME NOT NULL,
  INDEX idx_user_id (user_id),
  INDEX idx_status (status),
  INDEX idx_create_time (create_time),
  INDEX idx_user_status_time (user_id, status, create_time)
) ENGINE=InnoDB COMMENT='订单主表';
```

## user_info

```sql
CREATE TABLE user_info (
  id          BIGINT PRIMARY KEY AUTO_INCREMENT,
  mobile      VARCHAR(20),
  nickname    VARCHAR(64),
  status      TINYINT NOT NULL DEFAULT 1,
  create_time DATETIME NOT NULL,
  INDEX idx_mobile (mobile)
) ENGINE=InnoDB COMMENT='用户主表';
```

## pay_record

```sql
CREATE TABLE pay_record (
  id           BIGINT PRIMARY KEY AUTO_INCREMENT,
  order_id     BIGINT NOT NULL,
  trade_no     VARCHAR(64) NOT NULL,
  pay_status   TINYINT NOT NULL,
  amount       DECIMAL(12,2) NOT NULL,
  callback_time DATETIME,
  create_time  DATETIME NOT NULL,
  INDEX idx_order_id (order_id),
  INDEX idx_trade_no (trade_no)
) ENGINE=InnoDB COMMENT='支付流水';
```

## user_log

```sql
CREATE TABLE user_log (
  id          BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id     BIGINT NOT NULL,
  action      VARCHAR(32) NOT NULL,
  create_time DATETIME NOT NULL,
  detail      TEXT,
  INDEX idx_user_id (user_id),
  INDEX idx_create_time (create_time)
) ENGINE=InnoDB COMMENT='用户行为日志';
```

## 索引分析速查

| SQL 模式 | 可能命中索引 | 注意 |
|----------|--------------|------|
| WHERE user_id = ? AND status = ? ORDER BY create_time | idx_user_status_time | 左前缀匹配，较优 |
| WHERE status = 1 ORDER BY create_time | idx_status 或 idx_create_time | status 区分度低，filesort 风险 |
| WHERE date(create_time) = ? | 无（函数包裹） | 索引失效 |
| JOIN o.user_id = u.id | idx_user_id（两侧） | 先缩小 o 范围再 join |
