#!opt/local/bin/bash

export HDF5_USE_FILE_LOCKING=FALSE
epsg=5936

x_min=-5800000.0
y_min=-5800000.0
x_max=9800000.0
y_max=9800000.0

domain=akglaciers

x_min=1600000.0
x_max=3600000.0
y_min=-1920000.0
y_max=-860000.0


options='-overwrite -t_srs EPSG:5936 -r bilinear -co FORMAT=NC4 -co COMPRESS=DEFLATE -co ZLEVEL=2'
grid=1000

file=pr_total_mm_iem_cru_TS40_1901_2015.zip
wget -nc http://data.snap.uaf.edu/data/IEM/Inputs/historical/precipitation/$file
unzip -f $file

file=tas_mean_C_iem_cru_TS40_1901_2015.zip
wget -nc http://data.snap.uaf.edu/data/IEM/Inputs/historical/temperature/$file
unzip -f  $file

dem_file=iem_prism_dem_1km.tif
wget -nc http://data.snap.uaf.edu/data/IEM/Inputs/ancillary/elevation/$file
unzip -f  $file
gdalwarp $options -te $x_min $y_min $x_max $y_max -tr $grid $grid ${dem_file} ${domain}_iem_prism_dem_1km_${domain}.nc

start_year=1980
end_year=2004

pr_prefix=pr_cru_TS40_1km
tas_prefix=tas_cru_TS40_1km

#choose the years and the domain
for year in {1980..2004}; do
    for mon in 0{1..9} {10..12} ; do
        gdalwarp $options -te $x_min $y_min $x_max $y_max -tr $grid $grid ${pr_prefix}/pr_total_mm_CRU_TS40_historical_${mon}_${year}.tif ${pr_prefix}/pr_total_mm_CRU_TS40_historical_${mon}_${year}_${domain}.nc
        gdalwarp $options -te $x_min $y_min $x_max $y_max -tr $grid $grid ${tas_prefix}/tas_mean_C_CRU_TS40_historical_${mon}_${year}.tif ${tas_prefix}/tas_mean_C_CRU_TS40_historical_${mon}_${year}_${domain}.nc
        cdo -L settaxis,${year}-${mon}-1 -setreftime,${start_year}-1-1  ${pr_prefix}/pr_total_mm_CRU_TS40_historical_${mon}_${year}_${domain}.nc  ${pr_prefix}/pr_total_mm_CRU_TS40_historical_${mon}_${year}_cdo_${domain}.nc
        cdo -L settaxis,${year}-${mon}-1 -setreftime,${start_year}-1-1  ${tas_prefix}/tas_mean_C_CRU_TS40_historical_${mon}_${year}_${domain}.nc  ${tas_prefix}/tas_mean_C_CRU_TS40_historical_${mon}_${year}_cdo_${domain}.nc
    done
done

#set the variable attributes, rename them
cdo -L setattribute,precipitation@units="kg m-2 year-1",precipitation@standard_name="precipitation_flux",precipitation@long_name="precipitation" -chname,Band1,precipitation -mulc,12 -mergetime ${pr_prefix}/pr_total_mm_CRU_TS40_historical_*_*_cdo_${domain}.nc  pr_total_mm_CRU_TS40_historical_${start_year}_${end_year}_${domain}_MM.nc
cdo -L setattribute,air_temp@units="degree_Celsius",air_temp@long_name="2-m air temperature" -selvar,air_temp -chname,Band1,air_temp -mergetime ${tas_prefix}/tas_mean_C_CRU_TS40_historical_*_*_cdo_${domain}.nc tas_mean_C_CRU_TS40_historical_${start_year}_${end_year}_${domain}_MM.nc
cdo -L setattribute,usurf@units="m",usurf@standard_name="surface_elevation",usurf@long_name="surface elevation" -chname,Band1,usurf  ${domain}_iem_prism_dem_1km_${domain}.nc usurf_akcanada_1km_dem_${domain}.nc

#merge tas, pr and usurf, MM
cdo -L -O -f nc4 -z zip_2 merge usurf_akcanada_1km_dem_${domain}.nc -selyear,${start_year}/${end_year} pr_total_mm_CRU_TS40_historical_${start_year}_${end_year}_${domain}_MM.nc  -selyear,${start_year}/${end_year} tas_mean_C_CRU_TS40_historical_${start_year}_${end_year}_${domain}_MM.nc ${domain}_climate_cru_TS40_historical_${start_year}_${end_year}_MM.nc
adjust_timeline.py -a ${start_year}-1-1 -d ${start_year}-1-1 -p monthly ${domain}_climate_cru_TS40_historical_${start_year}_${end_year}_MM.nc

#calculate yearly monthly means and stddev
cdo -L -O -f nc4 -z zip_2 selvar,precipitation,air_temp -ymonmean ${domain}_climate_cru_TS40_historical_${start_year}_${end_year}_MM.nc ${domain}_climate_cru_TS40_historical_${start_year}_${end_year}_YMM_uf.nc
#cdo -L -O -f nc4 -z zip_2 selvar,precipitation,air_temp -ymonstd ${domain}_climate_cru_TS40_historical_${start_year}_${end_year}_MM.nc ${domain}_climate_cru_TS40_historical_${start_year}_${end_year}_YMMstd_uf.nc #there is no submonthly data
mpirun -np 8 fill_missing_petsc.py -v air_temp,precipitation ${domain}_climate_cru_TS40_historical_${start_year}_${end_year}_YMM_uf.nc ${domain}_climate_cru_TS40_historical_${start_year}_${end_year}_YMM.nc
adjust_timeline.py -a 1-1-1 -d 1-1-1 -p monthly -c 365_day ${domain}_climate_cru_TS40_historical_${start_year}_${end_year}_YMM.nc
ncks -4 -L 2 -A usurf_akcanada_1km_dem_${domain}.nc ${domain}_climate_cru_TS40_historical_${start_year}_${end_year}_YMM.nc
cdo setmisstoc,0 ${domain}_climate_cru_TS40_historical_${start_year}_${end_year}_YMM.nc tmp_${domain}_climate_cru_TS40_historical_${start_year}_${end_year}_YMM.nc
mv tmp_${domain}_climate_cru_TS40_historical_${start_year}_${end_year}_YMM.nc ${domain}_climate_cru_TS40_historical_${start_year}_${end_year}_YMM.nc
cdo -L -O -f nc4 -z zip_2 timmean ${domain}_climate_cru_TS40_historical_${start_year}_${end_year}_YMM.nc ${domain}_climate_cru_TS40_historical_${start_year}_${end_year}_TM.nc

