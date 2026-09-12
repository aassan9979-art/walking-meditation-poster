# index.html 다시 만들기
#
#   powershell -ExecutionPolicy Bypass -File tools\build.ps1
#
# src\poster.html 을 고친 뒤 이 스크립트를 돌리면 index.html 이 새로 만들어집니다.
# (src\poster.html 에는 <head> 껍데기가 없습니다. Artifact 로도 그대로 올릴 수 있게
#  하려고 그렇게 두었고, 이 스크립트가 껍데기와 링크 미리보기 태그를 붙여 줍니다.)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$src  = Join-Path $root "src\poster.html"
$out  = Join-Path $root "index.html"
$base = "https://aassan9979-art.github.io/walking-meditation-poster/"
$desc = "2026년 9월 27일(일) 오전 9시 · 10시 · 11시 · 낮 12시 · 오후 1시 출발 (한 시간) · 서귀포시 회수동 WE호텔 · 참가비 없음"

$raw = Get-Content $src -Raw -Encoding UTF8
$i = $raw.IndexOf('<div class="wrap">')
if ($i -lt 0) { throw "src\poster.html 에서 <div class=""wrap""> 를 찾지 못했습니다." }
$headPart = $raw.Substring(0, $i).TrimEnd()
$bodyPart = $raw.Substring($i).TrimEnd()

$doc = @"
<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="theme-color" content="#F5F3E8">
<meta name="description" content="$desc">
<link rel="canonical" href="$base">
<meta property="og:type" content="website">
<meta property="og:url" content="$base">
<meta property="og:locale" content="ko_KR">
<meta property="og:title" content="생명을 살리는 걷기명상">
<meta property="og:description" content="$desc">
<meta property="og:image" content="${base}og.png">
<meta property="og:image:secure_url" content="${base}og.png">
<meta property="og:image:type" content="image/png">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta property="og:image:alt" content="생명을 살리는 걷기 명상 안내 — 2026년 9월 27일 서귀포 회수동 WE호텔, 오전 9시부터 오후 1시까지 매시 정각 출발">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="생명을 살리는 걷기명상">
<meta name="twitter:description" content="$desc">
<meta name="twitter:image" content="${base}og.png">
$headPart
</head>
<body>
$bodyPart
</body>
</html>
"@

[System.IO.File]::WriteAllText($out, $doc, (New-Object System.Text.UTF8Encoding $false))
"index.html 다시 만듦 ({0:N0} bytes)" -f (Get-Item $out).Length
