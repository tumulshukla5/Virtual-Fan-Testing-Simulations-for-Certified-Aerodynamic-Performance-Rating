# MRF Setup Notes — ACJF-315 Fan Testing

## The MRF approach

The Moving Reference Frame (MRF) method solves the steady-state flow in a rotating reference frame within a cell zone containing the blades. The surrounding domain stays stationary. This avoids transient simulation while capturing the blade-driven pressure rise and thrust.

## Critical settings

### 1. Rotating wall boundary condition
Use `MRFnoSlip`, NOT standard `noSlip`:
```
blades
{
    type    MRFnoSlip;
}
```
Standard `noSlip` does not account for the frame rotation and gives incorrect blade loading.

### 2. Omega sign convention
For a pressure-adding fan (flow enters and exits with a pressure increase), `omega` must be **negative** in OpenFOAM's MRF convention:
```
MRF1
{
    cellZone    rotorZone;
    active      yes;
    omega       -314.16;   // rad/s — NEGATIVE for pressure-adding fan
    axis        (0 0 1);   // axial direction
    origin      (0 0 0);
}
```
A positive omega produces a pressure-reducing (suction) fan instead.

### 3. MRF zone extent
The MRF zone must enclose the **complete blade geometry** including tip clearance. A zone that clips the blade tips produces incorrect thrust and a distorted pressure field.

### 4. Inlet boundary condition
Use a **fixed velocity inlet** (not totalPressure), sweeping across operating points to generate the fan curve. A totalPressure inlet gives a system-resistance curve, not a true fan curve.

## Operating point sweep
10 operating points were simulated by varying the inlet velocity from 0.43 to 2.71 m/s, covering Q = 0.30 to 1.90 m³/s (1,077 to 6,836 CMH).

## Thrust extraction
Thrust is extracted by integrating the pressure and viscous forces on the blade surfaces:
```bash
foamRun -solver incompressibleFluid
postProcess -func 'forceCoeffs'
```
Or directly via `forces` function object in `controlDict`.
