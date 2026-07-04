#!/usr/bin/env bash
# 把工作流从真源同步到下游项目（幂等：首次安装 + 后续更新通用）。
# 覆盖框架文件、保留项目专属；可重复运行 = 同步更新，替代手动复制。
#
# 框架文件（覆盖）：入口 CLAUDE.md/AGENTS.md（剥离 SOURCE-REPO-ONLY）、
#                   docs/baseline/（除 project-context.md）、docs/templates/。
# 项目专属（保留）：docs/progress/、docs/baseline/project-context.md、
#                   docs/knowledge/ 实际条目、项目源码 —— 从不覆盖。
# 下游独有的框架文件（真源没有的，如本地分叉角色）只报告、不删。
#
# 与 install-downstream.sh 的分工：install 是「严格空目录的一次性首装」；
# 本脚本是「已有项目的安装 + 持续同步更新」，可对非空项目重复运行。
#
# 用法：scripts/sync-downstream.sh <目标项目目录> [--dry-run]
# 退出码：0 成功；1 安全/自检失败；2 用法错误。
set -euo pipefail

SRC="$(cd "$(dirname "$0")/.." && pwd)"
DEST=""
DRY=0
for a in "$@"; do
  case "$a" in
    --dry-run) DRY=1 ;;
    -*) echo "未知参数：$a" >&2; exit 2 ;;
    *) DEST="$a" ;;
  esac
done
[ -n "$DEST" ] || { echo "用法：scripts/sync-downstream.sh <目标项目目录> [--dry-run]" >&2; exit 2; }

