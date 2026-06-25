# 角色集精简设计 v3 · 删 UI（BCR-004）+ 删 Tester（BCR-006）

- 日期：2026-06-25
- 范围：删除 **UI（界面设计师）** 和 **Tester（测试工程师）**，6 角色 → 4 角色（PM / Architect / Developer / DevOps）。
- 设计方：agent-workflow 真源会话（General，Owner 驱动）
- 关联：coordination `REQUESTS.md` **BCR-004 + BCR-006 均「评估中」**，均指向本方案
- 状态：**设计 v3，待 review**（v2 吸收第一轮 7 条、v3 吸收第二轮 5 条）。review→定稿→精确到行落地 spec→改 baseline→回流
- 修订：v2 吸收第一轮 7 条（清除策略 / 质量门禁硬规则 / Owner 验收 / 状态对齐 / scripts+回归 / 模板 / ROADMAP）；**v3 吸收第二轮 5 条**——① 范围补 README + subagents；② 模板改「全 docs/templates/ grep 清理」；③ 方案 A 与 measure-context 口径（墓碑不计角色集）；④ 复核规则避免 PM 自审；⑤ Owner 验收主位置定死 `iteration.md`

> 本文是评估附件，非状态真源；流转状态以 coordination `REQUESTS.md` 为准。

---

## 一、提案

**删 UI** → 并入 PM（UI 要点进 PRD）。**删 Tester** → 接口/自动化测试并入 Developer 自测、手动验收由 Owner、取消独立 Tester Review 门禁。理由见 BCR-004/006，从略。

## 二、职责再分配

| 原职责 | 移交给 |
|---|---|
| UI：流程/交互/视觉/UI 验收 | PM（择要并入 role-pm；UI 要点进 PRD） |
| Tester：接口/自动化测试、回归 | Developer 自测（**产出证据，不等同 Review**） |
| Tester：手动点击验收 | Owner（验收 + 提 bug） |
| Tester Review（验收/边界/回归 门禁） | 见 §四（不是简单删，有硬替代） |

## 三、新角色集 + 流水线

**4 角色**：PM / Architect / Developer / DevOps。

**流水线**：`PRD(含 UI 要点) → 设计 → 实现(含 Developer 自测) → 部署就绪 → 关闭(含 Owner 验收) → 收尾`（UI 方案并入 PRD；测试阶段取消）。

**Review 影响领域**：「用户流程/页面/交互/视觉」Review 方 UI→**PM**；「验收/边界/回归」见 §四。

## 四、质量门禁替代（吸收 Finding 2，硬规则）

删 Tester **不等于**删质量门禁。明确三条硬规则，避免门禁降级：

1. **Developer 自测 = 提供证据，不算 Review**：自测覆盖范围 + 结果证据必留（无证据不得进关闭），但它是自审、不充当独立评审方。
2. **「验收标准 / 边界条件 / 回归风险」独立复核**（接管原 Tester 那一行，吸收 Finding 4 防自审）：验收标准由 PM 产出时，边界/回归至少由 **Architect 或 DevOps** 复核——**不得让 PM 复核自己产出的验收标准**；实现完成后 PM 可做产品验收复核，但不算对自己 PRD 的独立 Review。
3. **Owner 验收 = 关闭门禁，不代写角色 Review**：Owner 给通过/打回结论是关闭的硬前置，但不顶替上面的 PM/Architect 复核。
- 与现有「核心产出默认至少 2 个 Review 方」（multi-agent §165 L182-183）衔接：删 Tester 后 Review 方池仍有 PM/Architect/Developer/DevOps，核心产出仍可凑满 2 方；验收/回归视角由 PM 或 Architect 顶上，不留空。

## 五、Owner 验收 checkpoint（吸收 Finding 3）

- **记录位置（定死，吸收 Finding 5）**：`iteration.md` 关闭归档区「Owner 验收」小节为**真源记录**；`INDEX.md` 只放摘要/链接，不作判定依据，关闭检查以 `iteration.md` 为准。
- **状态枚举**：`通过 / 打回 / 有条件通过 / 未验收`。
- **阻塞语义**：**未验收或打回 → 迭代不得关闭**；有条件通过须列明条件并跟踪。
- **bug 去向**：Owner 验收发现的 bug 进 Change Note 或当前迭代实现修复记录，回归后再验收。
- **不代签**：Agent 只能记录 Owner **明确给出**的验收结论，不得代 Owner 判「通过」。

## 六、角色/模板文件的下游清除策略（吸收 Finding 1，高·拍板点）

**问题**：`sync-downstream.sh` 对真源没有的下游文件**只报告不删**（L9/50/56），模板也整目录覆盖不删 orphan（L90）。所以**物理删除 `role-ui.md`/`role-tester.md`（及废弃模板）后，下游 sync 不会清掉它们**，残留旧角色文件，与「删角色」目标冲突。两条路二选一（**拍板点**）：

