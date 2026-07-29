# Prompt 测试案例库（工具箱汇总）

> 用于 Prompt 测试助手 Step 2–7。完整样本见 `examples/prompt-test/`。

## 案例组 1：正常输入（稳定性 ×3）

| 样本 | 文件 | 期望 |
|------|------|------|
| 登录需求 | `examples/prompt-test/01-正常-登录需求.md` | 输出结构完整、字段不漂移 |

## 案例组 2：边界输入

| 样本 | 文件 | 易错点 |
|------|------|--------|
| 需求过短 | `examples/prompt-test/02-边界-需求过短.md` | 不应乱编完整方案 |
| 多模块混合 | `examples/prompt-test/03-边界-多模块混合.md` | 应分模块而非混在一起 |
| 超长 PRD | `examples/prompt-test/07-边界-超长PRD.md` | 应抓重点而非全量复述 |

## 案例组 3：错误 / 幻觉输入

| 样本 | 文件 | 易错点 |
|------|------|--------|
| 业务矛盾 | `examples/prompt-test/04-错误-业务矛盾.md` | 应先质疑再生成 |
| 参数异常 | `examples/prompt-test/06-错误-参数异常.md` | 应识别非法参数 |
| 证据不足 | `examples/prompt-test/05-证据不足-日志片段.md` + `assets/sample_logs/` | 禁止一行日志断定根因 |

## 待测 Prompt

- 用例生成：`prompts/待测Prompt-用例生成.md`
- Bug 分析：`prompts/待测Prompt-Bug分析.md`