# 0. 安全：目标不能是真源仓库自身或其子目录（否则会截断/污染真源文件）。
SRC_REAL="$(realpath "$SRC")"
DEST_REAL="$(realpath "$DEST" 2>/dev/null || echo "$DEST")"
case "$DEST_REAL" in
  "$SRC_REAL"|"$SRC_REAL"/*)
    echo "错误：目标目录不能是真源仓库自身或其子目录（会破坏真源文件）。" >&2; exit 1 ;;
esac

# 1. 前置关卡（真源侧）：双入口一致 + knowledge 无真源条目（防泄漏到下游）。
if ! diff -q "$SRC/CLAUDE.md" "$SRC/AGENTS.md" >/dev/null; then
  echo "错误：真源 CLAUDE.md 与 AGENTS.md 不一致，拒绝同步。" >&2; exit 1
fi
if find "$SRC/docs/knowledge" -name '*.md' ! -name 'INDEX.md' | grep -q .; then
  echo "错误：真源 docs/knowledge/ 含知识条目，拒绝同步（防真源知识泄漏到下游）。" >&2; exit 1
fi

NEW=0; [ -d "$DEST/docs/baseline" ] || NEW=1
MODE=$([ "$NEW" = 1 ] && echo "首次安装" || echo "更新")
echo "== 同步模式：$MODE   目标：$DEST $([ "$DRY" = 1 ] && echo '(dry-run，仅预览)')"

# 2. 报告下游独有的框架文件（真源没有，可能是本地分叉）——不删，提示人工处理。
if [ "$NEW" = 0 ]; then
  orphans=$(comm -13 \
    <(cd "$SRC/docs/baseline" && find . -type f | sort) \
    <(cd "$DEST/docs/baseline" && find . -type f ! -name 'project-context.md' | sort) || true)
  if [ -n "$orphans" ]; then
    echo "⚠️ 下游独有框架文件（真源没有，未删除，请人工决定是否为本地分叉）："
    echo "$orphans" | sed 's#^\./#     docs/baseline/#'
  fi
fi

# 3. dry-run：列出将覆盖/新增的框架文件清单，不写。
strip_block() { sed '/↓↓↓ SOURCE-REPO-ONLY/,/↑↑↑ SOURCE-REPO-ONLY/d' "$1" | cat -s; }
if [ "$DRY" = 1 ]; then
  echo "将覆盖/新增的框架文件："
  echo "     CLAUDE.md"
  echo "     AGENTS.md"
  ( cd "$SRC" && find docs/baseline -type f ! -name 'project-context.md' | sort | sed 's/^/     /' )
  ( cd "$SRC" && find docs/templates -type f | sort | sed 's/^/     /' )
  echo "将保留（不碰）：docs/progress/、project-context.md、docs/knowledge/ 已有条目"
  echo "(dry-run 结束，未写入)"; exit 0
fi

# 3b. 覆盖式同步保护：目标若是 git 仓且工作区不干净，拒绝（防冲掉未提交的本地改动）。
if git -C "$DEST" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if [ -n "$(git -C "$DEST" status --short 2>/dev/null)" ]; then
    echo "错误：目标工作区有未提交改动，拒绝同步（覆盖式操作可能冲掉本地改动）。" >&2
    echo "      请先在目标项目提交/暂存，或先用 --dry-run 预览。" >&2
    exit 1
  fi
fi

# 4. 覆盖框架文件。
mkdir -p "$DEST/docs"
strip_block "$SRC/CLAUDE.md" > "$DEST/CLAUDE.md"
strip_block "$SRC/AGENTS.md" > "$DEST/AGENTS.md"
# baseline：逐文件覆盖，排除项目专属 project-context.md
find "$SRC/docs/baseline" -type f ! -name 'project-context.md' | while read -r f; do
  rel="${f#"$SRC"/}"; mkdir -p "$DEST/$(dirname "$rel")"; cp "$f" "$DEST/$rel"
done
# templates：整目录覆盖（不删下游可能多出的模板，与 baseline orphan 策略一致）
mkdir -p "$DEST/docs/templates"; cp -R "$SRC/docs/templates/." "$DEST/docs/templates/"

# 5. 项目专属：仅首次铺，已存在不碰。
[ -f "$DEST/docs/baseline/project-context.md" ] || \
  cp "$SRC/docs/baseline/project-context.template.md" "$DEST/docs/baseline/project-context.md"
[ -d "$DEST/docs/knowledge" ] || cp -R "$SRC/docs/knowledge/." "$DEST/docs/knowledge/"

# 6. 版本标记：记录本次同步自真源哪个 commit。
ver=$(git -C "$SRC" rev-parse --short HEAD 2>/dev/null || echo unknown)
echo "synced-from: agent-workflow@$ver ($(date +%F))" > "$DEST/.workflow-version"

# 7. 同步后自检。
fail=0
grep -q "SOURCE-REPO-ONLY" "$DEST/CLAUDE.md" "$DEST/AGENTS.md" && { echo "自检失败：入口残留 SOURCE-REPO-ONLY。" >&2; fail=1; }
diff -q "$DEST/CLAUDE.md" "$DEST/AGENTS.md" >/dev/null || { echo "自检失败：双入口不一致。" >&2; fail=1; }
[ -f "$DEST/docs/baseline/project-context.md" ] || { echo "自检失败：project-context.md 缺失。" >&2; fail=1; }
[ -f "$DEST/docs/baseline/cross-project-collaboration.md" ] || { echo "自检失败：跨项目联动文件缺失。" >&2; fail=1; }
# 7b. 回流护栏（BCR-008）：sync 只应覆盖框架白名单文件；若本次动了白名单外文件（README / 项目专属 / 源码）则拦下，防「回流误带」。
if git -C "$DEST" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  offending=$(git -C "$DEST" status --short | cut -c4- | grep -Ev '^(CLAUDE\.md$|AGENTS\.md$|docs/baseline/|docs/templates/|docs/knowledge/|\.workflow-version$)' || true)
  if [ -n "$offending" ]; then
    echo "自检失败：sync 动了框架白名单外的文件（不应发生，疑似误带，请核查）：" >&2
    echo "$offending" | sed 's/^/     /' >&2
    fail=1
  fi
fi
[ "$fail" -eq 0 ] || { echo "同步自检未通过。" >&2; exit 1; }

echo "✅ $MODE 完成 → $DEST （版本 $ver）"
[ "$NEW" = 1 ] && echo "   下一步：填 project-context.md（含 coordination_root 启用跨项目联动）；缺 docs/progress/INDEX.md 时执行 Bootstrap。"
exit 0
