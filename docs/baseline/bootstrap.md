# 空项目第一次启动流程

## 目标

空项目第一次启动时，不应该直接让 Developer 写代码，也不应该直接让 PM 写完整 PRD。第一步应该执行 Bootstrap 初始化流程，让后续角色有共同入口、共同状态和共同文件结构。

这不是一个常驻项目经理角色。人类用户是项目 Owner（负责人）和实际项目经理；Bootstrap 只是一次性初始化机制。

Bootstrap 的触发规则、执行者和结束条件由 `docs/baseline/mechanisms.md` 统一定义。本文件只描述 Bootstrap 的具体执行步骤。

## 启动口令

用户可以这样启动：

```text
执行 Bootstrap 初始化流程。
```

如果 Agent 发现当前项目缺少 `CLAUDE.md`、`docs/baseline/project-context.md` 或 `docs/progress/INDEX.md`，应建议用户先执行 Bootstrap 初始化流程，不要直接进入 PM（产品经理）、UI（界面设计师）、Architect（架构师）、Developer（开发工程师）、Tester（测试工程师）或 DevOps（运维/部署工程师）的常规工作。

检测到缺失文件时，Agent 只能建议 Bootstrap，不能自动执行。只有用户明确说“执行 Bootstrap 初始化流程”或确认现在执行，才可以开始创建或修改文件。

## Bootstrap 步骤

1. 确认项目目录和 Git 状态。
   - 先执行 `git rev-parse --is-inside-work-tree` 判断是否为 Git 仓库。
   - 如果不是 Git 仓库，不执行 `git status`、`git pull` 或 `git log`，只询问用户是否初始化 Git。
   - 如果是 Git 仓库，执行 `git status --short`；如有远端，再执行 `git pull --rebase`；最后执行 `git log --oneline -10`。
   - 如果已有未归属文件，不覆盖、不删除，先记录现状。
2. 生成或确认 `CLAUDE.md`。
   - 如果 `CLAUDE.md` 已存在且内容完整，直接使用，不要求存在 `CLAUDE.template.md`。
   - 如果缺少 `CLAUDE.md` 且存在 `CLAUDE.template.md`，从模板生成并替换项目名称占位符；不要留下无法执行的模板变量。
   - 如果 `CLAUDE.md` 和 `CLAUDE.template.md` 都不存在，停止 Bootstrap，并提示用户先安装通用工作流。
3. 从 `docs/baseline/project-context.template.md` 生成 `docs/baseline/project-context.md`，只填写项目事实，不写当前阶段等动态状态。
   - 如果用户已经提供项目事实，写入对应字段。
   - 如果用户暂时没有想好项目，允许保留 `待填写` 占位，不阻塞目录结构初始化。
   - 项目事实未确认时，不进入 PRD 正式产出；Bootstrap 完成后的下一步是“补充或确认项目上下文”。
4. 基于 `docs/templates/progress-index.md` 创建或确认 `docs/progress/INDEX.md`，作为项目级当前状态入口。
5. 基于 `docs/templates/iteration.md` 创建初始迭代记录 `docs/progress/iterations/v0.1.md`，状态为 `PRD 阶段待启动`。
6. 基于 `docs/templates/role-log.md` 和 `docs/templates/role-corrections.md` 创建角色日志和纠错记录：
   - `pm.md` / `pm-corrections.md`
   - `ui.md` / `ui-corrections.md`
   - `architect.md` / `architect-corrections.md`
   - `developer.md` / `developer-corrections.md`
   - `tester.md` / `tester-corrections.md`
   - `devops.md` / `devops-corrections.md`
7. 不要向所有角色日志写重复的 Bootstrap 初始化记录；角色日志只创建初始模板，等该角色真正工作时再写日志。
8. 在 `docs/progress/INDEX.md` 记录 Bootstrap 结果和下一步建议。
9. 如果当前是 Git 仓库，提交初始 Bootstrap commit；如果用户选择暂不初始化 Git，记录“未提交：非 Git 仓库”。

## Bootstrap 完成后的推荐顺序

```text
Bootstrap 初始化
-> 用户确认项目上下文
-> PM（产品经理）创建 v0.1 PRD
-> UI（界面设计师）创建 UI 方案或声明无 UI 变更
-> Architect（架构师）创建设计文档
-> Developer（开发工程师）实现
-> Tester（测试工程师）验证
-> DevOps（运维/部署工程师）部署检查
-> 迭代关闭检查
-> 收尾归档
```

## 不允许做的事

- 不允许空项目第一步直接进入实现阶段。
- 不允许用户只是问候或闲聊时自动执行 Bootstrap。
- 不允许在没有项目上下文时编造技术栈；未知内容写 `待填写`。
- 不允许跳过 `project-context.md`。
- 不允许因为项目事实暂时未知就拒绝创建项目骨架。
- 不允许手写简化版迭代记录，必须基于 `docs/templates/iteration.md`。
- 不允许把当前阶段等动态状态写入 `project-context.md`。
- 不允许给所有角色日志追加重复 Bootstrap 流水账。
- 不允许把 Bootstrap 写成当前项目专属内容；它必须保持可复用。
