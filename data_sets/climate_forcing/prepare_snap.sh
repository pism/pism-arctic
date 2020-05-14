#!opt/local/bin/bash

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


options='-overwrite -t_srs EPSG:5936 -r average -co FORMAT=NC4 -co COMPRESS=DEFLATE -co ZLEVEL=1'
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


for year in {2000..2009}; do
    for mon in 0{1..9} {10..12} ; do
        gdalwarp $options -te $x_min $y_min $x_max $y_max -tr $grid $grid pr/pr_total_mm_CRU_TS40_historical_${mon}_${year}.tif pr/pr_total_mm_CRU_TS40_historical_${mon}_${year}_${domain}.nc
        gdalwarp $options -te $x_min $y_min $x_max $y_max -tr $grid $grid tas/tas_mean_C_CRU_TS40_historical_${mon}_${year}.tif tas/tas_mean_C_CRU_TS40_historical_${mon}_${year}_${domain}.nc
        cdo settaxis,${year}-${mon}-1 -setreftime,2000-1-1  pr/pr_total_mm_CRU_TS40_historical_${mon}_${year}_${domain}.nc  pr/pr_total_mm_CRU_TS40_historical_${mon}_${year}_cdo_${domain}.nc
        cdo settaxis,${year}-${mon}-1 -setreftime,2000-1-1  tas/tas_mean_C_CRU_TS40_historical_${mon}_${year}_${domain}.nc  tas/tas_mean_C_CRU_TS40_historical_${mon}_${year}_cdo_${domain}.nc
    done
done

gdalwarp $options -te $x_min $y_min $x_max $y_max -tr $grid $grid AKCanada_2km_DEM_mosaic.tif ${domain}_AKCanada_2km_DEM_mosaic_${domain}.nc

cdo setattribute,precipitation@units="kg m-2 year-1",precipitation@standard_name="precipitation_flux" -chname,Band1,precipitation -mergetime pr/pr_total_mm_CRU_TS40_historical_*_*_cdo_${domain}.nc  pr_total_mm_CRU_TS40_historical_2000_2009_${domain}_MM.nc
cdo setattribute,air_temp@units="degree_Celsius" -selvar,air_temp -chname,Band1,air_temp -mergetime tas/tas_mean_C_CRU_TS40_historical_*_*_cdo_${domain}.nc tas/tas_mean_C_CRU_TS40_historical_2000_2009_${domain}_MM.nc

cdo setattribute,usurf@units="m",usurf@standard_name="surface_elevation" -chname,Band1,usurf  ${domain}_AKCanada_2km_DEM_mosaic_${domain}.nc usurf_akcanada_2km_dem_${domain}.nc

cdo -O -f nc4 -z zip_3 setmisstoc,0 -merge usurf_akcanada_2km_dem_${domain}.nc -selyear,2000/2009 pr_total_mm_CRU_TS40_historical_2000_2009_${domain}_MM.nc  -selyear,2000/2009 tas/tas_mean_C_CRU_TS40_historical_2000_2009_${domain}_MM.nc ${domain}_climate_cru_TS40_historical_2000_2009_MM.nc
adjust_timeline.py -a 2000-1-1 -d 2000-1-1 -p monthly ${domain}_climate_cru_TS40_historical_2000_2009_MM.nc

cdo -O -f nc4 -z zip_3 merge -setattribute,air_temp_sd@units="K" -yearstd -chname,air_temp,air_temp_sd -selvar,air_temp ${domain}_climate_cru_TS40_historical_2000_2009_MM.nc -yearmean -selvar,air_temp,usurf ${domain}_climate_cru_TS40_historical_2000_2009_MM.nc -yearsum -selvar,precipitation ${domain}_climate_cru_TS40_historical_2000_2009_MM.nc ${domain}_climate_cru_TS40_historical_2000_2009_YM.nc
cdo -O -f nc4 -z zip_3 timmean -selyear,2000/2009 ${domain}_climate_cru_TS40_historical_2000_2009_YM.nc  ${domain}_climate_cru_TS40_historical_2000_2009_TM.nc

gdal_translate NETCDF:${domain}_climate_cru_TS40_historical_2000_2009_TM.nc:precipitation ${domain}_climate_cru_TS40_historical_2000_2009_TM_precip.tif
gdal_translate NETCDF:${domain}_climate_cru_TS40_historical_2000_2009_TM.nc:air_temp ${domain}_climate_cru_TS40_historical_2000_2009_TM_air_temp.tif
gdal_translate NETCDF:${domain}_climate_cru_TS40_historical_2000_2009_TM.nc:air_temp_sd ${domain}_climate_cru_TS40_historical_2000_2009_TM_air_temp_sd.tif
gdal_translate NETCDF:${domain}_climate_cru_TS40_historical_2000_2009_TM.nc:usurf ${domain}_climate_cru_TS40_historical_2000_2009_TM_usur.tif


# Created Merged Climate

cdo -O -f nc4 merge -selvar,precipitation akglaciers_climate_cru_TS40_historical_2000_2009_TM.nc -selvar,air_temp,air_temp_sd,usurf akglaciers_climate_MERRA2_2000_2009_TM.nc akglaciers_climate_m2_cru_2000_2009_TM.nc
