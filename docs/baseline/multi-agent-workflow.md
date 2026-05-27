# Claude Code 一人公司多角色协作基线

| 字段 | 值 |
|------|-----|
| 版本 | v1.0 |
| 状态 | 通用模板 |
| 适用范围 | 使用 Claude Code 的单人/小型项目 |

## 1. 目标

这套基线把 Claude Code 会话组织成一个轻量开发团队：同一个人可以在不同时间以 PM（产品经理）、UI（界面设计师）、Architect（架构师）、Developer（开发工程师）、Tester（测试工程师）、DevOps（运维/部署工程师）等角色启动 Agent，让项目拥有启动、需求、界面、设计、实现、测试、部署和复盘的持续记忆。

人类用户是项目 Owner 和实际项目经理，负责最终协调、优先级判断和流程取舍。工作流不设置常驻 Project Manager Agent，避免让一人公司产生没有实际价值的管理层。

它不是企业级流程管理系统。它的重点是：少量文件、明确职责、可追溯状态、可复用模板。

## 2. 文件结构

```text
CLAUDE.md
└── docs/
    ├── baseline/
    │   ├── project-context.md
    │   ├── multi-agent-workflow.md
    │   ├── work-modes.md
    │   ├── mechanisms.md
    │   ├── bootstrap.md
    │   ├── conventions.md
    │   ├── role-pm.md
    │   ├── role-ui.md
    │   ├── role-architect.md
    │   ├── role-developer.md
    │   ├── role-tester.md
    │   ├── role-devops.md
    │   └── role-creator.md
    └── progress/
        ├── INDEX.md
        ├── iterations/
        ├── ad-hoc/
        └── roles/
```

`baseline/` 写“怎么协作”，`progress/` 写“实际做了什么”。

## 3. 角色名称

文档中首次出现角色时应优先使用“英文代号（中文名称）”格式，方便阅读，同时保留稳定角色 id。

| 英文代号 | 中文名称 |
|----------|----------|
| PM | 产品经理 |
| UI | 界面设计师 |
| Architect | 架构师 |
| Developer | 开发工程师 |
| Tester | 测试工程师 |
| DevOps | 运维/部署工程师 |
| Role Creator | 角色创建者 |

## 4. 语言规则

这套工作流默认且必须以中文进行对话和协作。

- Agent 与用户的沟通使用中文。
- PRD、设计文档、Review 结论、部署检查、角色日志、纠错记录和基线修正提案使用中文。
- 代码标识符、命令、错误信息、第三方 API 名称、英文引用和用户明确要求的外文内容可以保留原文。
- 如果用户要求输出英文或双语内容，以用户当次明确要求为准；否则回到中文。
- 不要因为角色名是 PM、Architect、Developer、DevOps，就把工作流对话切换成英文。

## 5. 工作模式

本工作流支持标准迭代和非迭代工作两类模式。标准迭代用于明确要落地的产品功能；Bugfix、线上故障、产品方案、UI 草案、技术预研、运维任务等不强制进入迭代。

具体模式选择、记录路径和升级规则见 `docs/baseline/work-modes.md`。

## 6. 标准迭代流水线

```text
Bootstrap 初始化 -> PRD 阶段 -> UI 方案阶段 -> 设计阶段 -> 实现阶段 -> 测试阶段 -> 部署就绪检查 -> 用户确认迭代关闭
```

| 阶段 | 产出方 | Review 方 | 定稿条件 |
|------|--------|-----------|----------|
| Bootstrap 初始化 | 任一 Agent 按流程执行 | 用户确认 | 项目上下文和目录结构初始化完成 |
| PRD | PM（产品经理） | UI（界面设计师）、Architect（架构师）、Developer（开发工程师）、Tester（测试工程师） | 所有 Review 方通过 |
| UI 方案 | UI（界面设计师） | PM（产品经理）、Architect（架构师）、Developer（开发工程师）、Tester（测试工程师） | 所有 Review 方通过，或明确本迭代无 UI 变更 |
| 设计 | Architect（架构师） | PM（产品经理）、UI（界面设计师）、Developer（开发工程师）、Tester（测试工程师） | 所有 Review 方通过 |
| 实现 | Developer（开发工程师） | PM（产品经理）、UI（界面设计师）、Architect（架构师）、Tester（测试工程师） | 所有 Review 方通过 |
| 测试 | Tester（测试工程师） | PM（产品经理）、Developer（开发工程师） | 测试报告通过，阻塞缺陷关闭或明确延期 |
| 部署 | DevOps（运维/部署工程师） | 无标准 Review | 部署检查通过，或明确记录阻塞/跳过原因 |
| 迭代关闭 | 当前 Agent 执行关闭检查 | 用户确认 | INDEX、迭代记录、角色日志状态一致 |

