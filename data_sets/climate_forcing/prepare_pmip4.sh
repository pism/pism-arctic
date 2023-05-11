#!opt/local/bin/bash
set -x

export HDF5_USE_FILE_LOCKING=FALSE
epsg=5936

domain=akglaciers

grid=2000

x_min=1600000.0
x_max=3600000.0
y_min=-1920000.0
y_max=-860000.0

pmip_dir=PMIP4_Alaska_project
cdo_opt="-L -O -f nc4 -z zip_2"

#CESM2-WACCM-FV2 INM-CM4 MIROC-ES2L MPI-ESM1-2-LR
for gcm in CESM2-WACCM-FV2; do

    cdo $cdo_opt merge ${pmip_dir}/${gcm}/lgm/ts_*.nc -setattribute,pr@units="kg m-2 year-1" -mulc,3.15569259747e7 ${pmip_dir}/${gcm}/lgm/pr_*.nc ${gcm}_lgm_yearly.nc
    cdo $cdo_opt merge ${pmip_dir}/${gcm}/historical/ts_*.nc -setattribute,pr@units="kg m-2 year-1" -mulc,3.15569259747e7 ${pmip_dir}/${gcm}/historical/pr_*.nc ${gcm}_185001_201412.nc

    cdo $cdo_opt selyear,1980/2014 ${gcm}_185001_201412.nc ${gcm}_historical_yearly.nc
    cdo $cdo_opt ymonmean ${gcm}_historical_yearly.nc ${gcm}_historical.nc
    cdo $cdo_opt ymonmean ${gcm}_lgm_yearly.nc ${gcm}_lgm.nc

    cdo $cdo_opt chname,ts,air_temp_anomaly,pr,precipitation_anomaly -remapbil,../../grids/akglaciers_2km.txt -sub ${gcm}_lgm.nc ${gcm}_historical.nc ${domain}_${gcm}_lgm_historical.nc
    cdo $cdo_opt chname,ts,air_temp,pr,precipitation -remapbil,../../grids/akglaciers_2km.txt ${gcm}_lgm.nc  ${domain}_${gcm}_lgm.nc
    adjust_timeline.py -c 365_day -a 1-1-1 -d 1-1-1 -p monthly ${domain}_${gcm}_lgm.nc
    cdo $cdo_opt fldmean ${domain}_${gcm}_lgm.nc ${domain}_${gcm}_lgm_fldmean.nc #what for?

    cdo $cdo_opt chname,ts,air_temp,pr,precipitation -remapbil,../../grids/akglaciers_2km.txt ${gcm}_historical.nc  ${domain}_${gcm}_historical.nc #dont understand what this second part does
    cdo $cdo_opt fldmean ${domain}_${gcm}_historical.nc ${domain}_${gcm}_historical_fldmean.nc #what for?
    adjust_timeline.py -c 365_day -a 1-1-1 -d 1-1-1 -p monthly ${domain}_${gcm}_historical.nc

    adjust_timeline.py -c 365_day -a 1-1-1 -d 1-1-1 -p monthly ${domain}_${gcm}_lgm_historical.nc #where does the lgm-historical get calculated?
done

