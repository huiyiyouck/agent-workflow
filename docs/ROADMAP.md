# agent-workflow 演进路线

> **本文档性质**：真源仓库自身的开发规划，不属于被复制到下游的工作流产品。
> 下游项目复制工作流时可删除本文件。基线数据随版本变化，每完成一个阶段需用 `scripts/measure-context.sh` 复测更新。

## 当前进度（会话游标）

> **每次新会话开始先读本节**，即可知道「在做什么、做到哪、下一步干什么」，无需用户重述。每次推进后更新本节（改日期 + 各字段）。

- **更新于**：2026-06-22
- **正在做**：BCR-002（communications 命名轴 项目对→按需求）真源侧已落地（PR #6，merge `0a76dca`，落地 commit `b5a29a3`）。真源侧无待办。
- **当前阶段**：P0→P8 完成。P8 机制已跑通两个真实 BCR：BCR-001（自举，已回流下游闭环）、BCR-002（真源已落地，待 coordination/下游回流）。
- **已完成**：P1（`2701013`）+ P2（`04369cc`）+ P3（`79116bd`）+ P4（PR #1，merge `c112a9d`）+ P5（PR #2，merge `ddf5683`）+ **P7 全部完成**（PR #3 `6bfba79` / ai `6675531` / xiaobao `1dae522`）；ADR 路径修正（`c50bec0`）；P8 方案定稿（PR #4，merge `fe99ac3`）+ **P8 实现落地真源**（PR #5，merge `663f59b`，commit `fc22e75`）；**BCR-001 全闭环**（coordination 终态「已回流下游」，ai/xiaobao sync 至 `c8c66ce`）；**BCR-002 真源落地**（PR #6，merge `0a76dca`，commit `b5a29a3`；方案存档 `8af4e62`）。
- **下一步**（均非真源会话，真源侧无待办）：① coordination 会话把 `BCR-002` 标「已采纳→已落地真源」，回填落地 commit `b5a29a3`（merge `0a76dca`），实体迁移 `xiaobao__ai.md`→`REQ-001-news-l1.md` + 更新 `REQUESTS.md`/`PROJECTS.md`/`communications/README.md`；② ai/xiaobao 会话跑 `sync-downstream.sh` 回流；③ 回流清单完成后 coordination 把 `BCR-002` 标「已回流下游」终态。下一个新阶段（P9+）待 Owner 提出（候选：`workboard` 接入工作流）。
- **本轮搁置（明确不做）**：`workboard` 接入工作流。

## 演进定位

作为 Claude / Codex 可复用的「一人公司」团队工作流，本轮正向迭代要在两个相互拉扯的约束间取得平衡：

1. **按角色加载的上下文足够短** —— 每次进工作流 / 进角色的固定 token 成本要低。
2. **加载的上下文足够理解整个项目** —— 少量 token 就能让 Agent 抓住项目全貌和当前状态。

解张力的总思路是**分层**：固定成本层极致瘦身、项目理解层高密度、长尾规则细节按需检索。

> ⚠️ **核心风险（贯穿全程）**：工作流的本质是一堆边界规则在防止 Agent 误操作。把「减少 token」当唯一主指标，最容易把**低频但高危**的规则（force push 禁止、受保护路径删除门禁等）当「长尾」裁掉。因此压缩必须配套**风险分级 + 触发索引 + 回归用例**，缺一不可。

## 当前基线（实测，2026-06-19，口径见 `scripts/measure-context.sh`）

字符数（`wc -m`），约 1.5–1.7 token/字。统一字符口径，不混用字节数。

| 加载层 | 文件 | 字符 | 读取时机 |
|--------|------|------|----------|
| 固定层 | `CLAUDE.md` / `AGENTS.md`（入口） | 2,699 | 每次会话 |
| 固定层 | `runtime.md`（路由中枢） | 4,357 | 每次进工作流 |
| 迭代固定层 | `multi-agent-workflow.md` | 7,941 | 每次标准迭代必读（单文件最重） |
| 角色层 | `role-developer.md`（最重角色） | 3,504 | 指定该角色时 |
| 安全门禁 | `conventions.md`（删除门禁 + 事故复盘） | 3,146 | 触发删除 / Git 高危操作时 |

- **固定层（入口+runtime）= 7,056 字符**
- **标准迭代最重链路（+role-dev+multi）= 18,501 字符**，尚未算 `project-context`、`INDEX`、迭代摘要、模板片段。

**P1 改造后（2026-06-19，含第五轮 diff 复审修复）**：`runtime.md` 4357→**2606**（承载非迭代对称分流 + 双速查触发索引 + 模板可达性，职责较原计划扩展，硬上限相应放宽至 ≤2700，可达性优先于字数）；新增 `standard-iteration-quick.md` 1225 / `non-iteration-quick.md`（非迭代对称拆分，P1 范围扩展）；标准迭代启动链路 18501→**约 9900（≈-46%）**；固定规则链路 < 13000 硬指标。`multi-agent-workflow.md` 7941 与 `work-modes.md` 降为完整规范、按需读取。已修 4 项 diff 复审问题：Review 正文保护、PRD 模板可达、N4 口径、角色手册区分迭代/非迭代 Review。

## 衡量指标

- **主指标（P1 硬约束）**：固定规则链路（入口 + runtime + 标准迭代必读）字符数。
- **观测指标**：真实启动链路样例（叠加 role + project-context + INDEX）字符数 —— P1 用现有 template 估算观测，**P2 定义固定 fixture 口径后转硬验**。
- **硬约束（不可回归）**：行为不变。回归用例集（正向 / 负向 / 高危门禁）全部通过。
- **风险约束**：P0 高危规则不得因「低频」被移出可达路径。

## 阶段路线

### P0 度量与防漂移工具（已先行落地）

先于 P1，提供「先量基线再改」的前提工具，避免手算口径漂移、避免双入口漂移。

