#!/bin/bash

n=72
grid=5000
duration=5000
odir=2020_04_climate

python initialization.py -e alaska.csv -s chinook -q t2standard --domain akglaciers -g ${grid} -n${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep 100


n=140
grid=2000
duration=2000
odir=2020_05_cru_m4

python initialization.py -e alaska.csv -s pleiades_broadwell -q long -w 60:00:00  --domain akglaciers -g ${grid} -n${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep 100 -i  2020_05_cru/state/akglaciers_g5000m_id_CRU-DEF-4_0_20000.nc 


n=140
grid=1000
duration=100
odir=2020_05_cru_m4

python initialization.py -e alaska.csv -s pleiades_broadwell -q long -w 60:00:00  --domain akglaciers -g ${grid} -n${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep 10 -i  2020_05_cru_m4/state/akglaciers_g2000m_id_CRU-DEF-4_0_2000.nc

n=140
grid=500
duration=100
odir=2020_05_cru_m4

python initialization.py -e alaska.csv -s pleiades_broadwell -q long -w 60:00:00  --domain akglaciers -g ${grid} -n${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep 10 -i  2020_05_cru_m4/state/akglaciers_g2000m_id_CRU-DEF-4_0_2000.nc





n=140
grid=2000
duration=2000
odir=2020_05_cru_m1

python initialization.py -e alaska.csv -s pleiades_broadwell -q long -w 60:00:00  --domain akglaciers -g ${grid} -n${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep 100 -i  2020_05_cru/state/akglaciers_g5000m_id_CRU-DEF-1_0_20000.nc 

n=140
grid=1000
duration=100
odir=2020_05_cru_m1

python initialization.py -e alaska.csv -s pleiades_broadwell -q long -w 60:00:00  --domain akglaciers -g ${grid} -n${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep 10 -i  2020_05_cru_m1/state/akglaciers_g2000m_id_CRU-DEF-1_0_2000.nc

n=140
grid=500
duration=100
odir=2020_05_cru_m1

python initialization.py -e alaska.csv -s pleiades_broadwell -q long -w 60:00:00  --domain akglaciers -g ${grid} -n${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep 10 -i  2020_05_cru_m1/state/akglaciers_g2000m_id_CRU-DEF-1_0_2000.nc


n=140
grid=2000
duration=2000
odir=2020_05_cru_m0

python initialization.py -e alaska.csv -s pleiades_broadwell -q long -w 60:00:00  --domain akglaciers -g ${grid} -n${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep 100 -i  2020_05_cru/state/akglaciers_g5000m_id_CRU-DEF-0_0_20000.nc 

n=84
grid=5000
duration=20000
odir=2020_05_cru

python initialization.py -e alaska.csv -s pleiades_broadwell -q long -w 8:00:00  --domain akglaciers -g ${grid} -n${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep 100

n=84
grid=5000
duration=20000
odir=2020_05_sensitivity

python initialization.py -e alaska.csv -s pleiades_broadwell -q long -w 8:00:00  --domain akglaciers -g ${grid} -n${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep 100


n=140
grid=2000
duration=5000
step=2500
odir=2020_05_sensitivity

for T in -5; do
    for w in 3 5 7; do
        python initialization.py -e alaska.csv -s pleiades_broadwell -q long -w 68:00:00  --domain akglaciers -g ${grid} -n${n} --duration ${duration} --step ${step} --o_dir ${odir} --exstep 100 -i  2020_05_sensitivity/state/akglaciers_g5000m_id_CRU-DEF${T}_P_${w}_0_20000.nc
        qsub /nobackupp8/aaschwan/pism-arctic/initialization/2020_05_sensitivity/run_scripts/run_g${grid}m_id_CRU-DEF${T}_P_${w}_j.sh
    done
done

n=140
grid=1000
duration=100
step=100
odir=2020_05_sensitivity

for T in -5; do
    for w in 3; do
        python initialization.py -e alaska.csv -s pleiades_broadwell -q long -w 36:00:00  --domain akglaciers -g ${grid} -n${n} --duration ${duration} --step ${step} --o_dir ${odir} --exstep 100 -i  2020_05_sensitivity/state/akglaciers_g2000m_id_CRU-DEF${T}_P_${w}_2500_5000.nc
        qsub /nobackupp8/aaschwan/pism-arctic/initialization/2020_05_sensitivity/run_scripts/run_g${grid}m_id_CRU-DEF${T}_P_${w}_j.sh
    done
done




n=140
grid=2000
duration=5000
odir=2020_05_m4

python initialization.py -e alaska.csv -s pleiades_broadwell -q long -w 80:00:00  --domain akglaciers -g ${grid} -n${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep 100 -i 2020_04_cru/state/akglaciers_g2000m_id_CRU-DEF-4_0_10000_backup.nc

n=140
grid=2000
duration=5000
odir=2020_05_m5

python initialization.py -e alaska.csv -s pleiades_broadwell -q long -w 80:00:00  --domain akglaciers -g ${grid} -n${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep 100 -i 2020_05_cru/state/akglaciers_g5000m_id_CRU-DEF-5_0_20000.nc 


n=72
grid=5000
duration=10
odir=2020_04_test

python initialization.py -e alaska.csv -s chinook -q t2standard --domain akglaciers -g ${grid} -n${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep 1


odir=2019_11_test
d=akglaciers

n=120
grid=5000

python initialization.py --spatial_ts basic --exstep 10 -d ${d} --o_dir ${odir} -q t2standard -s chinook -w 2:00:00 -n ${n} -g ${grid} -e ../uncertainty_quantification/alaska.csv 

n=240
grid=1000

python initialization.py --spatial_ts basic --exstep 10 --duration 200 --step 200 -d ${d} --o_dir ${odir} -q t2standard -s chinook -w 24:00:00 -n ${n} -g ${grid} -e ../uncertainty_quantification/alaska.csv -i 2019_11_test/state/akglaciers_g5000m_v3a_id_CTRL_0_1000.nc

python initialization.py --spatial_ts basic --exstep 1 --duration 100 --step 100 -d ${d} --o_dir ${odir} -q t2standard -s chinook -w 24:00:00 -n ${n} -g ${grid} -e ../uncertainty_quantification/alaska.csv -i 2019_11_test/state/akglaciers_g1000m_id_CTRL_0_200.nc


n=120
grid=2000

odir=2019_11_pdd

python initialization.py --spatial_ts pdd --exstep monthly --duration 2 --step 2 -d ${d} --o_dir ${odir} -q t2standard -s chinook -w 2:00:00 -n ${n} -g ${grid} -e ../uncertainty_quantification/alaska.csv -i 2019_11_test/state/akglaciers_g1000m_id_CTRL_0_200.nc


n=12
grid=10000

odir=2019_11_pdd

python initialization.py --spatial_ts pdd --exstep monthly --duration 2 --step 2 -d ${d} --o_dir ${odir} -q t2standard -s chinook -w 2:00:00 -n ${n} -g ${grid} -e ../uncertainty_quantification/alaska.csv -i 2019_11_test/state/akglaciers_g1000m_id_CTRL_0_200.nc



n=120
grid=1000
duration=1
odir=2020_05_cru_m1_diff

python initialization.py -e alaska.csv -s chinook -q t2standard -w 01:00:00  --domain akglaciers -g ${grid} -n${n} --duration ${duration} --step ${duration} --o_dir ${odir} --exstep 1 -i  2020_05_cru_m1/state/akglaciers_g2000m_id_CRU-DEF-1_0_2000.nc
