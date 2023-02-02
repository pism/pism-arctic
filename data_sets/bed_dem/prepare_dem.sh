#!/bin/bash

set -x -e

export HDF5_USE_FILE_LOCKING=FALSE

icethicknessdir=/Volumes/79n/millan-global-ice-thickness
mcbed=BedMachineGreenland-v5.nc

epsg=5936
v=2022_millan
options='-overwrite -t_srs EPSG:5936 -r average -co FORMAT=NC4 -co COMPRESS=DEFLATE -co ZLEVEL=2'


akglaciers_grid() {

domain=akglaciers
localdomain=malaspina

x_min=1600000.0
x_max=3600000.0
y_min=-1920000.0
y_max=-860000.0

for grid in 250 500 1000 2000 5000; do
    # Surface from GEBCO
    gdalwarp $options -dstnodata -9999 -s_srs EPSG:4326 -t_srs EPSG:${epsg} -te $x_min $y_min $x_max $y_max  -tr $grid $grid GEBCO_2022.nc pism_${domain}_v${v}_g${grid}m.nc
    ncrename -v Band1,surface  pism_${domain}_v${v}_g${grid}m.nc
    ncatted -a _FillValue,surface,d,, -a standard_name,surface,o,c,"surface_altitude"  pism_${domain}_v${v}_g${grid}m.nc
    
    # Alaska Ice Thickness (Millan)
    gdalwarp $options  -dstnodata 0 -te $x_min $y_min $x_max $y_max -tr $grid $grid ${icethicknessdir}/THICKNESS-RGI-merged_EPSG_${epsg}.vrt pism_${domain}_v${v}_g${grid}m_thickness.nc
    ncrename -v Band1,thickness pism_${domain}_v${v}_g${grid}m_thickness.nc
    ncatted -a _FillValue,thickness,d,,  pism_${domain}_v${v}_g${grid}m_thickness.nc
    ncks -A -v thickness pism_${domain}_v${v}_g${grid}m_thickness.nc  pism_${domain}_v${v}_g${grid}m.nc

    # Generate bed and ice thickness
    ncap2 -O -s "topg=surface-thickness; ftt_mask=topg*0 + 1; where(thickness<0) {thickness=0;};"  pism_${domain}_v${v}_g${grid}m.nc  pism_${domain}_v${v}_g${grid}m.nc
    ncatted  -a standard_name,ftt_mask,d,, -a standard_name,topg,o,c,"bedrock_altitude" -a standard_name,thickness,o,c,"land_ice_thickness" -a _FillValue,topg,d,, -a _FillValue,thickness,d,, -a units,thickness,o,c,"m" -a units,topg,o,c,"m" -a units,surface,o,c,"m" -a units,ftt_mask,d,, pism_${domain}_v${v}_g${grid}m.nc

    # add tillwat
    gdalwarp $options -s_srs EPSG:3413  -dstnodata 0 -te $x_min $y_min $x_max $y_max -tr $grid $grid NETCDF:../velocities/ALA_G0240_0000.nc:v  pism_${domain}_v${v}_g${grid}m_velsurf_mag.nc
    ncatted -a _FillValue,Band1,d,, -a units,Band1,o,c,"m" pism_${domain}_v${v}_g${grid}m_velsurf_mag.nc
    ncap2 -O -s "tillwat=Band1*0; where(Band1>100) tillwat=2.0;" pism_${domain}_v${v}_g${grid}m_velsurf_mag.nc pism_${domain}_v${v}_g${grid}m_velsurf_mag.nc
    ncatted -a _FillValue,tillwat,d,, pism_${domain}_v${v}_g${grid}m_velsurf_mag.nc
    ncks -A -v tillwat pism_${domain}_v${v}_g${grid}m_velsurf_mag.nc pism_${domain}_v${v}_g${grid}m.nc
        
    gdalwarp $options -dstnodata 0 -cutline ../shape_files/${localdomain}-domain.shp pism_${domain}_v${v}_g${grid}m_thickness.nc  ${localdomain}_v${v}_g${grid}m_mask.nc
    ncatted -a _FillValue,Band1,d,,  ${localdomain}_v${v}_g${grid}m_mask.nc
    ncap2 -4 -L 2 -O -s "ftt_mask=Band1*0 + 1;"  ${localdomain}_v${v}_g${grid}m_mask.nc  ${localdomain}_v${v}_g${grid}m_mask.nc
    ncrename -v Band1,thickness ${localdomain}_v${v}_g${grid}m_mask.nc
    ncatted  -a units,thickness,o,c,"m" -a standard_name,thickness,o,c,"land_ice_thickness"  ${localdomain}_v${v}_g${grid}m_mask.nc

    ncatted -a proj,global,o,c,"epsg:5936"  pism_${domain}_v${v}_g${grid}m.nc
    ncatted -a proj,global,o,c,"epsg:5936" ${localdomain}_v${v}_g${grid}m_mask.nc
done
}

