#!/bin/bash

# python prepare_merra.py

cdo -O setattribute,air_temp@units="deg_C" -chname,T2M,air_temp -timmean -yearmean -selvar,T2M  -mergetime MERRA2_*.nc4 T2M_MERRA2_1980_2009.nc

cdo -O setattribute,precipitation@units="kg m-2 year-1" -chname,TQL,precipitation  -timmean -yearsum -selvar,TQL -mergetime MERRA2_*.nc4 TQL_MERRA2_1980_2009.nc


cdo -O -P 2 remapbil,"../bed_dem/pism_arctic_g5000m.nc"  MERRA2_1980_2009.nc  pism_g5000m_MERRA2_1980_2009_TM.nc

ncks -C -A -v topg,thickness ../bed_dem/pism_arctic_g5000m.nc  pism_g5000m_MERRA2_1980_2009_TM.nc
ncap2 -O -s "usurf=topg+thickness;"  pism_g5000m_MERRA2_1980_2009_TM.nc pism_g5000m_MERRA2_1980_2009_TM.nc
ncatted -a units,usurf,o,c,"m" -a standard_name,usurf,o,c,"surface_elevation" pism_g5000m_MERRA2_1980_2009_TM.nc
