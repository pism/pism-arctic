#!/bin/bash

set -x -e

icethicknessdir=/Volumes/79n/millan-global-ice-thickness
mcbed=BedMachineGreenland-2017-09-20.nc

options='-overwrite -r average -co FORMAT=NC4 -co COMPRESS=DEFLATE -co ZLEVEL=1'
optionsbil='-overwrite -r bilinear -co COMPRESS=LZW -co BIGTIFF=YES'

epsg=5936

domain=arctic

x_min=-5800000
y_min=-5800000
x_max=9800000
y_max=9800000

domain=akglaciers

x_min=1600000.0
x_max=3600000.0
y_min=-1920000.0
y_max=-860000.0

domain=atna

x_min=2000000.0
x_max=2800000.0
y_min=-1500000.0
y_max=-1000000.0


v=2022
options='-overwrite -t_srs EPSG:5936 -r average -co FORMAT=NC4 -co COMPRESS=DEFLATE -co ZLEVEL=1'
grid=2000

CUT="-dstnodata 0 -cutline  ../shape_files/no-model-domain.shp"

# grid=1000

# gdalwarp $optionsbil -dstnodata -9999 -s_srs EPSG:4326 -t_srs EPSG:${epsg} -te $x_min $y_min $x_max $y_max  -tr $grid $grid gebco_2021_n90.0_s45.0_w-180.0_e0.0.nc ${domain}_v${v}_g${grid}m.tif

for grid in 500 1000 2000 5000 10000 20000 40000; do
    # Surface from GEBCO
    gdalwarp $options -dstnodata -9999 -s_srs EPSG:4326 -t_srs EPSG:${epsg} -te $x_min $y_min $x_max $y_max  -tr $grid $grid gebco_2021_n90.0_s45.0_w-180.0_e0.0.nc pism_${domain}_v${v}_g${grid}m.nc
    ncrename -v Band1,surface  pism_${domain}_v${v}_g${grid}m.nc
    ncatted -a _FillValue,surface,d,, -a standard_name,surface,o,c,"surface_altitude"  pism_${domain}_v${v}_g${grid}m.nc
    
    # Ice thickness from Bedmachine
    gdalwarp $options -dstnodata 0 -s_srs EPSG:3413 -t_srs EPSG:${epsg} -te $x_min $y_min $x_max $y_max  -tr $grid $grid NETCDF:"${mcbed}":thickness pism_gris_g${grid}m_thickness.nc
    ncrename -v Band1,gris_thickness  pism_gris_g${grid}m_thickness.nc
    ncatted -a _FillValue,gris_thickness,d,,  pism_gris_g${grid}m_thickness.nc
    ncks -A -v gris_thickness pism_gris_g${grid}m_thickness.nc  pism_${domain}_v${v}_g${grid}m.nc

    # Alaska Ice Thickness (Millan)
    gdalwarp $options  -dstnodata 0 -te $x_min $y_min $x_max $y_max -tr $grid $grid ${icethicknessdir}/THICKNESS-RGI-merged_EPSG_${epsg}.vrt pism_${domain}_v${v}_g${grid}m_thickness.nc
    ncrename -v Band1,arctic_thickness pism_${domain}_v${v}_g${grid}m_thickness.nc
    ncatted -a _FillValue,arctic_thickness,d,,  pism_${domain}_v${v}_g${grid}m_thickness.nc
    ncks -A -v arctic_thickness pism_${domain}_v${v}_g${grid}m_thickness.nc  pism_${domain}_v${v}_g${grid}m.nc

    # Generate bed and ice thickness
    ncap2 -O -s "thickness=arctic_thickness+gris_thickness; topg=surface-thickness; ftt_mask=topg*0 + 1; where(thickness<0) {thickness=0;};"  pism_${domain}_v${v}_g${grid}m.nc  pism_${domain}_v${v}_g${grid}m.nc
    ncatted  -a standard_name,ftt_mask,d,, -a standard_name,topg,o,c,"bedrock_altitude" -a standard_name,thickness,o,c,"land_ice_thickness" -a _FillValue,topg,d,, -a _FillValue,thickness,d,, -a units,thickness,o,c,"m" -a units,topg,o,c,"m" -a units,surface,o,c,"m" -a units,ftt_mask,d,, pism_${domain}_v${v}_g${grid}m.nc

    gdalwarp $options -dstnodata 1 -cutline ../shape_files/akglaciers-domain.shp pism_${domain}_v${v}_g${grid}m_thickness.nc  ${domain}_v${v}_g${grid}m_akglaciers_mask.nc
    ncatted -a _FillValue,Band1,d,,  ${domain}_v${v}_g${grid}m_akglaciers_mask.nc
    ncap2 -O -s "ftt_mask=Band1*0; where(Band1==1) ftt_mask=1; thickness=Band1*0;"  ${domain}_v${v}_g${grid}m_akglaciers_mask.nc  ${domain}_v${v}_g${grid}m_akglaciers_mask.nc
    ncatted  -a units,thickness,o,c,"m" -a standard_name,thickness,o,c,"land_ice_thickness"  ${domain}_v${v}_g${grid}m_akglaciers_mask.nc
    ncks -O -v ftt_mask,thickness ${domain}_v${v}_g${grid}m_akglaciers_mask.nc ${domain}_v${v}_g${grid}m_akglaciers_mask.nc

    for var in thickness topg surface; do
        gdalwarp $options -te $x_min $y_min $x_max $y_max -tr $grid $grid NETCDF:pism_${domain}_v${v}_g${grid}m.nc:${var} ${domain}_v${v}_epsg${epsg}_g${grid}m_${var}.tif
    done
done

x_min=1600000.0
x_max=3600000.0
y_min=-1920000.0
y_max=-860000.0

# gdal_translate -projwin $x_min $y_max $x_max $y_min ${icethicknessdir}/RGI60-merged_EPSG_${epsg}.vrt akglaciersRGI60-merged_EPSG_${epsg}.vrt 
