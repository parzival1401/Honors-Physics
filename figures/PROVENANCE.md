# Figure provenance

Generated figures are copied in by `scripts/refresh-figures.sh` from the roots listed in that
script. This file records what the figures mean and where they came from, because that context
lives next to the data on the NAS and would otherwise be lost to anyone building from git alone.

Only the figures currently cited by the manuscript are kept here. Figures removed from the
manifest stay recoverable in git history.

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
| `eod-beam-quality` | full width at half maximum in x and y, and ellipticity, against stage position |
| `eod-beam-xcorr` | peak normalised cross-correlation, cross-correlation peak width, and beam displacement in x and y, against stage position |

Produced by `MicroscopeMinFlux.jl` `dev/beam_char_analysis.jl` (branch `beam_char`), which fits
two-dimensional Gaussian profiles per frame and computes the cross-correlation metrics through its
`xcorr2d` and `xcorr_metrics` routines.

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
2026-04-10. One figure per drive channel: `HVA1_polarization_angle_35.png` is channel 1 driving
the deflector with serial 35, `HVA2_polarization_angle_34.png` is channel 2 driving serial 34.
The per-frame camera data for each sit in the `EOD34` and `EOD35` subfolders beside them.

Each sweep runs the amplifier output across roughly plus and minus 200 V and records the beam
centre on the camera, at three input polarizations: parallel to the deflection axis,
perpendicular to it, and with the polarizer removed. Angles are derived from the displacement
using a 5.2 micrometre pixel pitch and a 190 mm crystal-to-camera distance, both stated in the
figure titles; the sensitivity bars are compared against the vendor's quoted minimum of
3 mrad/kV.

| Figure | Shows |
|---|---|
| `eod-polarization-hva1` | beam position and mrad/kV against drive voltage, channel 1 (serial 35) |
| `eod-polarization-hva2` | the same for channel 2 (serial 34) |

Measured sensitivities, in mrad/kV: perpendicular 3.42 and 3.61, unpolarized 2.40 and 3.21,
parallel 0.96 and 1.01, for channels 1 and 2 respectively.

Both plots label the deflector mode as "ODE" rather than "EOD" in the legend and title. That
comes from the analysis script, not from the manuscript, and needs fixing where the plots are
generated.
