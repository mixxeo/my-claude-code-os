#!/bin/bash
# PreToolUse hook: 과거 회고 파일 보호 가드
#
# retrospectives/ 하위 파일 중, 파일명에 포함된 연-월(YYYY-MM)이
# 현재 연-월보다 과거이면 Edit / Write / MultiEdit / NotebookEdit 호출을 차단한다.
# (회고는 "그 시점의 기록"이라 마감 후 불변으로 둔다는 원칙)

set -euo pipefail

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')

case "$TOOL_NAME" in
  Edit|Write|MultiEdit|NotebookEdit) ;;
  *) exit 0 ;;
esac

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')

case "$FILE_PATH" in
  */retrospectives/*) ;;
  *) exit 0 ;;
esac

BASENAME=$(basename "$FILE_PATH")
CURRENT_YM=$(date +%Y-%m)

if [[ "$BASENAME" =~ ([0-9]{4}-[0-9]{2}) ]]; then
  FILE_YM="${BASH_REMATCH[1]}"
  if [[ "$FILE_YM" < "$CURRENT_YM" ]]; then
    cat >&2 <<EOF
[과거 회고 보호 가드] 이 파일은 수정할 수 없습니다.
  파일: $FILE_PATH
  파일의 연-월: $FILE_YM (현재: $CURRENT_YM)

회고는 "그 시점의 기록"이라 한 번 마감되면 불변으로 유지합니다.
정말 수정이 필요하다면:
  1) 보완 회고를 새 파일로 작성하거나
  2) .claude/settings.json의 PreToolUse 훅을 일시적으로 비활성화하세요.
EOF
    exit 2
  fi
fi

exit 0
