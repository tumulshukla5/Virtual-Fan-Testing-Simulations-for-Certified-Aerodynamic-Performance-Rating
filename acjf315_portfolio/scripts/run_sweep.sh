#!/bin/bash
# run_sweep.sh — ACJF-315 fan curve sweep
# Runs 10 operating points by varying inlet velocity
# Each OP is a separate run; results extracted to sweep_results.csv
# OpenFOAM 12

set -e
INLETS=(0.428 0.713 0.998 1.069 1.283 1.568 1.854 2.139 2.424 2.708)
OPS=(OP01 OP02 OP03 OP04 OP05 OP06 OP07 OP08 OP09 OP10)

echo "OP,inletVel,Q_actual,deltaP" > sweep_results.csv

for i in "${!INLETS[@]}"; do
    OP=${OPS[$i]}
    VEL=${INLETS[$i]}
    echo "=== $OP: inlet velocity = $VEL m/s ==="
    
    # set inlet velocity in 0/U
    sed -i "s/Uinlet [0-9\.]*/Uinlet $VEL/" 0/U
    
    # run solver
    foamRun -solver incompressibleFluid 2>&1 | tail -3
    
    # extract Q and pressure from latest time
    LATEST=$(ls -d [0-9]* | sort -n | tail -1)
    # (post-processing script extracts Q and deltaP)
    python3 extract_op.py $LATEST $OP $VEL >> sweep_results.csv
    
    echo "$OP done"
done

echo "Sweep complete. Results in sweep_results.csv"
