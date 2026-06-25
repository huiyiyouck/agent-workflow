# BCR-003 元信息流转闭环设计（含根 `/root/Project/CLAUDE.md` 重设计）

- 日期：2026-06-25
- 设计方：agent-workflow 真源会话（General）
- 关联：BCR-003（coordination `REQUESTS.md` 基线修正提案池，当前状态「已提报」）
- 状态：**评估草案（方向 + 协议草案），未推进 BCR-003 状态**。review 通过后，先由 coordination 会话把 BCR-003 推进到「评估中」，再分环落地。
- 修订：v2.1（v2 吸收第一轮评审 5 条 Finding；v2.1 修「根会话不得写 coordination」边界冲突，覆盖 §二 step3 / §三 / §四 三处）

> **本文是评估附件，非状态真源。** BCR-003 流转状态以 coordination `REQUESTS.md` 为准；本文只承载机制设计与改动方案。review 由 Owner 拍板，不是任何会话/文件的内置职责。

---

## 一、要解决的问题

项目迭代中改了自己的「定位 / 名称 / 技术栈 / 上线 / 接入状态」，生态层三处真源没机制兜底同步，慢慢过期：

- coordination `PROJECTS.md`（项目目录结构化真源）—— **当前 workboard 行就过期**（`:51` 仍「本地 Node + 静态前端」、`:54` 仍「待开发 MVP」，实况已是 React+shadcn / 已上线）。
- 根 `/root/Project/CLAUDE.md` 生态索引（导航视图）。
- 本仓 BCR 回流清单各项目接入状态。

关键认知（第一轮评审 Finding 1）：**`PROJECTS.md` 自己也会过期**，所以不能简单令根索引「以 PROJECTS.md 为准」就完事——真源过期时需要停机/转交协议。

## 二、闭环数据流与载体（吸收 Finding 2）

载体：**「元信息变更台账」**——一处固定区块，记录每一笔待传播的元信息变更，三个会话据它接力，PROJECTS.md 与根索引都从**同一笔台账的 new 值**取数，谁都不充当对方的真源。

**台账字段**：

| 项目 | 字段 | old | new | 来源（commit / 迭代） | PROJECTS 已同步 | 生态索引已同步 |
|------|------|-----|-----|----------------------|-----------------|--------------|

**生命周期**：

```text
1. 子项目迭代关闭检查（agent-workflow mechanisms 第 9 项）发现元信息变更
   └→ 在台账写一行：填 项目/字段/old/new/来源；两个「已同步」列留空
2. coordination 会话：照该行 new 值改 PROJECTS.md 对应行 → 勾「PROJECTS 已同步」
3. 根目录会话：照已更新的 PROJECTS.md 改根索引；改完**输出「该行可勾『生态索引已同步』」回执**，转交 coordination 会话勾（根会话不写 coordination，见§三末原则）
4. 两列都勾 → 该行归档 / 移除
```

**台账位置（拍板点，见七）**：倾向 coordination `STATUS.md` 新增「## 元信息变更台账」区块（它本就是跨项目状态/待办性质）；备选挂 `PROJECTS.md` 旁或新建独立文件。

## 三、PROJECTS.md 过期时的停机/转交协议（吸收 Finding 1）

根目录会话自检发现「各仓实况」与 `PROJECTS.md` 不一致，但台账里**没有对应在途行**（说明这笔变更当初漏登记）时：

- **不得**按实况直接改根索引（根索引真源是 `PROJECTS.md`，不是某次目测的实况）；
- **不得**把根索引同步到明显过期的 `PROJECTS.md`（否则把错值固化下传）；
- **必须**：根会话**不直接写 coordination**，而是**输出一条完整的「待登记元信息变更台账行」内容**（项目 / 字段 / old / new / 来源标「根会话自检发现的漏登记」），转交 Owner 在 coordination 会话登记；coordination 会话登记并订正 `PROJECTS.md`（勾「PROJECTS 已同步」）后，根会话再同步根索引。

