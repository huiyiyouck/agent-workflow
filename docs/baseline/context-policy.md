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
2. `docs/baseline/project-context.md`
3. `docs/baseline/multi-agent-workflow.md`
4. `docs/baseline/work-modes.md`
5. 当前角色手册
6. `docs/progress/INDEX.md`
7. 本角色的 `*-current.md` 或最近摘要
8. 本角色纠错记录

不要默认读取：

- 所有历史迭代全文
- 所有角色日志全文
- 所有 Review 记录全文
- 整个知识库全文

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

## 归档流程

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

## 迭代记录治理

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

