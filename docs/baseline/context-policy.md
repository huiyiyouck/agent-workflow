# 上下文治理

## 目标

随着迭代和非迭代工作增多，角色日志、Review 记录和 ad-hoc 记录会快速膨胀。上下文治理的目标是：保留历史，但不让 Agent 每次启动都读完整历史。

核心原则：

```text
启动读索引，工作读相关，定期做摘要，旧记录归档。
```

## 启动读取层级

每次启动只默认读取：

1. `CLAUDE.md`
2. `docs/baseline/runtime.md`
3. `docs/baseline/project-context.md`，如存在
4. `docs/progress/INDEX.md`，如存在
5. 当前角色手册
6. 本角色的 `*-current.md` 或最近摘要
7. 本角色纠错记录

不要默认读取：

- `docs/baseline/multi-agent-workflow.md`
- `docs/baseline/work-modes.md`
- `docs/baseline/mechanisms.md`
- `docs/baseline/knowledge-base.md`
- 所有模板文件
- 所有历史迭代全文
- 所有角色日志全文
- 所有 Review 记录全文
- 整个知识库全文

启动后按 `docs/baseline/runtime.md` 判断工作模式，再读取对应规则文件。不要为了“保险”把所有 baseline 文件一次性读入上下文。

## 按需加载层级

| 场景 | 加载文件 |
|------|----------|
| 标准迭代 | `multi-agent-workflow.md`、当前迭代记录、本阶段产出物 |
| 非迭代工作 | `work-modes.md`、当前 ad-hoc 记录 |
| 收尾归档 | `mechanisms.md`；达到归档阈值时再读 `context-policy.md` |
| Bootstrap 初始化 | `mechanisms.md`、`bootstrap.md` |
| 知识库沉淀 | `knowledge-base.md`、`docs/knowledge/INDEX.md`、具体知识条目 |
| 创建文档 | 对应 `docs/templates/` 模板 |

## 角色日志分层

角色日志建议拆成三层：

```text
docs/progress/roles/{role}-current.md
docs/progress/roles/{role}-archive.md
docs/progress/roles/{role}-summary.md
```

| 文件 | 用途 | 启动是否默认读 |
|------|------|----------------|
| `{role}-current.md` | 最近工作日志，最多保留 10 条 | 是 |
| `{role}-summary.md` | 长期摘要、当前关注点、常见风险 | 是 |
| `{role}-archive.md` | 旧日志归档 | 否，按需搜索 |

如果项目仍使用单文件 `{role}.md`，也必须保持“最新在上”，并在超过 30 条后进行摘要归档。

## 归档触发时机

以下情况必须执行上下文归档：

- 某角色日志超过 30 条。
- 某迭代 Review 超过 3 轮。
- 单个角色日志文件超过 300 行。
- Agent 启动时需要读取超过 5 个历史文件才能判断状态。
- 用户感觉 Claude Code 变慢、变啰嗦或开始遗忘关键状态。
- 用户要求“今天收尾”“下班”“先停一下”。
- 非迭代工作、Change Note 或标准迭代已经完成。

## 会话收尾最小流程

每次会话结束，不管是否完成一个迭代，都必须做最小收尾：

1. 更新当前角色日志：本次动作、涉及文件、结论、遗留问题、下一步入口。
2. 更新当前工作记录：迭代记录、ad-hoc 记录或 Change Note。
3. 如果状态变化影响项目入口，更新 `docs/progress/INDEX.md`。
4. 记录验证证据；如果没有验证，写明原因。
5. 判断是否需要知识库沉淀。
6. 判断是否达到上下文归档阈值。
7. 如果本次有文件变更，提交 Git；如果暂不提交，写明原因和风险。

会话收尾不等于迭代关闭。它只是保证“今天到这里”之后，下次 Agent 能接得上。

## 通用归档流程

1. 读取旧日志或旧记录。
2. 提炼到 `{role}-summary.md`：
   - 当前稳定事实
   - 常见错误
   - 未关闭风险
   - 可复用经验
   - 关联知识库条目
3. 将旧日志移入 `{role}-archive.md` 或 `docs/progress/archive/`。
4. 保留最近 10 条在 `{role}-current.md`。
5. 如果有长期价值，提炼进 `docs/knowledge/`，不要只留在日志里。

## 迭代关闭归档

每个迭代关闭后，应生成一个短摘要：

```text
docs/progress/iterations/vX.Y-summary.md
```

摘要包含：

- 做了什么
- 关键决策
- 关键问题
- 遗留项
- 知识库链接
- 后续机会

后续 Agent 默认读 summary，不读完整 PRD、设计、Review 记录，除非任务需要。

迭代关闭归档还必须检查：

- 阶段门禁是否全部为已定稿、已跳过、已延期或已关闭。
- Change Note 是否已归档、已废弃或已转入下一迭代。
- 遗留问题是否有明确归属和下一步。
- 关键知识是否已经进入 `docs/knowledge/` 或写明不沉淀原因。
- `docs/progress/INDEX.md` 是否能表达当前项目状态。

## 非迭代工作归档

非迭代工作完成后，归档位置仍然是 `docs/progress/ad-hoc/`。不要把非迭代工作硬塞进迭代记录。

归档时必须写清：

- 最终状态：已完成 / 已中止 / 升级为标准迭代。
- 执行角色和涉及文件。
- 验证证据或未验证原因。
- 是否需要后续角色介入。
- 是否需要进入知识库。
- 如果升级为标准迭代，建议版本号和建议起始角色。

## Change Note 归档

Change Note 归档时必须同时完成四件事：

1. Change Note 自身状态更新为 `已归档`，或标记为 `已废弃` / `升级为重大变更`。
2. 迭代记录或 ad-hoc 记录中登记该 Change Note 的状态和结论。
3. 如果修改了已定稿文档，该文档必须保留 Change Note 引用或变更记录。
4. 对应角色日志写明确认、执行和验证结果。

如果 Change Note 产生了可复用经验，例如某类接口边界、测试缺陷、部署风险，应提炼到知识库。

## 知识库读取治理

知识库是长期资产，不是启动上下文。

Agent 使用知识库时应：

- 先读 `docs/knowledge/INDEX.md`
- 再读相关领域索引或具体条目
- 不全文扫描整个 `docs/knowledge/`
- 用关键词检索而不是盲读

## 不允许做的事

- 不允许把所有历史日志塞进 `CLAUDE.md`。
- 不允许让 Agent 每次启动读完整 `docs/progress/`。
- 不允许把流水账当知识库。
- 不允许为了省上下文删除历史，只能归档和摘要。
- 不允许把密钥、Token、Cookie 写入摘要或知识库。
