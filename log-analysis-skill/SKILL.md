---
name: log-analysis-workflow
version: 1.0.0
description: >-
  按七步工作流对测试/生产日志做结构化第一轮分析，输出可执行排查建议（关键词、异常类型、调用链、模块定位、历史规律、风险等级）。
  证据不足时输出缺失信息清单，禁止无依据猜测根因。
  当用户要求分析日志、排查报错、解读 traceId、日志排查时使用。
  触发词：分析日志、日志排查、报错分析、traceId、ELK 日志、ERROR 排查。
---

# 日志排查工作流

> **CRITICAL — 执行前 MUST 先用 Read 工具读取 `workflows/log_analysis.md`，并加载其中标注「必须引用」的 references 文件。**

## 适用场景

- 用户提供原始日志、报错截图文字、ELK 导出片段
- Bug 描述含「超时」「异常」「failed」「traceId」等
- 需要输出结构化排查方向，而非直接断言根因

## 执行规则

当用户要求分析日志、排查报错、解读 traceId 时：

1. 读取本 Skill
2. **严格按** [`workflows/log_analysis.md`](workflows/log_analysis.md) 执行，不得跳步
3. 标注「必须引用」的 references 文件必须加载

## 目录结构

```
log-analysis-skill/
├── SKILL.md
├── workflows/
│   └── log_analysis.md
├── references/
│   ├── log_keyword_types.md
│   ├── exception_type_map.md
│   ├── log_pattern_history.md
│   ├── service_call_chain.md
│   └── module_owner_map.md
└── assets/
    ├── sample_logs/          # 仿真日志样例
    ├── templates/            # 输出模板
    └── examples/             # 完整报告样例
```

## 禁止行为

- 无 traceId / 无上下游日志时断言「就是 XX 服务 bug」
- 跳过关键词与异常类型直接给根因
- timeout 与 duplicate key 混称为「系统异常」
- raw_log 有效信号不足时仍输出根因结论
