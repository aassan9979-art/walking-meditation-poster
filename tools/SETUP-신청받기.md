# 신청 받기 설치 방법

신청 페이지는 GitHub Pages 에 있습니다. 그런데 GitHub Pages 는 **파일을 보여주기만** 하고
신청 내용을 받아 저장하지는 못합니다. 그래서 중간에서 받아 주는 작은 프로그램이 하나 필요하고,
그 역할을 **Cloudflare Worker** 가 합니다. 무료이고 카드 등록도 필요 없습니다.

```
신청 페이지 (GitHub Pages)
        ↓  신청 내용을 보냄
Cloudflare Worker
        ↓  한 줄 기록
비공개 저장소 walking-meditation-applications
        └ data/applications.csv
```

한 번만 해두면 됩니다. 20분쯤 걸립니다.

---

## 1단계 — GitHub 토큰 만들기

Worker 가 비공개 저장소에 글을 쓰려면 열쇠가 필요합니다.

1. https://github.com/settings/personal-access-tokens/new 로 갑니다
   (로그인된 상태여야 합니다)
2. **Token name** — `걷기명상 신청받기`
3. **Expiration** — `Custom` 으로 **2026년 10월 31일** 쯤 (행사 뒤까지)
4. **Repository access** — `Only select repositories` 를 고르고
   **`walking-meditation-applications`** 하나만 선택
5. **Permissions** → `Repository permissions` → **Contents** 를 **Read and write** 로
6. 맨 아래 **Generate token**
7. 화면에 나오는 `github_pat_...` 을 **복사**합니다

> ⚠️ 이 토큰은 비밀번호와 같습니다. **카톡이나 메일, 대화창에 붙여넣지 마세요.**
> 다음 단계에서 Cloudflare 에만 붙여넣습니다. 창을 닫으면 다시 볼 수 없으니
> 그 전에 3단계까지 진행하세요.

---

## 2단계 — Cloudflare 가입

1. https://dash.cloudflare.com/sign-up 에서 메일 주소로 가입합니다
2. 메일로 온 링크를 눌러 인증합니다

---

## 3단계 — Worker 만들기

1. 왼쪽 메뉴에서 **Compute (Workers)** → **Workers & Pages**
2. **Create** → **Start with Hello World!** → **Get started**
3. 이름을 `walking-meditation-apply` 로 하고 **Deploy**
4. 배포가 끝나면 **Edit code** (또는 **</> Edit code**) 를 누릅니다
5. 편집기에 있던 내용을 **모두 지우고**, 이 폴더의 **`worker.js`** 내용을
   **전부 복사해서 붙여넣습니다**
6. 오른쪽 위 **Deploy** 를 누릅니다

---

## 4단계 — 설정값 넣기

Worker 화면에서 **Settings** → **Variables and Secrets** 로 갑니다.

**Secret 로 넣을 것** (`Add` → Type 을 `Secret` 으로)

| 이름 | 값 |
|---|---|
| `GITHUB_TOKEN` | 1단계에서 복사한 `github_pat_...` |

**일반 변수로 넣을 것** (Type 을 `Text` 로)

| 이름 | 값 |
|---|---|
| `GITHUB_REPO` | `aassan9979-art/walking-meditation-applications` |
| `FILE_PATH` | `data/applications.csv` |
| `ALLOW_ORIGIN` | `https://aassan9979-art.github.io` |

넣은 뒤 **Deploy** 를 다시 눌러 주세요.

---

## 5단계 — 주소 알려주기

Worker 화면 위쪽에 이런 주소가 있습니다.

```
https://walking-meditation-apply.<계정이름>.workers.dev
```

이 주소를 알려주시면 신청 페이지에 연결하겠습니다.
(이 주소는 비밀이 아닙니다. 편하게 알려주셔도 됩니다.)

---

## 신청 내용 보는 법

https://github.com/aassan9979-art/walking-meditation-applications 의
`data/applications.csv` 를 열면 됩니다.
오른쪽 **Download raw file** 로 내려받으면 Excel 에서 바로 열립니다.

## 잘 안 될 때

- **신청 페이지에서 "잠시 뒤 다시" 라고 나옴** — 4단계 설정값 이름에 오타가 없는지,
  Deploy 를 다시 눌렀는지 확인하세요.
- **토큰이 만료됨** — 1단계를 다시 해서 새 토큰을 만들고,
  4단계의 `GITHUB_TOKEN` 값만 바꾸면 됩니다.
- 어느 쪽이든 신청자에게는 **전화 접수 안내**가 함께 보이므로 신청 길이 완전히 막히지는 않습니다.