- `scripts/measure-context.sh`：输出单文件体量、链路合计、双入口一致性（已完成）。
  - ⚠️ 局限：只测「文件体量上界」，不等于实际加载量（实际链路取决于 runtime 按需读取决策）。体量看脚本，**行为看回归用例**，二者互补。
- **回归用例集**：清单见 `docs/regression-cases.md`（正向 / 负向 / 高危门禁，含补强后新增门禁：AI commit 核对 diff stat、Review 不得改正文、机制不代写他人角色结论/日志、禁止直接改他人角色日志、基线修正只能提案）。P1 改 baseline 前后各走一遍。

### P1 瘦身固定加载层（首攻）

**目标**：降低「每次进工作流 / 每次标准迭代」固定成本，主攻 `runtime.md`、`multi-agent-workflow.md`，并把 `conventions.md` 的 P0 门禁纳入引用映射。

**前置验证（动手前必做）**：盘点三处来源，填「P1 分类表」，据此决定走拆分还是精简重写。
- 来源范围：`multi-agent-workflow.md`（292 行）、`runtime.md` 质量底线段、`conventions.md` 的 P0 安全门禁（54-106）。
- 判据：**按风险加权，而非纯数量**。
  - 若高危规则集中且低频 → 可拆，但 P0 必留可达路径；
  - 若大部分高频必读 → 拆分只增跳转，改**精简重写**（压缩表达，不分文件）。

**P1 分类表（前置验证草案，2026-06-19）**：

| 规则 | 频率 | 风险 | 处置 |
|------|------|------|------|
| General 不读工作流基线，只有明确/确认触发才进入工作流 | 高 | P1 | 入口文件保留，runtime 只承接工作流后路由 |
| 工作流默认只读入口、runtime、project-context、INDEX、当前角色手册和摘要 | 高 | P1 | runtime 路由表保留，压缩表达 |
| 未初始化项目不能自动 Bootstrap，必须用户确认 | 中 | P0 | runtime 红线保留，Bootstrap 细节指向 `bootstrap.md` |
| Bootstrap、角色切换、非迭代任务都不等于标准迭代 | 高 | P1 | runtime 红线 + 标准迭代速查保留 |
| 标准迭代只能 PM 创建 PRD，其他角色只能建议切 PM | 高 | P1 | runtime 红线 + 标准迭代速查保留 |
| 工作模式分流：标准迭代 / 非迭代 / 收尾 / 关闭 / 知识库 | 高 | P1 | runtime 保留意图路由表；各模式细则按需读 |
| 旧版 Bootstrap 遗留状态需要纠正 | 低 | P1 | runtime 触发索引保留，细节可压缩 |
| 标准迭代流水线与阶段顺序 | 高 | P1 | 标准迭代速查表保留 |
| 当前阶段未定稿前不得进入下一阶段 | 高 | P1 | 标准迭代速查表保留 |
| 阶段回环规则：前置产出修改后只重确认受影响下游 | 中 | P1 | 标准迭代速查表短句 + 完整规范详述 |
| 状态词命名空间与状态真源 | 高 | P1 | 状态机表格保留在速查表 |
| 动态 Review 计划：影响领域决定 Review 方 | 高 | P1 | 速查表保留选择矩阵 |
| 标准迭代核心产出默认至少 2 个 Review 方，少于 2 个需用户确认 | 高 | P1 | runtime 红线短句 + 速查表保留 |
| Review 轮次 R1/R2/R3，R3 仍未通过升级阻塞 | 中 | P1 | 速查表保留状态机 |
| 缺陷严重度定义 | 中 | P2 | 完整规范保留；Tester/Review 触发时按需读 |
| 定稿后问题三档：实现取舍 / 轻量变更 / 重大变更 | 中 | P1 | 速查表保留三档表格 |
| 写权限矩阵 | 中 | P1 | 速查表保留压缩版；完整规范保留全表 |
| 角色日志和纠错记录 | 中 | P2 | runtime 留会话结束红线；细节指向 `context-policy.md` |
| 基线修正只能提案，不能在下游项目直接改 baseline | 低 | P0 | runtime 红线短句 + 速查表触发索引 |
| 角色新增/修改/删除必须受控 | 低 | P2 | 完整规范保留；触发“新增角色”时按需读 |
| 中文对话和中文记录默认规则 | 高 | P2 | runtime 红线保留 |
| 人类用户是 Owner，不虚拟常驻项目经理 | 高 | P1 | runtime 红线保留 |
| 只做当前角色允许做的事 | 高 | P1 | runtime 红线 + 角色手册保留 |
| 禁止 force push、禁止跳过 hooks、禁止覆盖未归属修改 | 低 | P0 | runtime 红线短句必须保留 |
| 受保护路径删除门禁 | 低 | P0 | runtime 红线 + 触发索引指向 `conventions.md` |
| 受保护路径默认集合：业务源码、部署配置、工作流框架 | 低 | P0 | `conventions.md` 完整规范保留；速查列最小集合 |
| 删除前停止文件级删除、列清单、Architect 显式 Review、通过后执行 | 低 | P0 | runtime 触发索引（全模式）+ `conventions.md` 完整流程 |
| 删除 commit 必须明示删除清单和 Review 留痕 | 低 | P0 | runtime 触发索引（全模式）+ `conventions.md` 完整规范 |
| AI 协作 commit push 前核对 diff stat 与 commit message（全模式，含非迭代） | 中 | P0 | runtime 红线短句 + 触发索引，不依赖标准迭代速查表 |
| Review 阶段不得改产出正文，只能追加 Review 记录 | 中 | P0 | runtime 红线短句（全模式）+ `conventions.md` |
| 机制不得代写角色专业结论 / 角色日志 / 改他人待办归属字段 | 中 | P1 | runtime 红线 + 触发索引指向 `mechanisms.md` |
| 禁止直接修改他人角色日志（普通角色工作时，非机制场景） | 低 | P1 | runtime 红线 / 默认原则 + 触发索引指向 `conventions.md` |

**前置验证结论**：

