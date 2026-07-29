# Prompt 测试计划

## 待测 Prompt
- [ ] `prompts/待测Prompt-用例生成.md`
- [ ] `prompts/待测Prompt-Bug分析.md`
- [ ] 其他助手 Prompt（`prompts/*助手Prompt.md`）

## 测试范围
- [ ] 稳定性 ×3（样本 01，新开对话）
- [ ] 边界：02、03、07
- [ ] 错误：04、06
- [ ] 多轮：见 `examples/prompt-test/sample_multiturn_script.md`
- [ ] 幻觉：05 + `assets/sample_logs/log_insufficient_01.log`

## 输出
- 报告格式：`outputs/Prompt测试报告输出格式.md`
- 运行记录：`records/运行记录模板.md`

## 通过标准
五类维度均覆盖，稳定性 3 次核心字段不漂移，幻觉场景克制下结论。
