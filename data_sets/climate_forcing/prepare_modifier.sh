#!/bin/bash

for T in -10 -8 -6 -4 -2 0; do
    echo "Creating climate modifier with T = ${T}C"
    python create_modifier.py -T_max ${T} arctic_climate_modifier_${T}C.nc
done