- `multi-agent-workflow.md` 约 1-6 节多为项目定位、目录和按需入口说明，适合下放到完整规范或 README，不应作为标准迭代必读全文。
- 7-12 节是标准迭代执行协议本体，必须进入“标准迭代速查表”，但可压缩为流水线、状态机、Review、变更、写权限五块。
- 13-15 节是长尾治理规则，除“基线修正只能提案”属 P0 外，适合放完整规范，通过触发索引读取。
- `runtime.md` 质量底线不是都同权：P0 红线必须保留；P1 路由/阶段/Review 规则保留短句；P2 说明性规则压缩或下放。
- `conventions.md` 的删除门禁低频但 P0，高危流程不能从可达路径移除；**runtime 全模式红线**必须包含“不得直接删除 + 触发 Architect Review + commit 留痕”，完整细节继续留在 `conventions.md`。
- **跨模式红线规则（含 P0/P1，按各自风险标级）归 runtime，不归标准迭代速查表**：Git 门禁、受保护路径删除、Review 正文保护、AI 协作 commit 核对、基线修正提案、机制写权限、禁止改他人角色日志等在非迭代 / Bootstrap / 收尾 / 审计同样触发；若只进标准迭代速查表，这些模式会绕过门禁。故 runtime 承载“全模式红线与默认原则 + 触发索引”，`standard-iteration-quick.md` 只承载标准迭代协议。
- 因此 P1 建议走**拆分**，不是整体精简重写。长尾假设成立，但 P0 低频规则必须以红线短句 + 触发索引形式保留在 runtime 默认可达路径。

**P1 速查表信息架构草案**：

P1 拆分后形成两层，职责严格分开——**跨模式安全规则不依赖标准迭代速查表**：

**`runtime.md`（全模式必读，每次进工作流都读）**：
1. `工作流后路由`：默认读取清单、意图分流表、标准迭代速查入口。
2. `全模式红线与默认原则（每条标 P0/P1/P2）`：**[P0]** force push / hooks / 未归属修改、受保护路径删除、AI 协作 commit push 前核对 diff stat、Review 阶段不得改正文、Bootstrap 写入需确认、基线修正只能提案（治理边界）；**[P1]** 机制不得代写角色结论 / 日志、禁止直接改他人角色日志、不虚拟常驻 PM；**[P2]** 中文默认。
3. `跨模式触发索引`：遇删除 → `conventions.md §受保护路径删除`；遇收尾 / 关闭 / 审计 → `mechanisms.md`；遇基线修正 → `multi-agent-workflow.md §14`。

**`standard-iteration-quick.md`（仅标准迭代必读，不放跨模式安全规则）**：
1. `标准迭代流水线`：PRD → UI → 设计 → 实现 → 测试 → 部署 → 关闭 → 收尾；非 PM 启动迭代必须转 PM。
2. `状态机与真源`：阶段状态、任务 / 迭代 / Change Note 状态、`INDEX` 与 `vX.Y.md` 真源关系。
3. `动态 Review`：影响领域选择矩阵、默认至少 2 方、R1/R2/R3 轮次、缺陷严重度简表。
4. `定稿后变更`：实现取舍 / 轻量变更 / 重大变更三档及触发 `mechanisms.md` 的条件。
5. `写权限与日志`：谁能改正文、谁能追加 Review、会话结束更新角色日志和 `INDEX` 的最小规则。

`multi-agent-workflow.md` 保留为完整规范，按需读取。`runtime.md` 同时把 Bootstrap 细节、旧状态纠正、模板清单、长尾质量底线下放到对应文件。

**产物（不只「速查表」，而是速查表 + 触发索引）**：
- 速查表只写结论会漏规则或导致保守全读。每条结论旁标触发与去向，格式如：
  `触发：删除文件 / 必守红线：不得直接删 / 详读：conventions.md §受保护路径删除 Review 门禁`。

**改造（视前置验证二选一）**：
- `runtime.md` → 目标 ≤2.0k 字符，**硬上限 ≤2.5k；P0/P1 可达性优先于字数**：保留路由表 + 全模式红线与默认原则 + 跨模式触发索引。
- `standard-iteration-quick.md`（新建）→ 必读 ≤1.5k 字符，只放标准迭代协议；`multi-agent-workflow.md` 保留完整规范，按需读取。
- **压缩原则**：压缩背景叙述、例子、重复解释；**保留协议本体**（状态机表格、Review 轮次、变更三档、红线短句）——这些是执行协议不是说明。

**完成条件**：
1. 固定规则链路 <1.3 万字符（**P1 硬约束**）；真实启动链路样例 <1.5 万字符（P1 观测，P2 转硬验）。
2. 回归用例集全过（含负向 + 高危门禁）。
3. 更新所有失效引用：以 `rg 'multi-agent-workflow|conventions|mechanisms|standard-iteration-quick'` 全仓扫描，**以当前输出为准**（覆盖 `runtime.md` 迭代入口、各 `role-*.md`、`work-modes.md`、`README` 等），逐处改指准确位置，不手写固定文件清单与数量。
4. **先更新 `measure-context.sh` 链路口径**（标准迭代必读 = `standard-iteration-quick.md`，`multi-agent-workflow.md` 完整规范单列），再用新口径复测 + 双入口一致性 OK。
5. **最小读取契约**（为 P2 铺垫，非重构）：明确 `INDEX` / `project-context` 中哪些字段是 Agent 启动必须能看懂的。

### P2 强化项目理解层

**目标**：直接服务「上下文够理解项目」。把承担项目理解重任却最弱的 `project-context.md`（29 行）和 `INDEX.md` 重设计为高信息密度「项目全貌快照」，承接 P1 末尾的读取契约。

**已做（2026-06-20）**：`project-context.template.md` 344→886，新增「8 问题启动契约」+ 架构模块地图 / 外部依赖 / 受保护路径（接 P1 删除门禁）/ 领域术语字段；脚本加真实启动链路 fixture，**12350 < 15000 硬验通过**。`INDEX` 当前状态块已满足契约 ⑦⑧（卡在哪 / 下一步），评估后保持不变。

