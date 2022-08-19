#!/bin/bash

n=24
grid=5000
duration=10000
odir=2022_05_init

python run_akglaciers.py -e alaska_present.csv -w 24:00:00 -s chinook -q t2small --domain akglaciers -g ${grid} -n${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep 100


n=24
grid=5000
duration=10000
odir=2022_05_init_ho

python run_akglaciers.py -e alaska_present.csv -w 48:00:00 -s chinook -q t2small --stress_balance blatter --domain akglaciers -g ${grid} -n${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep 100

n=24
grid=2000
duration=100
odir=2022_06_init_ho

python run_akglaciers.py -e alaska_present.csv -w 8:00:00 -s chinook -q t2small --stress_balance blatter --domain akglaciers -g ${grid} -n${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep 1

n=48
grid=1000
duration=10
odir=2022_06_init

python run_akglaciers.py -e alaska_present.csv -w 8:00:00 -s chinook -q t2small --stress_balance ssa+sia --domain atna -g ${grid} -n${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep 1

n=24
grid=2000
duration=10
odir=2022_06_init_ho

python run_akglaciers.py -e alaska_present.csv -w 8:00:00 -s chinook -q t2small --stress_balance blatter --domain atna -g ${grid} -n${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep 1

n=48
grid=1000
duration=10
odir=2022_06_phi_ho

python run_akglaciers.py -e alaska_present.csv -w 8:00:00 -s chinook -q t2small --stress_balance blatter --domain atna -g ${grid} -n${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep 1

n=24
grid=2000
duration=10
odir=2022_06_phi_ho

python run_akglaciers.py -e alaska_present.csv -w 8:00:00 -s chinook -q t2small --stress_balance blatter --domain atna -g ${grid} -n${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep 1

n=24
grid=2000
duration=1000
odir=2022_06_phip

python run_akglaciers.py -e alaska_present.csv -w 18:00:00 -s chinook -q t2small --stress_balance ssa+sia --domain atna -g ${grid} -n${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep 10

n=24
grid=2000
duration=500
odir=2022_06_phip2

python run_akglaciers.py -e alaska_present.csv -w 8:00:00 -s chinook -q t2small --stress_balance ssa+sia --domain atna -g ${grid} -n${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep 10

n=48
grid=1000
duration=5
odir=2022_06_phip_ho

python run_akglaciers.py -e alaska_present.csv -w 8:00:00 -s chinook -q t2small --stress_balance blatter --domain atna -g ${grid} -n${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep 1 -i 2022_06_phip/state/atna_g1000m_id_SNAP-FLUX-0_0_100_backup.nc

n=96
grid=500
duration=1
odir=2022_06_phip_ho

python run_akglaciers.py -e alaska_present.csv -w 18:00:00 -s chinook -q t2standard --stress_balance blatter --domain atna -g ${grid} -n${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep monthly -i 2022_06_phip_ho/state/atna_g1000m_id_SNAP-FLUX-0_0_5.nc

n=96
grid=500
duration=1
odir=2022_06_ho

python run_akglaciers.py -e alaska_present.csv -w 18:00:00 -s chinook -q t2standard --stress_balance blatter --domain atna -g ${grid} -n${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep monthly -i 2022_06_phip_ho/state/atna_g1000m_id_SNAP-FLUX-0_0_5.nc


n=48
grid=1000
duration=100
odir=2022_06_phip

python run_akglaciers.py -e alaska_present.csv -w 18:00:00 -s chinook -q t2small --stress_balance ssa+sia --domain atna -g ${grid} -n${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep 10 -i 2022_06_phip/state/atna_g2000m_id_SNAP-FLUX-0_0_1000.nc

n=72
grid=1000
duration=1
odir=2020_06_hist

python initialization.py -e alaska_present.csv -s chinook -w 1:00:00 -q t2standard --domain akglaciers -g ${grid} -n ${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep monthly

n=48
grid=500
duration=1
odir=2020_09_hist

python run_akglaciers.py -e alaska_present_climate.csv -s chinook -w 1:00:00 -q t2small --spatial_ts climate_testing --test_climate_models --domain akglaciers -g ${grid} -n ${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep yearly

n=48
grid=500
duration=1
odir=2020_09_def

python run_akglaciers.py -e alaska_present_def.csv -s chinook -w 1:00:00 -q t2small --spatial_ts climate_testing --test_climate_models --domain akglaciers -g ${grid} -n ${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep yearly


n=48
grid=500
duration=1
odir=2020_09_def_nofreeze

python run_akglaciers.py -e alaska_present_def.csv -s chinook -w 1:00:00 -q t2small --spatial_ts climate_testing --test_climate_models --domain akglaciers -g ${grid} -n ${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep yearly


n=72
grid=5000
duration=20000
odir=2020_09_lgm

python run_akglaciers.py -e alaska_lgm_gcms.csv -w 80:00:00 -s chinook -q t2standard --domain akglaciers -g ${grid} -n${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep 100

n=72
grid=5000
duration=20000
odir=2020_09_lgm_sl

python run_akglaciers.py -e alaska_lgm_gcms.csv -w 80:00:00 -s chinook -q t2standard --domain akglaciers -g ${grid} -n${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep 100


n=144
grid=2000
duration=5000
odir=2020_09_lgm_sl

for gcm in CCSM4 CNRM-CM5 GISS-E2-R IPSL-CM5A-LR MIROC-ESM MPI-ESM-P MRI-CGCM3; do
    python run_akglaciers.py -e alaska_lgm_gcms.csv --spatial_ts medium -w 120:00:00 -s chinook -q t2standard --domain akglaciers -g ${grid} -n${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep 100 -i ${odir}/state/akglaciers_g5000m_id_${gcm}_0_20000.nc
    sbatch /import/c1/ICESHEET/ICESHEET/pism-arctic/initialization/${odir}/run_scripts/run_g2000m_id_${gcm}_j.sh
done


n=72
grid=5000
duration=10000
odir=2020_09_lgm_sensitivity

python run_akglaciers.py -e alaska_lgm_sensitivity.csv --spatial_ts medium -w 120:00:00 -s chinook -q t2standard --domain akglaciers -g ${grid} -n${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep 100 -i 2020_09_lgm_sl/state/akglaciers_g5000m_id_ MRI-CGCM3_0_20000.nc



n=240
grid=1000
duration=10
odir=2020_06_lgm

for gcm in CCSM4 CNRM-CM5 GISS-E2-R IPSL-CM5A-LR MIROC-ESM MPI-ESM-P MRI-CGCM3; do
    python run_akglaciers.py -e alaska_lgm_gcms.csv --spatial_ts medium -w 120:00:00 -s chinook -q t2standard --domain akglaciers -g ${grid} -n${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep 1 -i ${odir}/state/akglaciers_g2000m_id_${gcm}_0_5000.nc
    sbatch /import/c1/ICESHEET/ICESHEET/pism-arctic/initialization/${odir}/run_scripts/run_g1000m_id_${gcm}_j.sh
done



