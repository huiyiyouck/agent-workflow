# BCR-002 评估方案 · communications 命名轴（项目对 → 按需求）

- 日期：2026-06-22
- 提出方：xiaobao（P7 对齐真源时工作区留痕，转正式 BCR）
- 评估方：Owner + agent-workflow 真源会话（General）
- coordination 登记：`REQUESTS.md` 基线修正提案池 · BCR-002
- 状态：**评估方案待 Owner review**（review 通过 → 改真源 baseline → PR → coordination 实体迁移 → 下游 sync 回流）

> **本文是评估附件，非状态真源。** BCR-002 的流转状态以 coordination `REQUESTS.md` 基线修正提案池为准；本文只承载评估推理与改动方案，避免双状态源。

---

## 一、提案内容

把 coordination `communications/` 沟通文档的命名/组织方式，从**按项目对一份**改为**按需求一份**。

| 维度 | 按项目对（真源现状） | 按需求（提案） |
|------|---------------------|----------------|
| 命名 | `communications/{a}__{b}.md`（如 `xiaobao__ai.md`） | `communications/{REQ-id}-{短名}.md`（如 `REQ-001-news-l1.md`） |
| 粒度 | 一对项目共用一份，承载该对所有需求 | 一个需求一份 |
| 反查 | 一份里多 REQ 混杂，靠标注区分 | 与 REQ id 一一对应，直达 |
| 长期可读 | 单份越积越长 | 需求关闭即归档，边界清晰 |

## 二、评估结论：**采纳「按需求一份」，现在落地正当时**

关键事实——这不是新问题，是 **P5 主动搁置的 v2 候选**（ROADMAP L279）。P5 当时选「按项目对 v1」、把「按需求」推到 v2 的两个理由：

1. 它是 **breaking 变更**（要动 coordination 实体文件 + REQUESTS 链接）；
2. P5 阶段**还没有 sync 回流机制**，"不做下游迁移"是当时前提。

这两个理由现在**大半已不成立**：
- ✅ P7/P8 已建成 **sync 回流机制**；
- ✅ 当前迁移成本**近乎为零**——coordination 里 communications 现仅 `xiaobao__ai.md` 一份、REQ-001 一条。

且方向上：你的直觉（一需求一份）+ 机制核心单元本就是 `REQ-###` → 命名轴应与之对齐。按项目对唯一优势「文件数有界」在一人公司小生态无价值。

**结论：趁生态仅 1 份沟通文档、迁移成本最低之机切换；越往后需求越多、迁移越贵。**

## 三、反向链接语义重定义（吸收 review Finding 1）

按项目对时一个项目对一份，PROJECTS.md 两个项目行各放一个链接成立；改按需求后**项目 → 沟通文档是一对多**（一个项目未来关联多份 `REQ-xxx-*.md`），PROJECTS.md 单个「沟通文档」字段钉死单份不再成立。重定义如下：

- **反孤儿主担保移到 `REQUESTS.md`**：每条 REQ 的「沟通文档」字段**一一对应**链接自己的 `communications/{REQ-id}-{短名}.md`。由于 REQ 与文档一一对应，每份文档都能从对应 REQ 条目找到，**天然无孤儿**。
- **目录索引 `communications/README.md`**：维护全部沟通文档清单（已有此文件），作为目录级总览。
- **`PROJECTS.md` 项目行「沟通文档」字段**：从"指向具体某一份"改为指向 `REQUESTS.md`（按项目可筛该项目参与的需求，每条再链到自己的沟通文档）；不再逐份钉死。

> 这样 PROJECTS.md 不随需求量爆炸，反孤儿由"REQ↔文档一一对应"保证，比"PROJECTS 逐份双链"更可持续。

## 四、真源 baseline 改动方案（本步范围，待 review 后实施）

### 文件 A：`docs/baseline/cross-project-collaboration.md`

