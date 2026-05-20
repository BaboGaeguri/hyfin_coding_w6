#!/usr/bin/env bash
# PostToolUse Hook — Claude가 Edit/Write로 파일을 수정할 때마다 자동 실행됩니다.
# AI의 판단이 아니라, 이벤트가 발생하면 무조건 이 스크립트가 돕니다.

root="${CLAUDE_PROJECT_DIR:-$(pwd)}"
log="$root/demos/claude/03_hook/edit-log.txt"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Claude가 파일을 수정함 → Hook 자동 실행됨" >> "$log"
exit 0
