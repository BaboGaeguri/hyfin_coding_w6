# .gitignore 연습용 놀이터

이 디렉토리는 **커밋해야 하는 파일**과 **공유하면 안 되는 파일**을 일부러 섞어둔 예제입니다.

## 파일 구성

| 파일 | 커밋? | 이유 |
|---|---|---|
| `main.py` | OK | 진짜 소스 코드 |
| `README.md` | OK | 문서 |
| `.gitignore` | OK | 무시 규칙 자체는 공유해야 함 |
| `trash.py` | 금지 | 공유할 필요 없는 잡동사니 파일 |

## .gitignore 내용

```gitignore
/trash.py
```

딱 한 줄입니다. 앞의 `/`는 "이 `.gitignore`가 놓인 디렉토리의 `trash.py`"로 **위치를 고정**한다는 뜻입니다. `/` 없이 `trash.py`라고만 쓰면 하위 디렉토리의 같은 이름 파일까지 전부 무시됩니다.

## 한번 직접 해보기

```bash
cd demos/gitignore/example

# trash.py 가 무시되는지, 어떤 규칙에 잡히는지 확인
git check-ignore -v trash.py
# → .gitignore:2:/trash.py    trash.py

# main.py 는? (출력이 없으면 = 무시 안 됨, 정상 추적)
git check-ignore -v main.py
```

## 직접 실험해볼 거리

- `.gitignore`의 `/trash.py`를 `trash.py`로 바꿔보고 차이를 비교해보기
- 새 파일 `trash2.py`를 만들고 `trash*.py` 같은 와일드카드 패턴으로 한 번에 무시해보기
- `trash.py`를 먼저 `git add` 한 뒤 `.gitignore`에 적어보고 — 무시가 안 되는 **함정**을 직접 겪어보기
