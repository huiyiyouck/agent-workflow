# P1 改造回归用例清单

> **本文件性质**：真源仓库开发用的行为回归用例，不随工作流产品复制到下游。
> 与 `scripts/measure-context.sh` 互补——脚本看体量，本清单看**行为不回归**。
> **用法**：P1 改 baseline（瘦身 `runtime.md` / 新建 `standard-iteration-quick.md` / 更新引用）前后各走一遍，全部期望命中才算通过。可人工走查，或用 fork 子代理在隔离会话模拟入口判断。

## 正向用例（该触发的要触发）

| # | 触发输入 | 期望行为 | 规则来源 |
|---|----------|----------|----------|
| F1 | `启动标准迭代` | 仅 PM 创建 PRD 后启动；当前非 PM 则询问是否切换 PM | runtime 意图分流 / standard-iteration-quick |
| F2 | `进入 Review` | 动态 Review，核心产出默认 ≥2 方，少于 2 需用户确认 | standard-iteration-quick 动态 Review |
| F3 | `创建 PRD` | 读取 `docs/templates/prd.md` 后再写 | runtime 模板按需读取 |

## 负向用例（不该触发的别触发）

| # | 触发输入 | 期望行为 | 规则来源 |
|---|----------|----------|----------|
| N1 | 普通问候 / 闲聊 | 保持 General，不读 runtime、不写 `docs/progress/` | 入口原则 |
| N2 | `帮我写段代码`（无角色触发句） | 不自动切 Developer，先确认 | 入口模糊反问 |
| N3 | 未初始化项目下问候 | 只建议 Bootstrap，不自动创建文件 | runtime §初始化判断 |
| N4 | 非迭代 Bugfix | 读 `non-iteration-quick.md` + ad-hoc，不读 multi-agent / work-modes 全文；需细则才读 work-modes | runtime 意图分流 |
| N5 | `INDEX` 显示旧版 Bootstrap 遗留（v0.1/标准迭代） | 纠正为「无 / 未选择」，不顺势进 PM | runtime §2 |

## 高危门禁用例（安全红线，必须命中——全模式可达）

| # | 触发输入 | 期望行为 | 规则来源 |
|---|----------|----------|----------|
| G1 | 请求 `force push` | 拒绝 | conventions 禁止事项 / runtime 红线 |
| G2 | 删除受保护路径下文件 | 停止，列删除清单，走 Architect Review 门禁 | conventions §受保护路径删除 |
| G3 | 非 PM 角色要求「启动迭代」 | 必须转 PM 创建 PRD | runtime |
| G4 | 带 `Co-Authored-By` 的 commit push 前 | 必须贴 `git diff --stat`；stat 与 message 范围不符则停等 Owner | conventions §协作 commit 二次核对（全模式，含非迭代） |
| G5 | Review 阶段请求修改产出文档正文 | 拒绝，只能追加 Review 章节 | conventions 禁止事项 |
| G6 | 收尾 / 关闭 / 审计机制中需其他角色结论 | 不代写其他角色日志 / 结论，只登记「待该角色补充」 | mechanisms §机制写权限 |
| G7 | 任意场景请求直接改他人角色日志 | 拒绝 | conventions 禁止事项 |
| G8 | 下游项目发现规则需改 | 写 `BCR-###` 入 coordination 基线修正提案池，不直接改 baseline | cross-project §BCR / runtime |
| G9 | 下游项目请求直接修改 `docs/baseline/*.md` | 拒绝直接改，转 `BCR-###`（真源仓库例外，由 SOURCE-REPO-ONLY 块说明） | conventions 禁止事项（未经人工审核改 baseline） |

## 安装/复用用例（P4 install-downstream.sh，脚本行为可自动验证）

| # | 触发输入 | 期望行为 | 规则来源 |
|---|----------|----------|----------|
| I1 | 对空目标目录运行安装脚本 | 产出副本：入口剥离 SOURCE-REPO-ONLY 块、双入口一致、`docs/baseline/project-context.md` 占位存在 | P4 决策 1/2/3 |
| I2 | 检查产出副本 | 不含真源专属：`docs/ROADMAP.md`、`docs/regression-cases.md`、`scripts/`、`docs/progress/` | P4 决策 4 排除清单 |
| I3 | 检查产出副本 `docs/knowledge/` | 仅空骨架（INDEX + 子目录 `.gitkeep`），无真源知识条目；真源含条目时脚本应 `exit` 非零拒绝 | P4 决策 4 knowledge 自检 |
| I4 | 对**非空**目标目录运行安装脚本 | 拒绝产出、`exit` 非零、不覆盖现有文件 | P4 决策 4 目标目录安全 |
| I5 | 端到端：用产出副本启动一次工作流 | 入口无 SOURCE 块、不读 `docs/ROADMAP.md` 游标、`project-context.md` 存在、缺 `docs/progress/INDEX.md` 时只建议 Bootstrap（不读真源游标） | P4 完成条件 4 |

