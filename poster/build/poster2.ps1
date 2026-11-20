# poster2.ps1 — Poster 2: landscape, 48 x 36 in, one central hero figure (the two ways to steer a
# beam, redrawn from the TikZ figure of main.tex) with the key results arranged around it.
. (Join-Path $PSScriptRoot 'lib.ps1')
. (Join-Path $PSScriptRoot 'content.ps1')

New-Poster 48 36
try {
$body = @{ size = 28 }
$cap = @{ size = 22; color = $C.muted }

Add-Banner 4.6 $Title 80 5.0

$m = 0.7; $gap = 0.6; $top = 4.6 + 0.6; $bot = 36 - $m
$sw = 11.0                                   # side columns
$xl = $m; $xr = 48 - $m - $sw
$xc = $m + $sw + $gap; $wc = 48 - 2 * ($m + $sw + $gap)

# One result card: big number, short label, figure; drawn on a white card.
function Add-Card([double]$l, [double]$t, [double]$w, [string]$value, [string]$label, [string]$fig, [double]$figH) {
    $v = Add-Text ($l + 0.2) ($t + 0.2) ($w - 0.4) 2 @($value) @{ size = 64; bold = $true; color = $C.red; align = 2 } -fit
    $y = $t + 0.2 + $v.Height / 72
    $lb = Add-Text ($l + 0.25) $y ($w - 0.5) 2 @($label) @{ size = 22; color = $C.ink; align = 2 } -fit
    return @{ v = $v; lb = $lb; y = $y + $lb.Height / 72 + 0.35 }
}

$hero = @{ title = 'Two ways to steer a beam'; body = {
    param($f)
    $ug = 1.2; $ue = 1.42
    Draw-Galvo ($f.l + 0.2) ($f.y - 0.3) $ug 28
    $ex = $f.l + 0.2 + 4.6 * $ug + 0.9
    Draw-EOD $ex ($f.y + 0.45) $ue 28
    $ly = $f.y + 4.1 * $ug - 0.1
    [void](Add-Text $f.l $ly (4.6 * $ug + 0.4) 1 @('**(a) Galvanometer:** a mirror turns') @{ size = 26; align = 2 } -fit)
    [void](Add-Text $ex $ly (11.2 * $ue) 1 @('**(b) EOD:** the index changes across the beam') @{ size = 26; align = 2 } -fit)
    Flow-Gap $f (4.1 * $ug + 0.75)
    $half = ($f.w - 0.6) / 2
    $a = Add-Text $f.l $f.y $half 5 @('A mirror turned through θ turns the beam through 2θ: tens of degrees of range, but the inertia of mirror and rotor makes a move take hundreds of microseconds.') $body -fit
    $b = Add-Text ($f.l + $half + 0.6) $f.y $half 5 @($Words.concept[0]) $body -fit
    Flow-Gap $f ([math]::Max($a.Height, $b.Height) / 72 + 0.2)
    [void](Flow-Text $f @('Schematic, not to scale. No moving part: the EOD''s speed is set by its electronics, not by inertia. The side view draws one electrode pair of the quadrupole; the end view shows all four.') $cap 0) } }

$cards = @{ title = 'Key results for the EODs'; body = {
    param($f)
    $n = 4; $cg = 0.4; $cw = ($f.w - ($n - 1) * $cg) / $n
    $spec = @(
        ,@('3.15 | 3.31', 'mrad/kV, EOD34 | EOD35, polarization perpendicular; vendor minimum >3', 'eod-polarization-hva1-mrad-per-kv')
        ,@('≤ 3%', 'of full scale: largest departure from a straight line across ±200 V', 'eod-polarization-hva1-cx')
        ,@('25 µs', 'settled within the noise, one dwell; an upper bound for EOD plus detector', 'eod-delay-step-response')
        ,@('0.001 mrad', 'EOD35 wander within a hold: no measurable addition to the laser''s own', 'eod-stab-eod35-angular')
    )
    $made = @(); $yFig = 0
    for ($k = 0; $k -lt $n; $k++) {
        $made += ,(Add-Card ($f.l + $k * ($cw + $cg)) $f.y $cw $spec[$k][0] $spec[$k][1] $spec[$k][2] 0)
        $yFig = [math]::Max($yFig, $made[$k].y)
    }
    $fh = [math]::Min(4.6 * $f.scale, ($cw - 0.3) * (Get-Aspect (FigPath $spec[0][2])))
    for ($k = 0; $k -lt $n; $k++) {
        $fw = $fh / (Get-Aspect (FigPath $spec[$k][2]))
        [void](Add-Pic $spec[$k][2] ($f.l + $k * ($cw + $cg) + ($cw - $fw) / 2) $yFig $fw)
    }
    $cardH = $yFig + $fh + 0.2 - $f.y
    for ($k = 0; $k -lt $n; $k++) {
        $r = Add-Rect ($f.l + $k * ($cw + $cg)) $f.y $cw $cardH $C.white $C.line 1.5 "Result card $($k + 1)"
        $r.ZOrder(1)
    }
    Flow-Gap $f ($cardH + 0.3)
    [void](Flow-Text $f @('Cards, left to right: sensitivity of EOD34 at three input polarizations; EOD34 beam center against drive; averaged step at 10 kHz with the two-stage fit; EOD35 deviation from the hold mean at each held voltage.') $cap 0) } }

$table = @{ title = 'Operating parameters of the EODs'; body = {
    param($f)
    $tbl = Add-ParamTable $f.l $f.y @(8.2, 6.2, ($f.w - 14.4)) $Words.eodTable 22
    Flow-Gap $f ($tbl.Height / 72 + 0.2)
    [void](Flow-Text $f @($Words.tableNote) @{ size = 20; color = $C.muted } 0) } }

$left = @(
    @{ title = 'Motivation'; num = '1'; body = { param($f) [void](Flow-Text $f $Words.motivation $body) } }
    @{ title = 'Setup and drive electronics'; num = '2'; body = {
        param($f)
        [void](Flow-Pics $f @('eod-setup-relay-two-deflectors') 5.0 0.2)
        [void](Flow-Pics $f @('eod-drive-circuit') 4.0 0.2)
        [void](Flow-Text $f @('Top: the two EODs in series, relayed by L1 and L2. Bottom: drive circuit; as built, the followers run on ±15 V.') $cap 0.3)
        [void](Flow-Text $f $Words.setupShort $body) } }
    @{ title = 'References and acknowledgments'; body = {
        param($f)
        [void](Flow-Text $f $Words.refs @{ size = 18; spaceAfter = 2 } 0.25)
        [void](Flow-Text $f $Words.ack @{ size = 18 }) } }
)
$right = @(
    @{ title = 'Beam quality'; num = '3'; body = {
        param($f)
        [void](Flow-Pics $f @('eod-quality-voltage-ellipticity') 4.2 0.2)
        [void](Flow-Text $f @($Words.ellipCap) $cap 0.3)
        [void](Flow-Text $f $Words.quality $body) } }
    @{ title = 'The donut under deflection'; num = '4'; body = {
        param($f)
        [void](Flow-Pics $f @('donut-static-image', 'donut-sweep-disp-eod35') 4.2 0.2)
        [void](Flow-Text $f @('Left: the donut at rest. Right: sweeping EOD35 moves it along both camera axes.') $cap 0.3)
        [void](Flow-Text $f $Words.donut $body) } }
    @{ title = 'Galvanometer scanners'; num = '5'; body = {
        param($f)
        [void](Flow-Pics $f @('galvo-cal-angle', 'galvo-step-100hz') 4.2 0.2)
        [void](Flow-Text $f @('Left: optical angle against command voltage. Right: small-step response.') $cap 0.3)
        [void](Flow-Text $f $Words.galvo $body) } }
)

Build-Column $xl $sw $top $bot $left 0.45 44 'left column'
$concl = @{ title = 'Conclusions and operating parameters'; body = {
    param($f)
    $tw = 14.2; $bw = $f.w - $tw - 0.5
    $a = Add-Text $f.l $f.y $bw 5 $Words.conclusions @{ size = 28 } -fit
    $tbl = Add-ParamTable ($f.l + $bw + 0.5) $f.y @(5.6, 4.1, ($tw - 9.7)) $Words.eodTable 21
    $th = $script:LastTableHeight
    $n = Add-Text ($f.l + $bw + 0.5) ($f.y + $th + 0.15) $tw 2 @($Words.tableNote) @{ size = 19; color = $C.muted } -fit
    Flow-Gap $f ([math]::Max($a.Height / 72, $th + 0.15 + $n.Height / 72)) } }
Build-Column $xc $wc $top $bot @($hero, $cards, $concl) 0.45 50 'center'
Build-Column $xr $sw $top $bot $right 0.45 44 'right column'

Save-Poster 'poster2-hero'
} catch { Abort-Poster $_ }
