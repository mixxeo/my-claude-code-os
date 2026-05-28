#!/bin/bash
# Stop hook: 스킬 실행 시간 계산 및 로그 기록

TMP_FILE="/tmp/claude-skill-tracking.tmp"
LOG_FILE="/Users/mixxeo/my-claude-code-os/.claude/skill-usage.log"

[ -f "$TMP_FILE" ] || exit 0

ENTRY=$(cat "$TMP_FILE")
START_TIME=$(echo "$ENTRY" | cut -d'|' -f1)
SKILL=$(echo "$ENTRY" | cut -d'|' -f2)

[ -z "$SKILL" ] && exit 0

END_TIME=$(python3 -c "import time; print(int(time.time() * 1000))")
DURATION_MS=$((END_TIME - START_TIME))
DURATION_SEC=$(python3 -c "print(round($DURATION_MS / 1000, 1))")
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# JSONL 형식으로 로그 기록
echo "{\"timestamp\":\"$TIMESTAMP\",\"skill\":\"$SKILL\",\"duration_sec\":$DURATION_SEC}" >> "$LOG_FILE"

rm -f "$TMP_FILE"