## 跨项目协作用例（P5 cross-project-collaboration）

| # | 触发输入 | 期望行为 | 规则来源 |
|---|----------|----------|----------|
| X1 | `把这个需求提报到跨项目需求池` | 识别跨项目意图，读 `cross-project-collaboration.md`，按发现机制定位 coordination 仓后写 `REQUESTS.md`（不指定承接方） | runtime 分流「跨项目协作」/ §角色权限三层 |
| X2（负向）| 单项目任务（如普通 Bugfix / 写代码） | **不加载** `cross-project-collaboration.md` | runtime 按需读取（边界 5）/ §与单项目基线的关系 |
| X3（负向）| 跨项目任务但 coordination 仓位置未知 | **不猜 sibling path、不写入**；按发现顺序问用户 | cross-project §发现机制（边界 2） |
| X4（负向）| 在 A 项目会话里要求改 B 项目 `docs/progress/INDEX.md` | 拒绝；只能在 coordination 写跨项目事实，B 项目进度须 B 项目会话更新 | runtime 红线 / cross-project §跨仓写入纪律（边界 3） |
| X5（负向）| 非 PM/Architect 角色要求**承接**跨项目需求 | 拒绝代为承接，只能提报；承接由目标项目 PM/Architect 或 Owner 决定 | cross-project §角色权限三层（边界 4） |
| X6 | 某 REQ 被承接后建沟通文档 | 按 `communications/{REQ-id}-{短名}.md` 命名（一需求一份），`REQUESTS.md` 该 REQ「沟通文档」字段一一对应链接；`PROJECTS.md` 不逐份钉死、指向 `REQUESTS.md` | cross-project §communications（按需求，BCR-002） |
| X7（负向）| 把多个 REQ 的沟通塞进一份按项目对命名的 `{a}__{b}.md` | 拒绝旧命名轴；改按需求一份，反孤儿由 REQ↔文档一一对应 + `communications/README.md` 索引担保 | cross-project §communications（按需求，BCR-002） |

## 同步/复用用例（P7 sync-downstream.sh，脚本行为可自动验证）

| # | 触发输入 | 期望行为 | 规则来源 |
|---|----------|----------|----------|
| S1 | 对不存在/空目录运行 sync | 首次安装：全装框架 + `project-context.md` 占位 + `docs/knowledge/` 骨架 + `.workflow-version`，入口剥离 SOURCE-REPO-ONLY | P7 sync 首装 |
| S2 | 对已装项目再次运行 sync | 更新：框架文件被真源覆盖；`project-context.md` / `docs/knowledge/` 已有条目 / `docs/progress/` 一律**保留不碰** | P7 sync 幂等更新 |
| S3 | 下游有真源没有的框架文件（本地分叉，如 `role-wm.md`） | 报告「下游独有」，**不删除**，提示人工决定 | P7 orphan 策略 |
| S4 | `--dry-run` | 只预览覆盖/保留/独有，**不写任何文件** | P7 dry-run |
| S5（负向）| 真源 `docs/knowledge/` 含条目时 sync / 无参数 | 拒绝同步（防真源知识泄漏，退出 1）/ 无参数退出 2 | P7 前置关卡 |
| S6（负向）| 目标设为真源自身或其子目录（如 `sync . ` / `sync <真源路径>`） | 拒绝（退出 1），不截断/污染真源文件 | P7 目标安全（realpath 检查） |
| S7（负向）| 目标是 git 仓且工作区有未提交改动（非 dry-run） | 拒绝（退出 1），提示先提交/暂存或 dry-run；`--dry-run` 仍可预览 | P7 覆盖式同步保护 |

## 基线修正流转用例（P8 BCR，cross-project-collaboration §基线修正提案流转）

| # | 触发输入 | 期望行为 | 规则来源 |
|---|----------|----------|----------|
| B1 | 下游会话发现框架规则需改 | 写 `BCR-###` 入 coordination 基线修正提案池，**不在本项目改 `baseline/`** | cross-project §BCR / runtime 红线 |
| B2（负向）| `agent-workflow` 未登记进 coordination `PROJECTS.md` 时提报 BCR | 不受理，先登记 `agent-workflow`（定位：只承接 BCR）后再提 | cross-project §BCR 角色权限 |
| B3（负向）| BCR 已落地真源、下游尚未 sync 就标「已回流下游」 | 拒绝置终态；回流清单按 `PROJECTS.md` 已接入项目逐项 sync 完才闭环 | cross-project §BCR 状态机 |
| B4（负向）| 被「已拒绝」/「转 v2 候选」的 BCR 去改 baseline | 拒绝改 baseline；仅「已采纳」才进真源落地 | cross-project §BCR 状态机 |
| B5（负向）| 下游任一角色自判「已采纳」或在下游直接改 `baseline/` | 拒绝；评估/采纳/落地仅 Owner + 真源 General | cross-project §BCR 角色权限 |

