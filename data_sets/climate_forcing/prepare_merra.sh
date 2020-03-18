#!/bin/bash

cdo -O selvar,air_temp,air_temp_sd -setattribute,air_temp@units="deg_C",air_temp_sd@units="K" -aexpr,"air_temp_sd=sqrt(Var_T2MMEAN);air_temp=T2MMEAN-273.13" -selyear,2000/2009 -mergetime MERRA2_*statM*slv*.nc4.nc T2M_MERRA2_2000_2009_MM.nc

cdo -O selvar,precipitation -setattribute,precipitation@units="kg m-2 year-1" -aexpr,"precipitation=3.15569259747e7*PRECTOT;" -selyear,2000/2009 -mergetime MERRA2_*00.tavgM_2d_flx_Nx.*.nc4 PR_MERRA2_2000_2009_MM.nc

cdo --reduce_dim -O selvar,usurf -setattribute,usurf@standard_name="surface_elevation",usurf@units="m" -chname,PHIS,usurf -divc,9.80665 MERRA2_101.const_2d_asm_Nx.00000000.nc4 MERRA2_topo.nc

cdo -O -f nc4 -z zip_2 merge  T2M_MERRA2_2000_2009_MM.nc PR_MERRA2_2000_2009_MM.nc MERRA2_topo.nc MERRA2_2000_2009_MM.nc
cdo -O -f nc4 -z zip_2 ymonmean  MERRA2_2000_2009_MM.nc MERRA2_2000_2009_YMM.nc
cdo -O -f nc4 -z zip_2 yearmean  MERRA2_2000_2009_MM.nc MERRA2_2000_2009_YM.nc
cdo -O -f nc4 -z zip_2 remapbil,"../bed_dem/pism_arctic_g5000m.nc" MERRA2_2000_2009_YMM.nc pism_g5000m_MERRA2_2000_2009_YMM.nc
cdo -O -f nc4 -z zip_2 remapbil,"../bed_dem/pism_arctic_g5000m.nc" MERRA2_2000_2009_YM.nc pism_g5000m_MERRA2_2000_2009_YM.nc
cdo -O -f nc4 -z zip_2 timmean pism_g5000m_MERRA2_2000_2009_YM.nc pism_g5000m_MERRA2_2000_2009_TM.nc
