#!/usr/bin/env bash
# 把工作流从真源仓库安装到下游项目目录，产出一份干净副本。
#
# 仅在真源仓库内运行。产出物：
#   - 入口文件 CLAUDE.md / AGENTS.md，剥离 SOURCE-REPO-ONLY 块；
#   - docs/baseline/、docs/templates/ 全量；
#   - docs/knowledge/ 仅空骨架（INDEX 索引 + 空目录 .gitkeep）；
#   - docs/baseline/project-context.md 占位（从模板复制，待下游填写）。
# 不带真源专属文件：docs/ROADMAP.md、docs/regression-cases.md、scripts/、docs/progress/。
#
# 退出码：0 成功；1 安全/自检失败；2 用法错误。
set -euo pipefail

SRC="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${1:-}"

# 1. 参数与目标目录安全：必须不存在或为空，否则拒绝（不覆盖用户文件）。
if [ -z "$DEST" ]; then
  echo "用法：scripts/install-downstream.sh <目标目录>" >&2
  exit 2
fi
if [ -e "$DEST" ] && [ -n "$(ls -A "$DEST" 2>/dev/null)" ]; then
  echo "错误：目标目录 $DEST 非空，拒绝产出（避免覆盖现有文件）。请指定不存在或空的目录。" >&2
  exit 1
fi

# 2. 安装前关卡：双入口必须逐字一致。
if ! diff -q "$SRC/CLAUDE.md" "$SRC/AGENTS.md" >/dev/null; then
  echo "错误：CLAUDE.md 与 AGENTS.md 不一致，拒绝安装。请先对齐双入口（diff CLAUDE.md AGENTS.md）。" >&2
  exit 1
fi

# 3. knowledge 自检：不得含真源知识条目（防真源知识泄漏）。
#    条目以独立 .md 沉淀在 docs/knowledge/{分类}/ 下；INDEX.md 只是索引。
if find "$SRC/docs/knowledge" -name '*.md' ! -name 'INDEX.md' | grep -q .; then
  echo "错误：docs/knowledge/ 含真源知识条目（INDEX.md 以外的 .md），拒绝安装。" >&2
  exit 1
fi
if grep -qE '^[[:space:]]*[-*]|\]\(' "$SRC/docs/knowledge/INDEX.md"; then
  echo "错误：docs/knowledge/INDEX.md 含疑似真源条目（列表项或链接），拒绝安装。" >&2
  exit 1
fi

# 4. 复制白名单。
strip_block() {  # 剥离 SOURCE-REPO-ONLY 块并压缩多余空行
  sed '/↓↓↓ SOURCE-REPO-ONLY/,/↑↑↑ SOURCE-REPO-ONLY/d' "$1" | cat -s
}
mkdir -p "$DEST/docs"
strip_block "$SRC/CLAUDE.md" > "$DEST/CLAUDE.md"
strip_block "$SRC/AGENTS.md" > "$DEST/AGENTS.md"
cp -R "$SRC/docs/baseline"  "$DEST/docs/baseline"
cp -R "$SRC/docs/templates" "$DEST/docs/templates"
cp -R "$SRC/docs/knowledge" "$DEST/docs/knowledge"
cp "$SRC/docs/baseline/project-context.template.md" "$DEST/docs/baseline/project-context.md"

# 5. 产出后自检。
fail=0
if grep -q "SOURCE-REPO-ONLY" "$DEST/CLAUDE.md" "$DEST/AGENTS.md"; then
  echo "自检失败：产出入口仍含 SOURCE-REPO-ONLY 锚点。" >&2; fail=1
fi
if ! diff -q "$DEST/CLAUDE.md" "$DEST/AGENTS.md" >/dev/null; then
  echo "自检失败：产出双入口不一致。" >&2; fail=1
fi
for p in docs/ROADMAP.md docs/regression-cases.md scripts docs/progress; do
  if [ -e "$DEST/$p" ]; then
    echo "自检失败：产出副本含真源专属 $p。" >&2; fail=1
  fi
done
if [ ! -f "$DEST/docs/baseline/project-context.md" ]; then
  echo "自检失败：project-context.md 占位缺失。" >&2; fail=1
fi
[ "$fail" -eq 0 ] || { echo "安装自检未通过，请检查上方错误。" >&2; exit 1; }

echo "✅ 已安装到 $DEST"
echo "   下一步：填写 $DEST/docs/baseline/project-context.md；首次加载工作流时若无 docs/progress/INDEX.md，按提示执行 Bootstrap 初始化工作台。"