**验证**：契约自洽（模板字段按 8 问题设计）。客观验证需一个填好的样例——用 fork 子代理只读 `project-context + INDEX` 复述项目定位 / 卡点 / 下一步，留待用户授权 spawn 或下游项目落地时执行。

### P3 角色手册渐进式拆分

**目标**：降低角色层加载。

**实证结论（2026-06-20）**：逐一审 7 个角色手册后，**只有 role-developer 含适合拆的低频大块**（子 Agent 调度流程/验证/并行限制，仅实际跨前后端调度时用）。architect / pm / tester / ui / devops 的「核心方法」都是该角色高频内容，拆出去反而每次多读一次（multi-agent 拆分教训的反面），故**不拆**。这也呼应 P3 边际收益本就小的判断。

**已做**：role-developer 3508→2788；子 Agent 调度细节挪到 `role-developer-detail.md`(772，按需)，保留高频「何时用」判断 + 指针。标准迭代启动链路 9865→9318。

**验证**：链路下降 ✓；role-developer 核心仍含身份/产出/审/TDD/自检/安全/启动检查，履职完整；detail 经手册内指针按需可达。

### P4 安装与复用体验

**目标**：降低复制到 Claude/Codex 项目的落地摩擦——复制后删 SOURCE-REPO-ONLY 引导、`project-context` 填写引导、双入口一致性正式校验做成安装流程一环。

**前置盘点（现状 / 缺口，2026-06-20）**：

| 子项 | 现状已有 | 真正缺口 |
|------|----------|----------|
| 删 SOURCE-REPO-ONLY | 入口文件该块已有 HTML 注释锚点（`<!-- ↓↓↓ SOURCE-REPO-ONLY … ↓↓↓ -->` / 结束锚点），可机械整块识别；README「推荐安装方式」步骤 1 已有手动删除文字引导 | 纯手动必漏。漏删后下游首个会话会读到「本仓库正在自我演进 → 先读 `docs/ROADMAP.md` 游标」，而下游无 ROADMAP（或误读真源 ROADMAP），直接走错启动路由 |
| 双入口一致性 | `measure-context.sh` 已有 `diff -q CLAUDE.md AGENTS.md` 检查 | ① 脚本注释写「块外正文应一致」，实现却是**完整文件** diff——注释与实现矛盾；② 仅 echo WARN、`exit 0`，不构成关卡 |
| project-context 填写 | 模板已是 8 问题契约（P2）；README 步骤 3 + `role-pm.md` 步骤 6 已有创建引导 | 缺口最小。唯一割裂：README 步骤 4 让空项目「等 Bootstrap」，但 project-context 属项目事实层、不归 Bootstrap（其只装 `progress/` 工作台），二者职责边界未说清 |

**设计决策**：

1. **删 SOURCE-REPO-ONLY → 安装脚本机械剥离（推荐）**
   新建 `scripts/install-downstream.sh <目标目录>`，在真源仓库运行，产出一份干净的下游副本：
   - 复制入口文件时按注释锚点 `sed`/`awk` 剥离整块 SOURCE-REPO-ONLY；
   - **不复制**真源专属文件（完整复制范围见决策 4）：`docs/ROADMAP.md`、`docs/regression-cases.md`、`scripts/measure-context.sh`、`scripts/install-downstream.sh` 自身；
   - 产出后自检：目标入口已无 SOURCE-REPO-ONLY 锚点，否则 `exit` 非零拒绝产出。
   - 备选 A1 纯文档引导（现状）：否决——机械删除靠人记必漏，违背「重复确认性工作交给自动化」。
   - 备选 A2 运行时自检（入口加常驻检测残留块）：否决——给每次启动加常驻字数，与 P1 瘦身冲突。

2. **双入口一致性 → 完整 diff + 修正注释 + 安装期作硬关卡（推荐）**
   - 维持**完整文件** `diff`（两入口本应逐字一致，Claude/Codex 读同一份产品内容）；
   - 修正 `measure-context.sh` 注释，删去「块外正文」措辞，与「完整 diff」实现对齐；
   - 关卡职责交给安装脚本：产出前校验双入口一致，不一致则 `exit` 非零；`measure-context.sh` 维持 WARN（度量用途，不阻断）。
   - 备选 B2 剥离块后再 diff：否决——更宽松且无必要，两入口本就该逐字一致。

3. **project-context 填写引导（最小增强，推荐）**
   - 安装脚本在目标处将 `project-context.template.md` 复制为 `project-context.md`（占位待填），使 8 问题契约从首个会话即完整可读（即便占位）；
   - README「推荐安装方式」首选「跑脚本」，保留手动步骤作 fallback。
   - ✅ **已定（用户拍板 2026-06-20）**：采纳自动铺占位。随之需改 README 步骤 4「空项目等 Bootstrap 再处理上下文」语义，澄清 project-context（项目事实层）≠ Bootstrap（progress 工作台），二者可在不同时机各自就位。实现时一并更新 README，确保不与 Bootstrap 流程冲突。

4. **复制范围与目标目录安全（第二轮复审补强）**
   核实 Bootstrap 实际只建 `docs/progress/`（bootstrap.md 步骤 2-3），**不建 `docs/knowledge/`**，据此分类处置：
   - **排除（真源专属，下游不带）**：`docs/ROADMAP.md`、`docs/regression-cases.md`、`scripts/measure-context.sh`、`scripts/install-downstream.sh` 自身，以及整个 `docs/progress/`——其中 `INDEX.md` 是真源状态实例（含「Bootstrap 状态：已完成」），复制会让下游误判已初始化；下游 progress 工作台 + INDEX 由 Bootstrap 从 `templates/progress-index.md` 生成。
   - **保留骨架 + 自检（`docs/knowledge/`）**：复制空目录骨架（`.gitkeep`）与空 `knowledge/INDEX.md`。**对 Codex「直接排除 docs/knowledge/」建议的修正**：Bootstrap 不建 knowledge 目录、无任何机制为下游补建，排除会留工作台洞；改为随安装复制空骨架，并由脚本自检 `knowledge/INDEX.md` 各分类下无条目、除 INDEX 外无 `.md`，若发现真源已沉淀知识则 `exit` 非零要求人工处理（防真源知识泄漏）。
   - **目标目录安全（采纳 finding 3）**：默认只接受目标目录不存在或为空；非空则 `exit` 非零拒绝并提示（本版不实现 `--merge`/`--force`），避免覆盖用户已有文件。

