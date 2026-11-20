# poster3.ps1 — Poster 3: portrait, 36 x 48 in, two columns; references in a footer strip.
# The portrait carries less height per column than the landscapes, so it shows a subset of the
# shared bullets, and the donut and galvanometer sections set one figure beside their text.
. (Join-Path $PSScriptRoot 'lib.ps1')
. (Join-Path $PSScriptRoot 'content.ps1')

New-Poster 36 48
try {
$body = @{ size = 28 }
$cap = @{ size = 22; color = $C.muted }

Add-Banner 5.0 $Title 72 4.0

$m = 0.7; $gap = 0.6; $top = 5.0 + 0.6
$cw2 = 18.0; $cw1 = 36 - 2 * $m - $gap - $cw2      # the right column carries more figures
$x1 = $m; $x2 = $m + $cw1 + $gap

# Footer: references and acknowledgments, no header band.
$fh = 2.9; $fy = 48 - $m - $fh
[void](Add-Rect $m $fy (36 - 2 * $m) $fh $C.tint $null 0 'Footer: references and acknowledgments')
$rw = 19.0
[void](Add-Text ($m + 0.4) ($fy + 0.3) $rw ($fh - 0.5) (@('**References**') + $Words.refs) @{ size = 18; spaceAfter = 1 })
[void](Add-Text ($m + 0.4 + $rw + 0.6) ($fy + 0.3) (36 - 2 * $m - $rw - 1.4) ($fh - 0.5) (@('**Acknowledgments**') + $Words.ack) @{ size = 18; spaceAfter = 4 })
$bot = $fy - 0.5

$left = @(
    @{ title = 'Motivation'; num = '1'; body = { param($f) [void](Flow-Text $f $Words.motivation[0..2] $body) } }
    @{ title = 'The electro-optic deflector'; num = '2'; body = {
        param($f)
        $u = 1.3; Draw-EOD ($f.l + 0.05) $f.y $u 26; Flow-Gap $f (2.85 * $u + 0.2)
        [void](Flow-Text $f @($Words.conceptCap) $cap 0.3)
        [void](Flow-Text $f $Words.concept[0..1] $body) } }
    @{ title = 'Setup and drive electronics'; num = '3'; body = {
        param($f)
        [void](Flow-Pics $f @('eod-setup-relay-two-deflectors', 'eod-drive-circuit') 4.4 0.2)
        [void](Flow-Text $f @('Left: the two EODs in series, relayed by L1 and L2. Right: drive circuit; as built, the followers run on ±15 V.') $cap 0.3)
        [void](Flow-Text $f $Words.setupShort $body) } }
    @{ title = 'Sensitivity and polarization'; num = '4'; body = {
        param($f)
        # the two numbers stacked in a narrow column, the figures beside them
        $sw = 4.2; $y0 = $f.y
        $h1 = Add-Stat $f.l $y0 $sw '3.15' 'mrad/kV, EOD34' 88 24
        $h2 = Add-Stat $f.l ($y0 + $h1 + 0.25) $sw '3.31' 'mrad/kV, EOD35' 88 24
        $n = Add-Text $f.l ($y0 + $h1 + $h2 + 0.55) $sw 3 @('Polarization perpendicular to the deflection axis: both meet the vendor minimum, >3 mrad/kV.') @{ size = 22; align = 2; color = $C.navy; bold = $true } -fit
        $statH = $h1 + $h2 + 0.55 + $n.Height / 72
        $g = New-Flow @(($f.l + $sw + 0.3), $y0, ($f.w - $sw - 0.3), 100) 'sens figs'; $g.scale = $f.scale
        [void](Flow-Pics $g @('eod-polarization-hva1-cx', 'eod-polarization-hva1-mrad-per-kv') 5.6 0 0.2)
        Flow-Gap $f ([math]::Max($statH, $g.y - $y0) + 0.25)
        [void](Flow-Text $f @('EOD34 beam center against its drive (left) and the sensitivity of each sweep (right), at three input polarizations.') $cap 0.3)
        [void](Flow-Text $f ($Words.sensitivity + $Words.linearity) $body) } }
    @{ title = 'Conclusions'; num = '9'; body = { param($f) [void](Flow-Text $f $Words.conclusions $body) } }
)
$right = @(
    @{ title = 'Step response'; num = '5'; body = {
        param($f)
        [void](Flow-Pics $f @('eod-delay-step-response', 'eod-delay-settled-fraction') 5.6 0.2)
        [void](Flow-Text $f @('Left: averaged rising step at 10 kHz with the two-stage fit. Right: step covered 5, 10 and 25 µs after the edge.') $cap 0.3)
        [void](Flow-Text $f $Words.step $body) } }
    @{ title = 'Pointing stability and beam quality'; num = '6'; body = {
        param($f)
        [void](Flow-Pics $f @('eod-stab-eod35-angular', 'eod-quality-voltage-ellipticity') 5.0 0.2)
        [void](Flow-Text $f @('Left: EOD35 deviation from the hold mean at each held voltage. Right: ellipticity against command voltage.') $cap 0.3)
        [void](Flow-Text $f @($Words.stability[1], $Words.quality[1]) $body) } }
    @{ title = 'The donut under deflection'; num = '7'; body = {
        param($f)
        Flow-Side $f 'donut-static-image' 6.4 $Words.donut[0..1] $body 0.2
        [void](Flow-Text $f @($Words.donutImgCap) $cap 0) } }
    @{ title = 'Galvanometer scanners'; num = '8'; body = {
        param($f)
        Flow-Side $f 'galvo-step-100hz' 6.4 $Words.galvo $body 0.2
        [void](Flow-Text $f @('Small-step response of both axes, from the 10% point.') $cap 0) } }
    @{ title = 'Operating parameters of the EODs'; body = {
        param($f)
        $tbl = Add-ParamTable $f.l $f.y @(6.4, 4.6, ($f.w - 11.0)) $Words.eodTable 20
        Flow-Gap $f ($script:LastTableHeight + 0.2)
        [void](Flow-Text $f @($Words.tableNote) @{ size = 18; color = $C.muted } 0) } }
)

Build-Column $x1 $cw1 $top $bot $left 0.45 46 'left column'
Build-Column $x2 $cw2 $top $bot $right 0.45 46 'right column'

Save-Poster 'poster3-portrait' 1800
} catch { Abort-Poster $_ }
