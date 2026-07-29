# SQL Analysis Workflow

## Purpose

对 SQL 做结构化第一轮性能风险识别，输出可和开发沟通的结构化结论（含 P0/P1/P2 风险等级与验证方式）。

## When to use

- 用户提供待分析 SQL（可脱敏）
- 接口慢、页面卡顿、偶发超时，怀疑 SQL 性能问题
- 日志排查已定位到具体 SQL

## 执行前加载

- `references/sql_input_contract.yaml`（用户填写或从对话提取）
- `references/sql_risk_signals.md`（**必须引用**）
- `outputs/SQL分析输出格式.md`（输出模板）

可选参考：

- `references/table_ddl.md` — 索引判断、join 分析
- `references/table_data_volume.md` — 扫描行数风险
- `references/risk_levels.md` — P0/P1/P2 判定
- `references/api_sql_mapping.md` — 接口与 SQL 对应关系
- `references/sql_incident_patterns.md` — 历史事故模式

## Required Inputs

| 字段 | 必填 | 说明 |
|------|------|------|
| sql | 是 | 待分析语句 |
| tables | 是 | 涉及表名列表 |
| business_scene | 是 | 业务场景，如「订单列表查询」 |
| data_volume | 是 | 核心表数据量级 |
| api_name | 建议 | 关联接口 |
| symptom | 建议 | 现象描述 |
| environment | 建议 | test / staging / production |
| has_explain | 可选 | 是否有执行计划 |

## 执行步骤（必须逐步输出，禁止跳步）

### Step 1：SQL 风险识别

**Goal**：对照高危信号规则库，列出命中项。

**必须引用**：`references/sql_risk_signals.md`

**Checkpoint**：

- [ ] 已列出 select *、深分页、函数包裹索引字段等命中项
- [ ] 未直接给出「加索引」结论

### Step 2：where 条件分析

**Goal**：评估过滤条件能否缩小扫描范围。

**检查点**：

- 是否有 where？能否缩小扫描范围？
- 字段区分度（如 status=1 是否过低）
- 函数 / 隐式转换 / or / 前缀模糊 like

### Step 3：索引判断

**Goal**：建议需验证的索引组合，不写死「必须加」。

**参考**：`references/table_ddl.md`

**检查点**：

- [ ] where / join / order by 字段是否与索引左前缀一致
- [ ] 表述为「建议验证」而非「必须加 xxx 索引」

### Step 4：慢查询判断

**Goal**：评估扫描行数、返回字段、锁等待风险。

**参考**：`references/table_data_volume.md`

### Step 5：join 风险

**Goal**：关联字段索引、先过滤再 join、大表 join 成本。

- 无 join 时输出「不适用」

### Step 6：order by 风险

**Goal**：filesort 可能、排序前数据量是否过大。

- 与 where、limit 组合看排序前数据量
- 联合索引是否覆盖 order by

### Step 7：性能风险输出

**Goal**：结构化输出风险类型、原因、影响、表现、验证方式、风险等级。

**必须引用**：`references/risk_levels.md`

| 字段 | 内容 |
|------|------|
| 风险类型 | 如慢查询 / 全表扫描 |
| 风险原因 | |
| 影响范围 | 接口 / 模块 |
| 可能表现 | 超时、CPU 升高等 |
| 验证方式 | explain、慢查询日志 |
| 风险等级 | P0 / P1 / P2 |

### Step 8：优化建议

**Goal**：至少 3 条可执行建议，说明「改哪里、查哪里、验证哪里」。

- 须含 explain 验证步骤
- 禁止无依据断言「必须加索引 xxx」

## 证据不足处理

若缺少表结构 / 数据量 / explain：

1. 禁止猜根因
2. 输出「待补充信息」清单
3. 使用 `assets/examples/missing_evidence_checklist.md` 结构

## 人工复核点

- [ ] 八步是否完整输出
- [ ] 风险等级是否与业务影响一致
- [ ] 优化建议是否具体到可执行的验证步骤
- [ ] 是否避免无证据的索引断言

## Final Output

使用 `outputs/SQL分析输出格式.md` 结构输出。
