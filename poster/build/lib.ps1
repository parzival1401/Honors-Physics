# lib.ps1 — shared helpers for the three posters. Builds native PowerPoint shapes through COM
# (PowerPoint must be installed), so every box, text run and schematic stays editable.
# All positions are in inches; PowerPoint works in points (72 per inch).

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$Root    = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)   # repo root
$FigDir  = Join-Path $Root 'figures'
$OutDir  = Split-Path -Parent $PSScriptRoot                         # poster/
$script:Warnings = New-Object System.Collections.ArrayList

# ---------- palette (642 nm laser red on deep navy) ----------
$C = @{
    navy   = '17284A'; navy2 = '24406E'; ink = '1E232B'; muted = '4A5565'
    red    = 'C62E2E'; tint = 'EEF2F8'; tint2 = 'DCE5F1'; white = 'FFFFFF'
    line   = 'B9C6DA'; ph = '8A96A8'
}
$FontBody = 'Calibri'; $FontHead = 'Calibri'

function P([double]$in) { [single]($in * 72) }
function RGBc([string]$hex) {
    $r = [Convert]::ToInt32($hex.Substring(0,2),16); $g = [Convert]::ToInt32($hex.Substring(2,2),16)
    $b = [Convert]::ToInt32($hex.Substring(4,2),16); return [int]($r + 256*$g + 65536*$b)
}
function Warn($msg) { [void]$script:Warnings.Add($msg); Write-Host "WARN: $msg" }

# ---------- presentation ----------
function New-Poster([double]$wIn, [double]$hIn) {
    $script:StartedApp = -not (Get-Process POWERPNT -ErrorAction SilentlyContinue)
    $script:App = New-Object -ComObject PowerPoint.Application
    $script:Pres = $script:App.Presentations.Add(0)
    $script:Pres.PageSetup.SlideWidth = P $wIn
    $script:Pres.PageSetup.SlideHeight = P $hIn
    $script:Slide = $script:Pres.Slides.Add(1, 12)   # ppLayoutBlank
    $script:Slide.FollowMasterBackground = 0
    $script:Slide.Background.Fill.Solid()
    $script:Slide.Background.Fill.ForeColor.RGB = RGBc $C.white
    $script:PW = $wIn; $script:PH = $hIn
}

