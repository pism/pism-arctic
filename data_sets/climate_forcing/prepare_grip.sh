#!opt/local/bin/bash
set -x

export HDF5_USE_FILE_LOCKING=FALSE

grip_dir=GRIP_Alaska_project
cdo_opt="-L -O -f nc4 -z zip_2"

cdo $cdo_opt selyear,-20999/1/100 ${grip_dir}/grip_johnsen1995.nc ${grip_dir}/grip_johnsen1995_lgm_present.nc #select the years since 21000 BP until present day (1950 CE)
cdo $cdo_opt selyear,-20999/-20999 ${grip_dir}/grip_johnsen1995.nc ${grip_dir}/grip_johnsen1995_lgm_ref.nc #select only the year '21000 BP', which is saved as 20999


cdo $cdo_opt sub ${grip_dir}/grip_johnsen1995_lgm_present.nc ${grip_dir}/grip_johnsen1995_lgm_ref.nc grip_johnsen1995_lgm_norm_dT.nc # subtract the lgm reference from all data, to have the anomaly from the lgm point of view

