
x_min=-1100000
y_min=300000
x_max=2000000
y_max=2400000

options='-overwrite -co "FORMAT=NC4" -co "COMPRESS=DEFLATE" -co "ZLEVEL=3"'
for grid in 250 500 1000 2000 5000 10000; do
    gdalwarp $options -s_srs EPSG:4326 -t_srs EPSG:3338 -te $x_min $y_min $x_max $y_max -r average -tr $grid $grid GEBCO_2019.nc pism_alaska_g${grid}m.nc
    ncrename -v Band1,topg  pism_alaska_g${grid}m.nc
    ncatted -a standard_name,topg,o,c,"bedrock_altitude"  pism_alaska_g${grid}m.nc
done