**产物**：
- `scripts/install-downstream.sh`（真源专属，不进下游）；
- README「推荐安装方式」改为首选脚本、保留手动 fallback；
- `measure-context.sh` 注释修正（与完整 diff 实现对齐）；
- 回归用例补安装类：如「下游入口不应残留 SOURCE-REPO-ONLY 块」「下游副本不应含 ROADMAP / measure / regression 等真源专属文件」「下游会话不因残留块去读 ROADMAP 游标」。

**已做（2026-06-21，实现 + 实跑验证）**：六个完成条件全部实跑通过——
- 空目录实跑产出 0 退出，自检全过：入口无 SOURCE 锚点、双入口逐字一致、`project-context.md` 占位存在；
- 产出副本不含真源专属（`ROADMAP`/`regression-cases`/`scripts/`/`progress/`），`docs/knowledge/` 仅空骨架（INDEX + 各分类 `.gitkeep`）；
- 非空目标目录拒绝产出（退出 1）且不改动既有文件；knowledge 含真源条目时退出 1 且不建半成品目录；无参数退出 2；
- 端到端：产出 `CLAUDE.md` 顶部直接为入口正文、无「自我演进→读 ROADMAP 游标」段、无 `ROADMAP` 引用，无 `docs/progress/` ⇒ 首个会话按 runtime 建议 Bootstrap，不读真源游标。
- knowledge 自检在 `cp` 前（步骤 3），失败不残留半成品目标目录。

**完成条件**：
1. `install-downstream.sh` 在临时目录实跑一次，产出的副本：入口无 SOURCE-REPO-ONLY 锚点、双入口一致、`project-context.md` 占位存在（脚本自检全通过）；
2. 产出副本**不含**真源专属实例：`docs/ROADMAP.md`、`docs/regression-cases.md`、`scripts/`、`docs/progress/`；`docs/knowledge/` 仅含空骨架（自检无真源条目）；
3. 在**非空**目标目录运行安装脚本必须失败、不覆盖现有文件；
4. **端到端验证**（采纳复审点 4）：产出副本能被一次干净的工作流启动加载——入口无 SOURCE 块、不去读 ROADMAP 游标、`project-context.md` 存在、`docs/progress/INDEX.md` 不存在时工作流应**建议 Bootstrap** 而非读真源游标；
5. 新增安装类回归用例全过；
6. README 与脚本口径一致，`measure-context.sh` 注释与实现一致。

### P5 跨项目协调联动（已完成，PR #2 `ddf5683`）

**目标**：把「跨项目协调」从 `xiaobao` 的本地分叉，回收并提炼成 agent-workflow 真源的正式一环。让每个项目复制工作流时就自带「如何与 coordination 协调仓联动」的能力，使跨项目需求能在 coordination 的需求池（`REQUESTS.md`）与各业务项目内部迭代（`PRD → … → 测试`）之间顺畅流转。

**背景诊断（2026-06-21）**：用户的 `niuma-cheng` 生态已是三层结构——agent-workflow（真源）→ N 个业务项目（`xiaobao`/`ai`/`workboard`/…）→ `niuma-cheng-coordination`（跨项目协调真源：需求池 / 契约 / 状态 / 沟通 / 决策）。

- **衔接件已在下游实战、真源缺失**：`xiaobao/docs/baseline/cross-project-collaboration.md` 已写得相当完整（三层模型、需求流转生命周期、契约真源、开工前同步、会话边界、新项目复用），coordination 仓库 4 处把它当规则真源引用；但 agent-workflow 真源 `docs/baseline/` 没有此文件 → coordination 引用的是「住在下游、真源却没有」的规则，新项目复制真源工作流不会自带跨项目能力，联动断点在此。
- **下游已分叉、版本落后**：`xiaobao` baseline 是旧版（仍用已废弃的 `architecture.md` ADR 路径），且其 `cross-project-collaboration.md` 内部有命名矛盾（communications 一处按需求 `REQ-001-news-l1.md`、另一处按项目对 `{a}__{b}.md`；coordination 实际用项目对 `xiaobao__ai.md`）→ 本轮按**项目对 v1** 统一消除矛盾（见已定架构边界 1）。
- **`xiaobao` 还多发明了 `role-wm.md`（工作流管理者）角色**，真源无；其职责与真源「下游不改 baseline、只写基线修正提案」及已有流程审计机制大面积重叠。**本轮搁置**（待 `xiaobao` 对齐最新真源后单独审查）。

**范围界定（用户拍板 2026-06-21）**：本轮**只补真源联动能力**；**不含**下游迁移执行（`xiaobao` 对齐、`ai`/`workboard` 接入），**不碰** WM 角色。**实现范围 = P5-1 / P5-2 / P5-3 / P5-5；P5-4（coordination 骨架模板）本轮默认不做**，除非用户单独拍板（理由：P5 目标是让业务项目知道如何联动**已有** coordination 仓，不是产出新的 coordination 产品模板；模板化应等 P5 真源规则稳定后再做）。

**已定架构边界（2026-06-21 方案复审补强，实现时不得突破）**：

