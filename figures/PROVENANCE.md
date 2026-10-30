# Figure provenance

Generated figures are copied in by `scripts/refresh-figures.sh` from the roots listed in that
script. This file records what the figures mean and where they came from, because that context
lives next to the data on the NAS and would otherwise be lost to anyone building from git alone.

Only the figures currently cited by the manuscript are kept here. Figures removed from the
manifest stay recoverable in git history.

Every data figure is one graph per file with no title; `main.tex` groups related graphs as (a),
(b), ... subfigures and the caption carries what the title used to. Each data PNG has a sidecar
`<name>.yaml` beside it, copied in by the refresh script, recording the former title, source
dataset, producing script and commit, axes and notes. The same record is embedded in the PNG
itself (read it with `exiftool`, or `read_figure_info` from `MicroscopeMinFlux.jl`
`dev/plot_style.jl`). The split figures were regenerated on 2026-10-26 from `MicroscopeMinFlux.jl`
commit `3dc9c23` (branch `worktree-galvo-delay-analysis`); the combined multi-panel originals are
still on the NAS, unused.

## Naming the two deflectors

The manuscript names the deflectors by serial number only, everywhere. Confirmed by the user on
2026-10-26:

| Serial | Position in path | Scan axis | Amplifier | Legend in the MAR_3 stage-sweep plots |
|---|---|---|---|---|
| EOD34 | first after the fibre | x | HVA1 | EOD P |
| EOD35 | second | y | HVA2 | EOD G |

