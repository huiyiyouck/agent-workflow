#!/usr/bin/env sh
# BCR-015 U2 · 门禁 fixture 回归：good 必须绿（退出 0），bad-* 必须被拦（退出非 0）。
# 静默通过、只报失败。
set -u
DIR="$(cd "$(dirname "$0")" && pwd)"
GATE="$DIR/l1-gates.sh"
FAIL=0

sh "$GATE" --selftest || FAIL=1

sh "$GATE" "$DIR/fixtures/good" >/dev/null 2>&1
[ $? -eq 0 ] || { echo "❌ fixture 回归：good 样本被误拦（应绿）" >&2; sh "$GATE" "$DIR/fixtures/good" >&2 || true; FAIL=1; }

for bad in "$DIR"/fixtures/bad-*; do
  [ -d "$bad" ] || continue
  if sh "$GATE" "$bad" >/dev/null 2>&1; then
    echo "❌ fixture 回归：$(basename "$bad") 未被拦下（应红）" >&2; FAIL=1
  fi
done

[ "$FAIL" -eq 0 ] && exit 0
exit 1