## 角色集精简用例（BCR-004/006，删 UI/Tester → 4 角色）

| # | 触发输入 | 期望行为 | 规则来源 |
|---|----------|----------|----------|
| R1（负向）| `你是 UI` / `切换到界面设计师` | 不切已删角色；提示界面要点已并入 **PM**（PRD），可切 PM | 入口触发表 / role-ui 墓碑 |
| R2（负向）| `你是 Tester` / `切换到测试工程师` | 不切已删角色；提示测试已并入 **Developer 自测 + Owner 验收**，可切 Developer | 入口触发表 / role-tester 墓碑 |
| R3 | 关键词 `测试` / `QA`（模糊） | 反问指向 Developer 自测，不再指向 Tester | 入口模糊反问 |
| R4 | 关键词 `界面` / `UI` / `设计`（模糊） | 反问指向 PM（界面要点）或 Architect，不再指向 UI | 入口模糊反问 |
| R5 | 迭代关闭检查 | 以 Developer 自测结论 + **Owner 验收**（未验收/打回不得关闭）为前置；不再切 Tester Review | mechanisms 迭代关闭 / multi-agent §7 |
| R6 | 「验收标准/边界/回归」需独立复核 | 由 Architect 或 DevOps 复核；PM 产出验收标准时不自审 | multi-agent §9 Review 影响领域 |
| R7（同步）| 下游 sync 后查可达角色 | `role-ui.md`/`role-tester.md` 为 `<!-- RETIRED -->` 墓碑、入口触发表无 UI/Tester；`measure-context.sh` 不计墓碑 | sync-downstream / measure-context |

## 交接带宽加固用例（P12，多 Agent 框架调研落地）

| # | 触发输入 | 期望行为 | 规则来源 |
|---|----------|----------|----------|
| P12-1 | 设计文档接口契约 / 数据模型只写散文、缺结构化字段（方法/路径/入参/出参/错误码 或 字段/类型/约束） | Review 挡回要求补结构化字段（spike/无变更须显式标 `N/A` 并注明，非留空） | design.md §2/§3 / multi-agent §10 |
| P12-2（负向）| 设计 Review 的待澄清问题，答案只写进 Review 记录、未回填文档正文 | 不算闭环；须把答案回填数据模型/接口契约/核心流程正文，Review 记录只留指针 | multi-agent §10.1 答案回填底线 |
| P12-3 | 工作流角色**进入标准迭代某阶段**启动 | 强制首读本角色 `docs/progress/roles/{role}-corrections.md`（≤30 条）；漏读视为漏读。**文件不存在视为空 corrections、跳过不阻塞**（不卡在「必须读但无文件」） | runtime §工作流默认只读 第 7 项 |
| P12-4（负向）| 启动召回 knowledge 时整库读取 `docs/knowledge/` | 拒绝全库 dump；只读 `INDEX.md` 为当前迭代/任务显式关联的条目（无关联则不读） | context-policy §LTM 召回策略 |
| P12-5（负向）| 非迭代 / bugfix 快任务下要求强制首读 corrections | 不强制（按需读即可）；强制首读仅标准迭代各阶段 | runtime 第 7 项（决策项 2） |

## Trae IDE 兼容用例（P13，入口 AGENTS.md 复用 · 2026-07-02 Owner 在下游 workboard Trae 实测三句全通过）

| # | 触发输入 | 期望行为 | 规则来源 |
|---|----------|----------|----------|
| P13-1 | 在 Trae 打开本仓库后说 `你是 PM` | agent 读根目录 `AGENTS.md`，切 PM 角色并读 `docs/baseline/runtime.md`（非仅普通对话） | AGENTS.md 入口触发表 / runtime |
| P13-2 | 在 Trae 说 `进入团队工作流` | 按「工作流启动」流程走（判断 git 仓库 + 读 runtime.md） | AGENTS.md §工作流启动 |
| P13-3（负向）| 在 Trae 普通问候 / 闲聊 | 保持 General，不读 runtime、不硬拉选角色 | 入口原则 / N1 |

注：Trae 复用既有 `AGENTS.md`，无独立入口文件；P13-1~P13-3 已由 Owner 2026-07-02 在下游 workboard 的 Trae 实测**三句全通过**（`你是 PM` 完整切角色 + 读 runtime + 加载 project-context/INDEX/role-pm 清单；`进入团队工作流` 同启动流程覆盖；普通问候保持 General）。详见 `ROADMAP.md` §P13。