function Save-Poster([string]$name, [int]$pxWide = 2400) {
    $pptx = Join-Path $OutDir "$name.pptx"
    $png  = Join-Path $OutDir "$name.png"
    if (Test-Path $pptx) { Remove-Item $pptx -Force }
    $script:Pres.SaveAs($pptx, 24)
    $pxHigh = [int]([math]::Round($pxWide * $script:PH / $script:PW))
    $script:Slide.Export($png, 'PNG', $pxWide, $pxHigh)
    $script:Pres.Close()
    if ($script:StartedApp) { $script:App.Quit() }
    [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($script:App)
    Write-Host "saved $pptx"; Write-Host "saved $png"
    if ($script:Warnings.Count) { Write-Host "$($script:Warnings.Count) warning(s)" } else { Write-Host 'no layout warnings' }
}

# On a failed build: close only the presentation this script made, quit only a PowerPoint it started.
function Abort-Poster($err) {
    Write-Host "BUILD FAILED: $($err.Exception.Message)"; Write-Host $err.ScriptStackTrace
    if ($script:Pres) { try { $script:Pres.Close() } catch {} }
    if ($script:App -and $script:StartedApp) { try { $script:App.Quit() } catch {} }
}

# ---------- primitives ----------
function Add-Rect([double]$l, [double]$t, [double]$w, [double]$h, [string]$fill, [string]$line = $null, [double]$lw = 0, [string]$name = $null) {
    $s = $script:Slide.Shapes.AddShape(1, (P $l), (P $t), (P $w), (P $h))
    $s.Shadow.Visible = 0
    if ($fill) { $s.Fill.Solid(); $s.Fill.ForeColor.RGB = RGBc $fill } else { $s.Fill.Visible = 0 }
    if ($line) { $s.Line.Visible = -1; $s.Line.ForeColor.RGB = RGBc $line; $s.Line.Weight = [single]$lw } else { $s.Line.Visible = 0 }
    if ($name) { $s.Name = $name }
    return $s
}

# An empty, dashed outline Fernando fills in later (logo, author, affiliation).
function Add-Placeholder([double]$l, [double]$t, [double]$w, [double]$h, [string]$name, [string]$color = $C.ph) {
    $s = Add-Rect $l $t $w $h $null $color 3 $name
    $s.Line.DashStyle = 4
    return $s
}

function Add-Line([double]$x1, [double]$y1, [double]$x2, [double]$y2, [string]$color, [double]$wPt, [int]$dash = 1, [bool]$arrow = $false) {
    $s = $script:Slide.Shapes.AddLine((P $x1), (P $y1), (P $x2), (P $y2))
    $s.Line.ForeColor.RGB = RGBc $color; $s.Line.Weight = [single]$wPt; $s.Line.DashStyle = [int]$dash
    if ($arrow) { $s.Line.EndArrowheadStyle = 2; $s.Line.EndArrowheadLength = 2; $s.Line.EndArrowheadWidth = 2 }
    return $s
}

# Cubic Bezier from p0 through controls c1, c2 to p3 (inches).
function Add-Curve($p0, $c1, $c2, $p3, [string]$color, [double]$wPt, [bool]$arrow = $false, [int]$dash = 1) {
    $ff = $script:Slide.Shapes.BuildFreeform(0, (P $p0[0]), (P $p0[1]))
    $ff.AddNodes(1, 1, (P $c1[0]), (P $c1[1]), (P $c2[0]), (P $c2[1]), (P $p3[0]), (P $p3[1]))
    $s = $ff.ConvertToShape()
    $s.Fill.Visible = 0; $s.Shadow.Visible = 0
    $s.Line.ForeColor.RGB = RGBc $color; $s.Line.Weight = [single]$wPt; $s.Line.DashStyle = [int]$dash
    if ($arrow) { $s.Line.EndArrowheadStyle = 2; $s.Line.EndArrowheadLength = 2; $s.Line.EndArrowheadWidth = 2 }
    return $s
}

# ---------- rich text ----------
# Paragraphs: a string array. A leading "- " makes a bullet. Inline markup:
#   **bold**   [[accent: bold red]]   ^{superscript}   _{subscript}
function Parse-Rich([string]$s) {
    # keep a number on the same line as its unit
    $s = [regex]::Replace($s, '(?<=\d) (?=(µs|µm|µrad|mrad|mm|ms|nm|kHz|kV|kΩ|mA|V\b|in\b|times\b))', [string][char]0xA0)
    $out = New-Object System.Text.StringBuilder; $runs = @()
    $bold = $false; $acc = $false; $i = 0
    while ($i -lt $s.Length) {
        if ($s.Substring($i).StartsWith('**')) { $bold = -not $bold; $i += 2; continue }
        if ($s.Substring($i).StartsWith('[[')) { $acc = $true; $i += 2; continue }
        if ($s.Substring($i).StartsWith(']]')) { $acc = $false; $i += 2; continue }
        if ($s.Substring($i).StartsWith('^{') -or $s.Substring($i).StartsWith('_{')) {
            $kind = $s[$i]; $end = $s.IndexOf('}', $i)
            $txt = $s.Substring($i + 2, $end - $i - 2)
            $runs += ,@($out.Length, $txt.Length, 'script', [string]$kind)
            [void]$out.Append($txt); $i = $end + 1; continue
        }
        $ch = $s[$i]
        if ($bold) { $runs += ,@($out.Length, 1, 'bold', '') }
        if ($acc)  { $runs += ,@($out.Length, 1, 'acc', '') }
        [void]$out.Append($ch); $i++
    }
    return @{ text = $out.ToString(); runs = $runs }
}

# Fill a TextFrame2 with paragraphs; options: size, color, bold, align (1 left, 2 center, 3 right),
# font, bulletIndent (in), spaceAfter (pt), lineSpacing.
function Set-Rich($tf2, [string[]]$paras, [hashtable]$o) {
    $size = if ($o.size) { $o.size } else { 32 }
    $color = if ($o.color) { $o.color } else { $C.ink }
    $font = if ($o.font) { $o.font } else { $FontBody }
    $parsed = @(); $isBullet = @()
    foreach ($p in $paras) {
        $b = $p.StartsWith('- '); $isBullet += $b
        $parsed += ,(Parse-Rich ($(if ($b) { $p.Substring(2) } else { $p })))
    }
    $full = ($parsed | ForEach-Object { $_.text }) -join "`r"
    $tr = $tf2.TextRange
    $tr.Text = $full
    $tr.Font.Name = $font; $tr.Font.Size = [single]$size; $tr.Font.Fill.ForeColor.RGB = RGBc $color
    $tr.Font.Bold = $(if ($o.bold) { -1 } else { 0 })
    $tr.ParagraphFormat.Alignment = [int]$(if ($o.align) { $o.align } else { 1 })
    $tr.ParagraphFormat.SpaceWithin = [single]$(if ($o.lineSpacing) { $o.lineSpacing } else { 0.95 })
    $sa = if ($o.ContainsKey('spaceAfter')) { $o.spaceAfter } else { [math]::Round($size * 0.45) }
    $offset = 1
    for ($k = 0; $k -lt $parsed.Count; $k++) {
        $para = $tr.Paragraphs($k + 1)
        $para.ParagraphFormat.SpaceAfter = [single]$(if ($k -lt $parsed.Count - 1) { $sa } else { 0 })
        if ($isBullet[$k]) {
            $ind = if ($o.bulletIndent) { $o.bulletIndent } else { 0.42 }
            $para.ParagraphFormat.Bullet.Visible = -1
            $para.ParagraphFormat.Bullet.Character = 8226
            $para.ParagraphFormat.Bullet.Font.Fill.ForeColor.RGB = RGBc $C.red
            $para.ParagraphFormat.LeftIndent = P $ind
            $para.ParagraphFormat.FirstLineIndent = [single](-(P $ind))
        } else {
            $para.ParagraphFormat.Bullet.Visible = 0
        }
        foreach ($r in $parsed[$k].runs) {
            $rng = $tr.Characters($offset + $r[0], $r[1])
            switch ($r[2]) {
                'bold'   { $rng.Font.Bold = -1 }
                'acc'    { $rng.Font.Bold = -1; $rng.Font.Fill.ForeColor.RGB = RGBc $C.red }
                'script' { if ($r[3] -eq '^') { $rng.Font.Superscript = -1 } else { $rng.Font.Subscript = -1 } }
            }
        }
        $offset += $parsed[$k].text.Length + 1
    }
}

# Text box; returns the shape. With -fit the height shrinks to the text (for flow layout);
# without it, text taller than the box is reported as an overflow.
function Add-Text([double]$l, [double]$t, [double]$w, [double]$h, [string[]]$paras, [hashtable]$o = @{}, [switch]$fit, [string]$name = $null) {
    $s = $script:Slide.Shapes.AddTextbox(1, (P $l), (P $t), (P $w), (P $h))
    $tf = $s.TextFrame2
    $tf.WordWrap = -1; $tf.AutoSize = 0; $s.Height = P $h
    $m = if ($o.ContainsKey('margin')) { $o.margin } else { 0 }
    $tf.MarginLeft = P $m; $tf.MarginRight = P $m; $tf.MarginTop = 0; $tf.MarginBottom = 0
    $tf.VerticalAnchor = [int]$(if ($o.anchor) { $o.anchor } else { 1 })   # 1 top, 3 middle, 4 bottom
    Set-Rich $tf $paras $o
    $bh = $tf.TextRange.BoundHeight
    if ($fit) { $s.Height = [single]($bh + 2) }
    elseif ($bh -gt $s.Height + 1) { Warn ("text overflow {0:N2} in > box {1:N2} in: '{2}'" -f ($bh/72), ($s.Height/72), $paras[0].Substring(0, [math]::Min(40, $paras[0].Length))) }
    if ($name) { $s.Name = $name }
    return $s
}

# ---------- pictures ----------
function Get-Aspect([string]$file) {
    $img = [System.Drawing.Image]::FromFile($file); $a = $img.Height / $img.Width; $img.Dispose(); return $a
}
function FigPath([string]$name) { Join-Path $FigDir "$name.png" }

# Picture at (l,t) with width w; returns @(shape, heightIn).
function Add-Pic([string]$name, [double]$l, [double]$t, [double]$w) {
    $f = FigPath $name; $h = $w * (Get-Aspect $f)
    $s = $script:Slide.Shapes.AddPicture($f, 0, -1, (P $l), (P $t), (P $w), (P $h))
    $s.Name = "Figure $name"
    return @($s, $h)
}
# Largest picture that fits inside (l,t,w,h), centered horizontally, top-aligned.
function Add-PicFit([string]$name, [double]$l, [double]$t, [double]$w, [double]$h) {
    $a = Get-Aspect (FigPath $name)
    $pw = [math]::Min($w, $h / $a); $ph = $pw * $a
    $r = Add-Pic $name ($l + ($w - $pw) / 2) $t $pw
    return @($r[0], $ph)
}

# ---------- poster furniture ----------
# Banner: navy band with two logo placeholders, the title and the author/affiliation placeholders.
function Add-Banner([double]$h, [string]$title, [double]$titleSize, [double]$logoW) {
    $W = $script:PW
    [void](Add-Rect 0 0 $W $h $C.navy $null 0 'Title banner')
    $pad = 0.7; $logoH = $h - 2 * $pad
    [void](Add-Placeholder $pad $pad $logoW $logoH 'Logo placeholder (left)' 'C9D3E3')
    [void](Add-Placeholder ($W - $pad - $logoW) $pad $logoW $logoH 'Logo placeholder (right)' 'C9D3E3')
    $tx = $pad + $logoW + 0.8; $tw = $W - 2 * $tx
    $titleBox = Add-Text $tx ($pad - 0.1) $tw ($h * 0.62) @($title) @{ size = $titleSize; bold = $true; color = $C.white; align = 2; font = $FontHead; lineSpacing = 0.9 } -name 'Title'
    $ay = $pad + $titleBox.Height / 72 + 0.25
    $ah = $h - $ay - $pad + 0.1
    $aw = $tw * 0.46
    [void](Add-Placeholder ($tx + $tw/2 - $aw - 0.2) $ay $aw $ah 'Author placeholder' 'C9D3E3')
    [void](Add-Placeholder ($tx + $tw/2 + 0.2) $ay $aw $ah 'Affiliation placeholder' 'C9D3E3')
    if ($ay + $ah -gt $h - 0.3) { Warn 'banner: author placeholders too low' }
}

# Section panel: tinted box with a navy header. Returns the content rectangle @(l, t, w, h).
function Add-Section([double]$l, [double]$t, [double]$w, [double]$h, [string]$title, [double]$headSize = 50, [string]$num = $null) {
    $hh = $headSize / 72 * 1.6
    [void](Add-Rect $l $t $w $h $C.tint $null 0 "Section: $title")
    [void](Add-Rect $l $t $w $hh $C.navy $null 0 "Header: $title")
    $label = if ($num) { "$num  $title" } else { $title }
    [void](Add-Text ($l + 0.45) $t ($w - 0.9) $hh @($label) @{ size = $headSize; bold = $true; color = $C.white; anchor = 3; font = $FontHead } -name "Heading: $title")
    $pad = 0.4
    return @(($l + $pad), ($t + $hh + 0.3), ($w - 2 * $pad), ($h - $hh - 0.3 - $pad))
}

# Flow cursor inside a content rectangle: stacks text and figures, reports overflow.
function New-Flow($rect, [string]$label) { return @{ l = $rect[0]; t = $rect[1]; w = $rect[2]; bottom = $rect[1] + $rect[3]; y = $rect[1]; label = $label; scale = 1.0; last = 0 } }
function Flow-Text($f, [string[]]$paras, [hashtable]$o = @{}, [double]$gap = 0.35, [double]$indent = 0, [double]$width = 0) {
    $w = if ($width -gt 0) { $width } else { $f.w - $indent }
    $s = Add-Text ($f.l + $indent) $f.y $w 30 $paras $o -fit
    $f.y += $s.Height / 72 + $gap; $f.last = $gap
    return $s
}
# A row of figures sharing one height (times the flow's figure scale, capped by the width), centered.
function Flow-Pics($f, [string[]]$names, [double]$height, [double]$gap = 0.3, [double]$hgap = 0.3) {
    $inv = @($names | ForEach-Object { 1.0 / (Get-Aspect (FigPath $_)) })
    $sumInv = ($inv | Measure-Object -Sum).Sum
    $hMax = ($f.w - $hgap * ($names.Count - 1)) / $sumInv
    $height = [math]::Min($height * $f.scale, $hMax)
    $ws = @($inv | ForEach-Object { $height * $_ })
    $total = ($ws | Measure-Object -Sum).Sum + $hgap * ($names.Count - 1)
    $x = $f.l + ($f.w - $total) / 2; $shapes = @()
    for ($k = 0; $k -lt $names.Count; $k++) { $shapes += (Add-Pic $names[$k] $x $f.y $ws[$k])[0]; $x += $ws[$k] + $hgap }
    $f.y += $height + $gap; $f.last = $gap
    return $shapes
}
# One figure on the left (base width figW, times the flow scale, capped at 60% of the flow), text beside it.
function Flow-Side($f, [string]$fig, [double]$figW, [string[]]$paras, [hashtable]$o = @{}, [double]$gap = 0.35) {
    $fw = [math]::Min($figW * $f.scale, $f.w * 0.6)
    $r = Add-Pic $fig $f.l $f.y $fw
    $s = Add-Text ($f.l + $fw + 0.4) $f.y ($f.w - $fw - 0.4) 30 $paras $o -fit
    $f.y += [math]::Max($r[1], $s.Height / 72) + $gap; $f.last = $gap
}
# Step past content drawn directly (schematics, tables, cards); not counted as trailing space.
function Flow-Gap($f, [double]$gap) { $f.y += $gap; $f.last = 0 }

# ---------- auto-balanced columns ----------
# A section is @{ title; num; body = { param($f) ... flow calls ... } }. Render-Section draws the
# content first, then the panel behind it sized to that content. Returns the panel shape.
function Render-Section([double]$l, [double]$t, [double]$w, $sec, [double]$scale, [double]$headSize) {
    $hh = $headSize / 72 * 1.6; $pad = 0.4
    $f = New-Flow @(($l + $pad), ($t + $hh + 0.3), ($w - 2 * $pad), 1000) $sec.title
    $f.scale = $scale
    & $sec.body $f
    $h = ($f.y - $f.last) - $t + $pad
    $panel = Add-Rect $l $t $w $h $C.tint $null 0 "Section: $($sec.title)"
    $panel.ZOrder(1)
    [void](Add-Rect $l $t $w $hh $C.navy $null 0 "Header: $($sec.title)")
    $label = if ($sec.num) { "$($sec.num)  $($sec.title)" } else { $sec.title }
    [void](Add-Text ($l + 0.45) $t ($w - 0.9) $hh @($label) @{ size = $headSize; bold = $true; color = $C.white; anchor = 3; font = $FontHead } -name "Heading: $($sec.title)")
    return $panel
}
# Shapes are indexed by z-order, which ZOrder() changes, so trial renders are undone by shape Id.
function Get-ShapeIds { $ids = New-Object 'System.Collections.Generic.HashSet[int]'; foreach ($s in $script:Slide.Shapes) { [void]$ids.Add($s.Id) }; return ,$ids }
function Remove-ShapesAfter($keep) {
    $doomed = @(); foreach ($s in $script:Slide.Shapes) { if (-not $keep.Contains($s.Id)) { $doomed += $s } }
    foreach ($s in $doomed) { $s.Delete() }
}

# Stack sections in a column from $top to $bot. The figure scale is binary-searched so the column
# fills its height; the last panel absorbs the remaining fraction of an inch.
function Build-Column([double]$l, [double]$w, [double]$top, [double]$bot, [object[]]$sections, [double]$gap = 0.45, [double]$headSize = 46, [string]$label = 'column', [double]$hi = 1.8) {
    $n0 = Get-ShapeIds
    $render = {
        param($s)
        $y = $top; $panels = @()
        foreach ($sec in $sections) { $p = Render-Section $l $y $w $sec $s $headSize; $panels += $p; $y += $p.Height / 72 + $gap }
        return @{ bottom = $y - $gap; panels = $panels }
    }
    $lo = 0.4; $best = $null
    for ($it = 0; $it -lt 7; $it++) {
        $s = ($lo + $hi) / 2
        $r = & $render $s
        Remove-ShapesAfter $n0
        if ($r.bottom -le $bot) { $lo = $s; $best = $s } else { $hi = $s }
    }
    if ($null -eq $best) { $best = 0.4; Warn "${label}: does not fit even at figure scale 0.4" }
    $r = & $render $best
    if ($env:POSTER_DEBUG) { foreach ($pn in $r.panels) { Write-Host ("  {0}: top {1:N2} h {2:N2}" -f $pn.Name, ($pn.Top / 72), ($pn.Height / 72)) } }
    if ($r.bottom -gt $bot + 0.01) { Warn ("{0}: overflows by {1:N2} in" -f $label, ($r.bottom - $bot)) }
    else { $last = $r.panels[-1]; $last.Height = [single]($last.Height + (P ($bot - $r.bottom))) }
    Write-Host ("{0}: figure scale {1:N2}, {2:N2} in left over" -f $label, $best, ($bot - $r.bottom))
}
function Flow-Check($f) {
    $over = $f.y - $f.bottom
    if ($over -gt 0.05) { Warn ("{0}: content overflows by {1:N2} in" -f $f.label, $over) }
    else { Write-Host ("{0}: {1:N2} in to spare" -f $f.label, -$over) }
}

# Big-number callout: value over a small label, centered in (l,t,w).
function Add-Stat([double]$l, [double]$t, [double]$w, [string]$value, [string]$label, [double]$vSize = 96, [double]$lSize = 28, [string]$vColor = $null) {
    $vc = if ($vColor) { $vColor } else { $C.red }
    $v = Add-Text $l $t $w 3 @($value) @{ size = $vSize; bold = $true; color = $vc; align = 2 } -fit
    $lb = Add-Text $l ($t + $v.Height / 72 + 0.05) $w 3 @($label) @{ size = $lSize; color = $C.muted; align = 2 } -fit
    return ($v.Height + $lb.Height) / 72 + 0.05
}

# Table from rows of strings (first row = header). colW in inches. Returns the shape.
function Add-ParamTable([double]$l, [double]$t, [double[]]$colW, [object[]]$rows, [double]$size = 26) {
    $nr = $rows.Count; $nc = $colW.Count
    $ts = $script:Slide.Shapes.AddTable($nr, $nc, (P $l), (P $t), (P ($colW | Measure-Object -Sum).Sum), (P (0.5 * $nr)))
    $ts.Name = 'Operating parameters table'
    $tb = $ts.Table
    $tb.ApplyStyle('{2D5ABB26-0587-4C30-8999-92F81FD0307C}')   # No Style, No Grid
    for ($j = 1; $j -le $nc; $j++) { $tb.Columns($j).Width = P $colW[$j - 1] }
    for ($i = 1; $i -le $nr; $i++) {
        for ($j = 1; $j -le $nc; $j++) {
            $cell = $tb.Cell($i, $j); $sh = $cell.Shape
            $sh.Fill.Visible = -1; $sh.Fill.Solid()
            $sh.Fill.ForeColor.RGB = RGBc $(if ($i -eq 1) { $C.navy2 } elseif ($i % 2 -eq 0) { $C.white } else { $C.tint2 })
            $tf = $sh.TextFrame2
            $tf.MarginLeft = P 0.15; $tf.MarginRight = P 0.15; $tf.MarginTop = P 0.07; $tf.MarginBottom = P 0.07
            $tf.VerticalAnchor = 3
            $o = @{ size = $size; spaceAfter = 0; lineSpacing = 0.9 }
            if ($i -eq 1) { $o.color = $C.white; $o.bold = $true }
            elseif ($j -eq 1) { $o.bold = $true; $o.color = $C.navy }
            Set-Rich $tf @([string]$rows[$i - 1][$j - 1]) $o
        }
    }
    # Size every row to its tallest cell explicitly: the table's own Height lags until PowerPoint lays it out.
    $total = 0
    for ($i = 1; $i -le $nr; $i++) {
        $rh = 0
        for ($j = 1; $j -le $nc; $j++) {
            $tf = $tb.Cell($i, $j).Shape.TextFrame2
            $rh = [math]::Max($rh, $tf.TextRange.BoundHeight + $tf.MarginTop + $tf.MarginBottom)
        }
        $tb.Rows($i).Height = [single]$rh; $total += $rh
    }
    $script:LastTableHeight = $total / 72
    return $ts
}

# ---------- schematics redrawn from the TikZ figure in main.tex ----------
# EOD side view: crystal with graded index between one electrode pair of the quadrupole, the beam
# bending gradually all along the crystal (a parabola), refraction at the exit face enlarging the bend.
# Plus an end-on view showing the four quadrupole electrodes around the aperture.
# (l,t) top-left, u = inches per drawing unit; the drawing spans 11.2 x 2.85 units (7.0 without the end view).
function Draw-EOD([double]$l, [double]$t, [double]$u, [double]$fs = 30, [bool]$endView = $true) {
    $ox = $l + 1.75 * $u; $oy = $t + 1.45 * $u              # drawing origin = beam entry point; spans 2.85 units down
    function X([double]$x) { $ox + $x * $u }
    function Y([double]$y) { $oy - $y * $u }
    $red = $C.red; $bw = [math]::Max(3, 5.5 * $u)
    $cr = Add-Rect (X 0) (Y 0.6) (3 * $u) (1.2 * $u) $null '333333' 1.5 'EOD crystal'
    $cr.Fill.Visible = -1; $cr.Fill.TwoColorGradient(1, 1)
    $cr.Fill.ForeColor.RGB = RGBc '8DB4E2'; $cr.Fill.BackColor.RGB = RGBc 'F4F8FD'
    [void](Add-Rect (X 0) (Y 0.75) (3 * $u) (0.13 * $u) '555555' $null 0 'Electrode +V')
    [void](Add-Rect (X 0) (Y -0.62) (3 * $u) (0.13 * $u) '555555' $null 0 'Electrode ground')
    $lab = @{ size = $fs; align = 2; color = $C.ink }
    [void](Add-Text (X 0) (Y 1.32) (3 * $u) (0.5 * $u) @('+V') $lab)
    [void](Add-Text (X 0) (Y -0.82) (3 * $u) (0.5 * $u) @('ground') $lab)
    [void](Add-Text (X 0) (Y 0.52) (3 * $u) (0.4 * $u) @('+Δn') @{ size = $fs * 0.85; align = 2; color = $C.navy })
    [void](Add-Text (X 0) (Y -0.18) (3 * $u) (0.4 * $u) @('−Δn') @{ size = $fs * 0.85; align = 2; color = $C.navy })
    # incoming beam with flat wavefronts
    [void](Add-Line (X -1.6) (Y 0) (X 0) (Y 0) $red $bw)
    foreach ($x in -1.35, -1.0, -0.65) { [void](Add-Line (X $x) (Y 0.3) (X $x) (Y -0.3) $red ($bw * 0.4)) }
    # gradual bend inside the crystal: quadratic Bezier (0,0)-(1.5,0)-(3,0.2) written as a cubic
    $ex = 3.0; $ey = 0.2
    [void](Add-Curve @((X 0), (Y 0)) @((X 1.0), (Y 0)) @((X 2.0), (Y 0.0667)) @((X $ex), (Y $ey)) $red $bw)
    # undeflected reference and the refracted exit beam
    $ang = 13.0 * [math]::PI / 180; $L = 2.0
    [void](Add-Line (X $ex) (Y $ey) (X ($ex + $L)) (Y $ey) '7F8A99' ($bw * 0.45) 4)
    [void](Add-Line (X $ex) (Y $ey) (X ($ex + $L * [math]::Cos($ang))) (Y ($ey + $L * [math]::Sin($ang))) $red $bw 1 $true)
    foreach ($sd in 0.65, 1.05, 1.45) {
        $cx = $ex + $sd * [math]::Cos($ang); $cy = $ey + $sd * [math]::Sin($ang)
        $px = -[math]::Sin($ang) * 0.3; $py = [math]::Cos($ang) * 0.3
        [void](Add-Line (X ($cx + $px)) (Y ($cy + $py)) (X ($cx - $px)) (Y ($cy - $py)) $red ($bw * 0.4))
    }
    # angle arc, radius R, from 0 to ang
    $R = 1.7; $k = 4.0 / 3.0 * [math]::Tan($ang / 4) * $R
    $p0 = @(($ex + $R), $ey); $p3 = @(($ex + $R * [math]::Cos($ang)), ($ey + $R * [math]::Sin($ang)))
    $c1 = @($p0[0], ($p0[1] + $k)); $c2 = @(($p3[0] + $k * [math]::Sin($ang)), ($p3[1] - $k * [math]::Cos($ang)))
    [void](Add-Curve @((X $p0[0]), (Y $p0[1])) @((X $c1[0]), (Y $c1[1])) @((X $c2[0]), (Y $c2[1])) @((X $p3[0]), (Y $p3[1])) $C.ink 2 $true)
    [void](Add-Text (X ($ex + $R + 0.3)) (Y ($ey + 0.5)) (1.6 * $u) (0.5 * $u) @('θ ∝ V') @{ size = $fs; color = $C.ink })
    [void](Add-Text (X -1.75) (Y -0.45) (1.9 * $u) (0.5 * $u) @('beam in') @{ size = $fs * 0.85; color = $C.muted })
    if ($endView) {
        # end view: square aperture, the same index gradient, four electrodes, beam spot
        $vx = 7.7; $vs = 1.5
        $sq = Add-Rect (X $vx) (Y ($vs / 2)) ($vs * $u) ($vs * $u) $null '333333' 1.5 'End view crystal'
        $sq.Fill.Visible = -1; $sq.Fill.TwoColorGradient(1, 1)
        $sq.Fill.ForeColor.RGB = RGBc '8DB4E2'; $sq.Fill.BackColor.RGB = RGBc 'F4F8FD'
        $e = 0.14; $g = 0.08; $sp = $vs * 0.7
        [void](Add-Rect (X ($vx + ($vs - $sp) / 2)) (Y ($vs / 2 + $g + $e)) ($sp * $u) ($e * $u) '555555' $null 0 'Quadrupole electrode')
        [void](Add-Rect (X ($vx + ($vs - $sp) / 2)) (Y (-$vs / 2 - $g)) ($sp * $u) ($e * $u) '555555' $null 0 'Quadrupole electrode')
        [void](Add-Rect (X ($vx - $g - $e)) (Y ($sp / 2)) ($e * $u) ($sp * $u) '555555' $null 0 'Quadrupole electrode')
        [void](Add-Rect (X ($vx + $vs + $g)) (Y ($sp / 2)) ($e * $u) ($sp * $u) '555555' $null 0 'Quadrupole electrode')
        $d = 0.42
        $spot = $script:Slide.Shapes.AddShape(9, (P (X ($vx + $vs / 2 - $d / 2))), (P (Y ($d / 2))), (P ($d * $u)), (P ($d * $u)))
        $spot.Fill.Solid(); $spot.Fill.ForeColor.RGB = RGBc $red; $spot.Line.Visible = 0; $spot.Shadow.Visible = 0; $spot.Name = 'Beam spot'
        [void](Add-Text (X ($vx - 0.9)) (Y 1.4) (($vs + 1.8) * $u) (0.5 * $u) @('end view: 4 electrodes') @{ size = $fs * 0.85; align = 2; color = $C.muted })
    }
}

# Galvanometer: a mirror turned through θ turns the reflected beam through 2θ.
# Spans 4.4 x 4.0 drawing units from (l,t).
function Draw-Galvo([double]$l, [double]$t, [double]$u, [double]$fs = 30) {
    $ox = $l + 2.9 * $u; $oy = $t + 3.0 * $u
    function X([double]$x) { $ox + $x * $u }
    function Y([double]$y) { $oy - $y * $u }
    $red = $C.red; $bw = [math]::Max(3, 5.5 * $u); $d2r = [math]::PI / 180
    [void](Add-Line (X -2.6) (Y 0) (X -0.05) (Y 0) $red $bw 1 $true)
    [void](Add-Line (X -0.6) (Y -0.6) (X 0.6) (Y 0.6) '7F8A99' 2 4)
    $m = 0.9; $a = 55 * $d2r
    [void](Add-Line (X (-$m * [math]::Cos($a))) (Y (-$m * [math]::Sin($a))) (X ($m * [math]::Cos($a))) (Y ($m * [math]::Sin($a))) '444444' ($bw * 1.3))
    [void](Add-Line (X 0) (Y 0) (X 0) (Y 2.3) '7F8A99' 2 4 $true)
    $b = 110 * $d2r
    [void](Add-Line (X 0) (Y 0) (X (2.4 * [math]::Cos($b))) (Y (2.4 * [math]::Sin($b))) $red $bw 1 $true)
    foreach ($arc in @(@(1.55, 90, 110, '2θ', -0.55, 1.85), @(1.0, 45, 55, 'θ', 0.75, 1.05))) {
        $R = $arc[0]; $a0 = $arc[1] * $d2r; $a1 = $arc[2] * $d2r; $da = $a1 - $a0
        $k = 4.0 / 3.0 * [math]::Tan($da / 4) * $R
        $p0 = @(($R * [math]::Cos($a0)), ($R * [math]::Sin($a0))); $p3 = @(($R * [math]::Cos($a1)), ($R * [math]::Sin($a1)))
        $c1 = @(($p0[0] - $k * [math]::Sin($a0)), ($p0[1] + $k * [math]::Cos($a0)))
        $c2 = @(($p3[0] + $k * [math]::Sin($a1)), ($p3[1] - $k * [math]::Cos($a1)))
        [void](Add-Curve @((X $p0[0]), (Y $p0[1])) @((X $c1[0]), (Y $c1[1])) @((X $c2[0]), (Y $c2[1])) @((X $p3[0]), (Y $p3[1])) $C.ink 2 $true)
        [void](Add-Text (X $arc[4]) (Y $arc[5]) (0.9 * $u) (0.45 * $u) @($arc[3]) @{ size = $fs; color = $C.ink })
    }
}
