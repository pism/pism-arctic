#!/bin/bash

options='-overwrite -r average -co FORMAT=NC4 -co COMPRESS=DEFLATE -co ZLEVEL=1'

domain=arctic

x_min=-1800000
y_min=-1800000
x_max=5800000
y_max=5800000
mcbed=BedMachineGreenland-2017-09-20.nc

for grid in 1000 2000 5000 10000 20000 40000; do
    gdalwarp $options -s_srs EPSG:4326 -t_srs EPSG:5936 -te $x_min $y_min $x_max $y_max  -tr $grid $grid GEBCO_2019.nc pism_${domain}_g${grid}m.nc
    ncrename -v Band1,topg  pism_${domain}_g${grid}m.nc
    ncatted -a standard_name,topg,o,c,"bedrock_altitude"  pism_${domain}_g${grid}m.nc
    ncap2 -O -s "land_ice_area_fraction_retreat(\$y,\$x)=0b;"  pism_${domain}_g${grid}m.nc  pism_${domain}_g${grid}m.nc
    gdalwarp $options -s_srs EPSG:3413 -t_srs EPSG:5936 -te $x_min $y_min $x_max $y_max  -tr $grid $grid NETCDF:"${mcbed}":bed pism_gris_g${grid}m_bed.nc
    ncrename -v Band1,bed  pism_gris_g${grid}m_bed.nc
    gdalwarp $options -s_srs EPSG:3413 -t_srs EPSG:5936 -te $x_min $y_min $x_max $y_max  -tr $grid $grid NETCDF:"${mcbed}":thickness pism_gris_g${grid}m_thickness.nc
    ncrename -v Band1,thickness  pism_gris_g${grid}m_thickness.nc
    ncks -A -v bed pism_gris_g${grid}m_bed.nc  pism_${domain}_g${grid}m.nc
    ncks -A -v thickness pism_gris_g${grid}m_thickness.nc  pism_${domain}_g${grid}m.nc
    ncap2 -O -s "where(thickness>0.1) {topg=bed;};" pism_${domain}_g${grid}m.nc  pism_${domain}_g${grid}m.nc
done

exit

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
y_min=660000
x_max=1660000
y_max=1660000

for grid in 250 500 1000 2000 5000 10000; do
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
    ncap2 -O -s "land_ice_area_fraction_retreat(\$y,\$x)=0b; where(bedrock>0 && ice_thickness>0) land_ice_area_fraction_retreat=1;"  pism_${domain}_g${grid}m.nc  pism_${domain}_g${grid}m
done
