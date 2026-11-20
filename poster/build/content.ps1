# content.ps1 — the words and numbers on the posters, all taken from the current main.tex
# (abstract, Sections 2–5 and Tables 2–3). Change a claim here and every poster follows.

$Title = 'Electro-Optic Deflector and Galvanometer Characterization for High-Speed Beam Scanning in MINFLUX Microscopy'

$Words = @{}

$Words.motivation = @(
    'MINFLUX locates a molecule with the dark center of a donut beam, stepped between a few positions around it in every cycle of about 100 µs [1,2].'
    '- Each position is held for about **25 µs**; a step must take a small fraction of that.'
    '- Target: below **2 nm at 10 kHz** with a 30 nm pattern [4]; a 1% scale error moves each position by 0.15 nm.'
    '- **EODs** step the pattern; **galvanometers** re-center it [3].'
)

$Words.concept = @(
    'A quadrupole field grades the refractive index evenly across the beam (Pockels effect, Δn = ½ n^{3} r E): the beam bends a little all along the crystal and leaves at **θ ∝ V** [5].'
    '- No moving part: speed is set by the electronics, not by inertia.'
    '- The price: milliradian angles, high voltage, and a polarization-dependent response.'
)
$Words.conceptCap = 'Schematic, not to scale. The side view draws one electrode pair of the quadrupole.'

$Words.setup = @(
    'Two Leysop ED2-2T-LT-AR561-642 EODs (2 mm aperture): **EOD34** steers x, **EOD35** steers y.'
    '- NI USB-6001 → LF411 voltage follower → HVA200 (gain −20, **±200 V**) → crystal.'
    '- The follower supplies the 10 mA the 1 kΩ amplifier input draws; without it the drive stopped at roughly ±135 to ±160 V.'
    '- Camera lever arm 220 mm, referred to the crystal center; steps read on a 150 kHz quadrant photodiode.'
)
$Words.setupShort = @(
    'Two Leysop ED2-2T-LT-AR561-642 EODs: **EOD34** steers x, **EOD35** steers y.'
    '- NI USB-6001 → LF411 voltage follower → HVA200 (gain −20, **±200 V**).'
    '- Without the follower, the 1 kΩ amplifier input limited the drive to roughly ±135 to ±160 V.'
)
$Words.relayCap = 'The two EODs in series, EOD34 first: L1 and L2 image the deflection plane of EOD34 onto EOD35; the half-wave plate rotates the polarization into the axis of EOD35.'
$Words.circuitCap = 'Drive circuit: each analog output feeds an LF411 follower and then its HVA200. As built, the followers run on ±15 V with 100 nF capacitors.'

$Words.sensitivity = @(
    '- Parallel: 0.89 and 0.90 mrad/kV, **about 3.6 times less**, close to r_{33}/r_{13} of lithium tantalate [6,7]: the half-wave plate is part of the calibration.'
    '- The two channels differ by **5%**: each needs its own calibration.'
)
$Words.linearity = @(
    'Linear to [[about 3% of full scale]] across ±200 V; the requirement is 1%.'
)
$Words.cxCap = 'EOD34 beam center against its drive at three input polarizations.'
$Words.barCap = 'EOD34 sensitivity from each sweep, against the vendor minimum.'

$Words.step = @(
    '- The beam begins to move **0.42 to 0.53 µs** after the amplifier output, arrives in two stages, and is [[settled by 25 µs]], one dwell.'
    '- The 150 kHz detector alone could give this response: an **upper bound** for deflector plus detector.'
)
$Words.stepCap = 'Rising step at 10 kHz averaged over all edges, with the two-stage fit and an ideal step seen through a 150 kHz detector alone.'
$Words.settledCap = 'Fraction of the step reached 5, 10 and 25 µs after the edge.'

$Words.stability = @(
    '- Laser and bench alone: 0.0022 mrad standard deviation over 673 s.'
    '- **EOD35 adds nothing measurable**: about 0.001 mrad within a hold.'
    '- EOD34 run: one slow 0.05 mrad excursion, not yet assigned to the unit, a voltage or the bench.'
)
$Words.stabCap = 'EOD35: deviation from the hold mean at each held voltage (lever arm 380 mm).'

