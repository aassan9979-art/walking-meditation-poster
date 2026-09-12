# 생명을 살리는 걷기명상 — 안내 포스터와 참가신청

2026년 9월 27일(일) 서귀포시 회수동 WE호텔에서 열리는 자살예방 걷기명상.
오전 9시 · 10시 · 11시 · 낮 12시 · 오후 1시, **다섯 번, 각 한 시간**.

| | |
|---|---|
| 포스터 (앞면·뒷면) | https://aassan9979-art.github.io/walking-meditation-poster/ |
| 참가신청 | https://aassan9979-art.github.io/walking-meditation-poster/apply/ |
| 신청 명단 (비공개) | https://github.com/aassan9979-art/walking-meditation-applications |
| 신청현황 시트 | https://docs.google.com/spreadsheets/d/1ieStDseUpKnjmDWjx1tTjzqkOHdFXR05YckPiK3S2AE/edit |

문의 — 고경봉 010-2699-3001 · 최혜광 010-2575-8810

## 파일

| 파일 | 무엇 |
|---|---|
| `src/poster.html` | **포스터를 고칠 파일.** 앞면·뒷면 본체 |
| `index.html` | 공개되는 포스터. `src/poster.html` 에서 자동 생성 — 직접 고치지 마세요 |
| `apply/index.html` | **신청 페이지.** 자동 생성이 아니라 직접 고칩니다 |
| `og.png` | 링크 미리보기 카드 (1200×630) |
| `map.jpg` | 뒷면 WE호텔 숲 안내도 |
| `tools/build.ps1` | `src/poster.html` → `index.html` |
| `tools/make-og.ps1` | `og.png` 다시 그리기 |
| `tools/worker.js` | 신청을 받아 비공개 저장소에 기록하는 Cloudflare Worker |
| `tools/SETUP-신청받기.md` | 위 Worker 설치·재설정 방법 |
| `.nojekyll` | GitHub Pages 가 Jekyll 로 처리하지 않도록 (없으면 빌드 실패) |

## 고치고 올리는 순서

```powershell
notepad src\poster.html                                    # 포스터를 고친다
powershell -ExecutionPolicy Bypass -File tools\build.ps1   # 공개용 파일을 다시 만든다
git add -A ; git commit -m "무엇을 고쳤는지" ; git push
```

올린 뒤 **1~2분** 지나면 반영됩니다. 브라우저에서 `Ctrl` + `F5` 로 새로고침해야
예전 화면이 안 나옵니다.

신청 페이지(`apply/index.html`)는 `build.ps1` 대상이 아닙니다. 직접 고치고 바로 push 하면 됩니다.

날짜·시간·문구를 바꿨다면 **네 곳을 함께** 고쳐야 합니다 — `src/poster.html`,
`apply/index.html`, `tools/build.ps1` 의 desc 변수, `tools/make-og.ps1` 의 글귀.
고친 뒤 `make-og.ps1` 도 다시 돌려 카드를 새로 그리세요.

> 한글이 든 `.ps1` 은 **UTF-8 BOM** 으로 저장해야 합니다. BOM 이 없으면
> Windows PowerShell 5.1 이 한글을 깨뜨립니다.
>
> PowerShell 은 변수 대소문자를 구분하지 않습니다. `make-og.ps1` 에서 캔버스 크기를
> CW/CH 로 쓴 이유입니다 — 반복문의 w/h 와 부딪힙니다.

## 신청은 어떻게 들어오나

```
신청 페이지 → Cloudflare Worker → 비공개 저장소 data/applications.csv → 구글시트
   즉시            즉시                    즉시                        1분마다
```

- Worker 주소 : `https://walking-meditation-apply.aassan9979-194.workers.dev`
- 설정값은 Cloudflare 대시보드에 있습니다 — `GITHUB_TOKEN`(비밀), `LIST_KEY`(비밀),
  `GITHUB_REPO`, `FILE_PATH`, `ALLOW_ORIGIN`
- **GitHub 토큰은 2026-09-27 만료.** 그 뒤에도 접수하려면 새로 만들어 `GITHUB_TOKEN` 만 교체
- 구글시트는 `A1` 의 `=IMPORTDATA(J2&J3)` 로 읽고, Apps Script 가 1분마다 `J3` 숫자를 바꿔
  새로 읽게 합니다. 즉시 갱신은 시트 메뉴 `명단` → `지금 새로고침`
- 시트 `H1` 참석 인원 합계 `=SUM(C2:C)`, `H2` 신청 건수 `=COUNTA(A2:A)`

**주의** — Worker 가 두 차례 예전 버전으로 되돌아간 적이 있습니다(연락처 하이픈 기능이
붙었다 사라짐). 그래서 신청서의 출발시각은 새 열이 아니라 `참석여부` 값에 붙여 보냅니다
("참석합니다. · 오전 10시"). 어느 버전이 돌든 유실되지 않습니다. 배포가 안정되면
별도 열로 분리해도 됩니다.

### 명단 비우기

행사 전에 시험 기록을 지우려면 `data/applications.csv` 를 머리글 한 줄만 남기고 비웁니다.
맨 앞 BOM 을 지우면 Excel 에서 한글이 깨지니 그대로 두세요.

## 디자인 메모

가을(추석) 색입니다. `src/poster.html` 위쪽 `:root` 에 모여 있습니다.

| 이름 | 값 | 쓰이는 곳 |
|---|---|---|
| `--paper` | `#F5F3E8` | 종이 바탕 (따뜻한 미색) |
| `--ink` | `#26402E` | 본문 글자, 아래 띠 (짙은 솔빛) |
| `--ink-soft` | `#5E6B52` | 보조 설명 |
| `--jade` | `#8A6524` | 작은 이름표, 강조 글자 (짙은 호박색) |
| `--leaf` | `#C79A3E` | 맨 위 띠, 짧은 막대, 버튼 (금빛) |
| `--rule` | `#DAD5C0` | 가는 선 |

글꼴 — 제목 **Noto Serif KR 900**, 본문 명조 **Gowun Batang**, 정보 **IBM Plex Sans KR**.
모두 Google Fonts.

앞면 그림은 SVG 로 직접 그렸습니다 (viewBox 794×140). 한가위 보름달, 능선 두 겹,
양옆 억새 22포기, 마른 흙길, 그 위로 멀어지는 발자국 10개. 발자국은 멀수록 작아지고
옅어지며 **보폭도 함께 좁아집니다** — 거리감이 여기서 나옵니다.
미리보기 카드(`make-og.ps1`)도 같은 장면을 GDI+ 로 다시 그린 것입니다.

## 크기

- A4 세로 = 794 × 1123 px (96dpi). 화면 폭이 794px 보다 넓으면 이 크기 그대로.
- 793px 이하면 축소하지 않고 핸드폰용 크기로 다시 흘러갑니다.
- 인쇄는 `Ctrl` + `P` → A4, 여백 없음. 앞면·뒷면 두 장으로 나옵니다.

포스터 앞면은 높이가 A4 로 **고정**입니다. 내용을 한 줄 늘리면 그만큼 어딘가를 줄여야
합니다. 여유는 그림 띠(`.forest`)가 흡수하는데 최소 높이가 118px 이고, 그보다 더 눌리면
맨 아래 주최·주관·후원 띠가 잘립니다. 글자를 키우기 전에 이 점을 확인하세요.