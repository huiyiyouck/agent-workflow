#!/usr/bin/env sh
# BCR-015 L1 门禁 G1/G2/G4/G5（G3 = 项目自身测试命令，由 workflow 单独执行）。v2（R3 落地复核修复）
# 用法：l1-gates.sh <项目根目录>；L1_REPLAY=1 时忽略时代标记做只读回放（验证解析逻辑，不用于执法）。
# 输出纪律：静默通过、只报失败；失败信息三段式「哪条规则 + 为什么错 + 该怎么改」。
#
# 适用范围：只校验含「## 阶段执行记录」小节的迭代记录（U1 模板起）；历史记录跳过（BCR-011：执法不回溯）。
# 已报备的收窄面（R3 后仍保留，随 fixture 飞轮收紧）：G4 允许 R3 处于 Review中 的过渡态；
# 畸形表格行（列数不足）静默放过；INDEX 一致性不由 CI 承接（属人工核对项，见 mechanisms §3）。
set -u
ROOT="${1:-.}"
ITER_DIR="$ROOT/docs/progress/iterations"
FAIL=0
[ -d "$ITER_DIR" ] || exit 0

fail() { printf '❌ [%s] %s\n   为什么错：%s\n   该怎么改：%s\n' "$1" "$2" "$3" "$4" >&2; FAIL=1; }
after_colon() { awk '{i=index($0,"："); print (i? substr($0,i+3) : "")}'; }

