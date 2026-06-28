# 生态根「立项受理职责」设计

> 日期：2026-06-28
> 范围：给 niuma-cheng 生态根目录（`/Users/ck/Project/niuma-cheng/CLAUDE.md`）增加「立项受理」职责，并在 agent-workflow baseline 补充立项编排归属说明。
> 状态：设计已经 Owner 批准（阶段一/二/三成立），待落地。

## 1. 背景与问题

生态里"Owner 想立一个新项目"这个**起点目前无人承接**：`ai` 接入时流程偏临时。需要明确**谁受理立项、按什么顺序把空项目架起来、各环节归哪个真源**。

约束来自现有架构：

- 根目录自我定义是 **只读导航 / 索引助手**：默认只读、**绝不修改子项目**、**不进入任何子项目工作流角色**；唯一既有例外是「索引维护职责」（照 `PROJECTS.md` 真源订正本文件索引）。
- 项目 meta 单一真源是 **coordination `PROJECTS.md`**；根对 coordination **只读**（输出待登记内容，由 coordination 会话落）。
- 工作流框架靠 `agent-workflow/scripts/install-downstream.sh` 复制到下游，脚本设计为 **"仅在真源仓库内运行"**，产出纯文件副本（剥离 SOURCE-REPO-ONLY、带 baseline/templates、铺 `project-context.md` 占位），**不碰 git、不做 Bootstrap**。
- workboard 每 60s **只读** `projects.config.json` + 各项目 `docs/progress/` 聚合，**不回写**；新项目要被它看到，得手工往 `projects.config.json` 加一行。

## 2. 核心决策

根目录在立项流程里担任 **「受理 + 编排口」**，不是"亲手执行全部写操作的中枢"。理由：新项目立项那一刻项目尚不存在，Owner 物理上站在生态根，根当受理口最自然；但"受理"不等于"根包揽所有真源的写入"，否则会破坏只读边界与单一真源闭环。

立项是现有「元信息流转闭环」的**创世特例**：没有"已存在子项目"来发起变更，改由根受理代发起；但 meta 仍落 coordination 真源，根仍只做「索引同步」那一环。

### 关键概念澄清："导入工作流" = 两件不同的事

| 动作 | 实质 | 执行位置 | 是否工作流角色动作 |
|---|---|---|---|
| ① 框架拷贝 | 跑 `install-downstream.sh <新目录>` | agent-workflow 真源仓库 | 否，纯文件 setup |
| ② Bootstrap + 定位 | 填 `project-context.md`、Bootstrap 建 `docs/progress/`、确立定位 | 新项目会话 | 是，必须项目会话做 |

根可触发 ①（setup 性质）；② 必须留新项目会话。原设计把 ① 误丢给新项目会话，导致"建壳后衔接不上"的困惑。

## 3. 三阶段流程

### 阶段一 · 根一条龙，产出"已铺好框架的空项目"

**物理侧（根独立完成，对应 Owner 说的"整个空项目架构 + 所有前置条件"）：**

1. **受理**：根收集立项要素——项目 id / 名称 / 定位 / 技术栈 / 远端仓库地址 / 分类(内部) / 关联项目，输出草案。
2. **建壳 + 导入框架**：根 `cd agent-workflow` 跑 `scripts/install-downstream.sh ../<新目录>`（脚本自建目录、铺框架）。
3. **首推远端**：新目录内 `git init` + 初始 commit + `git remote add` + `git push -u origin main`。**push 前确认远端空仓库已由 Owner 在 GitHub 建好**（`gh repo create` 或网页）。

**信息侧（收尾，不阻塞 Owner 进项目）：**

4. **输出交接制品**：根产出一段可直接复制的 Markdown，供下游会话核对落地（根不直写任何下游真源）：
   - `PROJECTS.md` 新项目块草案（id / 名称 / 技术栈 / 仓库 / 职责边界 / 当前入口 / 关联项目 / 沟通文档）；
   - `STATUS.md`「各项目当前状态」表新增一行（立项的 STATUS 登记**只指状态表**；立项**一律不进**「元信息变更台账」——台账只追踪既有项目 old→new 字段变更，立项是创世、不走迭代关闭检查。规则定死，不留"多数/视情况"）；
   - 根「项目索引」表新增行草案；
   - workboard `projects.config.json` 新增项草案。
   - 凡 Bootstrap 后才确定的字段（如"当前入口"= 项目 `docs/progress/INDEX.md`），标注"待 Bootstrap 后回填"，根不脑补。