1. **communications 命名 = 项目对（v1）**：采用 coordination 现状 `communications/{project-a}__{project-b}.md`（一对项目一份，承载这对项目之间所有需求的沟通过程）。回收 `cross-project-collaboration.md` 时，必须把 `xiaobao` 文件里「一个需求一份 `{REQ-id}-{短名}.md`」的相关表述**一并改写为「一对项目一份」**，消除其内部矛盾。「按需求命名」是 breaking 变更，**本轮不推**，列为 P7/v2 候选（避免在「不做下游迁移」的前提下把 coordination 现状变成 breaking 规则）。
2. **coordination 仓发现机制（实操 blocker，必须补）**：协调仓位置记录在业务项目 `project-context.md` 的「外部依赖与集成」字段（如 `coordination_root`）。Agent 发现顺序固定为 **用户明确指定 > `project-context.md` 记录 > 找不到则询问用户**；**禁止靠 sibling path（如 `../niuma-cheng-coordination`）猜测**（换机器即错）。
3. **跨仓写入纪律（P0/P1 红线）**：跨项目任务可读写 coordination 仓，但写入前必须确认 ① coordination 仓位置、② 其 git 同步状态（`git status` / 必要时 `pull`、冲突判断）、③ 本次改动范围；**只写 coordination 的跨项目事实**（`REQUESTS`/`STATUS`/`contracts`/`communications`）；**不得在 A 项目会话里改 B 项目的 `docs/progress/`**。该红线进 `runtime.md`（全模式）+ `cross-project-collaboration.md`。
4. **角色权限三层**（保留 `xiaobao` 既有模型，非泛化指针）：**提报**——任一项目任一角色可写需求到 `REQUESTS.md`，不指定承接方；**承接 / 拒绝**——仅目标项目 PM（产品经理）或 Architect（架构师），Owner 可直接指派，其他角色不得代为承接；**联调 / 证据更新**——相关角色（通常 Developer）。
5. **按需读取不破坏 P1**：新文件进 `docs/baseline/`（P4 安装脚本 `cp -R docs/baseline` 自动带上），但**只在「跨项目需求 / 契约 / 状态 / coordination 仓」触发时读取**，不进默认只读链路、不进标准迭代 quick、不计入固定规则链路。

**已做（2026-06-21，实现 P5-1/2/3/5，已通过 PR #2 合并 `ddf5683`）**：
- P5-1：新建 `docs/baseline/cross-project-collaboration.md`（项目对命名 v1、coordination 发现机制、跨仓写入纪律、角色权限三层、新项目复用对齐 P4）；`project-context.template.md` 外部依赖加 `coordination_root`。
- P5-2：`runtime.md` 加「跨项目协作」分流行 + 全模式红线「跨仓写入」[P0] + 触发索引；`runtime` 2606→2937，固定规则链路 6530→**6861（<13000）**。
  - **选择记录**：`runtime` 2937 > P1 放宽后的 2700 软上限——单是分流行 + 触发索引已推过 2700，P0 跨仓红线的「不猜路径 / 同步状态 / 改动范围 / 不改 B progress」是全模式不可绕过约束，压缩损害可达性。**接受 2937，可达性优先**（P1 既定调）；固定规则链路 6861 仍远低于 13000 硬指标。
- P5-3：6 个角色手册按三层权限挂钩跨项目（PM/Architect 承接层、Developer 联调层、Tester/UI/DevOps 提报层），轻量指针指向衔接文件。
- P5-5：`regression-cases` 加跨项目用例 X1-X5（1 正 + 4 负）；`install-downstream` 实跑产出副本含衔接文件、自检全过；measure 双入口一致、标准迭代链路 9318→9821（<15000）；衔接文件引用与角色指针全部可达。
- P5-4 未做（按方案搁置）。

**步骤与产物**：

| 步骤 | 做什么 | 产物 |
|------|--------|------|
| P5-1 回收衔接规则 | 把 `xiaobao` 的 `cross-project-collaboration.md` 提炼进真源 `docs/baseline/`：① communications **按项目对 v1**（边界 1），同步改写文件里「一个需求一份」表述消除内部矛盾；② 写入 coordination 仓**发现机制**（边界 2）与**跨仓写入纪律**（边界 3）；③ 保留**角色权限三层**模型（边界 4）；④ 对齐 P4 —「新项目复用」章节指向 `scripts/install-downstream.sh`、project-context 改为「安装脚本铺占位 / PM 填写」；⑤ 删除与已变更真源不符的引用（如已废弃的 `architecture.md` ADR 路径） | `docs/baseline/cross-project-collaboration.md`（真源新成员）；`project-context.template.md` 外部依赖字段加 `coordination_root` 示例 |
| P5-2 runtime 路由接入 | 工作模式分流表加「跨项目需求 / 契约 / 状态」一行 → 读 `cross-project-collaboration.md`；跨模式触发索引加跨项目入口；**全模式红线加跨仓写入纪律**（边界 3）；明确加载时机（仅跨项目任务读，单项目任务不读 → 边界 5） | `runtime.md` 改 |
| P5-3 角色职责挂钩 | 按**三层权限**（边界 4）挂钩：PM/Architect 加「承接 / 拒绝跨项目需求、转本项目迭代」；各角色加「可提报需求到 `REQUESTS.md`」；联调角色加「证据更新」。**轻量加指针**指向 `cross-project-collaboration.md`，不重写角色手册 | 相关 `role-*.md` 改 |
| ~~P5-4 coordination 骨架模板~~ | **本轮默认不做**（见范围界定）。如单独拍板再做：把 coordination 的 `REQUESTS / STATUS / PROJECTS / contract / communication` 结构做成 `docs/templates/` | —（搁置） |
| P5-5 收尾 | `install-downstream.sh` 确认带上新文件（`cp -R docs/baseline` 已覆盖，需确认非 SOURCE-REPO-ONLY、不被 knowledge 自检误拒）；`measure-context.sh` 复测（新文件按需读取，不进固定链路）；回归用例补跨项目（含负向，见完成条件 6）；ROADMAP 游标更新 | 脚本 / 回归 / ROADMAP |