Datasets label them in other ways (EOD G/P, ODE1/ODE2, HVA1/HVA2 file prefixes, "first/second
deflector"); translate through this table rather than carrying those labels into the text.

## Experiment 1 — beam degradation along the path

Setup drawing: `optics_svg/EOD/EOD_exp_1.png`, exported from the Photoshop source beside it.
642 nm, 80 mW source folded by two mirrors onto the deflector, which rides on a micrometer stage;
the transmitted beam is recorded directly on the camera sensor.

Measured results: NAS `EOD Driver test/beam characterizatiom/movig EDO1/MAR_3`, acquired
2026-03-04, with the deflector translated across the beam on the stage. Both figures are referred
to a control measurement, drawn as a dashed reference line, and both sweep stage position in
millimetres across the two deflector modes recorded in the dataset. The axes were in
thirty-seconds of an inch until the figures were regenerated on 2026-10-19; any earlier reading
of these plots is in those units.

| Figure | Shows |
|---|---|
| `eod-setup-beam-degradation` | bench layout for the measurement |
| `eod-beam-xcorr-ncc` | peak normalised cross-correlation against the control (`beam_quality_xcorr_ncc.png`) |
| `eod-beam-xcorr-fwhm` | width of the cross-correlation peak (`beam_quality_xcorr_fwhm.png`) |
| `eod-beam-xcorr-dx`, `-dy` | beam displacement in x and in y from the correlation peak (`beam_quality_xcorr_dx/dy.png`) |

The manuscript groups the four cross-correlation graphs as `fig:eod-beam-xcorr`. Legends name
the deflectors by serial, EOD34 (blue circles) and EOD35 (red squares), since the relabel of
2026-10-26 (`MicroscopeMinFlux.jl` commit `feb91d5`); earlier versions said EOD P and EOD G.

**Not used: the width and ellipticity graphs from this sweep** (`beam_quality_fwhm_x/y.png`,
`beam_quality_ellipticity.png`). The user flagged that data as wrong on 2026-10-26, so the
figure and the text built on it were removed from the manuscript; they remain in git history
only as a record, not for reuse. Their sweep also read exactly zero at both ends of travel, where
the width search failed.

Produced by `MicroscopeMinFlux.jl` `dev/beam_char_analysis.jl` (branch `beam_char`), which fits
two-dimensional Gaussian profiles per frame and computes the cross-correlation metrics through its
`xcorr2d` and `xcorr_metrics` routines.

### Station definitions for the along-the-path measurement

Distinct from the stage sweep above: here the camera is moved to fixed stations along the beam
path and the Gaussian profile is fitted at each, so that the change between consecutive stations
isolates the element added between them. The fibre output is the reference.

| Station | Position in the path | Measurable |
|---|---|---|
| P1 (control) | immediately after the fibre optic output | yes |
| P2 | after EOD34, before the first relay system | yes |
| P3 | after the first relay system | **no** — no room to place the camera |
| P4 | after EOD35, before the second relay system | yes |
| P5 | after the second relay system | yes |
| P6 | after the beam amplification system | yes |

Five of six stations yield data. Because P3 cannot be reached, the first relay cannot be
isolated: the P2-to-P4 comparison spans the first relay *and* EOD35 together, and
any degradation found there cannot be attributed to one or the other from this dataset alone.

Measured results: NAS `EOD Driver test/beam characterizatiom/gausian/may 26`, acquired
2026-05-26, one frame per station; the station key is also in `specs.txt` there. Produced by
`MicroscopeMinFlux.jl` `dev/analysis/beam_quality_positions.jl` (commit `4ca3fba`). These three
replace the combined `beam_quality_3panel.png`, which stays on the NAS unused.

| Figure | Source | Shows |
|---|---|---|
| `eod-path-fwhm` | `beam_quality_positions_fwhm.png` | FWHM in x and y at each station, log axis |
| `eod-path-ellipticity` | `beam_quality_positions_ellipticity.png` | ellipticity (max/min FWHM) at each station |
| `eod-path-r2` | `beam_quality_positions_r2.png` | Gaussian fit R² at each station |

The manuscript groups them as `fig:eod-path`, (a) to (c). P6 is ringed in every panel: its peak
is 9 counts, below the 15-count level at which the half-maximum search clears the noise, so its
width and fit are soft. Its FWHM is roughly six to seven times the others, hence the log axis.

An earlier legend for a seven-position `gausian/jun2` dataset described the stations differently,
by which optics were present rather than by where the camera sat. That dataset is not the one
cited by the manuscript; the table above supersedes it.

## Beam quality against deflection voltage

Measured results: NAS `EOD Driver test/beam characterizatiom/angle/mar_25`. Both deflectors are
swept across the drive range while the beam is recorded on the camera, and a two-dimensional
Gaussian is fitted per frame.

The x axis throughout is the **command voltage**, ±10 V, not the crystal drive. The HVA200
multiplies it by twenty, so the full sweep corresponds to ±200 V across the electrodes.

| Figure | Source | Shows |
|---|---|---|
| `eod-quality-voltage-fwhm` | `1_fwhm.png` | FWHM in x and y against sweep voltage, both units, with the undeflected control as a dashed line |
| `eod-quality-voltage-ellipticity` | `2_ellipticity.png` | ellipticity (max/min FWHM) against sweep voltage, both units |
| `eod-quality-voltage-r2` | `3_r2.png` | Gaussian fit R² against sweep voltage, both units |
| `eod-quality-voltage-omega` | `4_omega.png` | 1/e² radius against sweep voltage, fit-derived and FWHM-derived, both units |

The manuscript groups all four as one 2×2 figure, `fig:eod-quality-voltage`, (a) to (d) in the
order above.

What the set shows, in brief. The widths along the two axes move in opposite senses as the drive
advances, so the beam turns elliptical rather than changing size uniformly; the measured
ellipticity stays modest, within about fourteen percent of circular at worst. The two units do
not track each other — EOD34 departs from circular progressively toward positive drive, while
EOD35 is worst near the middle of the range.

Two independent indications that the profile is not exactly Gaussian: the fit R² sits between
roughly 0.94 and 0.97 rather than approaching unity, and the 1/e² radius derived from the fit
disagrees with the radius derived from the measured FWHM by roughly ten percent, in the same
direction for both units. For a true Gaussian those two derivations must agree, so the gap is a
shape discrepancy rather than noise. Worth resolving before any width from these plots is quoted
as a beam parameter.

The source filenames are generic ordinals (`1_fwhm.png` and so on) and are unique only because a
single source root holds them; see the warning in the manifest.

## Experiment 2 — beam deflection against drive voltage

Setup drawing: `optics_svg/EOD/EOD_exp_2_beam delfection.png`, exported from
`optics_svg/EOD_exp_2_beam delfection.psd` one directory up. Note the typo in both filenames,
"delfection"; the manifest glob reproduces it deliberately so the match keeps working, and
renaming the source means editing the manifest to match.

Same 642 nm, 80 mW source and two steering mirrors as experiment 1, but the deflector is driven
instead of translated: a USB-6001 issues the command voltage, an HVA200 high-voltage amplifier
raises it to the crystal drive level, and the deflected beam lands directly on the camera sensor.
The crystal-to-sensor distance is the lever arm that converts measured displacement into angle.

| Figure | Shows |
|---|---|
| `eod-setup-beam-deflection` | bench layout for the voltage-sweep measurement |

Measured results are not in the manuscript yet. The voltage sweep, the calibration curve in
mrad/V, and the comparison against the manufacturer specification remain to be produced; this
entry covers the setup drawing only.

## Experiment 3 — two deflectors relayed onto one another

Setup drawing: `optics_svg/EOD/EOD_exp_3_relay system_2EOD.png`, exported from the Photoshop
source of the same name in the `optics_svg` root.

Two deflectors in series, each on its own HVA200. Lenses L1 and L2 sit one focal length from the
neighbouring crystal and two focal lengths apart, so the deflection plane of the first crystal is
imaged onto the second and the pair acts as a single two-axis deflector. A half-wave plate
between them rotates the polarization into the second crystal's axis. The beam is recorded
directly on the camera.

| Figure | Shows |
|---|---|
| `eod-setup-relay-two-deflectors` | bench layout for the relayed deflector pair |

Setup drawing only; no measurements from this configuration are in the manuscript yet.

## Experiment 4 — donut creation on the relayed pair

Setup drawing: `optics_svg/EOD/EOD_exp_4_relay system_2EOD_donut_creation.png`, exported from the
Photoshop source of the same name in the `optics_svg` root.

The relayed deflector pair of experiment 3, with a quarter-wave plate after the second crystal
and a further lens train (L3 to L5) carrying the beam to the camera. Note that the drawing labels
no vortex or phase element, so the figure as drawn does not yet show what imposes the helical
phase; this should be checked against the bench before the donut section is written up.

| Figure | Shows |
|---|---|
| `donut-setup-creation` | bench layout for the donut-forming path |

Setup drawing only; no measurements from this configuration are in the manuscript yet.

## Polarization dependence of the deflection sensitivity

Measured results: NAS `EOD Driver test/beam characterizatiom/polarization/apr10`, acquired
2026-04-10. Four graphs per drive channel, `HVA<n>_polarization_{radial,cx,cy,mrad_per_kV}.png`.
These replace the combined `HVA1_polarization_angle_35.png` and `HVA2_polarization_angle_34.png`,
which carried a serial number in the filename; the split names carry none.

**HVA1 drives EOD34 and HVA2 drives EOD35** (confirmed by the user, 2026-10-26). The old
combined filenames carried the suffixes the other way round (`HVA1_..._35`, `HVA2_..._34`); those
suffixes were wrong. The data folders, the project's EOD audit and the measured values all agree
with the confirmed pairing: the audit records EOD34 at 0.96 / 2.40 / 3.42 mrad/kV (190 mm), which
is exactly the HVA1 result, and EOD35 at 1.01 / 3.21 / 3.61, exactly the HVA2 result. The
per-frame camera data for each sit in the `EOD34` and `EOD35` subfolders beside them.

Each sweep runs the amplifier output across roughly plus and minus 200 V and records the beam
centre on the camera, at three input polarizations: parallel to the deflection axis,
perpendicular to it, and with the polarizer removed. Angles are derived from the displacement
using a 5.2 micrometre pixel pitch and a 220 mm lever arm, both recorded in the sidecars; the
sensitivity bars are compared against the vendor's quoted minimum of 3 mrad/kV.

**Lever arm.** The 190 mm measured on the bench runs from the deflector housing face to the
sensor. The vendor puts the deflection pivot at the centre of the 60 mm housing, 30 mm further
back, so the angle is referred to 220 mm. The figures were regenerated at 220 mm on 2026-10-26
(`MicroscopeMinFlux.jl` commit `d390417`); anything computed earlier used 190 mm and overstates
every sensitivity by the factor 220/190, about sixteen percent.

| Figure | Shows |
|---|---|
| `eod-polarization-hva1-radial` | radial beam-centre position against amplifier output, EOD34 |
| `eod-polarization-hva1-cx`, `-cy` | beam centre in x and in y against amplifier output, EOD34 |
| `eod-polarization-hva1-mrad-per-kv` | sensitivity per input polarization against the 3 mrad/kV minimum, EOD34 |
| `eod-polarization-hva2-*` | the same four for EOD35 |

Each deflector is one 2×2 figure in the manuscript, (a) to (d) in the order above. The stable
filenames keep the amplifier name; the text and captions use the serial.

Measured sensitivities at 220 mm, in mrad/kV: perpendicular 2.95 and 3.12, unpolarized 2.08 and
2.77, parallel 0.83 and 0.88, for EOD34 and EOD35 respectively. At 190 mm these were 3.42 and
3.61, 2.40 and 3.21, 0.96 and 1.01; the audit values quoted above are the 190 mm ones.

The combined plots labelled the deflector "ODE" rather than "EOD" in legend and title. The split
graphs have no title and their legends name only the polarization, so that no longer shows.

## Pointing stability at held drive voltages

Measured results: NAS `EOD Driver test/beam characterizatiom/angle_stability/apr_4`, acquired
2026-04-03. Each deflector held at nine command voltages, −10 to +10 V in 2.5 V steps, 40 frames
per hold about 0.9 s apart (from the file timestamps), so roughly 36 s per hold. Regenerated by
`MicroscopeMinFlux.jl` commit `89db96a`.

The sources say EOD1 and EOD2: **EOD1 = HVA1 = EOD34, EOD2 = HVA2 = EOD35** (folders `EOD34`,
`EOD35` beside them). The stable names use the serial. The `ODE*_` files in the same folder are
old diagnostics and are not cited.

**Lever arm 380 mm** — this is a different bench from the polarization one: 350 mm from the
housing face to the sensor, plus the same 30 mm to the crystal centre (user-confirmed). One pixel
is about 0.0137 mrad.

| Figure | Shows |
|---|---|
| `eod-stab-eod34-timeseries-{m10v,0v,p10v}` | deviation from hold mean, x and y, frame by frame, EOD34 at −10, 0, +10 V (shared y range) |
| `eod-stab-eod35-timeseries-*` | the same for EOD35 |
| `eod-stab-eod34-std`, `-p2p` | standard deviation and peak-to-peak of radial wander per hold, in px, EOD34 |
| `eod-stab-eod35-std`, `-p2p` | the same for EOD35 |
| `eod-stab-eod34-angular`, `eod-stab-eod35-angular` | box plot of angular wander per hold, σ labelled, in mrad |

Manuscript figures: `fig:eod-stab-timeseries` (2×3), `fig:eod-stab-spread` (2×2),
`fig:eod-stab-angular` (1×2). In brief: EOD35 sits at about 0.001 mrad σ throughout; EOD34
matches that at −2.5 V and positive voltages but drifts slowly through the hold at −10, −7.5,
−5 and 0 V (σ 0.003–0.007 mrad; about 0.03 mrad over 36 s at 0 V, mostly in y).

## Laser pointing stability baseline

Measured results: NAS `EOD Driver test/beam characterizatiom/stability_laser/MAR_27`, 1000
frames over 673 s (14:10:34 to 14:21:46, about 0.67 s per frame). Lever arm 380 mm.

Three corrections to what the old combined figure implied:

- The old time axis was step × settle time and read 100 s; the real span is 673 s, so any drift
  rate read off the old plot was about 6.7 times too fast.
- It measures the laser and bench, not the deflector: the files come from the sweep program, but
  the HVA1 monitor stayed within 0.5 V and the beam did not follow the command.
- At 380 mm: σ 0.0019 mrad in x, 0.0046 in y, 0.0022 total; peak-to-peak 0.0119, 0.0199, 0.0116.

| Figure | Shows |
|---|---|
| `laser-stab-angular-x`, `-y`, `-total` | angular deviation from the mean against elapsed time |
| `laser-stab-xy-scatter` | beam-centre displacement on the camera, coloured by time |

Manuscript figure: `fig:laser-stab` (2×2).

## Donut beam (jun4)

Measured results: NAS `EOD Driver test/beam characterizatiom/donut/jun4`, analysed by
MicroscopeMinFlux.jl `dev/analysis/donut_jun4_thesis.jl` at ce95c01 (branch
worktree-galvo-delay-analysis, not pushed). Every per-run number is in `donut_runs_summary.csv`,
and every sweep step is in `deflec_donut/donut_sweep_steps.csv`.

Bench, from the user's third drawing of 2026-10-30, in path order (the two earlier drawings
placed the QWP and the plate differently):

