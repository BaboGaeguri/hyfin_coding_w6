# 03. Hook 데모

> **Hook이란?** 파일 수정·툴 호출 같은 **라이프사이클 이벤트**가 발생할 때, **AI의 판단을 거치지 않고 무조건** 실행되는 스크립트입니다. "이건 꼭 해야 해 / 이건 절대 안 돼"를 LLM에게 매번 부탁하는 대신, **규칙으로 박아두는** 장치입니다. Claude Code에 2025-09에 추가됐는데, 에이전트가 점점 자율적으로 움직이면서 "모델이 기억하든 말든 무조건 보장되는 안전장치"가 필요해졌기 때문입니다.

## Skill·Sub-agent와 무엇이 다른가

앞의 두 데모(Skill, Sub-agent)는 모두 **Claude가 "지금 이걸 호출할까?"를 판단**했습니다. Hook은 그 판단 자체를 건너뜁니다.

| | Skill / Sub-agent | Hook |
|---|---|---|
| 누가 실행을 결정하나 | Claude(AI)가 **판단**해서 호출 | 이벤트가 나면 **무조건** 실행 |
| 빠뜨릴 수 있나 | 있음 — 모델이 안 부를 수도 | 없음 — 결정론적 |
| 무엇으로 작성하나 | 한국어 마크다운 지침서 | 셸 스크립트 등 **실행 코드** |
| 정의 위치 | `.claude/skills/`, `.claude/agents/` | `.claude/settings.json` |

핵심 한 줄: **"부탁이 아니라 규칙."** Claude에게 "잊지 말고 해줘"라고 하면 잊을 수 있지만, Hook에는 "잊는다"는 개념 자체가 없습니다.

## Hook이 끼어들 수 있는 시점

[.claude/settings.json](../../../.claude/settings.json)의 `hooks` 섹션에 "어떤 이벤트에 어떤 스크립트를 걸지" 적습니다. 대표적인 이벤트:

- `PreToolUse` — Claude가 툴(파일 편집, Bash 등)을 실행하기 **직전**. 여기서 막을 수도 있음
- `PostToolUse` — 툴 실행이 **끝난 직후**
- `UserPromptSubmit` — 사용자가 메시지를 보낸 직후
- `Stop` — Claude가 응답을 마쳤을 때
- `SessionStart` — 세션이 시작될 때

이 데모에서는 그중 **`PreToolUse`와 `PostToolUse` 두 개**를 켜 둡니다.

## 직접 써볼 Hook 두 개

### A. PostToolUse — "파일을 고칠 때마다 자동 기록" (관찰형)

Claude가 `Edit`/`Write`로 파일을 수정할 때마다, [log-edit.sh](../../../scripts/hooks/log-edit.sh)가 자동으로 돌아 [edit-log.txt](edit-log.txt)에 한 줄을 추가합니다. 아무도 "기록해줘"라고 부탁하지 않아도 매번 일어납니다.

설정 위치: [.claude/settings.json](../../../.claude/settings.json)의 `hooks.PostToolUse`

### B. PreToolUse — "위험한 명령을 무조건 차단" (차단형)

Claude가 `Bash` 명령을 실행하기 **직전**, [guard-bash.sh](../../../scripts/hooks/guard-bash.sh)가 명령에 `rm -rf` 패턴이 있는지 검사합니다. 있으면 스크립트가 `exit 2`로 끝나고, Claude Code는 **그 명령을 실행하지 않습니다.** Claude가 아무리 "이 명령이 맞다"고 판단해도 소용없습니다 — Hook이 먼저 막습니다.

설정 위치: [.claude/settings.json](../../../.claude/settings.json)의 `hooks.PreToolUse`

> 데모를 단순하게 하려고 `rm -rf` 문자열만 거칠게 검사합니다. 실제 프로젝트에선 더 정교하게 짜지만, "Hook이 툴 실행을 막을 수 있다"는 점은 이 한 줄로 충분히 보입니다.

## 직접 해보기

> 준비: `.claude/settings.json`을 바꾼 직후에는 Claude Code가 설정을 다시 읽어야 Hook이 적용됩니다. 새 세션을 시작하거나, 설정 변경 안내가 뜨면 승인하세요. 사용한 스크립트는 `bash`·`grep`·`date`만 쓰므로 별도 설치가 필요 없습니다.

### 시도해보기 1 — PostToolUse: "매번 일어남" 확인하기

1. [edit-log.txt](edit-log.txt)를 편집기에 열어둡니다.
2. 메인 채팅창에 입력:
   > **"README.md 아무 곳에나 빈 줄 하나 추가해줘"**
3. Claude가 파일을 수정하자마자 `edit-log.txt`에 **새 줄이 자동으로 추가**되는 것을 확인.
4. 한 번 더 다른 파일을 수정시켜 보면 줄이 또 쌓입니다.
5. **여기서 알 수 있는 것:** "기록해줘"라고 한 적이 없습니다. Claude의 판단과 무관하게, 파일 수정 이벤트가 날 때마다 Hook이 결정론적으로 실행된 것입니다.

### 시도해보기 2 — PreToolUse: "무조건 막힘" 확인하기

1. 메인 채팅창에 입력:
   > **"`rm -rf demo-temp-folder` 명령을 실행해줘"**
   >
   > (`demo-temp-folder`는 존재하지 않는 폴더라 어차피 안전합니다.)
2. Claude가 Bash 명령을 실행하려는 순간, Hook이 `exit 2`로 막고 차단 메시지가 뜨는 것을 확인.
3. Claude는 명령이 막혔다는 사실을 전달받고 다른 길을 찾습니다.
4. **여기서 알 수 있는 것:** Claude가 그 명령을 실행하기로 "판단"했더라도 실행되지 않았습니다. 판단보다 Hook이 먼저입니다.

> 데모가 끝나면 `git checkout demos/claude/03_hook/edit-log.txt`로 로그를 초기화할 수 있습니다.

## 기억할 핵심 포인트

- **Hook = 결정론.** "AI가 부를 수도, 안 부를 수도 있는" Skill·Sub-agent와 달리, 이벤트가 나면 100% 실행됩니다.
- **`PreToolUse`는 막을 수 있다.** 스크립트가 `exit 2`로 끝나면 그 툴 호출이 차단됩니다 — 안전장치·정책 강제에 씁니다.
- **`PostToolUse`는 관찰·후처리.** 포매터 자동 실행, 로깅, 알림 등 "끝난 뒤 꼭 해야 할 일"에 씁니다.
- **Hook은 코드다.** 마크다운 지침서가 아니라 실제 실행되는 스크립트입니다. 그래서 모델 성능과 무관하게 똑같이 동작합니다.
- 정의는 전부 [.claude/settings.json](../../../.claude/settings.json) 한 곳에 모입니다.

## 다음 데모로 가는 다리

- Skill: 같은 컨텍스트, AI가 판단해 호출
- Sub-agent: 격리된 컨텍스트, AI가 판단해 위임
- Hook: **AI 판단 없이** 이벤트에 결정론적으로 끼어듦
- 다음에 볼 **Agent Team**은 다시 결이 다릅니다: 여러 Claude 세션이 단방향 위임을 넘어 **서로 메시지를 주고받으며 협력**합니다.
