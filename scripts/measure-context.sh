#!/usr/bin/env bash
# 统计工作流上下文加载体量，用于 ROADMAP 度量与回归。
# 注意：字符数是「文件体量上界」，不等于实际加载量——实际链路取决于 runtime 的按需读取决策。
# 因此本脚本是必要不充分：体量看这里，行为不回归看 docs/regression-cases.md。
set -euo pipefail
cd "$(dirname "$0")/.."

count() { wc -m < "$1" | tr -d ' '; }

echo "# 单文件体量（字符数，约 1.5-1.7 token/字）"
for f in CLAUDE.md AGENTS.md \
         docs/baseline/runtime.md \
         docs/baseline/standard-iteration-quick.md docs/baseline/non-iteration-quick.md \
         docs/baseline/multi-agent-workflow.md docs/baseline/work-modes.md docs/baseline/conventions.md \
         docs/baseline/role-*.md; do
  printf "  %-48s %6s\n" "$f" "$(count "$f")"
done

echo
echo "# 链路合计（字符数）"
entry=$(count CLAUDE.md); rt=$(count docs/baseline/runtime.md)
roledev=$(count docs/baseline/role-developer.md)
iq=$(count docs/baseline/standard-iteration-quick.md); nq=$(count docs/baseline/non-iteration-quick.md)
pc=$(count docs/baseline/project-context.template.md); pi=$(count docs/templates/progress-index.md)
printf "  %-46s %6s\n"               "固定层(入口+runtime)"                "$(( entry + rt ))"
printf "  %-46s %6s  [P1硬指标 <13000]\n" "固定规则链路(入口+runtime+迭代必读)" "$(( entry + rt + iq ))"
printf "  %-46s %6s  [观测 <15000]\n"    "标准迭代启动链路(+role-dev)"          "$(( entry + rt + roledev + iq ))"
printf "  %-46s %6s\n"               "非迭代启动链路(+role-dev)"            "$(( entry + rt + roledev + nq ))"
printf "  %-46s %6s  [P2硬验 <15000]\n" "真实启动链路fixture(+pc模板+index模板)" "$(( entry + rt + roledev + iq + pc + pi ))"
printf "  %-46s %6s  [完整规范, 按需]\n" "multi-agent-workflow(单列)"          "$(count docs/baseline/multi-agent-workflow.md)"

echo
echo "# 双入口一致性（CLAUDE.md 与 AGENTS.md 应完全一致）"
if diff -q CLAUDE.md AGENTS.md >/dev/null; then
  echo "  OK：CLAUDE.md 与 AGENTS.md 完全一致"
else
  echo "  WARN：CLAUDE.md 与 AGENTS.md 存在差异，请人工核对（运行 diff CLAUDE.md AGENTS.md）"
fi
