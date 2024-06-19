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

pmip_dir=ERAinterim # folder with a subfolder for each GCM, each GCM-folder has two subfolders /historical and /lgm which contain the tas, ts and pr GCM output for the experiment
cdo_opt="-L -O -f nc4 -z zip_2" #options for cdo to -O overwrite, -z compress the files after each action again, etc.

#cdo ${cdo_opt} mergetime ${pmip_dir}/data/data_to_do/t2_daily*.nc ${pmip_dir}/t2_daily_wrf_ERA-Interim_historical_tm.nc
#cdo ${cdo_opt} setgrid,${pmip_dir}/ERAinterim_grid ${pmip_dir}/t2_daily_wrf_ERA-Interim_historical_tm.nc ${pmip_dir}/t2_daily_wrf_ERA-Interim_historical_tm_gs.nc
#cdo $cdo_opt remapbil,../../grids/akglaciers_2km.txt ${pmip_dir}/t2_daily_wrf_ERA-Interim_historical_tm_gs.nc ${pmip_dir}/${domain}_t2_daily_wrf_ERA-Interim_historical_tm_gs.nc

#cdo $cdo_opt ymonstd ${pmip_dir}/${domain}_t2_daily_wrf_ERA-Interim_historical_tm_gs.nc ${pmip_dir}/${domain}_t2_daily_wrf_ERA-Interim_historical_tm_gs_YMMstd.nc # calculate yearly monthly means
#cdo -L -O -f nc4 -z zip_2 chname,t2,air_temp_sd ${pmip_dir}/${domain}_t2_daily_wrf_ERA-Interim_historical_tm_gs_YMMstd.nc ${pmip_dir}/${domain}_climate_t2_daily_wrf_ERA-Interim_historical_tm_gs_YMMstd.nc
#adjust_timeline.py -c 365_day -a 1-1-1 -d 1-1-1 -p monthly ${pmip_dir}/${domain}_climate_t2_daily_wrf_ERA-Interim_historical_tm_gs_YMMstd.nc
#cp ${pmip_dir}/${domain}_climate_t2_daily_wrf_ERA-Interim_historical_tm_gs_YMMstd.nc ${domain}_climate_t2_daily_wrf_ERA-Interim_historical_tm_gs_YMMstd.nc
#cdo $cdo_opt fldmean ${domain}_climate_t2_daily_wrf_ERA-Interim_historical_tm_gs_YMMstd.nc ${domain}_climate_t2_daily_wrf_ERA-Interim_historical_tm_gs_YMMstd_fldmean.nc
#cdo $cdo_opt yearmean ${domain}_climate_t2_daily_wrf_ERA-Interim_historical_tm_gs_YMMstd.nc ${domain}_climate_t2_daily_wrf_ERA-Interim_historical_tm_gs_YMMstd_yearmean.nc

for mulcc in 1.2 1.3 1.4 1.5 1.6; do
	cdo $cdo_opt mulc,${mulcc} ${domain}_climate_t2_daily_wrf_ERA-Interim_historical_tm_gs_YMMstd.nc ${domain}_climate_t2_daily_wrf_ERA-Interim_historical_tm_gs_YMMstd_${mulcc}.nc
done
