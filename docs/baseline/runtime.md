# 运行时加载路由

## 目标

本文件是 Claude Code 每次启动时的轻量入口。它只负责决定“现在该读什么”，不承载完整流程细节。

原则：

```text
先判定任务，再加载规则；只读当前需要的文件。
```

## 默认启动只读

每次启动默认只读取：

1. `CLAUDE.md`
2. `docs/baseline/runtime.md`
3. `docs/baseline/project-context.md`，如存在
4. `docs/progress/INDEX.md`，如存在
5. 当前角色手册：`docs/baseline/role-{role}.md`
6. 当前角色摘要、最近日志和纠错记录

如果用户没有指定角色，先问用户要以哪个角色工作，不要为了猜角色去加载所有角色手册。

## 不默认读取

启动时不要默认读取：

- `docs/baseline/multi-agent-workflow.md`
- `docs/baseline/work-modes.md`
- `docs/baseline/context-policy.md`
- `docs/baseline/mechanisms.md`
- `docs/baseline/knowledge-base.md`
- 所有模板文件
- 所有历史迭代全文
- 所有角色日志全文
- 整个知识库全文

这些文件只在触发条件满足时按需读取。

## 加载顺序

### 1. 判断项目是否初始化

如果缺少 `CLAUDE.md`、`docs/baseline/project-context.md` 或 `docs/progress/INDEX.md`：

1. 读取 `docs/baseline/mechanisms.md`
2. 读取 `docs/baseline/bootstrap.md`
3. 执行 Bootstrap 初始化流程

不要直接进入 PM（产品经理）、Developer（开发工程师）等常规角色工作。

### 2. 判断工作模式

根据用户请求和 `docs/progress/INDEX.md` 判断模式：

| 用户意图 | 工作模式 | 额外读取 |
|----------|----------|----------|
| 做版本、迭代、完整功能落地 | 标准迭代 | `multi-agent-workflow.md`、当前迭代记录 |
| Bug、线上问题、临时修复 | 非迭代 Bugfix / Incident | `work-modes.md`、相关 ad-hoc 记录 |
| 产品想法、UI 草案、技术预研、运维任务 | 非迭代方案/预研/任务 | `work-modes.md`、相关 ad-hoc 记录 |
| 今天收尾、下班、先停一下 | 收尾归档 | `mechanisms.md`；达到归档阈值时再读 `context-policy.md` |
| 迭代是否结束、准备关闭版本 | 迭代关闭检查 | `mechanisms.md`、当前迭代记录、必要 summary |
| 修改团队规则、新增/删除角色 | 基线修正 | `role-creator.md`、相关 baseline 文件 |
| 查询沉淀经验、写入长期知识 | 知识库工作 | `knowledge-base.md`、`docs/knowledge/INDEX.md` |

如果无法判断是否进入迭代，先问用户，不要同时加载标准迭代和非迭代规则。

### 3. 读取当前产出物

只读取当前任务相关的文件：

- 标准迭代：当前 `vX.Y.md` 和本阶段产出物。
- Review：被 Review 的文档、Review 计划中指定的相关结论。
- 非迭代：当前 ad-hoc 记录。
- Change Note：当前 Change Note 和它引用的定稿文档摘要。
- 知识库：先读 `docs/knowledge/INDEX.md`，再读具体条目。

不要因为目录存在就全文扫描。

### 4. 模板按创建时读取

只有在需要新建文档时才读取对应模板：

- 创建 PRD：`docs/templates/prd.md`
- 创建 UI 方案：`docs/templates/ui-spec.md`
- 创建设计文档：`docs/templates/design.md`
- 创建测试计划/报告：对应测试模板
- 创建 Change Note：`docs/templates/change-note.md`
- 会话收尾记录：`docs/templates/session-closeout.md`
- 迭代归档摘要：`docs/templates/iteration-summary.md`

不创建文档时，不读取模板。

## 质量底线

- 中文对话和中文记录是默认规则。
- 人类用户是项目 Owner（负责人）和实际项目经理，Agent 不虚拟常驻项目经理角色。
- 当前阶段未定稿前，不进入下一阶段；非迭代工作除外。
- 标准迭代产出采用动态 Review，默认至少 2 个相关 Review 方；少于 2 个需用户确认。
- 已定稿内容不能静默修改；轻量变更走 Change Note，重大变更回到对应阶段。
- 每次会话结束必须至少更新角色日志；状态变化影响项目入口时，同步更新 `docs/progress/INDEX.md`。
- 发现需要新增或修改基线规则时，先提案，经用户确认后再改。
