# Claude Code One-Person Company Workflow

一套面向“一人公司”的 Claude Code 多角色开发团队工作流。它的目标不是制造复杂流程，而是让同一个人可以按角色启动不同 Claude Code 会话，稳定完成从产品定义、架构设计、实现、Review、部署检查到复盘纠错的闭环。

这套工作流适合复制到任何 Claude Code 项目中使用。项目自己的业务背景、技术栈、启动方式、当前迭代状态写入 `docs/baseline/project-context.md`，通用协作规则保持不变。

## 语言约定

这套工作流默认且必须使用中文进行对话和协作。PRD、设计文档、Review 结论、部署检查、角色日志、纠错记录和基线提案都使用中文；代码标识符、命令、错误信息、第三方 API 名称和必要英文引用可以保留原文。

## 核心角色

| 角色 | 主要职责 | 是否进入标准门禁 |
|------|----------|------------------|
| PM | 需求、范围、验收标准、迭代规划 | 是 |
| Architect | 架构设计、技术边界、ADR、接口/数据流 | 是 |
| Developer | 代码实现、测试、修复 Review 问题 | 是 |
| DevOps | 部署、环境、健康检查、发布就绪 | 独立部署门禁 |
| Role Creator | 新角色设计、职责边界、接入模板 | 元流程，不参与普通迭代 |

## 推荐安装方式

1. 将本目录复制到新项目，或把 `CLAUDE.template.md` 改名为项目根目录的 `CLAUDE.md`。
2. 将 `docs/baseline/project-context.template.md` 复制为 `docs/baseline/project-context.md` 并填写项目事实。
3. 初始化 `docs/progress/INDEX.md`、`docs/progress/iterations/`、`docs/progress/roles/`。
4. 每次启动 Claude Code 时指定角色，例如：`这次以 Architect 角色工作`。

## 基本原则

- `CLAUDE.md` 只做入口索引，不塞长篇流程。
- `project-context.md` 只写项目事实，不写通用流程。
- `multi-agent-workflow.md` 是通用协作规则，不写具体项目业务。
- 每个阶段必须先定稿再进入下一阶段。
- Review 方只审自己职责边界内的问题。
- 发现流程问题时先写提案，不能直接改基线。
