Add-Type -AssemblyName System.Drawing

# 링크 미리보기 카드(og.png)를 다시 그립니다. 포스터와 같은 가을 풍경입니다.
#   powershell -ExecutionPolicy Bypass -File tools\make-og.ps1
# 이 파일은 반드시 UTF-8 BOM 으로 저장하세요. BOM 이 없으면 한글이 깨집니다.

$CW = 1200; $CH = 630
$bmp = New-Object System.Drawing.Bitmap($CW, $CH)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

function C($hex) { [System.Drawing.ColorTranslator]::FromHtml($hex) }
function A($col, $alpha) { [System.Drawing.Color]::FromArgb($alpha, $col.R, $col.G, $col.B) }
function Brush($col) { New-Object System.Drawing.SolidBrush($col) }

$paper    = C "#F5F3E8"
$ink      = C "#26402E"
$inkSoft  = C "#5E6B52"
$leaf     = C "#C79A3E"
$moon     = C "#F9F4DB"
$hillFar  = C "#DFDAC0"
$hillNear = C "#C6C1A0"
$trail    = C "#EAE2CB"
$trailFar = C "#F1ECDA"
$brush    = C "#B9A874"
$brushDark= C "#8C7B46"
$reed     = C "#AFA684"
$plume    = C "#DCD5B6"
$footInk  = C "#4C4029"

$bandTop = 300; $bandBottom = 512

$g.Clear($paper)
$g.FillRectangle((Brush $leaf), 0, 0, $CW, 10)

$g.SetClip((New-Object System.Drawing.Rectangle(0, $bandTop, $CW, ($bandBottom - $bandTop))))

# ---- 한가위 보름달 ----
foreach ($r in @(112, 86, 64)) {
  $alpha = [int](14 + (112 - $r) * 0.42)
  $g.FillEllipse((Brush (A $moon $alpha)), (905 - $r), (360 - $r), ($r * 2), ($r * 2))
}
$g.FillEllipse((Brush $moon), (905 - 42), (360 - 42), 84, 84)

# ---- 능선 ----
function Hill($pts, $color) {
  $arr = @()
  foreach ($p in $pts) { $arr += (New-Object System.Drawing.PointF($p[0], $p[1])) }
  $arr += (New-Object System.Drawing.PointF($CW, $bandBottom))
  $arr += (New-Object System.Drawing.PointF(0, $bandBottom))
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $path.AddPolygon($arr)
  $g.FillPath((Brush $color), $path)
  $path.Dispose()
}
Hill @(@(0,410),@(140,392),@(260,404),@(400,384),@(540,400),@(700,388),@(860,402),@(1020,386),@(1200,398)) $hillFar
Hill @(@(0,440),@(160,428),@(300,438),@(450,424),@(600,440),@(760,428),@(920,442),@(1080,430),@(1200,438)) $hillNear

# ---- 흙길 ----
$trailPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$trailPath.AddPolygon(@(
  (New-Object System.Drawing.PointF(240, $bandBottom)),
  (New-Object System.Drawing.PointF(632, 396)),
  (New-Object System.Drawing.PointF(674, 396)),
  (New-Object System.Drawing.PointF(1010, $bandBottom))
))
$trailBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Point(0, 396)),
  (New-Object System.Drawing.Point(0, $bandBottom)),
  $trailFar, $trail)
$g.FillPath($trailBrush, $trailPath)
$trailBrush.Dispose(); $trailPath.Dispose()

