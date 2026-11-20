# poster1.ps1 — Poster 1: classic three-column landscape, 48 x 36 in.
. (Join-Path $PSScriptRoot 'lib.ps1')
. (Join-Path $PSScriptRoot 'content.ps1')

New-Poster 48 36
try {
$body = @{ size = 28 }
$cap = @{ size = 22; color = $C.muted }

Add-Banner 4.6 $Title 80 5.0

$m = 0.7; $gap = 0.6; $top = 4.6 + 0.6; $bot = 36 - $m
$cw = (48 - 2 * $m - 2 * $gap) / 3
$x1 = $m; $x2 = $m + $cw + $gap; $x3 = $m + 2 * ($cw + $gap)

$col1 = @(
    @{ title = 'Motivation'; num = '1'; body = { param($f) [void](Flow-Text $f $Words.motivation $body) } }
    @{ title = 'The electro-optic deflector'; num = '2'; body = {
        param($f)
        $u = 1.2; Draw-EOD ($f.l + 0.2) $f.y $u 26; Flow-Gap $f (2.85 * $u + 0.2)
        [void](Flow-Text $f @($Words.conceptCap) $cap 0.3)
        [void](Flow-Text $f $Words.concept $body) } }
    @{ title = 'Setup and drive electronics'; num = '3'; body = {
        param($f)
        [void](Flow-Pics $f @('eod-setup-relay-two-deflectors', 'eod-drive-circuit') 3.4 0.2)
        [void](Flow-Text $f @('Left: the two EODs in series, relayed by L1 and L2. Right: drive circuit; as built, the followers run on ±15 V.') $cap 0.3)
        [void](Flow-Text $f $Words.setupShort $body) } }
    @{ title = 'References and acknowledgments'; body = {
        param($f)
        [void](Flow-Text $f $Words.refs @{ size = 22; spaceAfter = 3 } 0.3)
        [void](Flow-Text $f $Words.ack @{ size = 22 }) } }
)
$col2 = @(
    @{ title = 'Sensitivity and polarization'; num = '4'; body = {
        param($f)
        $half = $f.w / 2
        $s1 = Add-Stat $f.l $f.y $half '3.15' 'mrad/kV, EOD34' 96 26
        $s2 = Add-Stat ($f.l + $half) $f.y $half '3.31' 'mrad/kV, EOD35' 96 26
        Flow-Gap $f ([math]::Max($s1, $s2) + 0.1)
        [void](Flow-Text $f @('Polarization perpendicular to the deflection axis: both meet the vendor minimum, >3 mrad/kV.') @{ size = 24; align = 2; color = $C.navy; bold = $true } 0.3)
        [void](Flow-Pics $f @('eod-polarization-hva1-cx', 'eod-polarization-hva1-mrad-per-kv') 4.6 0.2)
        [void](Flow-Text $f @('EOD34 beam center against its drive (left) and the sensitivity of each sweep (right), at three input polarizations.') $cap 0.3)
        [void](Flow-Text $f ($Words.sensitivity + $Words.linearity) $body) } }
    @{ title = 'Step response'; num = '5'; body = {
        param($f)
        [void](Flow-Pics $f @('eod-delay-step-response', 'eod-delay-settled-fraction') 4.6 0.2)
        [void](Flow-Text $f @('Left: averaged rising step at 10 kHz with the two-stage fit. Right: step covered 5, 10 and 25 µs after the edge.') $cap 0.3)
        [void](Flow-Text $f $Words.step $body) } }
    @{ title = 'Pointing stability and beam quality'; num = '6'; body = {
        param($f)
        [void](Flow-Pics $f @('eod-stab-eod35-angular', 'eod-quality-voltage-ellipticity') 4.0 0.2)
        [void](Flow-Text $f @('Left: EOD35 deviation from the hold mean at each held voltage. Right: ellipticity against command voltage.') $cap 0.3)
        [void](Flow-Text $f @($Words.stability[1], $Words.quality[1]) $body) } }
)
$col3 = @(
    @{ title = 'The donut under deflection'; num = '7'; body = {
        param($f)
        [void](Flow-Pics $f @('donut-static-image', 'donut-sweep-disp-eod35') 4.0 0.2)
        [void](Flow-Text $f @('Left: the donut at rest, fitted ring radius dashed. Right: sweeping EOD35 moves it along both camera axes.') $cap 0.3)
        [void](Flow-Text $f $Words.donut $body) } }
    @{ title = 'Galvanometer scanners'; num = '8'; body = {
        param($f)
        Flow-Side $f 'galvo-cal-angle' 5.6 $Words.galvo $body 0.2
        [void](Flow-Text $f @('Optical angle against command voltage for both scanners.') $cap 0) } }
    @{ title = 'Conclusions'; num = '9'; body = {
        param($f)
        [void](Flow-Text $f $Words.conclusions $body 0.35)
        $tbl = Add-ParamTable $f.l $f.y @(5.3, 3.9, ($f.w - 9.2)) $Words.eodTable 21
        Flow-Gap $f ($script:LastTableHeight + 0.2)
        [void](Flow-Text $f @($Words.tableNote) @{ size = 19; color = $C.muted } 0) } }
)

Build-Column $x1 $cw $top $bot $col1 0.45 46 'column 1'
Build-Column $x2 $cw $top $bot $col2 0.45 46 'column 2'
Build-Column $x3 $cw $top $bot $col3 0.45 46 'column 3'

Save-Poster 'poster1-three-column'
} catch { Abort-Poster $_ }
