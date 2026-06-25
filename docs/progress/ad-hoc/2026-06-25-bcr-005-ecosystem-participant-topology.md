# BCR-005 设计 · 生态参与者拓扑 + 跨界协议（父框架）

- 日期：2026-06-25
- 提出方 / 设计方：agent-workflow 真源会话（General，Owner 驱动）
- 关联：coordination `REQUESTS.md` 基线修正提案池 · BCR-005
- 状态：**设计 v1，待 Owner review**（review 通过 → 落 agent-workflow 产品层 baseline → sync 回流）
- 收编：BCR-003（元信息同步台账）、根 `/root/Project/CLAUDE.md` 重设计、「授权直写 vs 人肉转述」缺口——三者都是本拓扑的 facet，不再各打补丁。

> **本文是评估附件，非状态真源。** BCR-005 流转状态以 coordination `REQUESTS.md` 为准。review 由 Owner 拍板。

---

## 一、要解决的问题

生态里有几类**非开发**参与者（coordination 协调台账、根索引、框架真源自己）一直是**游离定义**的——它们的角色、边界、"谁能改谁"散落在各自仓的 CLAUDE.md / cross-project-collaboration.md / PROJECTS.md，没有一处系统定义。后果：

- 「谁该动手改 coordination / 根索引」靠临场判断 → 退化成 **Owner 人肉转述**（BCR-003 评估记录转录走样 `748dc22`→`58de4eb` 就是回归证据）。
- coordination 是不是工作流的一部分、受不受管控，说不清。

**目标**：在 agent-workflow 产品层，把整个生态当**一个系统**定义清楚——每类参与者的性质、边界、各机制职责、跨仓写协议。coordination / 根索引不再游离，而是一等参与者。

## 二、参与者拓扑（核心）

| 节点 | 实例 | 性质 | 装 dev 工作流? | 在各机制的职责 | 跨仓写权限 |
|------|------|------|----------------|----------------|------------|
| **框架真源** | `agent-workflow` | 工作流产品 single source，自我演进 | **否**（真源仓 General 直接维护制品，不走角色/Review 门禁，见防滑 `1d55eea`） | 维护 baseline/模板/入口产品；**评估/采纳/落地 BCR** | ✅ 直写 coordination 的 BCR 池（状态/评估记录）；❌ 不改下游业务代码；❌ 不改根文件 |
| **协调真源台账** | `coordination` | 跨项目边界事实 single source（契约/REQ/BCR/STATUS/PROJECTS），纯 Markdown | **否**（门禁空转，General 直接维护台账） | 登记/回填 REQ·BCR·元信息台账；维护 STATUS/PROJECTS/契约真源；是 BCR **登记处、非回流对象** | 维护自己台账；❌ 不直写其他仓 |
| **开发型下游** | `xiaobao` / `ai` / `workboard` | 业务开发项目，已接入 dev 工作流 | **是** | 仓内按角色/门禁开发 | ✅ 向 coordination 登记 REQ/BCR/元信息台账行（既有「下游写 coordination」模型）；❌ 不改 baseline、不改别的下游 |
| **生态索引根** | `/root/Project/CLAUDE.md` | 生态导航视图，受工作流管控（不游离） | **否**（只读导航 + 索引维护职责，见根重设计草案） | 照 `PROJECTS.md` 同步索引；订正本文件不算改子项目 | ❌ 对 coordination 只读：输出回执/待写内容，不直写台账（见根重设计 §三总原则） |

## 三、跨界写协议（直写 vs 转交）

补的就是「Owner 当人肉信道」那个缺口：

1. **授权直写优先**：节点对某事有权威 **且** [P0] 允许写目标仓时，**直接跨仓写**（先满足 [P0]：确认仓位置 + git 同步 + 改动范围 + 只写跨项目事实），**不经 Owner 转述**。
2. **转交仅限跨权限边界**：只有当本节点对目标仓**无权限**时才转交（如真源会话/下游 → 根文件）。
3. **转交必走「读文件 / 精确制品」**，**禁止靠 Owner 口头/retype 重述状态真源**——retype 是有损信道（BCR-003 评估记录 garble 为回归用例）。

**「谁能写什么」矩阵**（由上表跨仓写权限列汇总）：

| 目标 | 框架真源 | coordination | 开发型下游 | 生态索引根 |
|------|---------|--------------|-----------|-----------|
| `baseline/` | ✅ | ❌ | ❌（只提 BCR） | ❌ |
| coordination 台账 | ✅(BCR池) | ✅(自有) | ✅(REQ/BCR/元信息) | ❌(只读+回执) |
| 根 `/root/Project/CLAUDE.md` | ❌ | ❌ | ❌ | ✅ |
| 下游业务仓 | ❌ | ❌ | ✅(自己) | ❌ |

## 四、三个 facet 如何收编

- **BCR-003（元信息同步台账）** = 本拓扑里「元信息变更」这条**跨界数据流的具体机制**（子项目→coordination→根索引）。
- **根 CLAUDE.md 重设计** = 本拓扑里「生态索引根」节点定义的**落地实现**。
- **直写 vs 转述** = 本拓扑 §三**跨界写协议**本身。

三者保持各自的设计游标与落地节奏，但**定位**统一挂在 BCR-005 之下。

## 五、落地方案（review 通过后）

- 目标文件：agent-workflow `docs/baseline/cross-project-collaboration.md`，新增一节「## 生态参与者与跨界协议」，承载 §二拓扑表 + §三协议 + 矩阵。
- 通用性把关：表内「生态索引根」写**通用措辞**（不在通用 baseline 硬编码 `/root/Project/CLAUDE.md`，沿用 BCR-003 §九设计注的取舍），本生态特定路径留在根 CLAUDE.md 自己。
- 自检：`./scripts/measure-context.sh`（评估固定层增量）；属会回流 baseline，落地后跑 `scripts/sync-downstream.sh` 自检。

## 六、待 Owner 拍板点

1. §二拓扑的**四类节点划分**是否完整、准确（尤其 coordination「非回流对象」、根「只读+回执」）？
2. §三**跨界写协议**三条 + 矩阵是否就是你要的"少经人肉信道"？
3. 落地位置放 `cross-project-collaboration.md` 新节，是否 OK（还是单列一个 `ecosystem-topology.md` baseline 文件）？
4. 通用 baseline 不硬编码本生态根路径的取舍，继续保持？

## 七、本次未做 / 待续

- 未改 baseline（本文仅设计 v1）。
- BCR-005 将在 coordination 登记为「评估中」，提出方=框架真源 General（自举型，同 BCR-001）。
- 验证：仅文档/状态核对，未跑脚本。