# ---- 억새 ----
$reeds = @(
  @(18,78),@(44,60),@(68,90),@(94,52),@(122,72),@(150,58),@(182,84),@(214,46),
  @(246,66),@(280,40),@(318,52),@(358,34),
  @(856,36),@(898,48),@(936,40),@(976,64),@(1012,46),@(1052,78),@(1086,54),
  @(1122,88),@(1156,64),@(1184,76)
)
$reedPen = New-Object System.Drawing.Pen((A $reed 190), 1.6)
$reedPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$reedPen.EndCap   = [System.Drawing.Drawing2D.LineCap]::Round
foreach ($r in $reeds) {
  $rx0 = [single]$r[0]; $rh = [single]$r[1]
  $top  = $bandBottom - $rh
  $tipx = $rx0 + $rh * 0.16
  $g.DrawBezier($reedPen,
    (New-Object System.Drawing.PointF($rx0, $bandBottom)),
    (New-Object System.Drawing.PointF(($rx0 + $rh * 0.02), ($bandBottom - $rh * 0.35))),
    (New-Object System.Drawing.PointF(($rx0 + $rh * 0.07), ($bandBottom - $rh * 0.7))),
    (New-Object System.Drawing.PointF($tipx, $top)))
  $pw = $rh * 0.11
  $ph = $rh * 0.32
  $state = $g.Save()
  $g.TranslateTransform($tipx, ($top - $rh * 0.09))
  $g.RotateTransform(14)
  $g.FillEllipse((Brush (A $plume 230)), (-$pw / 2), (-$ph / 2), $pw, $ph)
  $g.Restore($state)
}
$reedPen.Dispose()

# ---- 길가 덤불 ----
function Clump($pts, $color) {
  $arr = @()
  foreach ($p in $pts) { $arr += (New-Object System.Drawing.PointF($p[0], $p[1])) }
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $path.AddClosedCurve($arr, 0.5)
  $g.FillPath((Brush $color), $path)
  $path.Dispose()
}
Clump @(@(-40,$bandBottom+20),@(60,470),@(170,462),@(280,486),@(330,$bandBottom+20)) $brush
Clump @(@(1240,$bandBottom+20),@(1140,468),@(1030,460),@(920,484),@(870,$bandBottom+20)) $brush
Clump @(@(-40,$bandBottom+20),@(50,490),@(140,484),@(220,500),@(250,$bandBottom+20)) $brushDark
Clump @(@(1240,$bandBottom+20),@(1150,488),@(1060,482),@(985,498),@(955,$bandBottom+20)) $brushDark

# ---- 발자국 ----
$feet = @(
  @(575, 500, 13.0, -9, 224),
  @(664, 488, 11.8,  9, 214),
  @(593, 476, 10.6, -8, 201),
  @(662, 463,  9.3,  8, 189),
  @(611, 450,  8.0, -7, 176),
  @(660, 437,  6.8,  7, 161),
  @(629, 424,  5.5, -6, 145),
  @(658, 412,  4.3,  6, 130),
  @(645, 403,  3.4, -4, 115)
)
foreach ($f in $feet) {
  $fx = [single]$f[0]; $fy = [single]$f[1]; $fw = [single]$f[2]
  $rot = [single]$f[3]; $alpha = [int]$f[4]
  $b = Brush (A $footInk $alpha)
  $state = $g.Save()
  $g.TranslateTransform($fx, $fy)
  $g.RotateTransform($rot)
  $g.FillEllipse($b, (-$fw), (-$fw * 1.55), ($fw * 2), ($fw * 3.1))
  $g.FillEllipse($b, (-$fw * 0.62), ($fw * 2.2 - $fw * 0.55), ($fw * 1.24), ($fw * 1.1))
  $g.Restore($state)
  $b.Dispose()
}

# ---- 아래쪽을 종이색으로 ----
$fade = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Point(0, 476)),
  (New-Object System.Drawing.Point(0, $bandBottom)),
  (A $paper 0), (A $paper 150))
$g.FillRectangle($fade, 0, 476, $CW, ($bandBottom - 476))
$fade.Dispose()
$g.ResetClip()

# ---- 아래 띠 ----
$g.FillRectangle((Brush $ink), 0, $bandBottom, $CW, ($CH - $bandBottom))

# ---- 글자 ----
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

Text "2026년 9월 27일 (일) 오전 9시 ~ 오후 2시" $sans 29 $B $paper 70 530
Text "9시 · 10시 · 11시 · 12시 · 1시 매시 정각 출발 (한 시간)" $sans 20 $R (C "#D9D3B4") 70 568
Text "서귀포시 회수동 WE호텔 · 참가비 없음" $sans 18 $R (C "#B9B28E") 70 592

$out = Join-Path (Split-Path -Parent $PSScriptRoot) "og.png"
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()

$fi = Get-Item $out
"저장: {0}  ({1:N0} bytes, {2}x{3})" -f $fi.FullName, $fi.Length, $CW, $CH
