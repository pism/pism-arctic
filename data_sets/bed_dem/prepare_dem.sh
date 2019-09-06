options='-overwrite -r average -co FORMAT=NC4 -co COMPRESS=DEFLATE -co ZLEVEL=1'


# AK domain

domain=alaska

x_min=-1100000
y_min=300000
x_max=2000000
y_max=2400000

for grid in 250 500 1000 2000 5000 10000; do
    gdalwarp $options -s_srs EPSG:4326 -t_srs EPSG:3338 -te $x_min $y_min $x_max $y_max  -tr $grid $grid GEBCO_2019.nc pism_${domain}_g${grid}m.nc
    ncrename -v Band1,topg  pism_${domain}_g${grid}m.nc
    ncatted -a standard_name,topg,o,c,"bedrock_altitude"  pism_${domain}_g${grid}m.nc
done

domain=atna

x_min=-420000
y_min=150000
x_max=1660000
y_max=1660000

#for grid in 500 1000 2000 5000 10000; do
for grid in 250; do
    gdalwarp $options -dstnodata -9999 -cutline  ../shape_files/atna-domain.shp -s_srs EPSG:4326 -t_srs EPSG:3338 -te $x_min $y_min $x_max $y_max -tr $grid $grid GEBCO_2019.nc pism_${domain}_g${grid}m.nc
    ncrename -v Band1,surface  pism_${domain}_g${grid}m.nc
    ncatted -a standard_name,surface,o,c,"surface_altitude"  pism_${domain}_g${grid}m.nc
    gdalwarp $options  -dstnodata 0 -te $x_min $y_min $x_max $y_max -tr $grid $grid /Volumes/79n/world_ice_thickness/RGI60-01_EPSG_3338.vrt ${domain}_g${grid}m_thickness.nc
    ncks -A -v Band1 ${domain}_g${grid}m_thickness.nc  pism_${domain}_g${grid}m.nc
    ncrename -v Band1,ice_thickness  pism_${domain}_g${grid}m.nc
    ncatted -a _FillValue,ice_thickness,d,, pism_${domain}_g${grid}m.nc
    ncatted -a standard_name,ice_thickness,o,c,"land_ice_thickness"  pism_${domain}_g${grid}m.nc
    ncap2 -O -s "bedrock=surface-ice_thickness;"  pism_${domain}_g${grid}m.nc  pism_${domain}_g${grid}m.nc
    ncatted -a standard_name,bedrock,o,c,"bedrock_altitude" -a _FillValue,bedrock,d,, pism_${domain}_g${grid}m.nc
    ncks -O -4 -L 3 -v Band1 -x  pism_${domain}_g${grid}m.nc  pism_${domain}_g${grid}m.nc
done