| # | 位置 | before | after |
|---|------|--------|-------|
| A1 | L37 目录表 | …（按项目对，见下） | …（按需求一份，见下） |
| A2 | L90 字段表 | 沟通文档 → `communications/{a}__{b}.md` | → `communications/{REQ-id}-{短名}.md` |
| A3 | L136-143 §标题+正文+创建时机 | 「按项目对」/「每一对项目共用一份」`{project-a}__{project-b}.md`/「这对项目首个需求被承接后」 | 「按需求」/「每个被承接的需求一份」`{REQ-id}-{短名}.md`（如 `REQ-001-news-l1.md`）/「该需求被承接后」+ 一句"命名轴与机制核心单元 REQ 一致、关闭即归档、反查直达" |
| A4 | L141-142 职责分工+反孤儿 | 「反向链接到所属项目对沟通文档」/「`PROJECTS.md` 必须反向链接每份沟通文档」 | 按§三重定义：REQUESTS 一一对应担保反孤儿；`communications/README.md` 目录索引；`PROJECTS.md` 沟通文档字段指向 `REQUESTS.md`，不逐份钉死 |
| A5 | L147-154 头部模板 | `# {project-a} ↔ {project-b} 跨项目沟通` + 参与项目两行 | 见下（**保留契约真源 + 最近更新字段**，吸收 Finding 2） |

**A5 新头部模板（写死，保留全部高价值字段）**：
```markdown
# {REQ-id} {需求短名} 跨项目沟通

- 需求：{REQ-id}（状态见 ../REQUESTS.md）
- 参与项目：{提出方项目}, {承接方项目}
- 契约真源：contracts/{name}.md（涉及接口/字段时）
- 最近更新：YYYY-MM-DD
```

### 文件 B：`docs/ROADMAP.md`（1 处）
- L279「v2 候选 · communications 按需求命名」→ 划掉、标 **已采纳落地（BCR-002，2026-06-22）**，记一句来龙去脉。
- L238/245/263/270 的「项目对」是 **P5 历史决策留痕，保留不动**（不篡改历史）。

### 文件 C：`docs/regression-cases.md`（1 条，吸收 review 建议）
- 新增一条 communications 命名/反向链接用例：承接某 REQ 后，沟通文档按 `{REQ-id}-{短名}.md` 命名，REQUESTS.md 该 REQ「沟通文档」字段一一对应链接；PROJECTS.md 不逐份钉死沟通文档。

## 五、待 Owner 拍板点

1. 命名格式 `{REQ-id}-{短名}.md` 是否 OK？
2. 头部模板（A5，含契约真源 + 最近更新）是否 OK？
3. 短名是否要写死命名规范？**倾向不写死**，只给示例（短名 kebab-case，按需求自起），保持轻量。
4. **反向链接重定义（§三）是否 OK**？即：反孤儿落到 REQUESTS 一一对应、PROJECTS 字段改指向 REQUESTS、communications/README.md 做索引。
5. ROADMAP 这条改法是否 OK？

## 六、自检计划（改完执行，吸收 Finding 3）

- `grep -rn "{a}__{b}\|{project-a}\|{project-b}\|xiaobao__ai" docs/baseline README.md` 确认无残留（**范围限 `docs/baseline` + `README.md`，不扫 ROADMAP**——其历史留痕保留「项目对」字样，不用宽泛全词硬卡）；
- `./scripts/measure-context.sh`（命名轴改动不增量，链路应基本不变）；
- `scripts/sync-downstream.sh /tmp/agent-workflow-bcr-002-check`（**这是会回流的 baseline 规则，必须跑 sync 自检**）；
- `rg` 复核临时产物里 communications 新规则已回流、入口无 SOURCE-REPO-ONLY 残留。

## 七、落地全链路（三块，本方案只含第 1 块）

1. **真源 agent-workflow**（本会话，待 review 后）：文件 A/B/C → 开 `feat/p8-bcr-002` 分支 → PR → 合并。
2. **coordination 会话**：BCR-002 标「已采纳 → 已落地真源」；实体迁移：
   - `communications/xiaobao__ai.md` → `communications/REQ-001-news-l1.md`（头部按 A5 模板改写）；
   - `REQUESTS.md` REQ-001「沟通文档」字段 → 指向新文件名；
   - `PROJECTS.md` xiaobao / ai 两行「沟通文档」字段 → 改为指向 `REQUESTS.md`（按§三，不再钉死单份）；
   - `communications/README.md` 索引更新为新文件名。
3. **ai / xiaobao 会话**：`sync-downstream.sh` 回流；回流清单逐项完成后 coordination 置「已回流下游」终态。
