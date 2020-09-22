#!/bin/bash

for T in -6 -5 -4 -3 -2 -1 -0.5 0 0.5 1; do
    echo "Creating climate modifier with T = ${T}C"
    python create_modifier.py -T_max ${T} climate_modifier_${T}C.nc
done

for T in -5 -4 -3 0; do
    dSL=-110
    echo "Creating climate modifier with T = ${T}C and dSL = ${dSL}m"
    python create_modifier.py -s ${dSL} -T_max ${T} climate_modifier_${T}C_dSL_${dSL}m.nc
done
