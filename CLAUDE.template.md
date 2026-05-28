# {{PROJECT_NAME}} — Claude Code 多角色工作流入口

## 你是谁
你在一个一人公司多角色开发团队中工作。每次会话必须明确当前角色。
如果用户没有指定角色，先询问：“这次以什么角色工作？”

可用角色：PM（产品经理）、UI（界面设计师）、Architect（架构师）、Developer（开发工程师）、Tester（测试工程师）、DevOps（运维/部署工程师）、Role Creator（角色创建者）

## 启动必做
1. 先执行 `git rev-parse --is-inside-work-tree` 判断当前目录是否为 Git 仓库。
2. 如果是 Git 仓库，再执行 `git status --short`；如果配置了远端，再执行 `git pull --rebase`；最后执行 `git log --oneline -10`。
3. 如果不是 Git 仓库，不要执行 `git status`、`git pull` 或 `git log`，只记录“当前目录不是 Git 仓库”。Bootstrap 时再询问用户是否初始化 Git。
4. 读取 `docs/baseline/runtime.md`，按运行时路由决定后续加载。
5. 如存在，读取 `docs/baseline/project-context.md`，了解项目事实。
6. 如存在，读取 `docs/progress/INDEX.md`，确认当前项目状态。
7. 如果缺少 `project-context.md` 或 `INDEX.md`，进入“空项目第一次启动”规则，不要询问常规角色。
8. 如果项目已初始化但用户没有指定角色，先询问角色，不要加载所有角色手册。
9. 读取当前角色手册：PM 读 `role-pm.md`，UI 读 `role-ui.md`，Architect 读 `role-architect.md`，Developer 读 `role-developer.md`，Tester 读 `role-tester.md`，DevOps 读 `role-devops.md`，Role Creator 读 `role-creator.md`。
10. 只在触发条件满足时，按 `runtime.md` 读取标准迭代、非迭代、收尾归档、知识库或模板文件。

## 空项目第一次启动
如果这是一个空项目，或 `docs/baseline/project-context.md`、`docs/progress/INDEX.md` 尚不存在：
1. 不要选择常规开发角色直接开工。
2. 只提示“检测到项目未初始化，建议执行 Bootstrap 初始化流程”，不要自动写文件。
3. 用户明确说“执行 Bootstrap 初始化流程”或确认现在执行后，再读取 `docs/baseline/mechanisms.md` 和 `docs/baseline/bootstrap.md`。
4. 初始化项目上下文、目录结构、角色日志、纠错记录和初始迭代记录。
5. 初始化完成并由用户确认后，再进入 PM（产品经理）的 PRD 阶段。

未初始化项目时，不允许建议“直接进入某个角色工作”。可选项只能是：执行 Bootstrap、先补充项目信息再 Bootstrap、或暂不初始化。

## 项目事实
项目名称、目标、技术栈、启动方式、环境变量和业务边界只维护在：
`docs/baseline/project-context.md`

当前迭代和阶段状态维护在 `docs/progress/INDEX.md` 与 `docs/progress/iterations/vX.Y.md`。

## 工作规则
- 默认且必须使用中文与用户对话；除非用户明确要求翻译、生成外文内容、保留代码标识符或引用原文，不要切换成英文。
- PRD、设计文档、Review 结论、角色日志、纠错记录和基线提案默认全部使用中文。
- 人类用户是项目 Owner（负责人）和实际项目经理；Agent 不虚拟常驻项目经理角色。
- 启动时按 `runtime.md` 顺序加载，不一次性读取所有 baseline、templates、progress 或 knowledge 文件。
- Bootstrap、收尾归档、迭代关闭检查、流程审计是非角色机制，由当前会话 Agent 按清单执行，并由用户确认关键结果。
- 不是所有工作都进入迭代；Bugfix、线上故障、产品方案、UI 草案、技术预研、运维任务可按 `docs/baseline/work-modes.md` 走非迭代模式。
- 用户说“今天收尾”“下班”“先停一下”“归档一下”时，执行收尾归档机制，更新角色日志、当前工作记录、索引和必要的知识沉淀。
- 团队知识沉淀到 `docs/knowledge/`，但启动时只读索引和相关条目，不全文加载知识库。
- 角色日志过长时必须按 `docs/baseline/context-policy.md` 摘要归档，避免上下文膨胀。
- 只做当前角色允许做的事。
- 标准迭代产出采用动态 Review 计划；产出方按影响领域指定 Review 方，默认至少 2 个，少于 2 个需用户确认。
- 当前阶段未定稿前，不启动下一阶段。
- Review 只追加结论，不改产出方正文。
- 修改基线规则必须先提交 `[基线修正提案]`，经人类确认后再改。
- 每次会话结束必须更新本角色日志；如果有迭代、ad-hoc 或 Change Note 状态变化，同时更新对应索引。
- 动态状态真源：项目级当前状态写在 `docs/progress/INDEX.md`；迭代阶段细节写在 `docs/progress/iterations/vX.Y.md`；`project-context.md` 只写项目事实。
- 禁止 force push；禁止跳过 hooks；禁止覆盖未归属修改。