arctic_grid() {

domain=arctic

x_min=-5800000
y_min=-5800000
x_max=9800000
y_max=9800000

for grid in 250; do
    # Surface from GEBCO
    gdalwarp $options -dstnodata -9999 -s_srs EPSG:4326 -t_srs EPSG:${epsg} -te $x_min $y_min $x_max $y_max  -tr $grid $grid GEBCO_2022.nc pism_${domain}_v${v}_g${grid}m.nc
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

    gdalwarp $options -dstnodata 0 -cutline ../shape_files/${localdomain}-domain.shp pism_${domain}_v${v}_g${grid}m_thickness.nc  ${localdomain}_v${v}_g${grid}m_mask.nc
    ncatted -a _FillValue,Band1,d,,  ${localdomain}_v${v}_g${grid}m_mask.nc
    ncap2 -4 -L 2 -O -s "ftt_mask=Band1*0 + 1;"  ${localdomain}_v${v}_g${grid}m_mask.nc  ${localdomain}_v${v}_g${grid}m_mask.nc
    ncrename -v Band1,thickness ${localdomain}_v${v}_g${grid}m_mask.nc
    ncatted  -a units,thickness,o,c,"m" -a standard_name,thickness,o,c,"land_ice_thickness"  ${localdomain}_v${v}_g${grid}m_mask.nc

done
}

alaska_grid() {

domain=alaska

x_min=-0
y_min=-2000000
x_max=5800000
y_max=0

for grid in 500; do
    # Surface from GEBCO
    gdalwarp $options -dstnodata -9999 -s_srs EPSG:4326 -t_srs EPSG:${epsg} -te $x_min $y_min $x_max $y_max  -tr $grid $grid GEBCO_2022.nc pism_${domain}_v${v}_g${grid}m.nc
    ncrename -v Band1,surface  pism_${domain}_v${v}_g${grid}m.nc
    ncatted -a _FillValue,surface,d,, -a standard_name,surface,o,c,"surface_altitude"  pism_${domain}_v${v}_g${grid}m.nc
    

    # Alaska Ice Thickness (Millan)
    gdalwarp $options  -dstnodata 0 -te $x_min $y_min $x_max $y_max -tr $grid $grid ${icethicknessdir}/THICKNESS-RGI-merged_EPSG_${epsg}.vrt pism_${domain}_v${v}_g${grid}m_thickness.nc
    ncrename -v Band1,thickness pism_${domain}_v${v}_g${grid}m_thickness.nc
    ncatted -a _FillValue,thickness,d,,  pism_${domain}_v${v}_g${grid}m_thickness.nc
    ncks -A -v thickness pism_${domain}_v${v}_g${grid}m_thickness.nc  pism_${domain}_v${v}_g${grid}m.nc

    # Generate bed and ice thickness
    ncap2 -O -s "topg=surface-thickness; ftt_mask=topg*0 + 1; where(thickness<0) {thickness=0;};"  pism_${domain}_v${v}_g${grid}m.nc  pism_${domain}_v${v}_g${grid}m.nc
    ncatted  -a standard_name,ftt_mask,d,, -a standard_name,topg,o,c,"bedrock_altitude" -a standard_name,thickness,o,c,"land_ice_thickness" -a _FillValue,topg,d,, -a _FillValue,thickness,d,, -a units,thickness,o,c,"m" -a units,topg,o,c,"m" -a units,surface,o,c,"m" -a units,ftt_mask,d,, pism_${domain}_v${v}_g${grid}m.nc

    ncap2 -O -s "where(surface<0) surface=0;" pism_${domain}_v${v}_g${grid}m.nc ${domain}_v${v}_g${grid}m.nc
    ncap2 -O -s "where(thickness<10) surface=-9999;" pism_${domain}_v${v}_g${grid}m.nc ${domain}_v${v}_g${grid}m_surface_m.nc
    cdo setmissval,-9999 ${domain}_v${v}_g${grid}m_surface_m.nc ${domain}_v${v}_g${grid}m_surface_masked.nc
    for var in surface topg thickness; do
        gdal_translate NETCDF:${domain}_v${v}_g${grid}m.nc:$var ${domain}_v${v}_g${grid}m_${var}.tif
    done
done
}

alaska_grid
#akglaciers_grid