5. **落地与索引同步**：coordination 会话照草案落 `PROJECTS.md` + 状态表加行；待 `PROJECTS.md` 更新后，根照真源把新项目加进根「项目索引」表（**由立项流程本步直接驱动，不依赖元信息变更台账行、也不退化成被动自检**）。（workboard 上架见阶段三，根只在步骤 4 出草案。）

### 阶段二 · Owner 进新项目会话（正常 agent 工作流编排）

进新目录开会话 → 描述立项要做什么 → 填 `project-context.md` → Bootstrap → 项目定位 → 进首迭代。

### 阶段三 · 看板上架

workboard 会话照根在步骤 4 输出的 config 项草案，往 `projects.config.json` 加一行 `enabled:true`（属 workboard 自身职责，根只出草案、不直写）。

## 4. 边界与例外授权

- **新增例外（覆盖完整阶段一物理侧 · 一次性建壳）**：作为"绝不进入子项目做事"的**显式例外**，根在立项时可：
  1. 创建一个不存在或为空的新项目目录；
  2. 运行 `install-downstream.sh` 往该目录产出框架文件——**对 agent-workflow 真源只读；对该新目录执行一次性框架写入**（不是纯只读动作）；
  3. 在该新目录内执行 `git init`、首 commit、`git remote add`、首次 push。
  - **限定**：仅限"项目正式移交新项目会话前"的一次性建壳动作；移交后根不再进入该项目做 Bootstrap、定位、迭代或后续开发。
  - 全程不修改 agent-workflow 自身，不进入任何子项目工作流角色。在新职责段里显式写明，避免靠脑补。
- **根不做（YAGNI / 守边界）**：
  - 不替代 ② Bootstrap / 项目定位（留新项目会话）。
  - 不直写 `PROJECTS.md`（meta 真源属 coordination）。
  - 不改 workboard 的 `projects.config.json`（上架属 workboard）。
  - 不自动在 GitHub 建远端仓库（Owner 外向动作）。

## 5. 落地改动点（两处）

### 改动 1：根 CLAUDE.md 新增「立项受理职责」段

`/Users/ck/Project/niuma-cheng/CLAUDE.md`，在「索引维护职责」段之后新增一节，风格对齐现有段（含闭环图 + 触发 / 动作 / 例外 / 边界）。内容覆盖第 3、4 节：受理 → 建壳+导入框架 → 首推远端 → 输出四份交接制品草案 → coordination 落地 + 根索引同步（workboard 上架留阶段三）；并写明**扩展后的例外授权（覆盖完整物理侧建壳：建目录 / install / git init+push）** 与"不做"清单。

> 注：生态根 `CLAUDE.md` 与 `AGENTS.md` 是双入口镜像（仅 Claude↔Codex 措辞不同），新增段须**同步加入两者**保持逐字一致。生态根目录本身不是 git 仓库，此两文件改动无需 commit。

### 改动 2：agent-workflow baseline 补立项编排归属

`docs/baseline/cross-project-collaboration.md` §新项目复用团队工作流，补一段：新项目"受理 + 建空项目架构（建壳 / install-downstream / 首推远端）"由生态根「立项受理职责」承接；meta 登记仍落 coordination `PROJECTS.md`；Bootstrap + 定位仍在新项目会话；现有 1–3 步与生态根物理侧衔接——根跑完 install-downstream 后，新项目会话从"填 project-context"接续。并点明：第 232 步的 STATUS.md 登记指「各项目当前状态」表；**立项不进「元信息变更台账」**（台账只追踪既有项目字段变更）。

> 此文件在 agent-workflow 仓库，改动随仓库正常提交（按 Owner 指示决定何时 commit）。

## 6. 验收标准

- 根 CLAUDE.md 读到「立项受理职责」段，能据此独立完成阶段一物理侧（建壳 / 导入框架 / 首推远端），且明确把 meta 登记移交 coordination、Bootstrap 移交新项目会话。
- baseline §新项目复用 能从"生态根编排"无缝衔接到"新项目会话填 project-context"。
- 根能产出四份可直接复制的交接制品草案（`PROJECTS.md` 块 / `STATUS.md` 状态表行 / 根索引行 / workboard config 项），Bootstrap 后才定的字段标注"待回填"；**立项不进元信息变更台账**的规则被明确写死，spec 与 baseline 不再各走一套。
- 两文件对 install-downstream"仅真源仓库内运行"、根对 coordination"只读"、根"不进子项目工作流角色"三条原有约束零破坏；新增例外**覆盖完整阶段一物理侧（建目录 / install / git init+push）** 且被显式写明，措辞准确区分"对真源只读、对新目录写入"。
