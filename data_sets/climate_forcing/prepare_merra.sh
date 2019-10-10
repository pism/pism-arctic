#!/bin/bash


cdo -O setattribute,air_temp@units="K" -chname,T2MMEAN,air_temp -timmean -selvar,T2MMEAN  -mergetime MERRA2_*statM*.nc4 T2M_MERRA2_1980_2009.nc

cdo -O setattribute,air_temp_sd@units="K" -chname,T2MMEAN,air_temp_sd -timstd -selvar,T2MMEAN  -mergetime MERRA2_*statM*.nc4 SD_MERRA2_1980_2009.nc

cdo -O setattribute,precipitation@units="kg m-2 year-1" -chname,TPRECMAX,precipitation -timmean  -divc,6 -mulc,3.15569259747e7 -selvar,TPRECMAX -mergetime MERRA2_*statM*.nc4 PR_MERRA2_1980_2009.nc

cdo -O -P 2 remapbil,"../bed_dem/pism_arctic_g5000m.nc" -merge T2M_MERRA2_1980_2009.nc SD_MERRA2_1980_2009.nc PR_MERRA2_1980_2009.nc pism_g5000m_MERRA2_1980_2009_TM.nc

ncks -C -A -v topg,thickness ../bed_dem/pism_arctic_g5000m.nc  pism_g5000m_MERRA2_1980_2009_TM.nc
ncap2 -O -s "usurf=topg+thickness;"  pism_g5000m_MERRA2_1980_2009_TM.nc pism_g5000m_MERRA2_1980_2009_TM.nc
ncatted -a units,usurf,o,c,"m" -a standard_name,usurf,o,c,"surface_elevation" pism_g5000m_MERRA2_1980_2009_TM.nc

