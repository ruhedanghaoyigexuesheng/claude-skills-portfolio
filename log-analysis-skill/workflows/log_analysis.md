# Log Analysis Workflow

## Purpose

对测试/生产日志做结构化第一轮分析，输出可执行排查建议。

## When to use

- 用户提供原始日志、报错截图文字、ELK 导出片段
- Bug 描述含「超时」「异常」「failed」「traceId」等

## Required Inputs

- raw_log（必填）：原始日志文本
- occurred_at（建议）：发生时间
- environment（建议）：test / staging / prod
- business_scene（建议）：如「下单」「支付回调」
- trace_id / request_id（强烈建议）

## 执行步骤

### Step 1：提取日志关键词

**Goal**：输出结构化关键词，不写根因猜测。

**必须引用**：`references/log_keyword_types.md`

**Checkpoint**：

- [ ] 已提取级别、服务名、异常词、链路 ID、时间

### Step 2：识别异常类型

**Goal**：归类到网络/DB/MQ/缓存/权限/业务等。

**必须引用**：`references/exception_type_map.md`

### Step 3：调用链分析

**Goal**：标出 entry、上下游、异常节点。

**参考**：`references/service_call_chain.md`

**Checkpoint**：

- [ ] 未在无证据时断言「就是 XX 服务 bug」

### Step 4：模块定位

**Goal**：业务模块 + 技术模块 + 建议关注服务/表。

**参考**：`references/module_owner_map.md`（可选，用于明确负责人）

### Step 5：匹配历史规律

**必须引用**：`references/log_pattern_history.md`

**若无匹配**：明确写「无历史匹配，建议将本案入库」

### Step 6：输出排查建议

**输出模板**：`assets/templates/log_analysis_report.md`

### Step 7：证据不足处理

**规则**：若 raw_log 少于 3 类有效信号（级别/服务/异常词/traceId 等），禁止输出根因，只输出「缺失信息清单」。

**输出模板**：`assets/templates/missing_evidence_checklist.md`

## 人工复核点

- [ ] 排查建议是否具体到「查哪条日志、哪个 traceId」
- [ ] 风险等级是否与业务影响一致
- [ ] 是否避免无证据的根因结论

## Final Output

使用 `assets/templates/log_analysis_report.md` 结构输出。