1. EOD34, then the L1–L2 relay.
2. A half-wave plate, then EOD35.
3. The L3–L4 and L5–L6 relays.
4. The vortex plate (Vortex Photonics V-633-10-1, charge 1), one focal length past L6, in the
   plane conjugate to both deflectors.
5. Fold mirror M3.
6. A quarter-wave plate, just ahead of L7.
7. The camera in the focal plane of L7: a Thorlabs DCx, MONO8 8-bit, 5.2 µm pixels, 10 ms
   exposure.

"Polarizer" runs have a polarizer ahead of the QWP. The focal length of L7 is not recorded, so
displacements stay in µm at the camera.

Corrections to the earlier analysis of this data:

- **Fit model.** The old fit used a charge-2 model, (r/w)^4. The refit is charge 1. The l=1 and
  l=2 R² values agree within 0.03, so the radial profile alone cannot fix the charge; the charge
  is the plate's.
- **Extinction-ratio extremes.** Both were artifacts.
  - 1.33 (donut_pol): the ring centre was misdetected.
  - 0.0005 (min_ER): the minimum pixel, which was 0.
  - Now the null is the mean of the darkest 3×3 spot inside 0.5 r_peak, against an annulus
    background. It is reported as an upper bound when unresolved.
  - Only the optimized run resolves a null: 0.048 ± 0.018, on a 1-ADU floor of 0.039.
