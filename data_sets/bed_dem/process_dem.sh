#!/bin/bash

set -x -e

epsg=5936
options='-overwrite -r average -co FORMAT=NC4 -co COMPRESS=DEFLATE -co ZLEVEL=2'

default_millan_dir=/Volumes/79n/millan-global-ice-thickness
read -p "Enter path to Millan et al ice thickness (/millan-global-ice-thickness), default=$default_millan_dir: " millan_dir
millan_dir=${millan_dir:-$default_millan_dir}
millan=${millan_dir}/THICKNESS-RGI-merged_EPSG_${epsg}.vrt

default_glodem_dir=.
read -p "Enter path to GLODEM (/ak-glo) default=$default_glodem_dir: " glodem_dir
glodem_dir=${glodem_dir:-$default_glodem_dir}

glodem=${glodem_dir}/ak_glo_90_geoid.tif
glodem_slope=${glodem_dir}/ak_glo_90_geoid_slope.tif

default_gebcodem_dir=.
read -p "Enter path to GEBCO_2022.nc, default=$default_gebcodem_dir: " gebcodem_dir
gebcodem_dir=${gebcodem_dir:-$default_gebcodem_dir}
gebco=${gebcodem_dir}/GEBCO_2022.nc

default_add_malaspina=yes
read -p "Add Malaspina bed (yes/no) default=$default_add_malaspina: " add_malaspina
add_malaspina=${add_malaspina:-$default_add_malaspina}


default_v=2023_mibr
read -p "Enter dataset version; default=$default_v: " v
v=${v:-$default_v}


