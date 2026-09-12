Add-Type -AssemblyName System.Drawing

$W = 1200; $H = 630
$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

function C($hex) {
  [System.Drawing.ColorTranslator]::FromHtml($hex)
}

$paper     = C "#F2F7EE"
$ink       = C "#1C4733"
$inkSoft   = C "#4E6E58"
$leaf      = C "#57A86B"
$ridgeFar  = C "#D3E3D2"
$ridgeNear = C "#B2CDB4"
$trunkFar  = C "#96B79C"
$trunkMid  = C "#5A8A64"
$trunkNear = C "#2E6340"
$paperLift = C "#EAF2E6"

# ground
$g.Clear($paper)

# top leaf bar
$g.FillRectangle((New-Object System.Drawing.SolidBrush($leaf)), 0, 0, $W, 10)

# ---- forest band: y 320 .. 530 ----
$bandTop = 320; $bandBottom = 530
$g.SetClip((New-Object System.Drawing.Rectangle(0, $bandTop, $W, ($bandBottom - $bandTop))))

function Ridge($pts, $color) {
  $poly = New-Object System.Drawing.Drawing2D.GraphicsPath
  $arr = @()
  foreach ($p in $pts) { $arr += (New-Object System.Drawing.PointF($p[0], $p[1])) }
  $arr += (New-Object System.Drawing.PointF($W, $bandBottom))
  $arr += (New-Object System.Drawing.PointF(0, $bandBottom))
  $poly.AddPolygon($arr)
  $g.FillPath((New-Object System.Drawing.SolidBrush($color)), $poly)
  $poly.Dispose()
}

Ridge @(@(0,412),@(136,382),@(227,404),@(363,368),@(499,400),@(635,376),@(786,410),@(922,368),@(1058,400),@(1200,384)) $ridgeFar
Ridge @(@(0,441),@(181,415),@(317,437),@(453,410),@(604,441),@(755,420),@(906,449),@(1058,423),@(1200,446)) $ridgeNear

# trunks: x, topY(offset within band), width, tone(0 far 1 mid 2 near), alpha
$trunks = @(
  @(21,339,4,2,230), @(41,375,2,1,153), @(62,326,7,2,255), @(88,362,3,1,179),
  @(103,391,1.5,0,204), @(127,335,6,2,242), @(150,368,4,1,166), @(169,352,2,0,230),
  @(190,323,9,2,255), @(222,378,3,1,153), @(239,341,5,2,217), @(264,396,1.5,0,191),
  @(281,356,4,1,179), @(307,329,7,2,255), @(334,384,2,0,204), @(351,347,4.5,1,191),
  @(379,371,3,1,153), @(400,323,7.5,2,255), @(432,389,2,0,179), @(449,353,4,1,179),
  @(480,404,2,0,140), @(507,413,1.5,0,115), @(539,401,3,0,153), @(571,419,1.5,0,102),
  @(603,407,2,0,128), @(635,416,1.5,0,115), @(666,402,3,0,153),
  @(698,344,4.5,1,204), @(722,382,2,0,204), @(743,326,7.5,2,255), @(775,368,3,1,166),
  @(796,335,5,2,217), @(825,389,1.5,0,179), @(843,356,4,1,179), @(872,329,7,2,255),
  @(900,384,2,0,204), @(919,347,4.5,1,191), @(949,374,3,1,153), @(972,320,8,2,255),
  @(1006,395,2,0,179), @(1024,353,4,1,179), @(1053,332,6,2,242), @(1080,378,2,0,204),
  @(1101,341,4.5,2,217), @(1130,362,3,1,166), @(1151,326,7.5,2,255), @(1180,350,4,1,179)
)
foreach ($t in $trunks) {
  $tone = switch ([int]$t[3]) { 0 { $trunkFar } 1 { $trunkMid } default { $trunkNear } }
  $col = [System.Drawing.Color]::FromArgb([int]$t[4], $tone.R, $tone.G, $tone.B)
  $pen = New-Object System.Drawing.Pen($col, [single]$t[2])
  $bottom = if ([int]$t[3] -eq 0 -and $t[0] -gt 470 -and $t[0] -lt 680) { 496 } else { $bandBottom }
  # near trunks run off the top of the band so they read as trunks, not bars
  $top = switch ([int]$t[3]) { 2 { 300 } 1 { [single]$t[1] - 18 } default { [single]$t[1] } }
  $g.DrawLine($pen, [single]$t[0], [single]$top, [single]$t[0], [single]$bottom)
  $pen.Dispose()
}

# mist fading the trunk bases into the paper
$mistRect = New-Object System.Drawing.Rectangle(0, 455, $W, ($bandBottom - 455))
$mist = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Point(0, 455)),
  (New-Object System.Drawing.Point(0, $bandBottom)),
  [System.Drawing.Color]::FromArgb(0, $paper.R, $paper.G, $paper.B),
  [System.Drawing.Color]::FromArgb(255, $paper.R, $paper.G, $paper.B))
$g.FillRectangle($mist, $mistRect)
$mist.Dispose()
$g.ResetClip()

# ---- footer band ----
$g.FillRectangle((New-Object System.Drawing.SolidBrush($ink)), 0, 530, $W, ($H - 530))

# ---- type ----
$serifBlack = "Noto Serif KR Black"
$serifSemi  = "Noto Serif KR SemiBold"
$sans       = "Malgun Gothic"

function Text($s, $family, $size, $style, $color, $x, $y) {
  $f = New-Object System.Drawing.Font($family, [single]$size, $style, [System.Drawing.GraphicsUnit]::Pixel)
  $b = New-Object System.Drawing.SolidBrush($color)
  $fmt = [System.Drawing.StringFormat]::GenericTypographic.Clone()
  $fmt.FormatFlags = $fmt.FormatFlags -bor [System.Drawing.StringFormatFlags]::NoWrap
  $g.DrawString($s, $f, $b, [single]$x, [single]$y, $fmt)
  $f.Dispose(); $b.Dispose()
}

$R = [System.Drawing.FontStyle]::Regular
$B = [System.Drawing.FontStyle]::Bold

Text "명상 전문 지도사와 함께하는" $sans 27 $R $inkSoft 70 56
Text "생명을 살리는" $serifSemi 50 $R $ink 68 98
Text "걷기 명상" $serifBlack 112 $R $ink 64 164

Text "2026년 9월 27일 (일) 오전 10시 — 11시" $sans 30 $B $paper 70 552
Text "서귀포시 회수동 WE호텔 · 메가와티공원 · 편백숲 · 참가비 없음" $sans 21 $R (C "#BFD6C3") 70 594

$out = Join-Path (Split-Path -Parent $PSScriptRoot) "og.png"
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()

$fi = Get-Item $out
"저장: {0}  ({1:N0} bytes, {2}x{3})" -f $fi.FullName, $fi.Length, $W, $H
