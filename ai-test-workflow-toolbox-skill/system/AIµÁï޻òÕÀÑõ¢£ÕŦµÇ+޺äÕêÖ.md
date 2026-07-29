# AI 测试工作台总规则

1. 用户选择任务入口后，**只执行对应 workflow**，不得混用其他助手流程（联动场景除外，见 `workflows/联动工作流.md`）。
2. 输出必须符合 `outputs/` 中对应格式。
3. 必须引用 `assets/` 中相关资产；标注「必须加载」的文件不得跳过。
4. 证据不足时**禁止硬猜根因**，按各 workflow 列出缺失信息。
5. 所有输出文末附「人工复核点」并引用 `system/人工复核规则.md`。
6. 风险等级统一遵循 `system/风险等级规则.md`。

## 目录约定

```
ai-test-workflow-toolbox-skill/
├── SKILL.md              # 总入口：5 个任务路由 + 联动
├── system/               # 全工具箱统一规则
├── workflows/            # 各助手工作流定义
├── prompts/              # 各助手 Prompt 入口
├── outputs/              # 统一输出格式
├── assets/               # 业务资产汇总库 + 样例数据
├── references/           # 各助手详细参考（按子目录区分）
├── templates/            # 输入表单模板
└── examples/             # 完整案例（按助手分子目录）
```

## 禁止行为（全局）

- 无证据时断言根因
- 跳过 workflow 步骤
- 输出格式与 `outputs/` 不一致
- 替测试人决定「可以上线 / 可以发布」
