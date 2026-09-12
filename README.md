# 생명을 살리는 걷기명상 — 안내 포스터

2026년 9월 27일(일) 서귀포시 회수동 WE호텔에서 열리는 자살예방 걷기명상 안내 포스터입니다.
A4 세로 한 장이며, 핸드폰에서는 읽기 좋은 크기로 다시 흘러갑니다.

- 공개 주소 — https://aassan9979-art.github.io/walking-meditation-poster/
- 저장소 — https://github.com/aassan9979-art/walking-meditation-poster

## 파일

| 파일 | 무엇 |
|---|---|
| `src/poster.html` | **고칠 파일.** 포스터 본체 (머리 껍데기 없음) |
| `index.html` | 공개되는 파일. `src/poster.html` 에서 자동으로 만들어짐 — 직접 고치지 마세요 |
| `og.png` | 링크 미리보기 카드 그림 (1200×630) |
| `map.jpg` | 뒷면에 들어가는 WE호텔 숲 안내도 |
| `apply/index.html` | 참가 신청 페이지. 구글폼을 끼워 넣은 것이라 따로 손으로 고칩니다 (build.ps1 대상 아님) |
| `tools/build.ps1` | `src/poster.html` → `index.html` |
| `tools/make-og.ps1` | `og.png` 다시 그리기 |
| `tools/worker.js` | 신청 내용을 받아 비공개 저장소에 기록하는 Cloudflare Worker |
| `tools/SETUP-신청받기.md` | 위 Worker 설치 방법 (한 번만 하면 됩니다) |
| `.nojekyll` | GitHub Pages 가 Jekyll 로 처리하지 않도록 (없으면 빌드 실패) |

## 고치고 올리는 순서

```powershell
# 1. 내용을 고친다
notepad src\poster.html

# 2. 공개용 파일을 다시 만든다
powershell -ExecutionPolicy Bypass -File tools\build.ps1

# 3. 올린다
git add -A
git commit -m "무엇을 고쳤는지"
git push
```

올린 뒤 **1~2분** 지나면 공개 주소에 반영됩니다. 브라우저에서 `Ctrl` + `F5` 로 새로고침해야
예전 화면이 안 나옵니다.

날짜·장소·문구를 바꿨다면 `tools/build.ps1` 안의 `$desc` 와 `tools/make-og.ps1` 의 글귀도
같이 고쳐야 링크 미리보기가 맞습니다. `make-og.ps1` 은 **UTF-8 BOM** 으로 저장해야 합니다
(BOM 이 없으면 Windows PowerShell 5.1 이 한글을 깨뜨립니다).

## 디자인 메모

색 (`src/poster.html` 위쪽 `:root`)

| 이름 | 값 | 쓰이는 곳 |
|---|---|---|
| `--paper` | `#F2F7EE` | 종이 바탕 |
| `--ink` | `#1C4733` | 본문 글자, 아래 띠 |
| `--ink-soft` | `#4E6E58` | 보조 설명 |
| `--jade` | `#2F7A4B` | 작은 이름표, 강조 글자 |
| `--leaf` | `#57A86B` | 맨 위 띠, 짧은 막대 |
| `--rule` | `#C9DAC7` | 가는 선 |

글꼴 — 제목은 **Noto Serif KR 900**, 본문 명조는 **Gowun Batang**, 정보는 **IBM Plex Sans KR**.
모두 Google Fonts 에서 불러옵니다.

숲 그림은 SVG 로 직접 그렸습니다. 산 능선 두 겹(`#D3E3D2`, `#B2CDB4`) 뒤로 나무 줄기를
먼 것·중간·가까운 것 세 가지 초록(`#96B79C`, `#5A8A64`, `#2E6340`)으로 나눠 깊이를 냈고,
아래쪽은 안개처럼 종이색으로 사라집니다.

## 크기

- A4 세로 = 794 × 1123 px (96dpi). 화면 폭이 794px 보다 넓으면 이 크기 그대로 보입니다.
- 화면 폭이 793px 이하면 축소하지 않고 핸드폰용 크기로 다시 흘러갑니다.
- 인쇄는 `Ctrl` + `P` → A4, 여백 없음.

포스터 높이가 A4 로 고정돼 있어서, **내용을 한 줄 늘리면 그만큼 어딘가를 줄여야 합니다.**
여유는 숲 그림 띠(`.forest`)가 흡수합니다 — 최소 높이가 110px 이고, 그보다 더 눌리면
아래쪽이 잘립니다.