for rec in "$ITER_DIR"/v*.md; do
  [ -f "$rec" ] || continue
  base=$(basename "$rec")
  case "$base" in *-*) continue ;; esac
  if [ "${L1_REPLAY:-0}" != 1 ]; then
    grep -q '^## 阶段执行记录' "$rec" || continue
  fi
  ver="${base%.md}"

  # ---- 关闭态判定（G2 严格核对与 Change Note 终态检查的触发条件）----
  # escA 加固：并取「关闭结论主张可关闭」与「最终状态=已完成/已关闭」——删掉关闭结论行直接写终态，同样是关闭主张。
  closing=0
  concl_line=$(grep -E '^- 关闭结论' "$rec" | head -1 || true)
  concl_stripped=$(printf '%s' "$concl_line" | sed 's/不可关闭//g')
  case "$concl_stripped" in *可关闭*|*有条件关闭*) closing=1 ;; esac
  final_line=$(grep -E '^- 最终状态' "$rec" | head -1 || true)
  fv=$(printf '%s' "$final_line" | after_colon)
  fvt=$(printf '%s' "$fv" | sed 's/^[ 　—-]*//; s/[ 　—-]*$//')
  if [ "$fvt" != "进行中 / 已完成 / 已关闭 / 阻塞" ]; then   # 模板占位枚举跳过
    case "$fv" in *已完成*|*已关闭*) closing=1 ;; esac
  fi
  era=0; grep -q '^## 阶段执行记录' "$rec" && era=1

  # ---- G1 状态一致性：阶段门禁 / 部署检查状态词封闭枚举 ----
  g1=$(awk '
    /^### (PRD|设计|实现)( )?阶段/ { mode="stage"; next }
    /^### 部署就绪检查/            { mode="deploy"; next }
    /^###? /                       { mode="" }
    mode=="stage" && /^\|/ && $0 !~ /^\|[-— :|]+\|?$/ && $0 !~ /轮次/ {
      n=split($0, c, "|"); v=c[n-1]; gsub(/ /,"",v); gsub(/\*/,"",v); gsub("✅","",v); gsub("❌","",v); gsub("⚠️","",v);
      if (v!="" && v !~ /^(待Review|Review中|修改中|已定稿|阻塞|已跳过)$/) printf "阶段状态「%s」\n", v
    }
    mode=="deploy" && /^\|/ && $0 !~ /^\|[-— :|]+\|?$/ && $0 !~ /目标环境/ {
      split($0, c, "|"); v=c[2]; gsub(/ /,"",v); gsub(/\*/,"",v); gsub("✅","",v); gsub("❌","",v); gsub("⚠️","",v);
      if (v!="" && v !~ /^(待检查|检查中|通过|阻塞|已跳过)$/) printf "部署检查状态「%s」\n", v
    }
  ' "$rec")
  if [ -n "$g1" ]; then
    echo "$g1" | while IFS= read -r line; do
      fail G1 "$base" "$line 不在封闭词表内（BCR-011 状态枚举）" \
        "阶段门禁只用：待Review/Review中/修改中/已定稿/阻塞/已跳过；部署检查只用：待检查/检查中/通过/阻塞/已跳过"
    done
    FAIL=1
  fi

  # ---- G4 Review 轮次完整性：已定稿须含通过；禁 R4+；R3 不得停在修改中 ----
  g4=$(awk '
    /^### (PRD|设计|实现)( )?阶段/ { mode="stage"; next }
    /^###? /                       { mode="" }
    mode=="stage" && /^\|/ && $0 !~ /^\|[-— :|]+\|?$/ && $0 !~ /轮次/ {
      n=split($0, c, "|"); v=c[n-1]; gsub(/ /,"",v); gsub(/\*/,"",v); gsub("✅","",v); gsub("❌","",v); gsub("⚠️","",v);
      r=c[2]; gsub(/ /,"",r); gsub(/\*/,"",r);
      if (v=="已定稿" && $0 !~ /通过/) printf "DING|第%d行\n", NR
      if (r ~ /^R([4-9]|[1-9][0-9])/) printf "R4|第%d行（%s）\n", NR, r
      if (r ~ /^R3/ && v=="修改中") printf "R3M|第%d行\n", NR
    }
  ' "$rec")
  if [ -n "$g4" ]; then
    echo "$g4" | while IFS='|' read -r kind loc; do
      case "$kind" in
        DING) fail G4 "$base:$loc" "阶段状态为「已定稿」但该轮次行没有任何「通过」的 Review 结果" \
                "定稿条件 = 本轮指定 Review 方全部通过；补 Review 结果，或把状态改回 Review中/修改中" ;;
        R4)   fail G4 "$base:$loc" "出现 R4 及以上轮次——R3 仍未通过时必须升级「阻塞」交 Owner 决策，不进 R4" \
                "回看 standard-iteration-quick §Review 轮次：把该阶段置「阻塞」，由 Owner 裁决（接受现状/修改需求/关闭迭代）" ;;
        R3M)  fail G4 "$base:$loc" "R3 轮次状态为「修改中」——连续两轮未过后再改属变相进入 R4" \
                "R3 未过应置「阻塞」升级 Owner，不得回到修改中继续循环" ;;
      esac
    done
    FAIL=1
  fi

  # ---- G5 打回闸（R3-G1 加固：整行剥模板括注 + 首个全角冒号取值 + 占位精确匹配） ----
  owner_line=$(grep -E '^- Owner 验收' "$rec" | head -1 || true)
  if [ -n "$owner_line" ]; then
    ov=$(printf '%s' "$owner_line" | sed 's/（真源记录，未验收 \/ 打回则不得关闭）//' | after_colon)
    ovt=$(printf '%s' "$ov" | sed 's/^[ 　—-]*//; s/[ 　—-]*$//')
    if [ "$ovt" != "未验收 / 通过 / 打回 / 有条件通过" ]; then
      case "$ov" in
        *打回*)
          final_val=$(grep -E '^- 最终状态' "$rec" | head -1 | after_colon || true)
          concl_val=$(printf '%s' "$concl_line" | after_colon | sed 's/不可关闭//g')
          case "$final_val" in *已完成*|*已关闭*)
            fail G5 "$base" "Owner 验收为「打回」但迭代最终状态仍是完成/关闭——打回后静默重放行是免确认最危险的失效模式" \
              "打回后禁止任何阶段状态前进：修复后由 Owner 出具新的验收结论，才能继续推进或关闭" ;;
          esac
          case "$concl_val" in *可关闭*|*有条件关闭*)
            fail G5 "$base" "Owner 验收为「打回」但关闭结论仍主张可关闭" \
              "打回未解除前关闭结论只能是「不可关闭」；出现新的验收结论后再改" ;;
          esac ;;
      esac
    fi
  fi

  # ---- G2a 验收可执行化：PRD 验收标准表「验证方式」不得留空 ----
  prd="$ITER_DIR/$ver-prd.md"
  if [ -f "$prd" ] && grep -q '验证方式' "$prd"; then
    g2a=$(awk '
      /^## 3\. 验收标准/ { m=1; next }
      /^## /             { m=0 }
      m && /^\|/ && $0 !~ /^\|[-— :|]+\|?$/ && $0 !~ /验证方式/ {
        n=split($0, c, "|"); if (n>=5) { v=c[4]; gsub(/ /,"",v); if (v=="") printf "第%d行\n", NR }
      }
    ' "$prd")
    if [ -n "$g2a" ]; then
      echo "$g2a" | while IFS= read -r line; do
        fail G2 "$(basename "$prd"):$line" "验收标准的「验证方式」列留空——标不出验证方式的验收标准本身就是 PRD 缺陷" \
          "能自动验证的填命令/测试入口；确实无法自动验证的显式标「人工抽检」并写原因"
      done
      FAIL=1
    fi
  fi

  # ---- G2b 验收证据链：执行结果不得留空；关闭态下取值封闭枚举 + 与 PRD 逐行对应（R3-B1） ----
  # escB 加固：L1 时代记录主张关闭时，自测报告 / 验收证据链整体缺失是最重违规形态，直接 fail。
  rpt="$ITER_DIR/$ver-test-report.md"
  if [ "$closing" = 1 ] && [ "$era" = 1 ]; then
    if [ ! -f "$rpt" ] || ! grep -q '^## 验收证据链' "$rpt"; then
      fail G2 "$base" "迭代主张关闭（关闭结论或最终状态），但自测报告或其「验收证据链」小节整体缺失——整份证据链缺失比缺行更重，不得静默流到关闭" \
        "从 docs/templates/test-report.md 创建 $ver-test-report.md 并逐条填验收证据链；未验证则不得主张关闭"
    fi
  fi
  if [ -f "$rpt" ] && grep -q '^## 验收证据链' "$rpt"; then
    g2b=$(awk -v closing="$closing" '
      /^## 验收证据链/ { m=1; next }
      /^## /           { m=0 }
      m && /^\|/ && $0 !~ /^\|[-— :|]+\|?$/ && $0 !~ /验证入口/ {
        n=split($0, c, "|");
        if (n>=5) {
          v=c[4]; gsub(/ /,"",v); gsub(/\*/,"",v); gsub("✅","",v); gsub("❌","",v);
          if (v=="") printf "EMPTY|第%d行\n", NR
          else if (closing==1 && v !~ /^(绿|人工抽检)$/) printf "ENUM|第%d行（%s）\n", NR, v
        }
      }
    ' "$rpt")
    if [ -n "$g2b" ]; then
      echo "$g2b" | while IFS='|' read -r kind loc; do
        case "$kind" in
          EMPTY) fail G2 "$(basename "$rpt"):$loc" "验收证据链的「执行结果」列留空——跑不过的不许标绿，没跑的不许留白" \
                   "逐条填：绿（附证据）/ 红（不得标绿）/ 人工抽检（Owner 验收时抽查）" ;;
          ENUM)  fail G2 "$(basename "$rpt"):$loc" "迭代主张可关闭，但证据链存在非「绿/人工抽检」的执行结果——红状态不得流到关闭" \
                   "修复后把结果转绿并附证据，或按缺陷严重度处置（阻塞先修/延期记原因），关闭结论改「不可关闭」直至收敛" ;;
        esac
      done
      FAIL=1
    fi
    # 关闭态：PRD 每条验收标准须在证据链中有对应行（按 # 编号）
    if [ "$closing" = 1 ] && [ -f "$prd" ] && grep -q '验证方式' "$prd"; then
      prd_ids=$(awk '/^## 3\. 验收标准/{m=1;next} /^## /{m=0} m&&/^\|/&&$0!~/^\|[-— :|]+\|?$/&&$0!~/验证方式/{split($0,c,"|"); id=c[2]; gsub(/ /,"",id); if(id!="") print id}' "$prd")
      rpt_ids=$(awk '/^## 验收证据链/{m=1;next} /^## /{m=0} m&&/^\|/&&$0!~/^\|[-— :|]+\|?$/&&$0!~/验证入口/{split($0,c,"|"); id=c[2]; gsub(/ /,"",id); if(id!="") print id}' "$rpt")
      for id in $prd_ids; do
        printf '%s\n' "$rpt_ids" | grep -qx "$id" || \
          fail G2 "$base" "PRD 验收标准 #$id 在自测报告「验收证据链」表中没有对应行——缺行的验收等于没验收" \
            "在 $(basename "$rpt") 证据链表补 #$id 行（验证入口 + 执行结果 + 证据）；未验证则关闭结论不得主张可关闭"
      done
    fi
  fi

  # ---- Change Note 终态（R3-G2）：关闭态下 Change Notes 表各行归档状态须为终态 ----
  if [ "$closing" = 1 ]; then
    cn=$(awk '
      /^## Change Notes/ { m=1; next }
      /^## /             { m=0 }
      m && /^\|/ && $0 !~ /^\|[-— :|]+\|?$/ && $0 !~ /变更级别/ {
        n=split($0, c, "|"); s=c[n-1]; gsub(/ /,"",s); gsub(/\*/,"",s); gsub("✅","",s);
        first=c[2]; gsub(/ /,"",first);
        if (first!="" && s !~ /已归档|已废弃|转入/) printf "第%d行（%s）\n", NR, (s==""?"空":s)
      }
    ' "$rec")
    if [ -n "$cn" ]; then
      echo "$cn" | while IFS= read -r line; do
        fail G2 "$base:$line" "迭代主张可关闭，但 Change Note 归档状态不是终态（已归档/已废弃/转入下一迭代）" \
          "按 mechanisms §Change Note 收尾流转处理后再关闭；未处理完则关闭结论改「不可关闭」"
      done
      FAIL=1
    fi
  fi
done

exit $FAIL
