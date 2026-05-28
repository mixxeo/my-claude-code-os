#!/bin/bash
# UserPromptSubmit hook: 스킬 호출 감지 및 시작 시간 기록

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""')

# /skill-name 패턴으로 시작하는 경우만 처리
SKILL=$(echo "$PROMPT" | grep -oE '^[[:space:]]*/[a-zA-Z][a-zA-Z0-9_-]*' | tr -d ' ')

if [ -n "$SKILL" ]; then
  START_TIME=$(python3 -c "import time; print(int(time.time() * 1000))")
  TMP_FILE="/tmp/claude-skill-tracking.tmp"
  echo "${START_TIME}|${SKILL}" > "$TMP_FILE"
fi
