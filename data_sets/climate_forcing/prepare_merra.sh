#!/bin/bash

domain=akglaciers

start_year=2000
end_year=2009

t2m_dir=t2m_merra2
pr_dir=pr_merra2
topo_dir=topo_merra2

mkdir -p ${topo_dir}
mkdir -p ${t2m_dir}
mkdir -p ${pr_dir}

# Precip
wget -nc --load-cookies ~/.urs_cookies --save-cookies ~/.urs_cookies --auth-no-challenge=on --keep-session-cookies --content-disposition -i subset_M2TMNXFLX_5.12.4_20200321_200013.txt -P ${pr_dir}
# Temperature
wget -nc --load-cookies ~/.urs_cookies --save-cookies ~/.urs_cookies --auth-no-challenge=on --keep-session-cookies --content-disposition -i subset_M2SMNXSLV_5.12.4_20200321_194428.txt -P ${t2m_dir}
# Topography
wget -nc --load-cookies ~/.urs_cookies --save-cookies ~/.urs_cookies --auth-no-challenge=on --keep-session-cookies --content-disposition -i subset_M2C0NXASM_5.12.4_20200321_205746.txt -P ${topo_dir}

cdo -O -f nc4 selvar,air_temp,air_temp_sd,precipitation -setattribute,precipitation@units="kg m-2 year-1",air_temp@units="degree_Celsius",air_temp_sd@units="K"  -aexpr,"air_temp_sd=sqrt(Var_T2MMEAN);air_temp=T2MMEAN-273.15;precipitation=3.15569259747e7*PRECTOT;" -selyear,${start_year}/${end_year} -merge -mergetime "${t2m_dir}/MERRA2*statM*slv*nc4" -mergetime "${pr_dir}/MERRA2*tavgM*flx*nc4" MERRA2_2000_2009_MM.nc

cdo --reduce_dim -O selvar,usurf -setattribute,usurf@standard_name="surface_elevation",usurf@units="m" -chname,PHIS,usurf -divc,9.80665 ${topo_dir}/MERRA2_101.const_2d_asm_Nx.00000000.nc4.nc4 MERRA2_topo.nc
ncks -A -v usurf  MERRA2_topo.nc  MERRA2_2000_2009_MM.nc

cdo -O -f nc4 -z zip_2 ymonmean  MERRA2_2000_2009_MM.nc MERRA2_2000_2009_YMM.nc
cdo -O -f nc4 -z zip_2 yearmean  MERRA2_2000_2009_MM.nc MERRA2_2000_2009_YM.nc
cdo -O -f nc4 -z zip_2 remapbil,"../bed_dem/pism_${domain}_g2000m.nc" MERRA2_2000_2009_YMM.nc  ${domain}_climate_MERRA2_2000_2009_YMM.nc
adjust_timeline.py -d 2000-1-1 -u days -c 360_day -a 2000-1-1 -p monthly  ${domain}_climate_MERRA2_2000_2009_YMM.nc
cdo -O -f nc4 -z zip_2 remapbil,"../bed_dem/pism_${domain}_g2000m.nc" MERRA2_2000_2009_YM.nc  ${domain}_climate_MERRA2_2000_2009_YM.nc
cdo -O -f nc4 -z zip_2 timmean ${domain}_climate_MERRA2_2000_2009_YM.nc  ${domain}_climate_MERRA2_2000_2009_TM.nc

gdal_translate NETCDF:${domain}_climate_MERRA2_2000_2009_TM.nc:precipitation precipitation_merra2_2000_2009_TM.tif
gdal_translate NETCDF:${domain}_climate_MERRA2_2000_2009_TM.nc:air_temp air_temp_merra2_2000_2009_TM.tif
gdal_translate NETCDF:${domain}_climate_MERRA2_2000_2009_TM.nc:air_temp_sd air_temp_sd_merra2_2000_2009_TM.tif
