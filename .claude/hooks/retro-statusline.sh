#!/bin/bash
# statusLine: 이번 달 회고 진행률을 한 줄로 출력한다.
#
# Claude Code는 매 렌더링마다 이 스크립트를 호출하므로 빠르게 끝나야 한다.
# 디스크 스캔은 Stop hook이 미리 해두고, 여기서는 캐시 JSON만 읽는다.

set -euo pipefail

CACHE_FILE="/Users/mixxeo/my-claude-code-os/.claude/retro-progress.json"

# statusLine 입력 JSON(세션 정보)은 사용하지 않으므로 그대로 둔다.

if [ ! -f "$CACHE_FILE" ]; then
  echo "[retro] (대기 중 — 다음 턴 종료 후 갱신됩니다)"
  exit 0
fi

read -r PERIOD MD WD WE < <(jq -r '[.period, .monthly_done, .weekly_done, .weekly_expected] | @tsv' "$CACHE_FILE")

if [ "$MD" = "1" ]; then
  MSTR="done"
else
  MSTR="todo"
fi

echo "[retro $PERIOD] monthly: $MSTR | weekly: $WD/$WE"
