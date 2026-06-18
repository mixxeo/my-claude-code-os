#!/bin/bash
# Stop hook: 이번 달 회고 진행률을 캐시 파일로 저장한다.
#
# 회고 루프가 완료되면(=Claude가 응답을 마치면) 매번 실행돼서
# retrospectives/ 폴더를 스캔하고 .claude/retro-progress.json을 갱신한다.
# statusLine은 이 캐시를 읽어 상단에 한 줄로 표시한다.

set -euo pipefail

REPO_DIR="/Users/mixxeo/my-claude-code-os"
CACHE_FILE="$REPO_DIR/.claude/retro-progress.json"

[ -d "$REPO_DIR/retrospectives" ] || exit 0

NOW_YM=$(date +%Y-%m)
NOW_DAY=$(date +%-d)

MONTHLY_FILE="$REPO_DIR/retrospectives/monthly/${NOW_YM}.md"
if [ -f "$MONTHLY_FILE" ]; then
  MONTHLY_DONE=1
else
  MONTHLY_DONE=0
fi

WEEKLY_DONE=$(find "$REPO_DIR/retrospectives/weekly" -maxdepth 1 -type f -name "${NOW_YM}-*.md" 2>/dev/null | wc -l | tr -d ' ')

# 이번 달의 현재 주차 (1일~7일=1주, 8~14일=2주, …)
WEEKLY_EXPECTED=$(( (NOW_DAY + 6) / 7 ))

UPDATED_AT=$(date '+%Y-%m-%d %H:%M:%S')
cat > "$CACHE_FILE" <<EOF
{"period":"$NOW_YM","monthly_done":$MONTHLY_DONE,"weekly_done":$WEEKLY_DONE,"weekly_expected":$WEEKLY_EXPECTED,"updated_at":"$UPDATED_AT"}
EOF
