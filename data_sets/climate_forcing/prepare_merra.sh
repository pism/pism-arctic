#!/bin/bash


cdo -O selvar,air_temp,air_temp_sd,precipitation -setattribute,air_temp@units="K" -chname,T2MMEAN,air_temp  -setattribute,air_temp_sd@units="K" -aexpr,"air_temp_sd=sqrt(Var_T2MMEAN);" -setattribute,precipitation@units="kg m-2 year-1" -aexpr,"precipitation=3.15569259747e7*TPRECMAX;" -selyear,1980/2009 -mergetime MERRA2_*statM*.nc4.nc MERRA2_1980_2009_MM.nc

cdo yearsum -selvar,precipitation  MERRA2_1980_2009_MM.nc PR_MERRA2_1980_2009_YM.nc
cdo yearmean -selvar,air_temp,air_temp_sd  MERRA2_1980_2009_MM.nc T2M_MERRA2_1980_2009_YM.nc
cdo merge  PR_MERRA2_1980_2009_YM.nc T2M_MERRA2_1980_2009_YM.nc  MERRA2_1980_2009_YM.nc

cdo -O -P 2 remapbil,"../bed_dem/pism_arctic_g5000m.nc" MERRA2_1980_2009_YM.nc pism_g5000m_MERRA2_1980_2009_TM.nc


cdo -O -P 2 remapbil,"../bed_dem/pism_arctic_g5000m.nc" -merge T2M_MERRA2_1980_2009.nc SD_MERRA2_1980_2009.nc PR_MERRA2_1980_2009.nc pism_g5000m_MERRA2_1980_2009_TM.nc

ncks -C -A -v topg,thickness ../bed_dem/pism_arctic_g5000m.nc  pism_g5000m_MERRA2_1980_2009_TM.nc
ncap2 -O -s "usurf=topg+thickness;"  pism_g5000m_MERRA2_1980_2009_TM.nc pism_g5000m_MERRA2_1980_2009_TM.nc
ncatted -a units,usurf,o,c,"m" -a standard_name,usurf,o,c,"surface_elevation" pism_g5000m_MERRA2_1980_2009_TM.nc

