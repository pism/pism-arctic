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

anom_dir=anomalies
pmip_dir=PMIP3_Alaska_project
cdo_opt="-O -f nc4 -z zip_2"

for gcm in CCSM4 CNRM-CM5 GISS-E2-R IPSL-CM5A-LR MIROC-ESM MPI-ESM-P MRI-CGCM3; do
    mkdir -p ${pmip_dir}/${gcm}/${anom_dir}
    cdo $cdo_opt chname,ts,air_temp_anomaly,pr,precipitation_anomaly -remapycon,../../grids/akglaciers_2km.txt -sub -merge "${pmip_dir}/${gcm}/lgm/pr_*.nc ${pmip_dir}/${gcm}/lgm/ts_*.nc" -setattribute,pr@units="kg m-2 yr-1" -mulc,3.15569259747e7 -merge "${pmip_dir}/${gcm}/historical/pr_*.nc ${pmip_dir}/${gcm}/historical/ts_*.nc" ${domain}_${gcm}_lgm_historical.nc

done
