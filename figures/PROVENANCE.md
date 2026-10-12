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
thirty-seconds of an inch across the two deflector modes recorded in the dataset.

| Figure | Shows |
|---|---|
| `eod-setup-beam-degradation` | bench layout for the measurement |
| `eod-beam-quality` | full width at half maximum in x and y, and ellipticity, against stage position |
| `eod-beam-xcorr` | peak normalised cross-correlation, cross-correlation peak width, and beam displacement in x and y, against stage position |

Produced by `MicroscopeMinFlux.jl` `dev/beam_char_analysis.jl` (branch `beam_char`), which fits
two-dimensional Gaussian profiles per frame and computes the cross-correlation metrics through its
`xcorr2d` and `xcorr_metrics` routines.