- **Sweep control.** The old control ER of 0.0175 was the minimum-pixel artifact; the control is
  0.035 ± 0.016.
- **Symmetry measures.** CV and the Fourier terms now use background-subtracted profiles, with
  m_k = 2|F_k|/|F_0|.
- **First frame excluded.** Step 1 of the X sweep (+10 V) predates the move and is excluded.

Sweep pairing: X = HVA1 = EOD34, Y = HVA2 = EOD35, from the sweep_channel attribute.

- **EOD34:** 4.82 µm/V along x, with no cross-motion.
- **EOD35:** 4.33 µm/V along y plus −1.08 µm/V along x, i.e. 4.47 µm/V at −14.0° from y. The
  EOD35 axis is rotated 14° relative to EOD34.

| Figure | Shows |
|---|---|
| `donut-static-image` | optimized run, camera frame about the fitted centre, fitted ring radius and null marked |
| `donut-static-radial`, `-residual` | radial profile against l=1, l=2 and Gaussian fits, and the residuals |
| `donut-static-azimuthal` | ring intensity around r_peak |
| `donut-runs-er`, `donut-runs-cv` | extinction ratio (or bound) and ring CV for the five runs |
| `donut-sweep-ncc`, `donut-sweep-er` | shape similarity to the control and extinction ratio during both sweeps |
| `donut-sweep-disp-eod34`, `-eod35` | displacement at the camera with straight-line fits |

Manuscript: `fig:donut-static`, `tab:donut-runs`, `fig:donut-runs`, `fig:donut-sweep`.

**Lens focal lengths (user, 2026-10-30):** 100 mm for every lens except L5, 13.5 mm; L5-L6 is a 7.4x expander and the camera is 100 mm after L7. These do not reproduce the data: they predict about 0.8 um/V displacement and a ring a few um in radius, against 4.8 um/V and 86 um measured. Displacements therefore stay in um at the camera until the L7-to-camera distance and the beam size at the plate are measured.