akglaciers_grid() {

domain=akglaciers
localdomain=akglaciers

x_min=1600000.0
x_max=3600000.0
y_min=-1920000.0
y_max=-860000.0


for grid in 100 250 500 1000 2000 5000; do
    # Surface from GLO 90
    gdalwarp $options -dstnodata 0 -t_srs EPSG:${epsg} -te $x_min $y_min $x_max $y_max  -tr $grid $grid $glodem pism_${domain}_v${v}_g${grid}m_glo.nc
    
    ncrename -v Band1,surface  pism_${domain}_v${v}_g${grid}m_glo.nc
    ncatted -a _FillValue,surface,d,, -a standard_name,surface,o,c,"surface_altitude"  pism_${domain}_v${v}_g${grid}m_glo.nc

    gdalwarp $options -dstnodata 0 -t_srs EPSG:${epsg} -te $x_min $y_min $x_max $y_max  -tr $grid $grid $glodem_slope pism_${domain}_v${v}_g${grid}m_glo_slope.nc
    ncrename -v Band1,slope  pism_${domain}_v${v}_g${grid}m_glo_slope.nc
    ncatted -a _FillValue,slope,d,, pism_${domain}_v${v}_g${grid}m_glo_slope.nc

    gdalwarp $options -dstnodata 0 -t_srs EPSG:${epsg} -te $x_min $y_min $x_max $y_max  -tr $grid $grid $gebco pism_${domain}_v${v}_g${grid}m_gebco.nc
    ncrename -v Band1,surface  pism_${domain}_v${v}_g${grid}m_gebco.nc
    ncatted -a _FillValue,surface,d,, -a standard_name,surface,o,c,"surface_altitude"  pism_${domain}_v${v}_g${grid}m_gebco.nc

    cdo -O -f nc4 ifthenelse pism_${domain}_v${v}_g${grid}m_glo.nc pism_${domain}_v${v}_g${grid}m_glo.nc pism_${domain}_v${v}_g${grid}m_gebco.nc pism_${domain}_v${v}_g${grid}m.nc
    
    
    if [ "${add_malaspina}" == "yes" ]; then
        # Brinkerhoff / Tober bed
        gdalwarp $options -cutline ../shape_files/rgi-malaspina.shp -dstnodata 0 -s_srs EPSG:3338 -t_srs EPSG:${epsg} -te $x_min $y_min $x_max $y_max  -tr $grid $grid malaspina_bed_3338.tif pism_${domain}_v${v}_g${grid}m_malaspina_bed.nc
        ncrename -v Band1,topg pism_${domain}_v${v}_g${grid}m_malaspina_bed.nc
        ncatted -a units,topg,o,c,"m" pism_${domain}_v${v}_g${grid}m_malaspina_bed.nc
        ncap2 -O -s 'topg=double(topg)' pism_${domain}_v${v}_g${grid}m_malaspina_bed.nc pism_${domain}_v${v}_g${grid}m_malaspina_bed.nc
        ncatted -a _FillValue,topg,d,, -a missing_value,topg,d,, pism_${domain}_v${v}_g${grid}m_malaspina_bed.nc
        
    fi

    # Alaska Ice Thickness (Millan)
    gdalwarp $options  -dstnodata 0 -te $x_min $y_min $x_max $y_max -tr $grid $grid $millan pism_${domain}_v${v}_g${grid}m_thickness.nc
    ncrename -v Band1,thickness pism_${domain}_v${v}_g${grid}m_thickness.nc
    ncatted -a _FillValue,thickness,d,,  pism_${domain}_v${v}_g${grid}m_thickness.nc
    ncks -A -v thickness pism_${domain}_v${v}_g${grid}m_thickness.nc  pism_${domain}_v${v}_g${grid}m.nc

    ncks -A -v slope pism_${domain}_v${v}_g${grid}m_glo_slope.nc  pism_${domain}_v${v}_g${grid}m.nc
    
    # Generate bed and ice thickness
    ncap2 -O -s "topg=surface-thickness; ftt_mask=topg*0 + 1; where(thickness<0) {thickness=0;} where(surface<0) {surface=0;};"  pism_${domain}_v${v}_g${grid}m.nc  pism_${domain}_v${v}_g${grid}m.nc
    ncatted  -a standard_name,ftt_mask,d,, -a standard_name,topg,o,c,"bedrock_altitude" -a standard_name,thickness,o,c,"land_ice_thickness" -a _FillValue,topg,d,, -a _FillValue,thickness,d,, -a units,thickness,o,c,"m" -a units,topg,o,c,"m" -a units,surface,o,c,"m" -a units,ftt_mask,d,, pism_${domain}_v${v}_g${grid}m.nc
    
    if [ "${add_malaspina}" == "yes" ]; then
       cdo -O -L -f nc4 ifthenelse -selvar,topg pism_${domain}_v${v}_g${grid}m_malaspina_bed.nc -selvar,topg pism_${domain}_v${v}_g${grid}m_malaspina_bed.nc -selvar,topg pism_${domain}_v${v}_g${grid}m.nc pism_${domain}_v${v}_g${grid}m_topg.nc
    ncks -v topg -A pism_${domain}_v${v}_g${grid}m_topg.nc pism_${domain}_v${v}_g${grid}m.nc
    fi
    
    ncap2 -O -s "thickness=surface-topg; where(thickness<0) thickness=0; where(surface<=0) thickness=0; where(slope>35 && thickness<50) {thickness=0;};" pism_${domain}_v${v}_g${grid}m.nc pism_${domain}_v${v}_g${grid}m.nc
    ncrename -v thickness,thickness_mask pism_${domain}_v${v}_g${grid}m_thickness.nc
    ncks -A -v thickness_mask pism_${domain}_v${v}_g${grid}m_thickness.nc pism_${domain}_v${v}_g${grid}m.nc
    ncap2 -O -s "where(thickness_mask==0) thickness=0;" pism_${domain}_v${v}_g${grid}m.nc pism_${domain}_v${v}_g${grid}m.nc
    ncks -O -v thickness_mask,slope -x pism_${domain}_v${v}_g${grid}m.nc pism_${domain}_v${v}_g${grid}m.nc
    ncatted -a _FillValue,thickness,d,,  pism_${domain}_v${v}_g${grid}m.nc

    # add tillwat
    gdalwarp $options -t_srs EPSG:$epsg -s_srs EPSG:3413  -dstnodata 0 -te $x_min $y_min $x_max $y_max -tr $grid $grid NETCDF:../velocities/ALA_G0240_0000.nc:v  pism_${domain}_v${v}_g${grid}m_velsurf_mag.nc
    ncatted -a _FillValue,Band1,d,, -a units,Band1,o,c,"m" pism_${domain}_v${v}_g${grid}m_velsurf_mag.nc
    ncap2 -O -s "tillwat=Band1*0; where(Band1>100) tillwat=2.0;" pism_${domain}_v${v}_g${grid}m_velsurf_mag.nc pism_${domain}_v${v}_g${grid}m_velsurf_mag.nc
    ncatted -a _FillValue,tillwat,d,, pism_${domain}_v${v}_g${grid}m_velsurf_mag.nc
    ncks -A -v tillwat pism_${domain}_v${v}_g${grid}m_velsurf_mag.nc pism_${domain}_v${v}_g${grid}m.nc
        
    gdalwarp $options -dstnodata 0 -cutline ../shape_files/${localdomain}-domain.shp NETCDF:pism_${domain}_v${v}_g${grid}m.nc:thickness  ${localdomain}_v${v}_g${grid}m_mask.nc
    ncatted -a _FillValue,Band1,d,,  ${localdomain}_v${v}_g${grid}m_mask.nc
    ncap2 -4 -L 2 -O -s "ftt_mask=Band1*0 + 1;"  ${localdomain}_v${v}_g${grid}m_mask.nc  ${localdomain}_v${v}_g${grid}m_mask.nc
    ncrename -v Band1,thickness ${localdomain}_v${v}_g${grid}m_mask.nc
    ncatted  -a units,thickness,o,c,"m" -a standard_name,thickness,o,c,"land_ice_thickness" -a units,ftt_mask,d,, ${localdomain}_v${v}_g${grid}m_mask.nc

    ncatted -a proj,global,o,c,"epsg:5936"  pism_${domain}_v${v}_g${grid}m.nc
    ncatted -a proj,global,o,c,"epsg:5936" ${localdomain}_v${v}_g${grid}m_mask.nc
done
}


akglaciers_grid
