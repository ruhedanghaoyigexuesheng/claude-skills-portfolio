# Prompt 测试工作流

> **工具箱路径**：`ai-test-workflow-toolbox-skill/workflows/Prompt测试工作流.md`
> 样本目录：`examples/prompt-test/` | 参考：`references/prompt-test/`
> **路径说明**：5.6 教程课堂练习使用 `samples/`；工具箱统一为 `examples/prompt-test/`，@ 引用请用后者。

## Purpose

对用例生成、Bug 分析等 Prompt 执行可重复、可交接的工程化质量验证。

## When to use

- Prompt 上线 Skill 前
- Prompt 改版后（v1 → v2）
- 团队 Prompt 评审会前
- 用户说「测试 Prompt」「Prompt 稳不稳定」

## 输入

- **必填**：待测 Prompt（[`../prompts/`](../prompts/)）
- **必填**：测试目标评估表（Prompt 文件顶部 6 项）
- **必填**：测试样本（[`../examples/prompt-test/`](../examples/prompt-test/)）
- **选填**：期望输出规则（[`../templates/team_output_columns.md`](../templates/team_output_columns.md)）
- **选填**：System 文件（[`../system/AI测试工作台总规则.md`](../system/AI测试工作台总规则.md)）

## 执行步骤（严格按序）

### Step 1：明确 Prompt 目标

- 打开待测 Prompt，填写顶部「测试目标评估表」6 项
- 2 项以上答不上来 → **停止**，先改 Prompt 目标段
- 记录「本 Prompt 要完成的具体任务」一句话描述

### Step 2：正常样本质量测试

- 使用 [`examples/prompt-test/01-正常-登录需求.md`](../examples/prompt-test/01-正常-登录需求.md)
- 组合引用：`@prompts/待测Prompt.md` + `@examples/prompt-test/01-正常-登录需求.md`
- 检查：覆盖场景、输出格式、风险等级是否符合目标

### Step 3：稳定性测试（3 次）

- **同一 Prompt + 同一样本**，连续运行 **3 次**
- **每次新开对话**，避免上下文干扰
- 保存到 `records/01-正常-运行1.md` … `运行3.md`
- 对照 [`../references/prompt-test/稳定性检查清单.md`](../references/prompt-test/稳定性检查清单.md) 逐项打勾
- 记录漂移项（核心字段、格式、风险列）

### Step 4：边界输入测试

- 样本 02：[`examples/prompt-test/02-边界-需求过短.md`](../examples/prompt-test/02-边界-需求过短.md)
  - **期望**：提示信息不足，不编造完整方案
- 样本 03：[`examples/prompt-test/03-边界-多模块混合.md`](../examples/prompt-test/03-边界-多模块混合.md)
  - **期望**：先拆模块，不混在一张表
- 可选进阶：[`examples/prompt-test/07-边界-超长PRD.md`](../examples/prompt-test/07-边界-超长PRD.md)
- 记录「期望行为 vs 实际行为」各一行

### Step 5：错误输入测试

- 样本 04：[`examples/prompt-test/04-错误-业务矛盾.md`](../examples/prompt-test/04-错误-业务矛盾.md)
  - **期望**：识别矛盾，先质疑再生成
- 样本 06：[`examples/prompt-test/06-错误-参数异常.md`](../examples/prompt-test/06-错误-参数异常.md)
  - **期望**：指出参数不合理（如负数有效期）
- 不合格信号：顺着错误需求硬写用例

### Step 6：多轮一致性测试

- **同一对话内**执行，参考 [`../examples/prompt-test/sample_multiturn_script.md`](../examples/prompt-test/sample_multiturn_script.md)
- 第一轮：定义规则（格式、必须覆盖项）
- 第二轮：触发实际任务
- 检查：规则是否延续、格式是否保持

### Step 7：幻觉风险测试

- 样本 05：[`examples/prompt-test/05-证据不足-日志片段.md`](../examples/prompt-test/05-证据不足-日志片段.md)
- 配合 [`../assets/sample_logs/`](../assets/sample_logs/) 脱敏日志
- 对照 [`../references/prompt-test/幻觉测试四步法.md`](../references/prompt-test/幻觉测试四步法.md)
- **期望**：说明证据不足 + 列出需补充信息，不得给出确定根因

### Step 8：输出测试报告

- **必须**加载 [`../outputs/Prompt测试报告输出格式.md`](../outputs/Prompt测试报告输出格式.md)
- 汇总 `records/` 结论，填写问题清单 + 严重度
- 给出优化建议 + 通过/不通过结论
- 不通过 → 另存 `prompts/待测Prompt-v2.md`

## 输出

- 各样本运行记录（`records/`）
- 问题清单 + 风险等级（P0/P1/P2）
- 优化建议 + 是否通过
- 下一版 Prompt（如需要）

## 禁止

- 只测一次就判定通过
- 稳定性少于 3 次
- 跳过边界/错误/幻觉任一步骤
- 稳定性测试在同一对话连续跑（必须新开对话）
- 不输出结构化报告

## 快速启动命令

```
@workflows/Prompt测试工作流.md
@prompts/待测Prompt-用例生成.md

请按工作流对当前 Prompt 执行完整测试，并把报告写入 reports/。
```