- **方案 A · 墓碑化（retire，推荐，零机制风险）**：真源里**保留**这些文件，但内容替换为一行墓碑——「本角色/模板已废弃，职责见 role-pm.md / role-developer.md」。sync 照常覆盖下游同名文件 → 下游拿到墓碑。角色已从 runtime/入口/multi-agent 路由移除 → 不可达；文件留作墓碑。代价：留几个死文件。
- **方案 B · sync 增强**：给 `sync-downstream.sh` 加「废弃 baseline/模板清单」，安全删除下游这些已知文件（带 dry-run + 自检）。end-state 干净（文件真没了），但**改动同步机制本身**，风险/工作量更大。
- 适用对象一致：`role-ui.md`/`role-tester.md` + 废弃模板（见 §七）。
- **选 A 的度量口径（吸收 Finding 3）**：墓碑文件首行加稳定标记（如 `<!-- RETIRED -->`）；`measure-context.sh` 改为只统计 active 角色文件，墓碑单列「retired」、**不计入角色集体量**。

## 七、改动范围（吸收 Finding 5/6/7）

**角色文件**：`role-ui.md`/`role-tester.md` 按 §六策略墓碑化或删除；核心方法择要并入 `role-pm.md`/`role-developer.md`。

**核心 baseline**：`multi-agent-workflow.md`（角色表 L71/74、流水线 L102、阶段表 L108/111/113、Review 影响领域 L172/175、Review 矩阵 L242/243、一人提示 L202、intro L11、**衔接「至少 2 Review 方」L182-183**）、`runtime.md`（路由）、入口 `CLAUDE.md`/`AGENTS.md`（触发表）、`mechanisms.md`（关闭检查：测试报告→Developer 自测+Owner 验收、切 Tester→自测核对/报 Owner）、`standard-iteration-quick.md`；顺带清理 `work-modes.md`/`non-iteration-quick.md`/`bootstrap.md`/`conventions.md`/`knowledge-base.md`/`role-developer.md`/`role-pm.md`/`role-devops.md`/`role-general.md`/`cross-project-collaboration.md` 中的 UI/Tester 提及。

**对外说明 + 子代理（吸收 Finding 1）**：`README.md`（角色表 / 模糊触发 / UI 草案非迭代描述）；`docs/baseline/subagents/sub-frontend.md`（读 `vX.Y-ui.md`、UI 方案一致校验）、`sub-backend.md`（「不改 UI 方案」）——去 UI 阶段前置。

**模板**（同 §六清除策略，**全 `docs/templates/` grep 清理、逐个决定**保留领域标签/改名/墓碑化/并入）：`ui-spec.md`、`test-plan.md`、`test-report.md`（处置见拍板点）；`review-plan.md`/`iteration.md`/`progress-index.md` 去 UI/测试阶段字段、加 Owner 验收区；`ad-hoc-task.md`/`change-note.md`/`knowledge-note.md`/`iteration-summary.md` 清 UI/测试字段。

**脚本 + 回归 + 真源自述（吸收 Finding 5/7）**：
- `scripts/measure-context.sh`：角色 6→4，更新 role-*.md 测量口径。
- `scripts/sync-downstream.sh`：仅当选方案 B 时改（加废弃清单 + 安全删除 + dry-run）。
- `docs/regression-cases.md`：新增用例——触发「测试/QA/UI/界面」不再切到已删角色；下游 sync 后无可达旧角色（A：墓碑可达但标废弃 / B：文件已删）。
- `docs/ROADMAP.md`（真源自述，**不回流**）：L90 缺陷严重度「Tester/Review 触发」、L131、L255「Tester/UI 提报层」改为新角色集口径。

## 八、风险与缓解

1. **删 Tester = 移除独立质量门禁**（ROADMAP 核心风险：勿把高危规则当长尾裁掉）→ 缓解：§四三条硬规则 + §五 Owner 验收强制门禁。
2. **删角色文件回流不闭合**（Finding 1）→ §六策略闭合。
3. **历史产物**：下游历史 `roles/ui.md`/`roles/tester.md`、`vX.Y-ui-spec.md`/`vX.Y-test-report.md` 保留存档不追溯，新迭代起按新角色集走。

## 九、待 Owner / reviewer 拍板点

1. 角色集定 **4 角色**？
2. 测试阶段**彻底取消**（并入自测 + Owner 验收）？
3. §四质量门禁三条硬规则（自测=证据 / PM 或 Architect 复核验收回归 / Owner 验收=关闭门禁）OK？
4. §五 Owner 验收记录位置（iteration.md 关闭归档区）+ 状态枚举 + 未验收不得关闭 OK？
5. **§六清除策略选 A（墓碑化，推荐）还是 B（sync 增强）**？
6. UI 方案并入 PRD？`ui-spec.md` 保留为 PM 可选模板还是墓碑化？
7. `test-plan.md` + `test-report.md`：合并为一份 **Developer 自测计划/报告**模板，还是都墓碑化？
8. 历史 UI/Tester 产物保留存档不追溯？

## 十、未决 / 待续

- v2 是设计（范围+职责+门禁替代+清除策略+风险）；**精确到行落地 spec 待 review 通过 + §六/§七 拍板后再出**。
- BCR-004/006 已在 coordination「评估中」并指向本方案。
- 验证：本轮 grep 已核实改动范围（含 test-plan.md、L182-183、ROADMAP、sync orphan 行为），未改任何 baseline。
