#!/usr/bin/env bash
# PreToolUse Hook — Claude가 Bash 명령을 실행하기 "직전"에 자동 실행됩니다.
# 실행하려는 명령 정보가 표준 입력(stdin)으로 JSON 형태로 들어옵니다.
# exit 2 로 끝내면 Claude Code는 그 명령의 실행을 차단합니다.

input=$(cat)

if echo "$input" | grep -qE 'rm[[:space:]]+-rf'; then
  echo "[Hook 차단] 'rm -rf' 패턴이 포함된 명령은 이 데모 레포에서 금지되어 있습니다." >&2
  exit 2
fi

exit 0