一句话：根会话遇真源可疑时是「**上报 + 暂停**」，不自行决断。同理 coordination 会话若拿不准 new 值，回查提出方子项目，不臆测。

> **总原则——根会话对 coordination 全程只读（含台账）**：根会话只「输出待写内容 / 回执」，所有对 `coordination/STATUS.md` 台账的实际写入（登记新行、勾「PROJECTS 已同步」、勾「生态索引已同步」）一律由 coordination 会话执行。这保住根 CLAUDE.md「绝不修改子项目」边界，又不牺牲闭环。（注：子项目会话向 coordination 登记台账行属既有「下游写 coordination」模型，不受此限；本原则只约束根目录会话。）

## 四、根 CLAUDE.md 结构草案（骨架，吸收 Finding 4）

> 这是**结构骨架**，不是可直接落地的全文；数据值见「五、落地核对清单」，由根会话落地时照 `PROJECTS.md` 填。

新增 / 改动的节：

1. **新增「本文件的定位（受工作流管控）」**：本文件不游离于工作流外；项目元信息真源是 `coordination/PROJECTS.md`，本文件「项目索引」是其导航视图；本文件 review 不由根会话承担（Owner 拍板）。
2. **新增「索引维护职责」**：写清根会话的
   - 触发：台账有「PROJECTS 已同步、生态索引未同步」的行，或自检发现根索引与 PROJECTS.md 不符；
   - 动作：照 `PROJECTS.md` 订正「项目索引」表 + 「已知不一致」节；**输出「生态索引已同步」回执转交 coordination 会话勾台账**（根会话不写 coordination，见§三末原则）；
   - 停机/转交：按§三处理真源可疑情形；
   - 边界：只订正本文件，不回写 PROJECTS.md，不改子项目。
3. **职责边界补例外**：「照索引维护职责订正本文件，不算『改子项目』」。
4. **「项目索引」表表头说明改写（吸收 Finding 3）**：「**除『分类（内部）』外**，各字段照 `PROJECTS.md` 同步；『分类（内部）』仅根索引本地导航标签，由根文件自行维护，不从真源取数」。
5. **保留不动**：角色、生态关系图、入口速查的现状正文。

## 五、落地核对清单（数据值，吸收 Finding 4）

根会话落地改根索引时，逐项照 `PROJECTS.md` 当时值核对填入（**不照本草案、不照记忆**）：

- [ ] 「项目索引」表 5 行的 定位 / 技术栈 / 状态 列，逐行对齐 `PROJECTS.md`（重点：workboard 行——但前提是 PROJECTS.md 该行已先被订正，见§三）。
- [ ] 「已知不一致」节：清理已修复条目（如 `../claude-workflow` 路径已修复未清理者），保留仍成立条目（如 ai 无 git remote）。
- [ ] 「分类（内部）」列不动（非真源字段）。

## 六、落地分工（review 通过、BCR-003 转「评估中」后，分环）

| 环 | 谁做 | 改哪 |
|----|------|------|
| 触发规则 | **agent-workflow 真源会话**（本会话） | `mechanisms.md` 加第 9 项（变更→登记台账）；`cross-project-collaboration.md` 补一句定责任 + 指向台账机制 |
| 台账区块 + PROJECTS.md 订正 | coordination 会话 | `STATUS.md` 建台账区块；订正 `PROJECTS.md` workboard 等行；订 BCR-001 回流清单 workboard 状态 |
| 根索引重设计 + 同步 | 根目录会话（Owner 在根目录发话） | `/root/Project/CLAUDE.md` 套§四结构 + 照§五清单填值 |

> 本会话只产出设计与（review 后）agent-workflow baseline 那一环；不碰 coordination、不碰根文件。

## 七、待 Owner 拍板点

1. **台账位置**：放 coordination `STATUS.md` 新区块（推荐）/ `PROJECTS.md` 旁 / 独立文件？
2. **台账字段**（§二那 7 列）是否够用、命名 OK？
3. **停机/转交协议**（§三）措辞是否 OK——根会话遇真源可疑时「上报+暂停」而非自行决断？
4. 根 CLAUDE.md 的「定位 + 索引维护职责」两节 + 「不算改子项目」例外是否 OK？
5. 索引真源主从关系（PROJECTS.md 真源 / 根索引导航视图，分类字段除外）是否就是你要的？

