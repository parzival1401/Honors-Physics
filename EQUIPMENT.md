# Equipment list

Working reference for the hardware used in this thesis. Grouped by function rather than by
purchase order, so a component can be found from the subsystem it belongs to.

The **Documentation** column names the file held in the project where one exists.
"User-supplied" means the specification was given from memory or from a manual not kept in the
project, and so has not been checked against a primary source.

---

## Laser source and drive

| Model | Description | Manufacturer | Key specifications | Documentation |
|---|---|---|---|---|
| HL6366DG | Laser diode, 642 nm, 80 mW, TO-56 | Thorlabs | I_op 150 mA typ / 175 mA max; I_th 75 mA typ | HL6366DGSpecSheet.pdf |
| KLD101 | K-Cube laser diode driver | Thorlabs | 230 mA max; EXT IN (SMA) accepts 0–10 V, 20 kHz bandwidth | etn045988d03.pdf |
| LDM9T | Laser diode mount, integrated TEC and Bias-T | Thorlabs | Bias-T RF modulation >1 GHz (50 Ω); TEC range ~20–30 °C | LDM9T.pdf |

The 642 nm, 80 mW figure on this diode is the source labelled in every bench drawing.

## Beam steering — electro-optic

| Model | Description | Manufacturer | Key specifications | Documentation |
|---|---|---|---|---|
| ED2-2T-LT-AR561-642 | Electro-optic deflector, lithium tantalate (×2) | Leysop | Ø2 mm clear aperture; 60 mm housing; two MHV electrode inputs; AR coated for 561 and 642 nm; quoted minimum sensitivity >3 mrad/kV | **None** — no datasheet shipped for these semi-custom units; only quote line QN/25/11311 |
| HVA200 | High-voltage amplifier (×2) | Thorlabs | ±200 V out; gain −20 (inverting); 1 MHz; 100 mA; 400 V/µs | HVA200Manual.pdf |
| LF411 | JFET-input op-amp | Texas Instruments | Unity-gain BW 4.5 MHz; input impedance 10¹² Ω typ; supply current 560 µA typ at ±15 V | opamp datasheet.pdf |

Deflector serial numbers in the lab are **EOD34** and **EOD35**; one per transverse axis, each
driven single-ended from its own HVA200. Measured sensitivity at the best input polarization is
3.42 mrad/kV (EOD34) and 3.61 mrad/kV (EOD35), against 0.96 and 1.01 with the polarization
parallel to the deflection axis — so the half-wave plate setting is part of the calibration, not
an alignment detail. Lever arm 190 mm, camera pixel pitch 5.2 µm.

## Beam steering — galvanometer

| Model | Description | Manufacturer | Key specifications | Documentation |
|---|---|---|---|---|
| 671 | Galvo servo driver | Not stated | Supply ±18 to ±30 VDC in our jumper mode, abs. max ±30 V, UV trip ±17 V; our supply ±24 V; quiescent 200 mA with no scanner; output 2.5 A RMS typ, 7 A peak guaranteed (11.5 A typ). A ±15 V mode exists but needs resistor and jumper changes | User-supplied, cites 671 manual Table 1 (not in project) |
| 6230 | Galvo scanner | Not stated | Coil 1.07 Ω ±10 %, 173 µH; 7.1 A RMS max at T_case 50 °C; 25 A peak; back-EMF 229 µV/°/s; max rotor temperature 110 °C | User-supplied, cites 62xxH datasheet, 6230 column (not in project) |

## Signal generation

| Model | Description | Manufacturer | Key specifications | Documentation |
|---|---|---|---|---|
| FG085 | miniDDS function generator | JYE Tech | Amplitude reads correctly only into a high-impedance load; halves into 50 Ω | Manual_085F.pdf |
| SDG810 | Function generator, single channel | Siglent Technologies | 10 MHz bandwidth | User-supplied (no doc in project) |

The FG085 amplitude behaviour is a measurement trap: a reading taken into 50 Ω is half the
indicated value.

## Acquisition and control

| Model | Description | Manufacturer | Key specifications | Documentation |
|---|---|---|---|---|
| NI USB-6001 | USB data acquisition device | National Instruments | 14-bit; 20 kS/s aggregate; 8 AI / 2 AO / 13 DIO | 374259a.pdf |
| TriggerScope 16 (R3C, Board 4) | Trigger and I/O controller | ARC (per device ID) | Firmware v.613-MM; no specifications on file | User-supplied device ID string |
| TDS1000B | Digital storage oscilloscope, 2 channel | Tektronix | 40/60/100 MHz depending on model; up to 1 GS/s | oscillsocpe.pdf |

The USB-6001's 20 kS/s aggregate rate is shared across channels, so simultaneous acquisition
divides it.

## Detection

| Model | Description | Manufacturer | Key specifications | Documentation |
|---|---|---|---|---|
| DET10A | Si biased photodetector | Thorlabs | 200–1100 nm; 12 V internal bias battery | 13052d05.pdf |
| PDQ80A | Quadrant position-sensing detector | Thorlabs | 400–1050 nm; 150 kHz; 10 kV/A; supply ±5 to ±15 V | PDQ80A-Spec-Sheet.pdf, PDQ80A-CAD-PDF.pdf |

## Cabling

| Model | Description | Manufacturer | Key specifications | Documentation |
|---|---|---|---|---|
| RG-58/U | 50 Ω coaxial cable | Not identified in doc | 50 Ω nominal; 66 % velocity of propagation for solid PE types | BNc_conectors.pdf |

---

## Open items

Things worth resolving so the list can be cited with confidence.

**The camera is missing.** Every beam characterization in the EOD chapter records onto a camera
sensor, and the analysis depends on its pixel pitch — 5.2 µm is used throughout, with a 1280×1024
frame noted in the drive-chain audit. No camera appears in this list. It should, since the pixel
pitch is an input to every angle derived from a displacement.

**Four entries have no documentation in the project**: the SDG810, the 671 driver, the 6230
scanner, and the TriggerScope. Their specifications are currently unverifiable from inside the
repository.

**Two manufacturers are unidentified.** The 671 servo driver and 6230 scanner are recorded as
"not stated". Both part numbers are consistent with Cambridge Technology galvanometer products,
but that is an inference from the numbering and should be confirmed against the hardware rather
than taken from here.

**Three op-amps now appear across the project.** The LF411 is listed above; the EOD drive-chain
notes separately name an OPA4277 on the DAC evaluation board and an OPA4197 for the preamplifier
buffer, the latter chosen for its 20 V/µs slew rate. These are likely different circuits rather
than a contradiction, but which op-amp sits where is not recorded anywhere, and the preamplifier
board has not been fabricated.

**Not yet listed, though referenced elsewhere**: the TI DAC8814EVM evaluation board, the custom
op-amp preamplifier PCB, and the opto-mechanics for the deflector stations (CRM1LT/M rotation
mounts, PY005/M five-axis stage, kinematic bases).
