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


options='-overwrite -t_srs EPSG:5936 -r bilinear -co FORMAT=NC4 -co COMPRESS=DEFLATE -co ZLEVEL=1'
grid=2000

# # file=pr_decadal_summaries_AK_CAN_2km_CRU_TS31_historical.zip
# file=pr_AK_CAN_2km_CRU_TS40_historical.zip
# wget -nc http://data.snap.uaf.edu/data/Base/AK_CAN_2km/historical/CRU_TS/Historical_Monthly_and_Derived_Precipitation_Products_2km_CRU_TS/$file
# unzip -f $file

# # file=tas_decadal_summaries_AK_CAN_2km_CRU_TS31_historical.zip
# file=tas_AK_CAN_2km_CRU_TS40_historical.zip
# wget -nc http://data.snap.uaf.edu/data/Base/AK_CAN_2km/historical/CRU_TS/Historical_Monthly_and_Derived_Temperature_Products_2km_CRU_TS/$file
# unzip -f  $file

# # file=iem_prism_dem_1km.tif
# # wget -nc http://data.snap.uaf.edu/data/IEM/Inputs/ancillary/elevation/$file
# # unzip -f  $file

start_year=1980
end_year=2005

for year in {1980..2005}; do
    for mon in 0{1..9} {10..12} ; do
        gdalwarp $options -te $x_min $y_min $x_max $y_max -tr $grid $grid pr/pr_total_mm_CRU_TS40_historical_${mon}_${year}.tif pr/pr_total_mm_CRU_TS40_historical_${mon}_${year}_${domain}.nc
        gdalwarp $options -te $x_min $y_min $x_max $y_max -tr $grid $grid tas/tas_mean_C_CRU_TS40_historical_${mon}_${year}.tif tas/tas_mean_C_CRU_TS40_historical_${mon}_${year}_${domain}.nc
        cdo settaxis,${year}-${mon}-1 -setreftime,${start_year}-1-1  pr/pr_total_mm_CRU_TS40_historical_${mon}_${year}_${domain}.nc  pr/pr_total_mm_CRU_TS40_historical_${mon}_${year}_cdo_${domain}.nc
        cdo settaxis,${year}-${mon}-1 -setreftime,${start_year}-1-1  tas/tas_mean_C_CRU_TS40_historical_${mon}_${year}_${domain}.nc  tas/tas_mean_C_CRU_TS40_historical_${mon}_${year}_cdo_${domain}.nc
    done
done

exit

gdalwarp $options -te $x_min $y_min $x_max $y_max -tr $grid $grid AKCanada_2km_DEM_mosaic.tif ${domain}_AKCanada_2km_DEM_mosaic_${domain}.nc

cdo setattribute,precipitation@units="kg m-2 year-1",precipitation@standard_name="precipitation_flux" -chname,Band1,precipitation -mulc,12 -mergetime pr/pr_total_mm_CRU_TS40_historical_*_*_cdo_${domain}.nc  pr_total_mm_CRU_TS40_historical_${start_year}_${end_year}_${domain}_MM.nc
cdo setattribute,air_temp@units="degree_Celsius" -selvar,air_temp -chname,Band1,air_temp -mergetime tas/tas_mean_C_CRU_TS40_historical_*_*_cdo_${domain}.nc tas_mean_C_CRU_TS40_historical_${start_year}_${end_year}_${domain}_MM.nc

cdo setattribute,usurf@units="m",usurf@standard_name="surface_elevation" -chname,Band1,usurf  ${domain}_AKCanada_2km_DEM_mosaic_${domain}.nc usurf_akcanada_2km_dem_${domain}.nc

cdo -O -f nc4 -z zip_3 setmisstoc,0 -merge usurf_akcanada_2km_dem_${domain}.nc -selyear,${start_year}/${end_year} pr_total_mm_CRU_TS40_historical_${start_year}_${end_year}_${domain}_MM.nc  -selyear,${start_year}/${end_year} tas_mean_C_CRU_TS40_historical_${start_year}_${end_year}_${domain}_MM.nc ${domain}_climate_cru_TS40_historical_${start_year}_${end_year}_MM.nc
adjust_timeline.py -a ${start_year}-1-1 -d ${start_year}-1-1 -p monthly ${domain}_climate_cru_TS40_historical_${start_year}_${end_year}_MM.nc

cdo -O -f nc4 -z zip_1 setmisstoc,0 -merge usurf_akcanada_2km_dem_${domain}.nc -selvar,precipitation,air_temp -ymonmean ${domain}_climate_cru_TS40_historical_${start_year}_${end_year}_MM.nc ${domain}_climate_cru_TS40_historical_${start_year}_${end_year}_YMM.nc
adjust_timeline.py -a 1-1-1 -d 1-1-1 -p monthly -c 365_day ${domain}_climate_cru_TS40_historical_${start_year}_${end_year}_YMM.nc

cdo -O -f nc4 -z zip_1 yseasmean ${domain}_climate_cru_TS40_historical_${start_year}_${end_year}_MM.nc ${domain}_climate_cru_TS40_historical_${start_year}_${end_year}_YSM.nc


cdo -O -f nc4 -z zip_3 timmean -selyear,${start_year}/${end_year} ${domain}_climate_cru_TS40_historical_${start_year}_${end_year}_MM.nc  ${domain}_climate_cru_TS40_historical_${start_year}_${end_year}_TM.nc

gdal_translate NETCDF:${domain}_climate_cru_TS40_historical_${start_year}_${end_year}_TM.nc:precipitation ${domain}_climate_cru_TS40_historical_${start_year}_${end_year}_TM_precip.tif
gdal_translate NETCDF:${domain}_climate_cru_TS40_historical_${start_year}_${end_year}_TM.nc:air_temp ${domain}_climate_cru_TS40_historical_${start_year}_${end_year}_TM_air_temp.tif
gdal_translate NETCDF:${domain}_climate_cru_TS40_historical_${start_year}_${end_year}_TM.nc:air_temp_sd ${domain}_climate_cru_TS40_historical_${start_year}_${end_year}_TM_air_temp_sd.tif
gdal_translate NETCDF:${domain}_climate_cru_TS40_historical_${start_year}_${end_year}_TM.nc:usurf ${domain}_climate_cru_TS40_historical_${start_year}_${end_year}_TM_usurf.tif