**完成条件**：
1. 真源 `docs/baseline/cross-project-collaboration.md` 存在、内部命名自洽（communications 全文统一为项目对 v1，无「一个需求一份」残留）、引用全部可达、与 P4 安装流程口径一致；含发现机制、跨仓写入纪律、三层权限；
2. `runtime.md` 能把「跨项目」意图路由到该文件，且单项目任务不误加载；全模式红线含跨仓写入纪律；
3. PM/Architect/各角色手册的跨项目职责指针按三层权限挂钩、可达该文件，无断链；`project-context.template.md` 含 `coordination_root` 字段；
4. `install-downstream.sh` 实跑产出的下游副本含 `cross-project-collaboration.md`，自检仍全通过；
5. `measure-context.sh` 复测：固定规则链路不回归（新文件按需读取，不计入固定层）；双入口一致；
6. 新增跨项目回归用例全过，**含负向**：① 单项目任务**不加载** `cross-project-collaboration.md`；② 找不到 coordination root 时**不得写入**、须询问；③ A 项目会话**不得改** B 项目 `docs/progress/`；④ 非 PM/Architect **不得承接**需求（只能提报）。

**搁置项（后续阶段，本轮不做）**：
- **P6（已决 · 2026-06-22）· WM 角色裁撤**：`xiaobao` 对齐真源时，因真源入口 / `runtime` / 角色矩阵均无 WM，sync 后 `role-wm.md` 已成无入口死文件，故按「裁撤」处理并在小报侧删除该 orphan。日后若要把 WM 泛化收编，仍走基线修正提案（归集人 = 真源维护方）。
- ~~**v2 候选 · communications 按需求命名**~~：**已采纳落地（BCR-002，2026-06-22）**。P5 因「无回流机制 + 不动下游」搁置；P7/P8 建成 sync 回流后，趁生态仅 1 份沟通文档（`xiaobao__ai.md` / REQ-001）迁移成本最低之机切换为「一个需求一份 `{REQ-id}-{短名}.md`」，命名轴对齐机制核心单元 REQ。真源 `cross-project-collaboration.md` §communications 已改（反孤儿移交 REQUESTS 一一对应 + `communications/README.md` 索引）；coordination 实体迁移与下游 sync 回流随 BCR-002 流转。

### P7 下游同步能力与接入（已完成）

**目标**：让下游项目能**复用并持续同步**真源工作流，告别手动复制；据此把 `ai`/`xiaobao` 接入。用户拍板用**幂等同步脚本**机制（非 git subtree/submodule）。

**第 1 步 · 建能力（已完成，PR #3 `6bfba79`）**：
- 新增 `scripts/sync-downstream.sh`：幂等（首装 + 更新通吃，不要求空目录）；**覆盖框架**（入口剥离 SOURCE / `docs/baseline` 除 `project-context.md` / `docs/templates`），**保留项目专属**（`docs/progress/` / `project-context.md` / `docs/knowledge/` 已有条目）；**下游独有框架文件只报告不删**（接 P6 的 WM 触发点）；写 `.workflow-version` 版本标记；`--dry-run` 预览。
- 与 `install-downstream.sh` 分工：install 管「严格空目录一次性首装」，sync 管「已有项目安装 + 持续更新」，install 保留不动。
- **首轮复审加固**：① 目标安全 —— realpath 拒绝「目标=真源自身/子目录」（否则 `> $DEST/CLAUDE.md` 会先截断再读、毁真源入口）；② 覆盖式同步保护 —— 目标是 git 仓且工作区 dirty 则拒绝（提示先提交/暂存或 dry-run），dry-run 不受限；③ dry-run 由「只报数量」升级为「逐个列出覆盖清单」，便于审分叉项目。
- 回归用例 `regression-cases` 加 S1-S7；临时目录全测试通过（首装 / 更新保留专属 / orphan 报告 / dry-run 清单 / 用法错误 / 目标=真源拒绝 / dirty 拒绝 / clean 回归）。

**第 2 步 · `ai` 接入（已完成 2026-06-21）**：`sync-downstream.sh` 首装（`.workflow-version` = `agent-workflow@90edee2`）→ Bootstrap（建 `docs/progress/`）→ 填 `coordination_root` → coordination `PROJECTS.md`/`STATUS.md` 登记「已接入」；`ai` 已配 git remote 并推送 `main`（commit `6675531`）。

**第 3 步 · `xiaobao` 对齐（已完成 2026-06-22）**：清 dirty → `--dry-run` 看分叉 → 按 P6 裁撤 WM（删 `role-wm.md`）→ 正式 sync（23 改 / 5 增）→ 校验 progress/project-context/knowledge 无损；项目 ADR `architecture.md` 作下游独有保留（commit `1dae522`，已 push origin/main）。

**完成条件**：
1. `sync-downstream.sh` 幂等：首装与重复更新均自检通过；项目专属在更新中零损失；
2. 下游独有框架文件被报告而非删除；`--dry-run` 不写任何文件；真源 knowledge 含条目时拒绝同步；
3. S1-S7 回归用例全过；
4. `ai` 经 sync 接入后能干净启动工作流、跨项目联动可用（填 `coordination_root` 后）；
5. `xiaobao` 对齐后 progress/project-context 无损，分叉项（WM）按 P6 结论处理。

### P8 · 基线修正提案走 coordination 管理（方案定稿 · Owner 通过 · 已并入 main PR #4 `fe99ac3`）

**动机**：现状基线修正提案靠 **Owner 人肉「带回真源」**（口头/记忆摆渡，易丢、无状态、无追踪）。改为走 coordination 登记，把摆渡介质从「人脑记忆」升级为「双方可查的共享真源仓」——有登记、有状态、可追溯，复用 P5 需求池范式，不发明新机制。`agent-workflow` 在结构上是「被提需求方」，但**非业务项目**，须特殊处理（见下）。

**① 评估/采纳权（finding 5）**：基线修正由 **Owner + agent-workflow 真源维护会话（General）** 评估、采纳、落地。下游任一角色**只能提报**，不能在下游改 `docs/baseline/`，不能替真源判定「已采纳」。不套用 P5「目标项目 PM/Architect 承接」（agent-workflow 无 PM/Architect 承接语义）。

