# .gitignore 데모

> **`.gitignore`란?** Git이 **추적하지 않아야 할 파일·디렉토리**의 패턴을 적어두는 단순 텍스트 파일입니다. 레포 어느 위치에든 둘 수 있고, 한 줄에 한 패턴씩 적습니다.

`git add .` 한 줄로 의도하지 않게 비밀 키나 빌드 결과물이 같이 올라가는 사고를 막아주는, **모든 Git 레포의 기본 안전장치**입니다.

## 이 데모로 배울 것

1. **왜 필요한가** — `.gitignore` 없이 `git add .` 했을 때 어떤 일이 벌어지는지
2. **패턴 문법** — 와일드카드, 디렉토리, 위치 고정(`/`), 부정(`!`)
3. **자주 빠지는 함정** — 이미 추적 중인 파일은 `.gitignore`에 적어도 무시되지 않는다

## 시연용 예제

[`example/`](example/) 디렉토리는 "공유하면 안 되는 파일 하나"를 일부러 섞어둔 작은 놀이터입니다.

```
example/
├── main.py        ← 진짜 코드 (커밋해야 함)
├── README.md      ← 문서 (커밋해야 함)
├── trash.py       ← 잡동사니 (커밋 금지)
└── .gitignore     ← trash.py 를 무시하도록 작성됨
```

[example/.gitignore](example/.gitignore)는 딱 한 줄입니다:

```gitignore
/trash.py
```

앞의 `/`는 "이 `.gitignore`가 놓인 디렉토리의 `trash.py` 하나"로 위치를 못박는다는 뜻입니다.

## 발표 흐름 (7~8분 분량)

| 시간 | 내용 |
|---|---|
| 0:00 | "여러분이 실수로 비밀번호가 든 파일을 GitHub에 올리면 어떻게 될까요?" (실제 사례 한두 줄 소개) |
| 0:30 | [example/](example/) 디렉토리 열어서 파일 구성 보여주기 |
| 1:30 | **무시 여부 확인** — `git check-ignore -v trash.py` 로 `trash.py`가 규칙에 잡히는 걸 시연 |
| 3:00 | [example/.gitignore](example/.gitignore)의 `/trash.py`를 읽으며 패턴 문법 설명 (`/`의 의미) |
| 4:30 | **함정 시연** — 이미 추적 중인 파일은 무시되지 않음 (`git rm --cached` 필요) |
| 6:30 | 글로벌 `.gitignore`(`~/.config/git/ignore`) 짧게 언급하며 마무리 |

## 핵심 포인트 (입문자가 가져갔으면 하는 것)

- **`.gitignore`는 추적 시작을 막을 뿐**, 이미 추적 중인 파일에는 효력이 없습니다. 실수로 올라간 비밀은 `git rm --cached <파일>` 후 다시 커밋해야 합니다 (그리고 키는 즉시 폐기·재발급).
- **패턴 앞의 `/`는 위치를 고정합니다.** `trash.py`는 하위 디렉토리의 같은 이름까지 모두 무시하지만, `/trash.py`는 `.gitignore` 바로 옆 파일 하나만 무시합니다.
- **패턴은 위에서 아래로 읽힙니다.** 나중 줄이 앞 줄을 덮어쓸 수 있고, `!`로 부정해서 "이건 예외로 추적해"라고 지정할 수 있습니다.
- **레포마다 `.gitignore`를 새로 짤 필요 없습니다.** [github/gitignore](https://github.com/github/gitignore)에 언어·프레임워크별 템플릿이 모여 있습니다. 이 레포 루트의 [.gitignore](../../.gitignore)가 바로 그 Python 템플릿입니다.
- **내 환경 파일은 글로벌에.** `.DS_Store`, `.idea/`, `.vscode/` 같은 건 레포 `.gitignore`가 아니라 `~/.config/git/ignore`에 한 번만 적어두면 모든 레포에서 무시됩니다.

## 현실에서 자주 무시하는 것들

이 데모는 파일 하나(`trash.py`)로 단순하게 보여주지만, 실제 프로젝트에서는 보통 이런 것들을 무시합니다:

| 대상 | 왜 무시하나 |
|---|---|
| `.env` | API 키·비밀번호. 올라가면 봇이 몇 초 만에 긁어갑니다 |
| `*.log` | 실행할 때마다 새로 생기는 로그 |
| `build/`, `dist/` | 소스에서 다시 만들 수 있는 빌드 결과물 |
| `node_modules/` | 수십~수백 MB짜리 의존성. `package.json`만 있으면 복원 가능 |
| `__pycache__/` | 파이썬 바이트코드 캐시 |

## 시연 시 권장 명령어

```bash
# example 디렉토리에서 실행
cd demos/gitignore/example

# 1) trash.py 가 무시되는지, 어떤 규칙에 잡히는지 확인
git check-ignore -v trash.py

# 2) 함정 시연 — 이미 추적 중인 파일 케이스
#    (시연용으로 임시 git 레포를 만들고 보여주기)
git init demo-trap && cd demo-trap
echo "secret" > config.txt
git add config.txt && git commit -m "first"
echo "config.txt" > .gitignore
git status            # ← config.txt가 여전히 추적됨!
git rm --cached config.txt
git status            # ← 이제 무시됨
```

## 참고: Claude Code와 `.gitignore`의 관계

Claude Code는 파일을 읽고 쓸 때 `.gitignore`를 자동으로 존중합니다. 즉 `.env` 같은 파일이 `.gitignore`에 있으면 Claude가 실수로 그 내용을 읽어와 컨텍스트에 흘리는 위험이 줄어듭니다. **`.gitignore`는 Git의 안전장치이자 Claude Code의 안전장치이기도 합니다.**
