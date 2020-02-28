#!/bin/bash

set -x

# ncks -d lat,28000,-1 GEBCO_2019.nc cut_GEBCO_2019.nc

mcbed=BedMachineGreenland-2017-09-20.nc
icethicknessdir=/Volumes/79n/world_ice_thickness

options='-overwrite -r average -co FORMAT=NC4 -co COMPRESS=DEFLATE -co ZLEVEL=1'
optionsbil='-overwrite -r bilinear -co COMPRESS=LZW -co BIGTIFF=YES'

epsg=5936

domain=arctic

x_min=-5800000
y_min=-5800000
x_max=9800000
y_max=9800000

CUT="-dstnodata 0 -cutline  ../shape_files/no-model-domain.shp"

grid=1000

gdalwarp $optionsbil -dstnodata -9999 -s_srs EPSG:4326 -t_srs EPSG:${epsg} -te $x_min $y_min $x_max $y_max  -tr $grid $grid cut_GEBCO_2019.nc ${domain}_g${grid}m.tif

for grid in 500 1000 2000 5000 10000 20000 40000; do
    
    # Surface from GEBCO
    gdalwarp $options -dstnodata -9999 -s_srs EPSG:4326 -t_srs EPSG:${epsg} -te $x_min $y_min $x_max $y_max  -tr $grid $grid cut_GEBCO_2019.nc pism_${domain}_g${grid}m.nc
    ncrename -v Band1,surface  pism_${domain}_g${grid}m.nc
    ncatted -a _FillValue,surface,d,, -a standard_name,surface,o,c,"surface_altitude"  pism_${domain}_g${grid}m.nc
    
    # Ice thickness from Farinotti & Huss
    gdalwarp $options  -dstnodata 0 -te $x_min $y_min $x_max $y_max -tr $grid $grid ${icethicknessdir}/RGI60-merged_EPSG_${epsg}.vrt ${domain}_g${grid}m_thickness.nc
    ncrename -v Band1,arctic_thickness ${domain}_g${grid}m_thickness.nc
    ncatted -a _FillValue,arctic_thickness,d,,  ${domain}_g${grid}m_thickness.nc
    ncks -A -v arctic_thickness ${domain}_g${grid}m_thickness.nc  pism_${domain}_g${grid}m.nc

    # Ice thickness from Bedmachine
    gdalwarp $options -dstnodata 0 -s_srs EPSG:3413 -t_srs EPSG:${epsg} -te $x_min $y_min $x_max $y_max  -tr $grid $grid NETCDF:"${mcbed}":thickness pism_gris_g${grid}m_thickness.nc
    ncrename -v Band1,gris_thickness  pism_gris_g${grid}m_thickness.nc
    ncatted -a _FillValue,gris_thickness,d,,  pism_gris_g${grid}m_thickness.nc
    ncks -A -v gris_thickness pism_gris_g${grid}m_thickness.nc  pism_${domain}_g${grid}m.nc

    # Generate bed and ice thickness
    ncap2 -O -s "thickness=arctic_thickness+gris_thickness; topg=surface-thickness; ftt_mask=topg*0 + 1; where(thickness<0) {thickness=0;};"  pism_${domain}_g${grid}m.nc  pism_${domain}_g${grid}m.nc
    ncatted  -a standard_name,ftt_mask,d,, -a standard_name,topg,o,c,"bedrock_altitude" -a standard_name,thickness,o,c,"land_ice_thickness" -a _FillValue,topg,d,, -a _FillValue,thickness,d,, -a units,thickness,o,c,"m" -a units,topg,o,c,"m" -a units,surface,o,c,"m" -a units,ftt_mask,d,, pism_${domain}_g${grid}m.nc
done

x_min=1600000.0
x_max=3600000.0
y_min=-1920000.0
y_max=-860000.0

gdal_translate -projwin $x_min $y_max $x_max $y_min ${icethicknessdir}/RGI60-merged_EPSG_${epsg}.vrt akglaciersRGI60-merged_EPSG_${epsg}.vrt 