$Words.quality = @(
    '- Beam reproduced over **1.3 to 1.9 mm** of lateral travel in the 2 mm aperture: centering is the first limit.'
    '- Over the full drive the beam stays **within 14% of circular**; along the path, ellipticity stays below 1.2.'
)
$Words.ellipCap = 'Ellipticity against command voltage; unity is a circular beam.'

$Words.donut = @(
    '- Charge-one vortex plate: central intensity **5 ± 2%** of the ring peak, at the limit of the camera.'
    '- The donut follows the drive linearly, but its **null moves 5 to 12% less per volt** than its ring: calibrate on the null.'
    '- The two deflection axes are **14°** from perpendicular.'
)
$Words.donutImgCap = 'The donut at rest: fitted ring radius dashed, null circled.'
$Words.donutDispCap = 'Sweeping EOD35 moves the donut along both camera axes.'

$Words.galvo = @(
    '- **2.03°/V** in x and **1.44°/V** in y, the lower value set by the fold geometry of the second mirror; return to within a few µrad.'
    '- A move is complete **0.4 to 0.45 ms** after the command, longer than the 0.2 ms in which a receptor wanders half the pattern.'
)
$Words.galvoCalCap = 'Optical angle against command voltage.'
$Words.galvoStepCap = 'Small-step response of both axes.'

$Words.conclusions = @(
    '- **EOD characterization: met.** 3.15 and 3.31 mrad/kV, linear to about 3%, in place within the 25 µs dwell.'
    '- **Control interface: met** for calibration and slow control; fast switching falls to the FPGA path.'
    '- **Donut under deflection: met in part.** Null depth bounded by the camera; two-axis pattern not yet tested.'
    '- **Next:** the detector''s own step response, a better null measurement, every scale at the sample.'
)

# Table 2 of main.tex (operating parameters of the EODs), complete.
$Words.eodTable = @(
    ,@('Parameter', 'EOD34', 'EOD35')
    ,@('Axis', 'x', 'y, 14° from perpendicular to x')
    ,@('Sensitivity, polarization perpendicular', '3.15 mrad/kV', '3.31 mrad/kV')
    ,@('Sensitivity, polarization parallel', 'about 3.6 times lower', 'about 3.6 times lower')
    ,@('Linearity', 'within 3% of full scale', 'within 3% of full scale')
    ,@('Drive range', '±10 V command, ±200 V', '±10 V command, ±200 V')
    ,@('Delay after amplifier output', '0.42 to 0.53 µs', '0.42 to 0.53 µs')
    ,@('Fraction of step at 5 µs', 'about 0.80', 'about 0.92')
    ,@('Fraction of step at 10 µs', 'about 0.96', 'about 0.99')
    ,@('Settled', 'by 25 µs', 'by 25 µs')
    ,@('Hold stability', 'one 0.05 mrad excursion during the run, unassigned', 'about 0.001 mrad')
    ,@('Lateral working range', '1.3 to 1.6 mm', '1.3 to 1.9 mm')
    ,@('Donut motion at the camera, null (ring)', '4.25 (4.82) µm/V', '4.26 (4.47) µm/V')
)
$Words.tableNote = 'Sensitivities are referred to the crystal center and carry systematic uncertainties of a few percent; step-response figures are those of EOD and detector together, an upper bound for the EOD.'

$Words.refs = @(
    '[1] F. Balzarotti et al., Science 355, 606 (2017).'
    '[2] Y. Eilers et al., PNAS 115, 6117 (2018).'
    '[3] R. Schmidt et al., Nat. Commun. 12, 1478 (2021).'
    '[4] F. E. Becerra, K. A. Lidke, D. S. Lidke, S. Liu, proposal, University of New Mexico (2024).'
    '[5] G. R. B. E. Römer, P. Bechtold, Physics Procedia 56, 29 (2014).'
    '[6] J. L. Casson et al., J. Opt. Soc. Am. B 21, 1948 (2004).'
    '[7] A. Yariv, P. Yeh, Photonics, 6th ed., Oxford University Press (2007).'
)
$Words.ack = @(
    'I thank Professor Keith Lidke for sponsoring this research project and for full access to the laboratory; Mahsa Habibi for the help at the optical table and with the experiments; Ali Kazemi for the help with the setups; and the Lidke lab. Analysis code and graphs were written with help from Claude Code (Anthropic); the experimental work is my own.'
)