**② 登记位置与 id（finding 3）**：在 `coordination/REQUESTS.md` 开独立区块 `## 基线修正提案池`，独立前缀 **`BCR-###`**（Baseline Change Request），不与普通 `REQ-###` 混用。**不放 `decisions/`**——`decisions/` 只承载已采纳的终态决策，不适合「待评估/拒绝/部分采纳」的流转态。
**BCR 表最小列**（实现照此，避免写成散文，`BCR-001` 自举样例直接套模板）：`BCR id | 提出方 | 摘要 | 影响范围 | 状态 | 真源评估记录 | 真源落地 commit | 回流清单 | 备注`。

**③ 专属状态机 + 回流清单（finding 4：「已回流」是闭环条件，非可选）**：
`已提报 → 评估中 → 已采纳 / 部分采纳 / 已拒绝 / 转 v2 候选 → 已落地真源 → 回流中 → 已回流下游`
每条 BCR 带**下游回流清单**（真源改完后各下游未 sync 前仍在旧规则，须逐项追踪）：
`ai: <synced commit> / xiaobao: <synced commit> / workboard: 未接入（不适用）`。全部下游回流完才置「已回流下游」终态。
**回流清单的下游集合来源（finding 4）**：以 `coordination/PROJECTS.md` 中「已接入 agent-workflow」的项目为准——新项目接入后须纳入；未接入工作流的项目不计入、不构成阻塞（标「不适用」）。

**④ agent-workflow 登记进 PROJECTS.md**：`coordination/PROJECTS.md` 加 `agent-workflow` 条目，定位写死「**工作流真源，只承接基线修正提案（BCR），不承接业务功能 / 接口契约**」。未登记前不得受理提报。

**⑤ 分工（沿用 P5「需求池记状态、过程在各仓」）**：
- **coordination**：BCR 条目 + 状态流转 + 摘要 + 回流清单 + 链接。
- **真源 `docs/progress/ad-hoc/`**：评估细节 + 落地 diff + 回归用例（即 `2a8c936` 那种 proposal 文件）。

**⑥ 实施范围（finding 6：旧「带回真源」口径分散多处，须一并改，否则新旧并存）**：
- `cross-project-collaboration.md`：新增「§基线修正提案流转」（BCR 全流程主规则）。
- `runtime.md`（分流表/触发索引）、`work-modes.md`（审计行）、`mechanisms.md`（审计/收尾）、`multi-agent-workflow.md`（§14 基线修正 / §15 增删角色及相关引用）、`README.md`（真源性质说明）：把「写 `[基线修正提案]` 带回真源」统一改/补为「按 `cross-project-collaboration.md` 写入 coordination BCR 池」。
- `regression-cases.md`：补 BCR 回归用例（见⑨）。
- 行号随编辑漂移，实现时以 `grep "带回真源"` 为准定位。

**⑦ 自举（第一次例外，按序执行，避免「先改真源但 BCR 池不存在」的空窗，finding 5）**：
1. coordination 会话 push 当前 `ahead 2`；
2. `coordination/PROJECTS.md` 登记 `agent-workflow`（④ 的定位）；
3. `coordination/REQUESTS.md` 建 `BCR-001`（状态：评估中 → 已采纳）；
4. 真源 General 实现 P8 baseline 修改（⑥ 范围）；
5. `BCR-001` 置「已落地真源」，记真源 commit；
6. sync 回流各下游后置「已回流下游」。
自举例外**仅限本次**，不泛化为「下游可直接改 baseline」。

**⑧ 实施前置**：
1. 先在 **coordination 会话** push 当前 `ahead 2`（`048c757`/`65734c8`，ai 接入登记）——P8 要让 coordination 当共享真源，它自己得先收口。
2. ROADMAP 两处 stale 已修（`2a8c936` / `1dae522` 均已 push，本次 review 修正）。

**⑨ 回归用例（实现后补，纳入 `regression-cases.md`）**：
- 下游发现规则问题 → 写 coordination `BCR-###`，**不改本项目 `baseline/`**。
- `agent-workflow` 未登记进 `PROJECTS.md` 时**不得受理提报**。
- 已落地真源但下游未 sync 时**不得标「已回流下游」**。
- 被拒绝 / 转 v2 候选的提案**不得改 baseline**。
- 真源自举例外**仅本次 P8**，不得泛化成下游可直接改 baseline。

**实现后自检**：`./scripts/measure-context.sh`（字数不回退硬限）、`git diff --check`、`scripts/sync-downstream.sh /tmp/agent-workflow-p8-check`（同步自检通过）、`rg '带回真源|基线修正提案'`（复核旧口径无漏网残留——每处确认是有意保留还是已替换为 BCR 流转，finding 6）。

**度量记录（实现后）**：`runtime.md` 因 BCR 分流行/红线/触发索引由 2937→**3068 字符**，超过 P5 接受的 2937；但固定规则链路 **6992 < 13000**、标准迭代链路 **9952 < 15000**、真实启动 **12473 < 15000**，双入口一致。**接受 3068**，理由同 P1/P5 既定调——**BCR P0 可达性优先于 `runtime.md` 单文件体量**。

**已知局限（诚实记录，非缺陷）**：coordination 是独立仓，仍需「下游会话写 coordination、真源会话读 coordination」，摆渡动作不消失——但介质从「人脑记忆」变为「共享仓库登记」，这正是其价值。

## 执行原则

- 每阶段：**先量基线（脚本）→ 改动 → 复测字数 + 跑回归用例**，结果回写「当前基线」与游标。
- 分类按**风险加权**，不按纯数量；P0 规则即使低频也保留可达路径。
- 拆分前验证「高频/长尾」假设，不成立改精简重写；压缩叙述不压缩协议本体。
- 本仓库直接改 baseline（General 身份），每次改完必须复测字数 + 行为不回归。
- 一次只推进一个阶段，定稿后再进下一个。
