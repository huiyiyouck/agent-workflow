#!/usr/bin/env sh
# BCR-015 L1 门禁 G1/G2/G4/G5（G3 = 项目自身测试命令，由 workflow 单独执行）。
# 用法：l1-gates.sh <项目根目录>
# 输出纪律：静默通过、只报失败；失败信息三段式「哪条规则 + 为什么错 + 该怎么改」。
#
# 适用范围：只校验含「## 阶段执行记录」小节的迭代记录（U1 模板起的 L1 时代记录）；
# 历史记录整体跳过——BCR-011 判例：历史迭代记录不回改，仅约束新记录。
# v1 取向：宁薄勿误拦——判不准的不拦，边界靠 fixture 飞轮逐步收紧（失败案例回写）。
set -u
ROOT="${1:-.}"
ITER_DIR="$ROOT/docs/progress/iterations"
FAIL=0
[ -d "$ITER_DIR" ] || exit 0   # 未 Bootstrap 的仓不拦

fail() { # $1 门禁号 $2 位置 $3 为什么错 $4 该怎么改
  printf '❌ [%s] %s\n   为什么错：%s\n   该怎么改：%s\n' "$1" "$2" "$3" "$4" >&2
  FAIL=1
}

for rec in "$ITER_DIR"/v*.md; do
  [ -f "$rec" ] || continue
  base=$(basename "$rec")
  case "$base" in *-*) continue ;; esac            # 只看主迭代记录 vX.Y.md
  grep -q '^## 阶段执行记录' "$rec" || continue    # 历史记录跳过（L1 时代标记）
  ver="${base%.md}"

  # ---- G1 状态一致性：阶段门禁 / 部署检查状态词封闭枚举 ----
  g1=$(awk '
    /^### (PRD|设计|实现)( )?阶段/ { mode="stage"; next }
    /^### 部署就绪检查/            { mode="deploy"; next }
    /^###? /                       { mode="" }
    mode=="stage" && /^\|/ && $0 !~ /^\|[-— :|]+\|?$/ && $0 !~ /轮次/ {
      n=split($0, c, "|"); v=c[n-1]; gsub(/ /,"",v); gsub(/\*/,"",v); gsub("✅","",v); gsub("❌","",v); gsub("⚠️","",v);
      if (v!="" && v !~ /^(待Review|Review中|修改中|已定稿|阻塞|已跳过)$/)
        printf "阶段状态「%s」\n", v
    }
    mode=="deploy" && /^\|/ && $0 !~ /^\|[-— :|]+\|?$/ && $0 !~ /目标环境/ {
      split($0, c, "|"); v=c[2]; gsub(/ /,"",v); gsub(/\*/,"",v); gsub("✅","",v); gsub("❌","",v); gsub("⚠️","",v);
      if (v!="" && v !~ /^(待检查|检查中|通过|阻塞|已跳过)$/)
        printf "部署检查状态「%s」\n", v
    }
  ' "$rec")
  if [ -n "$g1" ]; then
    echo "$g1" | while IFS= read -r line; do
      fail G1 "$base" "$line 不在封闭词表内（BCR-011 状态枚举）" \
        "阶段门禁只用：待Review/Review中/修改中/已定稿/阻塞/已跳过；部署检查只用：待检查/检查中/通过/阻塞/已跳过"
    done
    FAIL=1
  fi

  # ---- G4 Review 轮次完整性：已定稿的行必须有通过的 Review 结果 ----
  g4=$(awk '
    /^### (PRD|设计|实现)( )?阶段/ { mode="stage"; next }
    /^###? /                       { mode="" }
    mode=="stage" && /^\|/ && $0 !~ /^\|[-— :|]+\|?$/ && $0 !~ /轮次/ {
      n=split($0, c, "|"); v=c[n-1]; gsub(/ /,"",v); gsub(/\*/,"",v); gsub("✅","",v); gsub("❌","",v); gsub("⚠️","",v);
      if (v=="已定稿" && $0 !~ /通过/) printf "第%d行\n", NR
    }
  ' "$rec")
  if [ -n "$g4" ]; then
    echo "$g4" | while IFS= read -r line; do
      fail G4 "$base:$line" "阶段状态为「已定稿」但该轮次行没有任何「通过」的 Review 结果" \
        "定稿条件 = 本轮指定 Review 方全部通过；把 Review 结果补进该行，或把状态改回 Review中/修改中"
    done
    FAIL=1
  fi

  # ---- G5 打回闸：Owner 验收为「打回」时禁止任何阶段前进/关闭 ----
  owner_line=$(grep -E '^- Owner 验收' "$rec" | head -1 || true)
  if [ -n "$owner_line" ]; then
    owner_val=$(printf '%s' "$owner_line" | awk -F'：' '{print $NF}')
    case "$owner_val" in
      *未验收*) : ;;   # 含「未验收」视为模板占位枚举，跳过
      *打回*)
        final_val=$(grep -E '^- 最终状态' "$rec" | head -1 | awk -F'：' '{print $NF}' || true)
        concl_val=$(grep -E '^- 关闭结论' "$rec" | head -1 | awk -F'：' '{print $NF}' | sed 's/不可关闭//g' || true)
        case "$final_val" in *已完成*|*已关闭*)
          fail G5 "$base" "Owner 验收为「打回」但迭代最终状态仍是完成/关闭——打回后静默重放行是免确认最危险的失效模式" \
            "打回后禁止任何阶段状态前进：修复后由 Owner 出具新的验收结论，才能继续推进或关闭" ;;
        esac
        case "$concl_val" in *可关闭*)
          fail G5 "$base" "Owner 验收为「打回」但关闭结论仍写「可关闭」" \
            "打回未解除前关闭结论只能是「不可关闭」；出现新的验收结论后再改" ;;
        esac ;;
    esac
  fi

  # ---- G2a 验收可执行化：PRD 验收标准表「验证方式」不得留空 ----
  prd="$ITER_DIR/$ver-prd.md"
  if [ -f "$prd" ] && grep -q '验证方式' "$prd"; then
    g2a=$(awk '
      /^## 3\. 验收标准/ { mode=1; next }
      /^## /             { mode=0 }
      mode && /^\|/ && $0 !~ /^\|[-— :|]+\|?$/ && $0 !~ /验证方式/ {
        n=split($0, c, "|");
        if (n>=5) { v=c[4]; gsub(/ /,"",v); if (v=="") printf "第%d行\n", NR }
      }
    ' "$prd")
    if [ -n "$g2a" ]; then
      echo "$g2a" | while IFS= read -r line; do
        fail G2 "$(basename "$prd"):$line" "验收标准的「验证方式」列留空——标不出验证方式的验收标准本身就是 PRD 缺陷" \
          "能自动验证的填命令/测试入口；确实无法自动验证的显式标「人工抽检」并写原因；界面类可用「构建+截图+人工抽检」组合"
      done
      FAIL=1
    fi
  fi

  # ---- G2b 验收证据链：自测报告证据链表「执行结果」不得留空 ----
  rpt="$ITER_DIR/$ver-test-report.md"
  if [ -f "$rpt" ] && grep -q '^## 验收证据链' "$rpt"; then
    g2b=$(awk '
      /^## 验收证据链/ { mode=1; next }
      /^## /           { mode=0 }
      mode && /^\|/ && $0 !~ /^\|[-— :|]+\|?$/ && $0 !~ /验证入口/ {
        n=split($0, c, "|");
        if (n>=5) { v=c[4]; gsub(/ /,"",v); if (v=="") printf "第%d行\n", NR }
      }
    ' "$rpt")
    if [ -n "$g2b" ]; then
      echo "$g2b" | while IFS= read -r line; do
        fail G2 "$(basename "$rpt"):$line" "验收证据链的「执行结果」列留空——跑不过的不许标绿，没跑的不许留白" \
          "逐条填：绿（附证据链接）/ 红（不得标绿，自测判定不得通过）/ 人工抽检（Owner 验收时抽查）"
      done
      FAIL=1
    fi
  fi
done

# 子 shell 内的 FAIL 变化传不出来：以是否产生过失败输出再兜底一次
exit $FAIL
