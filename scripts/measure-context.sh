#!/usr/bin/env bash
# 统计工作流上下文加载体量，用于 ROADMAP 度量与回归。
# 注意：字符数是「文件体量上界」，不等于实际加载量——实际链路取决于 runtime 的按需读取决策。
# 因此本脚本是必要不充分：体量看这里，行为不回归看回归用例。
set -euo pipefail
cd "$(dirname "$0")/.."

count() { wc -m < "$1" | tr -d ' '; }

echo "# 单文件体量（字符数，约 1.5-1.7 token/字）"
for f in CLAUDE.md AGENTS.md \
         docs/baseline/runtime.md docs/baseline/multi-agent-workflow.md \
         docs/baseline/work-modes.md docs/baseline/conventions.md \
         docs/baseline/role-*.md; do
  printf "  %-42s %6s\n" "$f" "$(count "$f")"
done

echo
echo "# 链路合计（字符数）"
fixed=$(( $(count CLAUDE.md) + $(count docs/baseline/runtime.md) ))
iter=$(( fixed + $(count docs/baseline/role-developer.md) + $(count docs/baseline/multi-agent-workflow.md) ))
printf "  %-42s %6s\n" "固定层(入口+runtime)" "$fixed"
printf "  %-42s %6s\n" "标准迭代最重链路(+role-dev+multi)" "$iter"

echo
echo "# 双入口一致性（SOURCE-REPO-ONLY 块外正文应一致）"
if diff -q CLAUDE.md AGENTS.md >/dev/null; then
  echo "  OK：CLAUDE.md 与 AGENTS.md 完全一致"
else
  echo "  WARN：CLAUDE.md 与 AGENTS.md 存在差异，请人工核对（运行 diff CLAUDE.md AGENTS.md）"
fi
