# ACJF-315 Axial Jet Fan — Virtual Performance Testing

Virtual fan-performance testing of the **ACJF-315 axial jet fan** in OpenFOAM 12 using a **resolved-blade MRF** approach.

## Overview

A resolved-blade CFD study to predict the thrust of the ACJF-315 axial jet fan from its blade geometry, for quality-assessment against the manufacturer datasheet.

## Result

| Quantity | Value |
|---|---|
| Predicted thrust (resolved-blade MRF) | **34.6 N** |
| Datasheet thrust | 30 N |
| Case | `acjf315_v2`, ~1.25M cells |

## Method — resolved-blade MRF

The harder of the two fan-modelling approaches, used specifically when predicting fan performance **from** blade geometry (as opposed to modelling a fan's effect on a space). Confirmed best-practices from this work:

- Rotating walls must use `MRFnoSlip`.
- `omega` must be explicit rad/s, with a **negative sign** for a pressure-adding fan.
- The MRF zone must enclose the whole blade.
- A flow-specified inlet yields a *system-resistance* curve, not a true fan curve.

## Meshing best-practices (what works / what to avoid)

**Working stack:** Python blade loft → gmsh remesh → blockMesh 360° annular → snappyHexMesh (blunt trailing edge + 1 mm tip clearance for layer coverage) → topoSet rotor cellZone → foamRun incompressibleFluid → GAMG + GaussSeidel → mpirun -np 16.

**Avoid:** cfMesh on twisted blades (hangs); boundary layers in snappy on a lofted STL (skew → GAMG crashes); long 10D ducts (friction decay); periodic 1/4-sector meshing (cyclic BC face-count mismatch).

## Repository contents

```
05-acjf315-fan-testing/
├── README.md
├── methodology/          MRF setup, meshing stack
├── scripts/              blade loft, gmsh, run scripts
└── results/              thrust extraction, convergence
```

## Two fan-modelling methods — pick by the question

| Method | When to use |
|---|---|
| **(A) Resolved-blade MRF** *(this project)* | Predicting fan performance FROM blade geometry. RAM-heavy, finicky. |
| **(B) Momentum / thrust source** | Studying a fan's *effect* on a space (tunnels, car parks). Robust, first-try success — the choice for most paid ventilation work. |

---

*Tools: OpenFOAM 12 · MRF · gmsh · snappyHexMesh · GAMG.*
