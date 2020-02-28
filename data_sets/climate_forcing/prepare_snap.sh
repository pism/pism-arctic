#!opt/local/bin/bash

epsg=5936

x_min=-5800000
y_min=-5800000
x_max=9800000
y_max=9800000

options='-overwrite -t_srs EPSG:5936 -r average -co FORMAT=NC4 -co COMPRESS=DEFLATE -co ZLEVEL=1'
grid=2000

# file=pr_decadal_summaries_AK_CAN_2km_CRU_TS31_historical.zip
file=pr_AK_CAN_2km_CRU_TS40_historical.zip
wget -nc http://data.snap.uaf.edu/data/Base/AK_CAN_2km/historical/CRU_TS/Historical_Monthly_and_Derived_Precipitation_Products_2km_CRU_TS/$file
unzip -f $file

# file=tas_decadal_summaries_AK_CAN_2km_CRU_TS31_historical.zip
file=tas_AK_CAN_2km_CRU_TS40_historical.zip
wget -nc http://data.snap.uaf.edu/data/Base/AK_CAN_2km/historical/CRU_TS/Historical_Monthly_and_Derived_Temperature_Products_2km_CRU_TS/$file
unzip -f  $file

# file=iem_prism_dem_1km.tif
# wget -nc http://data.snap.uaf.edu/data/IEM/Inputs/ancillary/elevation/$file
# unzip -f  $file


for year in {1910..2015}; do
    for mon in 0{1..9} {10..12} ; do
        gdalwarp $options -te $x_min $y_min $x_max $y_max -tr $grid $grid pr/pr_total_mm_CRU_TS40_historical_${mon}_${year}.tif pr/pr_total_mm_CRU_TS40_historical_${mon}_${year}.nc
        gdalwarp $options -te $x_min $y_min $x_max $y_max -tr $grid $grid tas/tas_mean_C_CRU_TS40_historical_${mon}_${year}.tif tas/tas_mean_C_CRU_TS40_historical_${mon}_${year}.nc
        cdo settaxis,${year}-${mon}-1 -setreftime,1910-1-1  pr/pr_total_mm_CRU_TS40_historical_${mon}_${year}.nc  pr/pr_total_mm_CRU_TS40_historical_${mon}_${year}_cdo.nc
        cdo settaxis,${year}-${mon}-1 -setreftime,1910-1-1  tas/tas_mean_C_CRU_TS40_historical_${mon}_${year}.nc  tas/tas_mean_C_CRU_TS40_historical_${mon}_${year}_cdo.nc
    done
done

gdalwarp $options -te $x_min $y_min $x_max $y_max -tr $grid $grid AKCanada_2km_DEM_mosaic.tif AKCanada_2km_DEM_mosaic.nc

cdo setattribute,precipitation@units="kg m-2 year-1",precipitation@standard_name="precipitation_flux" -chname,Band1,precipitation -mergetime pr/pr_total_mm_CRU_TS40_historical_*_*_cdo.nc  pr_total_mm_CRU_TS40_historical_1910_2015_MM.nc
cdo setattribute,air_temp@units="deg_C" -chname,Band1,air_temp -mergetime tas/tas_mean_C_CRU_TS40_historical_*_*_cdo.nc tas/tas_mean_C_CRU_TS40_historical_1910_2015_MM.nc

cdo setattribute,usurf@units="m",usurf@standard_name="surface_elevation" -chname,Band1,usurf  AKCanada_2km_DEM_mosaic.nc usurf_akcanada_2km_dem.nc
cdo -O -f nc4 -z zip_3 setmisstoc,0 -merge usurf_akcanada_2km_dem.nc pr_total_mm_CRU_TS40_historical_1910_2015_MM.nc tas/tas_mean_C_CRU_TS40_historical_1910_2015_MM.nc climate_cru_TS40_historical_1910_2009_MM.nc
adjust_timeline.py -a 1910-1-1 -d 1910-1-1 -p monthly climate_cru_TS40_historical_1910_2009_MM.nc
cdo -O -f nc4 -z zip_3 merge -yearstd -chname,air_temp,air_temp_sd -selvar,air_temp climate_cru_TS40_historical_1910_2009_MM.nc -yearmean -selvar,air_temp,usurf climate_cru_TS40_historical_1910_2009_MM.nc -yearsum -selvar,precipitation climate_cru_TS40_historical_1910_2009_MM.nc climate_cru_TS40_historical_1910_2009_YM.nc
cdo -O -f nc4 -z zip_3 timmean climate_cru_TS40_historical_1910_2009_YM.nc  climate_cru_TS40_historical_1910_2009_TM.nc
