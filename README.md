# Claude Code One-Person Company Workflow

一套面向“一人公司”的 Claude Code 多角色开发团队工作流。它的目标不是制造复杂流程，而是让同一个人可以按角色启动不同 Claude Code 会话，稳定完成从产品定义、架构设计、实现、Review、部署检查到复盘纠错的闭环。

这套工作流适合复制到任何 Claude Code 项目中使用。项目自己的业务背景、技术栈、启动方式、当前迭代状态写入 `docs/baseline/project-context.md`，通用协作规则保持不变。

## 语言约定

这套工作流默认且必须使用中文进行对话和协作。PRD、设计文档、Review 结论、部署检查、角色日志、纠错记录和基线提案都使用中文；代码标识符、命令、错误信息、第三方 API 名称和必要英文引用可以保留原文。

## 核心角色

| 角色 | 主要职责 | 是否进入标准门禁 |
|------|----------|------------------|
| PM（产品经理） | 需求、范围、验收标准、迭代规划 | 是 |
| UI（界面设计师） | 用户流程、界面结构、交互规范、视觉约束 | 是 |
| Architect（架构师） | 架构设计、技术边界、ADR、接口/数据流 | 是 |
| Developer（开发工程师） | 代码实现、测试、修复 Review 问题 | 是 |
| Tester（测试工程师） | 测试策略、测试用例、验收验证、缺陷回归 | 是 |
| DevOps（运维/部署工程师） | 部署、环境、健康检查、发布就绪 | 独立部署门禁 |
| Role Creator（角色创建者） | 新角色设计、职责边界、接入模板 | 元流程，不参与普通迭代 |

人类用户是项目 Owner（负责人）和实际项目经理，负责最终协调、优先级和流程取舍。工作流不设置常驻 Project Manager（项目经理）Agent，避免把一人公司做成虚假的管理层。

## 非角色机制

Bootstrap 初始化、收尾归档、迭代关闭检查、流程审计不是角色。它们由当前会话 Agent 在用户要求或检测到触发条件时执行，关键结果由用户确认。详细规则见 `docs/baseline/mechanisms.md`。

## 工作模式

不是所有工作都进入标准迭代。Bug 修复、线上故障、产品方案沉淀、UI 草案、技术预研、外部/开源项目部署等，可以按非迭代工作处理，记录在 `docs/progress/ad-hoc/`。详细规则见 `docs/baseline/work-modes.md`。

用户说“今天收尾”“下班”“先停一下”时，当前 Agent 执行收尾归档：更新角色日志、当前工作记录、项目索引、必要的知识库条目和下一步入口。

## Review 机制

标准迭代采用动态 Review 计划，不采用固定全员 Review。产出方根据本次影响领域指定 Review 方并写明理由；核心产出默认至少指定 2 个 Review 方，少于 2 个需用户确认。文档定稿后发现问题，按实现取舍、轻量变更、重大变更三档处理。轻量变更通过 Change Note 由受影响角色确认，执行完成后必须归档。

## 团队知识库和上下文

可复用知识沉淀在 `docs/knowledge/`，例如产品机会、重构机会、Bug 根因、部署经验和复盘结论。详细规则见 `docs/baseline/knowledge-base.md`。

为避免上下文膨胀，Agent 启动时只读索引、摘要和相关文件；角色日志过长时按 `docs/baseline/context-policy.md` 摘要归档。

## 推荐安装方式

1. 将本目录复制到新项目，或把 `CLAUDE.template.md` 改名为项目根目录的 `CLAUDE.md`。
2. 将 `docs/baseline/project-context.template.md` 复制为 `docs/baseline/project-context.md` 并填写项目事实。
3. 初始化 `docs/progress/INDEX.md`、`docs/progress/iterations/`、`docs/progress/roles/`。
4. 空项目第一次启动时，先说：`执行 Bootstrap 初始化流程`，并按 `docs/baseline/bootstrap.md` 初始化。
5. 后续每次启动 Claude Code 时指定角色，例如：`这次以 Architect（架构师）角色工作`。

## 基本原则

- `CLAUDE.md` 只做入口索引，不塞长篇流程。
- `project-context.md` 只写项目事实，不写通用流程。
- `multi-agent-workflow.md` 是通用协作规则，不写具体项目业务。
- 每个阶段必须先定稿再进入下一阶段。
- Review 方只审自己职责边界内的问题。
- 发现流程问题时先写提案，不能直接改基线。