## 八、本次未做 / 待续

- 未推进 coordination BCR-003 状态（仍「已提报」）——按 Finding 5，review 通过后再由 coordination 会话推「评估中」。
- 未写 BCR-003 在 agent-workflow baseline 的逐行 diff（mechanisms 第 9 项 / cross-project 一句的精确措辞）——拍板后补这一环的落地游标。
- 验证：本轮仅文档/状态核对，未跑任何脚本或测试。

## 九、agent-workflow 环 baseline 落地游标（待 BCR-003 转评估中后执行）

> **边界**：本节是**落地准备**，只给精确措辞与插入点；**本步不改 baseline**。等 coordination 会话把 BCR-003 推到「评估中」后，再按本节改 `mechanisms.md` / `cross-project-collaboration.md`。

### 块 A：`mechanisms.md` 新增第 9 项检查

- 目标文件：`docs/baseline/mechanisms.md`
- 插入位置：§3 迭代关闭检查 → `### 检查项` 列表末尾，现第 8 项之后，新增第 9 项。
- 精确文案：

```markdown
9. 本迭代是否变更了项目定位 / 名称 / 技术栈 / 上线状态 / 工作流接入状态？若是，由关闭检查执行者在 coordination `STATUS.md`「元信息变更台账」登记一行（项目 / 字段 / old / new / 来源），后续由 coordination 会话据此同步 `PROJECTS.md`、生态索引维护方照真源订正其导航视图（详见 `cross-project-collaboration.md` §项目元信息同步）。
```

### 块 B：`cross-project-collaboration.md` 新增「## 项目元信息同步」

- 目标文件：`docs/baseline/cross-project-collaboration.md`
- 插入位置：§基线修正提案流转（BCR）之后、`## communications（按需求）` 之前，新增一节。
- 精确文案：

```markdown
## 项目元信息同步

项目迭代中变更了**定位 / 名称 / 技术栈 / 上线状态 / 工作流接入状态**时，须保证生态层真源被同步订正，避免悄悄过期。

- **真源**：项目元信息的结构化单一真源是 coordination `PROJECTS.md`；各处生态索引（如生态根导航文件）是它的**导航视图**，照真源同步、不自由发挥。
- **载体**：变更登记在 coordination `STATUS.md`「元信息变更台账」——字段 `项目 | 字段 | old | new | 来源（commit/迭代） | PROJECTS 已同步 | 生态索引已同步`（本生态即根索引）。
- **三方接力**：
  1. 子项目迭代关闭检查发现变更 → 在台账登记一行（两个「已同步」列留空）；
  2. coordination 会话照该行 new 值改 `PROJECTS.md` → 勾「PROJECTS 已同步」；
  3. 生态索引维护方照已更新的 `PROJECTS.md` 订正导航视图 → 通知 coordination 会话勾「生态索引已同步」（索引维护方对 coordination 只读时，输出回执转交，不自行写台账）。
- **真源可疑时停机**：索引维护方发现「各仓实况」与 `PROJECTS.md` 不一致且台账无在途行时，**不得**按实况直接改索引、**不得**同步到过期真源，须输出待登记台账行转交 coordination 会话先订正 `PROJECTS.md`，再同步。
```

- **设计注（生态特定 vs 通用产品）**：上文用「生态根导航文件 / 导航视图」等**通用措辞**，刻意**不在通用 baseline 里硬编码 `/root/Project/CLAUDE.md`** 这种本生态特定路径——根索引那部分职责落在根 CLAUDE.md 自己（本文件§四），保证 baseline 复制到其他下游时不泄露本生态根路径。

> 落地后自检：`./scripts/measure-context.sh`（评估固定层增量）；若改动属会回流 baseline，按惯例跑 `scripts/sync-downstream.sh` 自检。
