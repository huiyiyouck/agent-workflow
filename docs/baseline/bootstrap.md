# 空项目第一次启动流程

## 目标

空项目第一次启动时，不应该直接让 Developer 写代码，也不应该直接让 PM 写完整 PRD。第一步应该执行 Bootstrap 初始化流程，让后续角色有共同入口、共同状态和共同文件结构。

这不是一个常驻项目经理角色。人类用户是项目 Owner 和实际项目经理；Bootstrap 只是一次性初始化机制。

## 启动口令

用户可以这样启动：

```text
执行 Bootstrap 初始化流程。
```

如果 Agent 发现当前项目缺少 `CLAUDE.md`、`docs/baseline/project-context.md` 或 `docs/progress/INDEX.md`，应建议用户先执行 Bootstrap 初始化流程，不要直接进入 PM、UI、Architect、Developer、Tester 或 DevOps 的常规工作。

## Bootstrap 步骤

1. 确认项目目录和 Git 状态。
   - 如果还不是 Git 仓库，询问用户是否初始化 Git。
   - 如果已有未归属文件，不覆盖、不删除，先记录现状。
2. 从模板生成或确认 `CLAUDE.md`。
3. 从 `project-context.template.md` 生成 `docs/baseline/project-context.md`。
4. 创建或确认 `docs/progress/INDEX.md`。
5. 创建角色日志和纠错记录：
   - `pm.md` / `pm-corrections.md`
   - `ui.md` / `ui-corrections.md`
   - `architect.md` / `architect-corrections.md`
   - `developer.md` / `developer-corrections.md`
   - `tester.md` / `tester-corrections.md`
   - `devops.md` / `devops-corrections.md`
6. 创建初始迭代记录 `docs/progress/iterations/v0.1.md`，状态为 `PRD 阶段待启动`。
7. 在 `docs/progress/INDEX.md` 记录 Bootstrap 结果和下一步建议。
8. 提交初始 Bootstrap commit。

## Bootstrap 完成后的推荐顺序

```text
Bootstrap 初始化
-> 用户确认项目上下文
-> PM 创建 v0.1 PRD
-> UI 创建 UI 方案或声明无 UI 变更
-> Architect 创建设计文档
-> Developer 实现
-> Tester 验证
-> DevOps 部署检查
-> 用户确认迭代关闭
```

## 不允许做的事

- 不允许空项目第一步直接进入实现阶段。
- 不允许在没有项目上下文时编造技术栈。
- 不允许跳过 `project-context.md`。
- 不允许把 Bootstrap 写成当前项目专属内容；它必须保持可复用。
