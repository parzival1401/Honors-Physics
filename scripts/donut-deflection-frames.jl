# donut-deflection-frames.jl
# Two camera frames from the preliminary donut deflection sweep (may8/angle_stability):
# EOD34 (HVA1) at -10 V and +10 V of command, the other EOD held at 0 V. Both are cropped
# about the same fixed point, the fitted centre stored with the undeflected control frame,
# and drawn on one colour scale, so the shift of the donut between them is visible.
#
# Writes figures/donut-prelim-eod34-m10v.png and figures/donut-prelim-eod34-p10v.png
# (+ .yaml sidecars) directly; they are not in figures.manifest.
#
# Run from the analysis repo's dev environment, which has HDF5 and CairoMakie:
#   cd MicroscopeMinFlux.jl/<worktree>/dev && julia --project=. <this file>

using HDF5, CairoMakie

const STYLE = raw"C:\Users\Parzival1401\Documents\MicroscopeMinFlux.jl\.claude\worktrees\galvo-delay-analysis\dev\plot_style.jl"
include(STYLE)
apply_plot_style!()

const DATA   = raw"Y:\Projects\NSF-MINFLUX\projects\Data\Evaluation Experiments\EOD Driver test\beam characterizatiom\donut\may8\angle_stability"
const OUT    = joinpath(@__DIR__, "..", "figures")
const SCRIPT = @__FILE__
const PX_UM  = 5.2      # camera pixel pitch, µm
const HALF   = 30       # px: crop half-width, as for the static donut figures

ctrl_cx, ctrl_cy = h5open(joinpath(DATA, "control", "beam_characterization.h5")) do h
    read_attribute(h, "center_x"), read_attribute(h, "center_y")
end
cx0, cy0 = round(Int, ctrl_cx), round(Int, ctrl_cy)
xr, yr = cx0-HALF:cx0+HALF, cy0-HALF:cy0+HALF
xs, ys = (xr .- ctrl_cx) .* PX_UM, (yr .- ctrl_cy) .* PX_UM

runs = [("m10v", "donut_hva1_step001_-10.0V_2026-05-08_120449.h5", "-10 V"),
        ("p10v", "donut_hva1_step200_10.0V_2026-05-08_120648.h5", "+10 V")]
frames = map(runs) do (_, f, _)
    h5open(joinpath(DATA, "hva1", f)) do h
        read(h["frame"])[xr, yr], read_attribute(h, "center_x"), read_attribute(h, "center_y")
    end
end
cmax = maximum(maximum(first(fr)) for fr in frames)

for ((tag, f, volts), (sub, cx, cy)) in zip(runs, frames)
    fig = panel_figure()
    ax = Axis(fig[1, 1], aspect = DataAspect(), xlabel = "x (µm)", ylabel = "y (µm)")
    hm = heatmap!(ax, xs, ys, sub; colormap = :inferno, colorrange = (0, cmax))
    scatter!(ax, [0.0], [0.0]; marker = :cross, color = :cyan, markersize = 4)
    Colorbar(fig[1, 2], hm; label = "Counts (ADU)")
    save_figure(joinpath(OUT, "donut-prelim-eod34-$tag.png"), fig;
        id = "donut_prelim_eod34_$tag", source = joinpath(DATA, "hva1", f), script = SCRIPT,
        x = "x at the camera from the control frame's centre (µm)",
        y = "y at the camera from the control frame's centre (µm)",
        shows = "Camera frame of the donut with EOD34 (HVA1) at $volts of command, EOD35 at 0 V; cropped ±$HALF px about the stored centre of the undeflected control frame (cross); colour scale shared by the -10 V and +10 V frames.",
        notes = "Preliminary sweep, before the donut was optimized: each EOD stepped from -10 V to +10 V in 200 steps, control frame at 0 V through all optics. Stored centre of this frame ($(round(cx; digits = 1)), $(round(cy; digits = 1))) px against the control's ($(round(ctrl_cx; digits = 1)), $(round(ctrl_cy; digits = 1))) px. Camera x/y are the first/second index of the stored frame (x = 1280-px side). Counts are 8-bit ADU, 10 ms exposure.")
end
