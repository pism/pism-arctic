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

pmip_dir=PMIP3_Alaska_project
cdo_opt="-L -O -f nc4 -z zip_2"

for gcm in CCSM4 CNRM-CM5 GISS-E2-R IPSL-CM5A-LR MIROC-ESM MPI-ESM-P MRI-CGCM3; do
    pr_Amon_CCSM4_historical_r1i1p1_198001-200512.ltm.nc
    cdo $cdo_opt merge ${pmip_dir}/${gcm}/lgm/ts_*.nc -setattribute,pr@units="kg m-2 year-1" -mulc,3.15569259747e7 ${pmip_dir}/${gcm}/lgm/pr_*.nc ${gcm}_lgm.nc
    cdo $cdo_opt merge ${pmip_dir}/${gcm}/historical/ts_*.nc -setattribute,pr@units="kg m-2 year-1" -mulc,3.15569259747e7 ${pmip_dir}/${gcm}/historical/pr_*.nc ${gcm}_historical.nc
    cdo $cdo_opt chname,ts,air_temp_anomaly,pr,precipitation_anomaly -remapbil,../../grids/akglaciers_2km.txt -sub ${gcm}_lgm.nc ${gcm}_historical.nc ${domain}_${gcm}_lgm_historical.nc
    adjust_timeline.py -c 365_day -a 1-1-1 -d 1-1-1 -p monthly ${domain}_${gcm}_lgm_historical.nc
    # cdo $cdo_opt yseasmean ${domain}_${gcm}_lgm_historical.nc ${domain}_${gcm}_lgm_historical_YSM.nc
    # cdo $cdo_opt fldmean ${domain}_${gcm}_lgm_historical_YSM.nc ${domain}_${gcm}_lgm_historical_YSM_fldmean.nc    
    # cdo $cdo_opt fldmean ${domain}_${gcm}_lgm_historical.nc ${domain}_${gcm}_lgm_historical_fldmean.nc
    # cdo $cdo_opt timmean ${domain}_${gcm}_lgm_historical_fldmean.nc ${domain}_${gcm}_lgm_historical_fldmean_TM.nc

done