当前阶段未定稿前，不进入下一阶段。Spike 或纯技术预研可以跳过部分阶段，但必须在迭代记录中说明原因和实际 Review 方。

PM（产品经理）负责产品内容是否正确，但不代表人类做最终项目协调。阶段推进、优先级取舍、是否接受风险延期，由人类 Owner 最终确认。

Bootstrap 初始化、迭代关闭检查、流程审计不是角色，而是非角色机制。触发时机、执行者和结束条件见 `docs/baseline/mechanisms.md`。任何当前会话 Agent 都可以在用户要求或自动检测到触发条件后执行这些机制，但结果必须由用户确认。

## 7. 状态机

产出文档和阶段门禁使用同一套状态词：

| 状态 | 含义 |
|------|------|
| 待Review | 初版刚提交，尚无人 Review |
| Review中 | Review 方正在反馈，或等待部分 Review 方反馈 |
| 修改中 | 产出方正在处理 Review 问题 |
| 已定稿 | 当前阶段所有必需 Review 均通过 |
| 阻塞 | 需要人类或外部条件解除 |
| 已跳过 | 该阶段不适用于本迭代，必须写原因 |

推荐唯一真源：`docs/progress/iterations/vX.Y.md` 的阶段门禁表。PRD/设计文档头部可以保留摘要，但定稿前必须检查两处状态一致。

## 8. Review 轮次

每个阶段按 `R1`、`R2`、`R3` 递增。

- `R1`: 初版提交。
- 有任何 `需修改`：产出方进入 `修改中`，修完后提交 `R2`。
- 全部 `通过`：产出方将阶段改为 `已定稿`。

Review 记录必须包含：轮次、结论、问题、严重程度、建议。不要只写“感觉不行”。

## 9. 写权限

| 文件 | 谁能改正文 | 谁能追加 |
|------|------------|----------|
| PRD | PM（产品经理） | UI（界面设计师）、Architect（架构师）、Developer（开发工程师）、Tester（测试工程师）追加 Review |
| 设计文档 | Architect（架构师） | PM（产品经理）、UI（界面设计师）、Developer（开发工程师）、Tester（测试工程师）追加 Review |
| 代码 | Developer（开发工程师） | Review 方不直接改，除非用户明确要求 |
| UI 方案 | UI（界面设计师） | PM（产品经理）、Architect（架构师）、Developer（开发工程师）、Tester（测试工程师）追加 Review |
| 测试报告 | Tester（测试工程师） | PM（产品经理）、Developer（开发工程师）追加 Review |
| 非迭代工作记录 | 执行角色 | 其他角色只在被邀请时追加意见 |
| 迭代记录 | 各阶段相关角色按职责更新 | Review 方追加自己的 Review 记录 |
| 角色日志 | 对应角色 | 无 |
| baseline/ | 经过人类确认后指定角色修改 | 任何角色可提出提案 |

## 10. Git 安全规则

每次开始：

```bash
git status --short
git pull --rebase
git log --oneline -10
```

如果发现未归属修改，先判断是否属于本次任务。不能覆盖、重置或顺手清理他人修改。

每次结束：

```bash
git status --short
git add <本次文件>
git commit -m "[Role] vX.Y 动作摘要"
git pull --rebase
git push
```

实现阶段 Review 必须记录 diff 范围：`base_commit` 到 `head_commit`。

## 11. 角色日志和纠错

每个角色维护：

```text
docs/progress/roles/{role}.md
docs/progress/roles/{role}-corrections.md
```

角色日志记录本次做了什么。纠错记录记录本角色犯过什么流程错误、如何避免复发。纠错记录保持 30 条以内。

## 12. 基线修正

任何角色发现流程规则有问题，不能直接改 `baseline/`，先在角色日志中写：

```text
[基线修正提案] 问题：...；建议：...
```

Architect（架构师）或 Role Creator（角色创建者）可汇总提案，但修改基线必须经过人类确认。

## 13. 角色创建机制

角色创建是可行的，但必须受控。坏的角色会增加流程噪音，让一人公司变成“一个人在管理一堆虚假岗位”。

新增角色必须满足至少一条：

- 有独立产出物。
- 有独立 Review 视角。
- 有明确不可替代的专业边界。
- 能减少现有角色的认知负担。

不应该新增角色的情况：

- 只是把一个任务换个名字。
- 职责和现有角色高度重叠。
- 没有产出路径、状态入口或退出条件。
- 增加的协调成本大于收益。

新增角色必须通过 `role-creator.md` 的流程，并更新角色矩阵、迭代模板、日志和纠错文件。
