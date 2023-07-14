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

pmip_dir=PMIP_Alaska_project # folder with a subfolder for each GCM, each GCM-folder has two subfolders /historical and /lgm which contain the tas, ts and pr GCM output for the experiment
cdo_opt="-L -O -f nc4 -z zip_2" #options for cdo to -O overwrite, -z compress the files after each action again, etc.

#CESM2-WACCM-FV2 INM-CM4 MIROC-ES2L MPI-ESM1-2-LR
#CESM2-WACCM-FV2 CNRM-CM5 GISS-E2-R INM-CM4 IPSL-CM5A-LR MIROC-ES2L MIROC-ESM MPI-ESM1-2-LR MPI-ESM-P MRI-CGCM3
for gcm in CESM2-WACCM-FV2 CNRM-CM5 GISS-E2-R INM-CM4 IPSL-CM5A-LR MIROC-ES2L MIROC-ESM MPI-ESM1-2-LR MPI-ESM-P MRI-CGCM3; do
    for experiment in lgm historical; do
        for variable in pr tas ts; do
            cdo ${cdo_opt} mergetime ${pmip_dir}/${gcm}/${experiment}/${variable}_*.nc ${pmip_dir}/${gcm}/${variable}_${experiment}.nc # merge the files into one large file per variable
        done

        cdo $cdo_opt merge ${pmip_dir}/${gcm}/ts_${experiment}.nc ${pmip_dir}/${gcm}/tas_${experiment}.nc ${pmip_dir}/${gcm}/tstas_${experiment}.nc # merge tas and ts 
        cdo $cdo_opt merge ${pmip_dir}/${gcm}/tstas_${experiment}.nc -setattribute,pr@units="kg m-2 year-1" -mulc,3.15569259747e7 ${pmip_dir}/${gcm}/pr_${experiment}.nc ${pmip_dir}/${gcm}_${experiment}.nc # merge tasts with pr and calculate the pr per year

    done

    cdo $cdo_opt selyear,1980/2004 ${pmip_dir}/${gcm}_historical.nc ${pmip_dir}/${gcm}_historical_1980-2004.nc # from the historical data (1850-2004) only use 1980-2004
    cdo $cdo_opt ymonmean ${pmip_dir}/${gcm}_historical_1980-2004.nc ${pmip_dir}/${gcm}_historical_YMM.nc # calculate yearly monthly means
    cdo $cdo_opt ymonmean ${pmip_dir}/${gcm}_lgm.nc ${pmip_dir}/${gcm}_lgm_YMM.nc # calculated yearly monthly means

    cdo $cdo_opt chname,tas,air_temp_anomaly,ts,surf_temp_anomaly,pr,precipitation_anomaly -remapbil,../../grids/akglaciers_2km.txt -sub ${pmip_dir}/${gcm}_lgm_YMM.nc ${pmip_dir}/${gcm}_historical_YMM.nc ${domain}_${gcm}_lgm_historical.nc
    adjust_timeline.py -c 365_day -a 1-1-1 -d 1-1-1 -p monthly ${domain}_${gcm}_lgm_historical.nc

    for experiment in lgm historical; do
        cdo $cdo_opt chname,tas,air_temp,ts,surf_temp,pr,precipitation -remapbil,../../grids/akglaciers_2km.txt ${pmip_dir}/${gcm}_${experiment}_YMM.nc  ${pmip_dir}/${domain}_${gcm}_${experiment}_YMM.nc
        adjust_timeline.py -c 365_day -a 1-1-1 -d 1-1-1 -p monthly ${pmip_dir}/${domain}_${gcm}_${experiment}_YMM.nc
        cdo $cdo_opt fldmean ${pmip_dir}/${domain}_${gcm}_${experiment}_YMM.nc ${pmip_dir}/${domain}_${gcm}_${experiment}_YMM_fldmean.nc
    done
done

