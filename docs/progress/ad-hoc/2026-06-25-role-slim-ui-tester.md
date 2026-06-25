# 角色集精简设计 v1 · 删 UI（BCR-004）+ 删 Tester（BCR-006）

- 日期：2026-06-25
- 范围：删除 **UI（界面设计师）** 和 **Tester（测试工程师）** 两个工作流角色，6 角色 → 4 角色（PM / Architect / Developer / DevOps）。
- 设计方：agent-workflow 真源会话（General，Owner 驱动）
- 关联：coordination `REQUESTS.md` BCR-004（删 UI，已提报）+ BCR-006（删 Tester，本次新立）
- 状态：**设计 v1，待 review**（review→定稿→精确到行落地 spec→改 baseline→回流）

> 本文是评估附件，非状态真源；流转状态以 coordination `REQUESTS.md` 为准。

---

## 一、提案

**删 UI**：职责并入 **PM**。一人公司 + AI 出原型（Figma Make / Claude Design）下，UI 与 PM 高度重叠；workboard v0.1 已实证「PM 兼 UI」跑通整迭代。

**删 Tester**：不再设独立测试角色。理由（Owner）：
- Tester 实际只能调接口测试，**没法代人手动点击**，与 Developer 自测高度重叠；
- 后续 **Developer 自测**（接口/自动化）覆盖这块；
- **手动点击验收由 Owner 完成**，提 bug 给 Developer 修；
- 故独立 Tester 角色用处不大、空转。

## 二、职责再分配

| 原角色职责 | 移交给 |
|---|---|
| UI：用户流程映射 / 交互状态 / 视觉约束 / UI 验收 | **PM**（择要并入 role-pm；UI 要点并入 PRD） |
| Tester：接口 / 自动化测试、回归 | **Developer 自测**（实现阶段内，自测证据必留） |
| Tester：验收 / 手动点击测试 | **Owner**（人工验收，提 bug） |
| Tester：bug 跟踪 | Owner 提 → Developer 修（迭代内回归或 Change Note） |
| Tester Review（验收/边界/回归 影响域门禁） | 取消独立门禁 → Developer 自测自审 + **Owner 验收 checkpoint（强制）** |

## 三、新角色集 + 新流水线

**角色集（4）**：PM（产品经理）/ Architect（架构师）/ Developer（开发工程师）/ DevOps（运维部署）。

**标准迭代流水线**（前 / 后）：
```
旧：PRD → UI 方案 → 设计 → 实现 → 测试 → 部署就绪 → 关闭 → 收尾
新：PRD(含 UI/界面要点) → 设计 → 实现(含 Developer 自测) → 部署就绪 → 关闭(含 Owner 验收) → 收尾
```
- UI 方案阶段：并入 PRD（PM 出，界面要点作为 PRD 一节或可选产出）。
- 测试阶段：取消独立阶段；接口/自动化测试并入实现（Developer 自测），手动验收落到「关闭」前的 Owner 验收。

**Review 影响领域调整**：
- 「用户流程 / 页面 / 交互 / 视觉」→ Review 方由 UI 改 **PM**。
- 「验收标准 / 边界条件 / 回归风险」→ 不再有 Tester 同行评审；改为 **Developer 自测自审 + Owner 验收**（移出 peer-Review 机制）。

## 四、改动范围（按文件，待落地 spec 精确到行）

**删除**：`role-ui.md`、`role-tester.md`（核心方法择要并入 `role-pm.md` / `role-developer.md`）。

**核心改**：
- `multi-agent-workflow.md`：角色表去 UI/Tester（L71/74）；流水线去 UI 方案/测试阶段（L102）；阶段表去对应行、迭代关闭去「切 Tester」（L108/111/113）；Review 影响领域表 UI→PM、删 Tester 行（L172/175）；Review 矩阵删 UI 方案/测试报告行（L242/243）；一人场景提示去 Tester 例（L202）；intro 角色列举（L11）。
- `runtime.md`：角色加载路由去 UI/Tester。
- 入口 `CLAUDE.md` / `AGENTS.md`：角色切换触发表去「UI/界面设计师」「测试/QA/Tester/测试工程师」精准触发 + 模糊反问（或把「测试」关键词指向 Developer 自测说明）。
- `mechanisms.md`：迭代关闭检查——「测试报告有结论」→「Developer 自测结论 + Owner 验收结论」；「切 Tester / Tester Review」→「Developer 自测核对，无法判断报 Owner」。
- `standard-iteration-quick.md`：流水线 UI/测试阶段处理。
- `work-modes.md` / `non-iteration-quick.md` / `bootstrap.md` / `role-developer.md` / `role-pm.md` / `role-devops.md` / `role-general.md` / `conventions.md` / `knowledge-base.md` / `cross-project-collaboration.md`：清理 UI/Tester 提及（多为顺带列举，落地 spec 逐处核）。

**模板**：
- `test-report.md`：保留并改为 **Developer 自测报告**模板（或并入 `iteration.md`）；
- `ui-spec.md`：并入 PRD 模板或留作 PM 可选产出；
- `review-plan.md` / `iteration.md` / `progress-index.md`：去 UI/测试阶段字段。

## 五、风险与缓解（供评估）

1. **删 Tester = 移除独立质量门禁**（ROADMAP 核心风险点：别把高危规则当长尾裁掉）。
   - 缓解：**Owner 验收 checkpoint 升为强制**——迭代关闭前必须有 Owner 验收结论（通过/打回），不可省；**Developer 自测纪律强化**（自测范围 + 证据必留，无证据不得进关闭）。
2. **删 UI = 视觉/交互专门视角弱化**。
   - 缓解：UI 要点并入 PRD 由 PM 负责；AI 出原型补足；workboard v0.1 已验证可行。
3. **历史产物归属**：各下游历史迭代有 `roles/ui.md`/`roles/tester.md`、`vX.Y-ui-spec.md`/`vX.Y-test-report.md`。
   - 处理：保留为历史存档，不追溯改写；新迭代起按新角色集走。落地 spec 须明确「历史产物不动、仅停用角色」。

## 六、待 Owner / reviewer 拍板点

1. 角色集定为 **4 角色**（PM/Architect/Developer/DevOps）——确认？
2. **测试阶段彻底取消**、并入 Developer 自测 + Owner 验收（而非保留一个轻量测试阶段）——确认？
3. **Owner 验收升为强制关闭门禁**（替代 Tester Review）——接受这个补偿性约束吗？
4. UI 方案阶段**并入 PRD**（vs 保留为 PM 可选独立阶段）——选哪个？
5. 模板 `test-report.md` **改为 Developer 自测报告**（vs 删除并入 iteration）——选哪个？
6. 历史 UI/Tester 产物**保留存档不追溯**——确认？

## 七、未决 / 待续

- 本文是设计 v1（范围 + 职责 + 风险）；**精确到行的落地 spec 待 review 通过后再出**（同 BCR-003/005：design→merged spec→落地）。
- BCR-006（删 Tester）待在 coordination 登记（Owner 驱动）；BCR-004（删 UI）已在册，落地时与 BCR-006 合并为一份「角色集精简」spec。
- 验证：本轮仅 grep 摸清引用范围，未改任何 baseline。
