# Figure provenance

Generated figures are copied in by `scripts/refresh-figures.sh` from the roots listed in that
script. This file records what the figures mean and where they came from, because that context
lives next to the data on the NAS and would otherwise be lost to anyone building from git alone.

## Experiment 1 — beam degradation along the path

Dataset: NAS `EOD Driver test/beam characterizatiom/gausian/jun2`, acquired 2026-06-02 to
2026-06-04, processed 2026-06-04 by `MicroscopeMinFlux.jl` `dev/analysis/beam_char_mul_pos.jl`
(branch `beam_char`). Camera pixel pitch 5.2 µm; 2D Gaussian fit on a 150 px half-side crop.

Position legend, verbatim from the dataset's `info.txt`:

| Figure | Position | Optics in the path |
|---|---|---|
| `eod-beam-profile-control` | control | reference frame |
| `eod-beam-profile-pos1` | 1 | after EOD 1, no more optics |
| `eod-beam-profile-pos2` | 2 | 1st relay only |
| `eod-beam-profile-pos3` | 3 | 1st relay and EOD 1 only |
| `eod-beam-profile-pos4` | 4 | 1st relay, EOD 1 and EOD 2 |
| `eod-beam-profile-pos5` | 5 | 1st and 2nd relays, EOD 1 and EOD 2 |
| `eod-beam-profile-pos6` | 6 | after beam expansion, both relays, both EODs |
| `eod-beam-profile-pos7` | 7 | polarized only |

Each `*_profile` figure carries the measured frame, the 2D Gaussian fit, a residual map, X and Y
profiles with fit overlay and 1/e² markers, a radial profile, and a metrics summary.

`eod-beam-quality-vs-position` is the combined plot: FWHM in x and y, ellipticity, R², RMS
residual, excess kurtosis, and power-in-bucket against position.
`eod-beam-comparison` places all measured beams side by side.

**Missing:** the manuscript also calls for peak normalised cross-correlation and beam displacement
against position. That figure does not exist. The algorithm is written — `xcorr2d` and
`xcorr_metrics` in `MicroscopeMinFlux.jl` `dev/beam_char_analysis.jl`, returning peak NCC,
cross-correlation peak FWHM, and sub-pixel dx/dy — but that script sweeps stage position for the
ODE modes and has never been run against this along-the-path dataset.

## EOD angle and polarization

`eod-angle-sweep-*` and `eod-polarization-*` are committed from
`project-nsf-minflux/project-log/figures`, themselves derived from the March and April 2026 sweeps.
Note that the polarization-resolved April sweeps used a 190 mm EOD-to-camera lever arm; earlier
figures assuming 350 mm are withdrawn.
